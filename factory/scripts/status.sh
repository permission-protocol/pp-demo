#!/usr/bin/env bash
# Factory Script: Status Dashboard
# Shows current state of all ideas, pipeline health, and cron readiness.
#
# Usage: bash factory/scripts/status.sh

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"
ARCHIVE_FILE="$FACTORY_DIR/ideas-archive.jsonl"

if [[ ! -f "$IDEAS_FILE" ]]; then
  echo "❌ No ideas file found"
  exit 1
fi

# ── Count by status ──
TOTAL=$(wc -l < "$IDEAS_FILE" | tr -d ' ')
ARCHIVED=$(wc -l < "$ARCHIVE_FILE" 2>/dev/null | tr -d ' ' || echo "0")

count_status() {
  local COUNT
  COUNT=$(grep -c "\"status\":[[:space:]]*\"$1\"" "$IDEAS_FILE" 2>/dev/null || true)
  echo "${COUNT:-0}" | tr -d '[:space:]'
}

BACKLOG=$(count_status "backlog-ready")
PRD_WIP=$(count_status "prd-wip")
PRD_READY=$(count_status "prd-ready")
BUILD_WIP=$(count_status "build-wip")
BUILD_READY=$(count_status "build-ready")
QA_WIP=$(count_status "qa-wip")
QA_PASSED=$(count_status "qa-passed")
QA_FAILED=$(count_status "qa-failed")
SHIPPED=$(count_status "shipped")

echo "═══════════════════════════════════════════════════════"
echo "  🏭 CREATE FACTORY — Status"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "  Pipeline:"
echo "  ─────────────────────────────────────────"
echo "  ⚪ Backlog         $BACKLOG"
echo "  📝 PRD WIP         $PRD_WIP"
echo "  📝 PRD Ready       $PRD_READY"
echo "  🟡 Build WIP       $BUILD_WIP"
echo "  ✅ Build Ready      $BUILD_READY"
echo "  🔵 QA WIP          $QA_WIP"
echo "  ✅ QA Passed        $QA_PASSED"
echo "  🔴 QA Failed        $QA_FAILED"
echo "  🚀 Shipped          $SHIPPED"
echo "  ─────────────────────────────────────────"
echo "  Active: $TOTAL  |  Archived: $ARCHIVED"
echo ""

# ── Priority list ──
echo "  Top Ideas (by priority):"
echo "  ─────────────────────────────────────────"
jq -s 'sort_by(.priority // 999)' "$IDEAS_FILE" | jq -r '.[] | 
  "  P\(.priority // "?") \(.id) [\(.status)] \(.title[:60])"'
echo ""

# ── Active work ──
ACTIVE=$(jq -s '[.[] | select(.status == "build-wip" or .status == "qa-wip")]' "$IDEAS_FILE")
ACTIVE_COUNT=$(echo "$ACTIVE" | jq 'length')
if [[ "$ACTIVE_COUNT" -gt 0 ]]; then
  echo "  🔥 Active Work:"
  echo "  ─────────────────────────────────────────"
  echo "$ACTIVE" | jq -r '.[] | "  \(.id) — \(.status) — \(.title[:50])"'
  echo ""
fi

# ── PRs pending merge ──
PRS=$(jq -s '[.[] | select(.pr_url != null and .pr_url != "none" and (.status == "qa-passed" or .status == "build-ready"))]' "$IDEAS_FILE")
PR_COUNT=$(echo "$PRS" | jq 'length')
if [[ "$PR_COUNT" -gt 0 ]]; then
  echo "  📋 PRs Ready for Merge:"
  echo "  ─────────────────────────────────────────"
  echo "$PRS" | jq -r '.[] | "  \(.id) — \(.pr_url)"'
  echo ""
fi

# ── Retry queue ──
RETRIES=$(jq -s '[.[] | select((.retry_count // 0) > 0)]' "$IDEAS_FILE")
RETRY_COUNT=$(echo "$RETRIES" | jq 'length')
if [[ "$RETRY_COUNT" -gt 0 ]]; then
  echo "  ⚠️  Retries:"
  echo "  ─────────────────────────────────────────"
  echo "$RETRIES" | jq -r '.[] | "  \(.id) — retry #\(.retry_count) — \(.status)"'
  echo ""
fi

# ── Scripts health ──
echo "  Scripts:"
echo "  ─────────────────────────────────────────"
for script in ideate.sh organize.sh spec.sh build.sh qa.sh status.sh; do
  if [[ -f "$FACTORY_DIR/scripts/$script" ]]; then
    echo "  ✅ $script"
  else
    echo "  ❌ $script (missing)"
  fi
done
echo ""

# ── Codex auth ──
echo "  Environment:"
echo "  ─────────────────────────────────────────"
if command -v codex &>/dev/null; then
  if codex login status &>/dev/null 2>&1; then
    echo "  ✅ Codex: authenticated"
  else
    echo "  ⚠️  Codex: not authenticated (run: codex login)"
  fi
else
  echo "  ❌ Codex: not installed"
fi

if [[ -f ~/.openclaw/secrets/github-pat-projects.txt ]]; then
  echo "  ✅ GitHub PAT: configured"
else
  echo "  ❌ GitHub PAT: missing"
fi

if [[ -f ~/.openclaw/secrets/discord-token.txt ]]; then
  echo "  ✅ Discord token: configured"
else
  echo "  ❌ Discord token: missing"
fi

# Repo cache
TARGET_FILE="$FACTORY_DIR/targets/pp.json"
if [[ -f "$TARGET_FILE" ]]; then
  CACHE_TARGET=$(jq -r '.target // "pp"' "$TARGET_FILE")
  CACHE_DIR="$HOME/pp-agent-work/factory-cache/$CACHE_TARGET"
  if [[ -d "$CACHE_DIR" ]]; then
    CACHE_AGE=$(( ( $(date +%s) - $(stat -f %m "$CACHE_DIR" 2>/dev/null || stat -c %Y "$CACHE_DIR" 2>/dev/null) ) / 3600 ))
    echo "  ✅ Repo cache: $CACHE_DIR (${CACHE_AGE}h old)"
  else
    echo "  ⚠️  Repo cache: not found (will clone on first build)"
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════"
