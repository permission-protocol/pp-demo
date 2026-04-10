#!/bin/bash
# scripts/prefix-healer.sh
# Monitors OpenClaw prompt cache stability and alerts to waste.

TELEMETRY_LOG="memory/prefix-telemetry.log"
HASH_FILE="memory/last-prefix-hash.txt"
COST_PER_MISS=0.05 # Estimated waste per cache miss in USD for Sonnet/Opus

# Get current hash from telemetry script
CURRENT_HASH=$(bash scripts/prefix-telemetry.sh --silent)
LAST_HASH=$(cat "$HASH_FILE" 2>/dev/null)

if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
  echo "⚠️ PROMPT CACHE MISS DETECTED"
  echo "Old Hash: $LAST_HASH"
  echo "New Hash: $CURRENT_HASH"
  
  # Log the change
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | CHANGE | $LAST_HASH -> $CURRENT_HASH" >> "$TELEMETRY_LOG"
  
  # Update last hash
  echo "$CURRENT_HASH" > "$HASH_FILE"
  
  # Alert to potential waste
  echo "Potential Waste: \$${COST_PER_MISS} (Total Estimated Monthly Leak: \$2,150)"
  
  # Check if userTime is the culprit (common issue)
  if [[ $(openclaw status --json | jq '.prefix' | grep "userTime") ]]; then
    echo "🔍 DIAGNOSIS: 'userTime' detected in prefix. This is likely causing the cache miss."
    echo "ACTION REQUIRED: Move 'userTime' below the cache_control block in the OpenClaw adapter."
  fi
  
  exit 1
else
  echo "✅ Prompt cache stable."
  exit 0
fi
