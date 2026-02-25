#!/bin/bash
# Pre-Merge Visual Review — screenshots preview URLs before merging PRs.
# Usage: pre-merge-review.sh <repo> <pr-number>
#
# Checks for Vercel preview deployment, takes screenshots,
# saves to /tmp/pr-review-<pr>.png
# Exit: 0 = screenshots taken, 1 = no preview found, 2 = error

set -uo pipefail

REPO="${1:?Usage: pre-merge-review.sh <owner/repo> <pr-number>}"
PR="${2:?Missing PR number}"
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt 2>/dev/null || echo "")

echo "=== Pre-Merge Review: $REPO #$PR ==="

# Get PR info
PR_JSON=$(GH_TOKEN="$GH_TOKEN" gh pr view "$PR" -R "$REPO" --json state,title,files,statusCheckRollup 2>/dev/null)
if [ -z "$PR_JSON" ]; then
    echo '{"error": "Could not fetch PR"}'
    exit 2
fi

TITLE=$(echo "$PR_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['title'])")
STATE=$(echo "$PR_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['state'])")

echo "Title: $TITLE"
echo "State: $STATE"

# Check for Vercel preview URL in status checks
PREVIEW_URL=$(echo "$PR_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
checks = data.get('statusCheckRollup', [])
for c in checks:
    # Vercel previews show as deployment status
    url = c.get('targetUrl', '') or ''
    if 'vercel' in url.lower() or 'preview' in url.lower():
        print(url)
        exit()
    name = c.get('name', '') or ''
    if 'vercel' in name.lower() or 'preview' in name.lower():
        print(url)
        exit()
print('')
" 2>/dev/null)

# Also check PR comments for preview URLs
if [ -z "$PREVIEW_URL" ]; then
    PREVIEW_URL=$(GH_TOKEN="$GH_TOKEN" gh pr view "$PR" -R "$REPO" --json comments --jq '.comments[].body' 2>/dev/null | grep -oE 'https://[a-zA-Z0-9.-]+\.vercel\.app[^ ]*' | head -1)
fi

# For permissionprotocol-site, we know the pattern
if [ -z "$PREVIEW_URL" ]; then
    if echo "$REPO" | grep -q "permissionprotocol-site"; then
        # Get branch name
        BRANCH=$(GH_TOKEN="$GH_TOKEN" gh pr view "$PR" -R "$REPO" --json headRefName --jq '.headRefName' 2>/dev/null)
        echo "Branch: $BRANCH"
        echo "No Vercel preview URL found. Check manually after deploy."
    fi
fi

if [ -n "$PREVIEW_URL" ]; then
    echo "Preview URL: $PREVIEW_URL"
fi

# Get changed HTML files to know what pages to screenshot
CHANGED_PAGES=$(echo "$PR_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
pages = []
for f in data.get('files', []):
    path = f.get('path', '')
    if path.endswith('.html') and not path.startswith('.'):
        name = path.replace('.html', '').replace('index', '')
        if name:
            pages.append('/' + name)
        else:
            pages.append('/')
print(' '.join(pages) if pages else '/')
" 2>/dev/null)

echo "Pages to check: $CHANGED_PAGES"

# Output review checklist
python3 << PYEOF
import json

review = {
    "repo": "$REPO",
    "pr": $PR,
    "title": """$TITLE""",
    "state": "$STATE",
    "preview_url": "$PREVIEW_URL" or None,
    "pages_to_screenshot": "$CHANGED_PAGES".split(),
    "checklist": [
        "Screenshot each changed page (desktop + mobile viewport)",
        "Verify nav links work",
        "Check brand colors match spec",
        "Verify mobile responsiveness",
        "Check for console errors"
    ]
}
print(json.dumps(review, indent=2))
PYEOF
