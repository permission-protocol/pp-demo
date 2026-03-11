#!/bin/bash
# PR Pre-Screen Cron — auto-review open PRs to main that haven't been screened.
# Checks for open PRs without a "🔍 PR Pre-Screen" comment, runs prescreen, posts results.
#
# Usage: pr-prescreen-cron.sh [owner/repo]
# Default repo: permission-protocol/app

set -uo pipefail

REPO="${1:-permission-protocol/app}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="🔍 PR Pre-Screen"
REVIEWED=0
SKIPPED=0

export GH_TOKEN="${GH_TOKEN:-$(cat ~/.openclaw/secrets/github-pat-projects.txt 2>/dev/null)}"

echo "=== PR Pre-Screen Cron: $REPO ==="
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Get open PRs targeting main
PRS=$(gh pr list -R "$REPO" --base main --state open --json number,title --limit 10 2>/dev/null)
if [ -z "$PRS" ] || [ "$PRS" = "[]" ]; then
    echo "No open PRs to main."
    exit 0
fi

PR_NUMBERS=$(echo "$PRS" | python3 -c "import json,sys; [print(p['number']) for p in json.load(sys.stdin)]" 2>/dev/null)

for PR_NUM in $PR_NUMBERS; do
    # Check if already screened (look for marker comment)
    HAS_REVIEW=$(gh pr view "$PR_NUM" -R "$REPO" --json comments --jq ".comments[] | select(.body | contains(\"$MARKER\")) | .id" 2>/dev/null | head -1)
    
    if [ -n "$HAS_REVIEW" ]; then
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    PR_TITLE=$(echo "$PRS" | python3 -c "import json,sys; [print(p['title']) for p in json.load(sys.stdin) if p['number']==$PR_NUM]" 2>/dev/null)
    echo ""
    echo "--- Screening #$PR_NUM: $PR_TITLE ---"
    
    # Run prescreen
    RESULT=$(bash "$SCRIPT_DIR/pr-prescreen.sh" "$REPO" "$PR_NUM" 2>/dev/null)
    EXIT_CODE=$?
    
    if [ -z "$RESULT" ]; then
        echo "⚠️ No output from prescreen for #$PR_NUM"
        continue
    fi
    
    # Build comment
    COMMENT=$(python3 -c "
import json, sys

try:
    report = json.loads('''$( echo "$RESULT" | python3 -c "import json,sys,re; raw=sys.stdin.read().strip(); m=re.search(r'\{.*\}',raw,re.DOTALL); print(json.dumps(json.loads(m.group())) if m else '{}')" 2>/dev/null )''')
except:
    report = {}

lint = report.get('tier1_lint', {})
logic = report.get('tier2_logic', {})
lint_findings = lint.get('findings', [])
logic_findings = logic.get('findings', [])
approval = report.get('overall', {}).get('approval', 'comment')
summary = report.get('overall', {}).get('summary', 'Review complete')

lines = ['## $MARKER', '']

if not lint_findings and not logic_findings:
    lines.append('✅ **No issues found** — clean PR.')
    lines.append('')
    lines.append(f'> {summary}')
else:
    if lint_findings:
        lines.append('### Tier 1: Quick Lint (Llama 8B)')
        lines.append(f'⏱️ {lint.get(\"time_seconds\", \"?\"):.1f}s')
        lines.append('')
        for f in lint_findings:
            sev = f.get('severity','?')
            icon = '🔴' if sev == 'high' else '🟡' if sev == 'medium' else '⚪'
            lines.append(f'{icon} **[{sev.upper()}]** \`{f.get(\"file\",\"?\")}\`: {f.get(\"issue\",\"\")}')
        lines.append('')
    
    if logic_findings:
        lines.append('### Tier 2: Deep Logic Review (R1 70B)')
        lines.append(f'⏱️ {logic.get(\"time_seconds\", \"?\"):.1f}s')
        lines.append('')
        for f in logic_findings:
            sev = f.get('severity','?')
            icon = '🔴' if sev in ('critical','high') else '🟡' if sev == 'medium' else '⚪'
            lines.append(f'{icon} **[{sev.upper()}]** \`{f.get(\"file\",\"?\")}\`: {f.get(\"issue\",\"\")}')
            if f.get('suggestion'):
                lines.append(f'  💡 {f[\"suggestion\"]}')
        lines.append('')
    
    lines.append(f'**Recommendation:** {approval.replace(\"_\", \" \").title()}')
    lines.append(f'> {summary}')

lines.append('')
lines.append('---')
lines.append('*Automated review by Charles (Llama 8B + DeepSeek R1 70B on DGX Spark)*')

print('\n'.join(lines))
" 2>/dev/null)
    
    if [ -z "$COMMENT" ]; then
        echo "⚠️ Could not build comment for #$PR_NUM"
        continue
    fi
    
    # Post comment
    gh pr comment "$PR_NUM" -R "$REPO" --body "$COMMENT" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Posted review on #$PR_NUM"
        REVIEWED=$((REVIEWED + 1))
    else
        echo "❌ Failed to post comment on #$PR_NUM"
    fi
done

echo ""
echo "=== Done: $REVIEWED reviewed, $SKIPPED already screened ==="
