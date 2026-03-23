#!/usr/bin/env bash
# Factory Error Sensor: Polls Sentry for unresolved issues and creates actionable bounties in ideas.jsonl

set -e

# Configuration
ORG_SLUG="permission-protocol"
# Sentry base URL uses org slug as subdomain
PROJECT_SLUG="javascript-nextjs"
SENTRY_API="https://sentry.io/api/0"
TOKEN_FILE="$HOME/.openclaw/secrets/sentry-auth-token.txt"
BACKLOG_FILE="$HOME/.openclaw/workspace/factory/ideas.jsonl"
MARKER_FILE="$HOME/.openclaw/workspace/factory/.last_sentry_scan"

if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "ERROR: Sentry token not found at $TOKEN_FILE"
  exit 1
fi

SENTRY_TOKEN=$(cat "$TOKEN_FILE")

echo "Polling Sentry ($ORG_SLUG/$PROJECT_SLUG) for new runtime errors..."

# Query unresolved issues in the last 24 hours
RESPONSE=$(curl -s -H "Authorization: Bearer $SENTRY_TOKEN" \
  "$SENTRY_API/projects/$ORG_SLUG/$PROJECT_SLUG/issues/?query=is:unresolved&statsPeriod=24h")

if echo "$RESPONSE" | grep -q '"detail":'; then
  echo "ERROR: API returned an error: $RESPONSE"
  exit 1
fi

# Extract issue IDs, Titles, and Permalinks
echo "$RESPONSE" | python3 -c '
import sys, json, os, datetime

try:
    issues = json.load(sys.stdin)
except Exception as e:
    print("Failed to parse JSON response:", e)
    sys.exit(1)

if not issues:
    print("No unresolved issues found in the last 24h.")
    sys.exit(0)

backlog_file = os.path.expanduser("~/.openclaw/workspace/factory/ideas.jsonl")

# Load existing bounties to avoid duplicates
existing_sentry_ids = set()
if os.path.exists(backlog_file):
    with open(backlog_file, "r") as f:
        for line in f:
            if not line.strip(): continue
            try:
                bounty = json.loads(line)
                if "sentry_issue_id" in bounty:
                    existing_sentry_ids.add(bounty["sentry_issue_id"])
            except:
                pass

new_count = 0
for issue in issues:
    issue_id = issue.get("id")
    if issue_id in existing_sentry_ids:
        continue
        
    title = issue.get("title", "Unknown Error")
    culprit = issue.get("culprit", "")
    permalink = issue.get("permalink", "")
    
    # Create the bounty payload
    now = datetime.datetime.utcnow().isoformat() + "Z"
    
    # Sensor-sourced bugs go straight to 'ready' (skip PRD step).
    # build.sh picks up 'ready' items alongside 'prd-ready'.
    bounty = {
        "id": f"sentry-{issue_id}",
        "title": f"Fix Runtime Error: {title}",
        "description": f"Sentry reported a runtime error in {culprit}.\nPermalink: {permalink}",
        "status": "ready",
        "type": "bugfix",
        "priority": "p1",
        "source": "error-sensor",
        "sentry_issue_id": issue_id,
        "repo": "permission-protocol/app",
        "target": "app",
        "created_at": now,
        "updated_at": now
    }
    
    with open(backlog_file, "a") as f:
        f.write(json.dumps(bounty) + "\n")
    
    print(f"Created new bounty: {bounty['title']}")
    new_count += 1

print(f"Successfully processed {len(issues)} active Sentry issues. Added {new_count} new bounties.")
'

date > "$MARKER_FILE"
