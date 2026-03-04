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

# 0. Generate fresh scan snapshot + dashboard
echo "--- Scan ---"
bash "$SCRIPT_DIR/gov-scan.sh" 2>&1 | head -1
bash "$SCRIPT_DIR/generate-dashboard-html.sh" 2>&1 | head -1
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

# 4. Dead Man's Switch Heartbeat Push
# Push a timestamp to Roca-Ventures/charles so the GitHub Action watchdog
# can detect if GOV-001 has been silent for >48h. This is the ONLY connection
# between GOV-001 and the external watchdog — the watchdog itself is independent.
echo "--- Dead Man's Switch Heartbeat ---"
CHARLES_HEARTBEAT_DIR="$HOME/tmp/charles-heartbeat"
HEARTBEAT_PAT_FILE="$HOME/.openclaw/secrets/github-pat-classic.txt"

if [ -f "$HEARTBEAT_PAT_FILE" ]; then
  HEARTBEAT_PAT=$(cat "$HEARTBEAT_PAT_FILE")
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Clone (shallow) or reuse
  if [ ! -d "$CHARLES_HEARTBEAT_DIR/.git" ]; then
    rm -rf "$CHARLES_HEARTBEAT_DIR"
    git clone --depth 1 "https://${HEARTBEAT_PAT}@github.com/Roca-Ventures/charles.git" \
      "$CHARLES_HEARTBEAT_DIR" 2>&1 | tail -1
  else
    cd "$CHARLES_HEARTBEAT_DIR" && git pull --rebase 2>&1 | tail -1
  fi

  cd "$CHARLES_HEARTBEAT_DIR"
  mkdir -p governance
  echo "GOV-001 heartbeat — last run: $TIMESTAMP" > governance/heartbeat.txt

  git config user.email "charles@roca-ventures.com"
  git config user.name "Charles (GOV-001)"
  git add governance/heartbeat.txt
  git diff --cached --quiet || git commit -m "gov: heartbeat $TIMESTAMP" 2>&1 | tail -1
  git push 2>&1 | tail -1 && echo "✅ Heartbeat pushed: $TIMESTAMP" || echo "⚠️ Heartbeat push failed (alert watchdog will trigger in <48h)"
else
  echo "⚠️ Heartbeat PAT not found — dead man's switch NOT updated"
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
