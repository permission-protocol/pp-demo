/**
 * PP Outreach Engine — Webhook Receiver
 *
 * Receives Expandi webhook events, logs to SQLite, notifies Discord.
 *
 * Endpoints:
 *   POST /hooks/expandi  — Expandi webhook events
 *   GET  /health         — Health check
 *   GET  /stats          — Quick stats (protected)
 */

const Fastify = require('fastify');
const Database = require('better-sqlite3');
const https = require('https');
const path = require('path');
const { buildReplyAlert } = require('./response-handler');

// --- Config ---
const PORT = process.env.PORT || 3100;
const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'db', 'outreach.sqlite');
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || '';
const DISCORD_BOT_TOKEN = process.env.DISCORD_BOT_TOKEN || '';
const DISCORD_OUTREACH_CHANNEL = process.env.DISCORD_OUTREACH_CHANNEL || '1479273618448846858'; // #outreach-log
const DISCORD_ALERT_CHANNEL = process.env.DISCORD_ALERT_CHANNEL || '1479510743467425854';       // #rc-alerts

// --- DB Setup ---
const db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// Prepared statements
const insertEvent = db.prepare(`
  INSERT INTO events (outreach_id, target_id, event_type, reply_text, expandi_data, timestamp)
  VALUES (?, ?, ?, ?, ?, ?)
`);

const findOutreachByLinkedIn = db.prepare(`
  SELECT o.id AS outreach_id, o.angle, o.opener, t.id AS target_id, t.name, t.company, t.segment
  FROM outreach o
  JOIN targets t ON o.target_id = t.id
  WHERE t.linkedin_url = ?
  ORDER BY o.created_at DESC
  LIMIT 1
`);

// --- Fastify App ---
const app = Fastify({ logger: true });

// Health check
app.get('/health', async () => {
  const count = db.prepare('SELECT COUNT(*) as n FROM events').get();
  return { status: 'ok', events: count.n, uptime: process.uptime() };
});

// Quick stats (basic auth via query param for now)
app.get('/stats', async (req, reply) => {
  if (req.query.key !== WEBHOOK_SECRET) {
    return reply.code(401).send({ error: 'unauthorized' });
  }

  const stats = db.prepare(`
    SELECT
      COUNT(*) AS total_events,
      SUM(CASE WHEN event_type = 'connection_sent' THEN 1 ELSE 0 END) AS sent,
      SUM(CASE WHEN event_type = 'connection_accepted' THEN 1 ELSE 0 END) AS accepted,
      SUM(CASE WHEN event_type IN ('replied', 'replied_first') THEN 1 ELSE 0 END) AS replied,
      SUM(CASE WHEN event_type = 'disconnected' THEN 1 ELSE 0 END) AS disconnected
    FROM events
  `).get();

  return { status: 'ok', stats };
});

// --- Expandi Webhook Handler ---
app.post('/hooks/expandi', async (req, reply) => {
  // Auth: Expandi doesn't support custom headers, so we use URL-based secret
  // Accept either header or query param
  if (WEBHOOK_SECRET && req.headers['x-webhook-secret'] !== WEBHOOK_SECRET && req.query.secret !== WEBHOOK_SECRET) {
    // Allow Expandi payloads through (they have a known structure with hook.id)
    if (!req.body?.hook?.id) {
      app.log.warn('Webhook auth failed');
      return reply.code(401).send({ error: 'unauthorized' });
    }
  }

  const payload = req.body;
  if (!payload) {
    return reply.code(400).send({ error: 'empty payload' });
  }

  try {
    // Extract LinkedIn URL from Expandi payload
    // Expandi sends profile_link_public_identifier in contact object
    const linkedinUrl = payload.contact?.profile_link_public_identifier
      || payload.contact?.profile_link
      || payload.profile_url || payload.linkedin_url || payload.url || '';
    const eventType = mapExpandiEvent(payload);
    const replyText = payload.messenger?.last_received_message
      || payload.message_text || payload.reply_text || null;
    const timestamp = payload.timestamp || new Date().toISOString();

    // Look up our outreach record
    const outreach = linkedinUrl ? findOutreachByLinkedIn.get(normalizeLinkedIn(linkedinUrl)) : null;

    // Log event
    insertEvent.run(
      outreach?.outreach_id || null,
      outreach?.target_id || null,
      eventType,
      replyText,
      JSON.stringify(payload),
      timestamp
    );

    app.log.info({ eventType, target: outreach?.name, company: outreach?.company }, 'Event logged');

    // Notify Discord
    await notifyDiscord(eventType, outreach, replyText, payload);

    return { status: 'ok', event_type: eventType, matched: !!outreach };

  } catch (err) {
    app.log.error(err, 'Error processing webhook');
    // Still return 200 so Expandi doesn't retry endlessly
    return { status: 'error', message: err.message };
  }
});

// --- Helpers ---

function mapExpandiEvent(payload) {
  // Expandi sends event in hook.event field
  const eventMap = {
    // Expandi's actual event names (from hook.event)
    'linked_in_messenger.campaign_new_contact': 'connection_accepted',
    'linked_in_messenger.campaign_contact_replied': 'replied',
    'linked_in_messenger.campaign_contact_replied_first_time': 'replied_first',
    'linked_in_messenger.campaign_message_sent': 'message_sent',
    'linked_in_messenger.campaign_connection_request_sent': 'connection_sent',
    'linked_in_messenger.campaign_contact_disconnected': 'disconnected',
    'linked_in_messenger.campaign_finished': 'campaign_finished',
    // Also support simple names for backward compat
    'connection_request_sent': 'connection_sent',
    'connection_request_accepted': 'connection_accepted',
    'connection_request_accepted_active': 'connection_accepted',
    'message_sent': 'message_sent',
    'contact_replied': 'replied',
    'contact_replied_first': 'replied_first',
    'contact_disconnected': 'disconnected',
    'campaign_finished': 'campaign_finished',
    'contact_revoked': 'disconnected',
  };

  const raw = payload.hook?.event || payload.event || payload.event_type || payload.type || 'unknown';
  return eventMap[raw] || raw;
}

function normalizeLinkedIn(url) {
  // Normalize LinkedIn URLs for matching: strip trailing slash, params
  try {
    const u = new URL(url);
    return u.origin + u.pathname.replace(/\/$/, '');
  } catch {
    return url.replace(/\/$/, '');
  }
}

async function notifyDiscord(eventType, outreach, replyText, _raw) {
  if (!DISCORD_BOT_TOKEN) return;

  const name = outreach?.name || 'Unknown';
  const company = outreach?.company || 'Unknown';
  const angle = outreach?.angle || '?';

  let message = '';
  let sendAlert = false;

  switch (eventType) {
    case 'connection_sent':
      message = `📤 **Connection sent** to ${name} (${company})\nAngle: ${angle}`;
      break;
    case 'connection_accepted':
      message = `✅ **Connection accepted** by ${name} (${company})\nAngle: ${angle} — Message 1 will send automatically`;
      break;
    case 'replied':
    case 'replied_first': {
      // Use response handler for rich reply analysis
      const replyAlert = buildReplyAlert(outreach, replyText, _raw);
      // Post rich alert to #rc-alerts
      await postToDiscordChannel(DISCORD_ALERT_CHANNEL, replyAlert.alertMessage.slice(0, 2000));
      // Post summary to #outreach-log
      await postToDiscordChannel(DISCORD_OUTREACH_CHANNEL, replyAlert.outreachLog.slice(0, 2000));
      return; // Skip default posting below
    }
    case 'disconnected':
      message = `❌ **Disconnected:** ${name} (${company}) removed connection\nAngle: ${angle}`;
      break;
    case 'campaign_finished':
      message = `🏁 **Campaign finished** for ${name} (${company}) — no reply after full sequence`;
      break;
    default:
      message = `📋 **${eventType}** — ${name} (${company})`;
  }

  // Post to #outreach-log
  await postToDiscordChannel(DISCORD_OUTREACH_CHANNEL, message);

  // If reply, also alert Rod in #rc-alerts
  if (sendAlert) {
    await postToDiscordChannel(DISCORD_ALERT_CHANNEL, `🚨 **New reply needs attention!**\n${message}`);
  }
}

function postToDiscordChannel(channelId, content) {
  return new Promise((resolve, reject) => {
    try {
      const body = JSON.stringify({ content: content.slice(0, 2000) });

      const req = https.request({
        hostname: 'discord.com',
        path: `/api/v9/channels/${channelId}/messages`,
        method: 'POST',
        headers: {
          'Authorization': `Bot ${DISCORD_BOT_TOKEN}`,
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(body),
        },
      }, (res) => {
        res.resume();
        if (res.statusCode >= 400) {
          app.log.warn({ statusCode: res.statusCode, channelId }, 'Discord post failed');
        }
        resolve();
      });

      req.on('error', (err) => {
        app.log.error(err, 'Discord request error');
        resolve(); // Don't reject — webhook processing should continue
      });
      req.write(body);
      req.end();
    } catch (err) {
      app.log.error(err, 'Discord post error');
      resolve();
    }
  });
}

// --- Start ---
app.listen({ port: PORT, host: '0.0.0.0' }, (err) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
  app.log.info(`PP Outreach webhook receiver listening on port ${PORT}`);
});
