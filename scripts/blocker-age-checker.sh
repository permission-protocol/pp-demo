#!/bin/bash
# scripts/blocker-age-checker.sh - Find and flag stale BLOCKED items in ideas.jsonl
# Outputs a summary of items blocked for > 48 hours.

IDEAS_FILE="/Users/moltbot/.openclaw/workspace/pp-os/ideas.jsonl"
THRESHOLD_DAYS=2
CURRENT_DATE=$(date +%Y-%m-%d)
THRESHOLD_EPOCH=$(date -v-${THRESHOLD_DAYS}d +%s)

echo "### Stale Blocker Audit ($CURRENT_DATE)"
echo "Checking for items BLOCKED for more than $THRESHOLD_DAYS days..."

# Use jq to filter blocked items and check their update date
# Note: This requires jq.
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

STALE_COUNT=0
while read -r line; do
    ID=$(echo "$line" | jq -r '.id')
    TITLE=$(echo "$line" | jq -r '.title')
    STATUS=$(echo "$line" | jq -r '.status')
    UPDATED=$(echo "$line" | jq -r '.updated')
    BLOCKED_BY=$(echo "$line" | jq -r '.blocked_by')
    
    if [ "$STATUS" == "BLOCKED" ]; then
        # Check if UPDATED is older than THRESHOLD_DAYS
        # Converting date to epoch for comparison (macOS date format)
        UPDATED_EPOCH=$(date -j -f "%Y-%m-%d" "$UPDATED" "+%s" 2>/dev/null)
        if [ $? -ne 0 ]; then continue; fi # Skip if date format is weird
        
        if [ "$UPDATED_EPOCH" -lt "$THRESHOLD_EPOCH" ]; then
            echo "- **$ID ($TITLE)**: Blocked by \"$BLOCKED_BY\" since $UPDATED"
            STALE_COUNT=$((STALE_COUNT + 1))
        fi
    fi
done < "$IDEAS_FILE"

if [ "$STALE_COUNT" -eq 0 ]; then
    echo "No stale blocked items found."
else
    echo "Total stale blockers: $STALE_COUNT"
fi
