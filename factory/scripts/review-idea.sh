#!/usr/bin/env bash
# Factory Script 2.5: CEO Review Gate
# Challenges ideas BEFORE they get a PRD. Inspired by Garry Tan's /plan-ceo-review.
#
# Usage:
#   bash factory/scripts/review-idea.sh [idea-id]        # Specific idea
#   bash factory/scripts/review-idea.sh                   # Top backlog-ready
#   bash factory/scripts/review-idea.sh --auto            # Autonomous (cron-ready)
#
# Flow:
#   1. Takes a backlog-ready idea
#   2. Sends it to Gemini with a "founder challenge" prompt
#   3. Gemini returns: APPROVED (proceed to spec) or RETHINK (needs revision)
#   4. On APPROVE: status → prd-ready (skip to spec)
#   5. On RETHINK: posts feedback, stays backlog-ready with notes appended
#
# This gate catches bad specs early — before we waste a Codex run on the wrong thing.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"

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
  echo "ℹ️  No backlog-ready ideas to review."
  exit 0
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

# Skip review for bugs — they have clear scope already
if [[ "$IDEA_TYPE" == "bug" ]]; then
  echo "🐛 Bug detected — skipping CEO review (bugs don't need product challenge)"
  echo "📋 $IDEA_ID → proceeding directly to spec"
  exit 0
fi

# Skip review for P0 retries — already validated
RETRY_COUNT=$(echo "$IDEA" | jq -r '.retry_count // 0')
if [[ "$RETRY_COUNT" -gt 0 ]]; then
  echo "♻️  Retry #$RETRY_COUNT — skipping CEO review (already validated)"
  exit 0
fi

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — CEO Review Gate"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Idea:       $IDEA_ID — $TITLE"
echo "Target:     $TARGET ($REPO)"
echo "Persona:    $PERSONA"
echo "Complexity: $COMPLEXITY"
echo "Priority:   P$PRIORITY"
echo ""

# ── Load FOCUS.md for strategic context ──
FOCUS_CONTENT=""
FOCUS_PATH="$HOME/.openclaw/workspace/pp-os/FOCUS.md"
if [[ -f "$FOCUS_PATH" ]]; then
  FOCUS_CONTENT=$(cat "$FOCUS_PATH")
fi

# ── Build the challenge prompt ──
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" << PROMPT
You are the CEO/founder reviewing a product idea before it enters the build pipeline.
Your job is NOT to rubber-stamp. Your job is to challenge whether this is the RIGHT thing to build.

## Current Strategic Focus
$FOCUS_CONTENT

## The Idea
- **Title:** $TITLE
- **Description:** $DESC
- **Target persona:** $PERSONA
- **Complexity:** $COMPLEXITY (S/M/L)
- **Priority:** P$PRIORITY
- **Repo:** $REPO

## Your Review Criteria
1. **Is this the right problem?** Does this address a real user pain, or is it engineering-driven?
2. **Is the scope right?** Is this too small to matter, or too big to ship fast?
3. **Does it align with the current focus?** (See strategic focus above)
4. **Is there a 10x version hiding inside?** What's the bigger product insight?
5. **What's the cost of NOT building this?** If nothing — skip it.
6. **Would a customer notice?** If not — deprioritize.

## Output Format
Start your response with exactly one of:
- VERDICT: APPROVED — (proceed to build)
- VERDICT: RETHINK — (needs revision)

Then provide:
- **Challenge:** 2-3 sentences on what you'd push back on
- **Bigger insight:** What's the real product opportunity here? (1-2 sentences)
- **Recommendation:** What to do next (build as-is, revise scope, merge with another idea, kill it)

Be direct. Be opinionated. Don't be polite about bad ideas.
PROMPT

if [[ "$AUTO" == true ]]; then
  echo "🤖 Running CEO review via Gemini..."
  
  REVIEW_OUTPUT=$(gemini_generate "$PROMPT_FILE" 0.8)
  rm -f "$PROMPT_FILE"
  
  if [[ -z "$REVIEW_OUTPUT" ]]; then
    echo "⚠️  Gemini returned empty response — skipping review"
    exit 1
  fi
  
  echo ""
  echo "───── CEO Review ─────"
  echo "$REVIEW_OUTPUT"
  echo ""
  
  # Parse verdict
  VERDICT=$(echo "$REVIEW_OUTPUT" | head -5 | grep -oE 'VERDICT: (APPROVED|RETHINK)' | head -1 || echo "")
  
  WIP_THREAD=$(get_thread_id "$IDEA_ID" "wip")
  
  if echo "$VERDICT" | grep -q "APPROVED"; then
    echo "✅ CEO Review: APPROVED"
    
    # Store review in a file for the spec phase to reference
    REVIEW_DIR="$FACTORY_DIR/reviews"
    mkdir -p "$REVIEW_DIR"
    echo "$REVIEW_OUTPUT" > "$REVIEW_DIR/${IDEA_ID}-ceo-review.md"
    
    discord_post "$CH_PIPELINE" "👔 **CEO Review: APPROVED** — $IDEA_ID: $TITLE
$(echo "$REVIEW_OUTPUT" | grep -A2 'Bigger insight:' | head -3)"
    
    echo "📋 Proceeding to spec phase"
    
  elif echo "$VERDICT" | grep -q "RETHINK"; then
    echo "🔄 CEO Review: RETHINK"
    
    # Store review
    REVIEW_DIR="$FACTORY_DIR/reviews"
    mkdir -p "$REVIEW_DIR"
    echo "$REVIEW_OUTPUT" > "$REVIEW_DIR/${IDEA_ID}-ceo-review.md"
    
    # Append feedback to the idea description for context
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    REVIEW_SUMMARY=$(echo "$REVIEW_OUTPUT" | grep -A5 'Challenge:\|Recommendation:' | head -8)
    TEMP=$(mktemp)
    while IFS= read -r line; do
      LINE_ID=$(echo "$line" | jq -r '.id')
      if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
        echo "$line" | jq -c --arg now "$NOW" --arg review "$REVIEW_SUMMARY" \
          '.updated_at = $now | .ceo_review = "rethink" | .ceo_feedback = $review'
      else
        echo "$line"
      fi
    done < "$IDEAS_FILE" > "$TEMP"
    mv "$TEMP" "$IDEAS_FILE"
    
    discord_post "$CH_PIPELINE" "🔄 **CEO Review: RETHINK** — $IDEA_ID: $TITLE
$(echo "$REVIEW_OUTPUT" | grep -A2 'Challenge:' | head -3)
$(echo "$REVIEW_OUTPUT" | grep -A2 'Recommendation:' | head -3)"
    
    echo "📋 Idea stays backlog-ready with feedback attached"
    echo "   Review: factory/reviews/${IDEA_ID}-ceo-review.md"
    
  else
    echo "⚠️  Could not parse verdict — defaulting to APPROVED"
    echo "   (Review output may not have followed format)"
    discord_post "$CH_PIPELINE" "👔 **CEO Review: APPROVED** (default) — $IDEA_ID: $TITLE"
  fi
  
else
  # Interactive mode: just show the prompt
  echo "───── Challenge Prompt ─────"
  cat "$PROMPT_FILE"
  echo ""
  echo "Charles: Run this review, then update the idea accordingly."
  echo "  APPROVED → proceed to: bash factory/scripts/spec.sh $IDEA_ID"
  echo "  RETHINK  → revise description, then re-run review"
  rm -f "$PROMPT_FILE"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
