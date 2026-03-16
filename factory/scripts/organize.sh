#!/usr/bin/env bash
# Factory Script 2: Organize
# Ranks, dedupes, and manages the idea backlog.
#
# Usage:
#   bash factory/scripts/organize.sh              # Interactive (stdin)
#   bash factory/scripts/organize.sh --auto        # Autonomous (cron-ready)
#
# --auto mode builds a prompt with all ideas + FOCUS + STATUS,
# expects a ranking JSON on stdin, validates, and applies it.
# Interactive mode shows the backlog and waits for manual JSONL input.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
ARCHIVE_FILE="$FACTORY_DIR/ideas-archive.jsonl"
MAX_ACTIVE=15

AUTO=false
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=true ;;
  esac
done

if [[ ! -f "$IDEAS_FILE" ]] || [[ ! -s "$IDEAS_FILE" ]]; then
  echo "❌ No ideas found in $IDEAS_FILE"
  exit 1
fi

touch "$ARCHIVE_FILE" 2>/dev/null || true

TOTAL=$(wc -l < "$IDEAS_FILE" | tr -d ' ')

# ══════════════════════════════════════════════════════════
# Auto mode: build prompt, expect ranking JSON on stdin
# ══════════════════════════════════════════════════════════
if [[ "$AUTO" == true ]]; then

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

  # Build ideas summary (mark immune ideas)
  IMMUNE_STATUSES=$(factory_config '.immune_statuses | join("|")' 2>/dev/null || echo "build-wip|build-ready|qa-wip|qa-passed|shipped")
  IDEAS_SUMMARY=$(jq -r --arg immune "$IMMUNE_STATUSES" '
    if (.status | test($immune)) then
      "- \(.id) [\(.complexity)] (\(.persona)) ⚠️IMMUNE[\(.status)]: \(.title) — \(.description[0:120])"
    else
      "- \(.id) [\(.complexity)] (\(.persona)): \(.title) — \(.description[0:150])"
    end' "$IDEAS_FILE")

  echo "═══════════════════════════════════════════════════════"
  echo "  🏭 CREATE FACTORY — Organize (Auto Mode)"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  echo "Ideas:      $TOTAL in backlog"
  echo "Max active: $MAX_ACTIVE (overflow archived)"
  echo ""

  # Build prompt file
  mkdir -p "$FACTORY_DIR/prompts"
  PROMPT_FILE="$FACTORY_DIR/prompts/organize-latest.txt"
  cat > "$PROMPT_FILE" << AUTOPROMPT

You are the Create Factory organize engine. Rank and triage the idea backlog.

## Your Task
Review all ideas below. Output a single JSON object with a "rankings" array. Nothing else — no markdown, no explanation, no code fences.

## Rules
1. Top 5 ideas must have UNIQUE priorities (1-5). No ties in the top 5.
2. Ideas ranked 6+ can share priority tiers.
3. Max $MAX_ACTIVE active ideas. If there are more, archive the weakest.
4. Archive any idea that is:
   - Premature (needs users/feedback we don't have yet)
   - Duplicate (overlaps significantly with a higher-ranked idea)
   - Off-FOCUS (doesn't directly help the deploy-gate mission)
5. Re-rank everything — don't assume prior rankings are correct.
6. Every idea must appear exactly once in the output.
7. Ideas marked ⚠️IMMUNE are ALREADY BUILT or IN PROGRESS. You MUST keep them (action: "keep"). Never archive immune ideas.
8. **Diversity check:** If 3+ of your top 5 touch the same page/component (e.g. all approval screen), flag it in your reasoning and spread priorities across different surfaces (CI output, GitHub Action, approval page, onboarding, dashboard).
9. **Type awareness:** Ideas with type "bug" that affect core user flows (Marco or Sarah blocked) should generally rank above features of the same size.

## FOCUS Filter (ranking criterion #1)
$FOCUS_CONTENT

## Current Status (what's already in-flight)
$STATUS_CONTENT

## Ideas to Rank
$IDEAS_SUMMARY

## Output Format
One JSON object, no wrapping:
{"rankings":[{"id":"idea-001","priority":1,"action":"keep"},{"id":"idea-009","priority":null,"action":"archive","reason":"Premature: needs user feedback first"}]}

Every idea must have: id, action ("keep" or "archive"). "keep" ideas must have integer priority. "archive" ideas must have reason.
AUTOPROMPT

  echo "Calling Gemini ($GEMINI_MODEL) for ranking..."
  echo ""

  LLM_OUTPUT=$(gemini_generate "$PROMPT_FILE" 0.3)
  if [[ $? -ne 0 ]] || [[ -z "$LLM_OUTPUT" ]]; then
    echo "❌ Gemini call failed"
    discord_post "$CH_PIPELINE" "❌ **Organize failed** — Gemini returned no ranking"
    exit 1
  fi

  echo "───── LLM Ranking ─────"
  echo "$LLM_OUTPUT"
  echo ""

  # Pipe to organize-apply.sh via stdin
  echo "$LLM_OUTPUT" | bash "$FACTORY_DIR/scripts/organize-apply.sh"

  exit 0
fi

# ══════════════════════════════════════════════════════════
# Interactive mode (original behavior, improved)
# ══════════════════════════════════════════════════════════

UNRANKED=$(jq -c 'select(.status == "idea-generated")' "$IDEAS_FILE" 2>/dev/null | wc -l | tr -d ' ')

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Organize"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Backlog:   $TOTAL ideas ($UNRANKED unranked)"
echo "Archive:   $(wc -l < "$ARCHIVE_FILE" | tr -d ' ') ideas"
echo ""
echo "───── Current Backlog ─────"

# Show all ideas grouped by status
for STATUS in "idea-generated" "backlog-ready" "prd-wip" "prd-ready" "build-wip" "build-ready" "qa-wip" "qa-passed" "shipped"; do
  ITEMS=$(jq -c "select(.status == \"$STATUS\")" "$IDEAS_FILE" 2>/dev/null || true)
  if [[ -n "$ITEMS" ]]; then
    COUNT=$(echo "$ITEMS" | wc -l | tr -d ' ')
    echo ""
    echo "  [$STATUS] ($COUNT)"
    echo "$ITEMS" | jq -r '  "    \(.id) | P\(.priority // "?") | \(.complexity // "?") | \(.target) | \(.title)"'
  fi
done

echo ""
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Charles: Review the backlog and output the FULL ranked list"
echo "as one JSON object per line. For each idea:"
echo "  - Set priority (1=highest)"
echo "  - Set status to 'backlog-ready' (if currently idea-generated)"
echo "  - Mark duplicates with status 'archived' and archived_reason"
echo ""
echo "Rules:"
echo "  - Max $MAX_ACTIVE in active backlog"
echo "  - Items with status beyond backlog-ready are locked (don't change)"
echo "  - P1-P5 must be uniquely ranked"
echo ""
echo "Paste the updated JSONL (one object per line)."
echo "Press Ctrl+D when done."
echo ""

# Read the updated backlog
TEMP_FILE=$(mktemp)
ARCHIVE_TEMP=$(mktemp)
ACTIVE_COUNT=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  if ! echo "$line" | jq . > /dev/null 2>&1; then
    echo "⚠️  Invalid JSON, skipping"
    continue
  fi

  STATUS=$(echo "$line" | jq -r '.status')
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  UPDATED=$(echo "$line" | jq --arg now "$NOW" '.updated_at = $now')

  if [[ "$STATUS" == "archived" ]]; then
    echo "$UPDATED" >> "$ARCHIVE_TEMP"
    echo "📦 Archived: $(echo "$line" | jq -r '.id') — $(echo "$line" | jq -r '.archived_reason // "no reason"')"
  else
    ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
    if [[ $ACTIVE_COUNT -le $MAX_ACTIVE ]]; then
      echo "$UPDATED" >> "$TEMP_FILE"
    else
      OVERFLOW=$(echo "$UPDATED" | jq '.status = "archived" | .archived_reason = "overflow: exceeded max active ideas"')
      echo "$OVERFLOW" >> "$ARCHIVE_TEMP"
      echo "📦 Overflow archived: $(echo "$line" | jq -r '.id')"
    fi
  fi
done

# Apply changes
if [[ -s "$TEMP_FILE" ]]; then
  mv "$TEMP_FILE" "$IDEAS_FILE"
  cat "$ARCHIVE_TEMP" >> "$ARCHIVE_FILE" 2>/dev/null

  NEW_TOTAL=$(wc -l < "$IDEAS_FILE" | tr -d ' ')
  ARCHIVED_NOW=$(wc -l < "$ARCHIVE_TEMP" 2>/dev/null | tr -d ' ')

  echo ""
  echo "───── Summary ─────"
  echo "Active backlog: $NEW_TOTAL ideas"
  echo "Archived this run: $ARCHIVED_NOW"
  echo "Total archive: $(wc -l < "$ARCHIVE_FILE" | tr -d ' ')"
  echo ""
  echo "Next step: bash factory/scripts/spec.sh"
else
  echo ""
  echo "⚠️  No input received. Backlog unchanged."
  rm -f "$TEMP_FILE"
fi

rm -f "$ARCHIVE_TEMP"
