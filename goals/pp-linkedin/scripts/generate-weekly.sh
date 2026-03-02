#!/bin/bash
# Generate weekly LinkedIn drafts for PP
# Called by cron every Sunday 8 AM MST
# Outputs drafts to goals/pp-linkedin/drafts/week-of-YYYY-MM-DD.md
# Sends Telegram notification for review

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
PP_DIR="$WORKSPACE/goals/pp-linkedin"
SCRIPTS_DIR="$PP_DIR/scripts"
DRAFTS_DIR="$PP_DIR/drafts"

# Calculate next Monday's date for the filename
NEXT_MONDAY=$(date -v+1d -j -f "%u" "1" +%Y-%m-%d 2>/dev/null || date -d "next monday" +%Y-%m-%d)
DRAFT_FILE="$DRAFTS_DIR/week-of-${NEXT_MONDAY}.md"

# Calculate schedule dates (Mon/Wed/Fri at 9am MST = 4pm UTC)
MON_DATE="${NEXT_MONDAY}T16:00:00.000Z"
WED_DATE=$(date -v+2d -j -f "%Y-%m-%d" "$NEXT_MONDAY" +%Y-%m-%d 2>/dev/null || date -d "$NEXT_MONDAY + 2 days" +%Y-%m-%d)
WED_DATE="${WED_DATE}T16:00:00.000Z"
FRI_DATE=$(date -v+4d -j -f "%Y-%m-%d" "$NEXT_MONDAY" +%Y-%m-%d 2>/dev/null || date -d "$NEXT_MONDAY + 4 days" +%Y-%m-%d)
FRI_DATE="${FRI_DATE}T16:00:00.000Z"

echo "Generating drafts for week of $NEXT_MONDAY"
echo "Schedule: Mon=$MON_DATE, Wed=$WED_DATE, Fri=$FRI_DATE"

# Gather inputs
RAW_IDEAS=$(cat "$PP_DIR/raw-ideas.md" 2>/dev/null || echo "No raw ideas file")
VOICE_GUIDE=$(cat "$SCRIPTS_DIR/weekly-drafts-prompt.md")
HUMANIZE_GUIDE=$(cat "$SCRIPTS_DIR/humanize-prompt.md")

# Get recent AI incident news for hooks
echo "Scanning recent AI incidents..."
INCIDENTS=$(curl -s "https://api.search.brave.com/res/v1/web/search?q=AI+agent+incident+autonomous+code+deploy+2026&count=5" \
  -H "Accept: application/json" \
  -H "Accept-Encoding: gzip" \
  -H "X-Subscription-Token: ${BRAVE_API_KEY:-}" 2>/dev/null | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    for r in d.get('web',{}).get('results',[])[:5]:
        print(f'- {r[\"title\"]}: {r.get(\"description\",\"\")[:100]}')
except: print('No recent incidents found')
" 2>/dev/null || echo "No recent incidents found")

echo "Incidents: $INCIDENTS"

# Store context for the cron session to use
cat > "$DRAFTS_DIR/.generation-context.md" << CONTEXT
# Weekly Draft Generation Context

## Week of: $NEXT_MONDAY
## Schedule Dates
- Monday: $MON_DATE
- Wednesday: $WED_DATE
- Friday: $FRI_DATE

## Raw Ideas (new fragments at bottom of file)
$RAW_IDEAS

## Recent AI Incidents
$INCIDENTS

## Voice Guide
$VOICE_GUIDE

## Humanize Rules
$HUMANIZE_GUIDE

## Published History (avoid repeating)
$(tail -20 "$PP_DIR/published.md" 2>/dev/null || echo "No history yet")
CONTEXT

echo "Context file written to $DRAFTS_DIR/.generation-context.md"
echo "READY_FOR_LLM"
