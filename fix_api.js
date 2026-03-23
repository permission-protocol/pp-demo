const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/app/api/summarize/route.ts';
let content = fs.readFileSync(file, 'utf8');
content = content.replace(/\\nexport async function POST/, '\nexport async function POST');
fs.writeFileSync(file, content);
