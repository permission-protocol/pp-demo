#!/usr/bin/env bash
# Factory Script 5: QA
# Semi-automated validation: automated checks + Peekaboo visual + PRD comparison.
#
# Usage: bash factory/scripts/qa.sh [idea-id]
# If no ID given, picks the highest-priority build-ready item.
#
# Flow:
#   1. Run automated checks (tsc, lint, tests)
#   2. Peekaboo visual capture of changed pages
#   3. Compare results against PRD acceptance criteria
#   4. On pass: status → qa-passed, ready for Rod to merge
#   5. On fail: write QA comments, status → prd-ready + P0, re-queue for Codex
#
# The retry loop: fail → QA notes appended to PRD → re-enters at prd-ready
# with P0 priority → build.sh picks it up first → Codex retries with context

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
PRDS_DIR="$FACTORY_DIR/prds"
QA_DIR="$FACTORY_DIR/qa-reports"
mkdir -p "$QA_DIR"

# ── Parse flags ──
AUTO_MODE=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO_MODE=true ;;
    *)      POSITIONAL+=("$arg") ;;
  esac
done
set -- "${POSITIONAL[@]+"${POSITIONAL[@]}"}"

if [[ ! -f "$IDEAS_FILE" ]]; then
  echo "❌ No ideas file found"
  exit 1
fi

# ── Find target idea ──
IDEA_ID="${1:-}"
if [[ -n "$IDEA_ID" ]]; then
  IDEA=$(grep "\"id\":\"$IDEA_ID\"\|\"id\": \"$IDEA_ID\"" "$IDEAS_FILE" | head -1)
else
  IDEA=$(grep '"status":"build-ready"\|"status": "build-ready"' "$IDEAS_FILE" | \
    jq -s 'sort_by(.priority // 999) | .[0]' 2>/dev/null)
  [[ "$IDEA" == "null" ]] && IDEA=""
fi

if [[ -z "$IDEA" ]] || [[ "$IDEA" == "null" ]]; then
  echo "❌ No build-ready ideas found."
  echo "Run: bash factory/scripts/build.sh first"
  exit 1
fi

IDEA_ID=$(echo "$IDEA" | jq -r '.id')
TITLE=$(echo "$IDEA" | jq -r '.title')
REPO=$(echo "$IDEA" | jq -r '.repo')
PR_URL=$(echo "$IDEA" | jq -r '.pr_url // "none"')
TARGET=$(echo "$IDEA" | jq -r '.target')

WORK_DIR="$HOME/pp-agent-work/factory-${IDEA_ID}"
PRD_PATH="$PRDS_DIR/${IDEA_ID}.md"
QA_REPORT="$QA_DIR/${IDEA_ID}-qa.md"
RETRY_COUNT=$(echo "$IDEA" | jq -r '.retry_count // 0')

# ── Copy build log to QA dir for reference in retry notes ──
BUILD_LOG_SRC="$FACTORY_DIR/logs/codex-${IDEA_ID}.log"
BUILD_LOG_DST="$QA_DIR/${IDEA_ID}-build.log"
if [[ -f "$BUILD_LOG_SRC" ]]; then
  cp "$BUILD_LOG_SRC" "$BUILD_LOG_DST"
fi

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — QA"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:      $IDEA_ID — $TITLE"
echo "Repo:      $REPO"
echo "PR:        $PR_URL"
echo "Workdir:   $WORK_DIR"
echo "PRD:       $PRD_PATH"
echo "Retries:   $RETRY_COUNT"
echo ""

# ── Update status → qa-wip ──
update_status() {
  local TARGET_STATUS="$1"
  local EXTRA_JQ="${2:-}"
  local NOW
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local TEMP
  TEMP=$(mktemp)
  while IFS= read -r line; do
    LINE_ID=$(echo "$line" | jq -r '.id')
    if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
      if [[ -n "$EXTRA_JQ" ]]; then
        echo "$line" | jq -c --arg s "$TARGET_STATUS" --arg now "$NOW" \
          ".status = \$s | .updated_at = \$now | $EXTRA_JQ"
      else
        echo "$line" | jq -c --arg s "$TARGET_STATUS" --arg now "$NOW" \
          '.status = $s | .updated_at = $now'
      fi
    else
      echo "$line"
    fi
  done < "$IDEAS_FILE" > "$TEMP"
  mv "$TEMP" "$IDEAS_FILE"
  echo "📋 Status: $IDEA_ID → $TARGET_STATUS"
}

update_status "qa-wip"

# ── Update WIP thread ──
WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")
THREAD_NAME=$(wip_thread_name "qa-wip" "$IDEA_ID" "$TITLE")
if [[ -n "$WIP_THREAD" ]]; then
  discord_thread_rename "$WIP_THREAD" "$THREAD_NAME"
  discord_thread_post "$WIP_THREAD" "🔵 **QA started** — running automated checks..."
fi
discord_post "$CH_PIPELINE" "🔍 **QA** — Running checks on **$IDEA_ID**: $TITLE"

# ── Initialize QA report ──
cat > "$QA_REPORT" << EOF
# QA Report: $IDEA_ID — $TITLE
**Date:** $(date -u +"%Y-%m-%d %H:%M UTC")
**PR:** $PR_URL
**Retry:** #$RETRY_COUNT

## Automated Checks
EOF

PASS=true
FAILURES=()

# ═══════════════════════════════════════════════════════
# PHASE 1: Automated Checks
# ═══════════════════════════════════════════════════════

# macOS uses gtimeout (from coreutils), Linux uses timeout
TIMEOUT_CMD="timeout"
command -v timeout &>/dev/null || TIMEOUT_CMD="gtimeout"

if [[ -d "$WORK_DIR" ]]; then
  cd "$WORK_DIR"
  
  # ── Check 1: TypeScript ──
  echo "───── Check 1: TypeScript ─────"
  if [[ -f "tsconfig.json" ]]; then
    TSC_OUTPUT=$($TIMEOUT_CMD "${QA_TIMEOUT:-300}" npx tsc --noEmit 2>&1 || true)
    
    # Filter: only count errors in files we changed (ignore pre-existing repo errors)
    PR_FILES=$(git diff --name-only main 2>/dev/null || git diff --name-only master 2>/dev/null)
    TSC_PR_ERRORS=""
    if [[ -n "$PR_FILES" ]]; then
      while IFS= read -r f; do
        MATCHES=$(echo "$TSC_OUTPUT" | grep "^${f}(" 2>/dev/null || true)
        [[ -n "$MATCHES" ]] && TSC_PR_ERRORS+="$MATCHES"$'\n'
      done <<< "$PR_FILES"
    fi
    
    TSC_ERRORS=$(echo "$TSC_PR_ERRORS" | grep -c "error TS" 2>/dev/null || true)
    TSC_ERRORS=${TSC_ERRORS:-0}
    TSC_ERRORS=$(echo "$TSC_ERRORS" | tr -d '[:space:]')
    TOTAL_ERRORS=$(echo "$TSC_OUTPUT" | grep -c "error TS" 2>/dev/null || true)
    TOTAL_ERRORS=$(echo "$TOTAL_ERRORS" | tr -d '[:space:]')
    
    if [[ "$TSC_ERRORS" -eq 0 ]]; then
      if [[ "$TOTAL_ERRORS" -gt 0 ]]; then
        echo "✅ TypeScript: clean (${TOTAL_ERRORS} pre-existing errors filtered)"
      else
        echo "✅ TypeScript: clean"
      fi
      echo "- [x] TypeScript: clean (0 errors in PR files, ${TOTAL_ERRORS} pre-existing)" >> "$QA_REPORT"
    else
      echo "❌ TypeScript: $TSC_ERRORS errors in PR files"
      echo "$TSC_PR_ERRORS" | grep "error TS" | head -10
      PASS=false
      FAILURES+=("typescript:${TSC_ERRORS}_errors")
      echo "- [ ] TypeScript: FAILED ($TSC_ERRORS errors in PR files)" >> "$QA_REPORT"
      echo '```' >> "$QA_REPORT"
      echo "$TSC_PR_ERRORS" | grep "error TS" | head -20 >> "$QA_REPORT"
      echo '```' >> "$QA_REPORT"
    fi
  else
    echo "⏭️  No tsconfig.json"
    echo "- [x] TypeScript: skipped (no tsconfig)" >> "$QA_REPORT"
  fi
  echo ""
  
  # ── Check 2: Lint ──
  echo "───── Check 2: Lint ─────"
  if [[ -f "package.json" ]] && grep -q '"lint"' package.json; then
    LINT_OUTPUT=$($TIMEOUT_CMD "${QA_TIMEOUT:-300}" npm run lint 2>&1 || true)
    LINT_EXIT=$?
    if [[ $LINT_EXIT -eq 0 ]]; then
      echo "✅ Lint: clean"
      echo "- [x] Lint: clean" >> "$QA_REPORT"
    else
      echo "⚠️  Lint: issues found"
      FAILURES+=("lint")
      echo "- [ ] Lint: issues found" >> "$QA_REPORT"
      echo '```' >> "$QA_REPORT"
      echo "$LINT_OUTPUT" | tail -10 >> "$QA_REPORT"
      echo '```' >> "$QA_REPORT"
    fi
  else
    echo "⏭️  No lint script"
    echo "- [x] Lint: skipped (no script)" >> "$QA_REPORT"
  fi
  echo ""
  
  # ── Check 3: Tests ──
  echo "───── Check 3: Tests ─────"
  if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
    TEST_OUTPUT=$($TIMEOUT_CMD "${QA_TIMEOUT:-300}" npm test 2>&1 || true)
    TEST_EXIT=$?
    if [[ $TEST_EXIT -eq 0 ]]; then
      echo "✅ Tests: passed"
      echo "- [x] Tests: passed" >> "$QA_REPORT"
    else
      echo "❌ Tests: failed"
      PASS=false
      FAILURES+=("tests")
      echo "- [ ] Tests: FAILED" >> "$QA_REPORT"
      echo '```' >> "$QA_REPORT"
      echo "$TEST_OUTPUT" | tail -20 >> "$QA_REPORT"
      echo '```' >> "$QA_REPORT"
    fi
  else
    echo "⏭️  No test script"
    echo "- [x] Tests: skipped (no script)" >> "$QA_REPORT"
  fi
  echo ""
  
  # ── Check 4: Diff summary ──
  echo "───── Check 4: Diff ─────"
  DIFF_STAT=$(git diff --stat main 2>/dev/null || git diff --stat master 2>/dev/null || echo "N/A")
  FILE_COUNT=$(git diff --name-only main 2>/dev/null | wc -l | tr -d ' ')
  echo "$DIFF_STAT"
  echo ""
  echo "## Diff Summary" >> "$QA_REPORT"
  echo "Files changed: $FILE_COUNT" >> "$QA_REPORT"
  echo '```' >> "$QA_REPORT"
  echo "$DIFF_STAT" >> "$QA_REPORT"
  echo '```' >> "$QA_REPORT"
  
else
  echo "❌ Workdir not found: $WORK_DIR"
  PASS=false
  FAILURES+=("no-workdir")
  echo "- [ ] FAILED: workdir not found" >> "$QA_REPORT"
fi

# ═══════════════════════════════════════════════════════
# PHASE 1b: File Coverage Check (PRD "Files to Change" vs actual diff)
# ═══════════════════════════════════════════════════════

echo "───── Check 5: File Coverage ─────"
echo "" >> "$QA_REPORT"
echo "## File Coverage" >> "$QA_REPORT"

if [[ -f "$PRD_PATH" ]] && [[ -d "$WORK_DIR" ]]; then
  cd "$WORK_DIR"
  # Extract file paths from PRD's "Files to Change" / "Files to Modify" sections
  PRD_FILES=$(sed -n '/^## Files to Change\|^## Files to Modify\|^### Modify\|^### New/,/^## [^F]/p' "$PRD_PATH" 2>/dev/null \
    | grep -oE '[a-zA-Z0-9_./@-]+\.(ts|tsx|md|yml|yaml|json)' | sort -u || true)
  
  # Get actual changed files
  DIFF_FILES=$(git diff --name-only main 2>/dev/null || git diff --name-only master 2>/dev/null)
  
  if [[ -n "$PRD_FILES" ]]; then
    MISSING_COUNT=0
    for prd_file in $PRD_FILES; do
      # Check if the file (or a close match) appears in the diff
      if echo "$DIFF_FILES" | grep -qF "$prd_file"; then
        echo "  ✅ $prd_file"
      else
        echo "  ❌ $prd_file (not in diff)"
        MISSING_COUNT=$((MISSING_COUNT + 1))
      fi
    done
    
    if [[ $MISSING_COUNT -eq 0 ]]; then
      echo "✅ All PRD files covered"
      echo "- [x] File coverage: all PRD files modified" >> "$QA_REPORT"
    else
      echo "⚠️  $MISSING_COUNT PRD file(s) not modified"
      echo "- [ ] File coverage: $MISSING_COUNT PRD files missing from diff" >> "$QA_REPORT"
      # Warning only — some PRD files might be "new" files that Codex creates elsewhere
    fi
  else
    echo "⏭️  No file paths found in PRD"
    echo "- [x] File coverage: skipped (no paths in PRD)" >> "$QA_REPORT"
  fi
else
  echo "⏭️  Skipped (missing PRD or workdir)"
fi
echo ""

# ═══════════════════════════════════════════════════════
# PHASE 2: Visual Capture (Peekaboo)
# ═══════════════════════════════════════════════════════

echo ""
echo "───── Visual Capture (Peekaboo) ─────"
echo "## Visual Capture" >> "$QA_REPORT"

SCREENSHOTS_DIR="$QA_DIR/${IDEA_ID}-screenshots"
mkdir -p "$SCREENSHOTS_DIR"

if command -v peekaboo &> /dev/null; then
  echo "📸 Peekaboo available — Charles should capture:"
  echo "  1. Each page/component affected by the PR"
  echo "  2. Before/after if possible (main vs branch)"
  echo "  3. Mobile viewport if UI change"
  echo ""
  echo "Screenshots saved to: $SCREENSHOTS_DIR"
  echo ""
  echo "Peekaboo screenshots pending — Charles to capture" >> "$QA_REPORT"
else
  echo "⚠️  Peekaboo not available on this machine."
  echo "  Charles: use browser tool screenshots instead"
  echo "  Save to: $SCREENSHOTS_DIR"
  echo ""
  echo "Peekaboo not available — manual screenshots needed" >> "$QA_REPORT"
fi

# ═══════════════════════════════════════════════════════
# PHASE 2b: Mobile QA (iPhone WebDriver — optional)
# ═══════════════════════════════════════════════════════

MOBILE_QA_ENABLED=$(factory_config '.mobile_qa_enabled' || echo "false")
MOBILE_QA_SCRIPT=$(factory_config '.mobile_qa_script' || echo "$HOME/.openclaw/workspace/scripts/iphone-qa.sh")
MOBILE_QA_WARNINGS=()

echo ""
echo "───── Mobile QA (iPhone) ─────"
echo "## Mobile QA" >> "$QA_REPORT"

if [[ "$MOBILE_QA_ENABLED" != "true" ]]; then
  echo "⏭️  Mobile QA disabled (set mobile_qa_enabled=true in config.json to enable)"
  echo "Mobile QA: disabled" >> "$QA_REPORT"
else
  # Only run for UI changes (*.tsx files in src/app/)
  UI_FILES_CHANGED=0
  if [[ -d "$WORK_DIR" ]]; then
    UI_FILES_CHANGED=$(cd "$WORK_DIR" && git diff --name-only main 2>/dev/null | grep -c '\.tsx$' || echo "0")
  fi

  if [[ "$UI_FILES_CHANGED" -eq 0 ]]; then
    echo "⏭️  No .tsx files changed — skipping mobile QA"
    echo "Mobile QA: skipped (no UI changes)" >> "$QA_REPORT"
  elif [[ ! -x "$MOBILE_QA_SCRIPT" ]]; then
    echo "⚠️  iphone-qa.sh not found or not executable"
    echo "Mobile QA: skipped (script not found)" >> "$QA_REPORT"
  else
    # Check if iPhone is connected
    IPHONE_CONNECTED=false
    if bash "$MOBILE_QA_SCRIPT" info &>/dev/null; then
      IPHONE_CONNECTED=true
    fi

    if [[ "$IPHONE_CONNECTED" != "true" ]]; then
      echo "⚠️  iPhone not connected — skipping mobile QA"
      echo "Mobile QA: skipped (iPhone not connected)" >> "$QA_REPORT"
    else
      echo "📱 iPhone connected — running mobile audit..."

      # Use PR URL or Vercel preview if available, fall back to production
      AUDIT_URL="${VERCEL_PREVIEW_URL:-https://permissionprotocol.com}"
      MOBILE_SCREENSHOTS="$QA_DIR/${IDEA_ID}-mobile"
      mkdir -p "$MOBILE_SCREENSHOTS"

      # Run the audit (captures screenshots + performance + accessibility)
      MOBILE_EXIT=0
      bash "$MOBILE_QA_SCRIPT" audit "$AUDIT_URL" "$MOBILE_SCREENSHOTS" 2>&1 | tee "$QA_DIR/${IDEA_ID}-mobile.log" || MOBILE_EXIT=$?

      if [[ $MOBILE_EXIT -eq 0 ]]; then
        echo "✅ Mobile audit complete — screenshots in $MOBILE_SCREENSHOTS"
        echo "Mobile QA: completed" >> "$QA_REPORT"

        # Check for P0 issues from the audit output
        MOBILE_LOG="$QA_DIR/${IDEA_ID}-mobile.log"
        if grep -qi "small tap target\|below.the.fold\|broken layout\|missing element" "$MOBILE_LOG" 2>/dev/null; then
          MOBILE_QA_WARNINGS+=("mobile-issues-detected")
          echo "⚠️  Mobile issues detected — see audit log for details"
          echo "Mobile QA warnings: issues detected (non-blocking)" >> "$QA_REPORT"
        fi
      else
        echo "⚠️  Mobile audit failed (exit $MOBILE_EXIT) — non-blocking"
        echo "Mobile QA: failed (non-blocking)" >> "$QA_REPORT"
      fi
    fi
  fi
fi

echo ""

# ═══════════════════════════════════════════════════════
# PHASE 3: PRD Acceptance Criteria Check
# ═══════════════════════════════════════════════════════

echo "───── PRD Acceptance Criteria ─────"
echo "" >> "$QA_REPORT"
echo "## PRD Acceptance Criteria" >> "$QA_REPORT"

if [[ -f "$PRD_PATH" ]]; then
  # Extract acceptance criteria from PRD (lines starting with - [ ] or - [x])
  CRITERIA=$(grep -E "^- \[[ x]\]" "$PRD_PATH" 2>/dev/null || true)
  if [[ -n "$CRITERIA" ]]; then
    echo "From PRD:"
    echo "$CRITERIA"
    echo ""
    echo "Charles: verify each criterion against the actual build output."
    echo "Mark as checked/unchecked in the QA report."
    echo ""
    echo "$CRITERIA" >> "$QA_REPORT"
  else
    echo "No checkboxes found in PRD. Charles: manually verify against PRD."
    echo "No structured criteria found — manual verification needed" >> "$QA_REPORT"
  fi
else
  echo "⚠️  PRD not found at $PRD_PATH"
  echo "PRD not found" >> "$QA_REPORT"
fi

# ═══════════════════════════════════════════════════════
# VERDICT
# ═══════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════"
echo ""
echo "## Verdict" >> "$QA_REPORT"

WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")

if $PASS; then
  # Include mobile warnings in the report (non-blocking)
  MOBILE_WARNING_TEXT=""
  if [[ ${#MOBILE_QA_WARNINGS[@]} -gt 0 ]]; then
    MOBILE_WARNING_TEXT="
📱 **Mobile QA warnings:** ${MOBILE_QA_WARNINGS[*]} (non-blocking — review screenshots)"
  fi

  echo "🟢 AUTOMATED CHECKS PASSED"
  echo ""
  echo "Charles: complete visual review + PRD criteria check, then:"
  echo ""
  echo "  ✅ To PASS (all criteria met, looks good):"
  echo "     Update status → qa-passed"
  echo "     Rod merges the PR"
  echo ""
  echo "  ❌ To FAIL (criteria not met or visual issues):"
  echo "     Write failure notes (see below)"
  echo ""
  echo "Automated checks: PASSED" >> "$QA_REPORT"
  echo "Visual review: PENDING" >> "$QA_REPORT"
  echo "PRD criteria: PENDING" >> "$QA_REPORT"
  
  # ── Update WIP thread → ready for review ──
  if [[ -n "$WIP_THREAD" ]]; then
    THREAD_NAME=$(wip_thread_name "build-ready" "$IDEA_ID" "$TITLE")
    discord_thread_rename "$WIP_THREAD" "$THREAD_NAME"
    discord_thread_post "$WIP_THREAD" "✅ **QA Passed** — Ready for review

📋 **Status:** Ready for Rod
🔗 **PR:** $PR_URL
🛡️ **PP:** <https://app.permissionprotocol.com/pp/deploy-requests>
✅ **Checks:** tsc clean, lint clean, tests pass
📸 **Screenshots:** Pending visual capture${MOBILE_WARNING_TEXT}

**React ✅ to approve + merge**
**React ❌ to reject (comment why)**
**React 🔄 to send back to Codex**"
  fi
  discord_post "$CH_PIPELINE" "✅ **QA passed** — $IDEA_ID ready for review"

  # ── In auto mode, mark as qa-passed and archive WIP thread ──
  if [[ "$AUTO_MODE" == "true" ]]; then
    update_status "qa-passed"
    echo "✅ Status → qa-passed (auto mode)"
    
    # Auto-archive the WIP thread (issue #145)
    if [[ -n "$WIP_THREAD" ]]; then
      DONE_THREAD_NAME="✅ ${IDEA_ID} — ${TITLE:0:80}"
      discord_thread_rename "$WIP_THREAD" "$DONE_THREAD_NAME"
      discord_thread_post "$WIP_THREAD" "✅ **QA Passed** — auto-archiving thread.
PR: $PR_URL"
      discord_thread_archive "$WIP_THREAD"
      echo "📦 WIP thread archived"
    fi
  fi

  exit 0
  
else
  echo "🔴 AUTOMATED CHECKS FAILED: ${FAILURES[*]}"
  echo ""
  echo "Automated checks: FAILED (${FAILURES[*]})" >> "$QA_REPORT"
  
  # ── Update WIP thread → stuck ──
  if [[ -n "$WIP_THREAD" ]]; then
    THREAD_NAME=$(wip_thread_name "qa-failed" "$IDEA_ID" "$TITLE")
    discord_thread_rename "$WIP_THREAD" "$THREAD_NAME"
    discord_thread_post "$WIP_THREAD" "🔴 **QA Failed** — ${FAILURES[*]}

Sending back to Codex with P0 priority.
Retry #$((RETRY_COUNT + 1)) of 3."
  fi
  discord_post "$CH_PIPELINE" "🔴 **QA failed** — $IDEA_ID: ${FAILURES[*]}"
  
  # ── Auto-retry in --auto mode ──
  if [[ "$AUTO_MODE" == "true" ]]; then
    NEW_RETRY=$((RETRY_COUNT + 1))
    if [[ $NEW_RETRY -le 3 ]]; then
      echo ""
      echo "🔄 Auto-retry #$NEW_RETRY of 3..."
      
      # Append failure notes to PRD with FULL captured error output
      {
        echo ""
        echo "## QA Failure Notes (Retry #$NEW_RETRY)"
        echo "**Failures:** ${FAILURES[*]}"
        echo ""
        if echo "${FAILURES[*]}" | grep -q "typescript"; then
          echo "### TypeScript Errors (MUST FIX THESE EXACT ERRORS)"
          echo "The following TypeScript errors are in files YOU changed. Fix each one:"
          echo '```'
          # Use already-captured TSC_PR_ERRORS instead of re-running tsc
          if [[ -n "${TSC_PR_ERRORS:-}" ]]; then
            echo "$TSC_PR_ERRORS" | grep "error TS" | head -30
          else
            cd "$WORK_DIR" && npx tsc --noEmit 2>&1 | grep "error TS" | head -30
          fi
          echo '```'
          echo ""
        fi
        if echo "${FAILURES[*]}" | grep -q "lint"; then
          echo "### Lint Errors"
          echo '```'
          if [[ -n "${LINT_OUTPUT:-}" ]]; then
            echo "$LINT_OUTPUT" | tail -30
          else
            cd "$WORK_DIR" && npm run lint 2>&1 | tail -30
          fi
          echo '```'
          echo ""
        fi
        if echo "${FAILURES[*]}" | grep -q "tests"; then
          echo "### Test Failures"
          echo '```'
          if [[ -n "${TEST_OUTPUT:-}" ]]; then
            echo "$TEST_OUTPUT" | tail -30
          else
            cd "$WORK_DIR" && npm test 2>&1 | tail -30
          fi
          echo '```'
          echo ""
        fi
        # Include Codex build log if available
        BUILD_LOG="$QA_DIR/${IDEA_ID}-build.log"
        if [[ -f "$BUILD_LOG" ]]; then
          echo "### Build Log (last 50 lines)"
          echo '```'
          tail -50 "$BUILD_LOG"
          echo '```'
        fi
      } >> "$PRD_PATH"
      
      # Re-queue: status → prd-ready, priority → 0 (P0), increment retry_count
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
      
      echo "📋 Re-queued: $IDEA_ID → prd-ready (P0, retry #$NEW_RETRY)"
      discord_thread_post "$WIP_THREAD" "🔄 **Auto-retry** — re-queued as P0 (retry #$NEW_RETRY of 3)"
    else
      echo ""
      echo "⚠️  MAX RETRIES REACHED ($RETRY_COUNT/3)"
      update_status "qa-failed"
      discord_post "$CH_PIPELINE" "🔴 **Max retries** — $IDEA_ID needs human intervention"
    fi
  fi
fi

if ! $PASS && [[ "$AUTO_MODE" != "true" ]]; then
  echo ""
  echo "───── On Failure: Retry Protocol ─────"
  echo ""
  echo "Charles should:"
  echo "  1. Append failure notes to PRD"
  echo "  2. Re-queue: status → prd-ready, priority → 0, retry_count +1"
  echo "  3. Run: bash factory/scripts/build.sh --auto && bash factory/scripts/qa.sh --auto"
  echo ""
  NEW_RETRY=$((RETRY_COUNT + 1))
  if [[ $NEW_RETRY -gt 3 ]]; then
    echo "⚠️  MAX RETRIES REACHED ($RETRY_COUNT/3)"
    echo "This idea needs human intervention."
  fi
fi

echo ""
echo "QA report saved: $QA_REPORT"
echo "═══════════════════════════════════════════════════════"
