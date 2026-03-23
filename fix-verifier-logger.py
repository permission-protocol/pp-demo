import re

# Update verifier to return policy_hash
verifier_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/verifier.ts'
with open(verifier_path, 'r') as f:
    vc = f.read()

vc = vc.replace(
    "import { getToolPolicy, ToolPolicy } from './policy';",
    "import { loadPolicy, getToolPolicy, ToolPolicy } from './policy';"
)
vc = vc.replace(
    "Promise<{ allowed: boolean; reason?: string; payload?: CanonicalPayload; token?: SignedToken; policy?: ToolPolicy }>",
    "Promise<{ allowed: boolean; reason?: string; payload?: CanonicalPayload; token?: SignedToken; policy?: ToolPolicy; policy_hash?: string }>"
)
vc = vc.replace(
    "return { allowed: true, payload, token, policy };",
    "return { allowed: true, payload, token, policy, policy_hash: loadPolicy().policy_hash };"
)

with open(verifier_path, 'w') as f:
    f.write(vc)

# Update receipt-logger to save policy_hash
logger_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/receipt-logger.ts'
with open(logger_path, 'r') as f:
    lc = f.read()

lc = lc.replace(
    "applied_policy?: ToolPolicy;",
    "applied_policy?: ToolPolicy;\n  policy_hash?: string;"
)
lc = lc.replace(
    "appliedPolicy?: ToolPolicy\n): Promise<AuditReceipt> {",
    "appliedPolicy?: ToolPolicy,\n  policyHash?: string\n): Promise<AuditReceipt> {"
)
lc = lc.replace(
    "applied_policy: appliedPolicy\n  };",
    "applied_policy: appliedPolicy,\n    policy_hash: policyHash\n  };"
)

with open(logger_path, 'w') as f:
    f.write(lc)

# Update execute route
route_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/authorization/execute/route.ts'
with open(route_path, 'r') as f:
    rc = f.read()

rc = rc.replace(
    "const { allowed, reason, payload, token, policy } = await interceptToolCall(",
    "const { allowed, reason, payload, token, policy, policy_hash } = await interceptToolCall("
)

rc = rc.replace(
    "executionResult,\n        policy\n      );",
    "executionResult,\n        policy,\n        policy_hash\n      );"
)

with open(route_path, 'w') as f:
    f.write(rc)
    
# Update test script
test_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(test_path, 'r') as f:
    tc = f.read()

tc = tc.replace(
    "`success: ${toolName} triggered`, result.policy);",
    "`success: ${toolName} triggered`, result.policy, result.policy_hash);"
)
with open(test_path, 'w') as f:
    f.write(tc)

