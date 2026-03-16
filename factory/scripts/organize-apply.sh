#!/usr/bin/env bash
# Factory Organize Applier
# Takes ranking JSON from stdin (from LLM), validates, and applies to ideas.jsonl.
#
# Usage: echo '{"rankings":[...]}' | bash factory/scripts/organize-apply.sh
#
# Expected input format:
# {"rankings":[
#   {"id":"idea-001","priority":1,"action":"keep"},
#   {"id":"idea-009","priority":null,"action":"archive","reason":"..."}
# ]}

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
ARCHIVE_FILE="$FACTORY_DIR/ideas-archive.jsonl"
MAX_ACTIVE=15

touch "$ARCHIVE_FILE" 2>/dev/null || true

# Read ranking JSON from stdin
RANKING_JSON=""
while IFS= read -r line; do
  # Strip markdown fences
  line=$(echo "$line" | sed 's/^```json//;s/^```//;s/```$//')
  RANKING_JSON+="$line"
done

if [[ -z "$RANKING_JSON" ]]; then
  echo "❌ No ranking input received"
  exit 1
fi

# Validate it's valid JSON with a rankings array
if ! echo "$RANKING_JSON" | jq -e '.rankings | length > 0' > /dev/null 2>&1; then
  echo "❌ Invalid ranking JSON — must have 'rankings' array"
  echo "Got: ${RANKING_JSON:0:200}"
  exit 1
fi

RANKING_COUNT=$(echo "$RANKING_JSON" | jq '.rankings | length')
IDEA_COUNT=$(wc -l < "$IDEAS_FILE" | tr -d ' ')

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Organize (Apply)"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Rankings received: $RANKING_COUNT"
echo "Ideas in backlog:  $IDEA_COUNT"
echo ""

# Validate: every idea must appear in rankings
IDEA_IDS=$(jq -r '.id' "$IDEAS_FILE" | sort)
RANKING_IDS=$(echo "$RANKING_JSON" | jq -r '.rankings[].id' | sort)

MISSING=$(comm -23 <(echo "$IDEA_IDS") <(echo "$RANKING_IDS"))
if [[ -n "$MISSING" ]]; then
  echo "⚠️  Ideas missing from rankings (will keep with low priority):"
  echo "$MISSING"
  echo ""
fi

# Validate: top 5 keep items must have unique priorities
TOP5=$(echo "$RANKING_JSON" | jq -r '[.rankings[] | select(.action == "keep" and .priority != null and .priority <= 5)] | sort_by(.priority) | .[0:5] | map(.priority) | unique | length')
TOP5_TOTAL=$(echo "$RANKING_JSON" | jq -r '[.rankings[] | select(.action == "keep" and .priority != null and .priority <= 5)] | length')
if [[ "$TOP5_TOTAL" -gt 0 ]] && [[ "$TOP5" -ne "$TOP5_TOTAL" ]]; then
  echo "⚠️  Top 5 priorities have ties — proceeding anyway but spec.sh may need tiebreaking"
fi

# Apply rankings using Python for reliability
python3 << 'PYEOF' - "$IDEAS_FILE" "$ARCHIVE_FILE" "$MAX_ACTIVE" "$RANKING_JSON"
import json, sys
from datetime import datetime, timezone

ideas_file = sys.argv[1]
archive_file = sys.argv[2]
max_active = int(sys.argv[3])
ranking_json = json.loads(sys.argv[4])

# Load ideas
ideas = {}
with open(ideas_file) as f:
    for line in f:
        line = line.strip()
        if line:
            idea = json.loads(line)
            ideas[idea["id"]] = idea

# Build ranking lookup
rankings = {r["id"]: r for r in ranking_json["rankings"]}

now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

active = []
archived = []

for idea_id, idea in ideas.items():
    idea["updated_at"] = now
    
    if idea_id in rankings:
        r = rankings[idea_id]
        
        if r["action"] == "archive":
            # Protect immune statuses (already built or in progress)
            immune = {"build-wip", "build-ready", "qa-wip", "qa-passed", "shipped"}
            if idea.get("status") in immune:
                print(f"  🛡️ Protected: {idea_id} [{idea['status']}] — immune from archival")
                idea["priority"] = r.get("priority", 99)
                active.append(idea)
                continue
            idea["status"] = "archived"
            idea["priority"] = None
            idea["archived_reason"] = r.get("reason", "Archived by organize")
            archived.append(idea)
            print(f"  📦 Archived: {idea_id} — {r.get('reason', 'no reason')[:70]}")
        else:
            # Keep — update priority, promote to backlog-ready if still idea-generated
            idea["priority"] = r.get("priority")
            if idea["status"] == "idea-generated":
                idea["status"] = "backlog-ready"
            active.append(idea)
            print(f"  P{r.get('priority', '?'):>2} | {idea_id} | {idea['title'][:60]}")
    else:
        # Not in rankings — keep with low priority
        idea["priority"] = 999
        active.append(idea)
        print(f"  P?? | {idea_id} | {idea['title'][:60]} (not ranked, keeping)")

# Sort active by priority
active.sort(key=lambda x: x.get("priority") or 999)

# Enforce max active — overflow to archive
overflow = []
if len(active) > max_active:
    overflow = active[max_active:]
    active = active[:max_active]
    for idea in overflow:
        idea["status"] = "archived"
        idea["archived_reason"] = f"Overflow: exceeded {max_active} active ideas"
        print(f"  📦 Overflow: {idea['id']} — {idea['title'][:50]}")

# Write active
with open(ideas_file, 'w') as f:
    for idea in active:
        f.write(json.dumps(idea) + '\n')

# Append archived + overflow
all_archived = archived + overflow
if all_archived:
    with open(archive_file, 'a') as f:
        for idea in all_archived:
            f.write(json.dumps(idea) + '\n')

print(f"\n── Summary ──")
print(f"Active:   {len(active)}")
print(f"Archived: {len(archived)}")
print(f"Overflow: {len(overflow)}")
print(f"Total archive: {len(all_archived)}")

# Output for Discord
keep_lines = []
for idea in active[:5]:
    keep_lines.append(f"P{idea.get('priority', '?')} | {idea['id']} | {idea['title'][:60]}")

archive_lines = []
for idea in all_archived:
    archive_lines.append(f"{idea['id']}: {idea.get('archived_reason', 'no reason')[:60]}")

# Write Discord summary to temp file for parent script
summary = f"Active: {len(active)} | Archived: {len(all_archived)}"
with open('/tmp/organize-discord-summary.txt', 'w') as f:
    f.write(summary + '\n')
    f.write("TOP5:\n")
    for line in keep_lines:
        f.write(line + '\n')
    if archive_lines:
        f.write("ARCHIVED:\n")
        for line in archive_lines:
            f.write(line + '\n')
PYEOF

echo ""

# Post to Discord
if [[ -f /tmp/organize-discord-summary.txt ]]; then
  SUMMARY=$(head -1 /tmp/organize-discord-summary.txt)
  TOP5_TEXT=$(awk '/^TOP5:/{found=1;next} /^ARCHIVED:/{found=0} found' /tmp/organize-discord-summary.txt | head -5)
  ARCHIVE_TEXT=$(awk '/^ARCHIVED:/{found=1;next} found' /tmp/organize-discord-summary.txt | head -5)
  
  DISCORD_MSG="🏭 **Organize (Auto)** — $SUMMARY

**Top 5:**
$(echo "$TOP5_TEXT" | sed 's/^/  /')
"
  if [[ -n "$ARCHIVE_TEXT" ]]; then
    DISCORD_MSG+="
**Archived:**
$(echo "$ARCHIVE_TEXT" | sed 's/^/  /')"
  fi
  
  DISCORD_MSG+="

Next: \`bash factory/scripts/spec.sh\`"
  
  discord_post "$CH_PIPELINE" "$DISCORD_MSG"
  rm -f /tmp/organize-discord-summary.txt
fi

echo "Next step: bash factory/scripts/spec.sh"
