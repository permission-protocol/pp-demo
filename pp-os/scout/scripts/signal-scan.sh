#!/bin/bash
# Scout Signal Scanner — wrapper for cron
# This triggers an OpenClaw session that runs the actual scan using web_search + LLM
# 
# Usage: Called by cron every 4 hours
# The cron task prompt does the real work — this is just documentation

echo "Signal scan should run as an OpenClaw cron task, not a bash script."
echo "The cron prompt has access to web_search, web_fetch, gh CLI, and LLM scoring."
echo ""
echo "Register with:"
echo '  openclaw cron add --name "scout-signal-scan" --schedule "0 6,10,14,18 * * *" --prompt "$(cat ~/.openclaw/workspace/pp-os/scout/scripts/signal-scan-prompt.md)"'
