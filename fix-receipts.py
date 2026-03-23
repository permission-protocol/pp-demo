import re

r = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/receipt-logger.ts'
with open(r, 'r') as f:
    c = f.read()

c = c.replace("signed_by: string;", "signers: string[];")
c = c.replace("signed_by: token.signed_by,", "signers: token.signers,")

with open(r, 'w') as f:
    f.write(c)
