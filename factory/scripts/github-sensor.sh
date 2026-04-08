#!/usr/bin/env bash
# Factory GitHub Issues Sensor: Pulls open issues labeled 'bug' or 'ready'
# from PP repos and creates actionable bounties in ideas.jsonl
#
# This is a PULL-BASED sensor — it reads real work items that humans or
# agents have already filed, not hallucinated features.

set -e

GH_TOKEN=$(cat "$HOME/.openclaw/secrets/github-pat-projects.txt")
BACKLOG_FILE="$HOME/.openclaw/workspace/factory/ideas.jsonl"

# Repos to scan
REPOS=(
  "permission-protocol/app"
  "permission-protocol/site"
  "permission-protocol/deploy-gate"
  "permission-protocol/python-sdk"
  "permission-protocol/cli"
  "permission-protocol/mcp-guard"
)

# Labels that signal work for the Factory
LABELS="bug,ready,factory"

echo "Scanning GitHub Issues across PP repos..."

NEW_COUNT=0
SCANNED=0

for REPO in "${REPOS[@]}"; do
  # Fetch open issues with relevant labels
  ISSUES=$(GH_TOKEN="$GH_TOKEN" gh issue list \
    --repo "$REPO" \
    --state open \
    --json number,title,body,labels,url,createdAt \
    --limit 50 2>/dev/null || echo "[]")
  
  if [[ "$ISSUES" == "[]" || -z "$ISSUES" ]]; then
    continue
  fi

  # Process each issue
  echo "$ISSUES" | python3 -c "
import sys, json, os, datetime

issues = json.load(sys.stdin)
repo = '$REPO'
backlog_file = os.path.expanduser('$BACKLOG_FILE')

# Target labels (any of these triggers a bounty)
target_labels = {'bug', 'ready', 'factory', 'p0', 'p1', 'help wanted'}

# Load existing bounties to avoid duplicates
existing_github_ids = set()
if os.path.exists(backlog_file):
    with open(backlog_file, 'r') as f:
        for line in f:
            if not line.strip(): continue
            try:
                bounty = json.loads(line)
                gid = bounty.get('github_issue_id', '')
                if gid:
                    existing_github_ids.add(gid)
            except:
                pass

new_count = 0
for issue in issues:
    issue_labels = {l.get('name','').lower() for l in issue.get('labels', [])}
    
    # Skip if no relevant label
    if not issue_labels & target_labels:
        continue
    
    number = issue.get('number')
    unique_id = f'{repo}#{number}'
    
    if unique_id in existing_github_ids:
        continue
    
    title = issue.get('title', 'Unknown Issue')
    url = issue.get('url', '')
    body = (issue.get('body') or '')[:500]  # Truncate body
    
    # Determine priority (check labels first, then title)
    priority = 'p2'
    if 'p0' in issue_labels or 'P0:' in title.upper():
        priority = 'p0'
    elif 'p1' in issue_labels or 'P1:' in title.upper():
        priority = 'p1'
    
    # Determine if it's a bounty candidate
    is_candidate = (issue_labels & target_labels) or (priority in ['p0', 'p1'])
    
    if not is_candidate:
        continue
    
    # Determine type from labels
    bounty_type = 'bugfix' if 'bug' in issue_labels else 'feature'
    
    # Sensor-sourced items go straight to 'ready' (skip PRD step).
    # build.sh now picks up 'ready' alongside 'prd-ready'.
    # The GitHub Issue body serves as the build spec for Codex.
    bounty = {
        'id': f'gh-{repo.split(\"/\")[1]}-{number}',
        'title': f'[{repo}] {title}',
        'description': f'GitHub Issue: {url}\n\n{body}',
        'status': 'ready',
        'type': bounty_type,
        'priority': priority,
        'source': 'github-sensor',
        'github_issue_id': unique_id,
        'github_url': url,
        'repo': repo,
        'target': repo.split('/')[1] if '/' in repo else 'app',
        'issue_number': number,
        'created_at': now,
        'updated_at': now
    }
    
    with open(backlog_file, 'a') as f:
        f.write(json.dumps(bounty) + '\n')
    
    print(f'New bounty: [{repo}] #{number} — {title}')
    new_count += 1

print(f'SENSOR_NEW={new_count}')
" 2>&1

  SCANNED=$((SCANNED + 1))
done

echo "Scanned $SCANNED repos. Done."
