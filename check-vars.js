const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/deploy-requests/[requestId]/page.tsx';
const code = fs.readFileSync(file, 'utf8');

// The block is injected around line 2100. Let's see if these variables are declared BEFORE line 2100.
const lines = code.split('\n');
const topHalf = lines.slice(0, 2100).join('\n');

const vars = ['reviewTitle', 'request', 'contextDetails', 'isAiBlocked', 'enrichment', 'approveDisabled', 'decisionState', 'handleApprove', 'handleDeny'];

vars.forEach(v => {
  if (topHalf.includes(`const ${v}`) || topHalf.includes(`let ${v}`) || topHalf.includes(`function ${v}`)) {
    console.log(`✅ ${v} found`);
  } else {
    // maybe array destructuring?
    if (topHalf.includes(` ${v} `) || topHalf.includes(`${v},`) || topHalf.includes(`${v} =`)) {
      console.log(`✅ ${v} found (used)`);
    } else {
      console.log(`❌ ${v} NOT FOUND`);
    }
  }
});
