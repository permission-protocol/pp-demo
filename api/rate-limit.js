// Rate limiter middleware — added by Codex agent
const WINDOW_MS = 60 * 1000;
const MAX_REQUESTS = 100;
const clients = new Map();

export default function handler(req, res) {
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  const now = Date.now();
  const record = clients.get(ip) || { count: 0, resetAt: now + WINDOW_MS };

  if (now > record.resetAt) {
    record.count = 0;
    record.resetAt = now + WINDOW_MS;
  }

  record.count++;
  clients.set(ip, record);

  const remaining = Math.max(0, MAX_REQUESTS - record.count);
  res.setHeader('X-RateLimit-Limit', MAX_REQUESTS);
  res.setHeader('X-RateLimit-Remaining', remaining);

  if (record.count > MAX_REQUESTS) {
    return res.status(429).json({ error: 'Too many requests' });
  }

  res.status(200).json({ ok: true, remaining });
}
