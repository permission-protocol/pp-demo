#!/usr/bin/env bash
# factory/scripts/reconcile.sh — Reconcile ideas.jsonl against merged GitHub PRs
# Runs on heartbeat or manually. Finds stale ideas and auto-marks merged ones as done.
#
# Usage: bash factory/scripts/reconcile.sh [--dry-run] [--verbose]

set -euo pipefail

WORKSPACE="${HOME}/.openclaw/workspace"
IDEAS_FILE="${WORKSPACE}/factory/ideas.jsonl"
GH_TOKEN_FILE="${HOME}/.openclaw/secrets/github-pat-projects.txt"
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TODAY=$(date -u +"%Y-%m-%d")

DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
  esac
done

if [ ! -f "$GH_TOKEN_FILE" ]; then
  echo '{"status":"error","message":"GitHub PAT not found"}' 
  exit 1
fi

GH_TOKEN=$(cat "$GH_TOKEN_FILE")

log() {
  if [ "$VERBOSE" = true ]; then
    echo "[reconcile] $1" >&2
  fi
}

# Step 1: Get all merged factory PRs from both repos
log "Fetching merged factory PRs..."

export GH_TOKEN="$GH_TOKEN"

APP_PRS=$(gh pr list \
  --repo permission-protocol/app \
  --state merged \
  --search "factory/" \
  --limit 100 \
  --json number,title,headRefName,mergedAt 2>/dev/null || echo "[]")

SITE_PRS=$(gh pr list \
  --repo permission-protocol/site \
  --state merged \
  --search "factory/" \
  --limit 100 \
  --json number,title,headRefName,mergedAt 2>/dev/null || echo "[]")

# Step 2: Extract idea IDs from merged PR branch names
# Branch pattern: factory/idea-NNN
MERGED_IDEAS=$(printf '%s\n%s\n' "$APP_PRS" "$SITE_PRS" | python3 -c "
import json, sys, re

merged = {}
for line in sys.stdin:
    line = line.strip()
    if not line or line == '[]':
        continue
    try:
        prs = json.loads(line)
    except:
        continue
    for pr in prs:
        branch = pr.get('headRefName', '')
        m = re.match(r'factory/(idea-\d+)', branch)
        if m:
            idea_id = m.group(1)
            merged[idea_id] = {
                'pr': pr.get('number'),
                'merged_at': pr.get('mergedAt', '')[:10],
                'title': pr.get('title', '')
            }

print(json.dumps(merged))
")

log "Found merged factory PRs: $(echo "$MERGED_IDEAS" | python3 -c 'import json,sys; print(len(json.loads(sys.stdin.read())))')"

# Step 3: Write merged ideas to temp file for python
MERGED_FILE=$(mktemp)
echo "$MERGED_IDEAS" > "$MERGED_FILE"

# Step 4: Reconcile against ideas.jsonl
python3 - "$NOW" "$DRY_RUN" "$MERGED_FILE" "$IDEAS_FILE" << 'PYEOF'
import json, sys, datetime

now = sys.argv[1]
dry_run = sys.argv[2] == "true"
merged_file = sys.argv[3]
ideas_file = sys.argv[4]

with open(merged_file) as f:
    merged = json.load(f)

with open(ideas_file) as f:
    ideas = [json.loads(l) for l in f if l.strip()]

changes = []
warnings = []

for idea in ideas:
    iid = idea.get("id", "")
    status = idea.get("status", "")
    
    # Skip already terminal states
    if status in ("done", "archived", "rejected"):
        continue
    
    # Check if this idea's PR was merged
    if iid in merged:
        pr_info = merged[iid]
        old_status = status
        if not dry_run:
            idea["status"] = "done"
            idea["updated_at"] = now
            idea["merged"] = pr_info["merged_at"]
            idea["pr_number"] = pr_info["pr"]
        changes.append({
            "id": iid,
            "old_status": old_status,
            "new_status": "done",
            "reason": f"PR #{pr_info['pr']} merged {pr_info['merged_at']}"
        })
        continue
    
    # Check for stale items
    updated = idea.get("updated_at", "")
    if updated:
        try:
            updated_dt = datetime.datetime.fromisoformat(updated.replace("Z", "+00:00")).replace(tzinfo=None)
            age_hours = (datetime.datetime.utcnow() - updated_dt).total_seconds() / 3600
        except:
            age_hours = 0
    else:
        age_hours = 0
    
    if status == "qa-passed" and age_hours > 48:
        warnings.append({
            "id": iid,
            "status": status,
            "age_hours": round(age_hours, 1),
            "message": f"qa-passed for {round(age_hours/24, 1)} days — probably merged, check manually"
        })
    elif status == "build-ready" and age_hours > 168:  # 7 days
        warnings.append({
            "id": iid,
            "status": status,
            "age_hours": round(age_hours, 1),
            "message": f"build-ready for {round(age_hours/24, 1)} days — stale, needs attention"
        })
    elif status == "build-failed" and age_hours > 48:
        warnings.append({
            "id": iid,
            "status": status,
            "age_hours": round(age_hours, 1),
            "message": f"build-failed for {round(age_hours/24, 1)} days — needs retry or archival"
        })
    elif status == "prd-wip" and age_hours > 168:  # 7 days
        warnings.append({
            "id": iid,
            "status": status,
            "age_hours": round(age_hours, 1),
            "message": f"prd-wip for {round(age_hours/24, 1)} days — spec stalled"
        })

# Write back
if not dry_run and changes:
    with open(ideas_file, "w") as f:
        for idea in ideas:
            f.write(json.dumps(idea, separators=(",", ":")) + "\n")

# Output results
result = {
    "status": "ok",
    "timestamp": now,
    "dry_run": dry_run,
    "changes": changes,
    "warnings": warnings,
    "summary": {
        "reconciled": len(changes),
        "warnings": len(warnings),
        "total_active": len([i for i in ideas if i.get("status") not in ("done", "archived", "rejected")])
    }
}

print(json.dumps(result, indent=2))
PYEOF

rm -f "$MERGED_FILE"
