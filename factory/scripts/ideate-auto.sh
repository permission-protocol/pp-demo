#!/usr/bin/env bash
# Factory Auto-Ideate Runner
# Called by cron agentTurn. Reads prompt from ideate.sh --auto,
# generates ideas, validates, appends, and posts to Discord.
#
# Usage: bash factory/scripts/ideate-auto.sh <target> [--organize]
#
# This script:
# 1. Runs ideate.sh --auto to build the prompt + get context
# 2. Reads the prompt output
# 3. Expects the calling agent to generate ideas based on the prompt
# 4. Validates and appends ideas to ideas.jsonl
# 5. Posts results to Discord

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"

TARGET="${1:?Usage: ideate-auto.sh <target> [--organize]}"
ORGANIZE=false
[[ "${2:-}" == "--organize" ]] && ORGANIZE=true

IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
NAME=$(jq -r '.name' "$TARGET_FILE")
REPO=$(jq -r '.repo' "$TARGET_FILE")

# Get next ID
if [[ -f "$IDEAS_FILE" ]]; then
  LAST_ID=$(jq -r '.id // empty' "$IDEAS_FILE" 2>/dev/null | grep -oE '[0-9]+$' | sort -n | tail -1 || echo "0")
  NEXT_ID=$((10#$LAST_ID + 1))
else
  NEXT_ID=1
  touch "$IDEAS_FILE"
fi

# Check active count
ACTIVE_COUNT=$(jq -c 'select(.status != "archived" and .status != "shipped")' "$IDEAS_FILE" 2>/dev/null | wc -l | tr -d ' ')
MAX_ACTIVE=20

if [[ "$ACTIVE_COUNT" -ge "$MAX_ACTIVE" ]]; then
  echo "⏭️  Skipping: $ACTIVE_COUNT active ideas (max $MAX_ACTIVE)"
  discord_post "$CH_PIPELINE" "⏭️ **Ideate skipped** — backlog has $ACTIVE_COUNT active ideas (max $MAX_ACTIVE)."
  exit 0
fi

# Append ideas from stdin (agent pipes JSON lines here)
IDEAS=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # Strip markdown fences if the LLM wraps output
  line=$(echo "$line" | sed 's/^```json//;s/^```//;s/```$//')
  [[ -z "$line" ]] && continue

  if ! echo "$line" | jq . > /dev/null 2>&1; then
    echo "⚠️  Invalid JSON, skipping: $line"
    continue
  fi

  # Validate required fields
  TITLE=$(echo "$line" | jq -r '.title // empty')
  DESC=$(echo "$line" | jq -r '.description // empty')
  if [[ -z "$TITLE" ]] || [[ -z "$DESC" ]]; then
    echo "⚠️  Missing title or description, skipping"
    continue
  fi

  ID="idea-$(printf '%03d' $NEXT_ID)"
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Preserve type (bug/feature), size (S/M/L), persona from LLM output; default missing fields
  ENRICHED=$(echo "$line" | jq -c --arg id "$ID" --arg target "$TARGET" \
    --arg repo "$REPO" --arg now "$NOW" \
    '{
      id: $id,
      title: .title,
      description: .description,
      type: (.type // "feature"),
      persona: (.persona // "Both"),
      size: (.size // "M"),
      target: $target,
      repo: $repo,
      status: "spec-ready",
      priority: null,
      prd_path: null,
      pr_url: null,
      created_at: $now,
      updated_at: $now,
      archived_reason: null
    } + (to_entries | map(select(.key | IN("title","description","type","persona","size","id","target","repo","status","priority","prd_path","pr_url","created_at","updated_at","archived_reason") | not)) | from_entries)')

  echo "$ENRICHED" >> "$IDEAS_FILE"
  echo "✅ $ID — $TITLE"
  IDEAS+=("$ID")
  NEXT_ID=$((NEXT_ID + 1))
done

# Post to Discord
if [[ ${#IDEAS[@]} -gt 0 ]]; then
  IDEA_LIST=""
  for ID in "${IDEAS[@]}"; do
    TITLE_LINE=$(grep "\"id\":[[:space:]]*\"$ID\"" "$IDEAS_FILE" | head -1 | jq -r '.title')
    IDEA_LIST+=$'\n'"  • **$ID**: $TITLE_LINE"
  done

  discord_post "$CH_PIPELINE" "🏭 **Ideate (Auto)** — Generated ${#IDEAS[@]} ideas for **$NAME**:$IDEA_LIST

Next: \`bash factory/scripts/organize.sh\`"

  echo ""
  echo "Added ${#IDEAS[@]} ideas. Total active: $((ACTIVE_COUNT + ${#IDEAS[@]}))"
else
  echo "⚠️  No valid ideas received."
  discord_post "$CH_PIPELINE" "⚠️ **Ideate (Auto)** — No valid ideas generated for **$NAME**. Check logs."
fi

# Optionally chain organize
if [[ "$ORGANIZE" == true ]] && [[ ${#IDEAS[@]} -gt 0 ]]; then
  echo ""
  echo "───── Auto-organizing... ─────"
  echo "Chain to organize.sh would run here (requires agent interaction)"
  echo "ORGANIZE_NEEDED=true"
fi
