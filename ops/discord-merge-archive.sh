#!/usr/bin/env bash

set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
THREADS_FILE="$WORKSPACE/ops/threads.yaml"
THREADS_MANAGER="$WORKSPACE/ops/threads_manager.py"
THREAD_ID=""
RESOLUTION_ARTIFACT=""
MESSAGE_TEXT=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --thread-id)
      THREAD_ID="$2"
      shift 2
      ;;
    --resolution-artifact)
      RESOLUTION_ARTIFACT="$2"
      shift 2
      ;;
    --message)
      MESSAGE_TEXT="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$THREAD_ID" || -z "$RESOLUTION_ARTIFACT" ]]; then
  echo "Usage: $0 --thread-id <id> --resolution-artifact <text-or-url> [--message <text>] [--dry-run]" >&2
  exit 1
fi

if [[ -z "$MESSAGE_TEXT" ]]; then
  MESSAGE_TEXT="Resolution artifact: $RESOLUTION_ARTIFACT"
fi

TOKEN_FILE="${DISCORD_TOKEN_FILE:-$HOME/.openclaw/secrets/discord-bot-token.txt}"
if [[ -n "${DISCORD_TOKEN:-}" ]]; then
  BOT_TOKEN="$DISCORD_TOKEN"
elif [[ -f "$TOKEN_FILE" ]]; then
  BOT_TOKEN="$(tr -d '\n' < "$TOKEN_FILE")"
else
  echo "Missing Discord token. Set DISCORD_TOKEN or create $TOKEN_FILE" >&2
  exit 1
fi

python3 "$THREADS_MANAGER" validate "$THREADS_FILE" >/dev/null

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "POST /channels/$THREAD_ID/messages => $MESSAGE_TEXT"
  echo "PATCH /channels/$THREAD_ID => {\"archived\":true,\"locked\":true}"
  echo "python3 $THREADS_MANAGER archive --path $THREADS_FILE --thread-id $THREAD_ID --resolution-artifact '$RESOLUTION_ARTIFACT'"
  exit 0
fi

curl -sS -X POST "https://discord.com/api/v10/channels/$THREAD_ID/messages" \
  -H "Authorization: Bot $BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(python3 - <<PY
import json
print(json.dumps({"content": "$MESSAGE_TEXT"}))
PY
)"

curl -sS -X PATCH "https://discord.com/api/v10/channels/$THREAD_ID" \
  -H "Authorization: Bot $BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"archived":true,"locked":true}'

python3 "$THREADS_MANAGER" archive \
  --path "$THREADS_FILE" \
  --thread-id "$THREAD_ID" \
  --resolution-artifact "$RESOLUTION_ARTIFACT"
