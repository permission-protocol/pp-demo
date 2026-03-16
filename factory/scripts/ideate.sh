#!/usr/bin/env bash
# Factory Script 1: Ideate
# Generates 3 product improvement ideas for a target.
#
# Usage:
#   bash factory/scripts/ideate.sh <target>              # Interactive (stdin)
#   bash factory/scripts/ideate.sh <target> --auto        # Autonomous (cron-ready)
#   bash factory/scripts/ideate.sh <target> --auto --organize  # Auto + rank after
#
# --auto mode builds a prompt from target config + FOCUS + existing ideas,
# spawns an isolated agentTurn, validates output, appends to ideas.jsonl,
# and posts to Discord. No human input needed.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
TARGET="${1:?Usage: ideate.sh <target> [--auto] [--organize]}"
shift
AUTO=false
ORGANIZE=false
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=true ;;
    --organize) ORGANIZE=true ;;
  esac
done

TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "❌ Target not found: $TARGET_FILE"
  echo "Available targets:"
  ls "$FACTORY_DIR/targets/" 2>/dev/null | sed 's/.json$//'
  exit 1
fi

# Parse target config
NAME=$(jq -r '.name' "$TARGET_FILE")
REPO=$(jq -r '.repo' "$TARGET_FILE")
PERSONAS=$(jq -r '.personas[]' "$TARGET_FILE")
PROMPT=$(jq -r '.ideate_prompt' "$TARGET_FILE")

# Get next idea ID
if [[ -f "$IDEAS_FILE" ]]; then
  LAST_ID=$(jq -r '.id // empty' "$IDEAS_FILE" 2>/dev/null | grep -oE '[0-9]+$' | sort -n | tail -1 || echo "0")
  NEXT_ID=$((10#$LAST_ID + 1))
else
  NEXT_ID=1
  touch "$IDEAS_FILE"
fi

# ── Count active ideas (non-archived, non-shipped) ──
ACTIVE_COUNT=0
if [[ -f "$IDEAS_FILE" ]] && [[ -s "$IDEAS_FILE" ]]; then
  ACTIVE_COUNT=$(jq -c 'select(.status != "archived" and .status != "shipped")' "$IDEAS_FILE" 2>/dev/null | wc -l | tr -d ' ')
fi

MAX_ACTIVE=20

# ── Auto mode: build prompt and write to file for agentTurn ──
if [[ "$AUTO" == true ]]; then

  # Gate: skip if backlog is full
  if [[ "$ACTIVE_COUNT" -ge "$MAX_ACTIVE" ]]; then
    echo "⏭️  Skipping ideation: $ACTIVE_COUNT active ideas (max $MAX_ACTIVE)"
    discord_post "$CH_PIPELINE" "⏭️ **Ideate skipped** — backlog has $ACTIVE_COUNT active ideas (max $MAX_ACTIVE). Run \`organize.sh\` or ship some first."
    exit 0
  fi

  # Build existing ideas summary for dedup
  EXISTING_SUMMARY=""
  if [[ -f "$IDEAS_FILE" ]] && [[ -s "$IDEAS_FILE" ]]; then
    EXISTING_SUMMARY=$(jq -r '"- \(.id): \(.title) — \(.description[0:120])"' "$IDEAS_FILE" 2>/dev/null | head -30)
  fi

  # Read FOCUS.md
  FOCUS_CONTENT=""
  FOCUS_PATH="$HOME/.openclaw/workspace/pp-os/FOCUS.md"
  if [[ -f "$FOCUS_PATH" ]]; then
    FOCUS_CONTENT=$(cat "$FOCUS_PATH")
  fi

  # Read STATUS.md
  STATUS_CONTENT=""
  STATUS_PATH="$HOME/.openclaw/workspace/pp-os/STATUS.md"
  if [[ -f "$STATUS_PATH" ]]; then
    STATUS_CONTENT=$(cat "$STATUS_PATH")
  fi

  # Read context files from target config
  CONTEXT_CONTENT=""
  for ctx in $(jq -r '.context_files[]' "$TARGET_FILE"); do
    FULL_PATH="$HOME/.openclaw/workspace/$ctx"
    if [[ -f "$FULL_PATH" ]]; then
      CONTEXT_CONTENT+="
--- $ctx ---
$(head -100 "$FULL_PATH")
"
    fi
  done

  # Get repo file tree (from cache — pull latest first)
  REPO_TREE=""
  CACHE_DIR="$HOME/pp-agent-work/factory-cache/$(jq -r '.target // "pp"' "$TARGET_FILE")"
  if [[ -d "$CACHE_DIR" ]]; then
    echo "📥 Updating repo cache..."
    git -C "$CACHE_DIR" pull --quiet 2>/dev/null || echo "⚠️  Cache pull failed (offline?)"
    REPO_TREE=$(cd "$CACHE_DIR" && find src -type f -name '*.ts' -o -name '*.tsx' 2>/dev/null | sort | head -80)
  fi

  # Build the prompt (persistent path — survives script exit)
  mkdir -p "$FACTORY_DIR/prompts"
  PROMPT_FILE="$FACTORY_DIR/prompts/ideate-latest.txt"
  cat > "$PROMPT_FILE" << AUTOPROMPT
You are the Create Factory ideation engine for $NAME ($REPO).

## Your Task
Generate exactly 3 product improvement ideas. Output ONLY 3 lines of JSON — one JSON object per line, nothing else. No markdown, no explanation, no code fences.

## Each idea must have these fields:
- "title": One-line description (concise, specific)
- "description": 2-3 sentences naming specific files, components, or behaviors to change
- "type": "feature" | "bug" (use "bug" if describing something broken/wrong; "feature" for new capabilities or improvements)
- "persona": "Marco" | "Sarah" | "Both"
- "size": "S" (hours) | "M" (half-day) | "L" (full day)

## Personas
$PERSONAS

## FOCUS Filter (HARD CONSTRAINT)
Every idea MUST pass this filter. If it doesn't directly help the deploy-gate mission, don't suggest it.

$FOCUS_CONTENT

## Current Status
$STATUS_CONTENT

## Strategic Context
$CONTEXT_CONTENT

## Repo Structure (key directories)
$REPO_TREE

## Existing Ideas (DO NOT DUPLICATE — suggest genuinely different improvements)
$EXISTING_SUMMARY

## Ideation Prompt
$PROMPT

## Output Format
Exactly 3 lines, each a valid JSON object. Example:
{"title":"Example title","description":"Example description naming specific files.","type":"feature","persona":"Marco","size":"S"}
{"title":"Another title","description":"Another description of a broken behavior.","type":"bug","persona":"Sarah","size":"M"}
{"title":"Third title","description":"Third description.","type":"feature","persona":"Both","size":"S"}
AUTOPROMPT

  echo "═══════════════════════════════════════════════════════"
  echo "  🏭 CREATE FACTORY — Ideate (Auto Mode)"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  echo "Target:     $NAME ($REPO)"
  echo "Active:     $ACTIVE_COUNT / $MAX_ACTIVE ideas"
  echo "Next ID:    idea-$(printf '%03d' $NEXT_ID)"
  echo "Existing:   $(wc -l < "$IDEAS_FILE" | tr -d ' ') total"
  echo "Prompt:     $PROMPT_FILE"
  echo ""
  echo "Calling Gemini ($GEMINI_MODEL)..."
  echo ""

  LLM_OUTPUT=$(gemini_generate "$PROMPT_FILE" 0.7)
  if [[ $? -ne 0 ]] || [[ -z "$LLM_OUTPUT" ]]; then
    echo "❌ Gemini call failed"
    discord_post "$CH_PIPELINE" "❌ **Ideate failed** — Gemini returned no ideas"
    exit 1
  fi

  echo "───── LLM Output ─────"
  echo "$LLM_OUTPUT"
  echo ""

  # Pipe to ideate-auto.sh via stdin
  echo "$LLM_OUTPUT" | bash "$FACTORY_DIR/scripts/ideate-auto.sh" "$TARGET" $([ "$ORGANIZE" == true ] && echo "--organize")

  exit 0
fi

# ══════════════════════════════════════════════════════════
# Interactive mode (original behavior)
# ══════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Ideate"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Target:    $NAME ($REPO)"
echo "Ideas file: $IDEAS_FILE"
echo "Next ID:   idea-$(printf '%03d' $NEXT_ID)"
echo "Active:    $ACTIVE_COUNT / $MAX_ACTIVE ideas"
echo ""
echo "───── Personas ─────"
echo "$PERSONAS"
echo ""
echo "───── Context ─────"
for ctx in $(jq -r '.context_files[]' "$TARGET_FILE"); do
  FULL_PATH="$HOME/.openclaw/workspace/$ctx"
  if [[ -f "$FULL_PATH" ]]; then
    echo "📄 $ctx ($(wc -l < "$FULL_PATH") lines)"
  else
    echo "⚠️  $ctx (not found)"
  fi
done
echo ""
echo "───── Prompt ─────"
echo "$PROMPT"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""

# Gate: skip if backlog is full
if [[ "$ACTIVE_COUNT" -ge "$MAX_ACTIVE" ]]; then
  echo "⏭️  Backlog full: $ACTIVE_COUNT active ideas (max $MAX_ACTIVE)"
  echo "   Run organize.sh to archive/ship, or increase the cap."
  exit 0
fi

echo "Charles: Generate exactly 3 ideas. For each, provide:"
echo "  - title: One-line description"
echo "  - description: 2-3 sentences, specific files/components"
echo "  - persona: Marco | Sarah | Both"
echo "  - complexity: S (hours) | M (half-day) | L (full day)"
echo ""
echo "Paste each idea as a JSON object (one per line)."
echo "Press Ctrl+D when done."
echo ""

# Read ideas from stdin
IDEAS=()
while IFS= read -r line; do
  # Skip empty lines
  [[ -z "$line" ]] && continue

  # Validate JSON
  if ! echo "$line" | jq . > /dev/null 2>&1; then
    echo "⚠️  Invalid JSON, skipping: $line"
    continue
  fi

  # Add metadata
  ID="idea-$(printf '%03d' $NEXT_ID)"
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  ENRICHED=$(echo "$line" | jq --arg id "$ID" --arg target "$TARGET" \
    --arg repo "$REPO" --arg now "$NOW" \
    '. + {
      id: $id,
      target: $target,
      repo: $repo,
      status: "idea-generated",
      priority: null,
      prd_path: null,
      pr_url: null,
      created_at: $now,
      updated_at: $now,
      archived_reason: null
    }')

  echo "$ENRICHED" >> "$IDEAS_FILE"
  echo "✅ Added: $ID — $(echo "$line" | jq -r '.title')"

  IDEAS+=("$ID")
  NEXT_ID=$((NEXT_ID + 1))
done

echo ""
echo "───── Summary ─────"
echo "Added ${#IDEAS[@]} ideas to $IDEAS_FILE"
echo "Total ideas in backlog: $(wc -l < "$IDEAS_FILE" | tr -d ' ')"
echo ""

# ── Post to Discord #factory-pipeline ──
if [[ ${#IDEAS[@]} -gt 0 ]]; then
  IDEA_LIST=""
  for ID in "${IDEAS[@]}"; do
    TITLE_LINE=$(grep "\"id\":\"$ID\"\|\"id\": \"$ID\"" "$IDEAS_FILE" | jq -r '.title')
    IDEA_LIST+=$'\n'"  • **$ID**: $TITLE_LINE"
  done

  discord_post "$CH_PIPELINE" "🏭 **Ideate** — Generated ${#IDEAS[@]} ideas for **$NAME**:$IDEA_LIST

Next: \`bash factory/scripts/organize.sh\`"
fi

echo "Next step: bash factory/scripts/organize.sh"
