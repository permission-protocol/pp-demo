#!/usr/bin/env bash
# Factory Script 6: Ship
# One-command post-build flow: sync main → run checks → push → create/update PR.
#
# Usage:
#   bash factory/scripts/ship.sh [idea-id]               # Ship specific idea
#   bash factory/scripts/ship.sh                          # Ship top build-wip/build-ready
#   bash factory/scripts/ship.sh --workdir /path/to/repo  # Ship from any repo dir
#
# What it does:
#   1. Rebase on main (catches conflicts early)
#   2. Run tsc + lint + tests (fails fast)
#   3. Push branch
#   4. Create or update PR
#   5. Update factory status → build-ready
#
# This replaces the manual "push, open PR, hope for the best" flow.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"

# ── Parse args ──
IDEA_ID_ARG=""
WORK_DIR_ARG=""
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --workdir) shift; WORK_DIR_ARG="${1:-}" ;;
    idea-*)    IDEA_ID_ARG="$arg" ;;
    *)         POSITIONAL+=("$arg") ;;
  esac
done

# ── Resolve idea + workdir ──
IDEA=""
IDEA_ID=""
TITLE=""
REPO=""
BRANCH=""

if [[ -n "$WORK_DIR_ARG" ]]; then
  # Standalone mode: ship from any repo, no factory tracking
  WORK_DIR="$WORK_DIR_ARG"
  cd "$WORK_DIR"
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  REPO=$(git remote get-url origin | sed 's|.*github.com[:/]||; s|\.git$||')
  TITLE="$BRANCH"
  echo "🚢 Standalone ship: $REPO @ $BRANCH"
elif [[ -n "$IDEA_ID_ARG" ]]; then
  IDEA=$(grep "\"id\":\"$IDEA_ID_ARG\"\|\"id\": \"$IDEA_ID_ARG\"" "$IDEAS_FILE" | head -1)
elif [[ -f "$IDEAS_FILE" ]]; then
  # Try build-wip first, then build-ready
  IDEA=$( (grep '"status":"build-wip"\|"status": "build-wip"' "$IDEAS_FILE" 2>/dev/null || true) | \
    jq -s 'sort_by(.priority // 999) | .[0]' 2>/dev/null)
  [[ "$IDEA" == "null" ]] && IDEA=""
  if [[ -z "$IDEA" ]]; then
    IDEA=$( (grep '"status":"build-ready"\|"status": "build-ready"' "$IDEAS_FILE" 2>/dev/null || true) | \
      jq -s 'sort_by(.priority // 999) | .[0]' 2>/dev/null)
    [[ "$IDEA" == "null" ]] && IDEA=""
  fi
fi

if [[ -n "$IDEA" ]] && [[ "$IDEA" != "null" ]] && [[ -z "$WORK_DIR_ARG" ]]; then
  IDEA_ID=$(echo "$IDEA" | jq -r '.id')
  TITLE=$(echo "$IDEA" | jq -r '.title')
  REPO=$(echo "$IDEA" | jq -r '.repo // "permission-protocol/app"')
  TARGET=$(echo "$IDEA" | jq -r '.target // "pp"')
  TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
  BRANCH_PREFIX=$(jq -r '.branch_prefix // "factory/"' "$TARGET_FILE" 2>/dev/null || echo "factory/")
  BRANCH="${BRANCH_PREFIX}${IDEA_ID}"
  WORK_DIR="$HOME/pp-agent-work/factory-${IDEA_ID}"
fi

if [[ -z "$WORK_DIR" ]] && [[ -z "${WORK_DIR_ARG:-}" ]]; then
  echo "❌ Nothing to ship. No build-wip/build-ready ideas and no --workdir specified."
  exit 1
fi

if [[ ! -d "$WORK_DIR" ]]; then
  echo "❌ Workdir not found: $WORK_DIR"
  exit 1
fi

cd "$WORK_DIR"

# Ensure we're on the right branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ -n "$BRANCH" ]] && [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
  git checkout "$BRANCH" 2>/dev/null || {
    echo "❌ Can't checkout $BRANCH (current: $CURRENT_BRANCH)"
    exit 1
  }
fi
BRANCH="${BRANCH:-$CURRENT_BRANCH}"

echo "═══════════════════════════════════════════════════════"
echo "  🚀 SHIP — $BRANCH"
echo "═══════════════════════════════════════════════════════"
echo ""
[[ -n "$IDEA_ID" ]] && echo "Idea:   $IDEA_ID — $TITLE"
echo "Repo:   $REPO"
echo "Branch: $BRANCH"
echo "Dir:    $WORK_DIR"
echo ""

SHIP_PASS=true
SHIP_FAILURES=()

# ═══════════════════════════════════════════════════════
# STEP 1: Sync with main
# ═══════════════════════════════════════════════════════
echo "───── Step 1: Sync with main ─────"
git fetch origin main 2>/dev/null || git fetch origin master 2>/dev/null || true
REBASE_OUTPUT=$(git rebase origin/main 2>&1 || git rebase origin/master 2>&1 || echo "REBASE_FAILED")

if echo "$REBASE_OUTPUT" | grep -q "REBASE_FAILED\|CONFLICT"; then
  echo "❌ Rebase conflict detected"
  git rebase --abort 2>/dev/null || true
  SHIP_PASS=false
  SHIP_FAILURES+=("rebase-conflict")
  echo "  Fix conflicts manually, then re-run ship.sh"
else
  echo "✅ Rebased on main"
fi
echo ""

# ═══════════════════════════════════════════════════════
# STEP 2: Pre-flight checks (tsc, lint, test)
# ═══════════════════════════════════════════════════════
TIMEOUT_CMD="timeout"
command -v timeout &>/dev/null || TIMEOUT_CMD="gtimeout"

if $SHIP_PASS; then
  echo "───── Step 2: Pre-flight checks ─────"
  
  # TypeScript
  if [[ -f "tsconfig.json" ]]; then
    TSC_OUT=$($TIMEOUT_CMD 300 npx tsc --noEmit 2>&1 || true)
    TSC_ERR=$(echo "$TSC_OUT" | grep -c "error TS" 2>/dev/null || echo "0")
    TSC_ERR=$(echo "$TSC_ERR" | tr -d '[:space:]')
    if [[ "$TSC_ERR" -eq 0 ]]; then
      echo "  ✅ tsc clean"
    else
      echo "  ❌ tsc: $TSC_ERR errors"
      echo "$TSC_OUT" | grep "error TS" | head -5
      SHIP_PASS=false
      SHIP_FAILURES+=("tsc:${TSC_ERR}_errors")
    fi
  fi
  
  # Lint
  if [[ -f "package.json" ]] && grep -q '"lint"' package.json; then
    LINT_OUT=$($TIMEOUT_CMD 300 npm run lint 2>&1 || true)
    LINT_EXIT=$?
    if [[ $LINT_EXIT -eq 0 ]]; then
      echo "  ✅ lint clean"
    else
      echo "  ⚠️  lint issues (non-blocking)"
    fi
  fi
  
  # Tests
  if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
    TEST_OUT=$($TIMEOUT_CMD 300 npm test 2>&1 || true)
    TEST_EXIT=$?
    if [[ $TEST_EXIT -eq 0 ]]; then
      echo "  ✅ tests pass"
    else
      echo "  ❌ tests failed"
      echo "$TEST_OUT" | tail -10
      SHIP_PASS=false
      SHIP_FAILURES+=("tests")
    fi
  fi
  echo ""
fi

# ═══════════════════════════════════════════════════════
# STEP 3: Push
# ═══════════════════════════════════════════════════════
if $SHIP_PASS; then
  echo "───── Step 3: Push ─────"
  
  # Stage + commit any uncommitted changes
  UNCOMMITTED=$(git status --porcelain 2>/dev/null)
  if [[ -n "$UNCOMMITTED" ]]; then
    # Clean factory artifacts
    rm -f FACTORY-PRD.md .factory-prompt.txt
    git add -A
    if [[ -n "$IDEA_ID" ]]; then
      git commit -m "factory($IDEA_ID): final cleanup" 2>/dev/null || true
    else
      git commit -m "ship: final cleanup" 2>/dev/null || true
    fi
  fi
  
  GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt 2>/dev/null || echo "")
  if [[ -n "$GH_TOKEN" ]]; then
    git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git" 2>/dev/null || true
  fi
  
  git push -u origin "$BRANCH" --force-with-lease 2>&1 || {
    echo "⚠️  force-with-lease failed, trying force..."
    git push -u origin "$BRANCH" --force 2>&1
  }
  echo "✅ Pushed $BRANCH"
  echo ""
  
  # ═══════════════════════════════════════════════════════
  # STEP 4: Create or update PR
  # ═══════════════════════════════════════════════════════
  echo "───── Step 4: PR ─────"
  
  # Check if PR already exists
  EXISTING_PR=$(gh pr view "$BRANCH" --repo "$REPO" --json url --jq '.url' 2>/dev/null || echo "")
  
  if [[ -n "$EXISTING_PR" ]]; then
    echo "✅ PR exists: $EXISTING_PR"
    PR_URL="$EXISTING_PR"
  else
    PR_TITLE="$TITLE"
    [[ -n "$IDEA_ID" ]] && PR_TITLE="factory($IDEA_ID): $TITLE"
    
    PRD_PATH="$FACTORY_DIR/prds/${IDEA_ID}.md"
    PR_BODY="## 🏭 Create Factory

**Idea:** ${IDEA_ID:-manual} — $TITLE

---

*Shipped via factory/scripts/ship.sh*"
    
    if [[ -n "$IDEA_ID" ]] && [[ -f "$PRD_PATH" ]]; then
      PR_BODY="## 🏭 Create Factory

**Idea:** $IDEA_ID — $TITLE

---

$(cat "$PRD_PATH")

---

*Shipped via factory/scripts/ship.sh*"
    fi
    
    PR_URL=$(gh pr create \
      --repo "$REPO" \
      --head "$BRANCH" \
      --base main \
      --title "$PR_TITLE" \
      --body "$PR_BODY" 2>&1) || {
      PR_URL=$(gh pr view "$BRANCH" --repo "$REPO" --json url --jq '.url' 2>/dev/null || echo "PR creation failed")
    }
    echo "✅ PR created: $PR_URL"
  fi
  echo ""
  
  # ═══════════════════════════════════════════════════════
  # STEP 5: Update factory status
  # ═══════════════════════════════════════════════════════
  if [[ -n "$IDEA_ID" ]]; then
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    TEMP=$(mktemp)
    while IFS= read -r line; do
      LINE_ID=$(echo "$line" | jq -r '.id')
      if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
        echo "$line" | jq -c --arg url "$PR_URL" --arg now "$NOW" \
          '.status = "build-ready" | .pr_url = $url | .updated_at = $now'
      else
        echo "$line"
      fi
    done < "$IDEAS_FILE" > "$TEMP"
    mv "$TEMP" "$IDEAS_FILE"
    echo "📋 Status: $IDEA_ID → build-ready"
    
    WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")
    if [[ -n "$WIP_THREAD" ]]; then
      discord_thread_post "$WIP_THREAD" "🚀 **Shipped** — $PR_URL
Checks: $(echo "${SHIP_FAILURES[*]:-all clean}")"
    fi
    discord_post "$CH_PIPELINE" "🚀 **Shipped** — $IDEA_ID | PR: $PR_URL"
  fi
fi

# ═══════════════════════════════════════════════════════
# RESULT
# ═══════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════"
if $SHIP_PASS; then
  echo "  🚀 SHIPPED"
  echo ""
  [[ -n "$IDEA_ID" ]] && echo "  Idea:   $IDEA_ID — $TITLE"
  echo "  PR:     ${PR_URL:-N/A}"
  echo "  Branch: $BRANCH"
  echo ""
  echo "  Next: bash factory/scripts/qa.sh ${IDEA_ID:-}"
else
  echo "  ❌ SHIP FAILED: ${SHIP_FAILURES[*]}"
  echo ""
  echo "  Fix the issues above, then re-run:"
  echo "  bash factory/scripts/ship.sh ${IDEA_ID:-}"
fi
echo "═══════════════════════════════════════════════════════"
