import re

p = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/audit-log/page.tsx'
with open(p, 'r') as f:
    c = f.read()

c = c.replace("signed_by: string;", "signers: string[];")
c = c.replace("receipt.signed_by", "receipt.signers.join(', ')")
c = c.replace("r.signed_by", "r.signers.join(', ')")
c = c.replace("filterSigner !== 'all' && r.signers.join(', ') !== filterSigner", "filterSigner !== 'all' && !r.signers.includes(filterSigner)")

# Update signers extraction logic to flatMap
old_signers = "const signers = Array.from(new Set(receipts.map(r => r.signers.join(', '))));"
new_signers = "const signers = Array.from(new Set(receipts.flatMap(r => r.signers || [])));"
c = c.replace(old_signers, new_signers)

with open(p, 'w') as f:
    f.write(c)
