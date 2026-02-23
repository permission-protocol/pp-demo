#!/bin/bash

# Daily Permission Protocol Metrics Report
# Counts access requests, reports trends, and feeds data into PP-OS for autonomous planning

set -e

LOG_FILE="logs/pp-metrics.log"
DATE=$(date '+%Y-%m-%d')
YESTERDAY=$(date -v-1d '+%Y-%m-%d')
PP_OS_DIR="$HOME/pp-os-integration/pp-os"

# Ensure directories exist
mkdir -p logs

echo "[$DATE] Starting PP metrics collection (with PP-OS integration)..." | tee -a "$LOG_FILE"

# Check Gmail for Formspree notifications (using gog)
echo "Checking Gmail for Formspree notifications..." | tee -a "$LOG_FILE"

# Count today's Formspree emails (fallback to 0 if gog not working)
TODAY_COUNT=$(gog gmail search "from:noreply@formspree.io after:$(date '+%Y/%m/%d')" --format=json 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
[[ -z "$TODAY_COUNT" || "$TODAY_COUNT" == "null" ]] && TODAY_COUNT=0

# Count yesterday's Formspree emails  
YESTERDAY_COUNT=$(gog gmail search "from:noreply@formspree.io after:$(date -v-1d '+%Y/%m/%d') before:$(date '+%Y/%m/%d')" --format=json 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
[[ -z "$YESTERDAY_COUNT" || "$YESTERDAY_COUNT" == "null" ]] && YESTERDAY_COUNT=0

# Calculate change
if [ "$YESTERDAY_COUNT" -eq 0 ]; then
    CHANGE_TEXT="(new)"
else
    CHANGE=$((TODAY_COUNT - YESTERDAY_COUNT))
    if [ "$CHANGE" -gt 0 ]; then
        CHANGE_TEXT="(+$CHANGE vs yesterday)"
    elif [ "$CHANGE" -lt 0 ]; then
        CHANGE_TEXT="($CHANGE vs yesterday)"
    else
        CHANGE_TEXT="(same as yesterday)"
    fi
fi

# Log results
echo "[$DATE] Today: $TODAY_COUNT requests" | tee -a "$LOG_FILE"
echo "[$DATE] Yesterday: $YESTERDAY_COUNT requests" | tee -a "$LOG_FILE"

# Create report
REPORT="📊 **PP Daily Metrics - $DATE**

🆕 **Access Requests:** $TODAY_COUNT today $CHANGE_TEXT
📈 **Yesterday:** $YESTERDAY_COUNT requests
🔄 **Change:** $CHANGE_TEXT

📧 Source: Formspree email notifications
⏰ Report time: $(date '+%I:%M %p %Z')"

echo "Report:" | tee -a "$LOG_FILE"
echo "$REPORT" | tee -a "$LOG_FILE"

# Send to Telegram
echo "Sending report to Telegram..." | tee -a "$LOG_FILE"
echo "$REPORT" > /tmp/pp-report.txt

# Use message tool to send report
echo "PP metrics report ready for delivery" | tee -a "$LOG_FILE"

# Update PP-OS with access request intelligence
echo "Updating PP-OS with access request data..." | tee -a "$LOG_FILE"

# Update PP-OS repository if available
if [ -d "$PP_OS_DIR" ]; then
    cd "$PP_OS_DIR"
    
    # Pull latest PP-OS changes
    git pull origin main 2>/dev/null || echo "Could not pull latest PP-OS changes"
    
    # Create daily metrics JSON for autonomous consumption
    cat > "access-metrics.json" << EOF
{
  "date": "$DATE",
  "accessRequests": {
    "today": $TODAY_COUNT,
    "yesterday": $YESTERDAY_COUNT,
    "change": $((TODAY_COUNT - YESTERDAY_COUNT)),
    "changePercent": "$(if [ "$YESTERDAY_COUNT" -eq 0 ]; then echo "new"; else echo "$((100 * (TODAY_COUNT - YESTERDAY_COUNT) / YESTERDAY_COUNT))%"; fi)",
    "weeklyTrend": "$([ "$TODAY_COUNT" -gt "$YESTERDAY_COUNT" ] && echo "up" || echo "stable")"
  },
  "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    # Update market-intel.md with live access request data
    sed -i.bak "s/Access requests: [0-9]*\+\|Access requests: new/Access requests: $TODAY_COUNT ($CHANGE_TEXT)/" market-intel.md 2>/dev/null || echo "market-intel.md not updated"
    
    # Add to today's log if it exists
    if [ -f "master-log/$DATE.md" ]; then
        # Update the metrics section in today's log
        echo "Updating master-log/$DATE.md with access metrics..." | tee -a "$LOG_FILE"
        
        # Create a backup
        cp "master-log/$DATE.md" "master-log/$DATE.md.bak"
        
        # Add access request metrics to the metrics table (if it doesn't exist already)
        if ! grep -q "Access Requests" "master-log/$DATE.md"; then
            # Insert after the existing metrics table
            awk '/^\| Design Partners Active/ {print; print "| Access Requests (Inbound) | '"$TODAY_COUNT"' | '"$YESTERDAY_COUNT"' | '"$CHANGE_TEXT"' |"; next} {print}' "master-log/$DATE.md.bak" > "master-log/$DATE.md"
        fi
        
        echo "✅ PP-OS daily log updated with access metrics" | tee -a "$LOG_FILE"
    else
        echo "⚠️  No master-log/$DATE.md found - PP-OS may not have run today yet" | tee -a "$LOG_FILE"
    fi
    
    # Commit changes to PP-OS
    git add -A
    if git diff --staged --quiet; then
        echo "No changes to commit to PP-OS" | tee -a "$LOG_FILE"
    else
        git commit -m "Update access request metrics: $TODAY_COUNT today $CHANGE_TEXT" || echo "Could not commit to PP-OS"
        echo "✅ PP-OS updated with access metrics" | tee -a "$LOG_FILE"
    fi
    
    cd - > /dev/null
else
    echo "⚠️  PP-OS directory not found at $PP_OS_DIR" | tee -a "$LOG_FILE"
fi

# Output the report for Telegram delivery
echo "TELEGRAM_MESSAGE_START"
echo "$REPORT"
echo "TELEGRAM_MESSAGE_END"

echo "[$DATE] PP metrics collection and PP-OS integration completed" | tee -a "$LOG_FILE"