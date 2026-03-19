#!/usr/bin/env bash
# Factory Script 2.75: Engineering Review
# Post-CEO-review, pre-spec technical challenge.
# Asks: "Will this implementation actually work? What's going to blow up?"
#
# Usage:
#   bash factory/scripts/eng-review.sh [idea-id]           # Specific idea
#   bash factory/scripts/eng-review.sh                      # Top backlog-ready
#   bash factory/scripts/eng-review.sh --auto               # Autonomous (cron)
#
# Flow:
#   1. Takes a backlog-ready idea (post-CEO-review)
#   2. Extracts relevant source code from the target repo
#   3. Sends to Gemini with eng-review prompt
#   4. Gemini returns: PROCEED / REVISE / SIMPLIFY
#   5. Output saved to factory/reviews/{id}-eng-review.md
#   6. Spec prompt reads this file for implementation context
#
# Pipeline position: review-idea.sh (CEO) → eng-review.sh → spec.sh
# Inspired by gstack /plan-eng-review

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
REVIEWS_DIR="$FACTORY_DIR/reviews"
CACHE_DIR="$HOME/pp-agent-work/factory-cache"

mkdir -p "$REVIEWS_DIR" "$CACHE_DIR"

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

# ── Find target idea ──
if [[ -n "$IDEA_ID_ARG" ]]; then
  IDEA=$(jq -c "select(.id == \"$IDEA_ID_ARG\")" "$IDEAS_FILE" | head -1)
else
  IDEA=$(jq -c 'select(.status == "backlog-ready")' "$IDEAS_FILE" | \
    jq -s 'sort_by(.priority // 999) | .[0]' 2>/dev/null)
  [[ "$IDEA" == "null" ]] && IDEA=""
fi

if [[ -z "$IDEA" ]] || [[ "$IDEA" == "null" ]]; then
  echo "ℹ️  No backlog-ready ideas for eng review."
  exit 0
fi

IDEA_ID=$(echo "$IDEA" | jq -r '.id')
TITLE=$(echo "$IDEA" | jq -r '.title')
DESC=$(echo "$IDEA" | jq -r '.description')
TARGET=$(echo "$IDEA" | jq -r '.target')
REPO=$(echo "$IDEA" | jq -r '.repo')
PERSONA=$(echo "$IDEA" | jq -r '.persona')
COMPLEXITY=$(echo "$IDEA" | jq -r '.complexity')
IDEA_TYPE=$(echo "$IDEA" | jq -r '.type // "feature"')

# Skip eng review for bugs — they have clear technical scope
if [[ "$IDEA_TYPE" == "bug" ]]; then
  echo "🐛 Bug — skipping eng review (scope is clear)"
  exit 0
fi

# Skip for retries
RETRY_COUNT=$(echo "$IDEA" | jq -r '.retry_count // 0')
if [[ "$RETRY_COUNT" -gt 0 ]]; then
  echo "♻️  Retry — skipping eng review"
  exit 0
fi

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Engineering Review"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:       $IDEA_ID — $TITLE"
echo "Target:     $TARGET ($REPO)"
echo "Complexity: $COMPLEXITY"
echo ""

# ── Clone/pull target repo for code context ──
REPO_CACHE="$CACHE_DIR/$TARGET"
TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
CLONE_CMD=$(jq -r '.clone_cmd // empty' "$TARGET_FILE" 2>/dev/null)

if [[ -d "$REPO_CACHE/.git" ]]; then
  git -C "$REPO_CACHE" pull --ff-only 2>/dev/null || git -C "$REPO_CACHE" fetch origin main 2>/dev/null || true
else
  if [[ -n "$CLONE_CMD" ]]; then
    eval "$CLONE_CMD $REPO_CACHE" 2>/dev/null || git clone --depth 50 "git@github.com:${REPO}.git" "$REPO_CACHE" 2>/dev/null
  else
    git clone --depth 50 "git@github.com:${REPO}.git" "$REPO_CACHE" 2>/dev/null
  fi
fi

# ── Extract relevant code context ──
CODE_CONTEXT=""
if [[ -d "$REPO_CACHE/src" ]]; then
  # Parse file paths and keywords from description
  FILE_PATTERNS=$(echo "$DESC" | grep -oE '[a-zA-Z0-9_/][a-zA-Z0-9_/.-]*\.(ts|tsx|js|jsx|py|md|yml|yaml)' | sort -u)
  KEYWORD_HINTS=$(echo "$DESC" | grep -oE '\b[a-z]{4,}[-_][a-z]+\b' | sort -u | head -5)

  FOUND_LIST=""
  for pattern in $FILE_PATTERNS; do
    MATCHES=$(find "$REPO_CACHE" -type f \
      -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/.next/*" \
      -path "*${pattern}*" 2>/dev/null | head -3)
    [[ -n "$MATCHES" ]] && FOUND_LIST+="$MATCHES"$'\n'
  done

  for keyword in $KEYWORD_HINTS; do
    KW_MATCHES=$(find "$REPO_CACHE" -type f \
      -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
      \( -name "route.ts" -o -name "page.tsx" -o -name "*.ts" \) \
      -path "*/${keyword}/*" 2>/dev/null | head -3)
    [[ -n "$KW_MATCHES" ]] && FOUND_LIST+="$KW_MATCHES"$'\n'
  done

  UNIQUE_FILES=$(echo "$FOUND_LIST" | grep -v '^$' | sort -u | head -10)

  if [[ -n "$UNIQUE_FILES" ]]; then
    for file in $UNIQUE_FILES; do
      REL_PATH="${file#$REPO_CACHE/}"
      LINES=$(wc -l < "$file" | tr -d ' ')
      CODE_CONTEXT+="
--- $REL_PATH ($LINES lines) ---
$(head -80 "$file")
"
      if [[ $LINES -gt 80 ]]; then
        CODE_CONTEXT+="... ($((LINES - 80)) more lines)
"
      fi
    done
  fi
fi

# ── Also grab project structure ──
TREE_CONTEXT=""
if [[ -d "$REPO_CACHE/src" ]]; then
  TREE_CONTEXT=$(find "$REPO_CACHE/src" -type f -name "*.ts" -o -name "*.tsx" | \
    sed "s|$REPO_CACHE/||" | sort | head -50)
fi

# ── Read CEO review if it exists ──
CEO_REVIEW=""
CEO_FILE="$REVIEWS_DIR/${IDEA_ID}-ceo-review.md"
if [[ -f "$CEO_FILE" ]]; then
  CEO_REVIEW=$(cat "$CEO_FILE")
fi

# ── Read FOCUS.md ──
FOCUS_CONTENT=""
FOCUS_PATH="$HOME/.openclaw/workspace/pp-os/FOCUS.md"
if [[ -f "$FOCUS_PATH" ]]; then
  FOCUS_CONTENT=$(cat "$FOCUS_PATH")
fi

# ── Build the review prompt ──
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" << PROMPT
You are a staff engineer reviewing a feature proposal BEFORE implementation begins.
Your job is to catch architectural problems, missing edge cases, and implementation landmines BEFORE code is written.

## The Idea
- **Title:** $TITLE
- **Description:** $DESC
- **Target persona:** $PERSONA
- **Complexity:** $COMPLEXITY
- **Repo:** $REPO

## CEO Review (if available)
$CEO_REVIEW

## Strategic Focus
$FOCUS_CONTENT

## Project Structure
\`\`\`
$TREE_CONTEXT
\`\`\`

## Relevant Source Code
$CODE_CONTEXT

## Your Review (answer ALL 5 sections)

### 1. Existing Code Leverage
- What existing code already partially solves this?
- Are we rebuilding anything that exists? If so, why?
- Which existing patterns/utilities should the implementation follow?
- Specific files and functions to reuse (with paths).

### 2. Architecture Concerns
- What components does this touch? What new coupling does it introduce?
- What's the data flow? (Input → Validation → Transform → Persist → Output)
- What happens if an external service (DB, API, auth) goes down mid-operation?
- What's the rollback plan if this ships and immediately breaks?
- Any scaling concerns at 10x current usage?

### 3. Edge Cases & Failure Modes
For each new codepath this introduces, list:
| Codepath | Failure Mode | How to Handle | User Sees |
|---|---|---|---|
| ... | ... | ... | ... |

Include at minimum:
- What if input is empty/null/malformed?
- What if concurrent requests hit the same resource?
- What if the operation partially succeeds then fails?

### 4. Test Requirements
For each new behavior, specify:
- Happy path test (what to assert)
- Failure path test (what error, what recovery)
- Edge case test (boundary values, empty state)

### 5. Verdict
Start with exactly one of:
- VERDICT: PROCEED — implementation plan is sound
- VERDICT: REVISE — needs changes before spec (list specific changes)
- VERDICT: SIMPLIFY — overbuilt, suggest minimal version

Then 2-3 sentences on the most important thing to get right during implementation.

Be direct. Be specific. Reference exact file paths from the code above.
PROMPT

if [[ "$AUTO" == true ]]; then
  echo "🔍 Running engineering review via Gemini..."

  REVIEW_OUTPUT=$(gemini_generate "$PROMPT_FILE" 0.5)
  rm -f "$PROMPT_FILE"

  if [[ -z "$REVIEW_OUTPUT" ]]; then
    echo "⚠️  Gemini returned empty response — skipping eng review"
    exit 0
  fi

  echo ""
  echo "───── Engineering Review ─────"
  echo "$REVIEW_OUTPUT"
  echo ""

  # Save the review
  {
    echo "# Engineering Review: $IDEA_ID — $TITLE"
    echo "**Date:** $(date -u +"%Y-%m-%d %H:%M UTC")"
    echo "**Repo:** $REPO"
    echo ""
    echo "$REVIEW_OUTPUT"
  } > "$REVIEWS_DIR/${IDEA_ID}-eng-review.md"

  # Parse verdict
  VERDICT=$(echo "$REVIEW_OUTPUT" | head -50 | grep -oE 'VERDICT: (PROCEED|REVISE|SIMPLIFY)' | head -1 || echo "")

  if echo "$VERDICT" | grep -q "PROCEED"; then
    echo "✅ Eng Review: PROCEED"
    discord_post "$CH_PIPELINE" "🔧 **Eng Review: PROCEED** — $IDEA_ID: $TITLE"

  elif echo "$VERDICT" | grep -q "REVISE"; then
    echo "🔄 Eng Review: REVISE — needs changes before spec"

    # Append revision notes to the idea
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    REVISION_NOTES=$(echo "$REVIEW_OUTPUT" | grep -A20 'VERDICT: REVISE' | tail -18)
    TEMP=$(mktemp)
    while IFS= read -r line; do
      LINE_ID=$(echo "$line" | jq -r '.id')
      if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
        echo "$line" | jq -c --arg now "$NOW" --arg notes "$REVISION_NOTES" \
          '.updated_at = $now | .eng_review = "revise" | .eng_feedback = $notes'
      else
        echo "$line"
      fi
    done < "$IDEAS_FILE" > "$TEMP"
    mv "$TEMP" "$IDEAS_FILE"

    discord_post "$CH_PIPELINE" "🔄 **Eng Review: REVISE** — $IDEA_ID: needs technical changes before spec"

  elif echo "$VERDICT" | grep -q "SIMPLIFY"; then
    echo "✂️  Eng Review: SIMPLIFY — overbuilt, needs scoping down"

    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    SIMPLIFY_NOTES=$(echo "$REVIEW_OUTPUT" | grep -A20 'VERDICT: SIMPLIFY' | tail -18)
    TEMP=$(mktemp)
    while IFS= read -r line; do
      LINE_ID=$(echo "$line" | jq -r '.id')
      if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
        echo "$line" | jq -c --arg now "$NOW" --arg notes "$SIMPLIFY_NOTES" \
          '.updated_at = $now | .eng_review = "simplify" | .eng_feedback = $notes'
      else
        echo "$line"
      fi
    done < "$IDEAS_FILE" > "$TEMP"
    mv "$TEMP" "$IDEAS_FILE"

    discord_post "$CH_PIPELINE" "✂️ **Eng Review: SIMPLIFY** — $IDEA_ID: overbuilt, needs scoping"

  else
    echo "⚠️  Could not parse verdict — defaulting to PROCEED"
    discord_post "$CH_PIPELINE" "🔧 **Eng Review: PROCEED** (default) — $IDEA_ID"
  fi

  echo "📝 Review saved: $REVIEWS_DIR/${IDEA_ID}-eng-review.md"

else
  echo "───── Eng Review Prompt ─────"
  echo "Prompt saved to: $PROMPT_FILE"
  echo ""
  echo "Run: bash factory/scripts/eng-review.sh $IDEA_ID --auto"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
