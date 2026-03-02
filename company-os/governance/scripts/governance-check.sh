#!/bin/bash
# Daily Governance Integrity Check
# Runs: drift detection + review SLA enforcement
# Reports findings to caller (cron announces to Telegram)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FINDINGS=""
EXIT_CODE=0

echo "=== Governance Integrity Check ==="
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# 0. Generate fresh scan snapshot
echo "--- Scan ---"
bash "$SCRIPT_DIR/gov-scan.sh" 2>&1 | head -1
echo ""

# 1. Drift Detection
echo "--- Drift Detection ---"
DRIFT_OUTPUT=$(bash "$SCRIPT_DIR/drift-check.sh" 2>&1) || true
DRIFT_EXIT=$?
echo "$DRIFT_OUTPUT"
if [ $DRIFT_EXIT -ne 0 ]; then
  FINDINGS="$FINDINGS\n⚠️ Drift detected"
  EXIT_CODE=1
fi

echo ""

# 2. Review SLA Enforcement
echo "--- Review SLA Check ---"
SLA_OUTPUT=$(bash "$SCRIPT_DIR/review-sla-enforce.sh" 2>&1) || true
SLA_EXIT=$?
if [ -n "$SLA_OUTPUT" ]; then
  echo "$SLA_OUTPUT"
else
  echo "✅ All review SLAs current."
fi
if [ $SLA_EXIT -ne 0 ]; then
  FINDINGS="$FINDINGS\n🔴 SLA breach — processes auto-disabled"
  EXIT_CODE=1
fi

echo ""

# 3. Approval token cleanup (expire old tokens)
echo "--- Approval Token Cleanup ---"
APPROVALS_DIR="$HOME/.openclaw/workspace/company-os/governance/approvals"
if [ -d "$APPROVALS_DIR" ]; then
  EXPIRED=0
  for f in "$APPROVALS_DIR"/*.json; do
    [ -f "$f" ] || continue
    IS_EXPIRED=$(python3 -c "
import json
from datetime import datetime
with open('$f') as fh:
    t=json.load(fh)
try:
    exp=datetime.strptime(t['expires_at'],'%Y-%m-%dT%H:%M:%SZ')
    if datetime.utcnow()>exp: print('yes')
    else: print('no')
except: print('yes')
" 2>/dev/null)
    if [ "$IS_EXPIRED" = "yes" ]; then
      rm "$f"
      EXPIRED=$((EXPIRED+1))
    fi
  done
  echo "Cleaned $EXPIRED expired approval tokens."
else
  echo "No approval tokens directory."
fi

echo ""

# Summary
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ Governance check passed. No issues."
else
  echo "⚠️ ISSUES FOUND:"
  echo -e "$FINDINGS"
fi

exit $EXIT_CODE
