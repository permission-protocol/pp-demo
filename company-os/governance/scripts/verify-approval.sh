#!/bin/bash
# Verify an approval token is valid for an Authority C action
#
# Usage: verify-approval.sh <process_id> <content_hash>
#
# Checks:
# 1. Approval file exists for this process_id
# 2. Content hash matches
# 3. Token not expired
# 4. Approver = rod
# 5. sender_id_verified present (token was minted via verified path)
# 6. Nonce present (token was minted by hardened mint-approval-token.sh)
#
# Exit 0 = approved, Exit 1 = denied (with reason)
#
# NOTE: Pass the current file's hash as content_hash — compute it at the
#       call site using: sha256sum <file> | awk '{print $1}'

set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
APPROVALS_DIR="$WORKSPACE/company-os/governance/approvals"
AUDIT_LOG="$WORKSPACE/company-os/governance/approval-log.jsonl"

PROCESS_ID="${1:-}"
CONTENT_HASH="${2:-}"

if [ -z "$PROCESS_ID" ] || [ -z "$CONTENT_HASH" ]; then
  echo "DENIED: Missing process_id or content_hash"
  echo "Usage: verify-approval.sh <process_id> <content_hash>"
  exit 1
fi

if [ ! -d "$APPROVALS_DIR" ]; then
  echo "DENIED: No approvals directory exists"
  exit 1
fi

# Find most recent approval for this process
LATEST=$(ls -t "$APPROVALS_DIR"/${PROCESS_ID}-*.json 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
  echo "DENIED: No approval token found for process $PROCESS_ID"
  exit 1
fi

# Verify all fields via Python for precise logic
PYOUT_FILE=$(mktemp)
set +e
python3 << PYEOF > "$PYOUT_FILE" 2>&1
import json, sys
from datetime import datetime, timezone

with open('$LATEST') as f:
    token = json.load(f)

errors = []

# Check process_id
if token.get('process_id') != '$PROCESS_ID':
    errors.append(f'process_id mismatch: {token.get("process_id")} != $PROCESS_ID')

# Check content_hash
if token.get('content_hash') != '$CONTENT_HASH':
    errors.append(f'content_hash mismatch: expected $CONTENT_HASH, got {token.get("content_hash")}')

# Check expiry
try:
    expires = datetime.strptime(token['expires_at'], '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=timezone.utc)
    if datetime.now(timezone.utc) > expires:
        errors.append(f'token expired at {token["expires_at"]}')
except Exception as e:
    errors.append(f'invalid expires_at: {e}')

# Check approver
if token.get('approver') != 'rod':
    errors.append(f'invalid approver: {token.get("approver")}')

# Check sender verification (hardened path)
if not token.get('sender_id_verified'):
    errors.append('token missing sender_id_verified — was not minted via hardened path')

# Check nonce (hardened path)
if not token.get('nonce'):
    errors.append('token missing nonce — was not minted via hardened mint-approval-token.sh')

# Check minting boundary
if token.get('minting_boundary') != 'telegram_verified':
    errors.append(f'unexpected minting_boundary: {token.get("minting_boundary")} (expected: telegram_verified)')

if errors:
    print('DENIED: ' + '; '.join(errors))
    sys.exit(1)
else:
    nonce = token.get('nonce', 'n/a')
    print(f'APPROVED: token={repr("$LATEST")}, approver={token["approver"]}, expires={token["expires_at"]}, nonce={nonce}')
    sys.exit(0)
PYEOF
EXIT_CODE=$?
set -e
RESULT=$(cat "$PYOUT_FILE")
rm -f "$PYOUT_FILE"
echo "$RESULT"

# Log verification event
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
if echo "$RESULT" | grep -q "^APPROVED"; then
  echo "{\"event\":\"TOKEN_VERIFIED\",\"process_id\":\"$PROCESS_ID\",\"content_hash\":\"$CONTENT_HASH\",\"token_file\":\"$LATEST\",\"timestamp\":\"$TIMESTAMP\"}" >> "$AUDIT_LOG" 2>/dev/null || true
else
  echo "{\"event\":\"TOKEN_VERIFY_FAILED\",\"process_id\":\"$PROCESS_ID\",\"content_hash\":\"$CONTENT_HASH\",\"reason\":\"$(echo $RESULT | head -1)\",\"timestamp\":\"$TIMESTAMP\"}" >> "$AUDIT_LOG" 2>/dev/null || true
fi

exit $EXIT_CODE
