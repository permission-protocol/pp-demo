const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/deploy-requests/[requestId]/page.tsx';
let code = fs.readFileSync(file, 'utf8');

code = code.replace(
  /disabled={approveDisabled}/g,
  "disabled={decisionState.status === 'submitting'}"
);

fs.writeFileSync(file, code);
