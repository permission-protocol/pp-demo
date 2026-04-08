const https = require('https');
const fs = require('fs');
const token = fs.readFileSync('/Users/moltbot/.openclaw/secrets/discord-token.txt', 'utf8').trim();

const data = JSON.stringify({
  name: '✅ Onboarding Flow QA',
  archived: true,
  locked: true
});

const req = https.request({
  hostname: 'discord.com',
  port: 443,
  path: '/api/v10/channels/1489650324879708351',
  method: 'PATCH',
  headers: {
    'Authorization': 'Bot ' + token,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
}, (res) => {
  let chunks = [];
  res.on('data', chunk => chunks.push(chunk));
  res.on('end', () => console.log(res.statusCode, Buffer.concat(chunks).toString()));
});

req.on('error', console.error);
req.write(data);
req.end();
