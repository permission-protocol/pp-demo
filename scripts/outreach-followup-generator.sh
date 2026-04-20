#!/bin/bash
# scripts/outreach-followup-generator.sh - Generate follow-up messages for outreach.
# Targets leads contacted > 14 days ago with no response.

DATE_NOW=$(date +%Y-%m-%d)
FOLLOWUP_WINDOW=14
OUTREACH_LOG="pp-os/scout/outreach/sent/receipt-outreach-blitz.txt" # Common log file for blitzes
LEADS_INDEX="pp-os/scout/leads/index.json"

echo "Checking for leads needing follow-up (sent > $FOLLOWUP_WINDOW days ago)..."

# In a real script, I'd parse the JSON and log files. 
# For now, I'll create a structured prompt/output that Charles can use in a session.

# Scan leads/index.json for "contacted" status and date
# Use jq to find leads where (today - contacted_at) >= 14 days AND status != "responded"
# Since I can't easily do date math in bash without dependencies, I'll use a python helper.

python3 <<EOF
import json
from datetime import datetime, timedelta

with open('$LEADS_INDEX', 'r') as f:
    data = json.load(f)

today = datetime.now()
followup_needed = []

for lead in data.get('leads', []):
    if lead.get('status') == 'contacted' and lead.get('contacted_at'):
        contacted_at = datetime.fromisoformat(lead['contacted_at'].replace('Z', '+00:00'))
        # Remove timezone for simple comparison
        if (today - contacted_at.replace(tzinfo=None)).days >= $FOLLOWUP_WINDOW:
            followup_needed.append(lead)

if not followup_needed:
    print("No leads need follow-up today.")
else:
    print(f"Found {len(followup_needed)} leads needing follow-up:")
    for lead in followup_needed:
        print(f"- {lead['company']} ({lead['contact']}) - Sent: {lead['contacted_at']}")
        # Draft a follow-up
        followup_msg = f"""
### Follow-up: {lead['company']} / {lead['contact']}
Target Date: {lead['contacted_at']}

Draft:
"Hi {lead['contact'].split()[0]}, circling back on the note I sent about Permission Protocol and the authorization gap in agentic AI. 

Since we last spoke, we've stabilized the 'Consequence Engine' — our pre-action enforcement gate. It's the infrastructure that ensures no agent action executes without a signed receipt.

Would love to show you how it fits into {lead['company']}'s roadmap. 10 minutes this week?"
"""
        print(followup_msg)
EOF
