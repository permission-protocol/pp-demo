#!/bin/bash
# Verify an approval token exists and is valid for an Authority C action
# Usage: verify-approval.sh <process_id> <content_hash>
#
# Checks:
# 1. Approval file exists for this process_id
# 2. Content hash matches
# 3. Token not expired
# 4. Approver = rod
#
# Exit 0 = approved, Exit 1 = denied (with reason)

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
APPROVALS_DIR="$WORKSPACE/company-os/governance/approvals"

PROCESS_ID="$1"
CONTENT_HASH="$2"

if [ -z "$PROCESS_ID" ] || [ -z "$CONTENT_HASH" ]; then
  echo "DENIED: Missing process_id or content_hash"
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

# Verify all fields
RESULT=$(python3 -c "
import json, sys
from datetime import datetime

with open('$LATEST') as f:
    token = json.load(f)

errors = []

# Check process_id
if token.get('process_id') != '$PROCESS_ID':
    errors.append(f'process_id mismatch: {token.get(\"process_id\")} != $PROCESS_ID')

# Check content_hash
if token.get('content_hash') != '$CONTENT_HASH':
    errors.append(f'content_hash mismatch: {token.get(\"content_hash\")} != $CONTENT_HASH')

# Check expiry
try:
    expires = datetime.strptime(token['expires_at'], '%Y-%m-%dT%H:%M:%SZ')
    if datetime.utcnow() > expires:
        errors.append(f'token expired at {token[\"expires_at\"]}')
except:
    errors.append('invalid expires_at')

# Check approver
if token.get('approver') != 'rod':
    errors.append(f'invalid approver: {token.get(\"approver\")}')

if errors:
    print('DENIED: ' + '; '.join(errors))
    sys.exit(1)
else:
    print(f'APPROVED: token={\"$LATEST\"}, approver={token[\"approver\"]}, expires={token[\"expires_at\"]}')
    sys.exit(0)
" 2>&1)

echo "$RESULT"
# Propagate exit code
echo "$RESULT" | grep -q "^APPROVED" && exit 0 || exit 1
