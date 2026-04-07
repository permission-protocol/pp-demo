#!/usr/bin/env bash

set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"

CRON_JOB=""
CRON_RUN_ID=""
CRON_RUN_DIR=""
CRON_FETCH_DIR=""
CRON_CONTEXT_FILE=""
CRON_PROMPT_FILE=""
CRON_OUTPUT_FILE=""
CRON_META_FILE=""
CRON_LOG_FILE=""

cron_init() {
  local job="$1"
  CRON_JOB="$job"
  CRON_RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
  CRON_RUN_DIR="$WORKSPACE/reports/cron-runs/$CRON_JOB/$CRON_RUN_ID"
  CRON_FETCH_DIR="$CRON_RUN_DIR/fetch"
  CRON_CONTEXT_FILE="$CRON_RUN_DIR/context.md"
  CRON_PROMPT_FILE="$CRON_RUN_DIR/prompt.md"
  CRON_OUTPUT_FILE="$CRON_RUN_DIR/agent-output.md"
  CRON_META_FILE="$CRON_RUN_DIR/meta.json"
  CRON_LOG_FILE="$WORKSPACE/logs/crons/$CRON_JOB.log"

  mkdir -p "$CRON_FETCH_DIR" "$(dirname "$CRON_LOG_FILE")"
  : > "$CRON_CONTEXT_FILE"
  cron_log "load" "Initialized $CRON_JOB at $CRON_RUN_DIR"
}

cron_log() {
  local phase="$1"
  local message="$2"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '[%s] [%s] %s\n' "$ts" "$phase" "$message" | tee -a "$CRON_LOG_FILE" >&2
}

cron_append_context() {
  local heading="$1"
  local body="$2"
  {
    printf '## %s\n' "$heading"
    printf '%s\n\n' "$body"
  } >> "$CRON_CONTEXT_FILE"
}

cron_load_file() {
  local label="$1"
  local path="$2"
  cron_require_file "$path"
  cron_log "load" "$path"
  cron_append_context "$label" "Path: $path

\`\`\`
$(sed -n '1,220p' "$path")
\`\`\`"
}

cron_fetch_cmd() {
  local label="$1"
  local command="$2"
  local dest="$CRON_FETCH_DIR/$label.txt"
  cron_log "fetch" "$label"
  bash -lc "$command" > "$dest"
  cron_append_context "$label" "Command: \`$command\`

\`\`\`
$(sed -n '1,220p' "$dest")
\`\`\`"
}

cron_require_command() {
  local cmd="$1"
  cron_log "validate" "Command: $cmd"
  command -v "$cmd" >/dev/null 2>&1
}

cron_require_file() {
  local path="$1"
  cron_log "validate" "File: $path"
  [[ -f "$path" ]]
}

cron_validate_nonempty() {
  local label="$1"
  local path="$2"
  cron_log "validate" "Non-empty payload: $label"
  [[ -s "$path" ]]
}

cron_validate_json() {
  local label="$1"
  local path="$2"
  cron_log "validate" "JSON payload: $label"
  python3 - <<PY >/dev/null
import json
from pathlib import Path
json.loads(Path("$path").read_text())
PY
}

cron_write_prompt() {
  local title="$1"
  local instructions="$2"
  cat > "$CRON_PROMPT_FILE" <<EOF
You are running the $CRON_JOB orchestration wrapper.

Mandatory execution pattern:
1. load
2. fetch
3. validate
4. invoke agent
5. write
6. log

Write only the requested final report. Do not describe the wrapper itself.

## Job
$title

## Instructions
$instructions

## Loaded Context
$(cat "$CRON_CONTEXT_FILE")
EOF
}

cron_invoke_agent() {
  local title="$1"
  local instructions="$2"
  local enable_search="${3:-0}"

  cron_write_prompt "$title" "$instructions"
  cron_log "invoke" "Launching OpenClaw ACP session"

  # The codex tool expects the skip flag after 'exec'
  local search_flag=""
  [[ "$enable_search" == "1" ]] && search_flag="--search"
  codex $search_flag exec --skip-git-repo-check --full-auto "$(<"$CRON_PROMPT_FILE")" | tee "$CRON_OUTPUT_FILE"
}

cron_write_report() {
  local latest="$WORKSPACE/reports/cron-runs/$CRON_JOB/latest.md"
  local latest_meta="$WORKSPACE/reports/cron-runs/$CRON_JOB/latest.json"
  mkdir -p "$(dirname "$latest")"
  cp "$CRON_OUTPUT_FILE" "$latest"
  cat > "$CRON_META_FILE" <<EOF
{"job":"$CRON_JOB","run_id":"$CRON_RUN_ID","generated_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","report":"$CRON_OUTPUT_FILE"}
EOF
  cp "$CRON_META_FILE" "$latest_meta"
  cron_log "write" "Saved report"
}

cron_finish() {
  cron_log "done" "Completed $CRON_JOB"
}
