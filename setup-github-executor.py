import os

# 1. Create executor.ts
executor_code = """import { CanonicalPayload } from './signer';

export async function executeTool(action: string, args: Record<string, any>): Promise<string> {
  if (action === 'deploy_code') {
    const { repo, workflow_id, ref } = args;

    if (!repo || !workflow_id || !ref) {
      throw new Error('deploy_code requires repo, workflow_id, and ref arguments');
    }

    const token = process.env.GITHUB_TOKEN || process.env.GITHUB_PAT;
    
    if (!token) {
      console.warn(`⚠️ [Executor] GITHUB_TOKEN not set. Simulating GitHub Workflow dispatch for ${repo}/${workflow_id} @ ${ref}`);
      return `simulated_success: workflow ${workflow_id} dispatched on ${repo}@${ref}`;
    }

    console.log(`🚀 [Executor] Triggering GitHub Workflow: ${repo}/${workflow_id} on branch ${ref}`);
    
    const url = `https://api.github.com/repos/${repo}/actions/workflows/${workflow_id}/dispatches`;
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': `Bearer ${token}`,
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'Permission-Protocol-MCP-Guard'
      },
      body: JSON.stringify({ ref })
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`GitHub API error (${response.status}): ${errText}`);
    }

    console.log(`✅ [Executor] GitHub Workflow successfully dispatched.`);
    return `success: workflow ${workflow_id} dispatched on ${repo}@${ref}`;
  }

  if (action === 'delete_user_data') {
    return `success: user ${args.user_id} deleted from database`;
  }

  return `success: ${action} executed`;
}
"""

with open('/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/lib/authorization/executor.ts', 'w') as f:
    f.write(executor_code)


# 2. Update execute route
route_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/authorization/execute/route.ts'
with open(route_path, 'r') as f:
    route_code = f.read()

if "import { executeTool }" not in route_code:
    route_code = route_code.replace(
        "import { persistReceipt } from '@/lib/authorization/receipt-logger';",
        "import { persistReceipt } from '@/lib/authorization/receipt-logger';\nimport { executeTool } from '@/lib/authorization/executor';"
    )

old_exec = "const executionResult = `success: ${jsonRpcMessage.params?.name} triggered`;"
new_exec = """let executionResult = '';
    try {
      const executionArgs = payload ? payload.args : (jsonRpcMessage.params?.arguments || {});
      executionResult = await executeTool(jsonRpcMessage.params?.name, executionArgs);
    } catch (execErr: any) {
      console.error('❌ [Executor] Failed to execute tool:', execErr.message);
      return NextResponse.json({ error: `Execution failed: ${execErr.message}` }, { status: 500 });
    }"""

route_code = route_code.replace(old_exec, new_exec)
with open(route_path, 'w') as f:
    f.write(route_code)


# 3. Update test script arguments
test_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(test_path, 'r') as f:
    test_code = f.read()

test_code = test_code.replace("env: 'prod', commit: '123'", "repo: 'permission-protocol/pp-sandbox-free-tier', workflow_id: 'deploy.yml', ref: 'main', env: 'prod'")
test_code = test_code.replace("env: 'dev', commit: '123'", "repo: 'permission-protocol/pp-sandbox-free-tier', workflow_id: 'deploy.yml', ref: 'main', env: 'dev'")

# Also update the interceptToolCall function call inside executeCall so we don't console log the fake result from there
old_test_exec = "console.log(`   📝 Receipt generated: ${receipt.receipt_id}`);"
new_test_exec = """console.log(`   📝 Receipt generated: ${receipt.receipt_id}`);
        console.log(`   ⚡ Execution Result: ${receipt.execution_result}`);"""
test_code = test_code.replace(old_test_exec, new_test_exec)

with open(test_path, 'w') as f:
    f.write(test_code)

