#!/bin/bash
# scripts/connectivity-check.sh - Diagnostic script for external API endpoints
# Used by Charles to monitor persistent blockers in STATUS.md

LOG_FILE="/Users/moltbot/.openclaw/workspace/memory/connectivity-diagnostics.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "--- Diagnostic Run: $TIMESTAMP ---" >> "$LOG_FILE"

# 1. Paperclip Port 3100 (via Tailscale)
echo "Checking Paperclip (100.122.174.112:3100)..." >> "$LOG_FILE"
timeout 5 nc -zv 100.122.174.112 3100 2>&1 >> "$LOG_FILE"

# 2. X API (Write perms test - simple check of existing endpoint)
# Note: Full write test requires Oauth/secret tokens, so we just log the config presence for now.
# Real test should use a simple status/update call to a private account.
echo "Checking X API config presence..." >> "$LOG_FILE"
if [ -f "/Users/moltbot/.openclaw/secrets/x-api.json" ]; then
  echo "X API secret file exists." >> "$LOG_FILE"
else
  echo "X API secret file MISSING." >> "$LOG_FILE"
fi

# 3. PostHog (Check if endpoint is reachable)
echo "Checking PostHog (app.posthog.com)..." >> "$LOG_FILE"
curl -s -o /dev/null -w "%{http_code}" https://app.posthog.com/health >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "Done." >> "$LOG_FILE"
