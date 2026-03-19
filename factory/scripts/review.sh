#!/usr/bin/env bash
# Factory Script 4.5: Paranoid Code Review
# Post-build, pre-QA code review. Catches bugs that tests don't catch.
# Runs Gemini against the git diff with a structured checklist.
#
# Usage:
#   bash factory/scripts/review.sh [idea-id]           # Review specific idea
#   bash factory/scripts/review.sh                      # Review top build-ready
#   bash factory/scripts/review.sh --auto               # Autonomous (cron-ready)
#
# Flow:
#   1. Get git diff (main vs factory branch)
#   2. Send diff + checklist to Gemini
#   3. Parse CRITICAL vs INFORMATIONAL findings
#   4. CRITICAL + auto mode → re-queue to build with review notes
#   5. No CRITICAL → pass, continue to QA
#
# Pipeline position: build.sh → ship.sh → review.sh → qa.sh
# Inspired by gstack /review (Garry Tan's pre-landing review)

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
REVIEWS_DIR="$FACTORY_DIR/reviews"
CHECKLIST="$FACTORY_DIR/checklists/review-checklist.md"

mkdir -p "$REVIEWS_DIR"

# ── Parse args ──
AUTO=false
IDEA_ID_ARG=""
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=true ;;
    idea-*) IDEA_ID_ARG="$arg" ;;
  esac
done

if [[ ! -f "$IDEAS_FILE" ]]; then
  echo "❌ No ideas file found"
  exit 1
fi

if [[ ! -f "$CHECKLIST" ]]; then
  echo "❌ Review checklist not found: $CHECKLIST"
  exit 1
fi

# ── Find target idea ──
if [[ -n "$IDEA_ID_ARG" ]]; then
  IDEA=$(grep "\"id\":\"$IDEA_ID_ARG\"\|\"id\": \"$IDEA_ID_ARG\"" "$IDEAS_FILE" | head -1)
else
  # Pick build-ready items (post-ship, pre-QA)
  IDEA=$( (grep '"status":"build-ready"\|"status": "build-ready"' "$IDEAS_FILE" 2>/dev/null || true) | \
    jq -s 'sort_by(.priority // 999) | .[0]' 2>/dev/null)
  [[ "$IDEA" == "null" ]] && IDEA=""
fi

if [[ -z "$IDEA" ]] || [[ "$IDEA" == "null" ]]; then
  echo "ℹ️  No build-ready ideas to review."
  exit 0
fi

IDEA_ID=$(echo "$IDEA" | jq -r '.id')
TITLE=$(echo "$IDEA" | jq -r '.title')
REPO=$(echo "$IDEA" | jq -r '.repo')
TARGET=$(echo "$IDEA" | jq -r '.target')
PR_URL=$(echo "$IDEA" | jq -r '.pr_url // "none"')

WORK_DIR="$HOME/pp-agent-work/factory-${IDEA_ID}"
TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
BRANCH_PREFIX=$(jq -r '.branch_prefix // "factory/"' "$TARGET_FILE" 2>/dev/null || echo "factory/")
BRANCH="${BRANCH_PREFIX}${IDEA_ID}"
REVIEW_FILE="$REVIEWS_DIR/${IDEA_ID}-code-review.md"

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Paranoid Code Review"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:     $IDEA_ID — $TITLE"
echo "Repo:     $REPO"
echo "Branch:   $BRANCH"
echo "Workdir:  $WORK_DIR"
echo ""

# ── Get the diff ──
if [[ ! -d "$WORK_DIR" ]]; then
  echo "❌ Workdir not found: $WORK_DIR"
  exit 1
fi

cd "$WORK_DIR"

# Fetch latest main
git fetch origin main --quiet 2>/dev/null || true

# Get the diff
DIFF=$(git diff origin/main --no-color 2>/dev/null || git diff main --no-color 2>/dev/null || echo "")
DIFF_STAT=$(git diff origin/main --stat 2>/dev/null || git diff main --stat 2>/dev/null || echo "N/A")
FILE_COUNT=$(git diff origin/main --name-only 2>/dev/null | wc -l | tr -d ' ')

if [[ -z "$DIFF" ]] || [[ "$FILE_COUNT" -eq 0 ]]; then
  echo "⚠️  No diff found against main. Nothing to review."
  exit 0
fi

echo "Files changed: $FILE_COUNT"
echo "$DIFF_STAT" | tail -1
echo ""

# ── Truncate diff if too large (Gemini context limits) ──
DIFF_CHARS=${#DIFF}
MAX_DIFF_CHARS=80000
if [[ $DIFF_CHARS -gt $MAX_DIFF_CHARS ]]; then
  echo "⚠️  Diff too large ($DIFF_CHARS chars), truncating to ${MAX_DIFF_CHARS}"
  DIFF="${DIFF:0:$MAX_DIFF_CHARS}

... [TRUNCATED — diff exceeds ${MAX_DIFF_CHARS} chars. Focus review on the visible portion.]"
fi

# ── Load the checklist ──
CHECKLIST_CONTENT=$(cat "$CHECKLIST")

# ── Build the review prompt ──
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" << PROMPT
You are a paranoid staff engineer doing a pre-merge code review. Your job is to find bugs that pass CI but blow up in production.

## Review Checklist
$CHECKLIST_CONTENT

## The Diff
This is the complete diff of the PR branch against main:

\`\`\`diff
$DIFF
\`\`\`

## Diff Stats
$DIFF_STAT

## Your Task
1. Read the FULL diff before commenting. Do NOT flag issues that are already addressed in the diff.
2. Apply the checklist in two passes: CRITICAL first, then INFORMATIONAL.
3. For each finding, cite the exact file and line from the diff.
4. Be terse: one line for the problem, one line for the fix.
5. Only flag real problems. Skip anything that's fine.
6. Respect the Suppressions section — do NOT flag suppressed patterns.

## Output Format
Start your response with a summary line:
REVIEW_SUMMARY: N issues (X critical, Y informational)

Then list findings:

**CRITICAL** (blocks merge):
- [file:line] Problem description
  Fix: suggested fix

**INFORMATIONAL** (non-blocking):
- [file:line] Problem description
  Fix: suggested fix

If no issues: REVIEW_SUMMARY: 0 issues (0 critical, 0 informational)

Be terse. No preamble, no "looks good overall", no compliments. Just findings.
PROMPT

# ── Run the review ──
if [[ "$AUTO" == true ]]; then
  echo "🔍 Running paranoid review via Gemini..."

  REVIEW_OUTPUT=$(gemini_generate "$PROMPT_FILE" 0.3)
  rm -f "$PROMPT_FILE"

  if [[ -z "$REVIEW_OUTPUT" ]]; then
    echo "⚠️  Gemini returned empty response — skipping review"
    exit 0
  fi

  echo ""
  echo "───── Code Review Results ─────"
  echo "$REVIEW_OUTPUT"
  echo ""

  # Save the review
  {
    echo "# Code Review: $IDEA_ID — $TITLE"
    echo "**Date:** $(date -u +"%Y-%m-%d %H:%M UTC")"
    echo "**Branch:** $BRANCH"
    echo "**Files:** $FILE_COUNT changed"
    echo ""
    echo "$REVIEW_OUTPUT"
  } > "$REVIEW_FILE"

  # ── Parse findings ──
  SUMMARY_LINE=$(echo "$REVIEW_OUTPUT" | grep -i "REVIEW_SUMMARY:" | head -1 || echo "")
  CRITICAL_COUNT=0
  INFO_COUNT=0

  if [[ -n "$SUMMARY_LINE" ]]; then
    CRITICAL_COUNT=$(echo "$SUMMARY_LINE" | grep -oE '[0-9]+ critical' | grep -oE '[0-9]+' || echo "0")
    INFO_COUNT=$(echo "$SUMMARY_LINE" | grep -oE '[0-9]+ informational' | grep -oE '[0-9]+' || echo "0")
  fi

  # Fall back to counting section entries if summary parsing fails
  if [[ "$CRITICAL_COUNT" == "0" ]]; then
    # Count lines starting with "- [" under CRITICAL section
    CRITICAL_COUNT=$(echo "$REVIEW_OUTPUT" | sed -n '/^\*\*CRITICAL\*\*/,/^\*\*INFORMATIONAL\*\*/p' | grep -c '^\- \[' 2>/dev/null || echo "0")
  fi
  if [[ "$INFO_COUNT" == "0" ]]; then
    INFO_COUNT=$(echo "$REVIEW_OUTPUT" | sed -n '/^\*\*INFORMATIONAL\*\*/,$p' | grep -c '^\- \[' 2>/dev/null || echo "0")
  fi

  CRITICAL_COUNT=$(echo "$CRITICAL_COUNT" | tr -d '[:space:]')
  INFO_COUNT=$(echo "$INFO_COUNT" | tr -d '[:space:]')

  echo "📋 Critical: $CRITICAL_COUNT | Informational: $INFO_COUNT"
  echo "📝 Review saved: $REVIEW_FILE"

  # ── Discord updates ──
  WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")

  if [[ "$CRITICAL_COUNT" -gt 0 ]]; then
    echo ""
    echo "🔴 CRITICAL findings detected — blocking QA"

    if [[ -n "$WIP_THREAD" ]]; then
      # Truncate review for Discord (2000 char limit)
      REVIEW_SNIPPET=$(echo "$REVIEW_OUTPUT" | head -30)
      discord_thread_post "$WIP_THREAD" "🔴 **Paranoid Review: $CRITICAL_COUNT CRITICAL finding(s)**

$REVIEW_SNIPPET

Review: \`factory/reviews/${IDEA_ID}-code-review.md\`"
    fi
    discord_post "$CH_PIPELINE" "🔴 **Review blocked** — $IDEA_ID: $CRITICAL_COUNT critical finding(s)"

    # ── Re-queue with review notes ──
    RETRY_COUNT=$(echo "$IDEA" | jq -r '.retry_count // 0')
    NEW_RETRY=$((RETRY_COUNT + 1))
    PRD_PATH="$FACTORY_DIR/prds/${IDEA_ID}.md"

    if [[ $NEW_RETRY -le 3 ]] && [[ -f "$PRD_PATH" ]]; then
      # Append review findings to PRD for Codex context
      {
        echo ""
        echo "## Code Review Findings (Retry #$NEW_RETRY)"
        echo "**Critical issues that MUST be fixed:**"
        echo ""
        echo "$REVIEW_OUTPUT" | sed -n '/^\*\*CRITICAL\*\*/,/^\*\*INFORMATIONAL\*\*/p' | head -40
        echo ""
        echo "Fix every CRITICAL issue listed above. Run \`npx tsc --noEmit\` after fixing."
      } >> "$PRD_PATH"

      # Re-queue
      TEMP=$(mktemp)
      while IFS= read -r line; do
        LINE_ID=$(echo "$line" | jq -r '.id')
        if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
          echo "$line" | jq -c --argjson retry "$NEW_RETRY" \
            '.status = "prd-ready" | .priority = 0 | .retry_count = $retry | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))'
        else
          echo "$line"
        fi
      done < "$IDEAS_FILE" > "$TEMP"
      mv "$TEMP" "$IDEAS_FILE"

      echo "🔄 Re-queued: $IDEA_ID → prd-ready (P0, retry #$NEW_RETRY)"
      if [[ -n "$WIP_THREAD" ]]; then
        discord_thread_post "$WIP_THREAD" "🔄 **Re-queued** for fix (retry #$NEW_RETRY of 3)"
      fi
    else
      echo "⚠️  Max retries reached or PRD missing — needs human intervention"
      discord_post "$CH_PIPELINE" "🔴 **Review: max retries** — $IDEA_ID needs human intervention"
    fi

    exit 1

  else
    echo ""
    echo "✅ No critical findings — clear for QA"

    if [[ -n "$WIP_THREAD" ]]; then
      REVIEW_MSG="✅ **Paranoid Review: PASSED**"
      if [[ "$INFO_COUNT" -gt 0 ]]; then
        REVIEW_MSG="✅ **Paranoid Review: PASSED** ($INFO_COUNT informational note(s))"
      fi
      discord_thread_post "$WIP_THREAD" "$REVIEW_MSG"
    fi
    discord_post "$CH_PIPELINE" "✅ **Review passed** — $IDEA_ID ($INFO_COUNT informational)"

    # Export findings for QA to pick up
    echo "$CRITICAL_COUNT" > "$REVIEWS_DIR/${IDEA_ID}-critical-count.txt"
    echo "$INFO_COUNT" > "$REVIEWS_DIR/${IDEA_ID}-info-count.txt"

    exit 0
  fi

else
  # Interactive mode
  echo "───── Review Prompt ─────"
  echo "Prompt saved to: $PROMPT_FILE"
  echo ""
  echo "Run: gemini_generate $PROMPT_FILE 0.3"
  echo "Or:  bash factory/scripts/review.sh $IDEA_ID --auto"
  echo ""
  echo "After review, continue to: bash factory/scripts/qa.sh $IDEA_ID"
fi
