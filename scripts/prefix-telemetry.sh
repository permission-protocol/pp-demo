#!/bin/bash
# scripts/prefix-telemetry.sh
# Hashes the static prompt components to detect cache-busting changes.

WORKSPACE_DIR="/Users/moltbot/.openclaw/workspace"
STABLE_FILES=(
  "$WORKSPACE_DIR/AGENTS.md"
  "$WORKSPACE_DIR/TOOLS.md"
  "$WORKSPACE_DIR/SOUL.md"
  "$WORKSPACE_DIR/USER.md"
  "$WORKSPACE_DIR/IDENTITY.md"
)

echo "--- Prompt Prefix Telemetry ---"
echo "Date: $(date)"

for FILE in "${STABLE_FILES[@]}"; do
  if [ -f "$FILE" ]; then
    MD5=$(openssl md5 "$FILE" 2>/dev/null | awk -F'= ' '{print $2}')
    echo "[$MD5] $(basename "$FILE")"
  else
    echo "[MISSING] $FILE"
  fi
done

# Combine all stable files for a single prefix hash
COMBINED_HASH=$(cat "${STABLE_FILES[@]}" 2>/dev/null | openssl md5 2>/dev/null | awk -F'= ' '{print $2}')
echo "-------------------------------"
echo "TOTAL PREFIX HASH: $COMBINED_HASH"
echo "-------------------------------"
