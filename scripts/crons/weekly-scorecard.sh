#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

cron_init "weekly-scorecard"

cron_load_file "PP Status" "$WORKSPACE/pp-os/STATUS.md"
cron_load_file "Long-Term Memory" "$WORKSPACE/MEMORY.md"
cron_load_file "Xdares Status" "$WORKSPACE/goals/xdares-seo-growth/STATUS.md"

cron_fetch_cmd "Previous Weekly Scorecard" "sed -n '1,220p' \"$WORKSPACE/pp-os/marketing/metrics/weekly-scorecard-prev.json\""
cron_fetch_cmd "Recent Daily Notes" 'for f in "'"$WORKSPACE"'"/memory/2026-*.md; do [ -f "$f" ] && { echo "--- $(basename "$f") ---"; sed -n '\''1,220p'\'' "$f"; }; done'

cron_require_command codex
cron_require_file "$WORKSPACE/pp-os/marketing/metrics/weekly-scorecard-prev.json"
cron_validate_nonempty "weekly-scorecard-prev" "$CRON_FETCH_DIR/Previous Weekly Scorecard.txt"
cron_validate_json "weekly-scorecard-prev" "$CRON_FETCH_DIR/Previous Weekly Scorecard.txt"

cron_invoke_agent \
  "Generate the weekly operating scorecard." \
  "Write a weekly scorecard with three sections: wins, misses, and next-week focus. Ground every point in the fetched scorecard data and recent notes. Keep the output executive-readable." \
  0

cron_write_report
cron_finish
