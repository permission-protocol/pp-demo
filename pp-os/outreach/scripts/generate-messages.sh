#!/usr/bin/env bash
#
# PP Message Generator — Takes a target profile and generates full outreach sequence
#
# Input: JSON target object (from enrichment or manual)
# Output: Full message sequence ready for Expandi injection
#
# Usage:
#   echo '{"name":"John Doe","company":"Acme","title":"CTO","linkedin_url":"...","signal":"...","angle":"incident_response"}' | ./generate-messages.sh
#   ./generate-messages.sh target.json
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAYBOOK="${SCRIPT_DIR}/../playbook.json"

# Read input
if [ -n "${1:-}" ] && [ -f "$1" ]; then
  TARGET=$(cat "$1")
else
  TARGET=$(cat -)
fi

# Validate
if [ -z "$TARGET" ]; then
  echo "ERROR: No target provided" >&2
  exit 1
fi

# Extract fields
NAME=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('name',''))")
FIRST_NAME=$(echo "$NAME" | awk '{print $1}')
COMPANY=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('company',''))")
TITLE=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title',''))")
SIGNAL=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('signal',''))")
SIGNAL_URL=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('signal_url',''))")
ANGLE=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('angle','accountability_gap'))")
LINKEDIN=$(echo "$TARGET" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('linkedin_url',''))")

if [ -z "$NAME" ] || [ -z "$COMPANY" ] || [ -z "$LINKEDIN" ]; then
  echo "ERROR: Missing required fields (name, company, linkedin_url)" >&2
  exit 1
fi

# Load playbook
PLAYBOOK_JSON=$(cat "$PLAYBOOK")

# Generate messages using playbook templates
python3 << PYEOF
import json, sys, random

target = json.loads('''$TARGET''')
playbook = json.loads('''$PLAYBOOK_JSON''')

name = target.get('name', '')
first_name = name.split()[0] if name else 'there'
company = target.get('company', '')
title = target.get('title', '')
signal = target.get('signal', '')
signal_url = target.get('signal_url', '')
angle = target.get('angle', 'accountability_gap')
linkedin = target.get('linkedin_url', '')

# Get angle config from playbook
angles = playbook.get('angles', {})
angle_config = angles.get(angle, angles.get('accountability_gap', {}))

# Select opener (random from playbook openers for this angle, or round-robin)
openers = playbook.get('openers', {})
opener_keys = list(openers.keys())
opener_key = random.choice(opener_keys) if opener_keys else 'O1'
opener_config = openers.get(opener_key, {})

# Template variables
vars = {
    'first_name': first_name,
    'name': name,
    'company': company,
    'title': title,
    'signal': signal,
    'signal_url': signal_url,
    'angle_name': angle_config.get('name', angle),
    'angle_hook': angle_config.get('hook', 'agent accountability'),
    'opener_style': opener_config.get('style', 'direct'),
}

# Connection note (max 290 chars to be safe)
cn_templates = [
    f"{first_name} — {signal[:100] if signal else f'been following what {company} is building'}. Quick question: when your AI agents start acting autonomously, what proves each action was authorized? That is what we are building.",
    f"{first_name} — {angle_config.get('hook', 'agent accountability')} is a gap most teams discover too late. We built the authorization receipt layer that fills it. Would love to compare notes on what {company} is seeing.",
    f"{first_name} — saw {signal[:60] if signal else f'what {company} is doing with AI agents'}. We are building cryptographic authorization receipts for exactly this problem space. Thought you would find it relevant.",
]

# Pick best template based on available context
if signal:
    cn = cn_templates[0]
else:
    cn = cn_templates[1]

# Ensure under 290 chars
if len(cn) > 290:
    cn = cn[:287] + '...'

# Short version (under 150 chars)
cn_short = f"{first_name} — {'saw ' + signal[:40] + '. ' if signal else ''}{angle_config.get('hook', 'Agent accountability')} is the gap. We built the receipt layer. Compare notes?"
if len(cn_short) > 150:
    cn_short = cn_short[:147] + '...'

# Message 1 (under 290 chars)  
m1 = f"Appreciate the connect. {angle_config.get('hook', 'The accountability gap in AI agents').capitalize()} is the exact problem we have been heads-down on. We built authorization receipts: signed proof of what each agent was authorized to do, before it acts. Is {company} running into this yet?"
if len(m1) > 290:
    m1 = m1[:287] + '...'

# Followup 1 (under 290 chars)
f1 = f"Concrete example: {company} agent {'takes an action outside its scope' if not signal else 'hits the scenario you described'}. With our receipt system, every action has signed authorization with exact parameters. Dispute resolution in seconds, not weeks. Worth a 15-min walkthrough?"
if len(f1) > 290:
    f1 = f1[:287] + '...'

# Followup 2 (under 290 chars)
f2 = f"Totally get it if you are deep in the build. Standing offer: when who authorized this agent action becomes a customer question for {company}, happy to jam on it. Good luck with everything."
if len(f2) > 290:
    f2 = f2[:287] + '...'

output = {
    'target': {
        'name': name,
        'company': company,
        'title': title,
        'linkedin_url': linkedin,
        'angle': angle,
        'opener': opener_key,
    },
    'messages': {
        'connection_note': cn,
        'connection_note_short': cn_short,
        'message_1': m1,
        'followup_1': f1,
        'followup_2': f2,
    },
    'char_counts': {
        'connection_note': len(cn),
        'connection_note_short': len(cn_short),
        'message_1': len(m1),
        'followup_1': len(f1),
        'followup_2': len(f2),
    },
    'inject_payload': {
        'profile_link': linkedin,
        'first_name': first_name,
        'company_name': company,
        'connection_note': cn,
        'connection_note_short': cn_short,
        'message_1': m1,
        'followup_1': f1,
        'followup_2': f2,
    }
}

print(json.dumps(output, indent=2))
PYEOF
