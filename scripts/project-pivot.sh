#!/bin/bash
# scripts/project-pivot.sh
# Automates the context archival and workspace setup for a project pivot.
# Usage: ./project-pivot.sh <old-name> <new-name>

OLD_NAME=$1
NEW_NAME=$2

if [[ -z "$OLD_NAME" || -z "$NEW_NAME" ]]; then
  echo "Usage: ./project-pivot.sh <old-name> <new-name>"
  exit 1
fi

echo "🚀 Pivoting $OLD_NAME to $NEW_NAME..."

# 1. Create new workspace directory
mkdir -p "$NEW_NAME"

# 2. Archival (simulated for now, would move files/configs)
echo "📦 Archiving context for $OLD_NAME..."
# mv "$OLD_NAME" "archive/$OLD_NAME-$(date +%Y-%m-%d)"

# 3. Update status (simulated)
echo "📝 Update STATUS.md files manually or via sub-agent."

echo "✅ Pivot complete. Workspace at $NEW_NAME/"
