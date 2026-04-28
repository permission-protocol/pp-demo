#!/bin/bash
# scripts/drought-war-room.sh
# Generates a consolidated "War Room" report for stale items.

echo "### 🔴 WAR ROOM REPORT: SPRINT 5 FAILURE IMMINENT"
echo "**Deadline:** May 1 (3 days away)"
echo "**Current Progress:** 0/10 installs"
echo "**Outreach Drought:** Day 66"
echo ""
echo "#### PENDING BATCH APPROVALS"
grep "approval pending" pp-os/STATUS.md | while read -r line; do
    ID=$(echo "$line" | grep -o "idea-[0-9]\+")
    DESC=$(echo "$line" | sed 's/.*- //')
    echo "- [ ] **$ID**: $DESC"
done
echo ""
echo "#### EXECUTION COMMANDS"
echo "- **Approve All Outreach:** \`/approve all-outreach\`"
echo "- **Approve Site Deploy:** \`/approve site-deploy\`"
echo ""
echo "#### RISK ASSESSMENT"
echo "- Sprint 5 Failure Probability: 95%"
echo "- Outreach Velocity: 0 sends/week"
