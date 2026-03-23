import fs from 'fs';

const path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts';
let code = fs.readFileSync(path, 'utf8');

code = code.replace("const unauthAuth = signAuthorization('req_del_unauth', 'delete_user_data', { user_id: mockDelete.user_id, hard_delete: mockDelete.hard_delete }, 'hacker_bob', 900);",
"const unauthAuth = signAuthorization('req_del_unauth', 'delete_user_data', { user_id: mockDelete.user_id, hard_delete: mockDelete.hard_delete }, 'hacker_bob', 900);");

fs.writeFileSync(path, code);
