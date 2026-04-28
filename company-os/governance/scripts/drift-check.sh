#!/bin/bash
# Drift Detection: compares live cron state vs ledger
# Outputs JSON with drift findings
# Exit 0 = clean, Exit 1 = drift detected

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
LEDGER="$WORKSPACE/company-os/governance/AUTONOMOUS_PROCESS_LEDGER.md"
DRIFT_LOG="$WORKSPACE/company-os/governance/drift-log.jsonl"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Get live cron state
LIVE_CRONS=$(openclaw cron list --json 2>/dev/null)

# Parse ledger entries (ID | Name | Authority | Human Gate | Risk | Runs On | Schedule | Status | Last Reviewed)
# Extract process names and their declared status from the index table
LEDGER_ENTRIES=$(grep '^| PP-\|^| XD-\|^| SYS-\|^| GOV-' "$LEDGER" | grep -v "^| ID" || true)

DRIFT_FOUND=0
FINDINGS="[]"

add_finding() {
  local severity="$1" type="$2" detail="$3"
  FINDINGS=$(echo "$FINDINGS" | python3 -c "
import sys,json
f=json.load(sys.stdin)
f.append({'severity':'$severity','type':'$type','detail':'''$detail'''})
print(json.dumps(f))")
  DRIFT_FOUND=1
}

# CHECK 1: Unknown crons (live but not in ledger)
LIVE_NAMES=$(echo "$LIVE_CRONS" | python3 -c "
import sys,json
d=json.load(sys.stdin)
jobs=d.get('jobs',d) if isinstance(d,dict) else d
for j in jobs:
    if j.get('enabled',True):
        print(j['name'])
" 2>/dev/null)

LEDGER_NAMES=$(echo "$LEDGER_ENTRIES" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
LEDGER_IDS=$(echo "$LEDGER_ENTRIES" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')

while IFS= read -r name; do
  [ -z "$name" ] && continue
  # Check if name matches column 3 OR if it's the name of one of the IDs in column 2 (for self-check)
  if ! echo "$LEDGER_NAMES" | grep -qx "$name" && ! echo "$LEDGER_IDS" | grep -qx "$name"; then
    add_finding "HIGH" "unregistered_process" "Live cron '$name' not found in ledger"
  fi
done <<< "$LIVE_NAMES"

# CHECK 2: Ledger says disabled but cron is enabled
while IFS= read -r line; do
  [ -z "$line" ] && continue
  LNAME=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
  LSTATUS=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $9); print $9}')
  
  if echo "$LSTATUS" | grep -qi "disabled"; then
    # Check if it's actually enabled in live crons
    IS_LIVE=$(echo "$LIVE_CRONS" | python3 -c "
import sys,json
d=json.load(sys.stdin)
jobs=d.get('jobs',d) if isinstance(d,dict) else d
for j in jobs:
    if j['name']=='$LNAME' and j.get('enabled',True):
        print('ENABLED')
" 2>/dev/null)
    if [ "$IS_LIVE" = "ENABLED" ]; then
      add_finding "HIGH" "disabled_but_running" "Ledger says '$LNAME' is disabled but cron is enabled"
    fi
  fi
done <<< "$LEDGER_ENTRIES"

# CHECK 3: Review SLA — Authority B/C processes not reviewed in 30 days
while IFS= read -r line; do
  [ -z "$line" ] && continue
  LID=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
  LNAME=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
  LAUTH=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $4); print $4}')
  LREVIEWED=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $10); print $10}')
  LSTATUS=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $9); print $9}')
  
  # Skip disabled processes
  echo "$LSTATUS" | grep -qi "disabled" && continue
  
  # Only check B and C authority
  if echo "$LAUTH" | grep -qE "^[BC]$"; then
    if [ -n "$LREVIEWED" ]; then
      DAYS_SINCE=$(python3 -c "
from datetime import datetime
try:
    reviewed=datetime.strptime('$LREVIEWED'.strip(),'%Y-%m-%d')
    now=datetime.utcnow()
    print((now-reviewed).days)
except: print(-1)
" 2>/dev/null)
      if [ "$DAYS_SINCE" -gt 30 ] 2>/dev/null; then
        add_finding "CRITICAL" "review_sla_breach" "$LID ($LNAME) — Authority $LAUTH not reviewed in ${DAYS_SINCE} days. AUTO-DISABLE REQUIRED."
      elif [ "$DAYS_SINCE" -gt 21 ] 2>/dev/null; then
        add_finding "WARN" "review_sla_warning" "$LID ($LNAME) — Authority $LAUTH review due in $((30-DAYS_SINCE)) days"
      fi
    fi
  fi
done <<< "$LEDGER_ENTRIES"

# CHECK 4: Schedule drift (live schedule != ledger schedule)
# Compare key crons
echo "$LIVE_CRONS" | python3 -c "
import sys,json
d=json.load(sys.stdin)
jobs=d.get('jobs',d) if isinstance(d,dict) else d
for j in jobs:
    s=j.get('schedule',{})
    print(f'{j[\"name\"]}|{s.get(\"expr\",\"\")}|{j.get(\"enabled\",True)}')
" 2>/dev/null > /tmp/drift-live-schedules.txt

# Write drift log entry
ENTRY=$(python3 -c "
import json
findings=$FINDINGS
print(json.dumps({
    'timestamp': '$NOW',
    'drift_found': $DRIFT_FOUND == 1,
    'finding_count': len(findings),
    'findings': findings
}))")

echo "$ENTRY" >> "$DRIFT_LOG"

# Output
if [ $DRIFT_FOUND -eq 1 ]; then
  echo "⚠️ DRIFT DETECTED"
  echo "$FINDINGS" | python3 -c "
import sys,json
for f in json.load(sys.stdin):
    print(f'  [{f[\"severity\"]}] {f[\"type\"]}: {f[\"detail\"]}')
"
  exit 1
else
  echo "✅ No drift detected. Ledger matches live state."
  exit 0
fi
