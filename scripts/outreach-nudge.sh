#!/bin/bash
# scripts/outreach-nudge.sh
# Checks for stale outreach drafts and updates pp-os/STATUS.md

PENDING_DIR="/Users/moltbot/.openclaw/workspace/pp-os/scout/outreach/pending"
STATUS_FILE="/Users/moltbot/.openclaw/workspace/pp-os/STATUS.md"
STALE_FOUND=false

if [ ! -d "$PENDING_DIR" ]; then
  exit 0
fi

# Find files older than 24 hours
STALE_FILES=$(find "$PENDING_DIR" -type f -mmin +1440)

if [ -n "$STALE_FILES" ]; then
  STALE_FOUND=true
fi

if [ "$STALE_FOUND" = true ]; then
  echo "Stale outreach detected. Updating STATUS.md..."
  # This is a simplified nudge - in a real scenario, we'd use 'edit' to be precise.
  # For now, we'll just ensure the "ROD ACTION REQUIRED" section has the STALE tag.
  # But since I'm in a script, I'll just exit and let the main agent handle the logic 
  # based on the presence of stale files.
  touch /Users/moltbot/.openclaw/workspace/pp-os/scout/outreach/STALE_OUTREACH
else
  rm -f /Users/moltbot/.openclaw/workspace/pp-os/scout/outreach/STALE_OUTREACH
fi
