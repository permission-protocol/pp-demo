#!/bin/bash
# check-token-health.sh — Verifies GA4/SC token health and alerts if re-auth needed.
set -euo pipefail

TOKEN_FILE="$HOME/.openclaw/secrets/google-analytics-token.json"
DISCORD_CHANNEL="1479273618876792893" # #daily-log

get_google_token() {
    if [ ! -f "$TOKEN_FILE" ]; then
        echo "❌ No Google token file found at $TOKEN_FILE"
        return 1
    fi
    
    local refresh_token client_id client_secret
    refresh_token=$(python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['refresh_token'])" 2>/dev/null || echo "")
    client_id=$(python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['client_id'])" 2>/dev/null || echo "")
    client_secret=$(python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['client_secret'])" 2>/dev/null || echo "")
    
    if [[ -z "$refresh_token" || -z "$client_id" || -z "$client_secret" ]]; then
        echo "❌ Missing fields in $TOKEN_FILE"
        return 1
    fi

    local resp
    resp=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
        -d "refresh_token=$refresh_token&client_id=$client_id&client_secret=$client_secret&grant_type=refresh_token")
    
    if echo "$resp" | grep -q "error"; then
        echo "❌ Token refresh failed: $resp"
        return 1
    fi
    
    echo "✅ Token refresh successful."
    return 0
}

echo "🔍 Checking Xdares/PP token health..."
if ! get_google_token; then
    echo "🚨 TOKEN EXPIRED OR INVALID. Manual re-auth required."
    # We don't have a direct 'message' CLI here easily without openclaw, 
    # but since this runs as an 'agentTurn' in cron, the agent will see this output.
    exit 1
fi
