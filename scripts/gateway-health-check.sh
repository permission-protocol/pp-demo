#!/usr/bin/env bash
# scripts/gateway-health-check.sh
# Restarts the OpenClaw gateway if persistent delivery failures are detected.

LOG_FILE="/Users/moltbot/.openclaw/workspace/memory/connectivity-diagnostics.log"
FAILURE_THRESHOLD=3

if [[ ! -f "$LOG_FILE" ]]; then
  exit 0
fi

# Count recent consecutive delivery failures (Discord/Telegram)
# We look for "Message failed" or provider-specific errors in the last 10 lines of the log
FAILURES=$(tail -n 20 "$LOG_FILE" | grep -c "Message failed" || true)

if [[ "$FAILURES" -ge "$FAILURE_THRESHOLD" ]]; then
  echo "Detected $FAILURES consecutive delivery failures. Restarting gateway..."
  openclaw gateway restart --reason "Persistent delivery failure detected by health check."
  # Clear log or mark as resolved to avoid loop
  echo "$(date) - Gateway restarted due to delivery failures." >> "$LOG_FILE"
fi
