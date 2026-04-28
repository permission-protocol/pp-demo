#!/bin/bash
# scripts/decision-inbox.sh - Aggregates all pending approvals for Rod.

echo "### 📥 Pending Decision Inbox (Rod Approval Required)"
echo ""

# 1. Outreach Pending
if [ -d "pp-os/scout/outreach/pending" ]; then
    FILES=$(ls pp-os/scout/outreach/pending/*.md 2>/dev/null)
    if [ ! -z "$FILES" ]; then
        echo "#### Outreach Drafts"
        for f in $FILES; do
            NAME=$(basename "$f")
            AGE=$(perl -e 'print int((-M $ARGV[0]))' "$f")
            echo "- [ ] **$NAME** (Age: $AGE days) -> \`/approve $NAME\`"
        done
        echo ""
    fi
fi

# 2. Blocked Ideas from ideas.jsonl
for IDEAS_FILE in "pp-os/ideas.jsonl" "factory/ideas.jsonl"; do
    if [ -f "$IDEAS_FILE" ]; then
        echo "#### Blocked Strategic Ideas ($IDEAS_FILE)"
        # Use jq to parse JSONL
        if command -v jq &> /dev/null; then
            jq -r 'select(.status == "BLOCKED") | "- [ ] **\(.id)**: \(.title) (Blocker: \(.blocked_by)) -> `/unblock \(.id)`"' "$IDEAS_FILE"
        else
            grep '"status": "BLOCKED"' "$IDEAS_FILE" | while read -r line; do
                ID=$(echo "$line" | sed -n 's/.*"id": "\([^"]*\)".*/\1/p')
                TITLE=$(echo "$line" | sed -n 's/.*"title": "\([^"]*\)".*/\1/p')
                REASON=$(echo "$line" | sed -n 's/.*"blocked_by": "\([^"]*\)".*/\1/p')
                echo "- [ ] **$ID**: $TITLE (Blocker: $REASON) -> \`/unblock $ID\`"
            done
        fi
        echo ""
    fi
done

# 3. Pull Request Approvals (if any)
if command -v gh &> /dev/null; then
    PR_LIST=$(gh pr list --label "ready" --json number,title --template '{{range .}}{{.number}} {{.title}}{{"\n"}}{{end}}')
    if [ ! -z "$PR_LIST" ]; then
        echo "#### PRs Ready for Merge"
        echo "$PR_LIST" | while read -r num title; do
            echo "- [ ] **#$num**: $title -> \`/merge $num\`"
        done
        echo ""
    fi
fi

echo "---"
echo "Total Pending: $(($(ls pp-os/scout/outreach/pending/*.md 2>/dev/null | wc -l) + $(grep -c '"status":"BLOCKED"' ideas.jsonl 2>/dev/null || echo 0)))"
