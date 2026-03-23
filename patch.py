import re

file_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/pp/deploy-requests/[requestId]/page.tsx'
with open(file_path, 'r') as f:
    content = f.read()

# Replace handleApprove logic
old_handle_approve = """    try {
      const response = await fetch(`/api/v1/deploy-requests/${request.id}/approve`, {"""

new_handle_approve = """    try {
      // 1. Atomic Loop: Sign & Authorize
      const signRes = await fetch('/api/authorization/sign', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          request_id: request.id,
          action: 'deploy_code',
          args: { env: request.env, commit: request.commitSha },
          signed_by: 'rod' // Mocked identity for atomic loop
        })
      });
      const signData = await signRes.json();
      if (!signRes.ok) throw new Error(signData.error || 'Signing failed');
      const { payload, token } = signData;

      // 2. Atomic Loop: Execute (Verifier Interceptor)
      const executeRes = await fetch('/api/authorization/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          jsonrpc: '2.0',
          id: 1,
          method: 'tools/call',
          params: {
            name: 'deploy_code',
            arguments: {
              env: request.env,
              commit: request.commitSha,
              _authorization: { payload, token }
            }
          }
        })
      });
      const executeData = await executeRes.json();
      if (!executeRes.ok) throw new Error(`Execution blocked: ${executeData.error}`);
      
      console.log('✅ Atomic loop executed successfully');

      // 3. Fallback to normal DB approve to update dashboard state
      const response = await fetch(`/api/v1/deploy-requests/${request.id}/approve`, {"""

content = content.replace(old_handle_approve, new_handle_approve)

# Update UI string
old_ui = """<li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> This change will execute</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> You will be recorded as the signer</li>"""

new_ui = """<li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> This change will execute</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> You will be recorded as the signer</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5" /> Authorization is bound to exact args</li>"""

content = content.replace(old_ui, new_ui)

with open(file_path, 'w') as f:
    f.write(content)
