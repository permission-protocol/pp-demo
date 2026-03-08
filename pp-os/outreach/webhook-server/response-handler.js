/**
 * Response Handler — Generates suggested reply strategies when a lead replies.
 *
 * Called by the webhook server when a reply event comes in.
 * Posts rich context + suggested responses to Discord #rc-alerts.
 */

const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'db', 'outreach.sqlite');

/**
 * Classify reply sentiment based on content analysis
 */
function classifyReply(replyText) {
  if (!replyText) return { sentiment: 'unknown', confidence: 0 };

  const lower = replyText.toLowerCase();

  // Meeting/positive signals
  const meetingSignals = ['call', 'chat', 'meet', 'demo', 'schedule', 'calendar', 'zoom', 'teams', 'free', 'available', 'let\'s talk', 'love to', 'would love', 'interested', 'tell me more', 'sounds good', 'sounds great', 'sign me up'];
  const positiveSignals = ['thanks', 'thank you', 'appreciate', 'interesting', 'cool', 'nice', 'great', 'good point', 'makes sense', 'relevant', 'checking out', 'look into'];
  const negativeSignals = ['not interested', 'no thanks', 'unsubscribe', 'stop', 'remove', 'don\'t contact', 'not relevant', 'no need', 'pass', 'we\'re good', 'already have', 'not looking'];
  const neutralSignals = ['who are you', 'what is this', 'what do you', 'how does', 'tell me about', 'can you explain', 'what\'s the'];

  const meetingScore = meetingSignals.filter(s => lower.includes(s)).length;
  const positiveScore = positiveSignals.filter(s => lower.includes(s)).length;
  const negativeScore = negativeSignals.filter(s => lower.includes(s)).length;
  const neutralScore = neutralSignals.filter(s => lower.includes(s)).length;

  if (meetingScore >= 1) return { sentiment: 'meeting', confidence: Math.min(meetingScore * 0.3 + 0.5, 1) };
  if (negativeScore >= 1) return { sentiment: 'negative', confidence: Math.min(negativeScore * 0.3 + 0.5, 1) };
  if (positiveScore >= 2) return { sentiment: 'positive', confidence: Math.min(positiveScore * 0.2 + 0.4, 1) };
  if (neutralScore >= 1) return { sentiment: 'curious', confidence: Math.min(neutralScore * 0.3 + 0.4, 1) };
  if (positiveScore >= 1) return { sentiment: 'positive', confidence: 0.4 };

  return { sentiment: 'neutral', confidence: 0.3 };
}

/**
 * Generate suggested responses based on reply sentiment and outreach context
 */
function generateSuggestions(sentiment, outreach, replyText) {
  const name = outreach?.name?.split(' ')[0] || 'there'; // First name only
  const company = outreach?.company || 'your company';
  const angle = outreach?.angle || 'accountability';

  const suggestions = [];

  switch (sentiment) {
    case 'meeting':
      suggestions.push({
        label: '📅 Schedule (direct)',
        text: `${name} — great, let's do it. I'm free [Tuesday/Thursday] afternoon MST. Want me to send a calendar invite, or is there a time that works better for you?`
      });
      suggestions.push({
        label: '📅 Schedule (with context)',
        text: `${name} — perfect. I'll keep it tight — 15 min to show how the authorization receipt system works and how it maps to what ${company} is building. When works best this week?`
      });
      break;

    case 'positive':
      suggestions.push({
        label: '🎯 Push toward meeting',
        text: `Glad it resonates. The best way to see if it fits is a quick 15-min walkthrough — I can show the SDK and how receipts work in a live deploy. Want to grab time this week?`
      });
      suggestions.push({
        label: '📎 Share resource',
        text: `Happy to share more. Here's our technical overview: [link]. The TL;DR: cryptographic receipts that bind agent authorization to specific actions — tamper-proof and machine-readable. Let me know if questions come up.`
      });
      break;

    case 'curious':
      suggestions.push({
        label: '📖 Explain concisely',
        text: `Good question. In short: before any AI agent executes a real-world action (deploy, payment, API call), it gets a cryptographic receipt proving exactly what was authorized, by whom, and when. If something goes wrong, the receipt is the proof. Think audit trail that can't be faked.`
      });
      suggestions.push({
        label: '🎯 Explain + meeting ask',
        text: `Quick version: cryptographic authorization receipts for AI agent actions. Before an agent deploys code or processes a payment, it needs a signed receipt. That receipt becomes the audit trail. Much easier to show than explain — got 15 min this week?`
      });
      break;

    case 'negative':
      suggestions.push({
        label: '🤝 Graceful exit',
        text: `Totally understand, ${name}. Appreciate you letting me know. If agent authorization ever comes up on your roadmap, happy to be a resource. Best of luck with ${company}.`
      });
      break;

    case 'neutral':
    default:
      suggestions.push({
        label: '🎯 Re-engage with value',
        text: `${name} — appreciate the response. The core idea: as ${company} gives AI agents more autonomy, you'll need cryptographic proof of what each agent was authorized to do. We built that receipt layer. Want a quick walkthrough?`
      });
      suggestions.push({
        label: '📎 Low-pressure share',
        text: `Thanks for getting back. Here's a 2-min read on how it works: [link]. No pressure — just thought it'd be relevant given what ${company} is building.`
      });
      break;
  }

  return suggestions;
}

/**
 * Build the full Discord alert message for a reply
 */
function buildReplyAlert(outreach, replyText, expandiPayload) {
  const classification = classifyReply(replyText);
  const suggestions = generateSuggestions(classification.sentiment, outreach, replyText);

  const name = outreach?.name || 'Unknown';
  const company = outreach?.company || 'Unknown';
  const angle = outreach?.angle || '?';
  const opener = outreach?.opener || '?';
  const segment = outreach?.segment || '?';

  const sentimentEmoji = {
    meeting: '🔥',
    positive: '💚',
    curious: '🤔',
    neutral: '😐',
    negative: '🔴',
    unknown: '❓',
  }[classification.sentiment] || '❓';

  // Build the thread message
  let lines = [];
  lines.push(`${sentimentEmoji} **Reply from ${name}** (${company})`);
  lines.push('');
  lines.push(`> ${replyText || '(no text captured)'}`);
  lines.push('');
  lines.push(`**Sentiment:** ${classification.sentiment} (${Math.round(classification.confidence * 100)}%)`);
  lines.push(`**Context:** angle=${angle} | opener=${opener} | segment=${segment}`);

  // Steps sent so far
  const stepsInfo = expandiPayload?.campaign_instance_contact?.nr_steps_before_responding;
  if (stepsInfo !== undefined) {
    lines.push(`**Replied after:** ${stepsInfo} campaign step(s)`);
  }

  lines.push('');
  lines.push('**Suggested responses:**');
  suggestions.forEach((s, i) => {
    lines.push(`\n${s.label}`);
    lines.push(`\`\`\`${s.text}\`\`\``);
  });

  lines.push('');
  lines.push('⚡ **Rod: copy/edit a suggestion above and reply on LinkedIn**');

  // Also update the event with classification
  try {
    const db = new Database(DB_PATH);
    db.prepare(`
      UPDATE events SET reply_classification = ?
      WHERE outreach_id = ? AND event_type IN ('replied', 'replied_first')
      ORDER BY id DESC LIMIT 1
    `).run(classification.sentiment, outreach?.outreach_id);
    db.close();
  } catch (err) {
    // Non-critical — classification is nice-to-have
  }

  return {
    outreachLog: `💬 **Reply from ${name}** (${company})\n> ${replyText || '(no text captured)'}\n\nAngle: ${angle} | Sentiment: ${sentimentEmoji} ${classification.sentiment}`,
    alertMessage: lines.join('\n'),
    classification,
  };
}

module.exports = { classifyReply, generateSuggestions, buildReplyAlert };
