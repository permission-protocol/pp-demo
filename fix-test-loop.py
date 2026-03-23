import re

p = '/Users/moltbot/.openclaw/workspace/permission-protocol-repo/scripts/test-atomic-loop.ts'
with open(p, 'r') as f:
    c = f.read()

# Replace signAuthorization calls
c = c.replace("'rod'", "['rod']")
c = c.replace("['rod'], 900", "['rod'], ['admin'], 900")
c = c.replace("'hacker_bob'", "['hacker_bob']")
c = c.replace("['hacker_bob'], 900", "['hacker_bob'], [], 900")
c = c.replace("['rod'], 7200", "['rod'], ['admin'], 7200")

new_tests = """
  // --- ORG WORKFLOW POLICIES ---
  const multiSigAuth = signAuthorization('req_deploy_multi', 'deploy_code', { env: 'prod', commit: '123' }, ['rod', 'alice'], ['admin'], 3600);
  await executeCall('Workflow 1: Multi-sig (2 approvers)', 'deploy_code', { env: 'prod', commit: '123', _authorization: multiSigAuth }, false);

  const singleSigAuth = signAuthorization('req_deploy_single', 'deploy_code', { env: 'prod', commit: '123' }, ['rod'], ['admin'], 3600);
  await executeCall('Workflow 2: Failed multi-sig (1 approver)', 'deploy_code', { env: 'prod', commit: '123', _authorization: singleSigAuth }, true);

  const roleAuth = signAuthorization('req_del_role', 'delete_user_data', { user_id: '123', hard_delete: true }, ['bob'], ['security'], 900);
  await executeCall('Workflow 3: Role-based Auth (security)', 'delete_user_data', { user_id: '123', hard_delete: true, _authorization: roleAuth }, false);

  const badRoleAuth = signAuthorization('req_del_bad_role', 'delete_user_data', { user_id: '123', hard_delete: true }, ['bob'], ['marketing'], 900);
  await executeCall('Workflow 4: Failed Role-based Auth', 'delete_user_data', { user_id: '123', hard_delete: true, _authorization: badRoleAuth }, true);

  const devEnvAuth = signAuthorization('req_deploy_dev', 'deploy_code', { env: 'dev', commit: '123' }, ['rod', 'alice'], ['admin'], 3600);
  await executeCall('Workflow 5: Failed Condition (env !== prod)', 'deploy_code', { env: 'dev', commit: '123', _authorization: devEnvAuth }, true);
"""

c = c.replace("  console.log('--- POLICY ENFORCEMENT ---');", "  console.log('--- POLICY ENFORCEMENT ---');" + new_tests)

with open(p, 'w') as f:
    f.write(c)
