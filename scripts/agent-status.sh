#!/bin/bash
# Agent Status Monitor — check progress of background coding agents
# Usage: agent-status.sh [session-id|all]
#
# Each agent should write status to /tmp/agent-status-<issue>.json
# This script reads those files and summarizes.

set -uo pipefail

TARGET="${1:-all}"

if [ "$TARGET" = "all" ]; then
    # Show all active agent status files
    found=0
    for f in /tmp/agent-status-*.json; do
        [ -f "$f" ] || continue
        found=1
        echo "=== $(basename "$f" .json | sed 's/agent-status-//') ==="
        cat "$f"
        echo ""
    done
    
    if [ "$found" -eq 0 ]; then
        echo "No active agent status files found."
        echo ""
        echo "Running codex processes:"
        ps aux | grep codex | grep -v grep | awk '{print $2, $11, $12}' || echo "  none"
    fi
else
    f="/tmp/agent-status-${TARGET}.json"
    if [ -f "$f" ]; then
        cat "$f"
    else
        echo "No status file for $TARGET"
        echo "Check process: ps aux | grep codex"
    fi
fi

# Also show git status of worktrees
echo ""
echo "=== Worktree commits ==="
for d in /tmp/pp-* /tmp/bl-* /tmp/deploy-gate-* /tmp/brand-lib-*; do
    [ -d "$d/.git" ] || [ -f "$d/.git" ] || continue
    LAST=$(cd "$d" && git log --oneline -1 2>/dev/null)
    DIRTY=$(cd "$d" && git status --short 2>/dev/null | wc -l | tr -d ' ')
    echo "$(basename $d): $LAST (${DIRTY} uncommitted)"
done
