#!/bin/bash
# scripts/cron-watchdog.sh
# Monitors OpenClaw cron health and alerts Rod to persistent failures.

CRON_LIST=$(openclaw cron list --json)
DATE=$(date)

echo "--- OpenClaw Cron Watchdog Report ($DATE) ---"

# Extract jobs with consecutiveErrors >= 3
FAILING_JOBS=$(echo "$CRON_LIST" | jq -r '.jobs[] | select(.state?.consecutiveErrors? >= 3) | "- \(.name) (\(.id)): \(.state.consecutiveErrors) consecutive errors. Last: \(.state.lastError)"')

if [ -n "$FAILING_JOBS" ]; then
  echo "⚠️ PERSISTENT CRON FAILURES DETECTED:"
  echo "$FAILING_JOBS"
  
  # Check specifically for mobile-qa-daily
  if echo "$FAILING_JOBS" | grep -q "mobile-qa-daily"; then
    echo ""
    echo "🔍 MOBILE-QA-DAILY DIAGNOSIS:"
    echo "Failure likely due to missing iPhone connection. Please check USB cable and ensure the device is unlocked."
  fi
  
  # Check for 'Unsupported channel' errors
  if echo "$FAILING_JOBS" | grep -q "Unsupported channel"; then
    echo ""
    echo "🔍 CHANNEL ERROR DIAGNOSIS:"
    echo "Some crons are targeting 'telegram' or 'discord' but the channel is not supported or configured. Check gateway config."
  fi

  # Exit with error to ensure the run is flagged as failed (this watchdog itself is a cron)
  exit 1
else
  echo "✅ All crons healthy."
  exit 0
fi
