#!/bin/bash
# Post to Buffer with an image via GraphQL API
# Usage: buffer-post-image.sh <channel_id> <text> <image_url> <dueAt>
#
# AUTHORITY C — requires approval token before posting.
# Set SKIP_APPROVAL=1 only for manual Rod-initiated posts.

BUFFER_KEY=$(cat ~/.openclaw/secrets/buffer-api-key.txt)
CHANNEL_ID="$1"
TEXT="$2"
IMAGE_URL="$3"
DUE_AT="$4"

if [ -z "$CHANNEL_ID" ] || [ -z "$TEXT" ] || [ -z "$IMAGE_URL" ] || [ -z "$DUE_AT" ]; then
  echo "Usage: buffer-post-image.sh <channel_id> <text> <image_url> <dueAt>"
  exit 1
fi

# Authority C enforcement
if [ "${SKIP_APPROVAL:-0}" != "1" ]; then
  CONTENT_HASH=$(echo -n "$TEXT" | shasum -a 256 | cut -d' ' -f1)
  VERIFY_SCRIPT="$HOME/.openclaw/workspace/company-os/governance/scripts/verify-approval.sh"
  if [ -f "$VERIFY_SCRIPT" ]; then
    VERIFY_RESULT=$(bash "$VERIFY_SCRIPT" "PP-008" "$CONTENT_HASH" 2>&1)
    if ! echo "$VERIFY_RESULT" | grep -q "^APPROVED"; then
      echo "⛔ AUTHORITY C BLOCKED: $VERIFY_RESULT"
      echo "Run: approve.sh PP-008 $CONTENT_HASH"
      exit 1
    fi
    echo "✅ $VERIFY_RESULT"
  fi
fi

TEXT_ESCAPED=$(echo "$TEXT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')

QUERY="mutation { createPost(input: { text: ${TEXT_ESCAPED}, channelId: \"${CHANNEL_ID}\", schedulingType: automatic, mode: customScheduled, dueAt: \"${DUE_AT}\", assets: { images: [{ url: \"${IMAGE_URL}\" }] } }) { ... on PostActionSuccess { post { id text } } ... on MutationError { message } } }"

QUERY_ESCAPED=$(echo "$QUERY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')

curl -s -X POST 'https://api.buffer.com' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${BUFFER_KEY}" \
  -d "{\"query\": ${QUERY_ESCAPED}}"
