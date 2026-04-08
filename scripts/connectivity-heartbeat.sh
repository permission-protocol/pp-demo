#!/bin/bash
# scripts/connectivity-heartbeat.sh
# Probes connectivity and logs status.

STATUS_FILE="/Users/moltbot/.openclaw/workspace/pp-os/scout/system-health.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[$TIMESTAMP] Running deep connectivity probe..." >> "$STATUS_FILE"

# Run deep status probe
DEEP_STATUS=$(openclaw status --deep 2>&1)

# Check for Discord/Telegram health
DISCORD_HEALTH=$(echo "$DEEP_STATUS" | grep -i "Discord" | grep -i "OK")
TELEGRAM_HEALTH=$(echo "$DEEP_STATUS" | grep -i "Telegram" | grep -i "OK")

if [[ -z "$DISCORD_HEALTH" ]]; then
  echo "[$TIMESTAMP] ALERT: Discord provider appears unhealthy or hung." >> "$STATUS_FILE"
  # We can't restart the gateway ourselves easily without breaking the session, 
  # but we can signal it.
  touch /Users/moltbot/.openclaw/workspace/pp-os/scout/DISCORD_HUNG
else
  rm -f /Users/moltbot/.openclaw/workspace/pp-os/scout/DISCORD_HUNG
  echo "[$TIMESTAMP] Discord OK." >> "$STATUS_FILE"
fi

if [[ -z "$TELEGRAM_HEALTH" ]]; then
  echo "[$TIMESTAMP] ALERT: Telegram provider appears unhealthy or hung." >> "$STATUS_FILE"
  touch /Users/moltbot/.openclaw/workspace/pp-os/scout/TELEGRAM_HUNG
else
  rm -f /Users/moltbot/.openclaw/workspace/pp-os/scout/TELEGRAM_HUNG
  echo "[$TIMESTAMP] Telegram OK." >> "$STATUS_FILE"
fi

echo "[$TIMESTAMP] Probe complete." >> "$STATUS_FILE"
