#!/bin/bash
# Codex Runner — wraps codex exec with status file output for monitoring.
# Usage: codex-run.sh <issue-number> <workdir> "<prompt>"
#
# Creates /tmp/agent-status-<issue>.json with live status.
# Appends status-writing instructions to the prompt.

set -uo pipefail

ISSUE="${1:?Usage: codex-run.sh <issue> <workdir> <prompt>}"
WORKDIR="${2:?Missing workdir}"
PROMPT="${3:?Missing prompt}"
STATUS_FILE="/tmp/agent-status-${ISSUE}.json"

# Initialize status
cat > "$STATUS_FILE" << EOF
{"issue": $ISSUE, "status": "starting", "started": "$(date -u +%Y-%m-%dT%H:%M:%SZ)", "workdir": "$WORKDIR"}
EOF

# Append status-writing instructions to prompt
STATUS_INSTRUCTIONS="

PROGRESS TRACKING (do this throughout your work):
After each major step, update the status file by running:
echo '{\"issue\": $ISSUE, \"status\": \"<phase>\", \"detail\": \"<what you just did>\", \"files_changed\": <count>, \"updated\": \"'\$(date -u +%Y-%m-%dT%H:%M:%SZ)'\"}' > $STATUS_FILE

Phases: reading, coding, testing, committing, done
Example: echo '{\"issue\": $ISSUE, \"status\": \"coding\", \"detail\": \"Created brand.html with 8 sections\", \"files_changed\": 2, \"updated\": \"'\$(date -u +%Y-%m-%dT%H:%M:%SZ)'\"}' > $STATUS_FILE"

FULL_PROMPT="${PROMPT}${STATUS_INSTRUCTIONS}"

cd "$WORKDIR"
codex exec --full-auto "$FULL_PROMPT"
EXIT_CODE=$?

# Final status
if [ $EXIT_CODE -eq 0 ]; then
    echo "{\"issue\": $ISSUE, \"status\": \"done\", \"exit_code\": 0, \"finished\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$STATUS_FILE"
else
    echo "{\"issue\": $ISSUE, \"status\": \"failed\", \"exit_code\": $EXIT_CODE, \"finished\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$STATUS_FILE"
fi

exit $EXIT_CODE
