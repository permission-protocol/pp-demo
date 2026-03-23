#!/usr/bin/env bash
# Factory Policy Gate: Evaluates PR blast radius and decides merge path.
#
# This is the Permission Protocol dogfood layer. Instead of routing all
# qa-passed PRs to Rod for manual review, we classify the diff by blast
# radius and auto-merge low-risk changes while hard-blocking high-risk ones.
#
# Usage: bash factory/scripts/policy-gate.sh [idea-id]
# If no ID given, processes all qa-passed items.
#
# Blast Radius Classification:
#   🟢 LOW    → UI-only changes (components, styles, static content)
#              → Auto-merge if tests pass
#   🟡 MEDIUM → API routes, business logic, new dependencies
#              → Auto-merge with notification to Rod
#   🔴 HIGH   → Auth, middleware, DB schemas, env config, secrets, CI/CD
#              → Hard block. Route to Rod for manual review.
#
# The classification is deterministic (file-path based), not LLM-based.
# No hallucination. No judgment calls. Just patterns.

set -euo pipefail
FACTORY_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$FACTORY_DIR/scripts/discord-helper.sh"
IDEAS_FILE="$FACTORY_DIR/ideas.jsonl"

GH_TOKEN=$(cat "$HOME/.openclaw/secrets/github-pat-projects.txt")
export GH_TOKEN

# ═══════════════════════════════════════════════════════
# POLICY RULES — Deterministic file-path classification
# ═══════════════════════════════════════════════════════

# 🔴 HIGH blast radius patterns (regex, matched against file paths in diff)
HIGH_PATTERNS=(
  "middleware\\.ts"
  "middleware\\.js"
  "src/lib/auth/"
  "src/lib/config/"
  "prisma/"
  "drizzle/"
  "migrations/"
  "\\.env"
  "render\\.yaml"
  "docker"
  "Dockerfile"
  "\\.github/workflows/"
  "action\\.yml"
  "package\\.json"       # dependency changes
  "pnpm-lock\\.yaml"
  "yarn\\.lock"
  "sentry\\."
  "instrumentation\\.ts"
  "next\\.config"
)

# 🟡 MEDIUM blast radius patterns
MEDIUM_PATTERNS=(
  "src/app/api/"
  "src/lib/"
  "src/server/"
  "src/workers/"
  "scripts/"
  "src/lib/worker/"
)

# Everything else is 🟢 LOW (components, pages, styles, static assets, docs)

classify_file() {
  local filepath="$1"
  
  for pattern in "${HIGH_PATTERNS[@]}"; do
    if echo "$filepath" | grep -qE "$pattern"; then
      echo "HIGH"
      return
    fi
  done
  
  for pattern in "${MEDIUM_PATTERNS[@]}"; do
    if echo "$filepath" | grep -qE "$pattern"; then
      echo "MEDIUM"
      return
    fi
  done
  
  echo "LOW"
}

classify_pr() {
  local repo="$1"
  local pr_number="$2"
  
  # Get the list of changed files
  local files
  files=$(GH_TOKEN="$GH_TOKEN" gh pr diff "$pr_number" --repo "$repo" --name-only 2>/dev/null)
  
  if [[ -z "$files" ]]; then
    echo "HIGH"  # If we can't read the diff, assume high risk
    return
  fi
  
  local max_level="LOW"
  local high_files=()
  local medium_files=()
  local low_files=()
  
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    local level
    level=$(classify_file "$file")
    
    case "$level" in
      HIGH)
        max_level="HIGH"
        high_files+=("$file")
        ;;
      MEDIUM)
        if [[ "$max_level" != "HIGH" ]]; then
          max_level="MEDIUM"
        fi
        medium_files+=("$file")
        ;;
      LOW)
        low_files+=("$file")
        ;;
    esac
  done <<< "$files"
  
  # Output classification report
  echo "CLASSIFICATION=$max_level"
  echo "HIGH_FILES=${#high_files[@]}"
  echo "MEDIUM_FILES=${#medium_files[@]}"
  echo "LOW_FILES=${#low_files[@]}"
  
  if [[ ${#high_files[@]} -gt 0 ]]; then
    echo "HIGH_LIST=$(IFS=,; echo "${high_files[*]}")"
  fi
  if [[ ${#medium_files[@]} -gt 0 ]]; then
    echo "MEDIUM_LIST=$(IFS=,; echo "${medium_files[*]}")"
  fi
}

# ═══════════════════════════════════════════════════════
# PROCESS qa-passed IDEAS
# ═══════════════════════════════════════════════════════

IDEA_ID="${1:-}"
PROCESSED=0
AUTO_MERGED=0
BLOCKED=0

process_idea() {
  local idea_json="$1"
  local id title repo pr_url pr_number
  
  id=$(echo "$idea_json" | jq -r '.id')
  title=$(echo "$idea_json" | jq -r '.title')
  repo=$(echo "$idea_json" | jq -r '.repo // empty')
  pr_url=$(echo "$idea_json" | jq -r '.pr_url // empty')
  
  if [[ -z "$pr_url" ]]; then
    echo "⚠️  $id: No PR URL found, skipping"
    return
  fi
  
  # Extract PR number and repo from URL
  pr_number=$(echo "$pr_url" | grep -oE '[0-9]+$')
  if [[ -z "$repo" ]]; then
    repo=$(echo "$pr_url" | sed 's|https://github.com/||; s|/pull/.*||')
  fi
  
  echo ""
  echo "═══════════════════════════════════════"
  echo "📋 Policy Gate: $id — $title"
  echo "   PR: $pr_url"
  echo "═══════════════════════════════════════"
  
  # Classify the PR
  local report
  report=$(classify_pr "$repo" "$pr_number")
  local classification
  classification=$(echo "$report" | grep "^CLASSIFICATION=" | cut -d= -f2)
  
  echo "$report"
  echo ""
  
  case "$classification" in
    LOW)
      echo "🟢 LOW blast radius — Auto-merging"
      
      # Check that CI is passing
      local checks_ok
      checks_ok=$(GH_TOKEN="$GH_TOKEN" gh pr checks "$pr_number" --repo "$repo" 2>/dev/null | grep -c "fail" || true)
      
      if [[ "$checks_ok" -gt 0 ]]; then
        echo "❌ CI checks failing — blocking merge"
        discord_post "1482047785435009105" "🔴 **Policy Gate:** \`$id\` classified as LOW risk but CI is failing. Blocked.\n$pr_url"
        return
      fi
      
      # Auto-merge
      GH_TOKEN="$GH_TOKEN" gh pr merge "$pr_number" --repo "$repo" --squash --auto 2>/dev/null && {
        echo "✅ Auto-merge enabled"
        
        # Update status in ideas.jsonl
        python3 -c "
import json, datetime
lines = []
with open('$IDEAS_FILE', 'r') as f:
    for line in f:
        if not line.strip(): continue
        idea = json.loads(line)
        if idea['id'] == '$id':
            idea['status'] = 'done'
            idea['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
            idea['merge_type'] = 'auto-merged'
            idea['policy_classification'] = 'LOW'
        lines.append(json.dumps(idea))
with open('$IDEAS_FILE', 'w') as f:
    f.write('\n'.join(lines) + '\n')
"
        discord_post "1482047785435009105" "🟢 **Policy Gate:** Auto-merged \`$id\` — $title\nClassification: LOW blast radius (UI-only changes)\n$pr_url"
        AUTO_MERGED=$((AUTO_MERGED + 1))
      } || {
        echo "⚠️  Auto-merge failed (may need branch protection override)"
        discord_post "1482047785435009105" "⚠️ **Policy Gate:** \`$id\` classified LOW but auto-merge failed. Needs manual merge.\n$pr_url"
      }
      ;;
      
    MEDIUM)
      echo "🟡 MEDIUM blast radius — Auto-merging with notification"
      local medium_list
      medium_list=$(echo "$report" | grep "^MEDIUM_LIST=" | cut -d= -f2 || echo "")
      
      # Check CI
      local checks_ok
      checks_ok=$(GH_TOKEN="$GH_TOKEN" gh pr checks "$pr_number" --repo "$repo" 2>/dev/null | grep -c "fail" || true)
      
      if [[ "$checks_ok" -gt 0 ]]; then
        echo "❌ CI checks failing — blocking merge"
        discord_post "1482047785435009105" "🔴 **Policy Gate:** \`$id\` classified as MEDIUM risk but CI is failing. Blocked.\n$pr_url"
        return
      fi
      
      GH_TOKEN="$GH_TOKEN" gh pr merge "$pr_number" --repo "$repo" --squash --auto 2>/dev/null && {
        echo "✅ Auto-merge enabled (with notification)"
        
        python3 -c "
import json, datetime
lines = []
with open('$IDEAS_FILE', 'r') as f:
    for line in f:
        if not line.strip(): continue
        idea = json.loads(line)
        if idea['id'] == '$id':
            idea['status'] = 'done'
            idea['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
            idea['merge_type'] = 'auto-merged-medium'
            idea['policy_classification'] = 'MEDIUM'
        lines.append(json.dumps(idea))
with open('$IDEAS_FILE', 'w') as f:
    f.write('\n'.join(lines) + '\n')
"
        # Notify Rod in #rc-main
        discord_post "1479281042690019358" "🟡 **Factory Auto-Merge (MEDIUM):** $title\nFiles touching business logic: \`$medium_list\`\nPR: $pr_url\n\n*Auto-merged by Policy Gate. Review post-merge if needed.*"
        discord_post "1482047785435009105" "🟡 **Policy Gate:** Auto-merged \`$id\` — $title\nClassification: MEDIUM (business logic changes)\n$pr_url"
        AUTO_MERGED=$((AUTO_MERGED + 1))
      } || {
        echo "⚠️  Auto-merge failed"
        discord_post "1482047785435009105" "⚠️ **Policy Gate:** \`$id\` classified MEDIUM but auto-merge failed.\n$pr_url"
      }
      ;;
      
    HIGH)
      echo "🔴 HIGH blast radius — Blocking. Routing to Rod."
      local high_list
      high_list=$(echo "$report" | grep "^HIGH_LIST=" | cut -d= -f2 || echo "")
      
      # Update status to needs-review
      python3 -c "
import json, datetime
lines = []
with open('$IDEAS_FILE', 'r') as f:
    for line in f:
        if not line.strip(): continue
        idea = json.loads(line)
        if idea['id'] == '$id':
            idea['status'] = 'needs-rod-review'
            idea['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
            idea['policy_classification'] = 'HIGH'
            idea['high_risk_files'] = '$high_list'
        lines.append(json.dumps(idea))
with open('$IDEAS_FILE', 'w') as f:
    f.write('\n'.join(lines) + '\n')
"
      # Alert Rod in #rc-main
      discord_post "1479281042690019358" "🔴 **Factory Policy Gate — HUMAN REVIEW REQUIRED**\n**$title**\n\n⚠️ High blast radius files:\n\`\`\`\n$high_list\n\`\`\`\nPR: $pr_url\n\nThis PR touches critical infrastructure. Auto-merge blocked."
      discord_post "1482047785435009105" "🔴 **Policy Gate:** Blocked \`$id\` — $title\nClassification: HIGH (critical infra)\nRouted to Rod for manual review."
      BLOCKED=$((BLOCKED + 1))
      ;;
  esac
  
  PROCESSED=$((PROCESSED + 1))
}

# ── Find qa-passed ideas ──
if [[ -n "$IDEA_ID" ]]; then
  IDEA=$(grep "\"id\":\"$IDEA_ID\"\|\"id\": \"$IDEA_ID\"" "$IDEAS_FILE" | head -1)
  if [[ -z "$IDEA" ]]; then
    echo "❌ Idea $IDEA_ID not found"
    exit 1
  fi
  process_idea "$IDEA"
else
  while IFS= read -r idea_line; do
    [[ -z "$idea_line" ]] && continue
    process_idea "$idea_line"
  done < <(grep '"status":"qa-passed"\|"status": "qa-passed"' "$IDEAS_FILE" 2>/dev/null || true)
fi

echo ""
echo "═══════════════════════════════════════"
echo "Policy Gate Summary"
echo "  Processed:    $PROCESSED"
echo "  Auto-merged:  $AUTO_MERGED"
echo "  Blocked:      $BLOCKED"
echo "═══════════════════════════════════════"
