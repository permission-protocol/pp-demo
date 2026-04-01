#!/bin/bash
# scripts/cron-audit.sh
# Proactively identifies and notifies about failing crons.

# 1. Fetch failing crons (this is hard without a direct CLI to get the status log)
# For now, we'll scan the most recent heartbeats or the main log.
LOG_FILE="$HOME/.openclaw/logs/gateway.log"
FAILING_CRONS=$(grep "cron" "$LOG_FILE" | tail -n 1000 | grep "failed\|unsupported" | awk -F' ' '{print $NF}' | sort | uniq -c | sort -nr)

echo "--- Cron Audit Report ---"
echo "Date: $(date)"

if [ -z "$FAILING_CRONS" ]; then
  echo "✅ No failing crons detected in last 1k log entries."
else
  echo "⚠️ Failing Crons Detected:"
  echo "$FAILING_CRONS"
  
  # List all crons for easy review
  echo "--- Current Cron List ---"
  openclaw cron list
fi

echo "-------------------------------"
echo "Action: If 'Unsupported channel' exists, check plugins config. If 'Rate limited', increase interval or switch to cheaper model."
