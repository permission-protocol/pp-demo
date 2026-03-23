const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/deploy-requests/[requestId]/page.tsx';
let code = fs.readFileSync(file, 'utf8');

code = code.replace(
  /{session\?\.user\?\.name \|\| 'Rodrigo Carvalho'} \(@{session\?\.user\?\.username \|\| 'rod'}\)/g,
  "Rodrigo Carvalho (@rod)"
);

fs.writeFileSync(file, code);
