#!/bin/bash
# Charles: Charles's Cron Health Report

# This script is called by Charles during nightly-self-improvement.
# It summarizes cron status from the tool output directly.

echo "## Cron Health Report - $(date)"
echo ""
echo "| Job | Status | Last Run | Duration | Result |"
echo "| :--- | :--- | :--- | :--- | :--- |"

# Note: This expects input from a file containing the JSON output of 'openclaw cron list'
JSON_FILE=$1

if [[ ! -f "$JSON_FILE" ]]; then
  echo "Usage: $0 <cron_list.json>"
  exit 1
fi

jq -r '.jobs[] | select(.enabled == true) | "| \(.name) | \(.state.lastStatus // "N/A") | \(.state.lastRunAtMs | if . then (. / 1000 | strftime("%Y-%m-%d %H:%M")) else "N/A" end) | \(.state.lastDurationMs // 0)ms | \(.state.lastRunStatus // "N/A") |"' "$JSON_FILE"

echo ""
echo "### Active Timeouts/Errors"
jq -r '.jobs[] | select(.enabled == true and .state.lastStatus == "error") | "- **\(.name)**: \(.state.lastError // "Unknown error") (Consecutive: \(.state.consecutiveErrors))"' "$JSON_FILE"
