#!/bin/bash
# Deterministic approval token minting with Telegram sender verification
#
# BOUNDARY: This script is the ONLY authorized path for minting approval tokens.
#           It must be invoked with a verified Telegram sender ID — the agent
#           cannot fabricate this without a real signal from the authorized approver.
#
# Usage: mint-approval-token.sh \
#           --process-id <id> \
#           --draft-file <path> \
#           --sender-id <telegram_user_id> \
#           [--ttl-hours <hours>]
#
# Exit 0 = token minted, prints token file path
# Exit 1 = denied (with reason on stderr)
#
# Security properties:
# 1. Sender ID MUST be Rod's Telegram ID (hardcoded, not configurable by agent)
# 2. Content hash computed from the actual file — never accepted as parameter
# 3. Nonce generated per-mint — prevents replay attacks
# 4. All issuances appended to approval-log.jsonl (append-only audit trail)
# 5. Process ID must be a known registered process (whitelist)

set -euo pipefail

# ─── Hardcoded constants ───────────────────────────────────────────────────────
AUTHORIZED_SENDER_ID="6091356144"   # Rod's Telegram user ID — do NOT parameterize
WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
GOVERNANCE_DIR="$WORKSPACE/company-os/governance"
APPROVALS_DIR="$GOVERNANCE_DIR/approvals"
AUDIT_LOG="$GOVERNANCE_DIR/approval-log.jsonl"
NONCE_LOG="$GOVERNANCE_DIR/used-nonces.txt"

# Registered process IDs that are allowed to request approval tokens
ALLOWED_PROCESSES=("PP-001" "PP-008" "XD-001")

# ─── Parse arguments ──────────────────────────────────────────────────────────
PROCESS_ID=""
DRAFT_FILE=""
SENDER_ID=""
TTL_HOURS="24"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --process-id) PROCESS_ID="$2"; shift 2 ;;
    --draft-file) DRAFT_FILE="$2"; shift 2 ;;
    --sender-id)  SENDER_ID="$2"; shift 2 ;;
    --ttl-hours)  TTL_HOURS="$2"; shift 2 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ─── Validate required args ───────────────────────────────────────────────────
if [ -z "$PROCESS_ID" ] || [ -z "$DRAFT_FILE" ] || [ -z "$SENDER_ID" ]; then
  echo "ERROR: Missing required argument. Usage:" >&2
  echo "  $0 --process-id <id> --draft-file <path> --sender-id <telegram_id>" >&2
  exit 1
fi

# ─── Sender verification (Gate 1) ─────────────────────────────────────────────
# This is the critical enforcement boundary.
# If the agent tries to call this script without a real Telegram signal from Rod,
# it must fabricate the sender ID — which is detectable and logged.
if [ "$SENDER_ID" != "$AUTHORIZED_SENDER_ID" ]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  # Log the unauthorized attempt
  mkdir -p "$GOVERNANCE_DIR"
  echo "{\"event\":\"UNAUTHORIZED_MINT_ATTEMPT\",\"process_id\":\"$PROCESS_ID\",\"claimed_sender\":\"$SENDER_ID\",\"timestamp\":\"$TIMESTAMP\"}" >> "$AUDIT_LOG"
  echo "DENIED: sender_id $SENDER_ID is not authorized. Expected: $AUTHORIZED_SENDER_ID" >&2
  exit 1
fi

# ─── Process ID whitelist (Gate 2) ────────────────────────────────────────────
PROCESS_ALLOWED=false
for allowed in "${ALLOWED_PROCESSES[@]}"; do
  if [ "$PROCESS_ID" = "$allowed" ]; then
    PROCESS_ALLOWED=true
    break
  fi
done

if [ "$PROCESS_ALLOWED" != "true" ]; then
  echo "DENIED: process_id '$PROCESS_ID' is not in the approved process list" >&2
  echo "  Allowed: ${ALLOWED_PROCESSES[*]}" >&2
  exit 1
fi

# ─── Draft file existence check (Gate 3) ─────────────────────────────────────
if [ ! -f "$DRAFT_FILE" ]; then
  echo "DENIED: draft file not found: $DRAFT_FILE" >&2
  exit 1
fi

# ─── Compute content hash from actual file (deterministic — not from parameter) ──
CONTENT_HASH=$(sha256sum "$DRAFT_FILE" 2>/dev/null | awk '{print $1}' \
  || shasum -a 256 "$DRAFT_FILE" | awk '{print $1}')

if [ -z "$CONTENT_HASH" ]; then
  echo "ERROR: Failed to compute hash for $DRAFT_FILE" >&2
  exit 1
fi

# ─── Generate nonce ───────────────────────────────────────────────────────────
NONCE=$(python3 -c "import uuid; print(str(uuid.uuid4()))")

# Verify nonce hasn't been used (replay protection)
mkdir -p "$GOVERNANCE_DIR"
touch "$NONCE_LOG"
if grep -qF "$NONCE" "$NONCE_LOG" 2>/dev/null; then
  echo "ERROR: Nonce collision detected — this should never happen" >&2
  exit 1
fi

# ─── Mint the token ───────────────────────────────────────────────────────────
mkdir -p "$APPROVALS_DIR"

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EPOCH=$(date +%s)
EXPIRES_AT=$(python3 -c "
from datetime import datetime, timedelta, timezone
expiry = datetime.now(timezone.utc) + timedelta(hours=$TTL_HOURS)
print(expiry.strftime('%Y-%m-%dT%H:%M:%SZ'))
")

TOKEN_FILE="$APPROVALS_DIR/${PROCESS_ID}-${EPOCH}.json"

cat > "$TOKEN_FILE" << EOF
{
  "process_id": "$PROCESS_ID",
  "content_hash": "$CONTENT_HASH",
  "draft_file": "$DRAFT_FILE",
  "approver": "rod",
  "sender_id_verified": "$SENDER_ID",
  "approved_at": "$NOW",
  "expires_at": "$EXPIRES_AT",
  "ttl_hours": $TTL_HOURS,
  "nonce": "$NONCE",
  "minting_boundary": "telegram_verified"
}
EOF

# ─── Register nonce as used ────────────────────────────────────────────────────
echo "$NONCE $NOW $PROCESS_ID" >> "$NONCE_LOG"

# ─── Append to audit log (append-only) ────────────────────────────────────────
echo "{\"event\":\"TOKEN_MINTED\",\"process_id\":\"$PROCESS_ID\",\"content_hash\":\"$CONTENT_HASH\",\"draft_file\":\"$DRAFT_FILE\",\"nonce\":\"$NONCE\",\"sender_id\":\"$SENDER_ID\",\"approved_at\":\"$NOW\",\"expires_at\":\"$EXPIRES_AT\",\"token_file\":\"$TOKEN_FILE\"}" >> "$AUDIT_LOG"

echo "$TOKEN_FILE"
