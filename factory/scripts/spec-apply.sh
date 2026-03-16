#!/usr/bin/env bash
# Factory Spec Applier
# Takes PRD markdown from stdin, saves to prds/, validates paths, updates status.
#
# Usage: cat prd.md | bash factory/scripts/spec-apply.sh <idea-id>
#
# Or in auto flow: agent writes PRD, pipes to this script.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
PRDS_DIR="$FACTORY_DIR/prds"
CACHE_DIR="$HOME/pp-agent-work/factory-cache"

IDEA_ID="${1:?Usage: spec-apply.sh <idea-id>}"

mkdir -p "$PRDS_DIR"

# Read PRD from stdin
PRD_CONTENT=""
while IFS= read -r line; do
  PRD_CONTENT+="$line"$'\n'
done

if [[ -z "$PRD_CONTENT" ]]; then
  echo "❌ No PRD content received"
  exit 1
fi

# Get idea info
IDEA=$(jq -c "select(.id == \"$IDEA_ID\")" "$IDEAS_FILE" | head -1)
if [[ -z "$IDEA" ]] || [[ "$IDEA" == "null" ]]; then
  echo "❌ Idea $IDEA_ID not found"
  exit 1
fi

TITLE=$(echo "$IDEA" | jq -r '.title')
TARGET=$(echo "$IDEA" | jq -r '.target')
REPO=$(echo "$IDEA" | jq -r '.repo')
PRD_PATH="$PRDS_DIR/${IDEA_ID}.md"

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Spec (Apply)"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:     $IDEA_ID — $TITLE"
echo "PRD path: $PRD_PATH"
echo ""

# Save PRD
echo "$PRD_CONTENT" > "$PRD_PATH"
echo "✅ PRD saved: $PRD_PATH ($(wc -c < "$PRD_PATH" | tr -d ' ') bytes)"

# Validate file paths against repo cache
REPO_CACHE="$CACHE_DIR/$TARGET"
if [[ -d "$REPO_CACHE/src" ]]; then
  echo ""
  echo "───── Path Validation ─────"
  WARNINGS=0
  NEW_FILES=0

  # Extract src/ paths from PRD
  PRD_PATHS=$(grep -oE 'src/[a-zA-Z0-9_/.@\[\]-]+\.(ts|tsx|js|jsx)' "$PRD_PATH" 2>/dev/null | sort -u)

  for path in $PRD_PATHS; do
    if [[ -f "$REPO_CACHE/$path" ]]; then
      echo "  ✅ $path"
    else
      # Check if it looks like a new file (mentioned near "new", "add", "create")
      CONTEXT=$(grep -B1 -A1 "$path" "$PRD_PATH" 2>/dev/null | tr '\n' ' ')
      if echo "$CONTEXT" | grep -qiE "new|add|create"; then
        echo "  🆕 $path (new file)"
        NEW_FILES=$((NEW_FILES + 1))
      else
        echo "  ⚠️  $path (not found in repo)"
        WARNINGS=$((WARNINGS + 1))
      fi
    fi
  done

  echo ""
  if [[ $WARNINGS -eq 0 ]]; then
    echo "✅ All paths valid ($NEW_FILES new files planned)"
  else
    echo "⚠️  $WARNINGS path(s) may be typos — review before build"
  fi
else
  echo "⚠️  No repo cache found — skipping path validation"
fi

# Update idea status → prd-ready
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TEMP=$(mktemp)
while IFS= read -r line; do
  LINE_ID=$(echo "$line" | jq -r '.id')
  if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
    echo "$line" | jq -c --arg now "$NOW" --arg prd "factory/prds/${IDEA_ID}.md" \
      '.status = "prd-ready" | .prd_path = $prd | .updated_at = $now'
  else
    echo "$line"
  fi
done < "$IDEAS_FILE" > "$TEMP"
mv "$TEMP" "$IDEAS_FILE"
echo ""
echo "✅ Status: $IDEA_ID → prd-ready"

# Post to Discord
SUMMARY=$(head -20 "$PRD_PATH" | grep -E "^## Summary" -A5 | tail -4 | head -3 | tr '\n' ' ')
discord_post "$CH_PIPELINE" "📝 **Spec (Auto)** — PRD written for **$IDEA_ID: $TITLE**

${SUMMARY:0:300}

PRD: \`factory/prds/${IDEA_ID}.md\`
Next: \`bash factory/scripts/build.sh\`"

echo ""
echo "Next step: bash factory/scripts/build.sh"
