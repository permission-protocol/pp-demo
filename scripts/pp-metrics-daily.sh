#!/bin/bash

# Daily Permission Protocol Metrics Report
# Counts access requests and reports trends

set -e

LOG_FILE="logs/pp-metrics.log"
DATE=$(date '+%Y-%m-%d')
YESTERDAY=$(date -d "yesterday" '+%Y-%m-%d')

# Ensure log directory exists
mkdir -p logs

echo "[$DATE] Starting PP metrics collection..." | tee -a "$LOG_FILE"

# Check Gmail for Formspree notifications (using gog)
echo "Checking Gmail for Formspree notifications..." | tee -a "$LOG_FILE"

# Count today's Formspree emails
TODAY_COUNT=$(gog gmail search "from:noreply@formspree.io after:$(date '+%Y/%m/%d')" --format=json 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")

# Count yesterday's Formspree emails  
YESTERDAY_COUNT=$(gog gmail search "from:noreply@formspree.io after:$(date -d "yesterday" '+%Y/%m/%d') before:$(date '+%Y/%m/%d')" --format=json 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")

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

# For now, just output the report (will be sent by cron handler)
echo "TELEGRAM_MESSAGE_START"
echo "$REPORT"
echo "TELEGRAM_MESSAGE_END"

echo "[$DATE] PP metrics collection completed" | tee -a "$LOG_FILE"