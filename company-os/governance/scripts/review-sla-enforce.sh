#!/bin/bash
# Review SLA Enforcement
# Any Authority B/C process not reviewed in 30 days gets auto-disabled.
# Run as part of daily drift check.

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
LEDGER="$WORKSPACE/company-os/governance/AUTONOMOUS_PROCESS_LEDGER.md"
NOW_EPOCH=$(date +%s)

LEDGER_ENTRIES=$(grep '^| PP-\|^| XD-\|^| SYS-' "$LEDGER" | grep -v "^| ID" || true)

DISABLED_ANY=0

while IFS= read -r line; do
  [ -z "$line" ] && continue
  
  LID=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
  LNAME=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
  LAUTH=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $4); print $4}')
  LSTATUS=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $9); print $9}')
  LREVIEWED=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $10); print $10}')
  
  # Skip already disabled or infrastructure
  echo "$LSTATUS" | grep -qi "disabled" && continue
  [ "$LAUTH" = "—" ] && continue
  
  # Only enforce on B and C
  echo "$LAUTH" | grep -qE "^[BC]$" || continue
  
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
      echo "🔴 SLA BREACH: $LID ($LNAME) — Authority $LAUTH — last reviewed ${DAYS_SINCE} days ago"
      
      # Find cron ID by name and disable
      CRON_ID=$(openclaw cron list --json 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
jobs=d.get('jobs',d) if isinstance(d,dict) else d
for j in jobs:
    if j['name']=='$LNAME' and j.get('enabled',True):
        print(j['id'])
        break
" 2>/dev/null)
      
      if [ -n "$CRON_ID" ]; then
        openclaw cron edit "$CRON_ID" --disable 2>/dev/null
        echo "  ⛔ AUTO-DISABLED cron $CRON_ID ($LNAME)"
        DISABLED_ANY=1
      fi
    elif [ "$DAYS_SINCE" -gt 21 ] 2>/dev/null; then
      echo "🟡 SLA WARNING: $LID ($LNAME) — Authority $LAUTH — review due in $((30-DAYS_SINCE)) days"
    fi
  fi
done <<< "$LEDGER_ENTRIES"

if [ $DISABLED_ANY -eq 1 ]; then
  echo ""
  echo "⚠️ Processes were auto-disabled due to review SLA breach."
  echo "To re-enable: review the process, update Last Reviewed in ledger, then: openclaw cron edit <id> --enable"
  exit 1
fi

exit 0
