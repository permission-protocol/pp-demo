import re

v = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/verifier.ts'
with open(v, 'r') as f:
    c = f.read()

# Fix schema checks
c = c.replace("!token.signed_by || !token.signed_at", "!token.signers || !token.roles || !token.signed_at")

# Fix Policy Enforcement logic
policy_enforcement_old = """  // 6. Policy Enforcement (The Authority Plane)
  if (policy.allowed_signers && !policy.allowed_signers.includes(token.signed_by)) {
    throw new Error(`Policy violation: Signer '${token.signed_by}' is not authorized to sign for action '${payload.action}'`);
  }

  if (policy.max_ttl_seconds) {"""

policy_enforcement_new = """  // 6. Policy Enforcement (The Authority Plane)
  
  // A. Multi-Sig & Role-Based Auth
  const requiredApprovals = policy.required_approvals || 1;
  let validSignatures = 0;
  
  // Simple check: we need at least `requiredApprovals` valid signers/roles
  // In a robust implementation, the token itself would have N independent cryptographic signatures
  // For v1, the PP backend mints the final execution token on behalf of N signers (which it verified via its own DB)
  for (const signer of token.signers) {
    const isAllowedSigner = policy.allowed_signers ? policy.allowed_signers.includes(signer) : true;
    const hasAllowedRole = policy.allowed_roles ? token.roles.some(r => policy.allowed_roles!.includes(r)) : true;
    
    if (isAllowedSigner && hasAllowedRole) {
      validSignatures++;
    }
  }

  if (validSignatures < requiredApprovals) {
    throw new Error(`Policy violation: Requires ${requiredApprovals} valid approvals, found ${validSignatures}. Evaluated signers: ${token.signers.join(', ')}`);
  }

  // B. Basic Conditions
  if (policy.conditions) {
    for (const cond of policy.conditions) {
      const keys = cond.field.split('.');
      let val: any = payload;
      for (const k of keys) {
        val = val?.[k];
      }
      if (val !== cond.equals) {
        throw new Error(`Policy violation: Condition '${cond.field} == ${cond.equals}' failed (got '${val}')`);
      }
    }
  }

  if (policy.max_ttl_seconds) {"""

c = c.replace(policy_enforcement_old, policy_enforcement_new)

with open(v, 'w') as f:
    f.write(c)
