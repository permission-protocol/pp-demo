#!/bin/bash
# Post a Twitter thread to Buffer
# Usage: buffer-thread.sh <channel_id> <dueAt> <tweet1> <tweet2> [tweet3] [tweet4]
# First arg after dueAt is the main tweet text, rest are thread replies

BUFFER_KEY=$(cat ~/.openclaw/secrets/buffer-api-key.txt)
CHANNEL_ID="$1"
DUE_AT="$2"
shift 2

MAIN_TEXT="$1"
shift

# Build thread array
THREAD_ITEMS=""
for tweet in "$@"; do
  ESCAPED=$(echo "$tweet" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')
  if [ -n "$THREAD_ITEMS" ]; then
    THREAD_ITEMS="$THREAD_ITEMS, "
  fi
  THREAD_ITEMS="${THREAD_ITEMS}{text: ${ESCAPED}}"
done

MAIN_ESCAPED=$(echo "$MAIN_TEXT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')

if [ -n "$THREAD_ITEMS" ]; then
  QUERY="mutation { createPost(input: { text: ${MAIN_ESCAPED}, channelId: \"${CHANNEL_ID}\", schedulingType: automatic, mode: customScheduled, dueAt: \"${DUE_AT}\", metadata: { twitter: { thread: [${THREAD_ITEMS}] } } }) { ... on PostActionSuccess { post { id text } } ... on MutationError { message } } }"
else
  QUERY="mutation { createPost(input: { text: ${MAIN_ESCAPED}, channelId: \"${CHANNEL_ID}\", schedulingType: automatic, mode: customScheduled, dueAt: \"${DUE_AT}\" }) { ... on PostActionSuccess { post { id text } } ... on MutationError { message } } }"
fi

QUERY_ESCAPED=$(echo "$QUERY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')

curl -s -X POST 'https://api.buffer.com' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${BUFFER_KEY}" \
  -d "{\"query\": ${QUERY_ESCAPED}}"
