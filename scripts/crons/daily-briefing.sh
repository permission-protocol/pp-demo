#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

cron_init "daily-briefing"

cron_load_file "Focus" "$WORKSPACE/FOCUS.md"
cron_load_file "PP Status" "$WORKSPACE/pp-os/STATUS.md"
cron_load_file "Heartbeat Rules" "$WORKSPACE/HEARTBEAT.md"

cron_fetch_cmd "Heartbeat Check" "bash \"$WORKSPACE/scripts/heartbeat-check.sh\""
cron_fetch_cmd "Thread State Validation" "python3 \"$WORKSPACE/ops/threads_manager.py\" validate \"$WORKSPACE/ops/threads.yaml\""
cron_fetch_cmd "Workspace Git Status" "git -C \"$WORKSPACE\" status --short --branch"

cron_require_command codex
cron_require_file "$WORKSPACE/scripts/heartbeat-check.sh"
cron_require_file "$WORKSPACE/ops/threads_manager.py"
cron_validate_nonempty "heartbeat-check" "$CRON_FETCH_DIR/Heartbeat Check.txt"
cron_validate_json "heartbeat-check" "$CRON_FETCH_DIR/Heartbeat Check.txt"

cron_invoke_agent \
  "Generate Rod's daily briefing." \
  "Produce a short daily briefing with system health, active focus, and immediate actions. Use the heartbeat output and validated thread state as operational inputs. End with a single highest-leverage next step." \
  0

cron_write_report
cron_finish
