// Input validation middleware — added by Codex agent
const RULES = {
  email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  username: /^[a-zA-Z0-9_-]{3,30}$/,
  url: /^https?:\/\/.+/,
};

export default function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { field, value } = req.body || {};

  if (!field || !value) {
    return res.status(400).json({ error: 'Missing field or value' });
  }

  const pattern = RULES[field];
  if (!pattern) {
    return res.status(400).json({ error: `Unknown field: ${field}` });
  }

  const valid = pattern.test(value);
  res.status(200).json({ field, valid, value });
}
