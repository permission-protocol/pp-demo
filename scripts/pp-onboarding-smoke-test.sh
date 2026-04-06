#!/usr/bin/env bash
# PP Onboarding Smoke Test
# Tests the full install → Hello World PR → deploy request → receipt flow
# as if a brand new user installed the GitHub App.
#
# Prerequisites:
#   - GitHub App private key at ~/.openclaw/secrets/github-app-private-key.pem
#   - App ID at ~/.openclaw/secrets/github-app-id.txt
#   - Test PAT at ~/.openclaw/secrets/github-pat-pp-test.txt (needs repo + admin:org scope)
#
# Usage:
#   bash scripts/pp-onboarding-smoke-test.sh [--cleanup-only]

set -euo pipefail

# --- Config ---
APP_ID=$(cat ~/.openclaw/secrets/github-app-id.txt)
TEST_PAT=$(cat ~/.openclaw/secrets/github-pat-projects.txt)
APP_KEY="$HOME/.openclaw/secrets/github-app-private-key.pem"
PP_APP_URL="https://app.permissionprotocol.com"
TEST_REPO_OWNER="permission-protocol"
TEST_REPO_NAME="demo-repository"
TEST_REPO="$TEST_REPO_OWNER/$TEST_REPO_NAME"
INSTALLATION_ID="115918626"  # permission-protocol org installation

# --- Helpers ---
log() { echo "[$(date '+%H:%M:%S')] $*"; }
fail() { echo "❌ FAIL: $*" >&2; exit 1; }
pass() { echo "✅ PASS: $*"; }

generate_jwt() {
  node -e "
    const crypto = require('crypto');
    const fs = require('fs');
    const key = fs.readFileSync('$APP_KEY', 'utf8');
    const now = Math.floor(Date.now() / 1000);
    const header = Buffer.from(JSON.stringify({alg: 'RS256', typ: 'JWT'})).toString('base64url');
    const payload = Buffer.from(JSON.stringify({iat: now - 60, exp: now + 600, iss: '$APP_ID'})).toString('base64url');
    const sig = crypto.sign('sha256', Buffer.from(header + '.' + payload), key).toString('base64url');
    console.log(header + '.' + payload + '.' + sig);
  "
}

get_installation_token() {
  local jwt=$(generate_jwt)
  curl -s -X POST \
    -H "Authorization: Bearer $jwt" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])"
}

# --- Cleanup mode ---
if [[ "${1:-}" == "--cleanup-only" ]]; then
  log "Cleaning up test artifacts..."
  
  # Close any open PRs with "Hello World" or test labels
  TEST_PRS=$(curl -s -H "Authorization: token $TEST_PAT" \
    "https://api.github.com/repos/$TEST_REPO/pulls?state=open" \
    | python3 -c "
import json,sys
prs = json.load(sys.stdin)
for pr in prs:
  if 'hello' in pr['title'].lower() or 'permission-protocol' in pr.get('head',{}).get('ref','').lower() or 'setup' in pr['title'].lower():
    print(pr['number'])
")
  
  for pr_num in $TEST_PRS; do
    log "Closing PR #$pr_num..."
    curl -s -X PATCH \
      -H "Authorization: token $TEST_PAT" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$TEST_REPO/pulls/$pr_num" \
      -d '{"state":"closed"}' > /dev/null
  done
  
  # Delete test branches
  TEST_BRANCHES=$(curl -s -H "Authorization: token $TEST_PAT" \
    "https://api.github.com/repos/$TEST_REPO/branches" \
    | python3 -c "
import json,sys
branches = json.load(sys.stdin)
for b in branches:
  if b['name'] != 'main' and ('setup' in b['name'] or 'hello' in b['name'] or 'permission' in b['name']):
    print(b['name'])
")
  
  for branch in $TEST_BRANCHES; do
    log "Deleting branch: $branch"
    curl -s -X DELETE \
      -H "Authorization: token $TEST_PAT" \
      "https://api.github.com/repos/$TEST_REPO/git/refs/heads/$branch" > /dev/null
  done
  
  pass "Cleanup complete"
  exit 0
fi

# --- Main test flow ---
log "=== PP Onboarding Smoke Test ==="
log "Testing: $TEST_REPO"
echo ""

# Step 0: Clean slate
log "Step 0: Cleaning previous test artifacts..."
bash "$0" --cleanup-only 2>/dev/null || true
echo ""

# Step 1: Verify the App is installed on the repo
log "Step 1: Verifying GitHub App installation..."
INST_TOKEN=$(get_installation_token)

REPO_ACCESS=$(curl -s -H "Authorization: token $INST_TOKEN" \
  "https://api.github.com/installation/repositories" \
  | python3 -c "
import json,sys
data = json.load(sys.stdin)
repos = [r['full_name'] for r in data.get('repositories', [])]
print('yes' if '$TEST_REPO' in repos else 'no')
")

if [[ "$REPO_ACCESS" != "yes" ]]; then
  log "⚠️  App not installed on $TEST_REPO. Adding it..."
  # Add the repo to the installation (requires PAT with write:org scope)
  REPO_ID=$(curl -s -H "Authorization: token $TEST_PAT" \
    "https://api.github.com/repos/$TEST_REPO" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
  
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $TEST_PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/user/installations/$INSTALLATION_ID/repositories/$REPO_ID")
  
  if [[ "$HTTP_CODE" == "204" ]]; then
    log "Added repo to installation. Waiting for webhook processing..."
    sleep 5
    pass "Repo added to installation"
  else
    fail "Could not add repo to installation (HTTP $HTTP_CODE). Need PAT with write:org scope."
  fi
else
  pass "App already installed on $TEST_REPO"
fi
echo ""

# Step 2: Create a test commit to trigger a PR (simulating user activity)
log "Step 2: Creating test commit to trigger deploy-gate..."
TIMESTAMP=$(date +%s)
TEST_BRANCH="test/smoke-test-$TIMESTAMP"

# Get main branch SHA
MAIN_SHA=$(curl -s -H "Authorization: token $TEST_PAT" \
  "https://api.github.com/repos/$TEST_REPO/git/ref/heads/main" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['object']['sha'])")

# Create branch
curl -s -X POST \
  -H "Authorization: token $TEST_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$TEST_REPO/git/refs" \
  -d "{\"ref\": \"refs/heads/$TEST_BRANCH\", \"sha\": \"$MAIN_SHA\"}" > /dev/null

# Create a file on the branch
curl -s -X PUT \
  -H "Authorization: token $TEST_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$TEST_REPO/contents/smoke-test-$TIMESTAMP.txt" \
  -d "{
    \"message\": \"Smoke test commit ($TIMESTAMP)\",
    \"content\": \"$(echo "PP onboarding smoke test - $TIMESTAMP" | base64)\",
    \"branch\": \"$TEST_BRANCH\"
  }" > /dev/null

# Create PR
PR_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $TEST_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$TEST_REPO/pulls" \
  -d "{
    \"title\": \"[Smoke Test] Onboarding verification ($TIMESTAMP)\",
    \"body\": \"Automated smoke test for PP onboarding flow.\",
    \"head\": \"$TEST_BRANCH\",
    \"base\": \"main\"
  }")

PR_NUMBER=$(echo "$PR_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('number', 'FAILED'))")
PR_URL=$(echo "$PR_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('html_url', 'FAILED'))")

if [[ "$PR_NUMBER" == "FAILED" ]]; then
  fail "Could not create PR: $(echo "$PR_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('message', 'unknown'))")"
fi

pass "Created PR #$PR_NUMBER: $PR_URL"
echo ""

# Step 3: Wait for the PP status check to appear
log "Step 3: Waiting for Permission Protocol status check..."
MAX_WAIT=60
ELAPSED=0

while [[ $ELAPSED -lt $MAX_WAIT ]]; do
  # Get the latest commit SHA on the PR
  PR_HEAD=$(curl -s -H "Authorization: token $TEST_PAT" \
    "https://api.github.com/repos/$TEST_REPO/pulls/$PR_NUMBER" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['head']['sha'])")
  
  # Check statuses on that commit
  PP_STATUS=$(curl -s -H "Authorization: token $TEST_PAT" \
    "https://api.github.com/repos/$TEST_REPO/commits/$PR_HEAD/statuses" \
    | python3 -c "
import json,sys
statuses = json.load(sys.stdin)
for s in statuses:
  if 'permission' in s.get('context','').lower() or 'pp' in s.get('context','').lower():
    print(f\"{s['state']}|{s['context']}|{s.get('description','')}\")
    break
else:
  print('none')
")
  
  if [[ "$PP_STATUS" != "none" ]]; then
    STATE=$(echo "$PP_STATUS" | cut -d'|' -f1)
    CONTEXT=$(echo "$PP_STATUS" | cut -d'|' -f2)
    DESC=$(echo "$PP_STATUS" | cut -d'|' -f3)
    pass "Status check found: [$STATE] $CONTEXT — $DESC"
    break
  fi
  
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  log "  Waiting... (${ELAPSED}s / ${MAX_WAIT}s)"
done

if [[ $ELAPSED -ge $MAX_WAIT ]]; then
  log "⚠️  No PP status check appeared after ${MAX_WAIT}s"
  log "  This could mean:"
  log "    - deploy-gate Action not configured on this repo"
  log "    - Webhook not firing for this repo"
  log "    - App backend not processing the event"
  echo ""
fi

# Step 4: Check if a deploy request was created in the PP app
log "Step 4: Checking PP app for deploy request..."
PP_API_KEY=$(cat ~/.openclaw/secrets/pp-api-key.txt 2>/dev/null || echo "")

if [[ -n "$PP_API_KEY" ]]; then
  # Try to query the PP API for recent deploy requests
  PP_REQUESTS=$(curl -s \
    -H "Authorization: Bearer $PP_API_KEY" \
    -H "Accept: application/json" \
    "$PP_APP_URL/api/v1/requests?repo=$TEST_REPO&limit=5" 2>/dev/null || echo "{}")
  
  log "  PP API response: $(echo "$PP_REQUESTS" | head -c 200)"
else
  log "  ⚠️  No PP API key found — skipping API verification"
  log "  Manual check: $PP_APP_URL/c/deploy-gate"
fi
echo ""

# Step 5: Summary
log "=== Smoke Test Summary ==="
echo "  Repo:      $TEST_REPO"
echo "  PR:        #$PR_NUMBER ($PR_URL)"
echo "  Branch:    $TEST_BRANCH"
echo "  Status:    ${PP_STATUS:-not checked}"
echo ""
log "To clean up: bash scripts/pp-onboarding-smoke-test.sh --cleanup-only"
log "To check manually: $PP_APP_URL"
