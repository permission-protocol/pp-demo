# 1. Update policy.ts
p = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/policy.ts'
with open(p, 'r') as f:
    c = f.read()

c = c.replace("allowed_signers?: string[];\n  max_ttl_seconds?: number;",
"""allowed_signers?: string[];
  allowed_roles?: string[];
  required_approvals?: number;
  conditions?: Array<{ field: string; equals: any }>;
  max_ttl_seconds?: number;""")

with open(p, 'w') as f:
    f.write(c)

# 2. Update signer.ts
s = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/signer.ts'
with open(s, 'r') as f:
    c = f.read()

c = c.replace("signed_by: string;", "signers: string[];\n  roles: string[];")
c = c.replace("signedBy: string,", "signers: string[],\n  roles: string[] = [],")
c = c.replace("signed_by: signedBy,", "signers,\n    roles,")

with open(s, 'w') as f:
    f.write(c)
