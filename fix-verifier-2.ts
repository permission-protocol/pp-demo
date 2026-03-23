import fs from 'fs';

const path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/verifier.ts';
let code = fs.readFileSync(path, 'utf8');

code = code.replace("await verifyAuthorization(payload, token, publicKeyPem, expectedKeyId);", "await verifyAuthorization(payload, token, publicKeyPem, policy, expectedKeyId);");

fs.writeFileSync(path, code);
