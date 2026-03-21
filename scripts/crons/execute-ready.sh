#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

cron_init "execute-ready"

cron_load_file "Focus" "$WORKSPACE/FOCUS.md"
cron_load_file "PP Status" "$WORKSPACE/pp-os/STATUS.md"
cron_load_file "Governance Ledger" "$WORKSPACE/company-os/governance/AUTONOMOUS_PROCESS_LEDGER.md"

cron_fetch_cmd "Ready Board Items" "bash \"$WORKSPACE/scripts/board-ready-items.sh\""
cron_fetch_cmd "Git Status" "git -C \"$WORKSPACE\" status --short --branch"

cron_require_command codex
cron_require_command gh
cron_require_file "$WORKSPACE/scripts/board-ready-items.sh"
cron_validate_nonempty "ready-board-items" "$CRON_FETCH_DIR/Ready Board Items.txt"
cron_validate_json "ready-board-items" "$CRON_FETCH_DIR/Ready Board Items.txt"

cron_invoke_agent \
  "Execute up to three PP Ready items." \
  "Use the fetched Ready board items as the source of truth. If the queue is empty, output a short no-op report. If work exists, state which items should be executed now, which approvals still gate them, and the next action for each." \
  0

cron_write_report
cron_finish
