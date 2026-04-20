#!/bin/bash
# linkedin-pivot.sh - Drafts a LinkedIn follow-up to a secondary contact.
# Usage: bash scripts/linkedin-pivot.sh "Company Name" "Primary Contact Name" "Secondary Contact Name" "Role"

COMPANY=$1
PRIMARY=$2
SECONDARY=$3
ROLE=$4

if [ -z "$COMPANY" ] || [ -z "$PRIMARY" ] || [ -z "$SECONDARY" ]; then
    echo "Usage: bash scripts/linkedin-pivot.sh \"Company Name\" \"Primary Contact Name\" \"Secondary Contact Name\" \"Role\""
    exit 1
fi

cat <<EOF
---
LinkedIn Pivot Draft for $COMPANY
Target: $SECONDARY ($ROLE)
Pivot from: $PRIMARY
---

Hi $SECONDARY — dropping a quick note here as I haven't been able to connect with $PRIMARY yet.

We're seeing a lot of interest from engineering teams at places like $COMPANY who are adopting AI coding agents but need a way to enforce authorization at the deploy gate. 

We've built the Consequence Engine to solve exactly that — cryptographic receipts for every agent action, signed by your own authority.

Would you be the right person to chat with about a 15-min technical walkthrough, or should I circle back with $PRIMARY?

Best,
Rod
---
EOF
