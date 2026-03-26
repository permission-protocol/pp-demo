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

READY_JSON="$CRON_FETCH_DIR/Ready Board Items.txt"
NUM_READY=$(jq 'length' "$READY_JSON")

if [[ "$NUM_READY" -eq 0 ]]; then
  echo "No Ready items found on the PP board, so no execution should happen now. Next action: wait for Rod to move approved work into Ready, then re-run this job." > "$CRON_OUTPUT_FILE"
else
  echo "Found $NUM_READY item(s) in the Ready queue. Spawning execution for up to 3 items." > "$CRON_OUTPUT_FILE"
  echo "" >> "$CRON_OUTPUT_FILE"
  
  jq -c '.[0:3][]' "$READY_JSON" | while read -r item; do
    ISSUE_NUM=$(echo "$item" | jq -r '.number')
    TITLE=$(echo "$item" | jq -r '.title')
    REPO_NAME=$(echo "$item" | jq -r '.repo')
    
    FULL_REPO="permission-protocol/$REPO_NAME"
    if [[ -z "$REPO_NAME" || "$REPO_NAME" == "null" ]]; then
      FULL_REPO="permission-protocol/app" # Fallback if draft
    fi
    
    WORKDIR="/tmp/pp-$ISSUE_NUM"
    LOGFILE="$WORKSPACE/logs/crons/codex-issue-$ISSUE_NUM.log"
    
    PROMPT="Implement issue #$ISSUE_NUM: $TITLE for $FULL_REPO. 
    1. Clone the repository ($FULL_REPO) into the current directory.
    2. Create a new branch (e.g., feature/issue-$ISSUE_NUM).
    3. Make the necessary code changes.
    4. Run visual reviews or automated checks as required.
    5. Commit the changes and open a Pull Request.
    6. Exit.
    "
    
    echo "▶️ Launching background agent for Issue #$ISSUE_NUM ($TITLE)..." >> "$CRON_OUTPUT_FILE"
    echo "  - Repo: $FULL_REPO" >> "$CRON_OUTPUT_FILE"
    echo "  - Workdir: $WORKDIR" >> "$CRON_OUTPUT_FILE"
    echo "  - Log: $LOGFILE" >> "$CRON_OUTPUT_FILE"
    
    mkdir -p "$WORKDIR"
    # Spawn codex-run.sh in the background
    nohup bash "$WORKSPACE/scripts/codex-run.sh" "$ISSUE_NUM" "$WORKDIR" "$PROMPT" > "$LOGFILE" 2>&1 &
    
    # Optionally update GitHub project status here to "In progress"
    # For now, rely on GitHub automations or human tracking.
  done
  
  echo "" >> "$CRON_OUTPUT_FILE"
  echo "Execution successfully spawned. The agents will process the issues and open PRs." >> "$CRON_OUTPUT_FILE"
fi

cron_write_report
cron_finish
