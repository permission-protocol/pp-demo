test_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(test_path, 'r') as f:
    test_code = f.read()

if "import { executeTool }" not in test_code:
    test_code = test_code.replace(
        "import { persistReceipt } from '../src/lib/authorization/receipt-logger';",
        "import { persistReceipt } from '../src/lib/authorization/receipt-logger';\nimport { executeTool } from '../src/lib/authorization/executor';"
    )

old_exec = "const receipt = await persistReceipt(result.payload, result.token, 'VERIFIED_VALID', `success: ${toolName} triggered`, result.policy, result.policy_hash);"
new_exec = """const executionResult = await executeTool(toolName, result.payload.args);
        const receipt = await persistReceipt(result.payload, result.token, 'VERIFIED_VALID', executionResult, result.policy, result.policy_hash);"""
        
test_code = test_code.replace(old_exec, new_exec)

with open(test_path, 'w') as f:
    f.write(test_code)
