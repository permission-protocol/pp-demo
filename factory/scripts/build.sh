#!/usr/bin/env bash
# Factory Script 4: Build
# Fully automated: finds prd-ready items, spawns Codex, pushes branch, creates PR.
#
# Usage: bash factory/scripts/build.sh [idea-id]
# If no ID given, picks the highest-priority prd-ready item.
#
# Flow:
#   1. Find top prd-ready idea
#   2. Clone/reuse repo workdir
#   3. Create branch factory/{idea-id}
#   4. Run Codex --full-auto against the PRD
#   5. Push branch + create PR
#   6. Update status → build-ready

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
PRDS_DIR="$FACTORY_DIR/prds"

# ── Parse flags ──
AUTO_MODE=false
POST_CODEX=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --auto)       AUTO_MODE=true ;;
    --post-codex) POST_CODEX=true ;;
    *)            POSITIONAL+=("$arg") ;;
  esac
done
set -- "${POSITIONAL[@]+"${POSITIONAL[@]}"}"

if [[ ! -f "$IDEAS_FILE" ]]; then
  echo "❌ No ideas file found"
  exit 1
fi

# ── Find target idea ──
# Priority: explicit ID > resume build-wip (fresh < 2h) > prd-ready > nothing
IDEA_ID="${1:-}"
IDEA=""

if [[ -n "$IDEA_ID" ]]; then
  IDEA=$(grep "\"id\":\"$IDEA_ID\"\|\"id\": \"$IDEA_ID\"" "$IDEAS_FILE" | head -1)
else
  # First: check for fresh build-wip items to resume (updated < 2 hours ago)
  TWO_HOURS_AGO=$(date -u -v-2H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "2 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
  BUILD_WIP=$( (grep '"status":"build-wip"\|"status": "build-wip"' "$IDEAS_FILE" 2>/dev/null || true) | \
    jq -s --arg cutoff "$TWO_HOURS_AGO" '[.[] | select(.updated_at >= $cutoff)] | sort_by(.priority // 999) | .[0]' 2>/dev/null)
  
  if [[ -n "$BUILD_WIP" ]] && [[ "$BUILD_WIP" != "null" ]]; then
    IDEA="$BUILD_WIP"
    echo "♻️  Resuming build-wip item (updated recently)"
  else
    # Check for stale build-wip (> 2h) — alert, don't auto-resume
    STALE_WIP=$(grep '"status":"build-wip"\|"status": "build-wip"' "$IDEAS_FILE" 2>/dev/null | head -1 || true)
    if [[ -n "$STALE_WIP" ]]; then
      STALE_ID=$(echo "$STALE_WIP" | jq -r '.id')
      echo "⚠️  Stale build-wip detected: $STALE_ID (> 2h old). Skipping — needs human review."
      discord_post "$CH_PIPELINE" "⚠️ **Stale build-wip:** $STALE_ID has been in build-wip for >2 hours. May be stuck. Skipping to prd-ready queue."
    fi
    
    # Then: pick highest-priority prd-ready OR ready (sensor-sourced bugs skip PRD)
    IDEA=$( (grep '"status":"prd-ready"\|"status": "prd-ready"\|"status":"ready"\|"status": "ready"' "$IDEAS_FILE" || true) | \
      jq -s 'sort_by(
        (if .priority == "p0" then 0 elif .priority == "p1" then 1 elif .priority == "p2" then 2 else 3 end),
        (if .source == "error-sensor" or .source == "github-sensor" then 0 else 1 end)
      ) | .[0]' 2>/dev/null)
    [[ "$IDEA" == "null" ]] && IDEA=""
  fi
fi

if [[ -z "$IDEA" ]] || [[ "$IDEA" == "null" ]]; then
  echo "ℹ️  No build-wip or prd-ready ideas found. Queue empty."
  exit 0
fi

IDEA_ID=$(echo "$IDEA" | jq -r '.id')
TITLE=$(echo "$IDEA" | jq -r '.title')
TARGET=$(echo "$IDEA" | jq -r '.target // "pp"')
REPO=$(echo "$IDEA" | jq -r '.repo // "permission-protocol/app"')

# Guard: reject null/empty target or repo
if [[ -z "$TARGET" || "$TARGET" == "null" ]]; then
  echo "⚠️  idea $IDEA_ID missing target — defaulting to 'pp'"
  TARGET="pp"
fi
if [[ -z "$REPO" || "$REPO" == "null" ]]; then
  echo "⚠️  idea $IDEA_ID missing repo — defaulting to 'permission-protocol/app'"
  REPO="permission-protocol/app"
fi

TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
BRANCH_PREFIX=$(jq -r '.branch_prefix // "factory/"' "$TARGET_FILE")

PRD_PATH="$PRDS_DIR/${IDEA_ID}.md"
if [[ ! -f "$PRD_PATH" ]]; then
  echo "❌ PRD not found: $PRD_PATH"
  exit 1
fi

WORK_DIR="$HOME/pp-agent-work/factory-${IDEA_ID}"
BRANCH="${BRANCH_PREFIX}${IDEA_ID}"

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Build (Automated)"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:     $IDEA_ID — $TITLE"
echo "Repo:     $REPO"
echo "Branch:   $BRANCH"
echo "PRD:      $PRD_PATH"
echo "Workdir:  $WORK_DIR"
echo ""

# ── Update status → build-wip ──
update_status() {
  local TARGET_STATUS="$1"
  local NOW
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local TEMP
  TEMP=$(mktemp)
  while IFS= read -r line; do
    LINE_ID=$(echo "$line" | jq -r '.id')
    if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
      echo "$line" | jq -c --arg s "$TARGET_STATUS" --arg now "$NOW" \
        '.status = $s | .updated_at = $now'
    else
      echo "$line"
    fi
  done < "$IDEAS_FILE" > "$TEMP"
  mv "$TEMP" "$IDEAS_FILE"
  echo "📋 Status: $IDEA_ID → $TARGET_STATUS"
}

update_status "build-wip"

# ── Create or update WIP thread ──
WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")
THREAD_NAME=$(wip_thread_name "build-wip" "$IDEA_ID" "$TITLE")
if [[ -z "$WIP_THREAD" ]]; then
  WIP_THREAD=$(discord_thread_create "$CH_WIP" "$THREAD_NAME" \
    "🟡 **Build started**: $IDEA_ID — $TITLE
**Repo:** $REPO
**Branch:** \`$BRANCH\`
**PRD:** \`factory/prds/${IDEA_ID}.md\`

Codex is working...")
  save_thread_id "$IDEA_ID" "wip" "$WIP_THREAD"
else
  discord_thread_rename "$WIP_THREAD" "$THREAD_NAME"
  discord_thread_post "$WIP_THREAD" "🟡 **Build restarted** (retry)"
fi

# Post to pipeline log
discord_post "$CH_PIPELINE" "🔨 **Build** — Starting Codex on **$IDEA_ID**: $TITLE
Repo: \`$REPO\` | Branch: \`$BRANCH\`"

# ── Clone or reuse repo ──
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt)
export GH_TOKEN

if [[ -d "$WORK_DIR" ]]; then
  echo "♻️  Reusing workdir: $WORK_DIR"
  cd "$WORK_DIR"
  git checkout main 2>/dev/null || git checkout master 2>/dev/null || true
  git pull --ff-only 2>/dev/null || true
else
  echo "📥 Cloning $REPO → $WORK_DIR"
  gh repo clone "$REPO" "$WORK_DIR" -- --depth=50
  cd "$WORK_DIR"
fi

# Configure git
git config user.name "Charles Goldberg"
git config user.email "cgoldber82@gmail.com"
git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git"

# Create or checkout branch
git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH" 2>/dev/null || {
  git checkout main 2>/dev/null || git checkout master
  git checkout -b "$BRANCH"
}
echo "🌿 Branch: $BRANCH"

# Install dependencies (needed for tsc/lint/tests in QA)
if [[ -f "package-lock.json" ]] && [[ ! -d "node_modules" ]]; then
  echo "📦 Installing dependencies..."
  npm ci --silent 2>&1 | tail -3
fi
echo ""

# ── Prepare PRD for Codex ──
cp "$PRD_PATH" "$WORK_DIR/FACTORY-PRD.md"

# Detect idea type (bug vs feature)
IDEA_TYPE=$(echo "$IDEA" | jq -r '.type // "feature"')

# Extract Codex prompt from PRD (section varies by type)
CODEX_PROMPT=""
if [[ "$IDEA_TYPE" == "bug" ]]; then
  # For bugs: extract Fix Approach + Acceptance Criteria
  CODEX_PROMPT=$(sed -n '/^## Fix Approach/,/^## Test Plan/{ p; }' "$PRD_PATH" | sed '/^$/d')
  if [[ -n "$CODEX_PROMPT" ]]; then
    CODEX_PROMPT="You are fixing a bug. Read FACTORY-PRD.md for full context.

$CODEX_PROMPT

Fix this bug with the minimal change needed. Add a test if possible. Run \`npx tsc --noEmit\` before finishing."
  fi
fi

# Fall back to standard Codex Prompt section (features) or generic prompt
if [[ -z "$CODEX_PROMPT" ]]; then
  CODEX_PROMPT=$(sed -n '/^## Codex Prompt/,/^## /{ /^## Codex Prompt/d; /^## /d; p; }' "$PRD_PATH" | sed '/^$/d')
fi
if [[ -z "$CODEX_PROMPT" ]]; then
  CODEX_PROMPT="Read FACTORY-PRD.md and implement all changes described. Follow the acceptance criteria exactly. Commit your changes when done."
fi

# ── Inject retry context if this is a retry ──
RETRY_COUNT=$(echo "$IDEA" | jq -r '.retry_count // 0')
if [[ "$RETRY_COUNT" -gt 0 ]]; then
  # Extract QA failure notes from PRD
  FAILURE_NOTES=$(sed -n '/^## QA Failure Notes/,/^## /{ /^## QA Failure Notes/d; /^## [^Q]/d; p; }' "$PRD_PATH" | sed '/^$/d')
  if [[ -n "$FAILURE_NOTES" ]]; then
    CODEX_PROMPT="IMPORTANT: This is retry #$RETRY_COUNT. The previous build failed QA. Fix these issues FIRST before implementing the rest:

$FAILURE_NOTES

---

$CODEX_PROMPT"
    echo "⚠️  Retry #$RETRY_COUNT — failure context injected into prompt"
    echo ""
  fi
fi

# ── Post-Codex mode: skip Codex, go straight to push+PR ──
if [[ "$POST_CODEX" == "true" ]]; then
  echo "⏩ Post-Codex mode: skipping Codex, going to push+PR..."
  cd "$WORK_DIR"
  # Jump past the Codex section
else

echo "───── Running Codex ─────"

# Save prompt to file (Codex reads it; avoids shell escaping issues)
PROMPT_FILE="$WORK_DIR/.factory-prompt.txt"
echo "$CODEX_PROMPT" > "$PROMPT_FILE"
echo "Prompt saved to: $PROMPT_FILE"
echo "Prompt preview: ${CODEX_PROMPT:0:200}..."
echo ""

# ── Auto mode: run Codex directly ──
# ── Interactive mode: print command for Charles to run via exec tool with pty:true ──
if [[ "${AUTO_MODE:-false}" == "true" ]]; then
  # Verify Codex auth
  if ! codex login status &>/dev/null; then
    echo "❌ Codex not authenticated. Run: codex login"
    discord_thread_post "$(get_thread_id "$IDEA_ID" "wip")" "❌ **Codex auth expired** — run \`codex login\`"
    discord_post "$CH_PIPELINE" "🔴 **Build blocked** — $IDEA_ID: Codex auth expired"
    exit 1
  fi

  echo "🤖 Auto mode: running Codex (30min timeout)..."
  CODEX_LOG="$FACTORY_DIR/logs/codex-${IDEA_ID}.log"
  mkdir -p "$FACTORY_DIR/logs"
  CODEX_EXIT=0
  TIMEOUT_CMD="timeout"
  command -v timeout &>/dev/null || TIMEOUT_CMD="gtimeout"
  $TIMEOUT_CMD 1800 codex exec --full-auto "$(cat "$PROMPT_FILE")" 2>&1 | tee "$CODEX_LOG" || CODEX_EXIT=$?

  if [[ $CODEX_EXIT -ne 0 ]]; then
    echo ""
    echo "⚠️  Codex exited with code $CODEX_EXIT"
    echo "Check output above for errors."
    echo "Status remains: build-wip"
    discord_thread_post "$(get_thread_id "$IDEA_ID" "wip")" "❌ **Codex failed** (exit code $CODEX_EXIT)"
    exit 1
  fi
else
  echo "📋 Run this command (needs PTY):"
  echo ""
  echo "  cd $WORK_DIR && codex exec --full-auto \"\$(cat .factory-prompt.txt)\""
  echo ""
  echo "Or Charles runs via exec tool:"
  echo "  exec pty:true workdir:$WORK_DIR command:\"codex exec --full-auto \\\"\$(cat .factory-prompt.txt)\\\"\""
  echo ""
  echo "After Codex completes, run:"
  echo "  bash factory/scripts/build.sh $IDEA_ID --post-codex"
  echo ""
  echo "Status: build-wip (waiting for Codex)"
  exit 0
fi

echo ""
echo "───── Codex Complete ─────"

fi  # end post-codex skip

# ── Check if anything changed ──
CHANGED_FILES=$(git diff --name-only 2>/dev/null; git diff --cached --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
if [[ -z "$CHANGED_FILES" ]]; then
  echo "⚠️  No files changed. Codex may not have made any modifications."
  echo "Status remains: build-wip"
  exit 1
fi

echo "Files changed:"
echo "$CHANGED_FILES" | head -20
echo ""

# ── Clean factory artifacts BEFORE staging ──
rm -f "$WORK_DIR/FACTORY-PRD.md" "$WORK_DIR/.factory-prompt.txt"

# ── Stage and commit if Codex didn't already ──
UNCOMMITTED=$(git status --porcelain 2>/dev/null)
if [[ -n "$UNCOMMITTED" ]]; then
  git add -A
  git commit -m "factory($IDEA_ID): $TITLE" 2>/dev/null || true
fi

# ── Push branch ──
echo "📤 Pushing $BRANCH..."
git push -u origin "$BRANCH" --force-with-lease 2>&1 || {
  echo "⚠️  Push failed. Trying force push..."
  git push -u origin "$BRANCH" --force 2>&1
}
echo ""

# ── Create PR ──
echo "📝 Creating PR..."
PR_URL=$(gh pr create \
  --repo "$REPO" \
  --head "$BRANCH" \
  --base main \
  --title "factory($IDEA_ID): $TITLE" \
  --body "## 🏭 Create Factory

**Idea:** $IDEA_ID — $TITLE
**PRD:** [View PRD](../blob/$BRANCH/FACTORY-PRD.md)

---

$(cat "$PRD_PATH")

---

*This PR was generated by the Create Factory pipeline.*
*Built with Codex \`--full-auto\` from a Charles-authored PRD.*" 2>&1) || {
  # PR might already exist
  PR_URL=$(gh pr view "$BRANCH" --repo "$REPO" --json url --jq '.url' 2>/dev/null || echo "PR creation failed")
}

echo "🔗 PR: $PR_URL"
echo ""

# ── Update idea with PR URL and status ──
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

# ── Update WIP thread → ready for QA ──
THREAD_NAME=$(wip_thread_name "build-ready" "$IDEA_ID" "$TITLE")
WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")
if [[ -n "$WIP_THREAD" ]]; then
  discord_thread_rename "$WIP_THREAD" "$THREAD_NAME"
  # Try to find the PP deploy request URL from the PR's check runs
  PR_NUM=$(echo "$PR_URL" | grep -o '[0-9]*$')
  PP_REQUEST_URL=""
  if [[ -n "$PR_NUM" ]]; then
    PP_REQUEST_URL=$(cd "$WORK_DIR" && GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) \
      gh api "repos/permission-protocol/app/pulls/${PR_NUM}/commits" --jq '.[0].sha' 2>/dev/null | \
      xargs -I{} bash -c 'GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh api "repos/permission-protocol/app/commits/{}/check-runs" --jq ".check_runs[] | select(.name | contains(\"Deploy Gate\")) | .output.summary" 2>/dev/null' | \
      grep -o 'https://app.permissionprotocol.com/pp/[^ )"]*' | head -1 2>/dev/null || echo "")
  fi
  if [[ -z "$PP_REQUEST_URL" ]]; then
    PP_REQUEST_URL="https://app.permissionprotocol.com/pp/deploy-requests"
  fi

  discord_thread_post "$WIP_THREAD" "✅ **Build complete** — ready for QA
🔗 **PR:** $PR_URL
🛡️ **PP:** <${PP_REQUEST_URL}>
📁 Files changed: $(cd "$WORK_DIR" && git diff --name-only main 2>/dev/null | wc -l | tr -d ' ')

Next: \`bash factory/scripts/qa.sh $IDEA_ID\`"
fi

discord_post "$CH_PIPELINE" "✅ **Build complete** — $IDEA_ID | PR: $PR_URL"

echo "═══════════════════════════════════════════════════════"
echo "  ✅ Build complete"
echo ""
echo "  Idea:   $IDEA_ID"
echo "  Status: build-ready"
echo "  PR:     $PR_URL"
echo "  Branch: $BRANCH"
echo ""
echo "  Next: bash factory/scripts/qa.sh $IDEA_ID"
echo "═══════════════════════════════════════════════════════"
