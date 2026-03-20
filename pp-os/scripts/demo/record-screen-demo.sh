#!/usr/bin/env bash
# record-screen-demo.sh — Full screen recording of PP enforcement demo
#
# Usage: bash record-screen-demo.sh [scenario]
#   scenario: "blocked-egress" (default), "kill-switch"
#
# Zero human intervention. Outputs MP4 + GIF.

set -euo pipefail

SCENARIO="${1:-blocked-egress}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$WORKSPACE/marketing/demos"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
VIDEO_FILE="$OUTPUT_DIR/screen-${SCENARIO}-${TIMESTAMP}.mp4"

mkdir -p "$OUTPUT_DIR"

# Clean signal files
rm -f /tmp/pp-demo-waiting /tmp/pp-demo-approved /tmp/pp-demo-killed /tmp/pp-demo-done

# ═══════════════════════════════════════════
# Phase 1: Open Terminal with demo script on left half
# ═══════════════════════════════════════════
echo "🎬 Launching Terminal with demo..."

osascript <<ASCRIPT
tell application "Terminal"
  activate
  do script "bash '${SCRIPT_DIR}/scenarios/${SCENARIO}-live.sh'"
  delay 0.3
  set bounds of front window to {0, 25, 960, 900}
  set current settings of front window to settings set "Pro"
end tell
ASCRIPT

sleep 2

# ═══════════════════════════════════════════
# Phase 2: Start screen recording (background)
# ═══════════════════════════════════════════
echo "📹 Starting screen recording..."

# Use peekaboo for smart capture → MP4
peekaboo capture live \
  --mode screen \
  --duration 35 \
  --active-fps 12 \
  --idle-fps 6 \
  --video-out "$VIDEO_FILE" \
  --path "/tmp/pp-demo-frames-$$" \
  --resolution-cap 1920 \
  --json > /tmp/pp-capture-result.json 2>&1 &
CAPTURE_PID=$!

sleep 1

# ═══════════════════════════════════════════
# Phase 3: Wait for demo to hit approval point
# ═══════════════════════════════════════════
echo "⏳ Waiting for demo to reach approval point..."

WAIT=0
while [ ! -f /tmp/pp-demo-waiting ] && [ $WAIT -lt 30 ]; do
  sleep 0.5
  WAIT=$((WAIT + 1))
done

if [ ! -f /tmp/pp-demo-waiting ]; then
  echo "❌ Timeout — demo never reached approval point"
  kill $CAPTURE_PID 2>/dev/null || true
  exit 1
fi
rm -f /tmp/pp-demo-waiting
echo "🎯 Demo at approval point"

# Dramatic pause
sleep 3

# ═══════════════════════════════════════════
# Phase 4: Send approval/kill signal
# ═══════════════════════════════════════════
if [ "$SCENARIO" = "blocked-egress" ]; then
  echo "✅ Approving..."
  touch /tmp/pp-demo-approved
elif [ "$SCENARIO" = "kill-switch" ]; then
  echo "🚨 Kill switch..."
  touch /tmp/pp-demo-killed
fi

# ═══════════════════════════════════════════
# Phase 5: Wait for demo to finish
# ═══════════════════════════════════════════
WAIT=0
while [ ! -f /tmp/pp-demo-done ] && [ $WAIT -lt 30 ]; do
  sleep 0.5
  WAIT=$((WAIT + 1))
done
rm -f /tmp/pp-demo-done
echo "🏁 Demo finished"

# Let recording capture the final state
sleep 2

# Kill capture gracefully
kill $CAPTURE_PID 2>/dev/null || true
wait $CAPTURE_PID 2>/dev/null || true

# Close demo Terminal window
osascript -e 'tell application "Terminal" to close front window' 2>/dev/null || true

# ═══════════════════════════════════════════
# Phase 6: Post-process
# ═══════════════════════════════════════════
if [ -f "$VIDEO_FILE" ]; then
  echo ""
  echo "✅ Screen recording saved: $VIDEO_FILE"
  SIZE=$(ls -lh "$VIDEO_FILE" | awk '{print $5}')
  echo "   Size: $SIZE"

  # Generate GIF
  GIF_FILE="${VIDEO_FILE%.mp4}.gif"
  echo "🎞  Generating GIF..."
  ffmpeg -y -i "$VIDEO_FILE" -vf "fps=10,scale=960:-1:flags=lanczos" -loop 0 "$GIF_FILE" 2>/dev/null
  if [ -f "$GIF_FILE" ]; then
    GIF_SIZE=$(ls -lh "$GIF_FILE" | awk '{print $5}')
    echo "   GIF: $GIF_FILE ($GIF_SIZE)"
  fi
else
  echo "❌ No video file produced. Check /tmp/pp-capture-result.json"
  cat /tmp/pp-capture-result.json 2>/dev/null
fi

# Cleanup
rm -rf "/tmp/pp-demo-frames-$$" /tmp/pp-capture-result.json
