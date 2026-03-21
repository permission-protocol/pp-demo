#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

cron_init "unified-hotline"

cron_load_file "Hotline Prompt" "$WORKSPACE/pp-os/scout/scripts/hotline-scan-prompt.md"
cron_load_file "PP Status" "$WORKSPACE/pp-os/STATUS.md"
cron_load_file "Recent Memory" "$WORKSPACE/memory/2026-03-21.md"

cron_fetch_cmd "Scout State" "sed -n '1,220p' \"$WORKSPACE/pp-os/scout/state.json\""
cron_fetch_cmd "Recent Hotline Signals" "python3 - <<'PY'\nfrom datetime import date\nfrom pathlib import Path\npath = Path('$WORKSPACE/pp-os/scout/signals') / f'{date.today().isoformat()}.jsonl'\nprint(path.read_text() if path.exists() else '[]')\nPY"

cron_require_command codex
cron_require_file "$WORKSPACE/pp-os/scout/scripts/hotline-scan-prompt.md"
cron_require_file "$WORKSPACE/pp-os/scout/state.json"
cron_validate_nonempty "scout-state" "$CRON_FETCH_DIR/Scout State.txt"

cron_invoke_agent \
  "Run the unified hotline scan." \
  "Use the hotline prompt and fetched scout state to produce the next hotline report. Call out hot signals, recommended fast-track actions, and any blocker that should halt outbound action. If there are no actionable signals, say so explicitly." \
  1

cron_write_report
cron_finish
