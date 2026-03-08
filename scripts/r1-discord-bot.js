#!/usr/bin/env node
// R1 Discord Bot v2 — Thread-based conversations, model switching, system prompts
const { Client, GatewayIntentBits } = require('discord.js');
const fs = require('fs');
const os = require('os');

const TOKEN = fs.readFileSync(
  os.homedir() + '/.openclaw/secrets/r1-discord-token.txt', 'utf8'
).trim();

const OLLAMA_URL = 'http://100.111.31.56:11434';
const CHANNEL_ID = '1479611901360214109'; // #r1-chat

// ─── Model config ───
const MODELS = {
  r1:    { id: 'deepseek-r1:70b', name: 'DeepSeek R1 70B', emoji: '🧠' },
  coder: { id: 'qwen2.5-coder:32b', name: 'Qwen 2.5 Coder 32B', emoji: '💻' },
  fast:  { id: 'llama3.1:8b', name: 'Llama 3.1 8B', emoji: '⚡' },
};
const DEFAULT_MODEL = 'r1';

// ─── System prompts ───
const SYSTEM_PROMPTS = {
  r1: `You are R1, a reasoning-focused AI running locally on a DGX Spark. You excel at deep analysis, strategy, and thorough thinking. Be direct and substantive. Skip pleasantries.`,
  coder: `You are a coding assistant running locally on a DGX Spark. Write clean, well-structured code. Explain your approach briefly. Use markdown code blocks.`,
  fast: `You are a fast, concise AI assistant. Keep responses short and direct. Prioritize speed over depth.`,
};

// ─── Conversation memory (per-thread, in-memory) ───
// Map<threadId|channelId, Array<{role, content}>>
const conversations = new Map();
const MAX_HISTORY = 20; // messages per conversation
const CONV_TTL_MS = 2 * 60 * 60 * 1000; // 2 hours
const convTimestamps = new Map();

function getConversation(id) {
  const now = Date.now();
  const lastActive = convTimestamps.get(id) || 0;
  if (now - lastActive > CONV_TTL_MS) {
    conversations.delete(id);
  }
  convTimestamps.set(id, now);
  if (!conversations.has(id)) conversations.set(id, []);
  return conversations.get(id);
}

function addToConversation(id, role, content) {
  const conv = getConversation(id);
  conv.push({ role, content });
  if (conv.length > MAX_HISTORY * 2) {
    // Keep system context but trim old messages
    conversations.set(id, conv.slice(-MAX_HISTORY * 2));
  }
}

// ─── Parse model prefix ───
function parseMessage(content) {
  const trimmed = content.trim();
  
  // Check for /model commands
  const modelMatch = trimmed.match(/^\/(\w+)\s+([\s\S]+)/);
  if (modelMatch) {
    const modelKey = modelMatch[1].toLowerCase();
    if (MODELS[modelKey]) {
      return { model: modelKey, prompt: modelMatch[2].trim() };
    }
  }

  // Check for /models list command
  if (trimmed === '/models') {
    return { command: 'models' };
  }

  // Check for /clear command
  if (trimmed === '/clear') {
    return { command: 'clear' };
  }

  // Check for /think toggle (show R1's thinking)
  const thinkMatch = trimmed.match(/^\/think\s+([\s\S]+)/);
  if (thinkMatch) {
    return { model: 'r1', prompt: thinkMatch[1].trim(), showThinking: true };
  }

  return { model: DEFAULT_MODEL, prompt: trimmed };
}

// ─── Main bot ───
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

client.once('ready', () => {
  console.log(`R1 bot v2 online as ${client.user.tag}`);
  console.log(`Models: ${Object.entries(MODELS).map(([k,v]) => `${v.emoji} /${k} (${v.name})`).join(', ')}`);
});

client.on('messageCreate', async (msg) => {
  if (msg.author.bot) return;
  if (msg.channel.id !== CHANNEL_ID && msg.channel.parentId !== CHANNEL_ID) return;

  const parsed = parseMessage(msg.content);

  // Handle commands
  if (parsed.command === 'models') {
    const list = Object.entries(MODELS)
      .map(([key, m]) => `${m.emoji} **/${key}** — ${m.name}`)
      .join('\n');
    await msg.reply(`**Available models:**\n${list}\n\n**Commands:**\n🧵 Reply in a thread for conversation memory\n🔍 **/think** — Show R1's reasoning chain\n🗑️ **/clear** — Reset conversation history`);
    return;
  }

  if (parsed.command === 'clear') {
    const convId = msg.channel.id;
    conversations.delete(convId);
    await msg.reply('🗑️ Conversation cleared.');
    return;
  }

  if (!parsed.prompt) return;

  const modelConfig = MODELS[parsed.model];
  const convId = msg.channel.id; // thread ID if in thread, channel ID if not
  const systemPrompt = SYSTEM_PROMPTS[parsed.model] || SYSTEM_PROMPTS.r1;

  // Build conversation context
  addToConversation(convId, 'user', parsed.prompt);
  const history = getConversation(convId);

  // Build messages array for chat endpoint
  const messages = [
    { role: 'system', content: systemPrompt },
    ...history,
  ];

  // Auto-create thread for new top-level messages (keeps #r1-chat clean)
  let replyTarget = msg;
  if (msg.channel.id === CHANNEL_ID && !msg.channel.isThread?.()) {
    try {
      const threadName = parsed.prompt.slice(0, 80) + (parsed.prompt.length > 80 ? '...' : '');
      const thread = await msg.startThread({
        name: `${modelConfig.emoji} ${threadName}`,
        autoArchiveDuration: 60,
      });
      replyTarget = thread;
    } catch (e) {
      console.error('Thread creation failed:', e.message);
    }
  }

  // Show typing
  const typingInterval = setInterval(() => {
    (replyTarget.channel || replyTarget).sendTyping?.().catch(() => {});
  }, 5000);
  (replyTarget.channel || replyTarget).sendTyping?.().catch(() => {});

  try {
    const res = await fetch(`${OLLAMA_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: modelConfig.id,
        messages: messages,
        stream: false,
      }),
    });

    if (!res.ok) {
      clearInterval(typingInterval);
      const errText = await res.text().catch(() => '');
      await replyTarget.send?.(`⚠️ Ollama error: ${res.status} — ${errText.slice(0, 200)}`);
      return;
    }

    const data = await res.json();
    let response = data.message?.content || '(empty response)';
    let thinkingBlock = '';

    // Extract and optionally show thinking
    const thinkMatch = response.match(/<think>([\s\S]*?)<\/think>/);
    if (thinkMatch) {
      thinkingBlock = thinkMatch[1].trim();
      response = response.replace(/<think>[\s\S]*?<\/think>/g, '').trim();
    }

    if (!response) response = '(R1 thought about it but had nothing to say)';

    // Add assistant response to conversation
    addToConversation(convId, 'assistant', response);

    clearInterval(typingInterval);

    // Send thinking block first if requested
    if (parsed.showThinking && thinkingBlock) {
      const thinkChunks = splitMessage(`💭 **Thinking:**\n\`\`\`\n${thinkingBlock}\n\`\`\``, 2000);
      for (const chunk of thinkChunks) {
        await replyTarget.send?.(chunk);
      }
    }

    // Send response
    const chunks = splitMessage(response, 2000);
    for (const chunk of chunks) {
      await replyTarget.send?.(chunk);
    }

    // Log timing
    const secs = data.total_duration ? (data.total_duration / 1e9).toFixed(1) : '?';
    const tps = data.eval_count && data.eval_duration
      ? (data.eval_count / (data.eval_duration / 1e9)).toFixed(1)
      : '?';
    console.log(`[${msg.author.username}] ${modelConfig.emoji} ${parsed.model} | ${parsed.prompt.slice(0, 60)}... → ${secs}s, ${tps} tok/s`);

  } catch (err) {
    clearInterval(typingInterval);
    console.error('Error:', err.message);
    await replyTarget.send?.(`❌ Failed to reach Spark: ${err.message}`).catch(() => {});
  }
});

function splitMessage(text, maxLen) {
  if (text.length <= maxLen) return [text];
  const chunks = [];
  while (text.length > 0) {
    let split = text.lastIndexOf('\n', maxLen);
    if (split <= 0) split = maxLen;
    chunks.push(text.slice(0, split));
    text = text.slice(split).trimStart();
  }
  return chunks;
}

// Cleanup old conversations every 30 min
setInterval(() => {
  const now = Date.now();
  for (const [id, ts] of convTimestamps) {
    if (now - ts > CONV_TTL_MS) {
      conversations.delete(id);
      convTimestamps.delete(id);
    }
  }
}, 30 * 60 * 1000);

client.login(TOKEN);
