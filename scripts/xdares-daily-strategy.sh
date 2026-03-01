#!/bin/bash
# Daily Xdares Strategy Pipeline
# 1. Run rule-based recommendations (fast, deterministic)
# 2. Run R1 deep strategy analysis (slow, reasoning)
# 3. Output combined report
#
# Usage: xdares-daily-strategy.sh
# Dependencies: xdares-strategy-recommend.sh, strategy-r1-analyze.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GOAL_DIR="$HOME/.openclaw/workspace/goals/xdares-seo-growth"

echo "=== Xdares Daily Strategy Pipeline ==="
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Step 1: Rule-based recommendations
echo ""
echo "--- Step 1: Rule-based analysis ---"
if [ -f "$GOAL_DIR/metrics/latest.json" ]; then
    bash "$SCRIPT_DIR/xdares-strategy-recommend.sh" 2>&1
    echo "✅ Rule-based recommendations updated"
else
    echo "⚠️ No latest.json found — skipping rule-based analysis"
fi

# Step 2: R1 deep strategy — SHELVED (R1 just parrots rule-based output, no added value)
# To re-enable: uncomment and add R1 cron back (was xdares-r1-strategy, 18:30 daily)
# See strategy-r1-analyze.sh for the R1 script (still exists, just not called)

echo ""
echo "=== Pipeline Complete (rule-based only) ==="
echo "Recommendations: $GOAL_DIR/metrics/recommendations.json"
