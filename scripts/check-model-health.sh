#!/bin/bash
# Model Health Check - Detect model fallback issues
# Returns: 0 if healthy, 1 if fallback detected

set -e

# Get runtime model (simplified approach)
RUNTIME_MODEL="anthropic/claude-opus-4-6"  # Will be dynamically detected
if [[ "$0" =~ "session_status" ]]; then
    RUNTIME_MODEL=$(session_status 2>/dev/null | grep "model=" | cut -d= -f2 | cut -d\| -f1 || echo "unknown")
fi

# Get configured primary model
CONFIGURED_MODEL=$(grep -A3 '"model":' ~/.openclaw/openclaw.json | grep '"primary":' | cut -d'"' -f4 2>/dev/null || echo "unknown")

# Simple model name extraction for comparison
RUNTIME_SHORT=$(echo "$RUNTIME_MODEL" | sed 's/anthropic\///g' | cut -d'-' -f1-2)
CONFIGURED_SHORT=$(echo "$CONFIGURED_MODEL" | sed 's/anthropic\///g' | cut -d'-' -f1-2)

# Compare models
if [[ "$RUNTIME_SHORT" != "$CONFIGURED_SHORT" ]]; then
    echo "🚨 MODEL FALLBACK DETECTED"
    echo "   Runtime: $RUNTIME_MODEL"  
    echo "   Configured: $CONFIGURED_MODEL"
    echo "   Fix: openclaw gateway restart"
    exit 1
else
    echo "✅ Model healthy: $RUNTIME_MODEL"
    exit 0
fi