#!/usr/bin/env bash
# Factory Script 3: Spec
# Writes a PRD for the top-ranked backlog-ready idea.
#
# Usage:
#   bash factory/scripts/spec.sh [idea-id]              # Interactive
#   bash factory/scripts/spec.sh [idea-id] --auto        # Autonomous (cron-ready)
#
# --auto mode clones/pulls the target repo, extracts relevant code,
# builds a prompt with the PRD template, and outputs it for an agent.
# Interactive mode shows context and waits for manual PRD creation.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
PRDS_DIR="$FACTORY_DIR/prds"
TEMPLATES_DIR="$FACTORY_DIR/templates"
CACHE_DIR="$HOME/pp-agent-work/factory-cache"

AUTO=false
IDEA_ID_ARG=""
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=true ;;
    idea-*|gh-*) IDEA_ID_ARG="$arg" ;;
  esac
done

if [[ ! -f "$IDEAS_FILE" ]]; then
  echo "❌ No ideas file found"
  exit 1
fi

mkdir -p "$PRDS_DIR" "$CACHE_DIR"

# ── Find the target idea ──
if [[ -n "$IDEA_ID_ARG" ]]; then
  IDEA=$(jq -c "select(.id == \"$IDEA_ID_ARG\")" "$IDEAS_FILE" | head -1)
else
  # Pick highest priority backlog-ready item
  IDEA=$(jq -c 'select(.status == "backlog-ready")' "$IDEAS_FILE" | \
    jq -s 'sort_by(.priority // 999) | .[0]' 2>/dev/null)
  [[ "$IDEA" == "null" ]] && IDEA=""
fi

if [[ -z "$IDEA" ]] || [[ "$IDEA" == "null" ]]; then
  echo "❌ No backlog-ready ideas found."
  echo "Run: bash factory/scripts/organize.sh first"
  exit 1
fi

IDEA_ID=$(echo "$IDEA" | jq -r '.id')
TITLE=$(echo "$IDEA" | jq -r '.title')
DESC=$(echo "$IDEA" | jq -r '.description')
TARGET=$(echo "$IDEA" | jq -r '.target')
REPO=$(echo "$IDEA" | jq -r '.repo')
PERSONA=$(echo "$IDEA" | jq -r '.persona')
COMPLEXITY=$(echo "$IDEA" | jq -r '.complexity')
PRIORITY=$(echo "$IDEA" | jq -r '.priority')
IDEA_TYPE=$(echo "$IDEA" | jq -r '.type // "feature"')

# Load target config
TARGET_FILE="$FACTORY_DIR/targets/${TARGET}.json"
PERSONAS=$(jq -r '.personas[]' "$TARGET_FILE" 2>/dev/null || echo "N/A")
CLONE_CMD=$(jq -r '.clone_cmd // empty' "$TARGET_FILE" 2>/dev/null)

# Update status to prd-wip
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TEMP=$(mktemp)
while IFS= read -r line; do
  LINE_ID=$(echo "$line" | jq -r '.id')
  if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
    echo "$line" | jq -c --arg now "$NOW" '.status = "prd-wip" | .updated_at = $now'
  else
    echo "$line"
  fi
done < "$IDEAS_FILE" > "$TEMP"
mv "$TEMP" "$IDEAS_FILE"

PRD_PATH="$PRDS_DIR/${IDEA_ID}.md"

# ── Clone/pull the target repo ──
REPO_CACHE="$CACHE_DIR/$TARGET"
clone_or_pull_repo() {
  if [[ -d "$REPO_CACHE/.git" ]]; then
    echo "📦 Pulling latest for $REPO..."
    git -C "$REPO_CACHE" pull --ff-only 2>/dev/null || git -C "$REPO_CACHE" fetch origin main 2>/dev/null || true
  else
    echo "📦 Cloning $REPO..."
    if [[ -n "$CLONE_CMD" ]]; then
      eval "$CLONE_CMD $REPO_CACHE" 2>/dev/null || git clone --depth 50 "git@github.com:${REPO}.git" "$REPO_CACHE" 2>/dev/null
    else
      git clone --depth 50 "git@github.com:${REPO}.git" "$REPO_CACHE" 2>/dev/null
    fi
  fi
}

# ── Extract relevant code from idea description ──
# Parse file paths mentioned in the description (patterns like src/..., lib/..., etc.)
extract_relevant_code() {
  local REPO_DIR="$1"
  local DESCRIPTION="$2"
  local CODE_CONTEXT=""

  # Extract file-like patterns from description (e.g. action.yml, route.ts, enrich.ts)
  local FILE_PATTERNS
  FILE_PATTERNS=$(echo "$DESCRIPTION" | grep -oE '[a-zA-Z0-9_/][a-zA-Z0-9_/.-]*\.(ts|tsx|js|jsx|py|md|yml|yaml)' | sort -u)

  # Extract directory-like patterns (src/..., .github/..., templates/...)
  local DIR_PATTERNS
  DIR_PATTERNS=$(echo "$DESCRIPTION" | grep -oE '(src|\.github|templates)/[a-zA-Z0-9_/.-]+' | sort -u)

  # Extract keyword hints (e.g. "verify endpoint" → search for dirs named "verify")
  local KEYWORD_HINTS
  KEYWORD_HINTS=$(echo "$DESCRIPTION" | grep -oE '\b[a-z]{4,}[-_][a-z]+\b|verify|enrichment|approve|receipt|deploy-gate|post-approval' | sort -u | head -5)

  # Search full repo tree (excluding node_modules, .git, dist)
  local FOUND_LIST=""
  for pattern in $FILE_PATTERNS $DIR_PATTERNS; do
    local MATCHES
    MATCHES=$(find "$REPO_DIR" -type f \
      -not -path "*/node_modules/*" \
      -not -path "*/.git/*" \
      -not -path "*/dist/*" \
      -not -path "*/.next/*" \
      -path "*${pattern}*" 2>/dev/null | head -3)
    if [[ -n "$MATCHES" ]]; then
      FOUND_LIST+="$MATCHES"$'\n'
    fi
  done

  # Secondary: keyword-based directory search for files we might have missed
  for keyword in $KEYWORD_HINTS; do
    # Find route.ts / page.tsx files in directories matching the keyword
    local KW_MATCHES
    KW_MATCHES=$(find "$REPO_DIR" -type f \
      -not -path "*/node_modules/*" \
      -not -path "*/.git/*" \
      -not -path "*/dist/*" \
      -not -path "*/.next/*" \
      \( -name "route.ts" -o -name "page.tsx" -o -name "*.ts" \) \
      -path "*/${keyword}/*" 2>/dev/null | head -3)
    if [[ -n "$KW_MATCHES" ]]; then
      FOUND_LIST+="$KW_MATCHES"$'\n'
    fi
  done

  # Find test files matching keywords
  for keyword in $KEYWORD_HINTS; do
    local TEST_MATCHES
    TEST_MATCHES=$(find "$REPO_DIR" -type f \
      -not -path "*/node_modules/*" \
      -not -path "*/.git/*" \
      \( -path "*/tests/*" -o -path "*/test/*" -o -path "*/__tests__/*" \) \
      -name "*${keyword}*" 2>/dev/null | head -2)
    if [[ -n "$TEST_MATCHES" ]]; then
      FOUND_LIST+="$TEST_MATCHES"$'\n'
    fi
  done

  # Dedupe
  local UNIQUE_FILES
  UNIQUE_FILES=$(echo "$FOUND_LIST" | grep -v '^$' | sort -u | head -12)

  # Build set of "primary files" — explicitly named in the description (get full content)
  local PRIMARY_FILES=""
  for pattern in $FILE_PATTERNS; do
    # Only exact filename matches count as primary (e.g. "enrich.ts", "action.yml")
    local BASENAME
    BASENAME=$(basename "$pattern")
    for file in $UNIQUE_FILES; do
      if [[ "$(basename "$file")" == "$BASENAME" ]] || [[ "$file" == *"$pattern"* ]]; then
        PRIMARY_FILES+="$file"$'\n'
      fi
    done
  done
  PRIMARY_FILES=$(echo "$PRIMARY_FILES" | grep -v '^$' | sort -u | head -3)

  if [[ -n "$UNIQUE_FILES" ]]; then
    for file in $UNIQUE_FILES; do
      local REL_PATH="${file#$REPO_DIR/}"
      local LINES=$(wc -l < "$file" | tr -d ' ')
      local IS_PRIMARY=false

      # Check if this is a primary file (explicitly named in description)
      if echo "$PRIMARY_FILES" | grep -qF "$file"; then
        IS_PRIMARY=true
      fi

      # Check if this is a test file
      local IS_TEST=false
      if echo "$file" | grep -qE '/tests?/|/__tests__/'; then
        IS_TEST=true
      fi

      if [[ "$IS_PRIMARY" == true ]] && [[ $LINES -le 500 ]]; then
        # Primary files: full content (up to 500 lines)
        CODE_CONTEXT+="
--- $REL_PATH ($LINES lines) [PRIMARY — full content] ---
$(cat "$file")
"
      elif [[ "$IS_TEST" == true ]]; then
        # Test files: first 60 lines (enough to see patterns)
        CODE_CONTEXT+="
--- $REL_PATH ($LINES lines) [TEST] ---
$(head -60 "$file")
"
        if [[ $LINES -gt 60 ]]; then
          CODE_CONTEXT+="
... ($((LINES - 60)) more lines)
"
        fi
      else
        # Other files: first 100 lines
        CODE_CONTEXT+="
--- $REL_PATH ($LINES lines) ---
$(head -100 "$file")
"
        if [[ $LINES -gt 100 ]]; then
          CODE_CONTEXT+="
... ($((LINES - 100)) more lines)
"
        fi
      fi
    done
  fi

  echo "$CODE_CONTEXT"
}

# ── Validate PRD file paths against repo ──
validate_prd_paths() {
  local PRD_FILE="$1"
  local REPO_DIR="$2"
  local WARNINGS=0

  # Extract file paths from PRD (src/... patterns)
  local PRD_PATHS
  PRD_PATHS=$(grep -oE 'src/[a-zA-Z0-9_/.@\[\]-]+\.(ts|tsx)' "$PRD_FILE" 2>/dev/null | sort -u)

  for path in $PRD_PATHS; do
    # Skip paths that are clearly new files (contain "new" in nearby context)
    if [[ ! -f "$REPO_DIR/$path" ]]; then
      echo "⚠️  Path not found in repo: $path (may be a new file)"
      WARNINGS=$((WARNINGS + 1))
    fi
  done

  if [[ $WARNINGS -eq 0 ]]; then
    echo "✅ All file paths validated against repo"
  else
    echo "⚠️  $WARNINGS path(s) not found — may be new files or typos"
  fi
}

# ══════════════════════════════════════════════════════════
# Auto mode
# ══════════════════════════════════════════════════════════
if [[ "$AUTO" == true ]]; then

  clone_or_pull_repo

  # Extract code context
  CODE_CONTEXT=""
  if [[ -d "$REPO_CACHE/src" ]]; then
    CODE_CONTEXT=$(extract_relevant_code "$REPO_CACHE" "$DESC")
  fi

  # Read FOCUS.md
  FOCUS_CONTENT=""
  FOCUS_PATH="$HOME/.openclaw/workspace/pp-os/FOCUS.md"
  if [[ -f "$FOCUS_PATH" ]]; then
    FOCUS_CONTENT=$(cat "$FOCUS_PATH")
  fi

  # Read engineering review if it exists (from eng-review.sh)
  ENG_REVIEW_CONTENT=""
  ENG_REVIEW_PATH="$FACTORY_DIR/reviews/${IDEA_ID}-eng-review.md"
  if [[ -f "$ENG_REVIEW_PATH" ]]; then
    ENG_REVIEW_CONTENT=$(cat "$ENG_REVIEW_PATH")
    echo "📋 Engineering review found — injecting into spec context"
  fi

  # Read CEO review if it exists (from review-idea.sh)
  CEO_REVIEW_CONTENT=""
  CEO_REVIEW_PATH="$FACTORY_DIR/reviews/${IDEA_ID}-ceo-review.md"
  if [[ -f "$CEO_REVIEW_PATH" ]]; then
    CEO_REVIEW_CONTENT=$(cat "$CEO_REVIEW_PATH")
    echo "📋 CEO review found — injecting into spec context"
  fi

  # Read appropriate template based on idea type
  PRD_TEMPLATE=""
  if [[ "$IDEA_TYPE" == "bug" ]] && [[ -f "$TEMPLATES_DIR/bugfix.md" ]]; then
    PRD_TEMPLATE=$(cat "$TEMPLATES_DIR/bugfix.md")
    echo "📋 Type: bug → using bugfix template"
  elif [[ -f "$TEMPLATES_DIR/prd.md" ]]; then
    PRD_TEMPLATE=$(cat "$TEMPLATES_DIR/prd.md")
    echo "📋 Type: feature → using PRD template"
  fi

  echo "═══════════════════════════════════════════════════════"
  echo "  🏭 CREATE FACTORY — Spec (Auto Mode)"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  echo "Idea:       $IDEA_ID — $TITLE"
  echo "Target:     $TARGET ($REPO)"
  echo "Persona:    $PERSONA"
  echo "Complexity: $COMPLEXITY"
  echo "PRD path:   $PRD_PATH"
  echo "Repo cache: $REPO_CACHE"
  echo ""

  # Output the prompt (bug vs feature)
  if [[ "$IDEA_TYPE" == "bug" ]]; then
    cat << AUTOPROMPT

You are the Create Factory spec engine. Write a **bugfix spec** for the issue below.

## Your Task
Analyze the relevant source code, identify the root cause, and write a focused bugfix spec.
Output ONLY the bugfix markdown — no wrapping, no code fences around the whole thing.

## Bug Report
- **ID:** $IDEA_ID
- **Title:** $TITLE
- **Description:** $DESC
- **Persona affected:** $PERSONA
- **Priority:** P$PRIORITY
- **Repo:** $REPO

## Bugfix Template (follow this structure)
$PRD_TEMPLATE

## Relevant Source Code (from the actual repo)
$CODE_CONTEXT

## Critical Rules for the Fix Approach section:
1. Reference EXACT file paths and function names from the code above
2. Identify the root cause precisely — not symptoms
3. The fix should be minimal — don't refactor unrelated code
4. Include a regression test if possible
5. End with: "Before finishing, run \`npx tsc --noEmit\` and fix any type errors."

## Output
Write the bugfix spec now. Replace all {{placeholders}} with real values.
Save path: $PRD_PATH
AUTOPROMPT
  else
    cat << AUTOPROMPT

You are the Create Factory spec engine. Write a PRD for the idea below.

## Your Task
Write a complete PRD following the template. Output ONLY the PRD markdown — no wrapping, no code fences around the whole thing, no explanation.

## Idea
- **ID:** $IDEA_ID
- **Title:** $TITLE
- **Description:** $DESC
- **Persona:** $PERSONA
- **Complexity:** $COMPLEXITY
- **Priority:** P$PRIORITY
- **Repo:** $REPO

## Personas
$PERSONAS

## FOCUS
$FOCUS_CONTENT

## PRD Template (follow this structure exactly)
$PRD_TEMPLATE

## Engineering Review (address these concerns in the spec)
$ENG_REVIEW_CONTENT

## CEO Review (product direction context)
$CEO_REVIEW_CONTENT

## Relevant Source Code (from the actual repo)
$CODE_CONTEXT

## Critical Rules for the Codex Prompt section:
1. Reference EXACT file paths from the repo (you can see them in the code above)
2. Reference EXACT function names, types, and imports
3. Name an existing similar function as a pattern to follow
4. Include constraints (don't modify schema, don't touch frontend, etc.)
5. The prompt must be copy-paste ready — a developer should be able to hand it to Codex verbatim
6. If test files are shown above (marked [TEST]), tell Codex to add tests following the same patterns
7. Files marked [PRIMARY] contain full content — use specific line references and function signatures from them
8. BEFORE proposing new endpoints or files, check if existing code already handles it. Wrap existing APIs with new UI — don't rebuild what exists.
9. End the Codex prompt with: "Before finishing, run `npx tsc --noEmit` and fix any type errors."

## Output
Write the PRD now. Replace all {{placeholders}} with real values.
Save path: $PRD_PATH
AUTOPROMPT
  fi  # end bug vs feature prompt

  echo ""
  echo "PRD_PATH=$PRD_PATH"
  echo "REPO_CACHE=$REPO_CACHE"
  echo "IDEA_ID=$IDEA_ID"

  exit 0
fi

# ══════════════════════════════════════════════════════════
# Interactive mode
# ══════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Spec"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:       $IDEA_ID — $TITLE"
echo "Type:       $IDEA_TYPE"
echo "Target:     $TARGET ($REPO)"
echo "Persona:    $PERSONA"
echo "Complexity: $COMPLEXITY"
echo "PRD path:   $PRD_PATH"
echo ""
echo "───── Idea Description ─────"
echo "$DESC"
echo ""
echo "───── Personas ─────"
echo "$PERSONAS"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Charles: Write the PRD for this idea. Include:"
echo ""
echo "  ## Summary"
echo "  ## Problem"
echo "  ## Solution"
echo "  ## User Journey"
echo "  ## Files to Change (exact paths)"
echo "  ## Acceptance Criteria (checkboxes)"
echo "  ## Edge Cases"
echo "  ## Out of Scope"
echo "  ## Codex Prompt (copy-paste ready)"
echo ""
echo "Save the PRD to: $PRD_PATH"
echo "Then run: bash factory/scripts/build.sh"
echo ""
echo "Status updated: $IDEA_ID → prd-wip"
