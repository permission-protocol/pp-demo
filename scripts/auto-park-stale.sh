#!/bin/bash
# scripts/auto-park-stale.sh — Moves items > 10 days old from BLOCKED/ROD ACTION to PARKED
set -euo pipefail

STATUS_FILE="pp-os/STATUS.md"
THRESHOLD=10

# We'll use a temporary file to rebuild the status
# This is a bit complex for a shell script, so we'll do a simple grep/sed 
# approach to move lines.

echo "🔍 Pruning items older than $THRESHOLD days..."

# Identify items to move
STALE_ITEMS=$(grep -E "\(([A-Z][a-z]{2}) [0-9]+, ([0-9]+) days\)" "$STATUS_FILE" | grep -v "Recently Shipped" || true)

while IFS= read -r line; do
    if [[ $line =~ ([0-9]+)\ days ]]; then
        days="${BASH_REMATCH[1]}"
        if [[ $days -ge $THRESHOLD ]]; then
            echo "📦 Parking: $line"
            # Remove from current location
            sed -i '' "/$(echo "$line" | sed 's/[^^]/[&]/g; s/\^/\\^/g')/d" "$STATUS_FILE"
            # Append to Backlog/Parked section
            # We assume there's a Backlog section. We'll append to the end for now.
            echo "$line — PARKED (Auto-pruned after $days days)" >> "$STATUS_FILE"
        fi
    fi
done <<< "$STALE_ITEMS"

echo "✅ Pruning complete."
