test_path = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(test_path, 'r') as f:
    test_code = f.read()

# Replace any remaining mock deploy args
test_code = test_code.replace(
    "const mockDeploy = { id: 'req_deploy', env: 'prod', commitSha: 'abc123' };",
    "const mockDeploy = { id: 'req_deploy', repo: 'permission-protocol/pp-sandbox-free-tier', workflow_id: 'deploy.yml', ref: 'main', env: 'prod' };"
)
test_code = test_code.replace(
    "{ env: mockDeploy.env, commit: mockDeploy.commitSha }",
    "{ repo: mockDeploy.repo, workflow_id: mockDeploy.workflow_id, ref: mockDeploy.ref, env: mockDeploy.env }"
)
test_code = test_code.replace(
    "commit: 'DEF456'",
    "ref: 'feature-branch'"
)

with open(test_path, 'w') as f:
    f.write(test_code)
