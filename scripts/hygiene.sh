#!/bin/bash
# Charles' Workspace Hygiene Script
# Moves transient/temporary files to archives to keep the workspace clean.

DATE=$(date +%Y-%m-%d)
ARCHIVE_DIR="archives/hygiene/$DATE"

mkdir -p "$ARCHIVE_DIR"

# List of patterns to move
PATTERNS=(
    "fix-*.py"
    "fix-*.js"
    "fix-*.ts"
    "fix.py"
    "fix.js"
    "patch-*.js"
    "patch-*.py"
    "patch.js"
    "patch.py"
    "test-*.py"
    "test-*.js"
    "test-*.ts"
    "screen*.png"
    "demo*.png"
    "demo*.mp4"
    "demo*.gif"
    "tmp-*.json"
    "e2e-failure.png"
    "e2e.txt"
    "replace-ui.js"
    "hardcode.js"
    "update-page.js"
)

MOVED_COUNT=0

for pattern in "${PATTERNS[@]}"; do
    # Use find to avoid "Argument list too long" and handle no matches
    find . -maxdepth 1 -name "$pattern" -exec mv {} "$ARCHIVE_DIR/" \; -print | while read -r file; do
        ((MOVED_COUNT++))
    done
done

if [ $MOVED_COUNT -gt 0 ]; then
    echo "Successfully moved $MOVED_COUNT transient files to $ARCHIVE_DIR"
else
    echo "No transient files found to clean up."
    rmdir "$ARCHIVE_DIR" 2>/dev/null
fi
