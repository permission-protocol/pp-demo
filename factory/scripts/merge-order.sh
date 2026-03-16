#!/usr/bin/env bash
# Factory Script: Merge Order Analyzer
# Detects overlapping file changes across factory PRs and suggests optimal merge order.
#
# Usage: bash factory/scripts/merge-order.sh [repo]
# Default repo: permission-protocol/app
#
# Output: ordered list of PRs with conflict risk annotations.
# Strategy: PRs touching unique files go first, shared-file PRs go last (fewest conflicts).

set -euo pipefail

REPO="${1:-permission-protocol/app}"
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt)
export GH_TOKEN

echo "═══════════════════════════════════════════════════════"
echo "  🏭 MERGE ORDER ANALYZER — $REPO"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── Get all open factory PRs ──
PRS=$(gh pr list --repo "$REPO" --state open --json number,title,headRefName --jq '.[] | select(.headRefName | startswith("factory/"))' 2>/dev/null)

if [[ -z "$PRS" ]]; then
  echo "No open factory/* PRs found."
  exit 0
fi

PR_NUMBERS=$(echo "$PRS" | jq -r '.number')
PR_COUNT=$(echo "$PR_NUMBERS" | wc -l | tr -d ' ')
echo "Found $PR_COUNT open factory PRs"
echo ""

# ── Collect changed files per PR ──
declare -A PR_FILES  # pr_number → file list
declare -A FILE_PRS  # file → pr numbers that touch it
declare -A PR_TITLES

while IFS= read -r pr_num; do
  [[ -z "$pr_num" ]] && continue
  FILES=$(gh pr diff "$pr_num" --repo "$REPO" --name-only 2>/dev/null || echo "")
  TITLE=$(echo "$PRS" | jq -r "select(.number == $pr_num) | .title")
  PR_FILES[$pr_num]="$FILES"
  PR_TITLES[$pr_num]="$TITLE"
  
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if [[ -n "${FILE_PRS[$file]:-}" ]]; then
      FILE_PRS[$file]="${FILE_PRS[$file]} $pr_num"
    else
      FILE_PRS[$file]="$pr_num"
    fi
  done <<< "$FILES"
done <<< "$PR_NUMBERS"

# ── Find conflicting files (touched by 2+ PRs) ──
echo "───── Conflict Risk Analysis ─────"
echo ""

CONFLICT_FILES=()
for file in "${!FILE_PRS[@]}"; do
  PR_LIST="${FILE_PRS[$file]}"
  PR_ARRAY=($PR_LIST)
  if [[ ${#PR_ARRAY[@]} -gt 1 ]]; then
    CONFLICT_FILES+=("$file")
    echo "⚠️  $file → touched by PRs: ${PR_LIST}"
  fi
done

if [[ ${#CONFLICT_FILES[@]} -eq 0 ]]; then
  echo "✅ No overlapping files — all PRs can merge in any order!"
  echo ""
  echo "───── Suggested Order (by PR number) ─────"
  while IFS= read -r pr_num; do
    [[ -z "$pr_num" ]] && continue
    echo "  #$pr_num — ${PR_TITLES[$pr_num]}"
  done <<< "$PR_NUMBERS"
  exit 0
fi

echo ""

# ── Score each PR: higher conflict score = merge later ──
declare -A PR_CONFLICT_SCORE

while IFS= read -r pr_num; do
  [[ -z "$pr_num" ]] && continue
  SCORE=0
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    PR_LIST="${FILE_PRS[$file]:-}"
    PR_ARRAY=($PR_LIST)
    if [[ ${#PR_ARRAY[@]} -gt 1 ]]; then
      SCORE=$((SCORE + ${#PR_ARRAY[@]} - 1))
    fi
  done <<< "${PR_FILES[$pr_num]}"
  PR_CONFLICT_SCORE[$pr_num]=$SCORE
done <<< "$PR_NUMBERS"

# ── Sort by conflict score (lowest first = merge first) ──
echo "───── Recommended Merge Order ─────"
echo "(lowest conflict risk first)"
echo ""

SORTED=$(for pr_num in "${!PR_CONFLICT_SCORE[@]}"; do
  echo "${PR_CONFLICT_SCORE[$pr_num]} $pr_num"
done | sort -n)

ORDER=1
while IFS= read -r line; do
  SCORE=$(echo "$line" | awk '{print $1}')
  PR_NUM=$(echo "$line" | awk '{print $2}')
  RISK="🟢"
  [[ $SCORE -gt 0 ]] && RISK="🟡"
  [[ $SCORE -gt 2 ]] && RISK="🔴"
  echo "  $ORDER. $RISK #$PR_NUM — ${PR_TITLES[$PR_NUM]} (conflict score: $SCORE)"
  ORDER=$((ORDER + 1))
done <<< "$SORTED"

echo ""
echo "───── Recommendation ─────"
echo "Merge 🟢 PRs first, then 🟡, then 🔴."
echo "After each 🟡/🔴 merge, remaining PRs may need rebase."
echo ""
echo "To auto-rebase after each merge:"
echo "  for pr in <remaining>; do gh pr update-branch \$pr --repo $REPO; done"
echo "═══════════════════════════════════════════════════════"
