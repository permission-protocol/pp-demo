#!/bin/bash
# Create an approval token for an Authority C action
# Usage: approve.sh <process_id> <content_hash> [ttl_hours]
#
# Creates a signed approval file that enforcement scripts verify.
# Approval token = JSON with: process_id, content_hash, approver, timestamp, expires
# Token is written to governance/approvals/<process_id>-<timestamp>.json

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
APPROVALS_DIR="$WORKSPACE/company-os/governance/approvals"
mkdir -p "$APPROVALS_DIR"

PROCESS_ID="$1"
CONTENT_HASH="$2"
TTL_HOURS="${3:-24}"

if [ -z "$PROCESS_ID" ] || [ -z "$CONTENT_HASH" ]; then
  echo "Usage: approve.sh <process_id> <content_hash> [ttl_hours]"
  exit 1
fi

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TIMESTAMP=$(date +%s)
EXPIRES_AT=$(python3 -c "from datetime import datetime,timedelta; print((datetime.utcnow()+timedelta(hours=$TTL_HOURS)).strftime('%Y-%m-%dT%H:%M:%SZ'))")

TOKEN_FILE="$APPROVALS_DIR/${PROCESS_ID}-${TIMESTAMP}.json"

cat > "$TOKEN_FILE" << EOF
{
  "process_id": "$PROCESS_ID",
  "content_hash": "$CONTENT_HASH",
  "approver": "rod",
  "approved_at": "$NOW",
  "expires_at": "$EXPIRES_AT",
  "ttl_hours": $TTL_HOURS
}
EOF

echo "$TOKEN_FILE"
