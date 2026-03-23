p1 = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/authorization/sign/route.ts'
with open(p1, 'r') as f:
    c1 = f.read()

c1 = c1.replace("const { request_id, action, args, signed_by } = body;", "const { request_id, action, args, signers, roles } = body;")
c1 = c1.replace("if (!request_id || !action || !args || !signed_by)", "if (!request_id || !action || !args || !signers)")
c1 = c1.replace("error: 'Missing required fields: request_id, action, args, signed_by'", "error: 'Missing required fields: request_id, action, args, signers'")
c1 = c1.replace("signAuthorization(request_id, action, args, signed_by, 3600);", "signAuthorization(request_id, action, args, signers, roles || [], 3600);")

with open(p1, 'w') as f:
    f.write(c1)

p2 = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/deploy-requests/[requestId]/page.tsx'
with open(p2, 'r') as f:
    c2 = f.read()

c2 = c2.replace("signed_by: 'rod' // Mocked identity for atomic loop", "signers: ['rod'], // Mocked identity for atomic loop\n          roles: ['admin']")

with open(p2, 'w') as f:
    f.write(c2)

p3 = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-signer.ts'
with open(p3, 'r') as f:
    c3 = f.read()

c3 = c3.replace("'rod'", "['rod'], ['admin']")

with open(p3, 'w') as f:
    f.write(c3)
