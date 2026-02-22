#!/bin/bash
# Health check script for Charles
# Run this if you suspect I'm having issues

set -e

echo "🦞 Charles Health Check"
echo "======================"

# Check OpenClaw status
echo "1. OpenClaw Gateway..."
if openclaw status >/dev/null 2>&1; then
    echo "   ✅ Gateway running"
else
    echo "   ❌ Gateway issues detected"
    exit 1
fi

# Check for cooldowns
echo "2. Provider Cooldowns..."
COOLDOWN=$(openclaw doctor --repair 2>&1 | grep -i "disabled:billing\|cooldown" || echo "none")
if [[ "$COOLDOWN" == "none" ]]; then
    echo "   ✅ No cooldowns"
else
    echo "   ⚠️  Cooldown detected: $COOLDOWN"
fi

# Check API key works
echo "3. API Key Test..."
RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $(cat ~/.openclaw/secrets/anthropic-api-key.txt)" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' 2>/dev/null)

if echo "$RESPONSE" | grep -q '"role":"assistant"'; then
    echo "   ✅ API key working"
else
    echo "   ❌ API key issues: $(echo "$RESPONSE" | head -1)"
fi

# Check memory search
echo "4. Memory Search..."
if openclaw memory status | grep -q "Vector: ready"; then
    echo "   ✅ Memory search ready"
else
    echo "   ⚠️  Memory search issues"
fi

echo ""
echo "🎷 Overall: $([ "$COOLDOWN" == "none" ] && echo "HEALTHY" || echo "NEEDS ATTENTION")"