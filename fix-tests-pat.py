test_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(test_path, 'r') as f:
    test_code = f.read()

test_code = test_code.replace(
    "permission-protocol/pp-sandbox-free-tier",
    "permission-protocol/demo-repository"
)
test_code = test_code.replace(
    "deploy.yml",
    "proof-html.yml"
)

with open(test_path, 'w') as f:
    f.write(test_code)
