file_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/src/app/api/authorization/execute/route.ts'
with open(file_path, 'r') as f:
    c = f.read()

c = c.replace("'success: ${jsonRpcMessage.params?.name} triggered'", "`success: ${jsonRpcMessage.params?.name} triggered`")

with open(file_path, 'w') as f:
    f.write(c)
