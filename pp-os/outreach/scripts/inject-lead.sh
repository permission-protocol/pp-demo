#!/usr/bin/env bash
#
# PP Lead Injector — Generates messages and injects a lead into Expandi
#
# Usage:
#   ./inject-lead.sh '{"name":"John","company":"Acme","linkedin_url":"...","signal":"...","angle":"incident_response"}'
#   echo '<json>' | ./inject-lead.sh
#   ./inject-lead.sh target.json
#   ./inject-lead.sh target.json --dry-run
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CREDS_FILE="${HOME}/.openclaw/secrets/expandi-api.json"
DRY_RUN=""

# Parse args
TARGET_INPUT=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN="true" ;;
    *)
      if [ -f "$arg" ]; then
        TARGET_INPUT=$(cat "$arg")
      else
        TARGET_INPUT="$arg"
      fi
      ;;
  esac
done

# Read from stdin if no arg
if [ -z "$TARGET_INPUT" ]; then
  TARGET_INPUT=$(cat -)
fi

if [ -z "$TARGET_INPUT" ]; then
  echo "ERROR: No target provided" >&2
  echo "Usage: ./inject-lead.sh '<json>' [--dry-run]" >&2
  exit 1
fi

# Load Expandi creds
if [ ! -f "$CREDS_FILE" ]; then
  echo "ERROR: Expandi creds not found at $CREDS_FILE" >&2
  exit 1
fi

ASSIGN_URL=$(python3 -c "import json; d=json.load(open('$CREDS_FILE')); print(d['assign_url'] + '?key=' + d['key'] + '&secret=' + d['secret'])")

# Generate messages
echo "🔧 Generating messages..."
GENERATED=$(echo "$TARGET_INPUT" | bash "${SCRIPT_DIR}/generate-messages.sh")

if [ -z "$GENERATED" ]; then
  echo "ERROR: Message generation failed" >&2
  exit 1
fi

# Extract inject payload
INJECT_PAYLOAD=$(echo "$GENERATED" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)['inject_payload']))")
TARGET_NAME=$(echo "$GENERATED" | python3 -c "import sys,json; print(json.load(sys.stdin)['target']['name'])")
TARGET_COMPANY=$(echo "$GENERATED" | python3 -c "import sys,json; print(json.load(sys.stdin)['target']['company'])")

# Show what we're about to do
echo ""
echo "📋 Target: $TARGET_NAME ($TARGET_COMPANY)"
echo ""
echo "$GENERATED" | python3 -c "
import sys, json
d = json.load(sys.stdin)
msgs = d['messages']
counts = d['char_counts']
for key in ['connection_note', 'connection_note_short', 'message_1', 'followup_1', 'followup_2']:
    status = '✅' if counts[key] <= 300 else '❌'
    print(f\"  {status} {key}: {counts[key]} chars\")
    print(f\"     {msgs[key][:100]}...\")
    print()
"

if [ -n "$DRY_RUN" ]; then
  echo "🏁 DRY RUN — not injecting"
  echo ""
  echo "Payload:"
  echo "$INJECT_PAYLOAD" | python3 -m json.tool
  exit 0
fi

# Inject into Expandi
echo "💉 Injecting into Expandi campaign..."
RESULT=$(curl -s -X POST "$ASSIGN_URL" \
  -H "Content-Type: application/json" \
  -d "$INJECT_PAYLOAD" 2>&1)

echo "📬 Result: $RESULT"

# Check for warnings
if echo "$RESULT" | grep -q "placeholders_not_added"; then
  echo ""
  echo "⚠️  WARNING: Some placeholders were rejected (too long)"
  echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print('  Rejected:', d.get('placeholders_not_added', 'unknown'))" 2>/dev/null
fi

if echo "$RESULT" | grep -q "Added to campaign"; then
  echo "✅ Successfully injected $TARGET_NAME into Expandi campaign"
fi
