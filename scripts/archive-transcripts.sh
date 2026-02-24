#!/bin/bash
# 🎷 Charles Transcript Archiver
# Archives new OpenClaw session transcripts incrementally
# Usage: ./scripts/archive-transcripts.sh [--clean] [--dry-run]
#   --clean   Remove archived orphan transcripts from disk after push
#   --dry-run Show what would be archived without doing it

set -euo pipefail

SESSIONS_DIR="$HOME/.openclaw/agents/main/sessions"
WORKSPACE="$HOME/.openclaw/workspace"
ARCHIVES_DIR="$WORKSPACE/archives"
MANIFEST="$ARCHIVES_DIR/transcripts-manifest.txt"
SESSIONS_JSON="$SESSIONS_DIR/sessions.json"

CLEAN=false
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --clean) CLEAN=true ;;
    --dry-run) DRY_RUN=true ;;
  esac
done

echo "🎷 Charles Transcript Archiver"
echo "=============================="

mkdir -p "$ARCHIVES_DIR"
touch "$MANIFEST"

# Get list of active session IDs (not orphans)
ACTIVE_IDS=$(python3 -c "
import json, sys
try:
    with open('$SESSIONS_JSON') as f:
        data = json.load(f)
    # sessions.json can be dict or list
    if isinstance(data, dict):
        for k, v in data.items():
            if isinstance(v, dict) and 'id' in v:
                print(v['id'])
            elif isinstance(v, str):
                print(v)
    elif isinstance(data, list):
        for item in data:
            if isinstance(item, dict) and 'id' in item:
                print(item['id'])
except Exception as e:
    print(f'Warning: Could not parse sessions.json: {e}', file=sys.stderr)
" 2>/dev/null || true)

# Find all transcript files
ALL_TRANSCRIPTS=$(ls "$SESSIONS_DIR"/*.jsonl 2>/dev/null | xargs -n1 basename || true)

if [ -z "$ALL_TRANSCRIPTS" ]; then
  echo "📭 No transcript files found."
  exit 0
fi

TOTAL=$(echo "$ALL_TRANSCRIPTS" | wc -l | tr -d ' ')
echo "📁 Total transcript files: $TOTAL"

# Find NEW files (not in manifest)
NEW_FILES=()
ORPHAN_FILES=()

while IFS= read -r file; do
  uuid="${file%.jsonl}"
  
  # Check if already archived
  if grep -qxF "$file" "$MANIFEST" 2>/dev/null; then
    continue
  fi
  
  NEW_FILES+=("$file")
  
  # Check if orphan (not in active sessions)
  if ! echo "$ACTIVE_IDS" | grep -qF "$uuid" 2>/dev/null; then
    ORPHAN_FILES+=("$file")
  fi
done <<< "$ALL_TRANSCRIPTS"

echo "🆕 New (unarchived) files: ${#NEW_FILES[@]}"
echo "👻 Of which orphans: ${#ORPHAN_FILES[@]}"

if [ ${#NEW_FILES[@]} -eq 0 ]; then
  echo "✅ Nothing new to archive."
  exit 0
fi

# Calculate sizes
NEW_SIZE=$(cd "$SESSIONS_DIR" && du -ch "${NEW_FILES[@]}" 2>/dev/null | tail -1 | cut -f1)
echo "📦 Uncompressed size: $NEW_SIZE"

if $DRY_RUN; then
  echo ""
  echo "🔍 DRY RUN — would archive ${#NEW_FILES[@]} files ($NEW_SIZE)"
  if $CLEAN; then
    echo "🧹 Would clean ${#ORPHAN_FILES[@]} orphan files from disk after push"
  fi
  exit 0
fi

# Create dated archive
TODAY=$(date +%Y-%m-%d)
ARCHIVE_NAME="transcripts-${TODAY}.tar.gz"

# Handle duplicate date (multiple archives same day)
COUNTER=1
while [ -f "$ARCHIVES_DIR/$ARCHIVE_NAME" ]; do
  ARCHIVE_NAME="transcripts-${TODAY}-${COUNTER}.tar.gz"
  ((COUNTER++))
done

echo ""
echo "📦 Compressing ${#NEW_FILES[@]} files → $ARCHIVE_NAME"
cd "$SESSIONS_DIR"
tar czf "$ARCHIVES_DIR/$ARCHIVE_NAME" "${NEW_FILES[@]}"

COMPRESSED_SIZE=$(ls -lh "$ARCHIVES_DIR/$ARCHIVE_NAME" | awk '{print $5}')
echo "✅ Compressed: $NEW_SIZE → $COMPRESSED_SIZE"

# Check GitHub file size limit (warn at 50MB, fail at 100MB)
BYTES=$(stat -f%z "$ARCHIVES_DIR/$ARCHIVE_NAME" 2>/dev/null || stat --printf="%s" "$ARCHIVES_DIR/$ARCHIVE_NAME" 2>/dev/null)
if [ "$BYTES" -gt 104857600 ]; then
  echo "❌ Archive exceeds GitHub 100MB limit. Split needed."
  echo "   Consider archiving more frequently."
  rm "$ARCHIVES_DIR/$ARCHIVE_NAME"
  exit 1
elif [ "$BYTES" -gt 52428800 ]; then
  echo "⚠️  Archive exceeds 50MB (GitHub warning threshold). Consider archiving more frequently."
fi

# Update manifest
for file in "${NEW_FILES[@]}"; do
  echo "$file" >> "$MANIFEST"
done
echo "📋 Manifest updated (+${#NEW_FILES[@]} entries)"

# Git commit and push
cd "$WORKSPACE"
git add "archives/$ARCHIVE_NAME" "archives/transcripts-manifest.txt"
git commit -m "Archive: ${#NEW_FILES[@]} session transcripts ($COMPRESSED_SIZE compressed) — $TODAY"
echo "⬆️  Pushing to GitHub..."
git push

if [ $? -eq 0 ]; then
  echo "✅ Archive pushed to GitHub"
else
  echo "❌ Push failed! Archive saved locally at: archives/$ARCHIVE_NAME"
  exit 1
fi

# Clean orphans from disk if requested
if $CLEAN; then
  echo ""
  echo "🧹 Cleaning ${#ORPHAN_FILES[@]} archived orphans from disk..."
  CLEANED=0
  for file in "${ORPHAN_FILES[@]}"; do
    rm "$SESSIONS_DIR/$file"
    ((CLEANED++))
  done
  echo "✅ Removed $CLEANED orphan transcript files"
  
  # Report savings
  echo "💾 Disk space recovered (approximate): $NEW_SIZE"
fi

echo ""
echo "🎷 Archive complete!"
echo "   Archive: archives/$ARCHIVE_NAME ($COMPRESSED_SIZE)"
echo "   Files: ${#NEW_FILES[@]} archived, ${#ORPHAN_FILES[@]} orphans"
if $CLEAN; then
  echo "   Cleaned: ${#ORPHAN_FILES[@]} orphans removed from disk"
fi
