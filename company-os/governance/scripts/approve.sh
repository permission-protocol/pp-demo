#!/bin/bash
# DEPRECATED — use mint-approval-token.sh directly.
#
# This wrapper exists for backward compatibility but now REQUIRES sender verification.
# Old usage (pre-hardening) accepted content_hash as a parameter — that is NO LONGER
# supported. Pass --draft-file so the hash is computed from the actual file.
#
# Usage: approve.sh <process_id> <draft_file_path> <telegram_sender_id> [ttl_hours]
#
# This script is intentionally minimal. The real enforcement is in mint-approval-token.sh.
# Do NOT add logic here — the boundary is in mint-approval-token.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROCESS_ID="${1:-}"
DRAFT_FILE="${2:-}"
SENDER_ID="${3:-}"
TTL_HOURS="${4:-24}"

if [ -z "$PROCESS_ID" ] || [ -z "$DRAFT_FILE" ] || [ -z "$SENDER_ID" ]; then
  echo "Usage: approve.sh <process_id> <draft_file_path> <telegram_sender_id> [ttl_hours]" >&2
  echo "" >&2
  echo "Note: This wrapper now requires --sender-id for Telegram sender verification." >&2
  echo "      The old approve.sh accepted a content_hash as parameter — that is REMOVED." >&2
  echo "      Hash is now computed from the actual draft file." >&2
  exit 1
fi

exec "$SCRIPT_DIR/mint-approval-token.sh" \
  --process-id "$PROCESS_ID" \
  --draft-file "$DRAFT_FILE" \
  --sender-id "$SENDER_ID" \
  --ttl-hours "$TTL_HOURS"
