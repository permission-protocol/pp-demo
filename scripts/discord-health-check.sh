#!/usr/bin/env bash

# Discord Health Check for OpenClaw
# Checks if the discord provider is active and responsive.

LOG_FILE="$HOME/.openclaw/logs/gateway.log"
TEST_CHANNEL="1479273618876792893" # #daily-log

echo "--- Discord Health Check ---"

# 1. Check config
if ! grep -q '"discord"' "$HOME/.openclaw/openclaw.json"; then
    echo "❌ Discord provider not found in openclaw.json"
    exit 1
fi

# 2. Check logs for recent activity
echo "Checking logs for Discord status..."
LAST_STATUS=$(grep -i "discord" "$LOG_FILE" | tail -n 5)
echo "$LAST_STATUS"

if echo "$LAST_STATUS" | grep -q "awaiting gateway readiness"; then
    echo "⚠️ Discord is stuck 'awaiting gateway readiness'. This usually requires a restart."
fi

if echo "$LAST_STATUS" | grep -q "stale-socket"; then
    echo "⚠️ Discord is experiencing 'stale-socket' restarts."
fi

# 3. Test tool accessibility
echo "Testing tool accessibility..."
RESULT=$(openclaw tool call message '{"action":"channel-info","channel":"discord","channelId":"'$TEST_CHANNEL'"}' 2>&1)

if echo "$RESULT" | grep -q "Unsupported channel"; then
    echo "❌ Discord provider NOT REGISTERED with message tool."
    echo "Suggested Action: openclaw gateway restart"
elif echo "$RESULT" | grep -q "error"; then
    echo "❌ Discord tool call failed: $RESULT"
else
    echo "✅ Discord provider is active and tool call succeeded."
fi

echo "---------------------------"
