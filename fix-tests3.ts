import fs from 'fs';

const path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts';
let code = fs.readFileSync(path, 'utf8');

const regex = /if \(expectedToFail\) {\s*console\.log\(\`\$\{testName\}: \$\{\!result\.allowed \? '✅ DENY' : '❌ ALLOW'\} \- \$\{result\.reason \|\| 'No reason provided'\}\`\);\s*\} else {\s*console\.log\(\`\$\{testName\}: \$\{result\.allowed \? '✅ ALLOW' : '❌ DENY \- ' \+ \(result\.reason \|\| ''\)\}\`\);/

const replace = `if (expectedToFail) {
      console.log(\`\${testName}: \${!result.allowed ? '✅ DENY' : '❌ ALLOW'} - \${result.reason || 'No reason provided'}\`);
    } else {
      console.log(\`\${testName}: \${result.allowed ? '✅ ALLOW' : '❌ DENY - ' + (result.reason || '')}\`);`;

code = code.replace(regex, replace);

fs.writeFileSync(path, code);
