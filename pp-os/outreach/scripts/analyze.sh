#!/usr/bin/env bash
# PP Outreach Engine — Weekly Analysis
# Runs every Sunday 10 PM MST via cron on pp-scout-sfo2
# Computes win rates, updates playbook, posts summary to Discord

set -euo pipefail

DB_PATH="${DB_PATH:-/opt/pp-outreach/db/outreach.sqlite}"
PLAYBOOK_PATH="${PLAYBOOK_PATH:-/opt/pp-outreach/playbook.json}"
DISCORD_WEBHOOK="${DISCORD_WEBHOOK_URL:-}"
MIN_SENDS=20  # Minimum sends before judging a variant

echo "[$(date -Iseconds)] Starting weekly analysis..."

# --- Compute metrics by angle ---
ANGLE_STATS=$(sqlite3 "$DB_PATH" <<'SQL'
.mode json
SELECT
  o.angle,
  COUNT(DISTINCT o.id) AS sends,
  COUNT(DISTINCT CASE WHEN e.event_type = 'connection_accepted' THEN o.id END) AS accepted,
  COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) AS replied,
  COUNT(DISTINCT CASE WHEN e.event_type = 'disconnected' THEN o.id END) AS disconnected,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'connection_accepted' THEN o.id END) / NULLIF(COUNT(DISTINCT o.id), 0), 1) AS accept_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) / NULLIF(COUNT(DISTINCT o.id), 0), 1) AS reply_pct
FROM outreach o
LEFT JOIN events e ON e.outreach_id = o.id
GROUP BY o.angle
ORDER BY reply_pct DESC;
SQL
)

# --- Compute metrics by opener ---
OPENER_STATS=$(sqlite3 "$DB_PATH" <<'SQL'
.mode json
SELECT
  o.opener,
  COUNT(DISTINCT o.id) AS sends,
  COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) AS replied,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) / NULLIF(COUNT(DISTINCT o.id), 0), 1) AS reply_pct
FROM outreach o
LEFT JOIN events e ON e.outreach_id = o.id
GROUP BY o.opener
ORDER BY reply_pct DESC;
SQL
)

# --- Compute metrics by signal type ---
SIGNAL_STATS=$(sqlite3 "$DB_PATH" <<'SQL'
.mode json
SELECT
  s.type AS signal_type,
  COUNT(DISTINCT o.id) AS sends,
  COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) AS replied,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) / NULLIF(COUNT(DISTINCT o.id), 0), 1) AS reply_pct
FROM outreach o
LEFT JOIN events e ON e.outreach_id = o.id
LEFT JOIN signals s ON o.signal_id = s.id
GROUP BY s.type
ORDER BY reply_pct DESC;
SQL
)

# --- Compute metrics by segment ---
SEGMENT_STATS=$(sqlite3 "$DB_PATH" <<'SQL'
.mode json
SELECT
  t.segment,
  COUNT(DISTINCT o.id) AS sends,
  COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) AS replied,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) / NULLIF(COUNT(DISTINCT o.id), 0), 1) AS reply_pct
FROM outreach o
JOIN targets t ON o.target_id = t.id
LEFT JOIN events e ON e.outreach_id = o.id
GROUP BY t.segment
ORDER BY reply_pct DESC;
SQL
)

# --- Overall stats ---
TOTALS=$(sqlite3 "$DB_PATH" <<'SQL'
.mode json
SELECT
  COUNT(DISTINCT o.id) AS total_sent,
  COUNT(DISTINCT CASE WHEN e.event_type = 'connection_accepted' THEN o.id END) AS total_accepted,
  COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') THEN o.id END) AS total_replied,
  COUNT(DISTINCT CASE WHEN e.event_type IN ('replied', 'replied_first') AND e.reply_classification = 'meeting' THEN o.id END) AS total_meetings
FROM outreach o
LEFT JOIN events e ON e.outreach_id = o.id;
SQL
)

echo "=== ANGLE STATS ==="
echo "$ANGLE_STATS" | python3 -m json.tool 2>/dev/null || echo "$ANGLE_STATS"
echo ""
echo "=== OPENER STATS ==="
echo "$OPENER_STATS" | python3 -m json.tool 2>/dev/null || echo "$OPENER_STATS"
echo ""
echo "=== SIGNAL TYPE STATS ==="
echo "$SIGNAL_STATS" | python3 -m json.tool 2>/dev/null || echo "$SIGNAL_STATS"
echo ""
echo "=== SEGMENT STATS ==="
echo "$SEGMENT_STATS" | python3 -m json.tool 2>/dev/null || echo "$SEGMENT_STATS"
echo ""
echo "=== TOTALS ==="
echo "$TOTALS" | python3 -m json.tool 2>/dev/null || echo "$TOTALS"

# --- Save analysis snapshot ---
ANALYSIS_DIR="/opt/pp-outreach/data/analysis"
mkdir -p "$ANALYSIS_DIR"
SNAPSHOT_FILE="$ANALYSIS_DIR/weekly-$(date +%Y-%m-%d).json"

cat > "$SNAPSHOT_FILE" <<EOF
{
  "date": "$(date -Iseconds)",
  "totals": $TOTALS,
  "by_angle": $ANGLE_STATS,
  "by_opener": $OPENER_STATS,
  "by_signal_type": $SIGNAL_STATS,
  "by_segment": $SEGMENT_STATS
}
EOF

echo "Snapshot saved to $SNAPSHOT_FILE"

# --- Post to Discord ---
if [ -n "$DISCORD_WEBHOOK" ]; then
  # Extract key numbers from totals (crude but works)
  SENT=$(echo "$TOTALS" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['total_sent'])" 2>/dev/null || echo "?")
  ACCEPTED=$(echo "$TOTALS" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['total_accepted'])" 2>/dev/null || echo "?")
  REPLIED=$(echo "$TOTALS" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['total_replied'])" 2>/dev/null || echo "?")
  MEETINGS=$(echo "$TOTALS" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['total_meetings'])" 2>/dev/null || echo "?")

  DISCORD_MSG="📊 **Weekly Outreach Analysis** — $(date +%Y-%m-%d)\n\nSent: $SENT | Accepted: $ACCEPTED | Replied: $REPLIED | Meetings: $MEETINGS\n\n**By Angle:**\n\`\`\`\n$ANGLE_STATS\n\`\`\`\n**By Signal Type:**\n\`\`\`\n$SIGNAL_STATS\n\`\`\`\nFull snapshot: $SNAPSHOT_FILE"

  curl -s -X POST "$DISCORD_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"content\": \"$(echo -e "$DISCORD_MSG" | head -c 1900)\"}" || true

  echo "Discord notification sent"
fi

echo "[$(date -Iseconds)] Analysis complete."
