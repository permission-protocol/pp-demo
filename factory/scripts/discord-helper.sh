#!/usr/bin/env bash
# Factory Discord Helper
# Shared functions for posting to Discord channels.
# Source this from other factory scripts.

FACTORY_DIR="${FACTORY_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FACTORY_CONFIG="$FACTORY_DIR/config.json"
DISCORD_CHANNELS="$FACTORY_DIR/discord-channels.json"
DISCORD_TOKEN=$(cat ~/.openclaw/secrets/discord-token.txt 2>/dev/null || echo "")
DISCORD_API="https://discord.com/api/v10"

# ── Config helpers ──
factory_config() {
  jq -r "$1" "$FACTORY_CONFIG" 2>/dev/null
}

GEMINI_MODEL=$(factory_config '.gemini_model')
GEMINI_KEY_PATH=$(factory_config '.gemini_key_path' | sed "s|^~|$HOME|")
CODEX_TIMEOUT=$(factory_config '.codex_timeout_seconds')
QA_TIMEOUT=$(factory_config '.qa_check_timeout_seconds')
MAX_RETRIES=$(factory_config '.max_retries')

# Channel IDs (from config.json)
CH_CONTROL=$(factory_config '.discord_channels.control')
CH_PIPELINE=$(factory_config '.discord_channels.pipeline')
CH_WIP=$(factory_config '.discord_channels.wip')
CH_DONE=$(factory_config '.discord_channels.done')

# ── Gemini API helper ──
# Usage: gemini_generate <prompt_file> [temperature]
gemini_generate() {
  local PROMPT_FILE="$1"
  local TEMP="${2:-0.7}"
  local KEY
  KEY=$(python3 -c "import json; print(json.load(open('$GEMINI_KEY_PATH'))['api_key'])" 2>/dev/null)

  if [[ -z "$KEY" ]]; then
    echo "❌ Gemini key not found at $GEMINI_KEY_PATH" >&2
    return 1
  fi

  local RESPONSE_FILE
  RESPONSE_FILE=$(mktemp)
  local REQUEST_FILE
  REQUEST_FILE=$(mktemp)

  # Build request JSON with Python (avoids shell escaping issues)
  python3 - "$PROMPT_FILE" "$TEMP" "$REQUEST_FILE" << 'PYEOF'
import json, sys
prompt_file, temp, out_file = sys.argv[1], float(sys.argv[2]), sys.argv[3]
with open(prompt_file) as f:
    prompt_text = f.read()
payload = {
    "contents": [{"parts": [{"text": prompt_text}]}],
    "generationConfig": {"temperature": temp}
}
with open(out_file, 'w') as f:
    json.dump(payload, f)
PYEOF

  curl -s "https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${KEY}" \
    -H 'Content-Type: application/json' \
    -d "@${REQUEST_FILE}" \
    -o "$RESPONSE_FILE" 2>/dev/null

  rm -f "$REQUEST_FILE"

  local TEXT
  TEXT=$(python3 - "$RESPONSE_FILE" << 'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    r = json.load(f)
print(r['candidates'][0]['content']['parts'][0]['text'].strip())
PYEOF
  )

  rm -f "$RESPONSE_FILE"

  if [[ -z "$TEXT" ]]; then
    echo "❌ Gemini returned empty response" >&2
    return 1
  fi

  echo "$TEXT"
}

# ── Post a message to a channel ──
# Usage: discord_post <channel_id> <message>
discord_post() {
  local CHANNEL="$1"
  local MSG="$2"
  
  if [[ -z "$DISCORD_TOKEN" ]] || [[ -z "$CHANNEL" ]]; then
    echo "[discord] skipped (no token or channel)"
    return 0
  fi
  
  # Truncate to Discord's 2000 char limit
  if [[ ${#MSG} -gt 1950 ]]; then
    MSG="${MSG:0:1950}..."
  fi
  
  local RESPONSE
  RESPONSE=$(curl -s -X POST "$DISCORD_API/channels/$CHANNEL/messages" \
    -H "Authorization: Bot $DISCORD_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg content "$MSG" '{content: $content}')" 2>/dev/null)
  
  echo "$RESPONSE" | jq -r '.id // empty' 2>/dev/null
}

# ── Create a thread in a channel ──
# Usage: discord_thread_create <channel_id> <thread_name> [message]
# Returns: thread_id
discord_thread_create() {
  local CHANNEL="$1"
  local NAME="$2"
  local MSG="${3:-Thread created}"
  
  if [[ -z "$DISCORD_TOKEN" ]] || [[ -z "$CHANNEL" ]]; then
    echo ""
    return 0
  fi
  
  # Truncate thread name to 100 chars (Discord limit)
  NAME="${NAME:0:100}"
  
  local RESPONSE
  RESPONSE=$(curl -s -X POST "$DISCORD_API/channels/$CHANNEL/threads" \
    -H "Authorization: Bot $DISCORD_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg name "$NAME" --argjson type 11 --argjson auto 4320 '{
      name: $name,
      type: $type,
      auto_archive_duration: $auto
    }')" 2>/dev/null)
  
  local THREAD_ID
  THREAD_ID=$(echo "$RESPONSE" | jq -r '.id // empty' 2>/dev/null)
  
  # Post initial message in the thread and add Rod
  if [[ -n "$THREAD_ID" ]]; then
    discord_post "$THREAD_ID" "$MSG" > /dev/null
    # Add Rod so thread shows in his sidebar
    curl -s -X PUT "$DISCORD_API/channels/$THREAD_ID/thread-members/715570578555273288" \
      -H "Authorization: Bot $DISCORD_TOKEN" > /dev/null 2>&1
  fi
  
  echo "$THREAD_ID"
}

# ── Post to a thread ──
# Usage: discord_thread_post <thread_id> <message>
discord_thread_post() {
  discord_post "$1" "$2"
}

# ── Rename a thread (update emoji prefix) ──
# Usage: discord_thread_rename <thread_id> <new_name>
discord_thread_rename() {
  local THREAD_ID="$1"
  local NEW_NAME="${2:0:100}"
  
  if [[ -z "$DISCORD_TOKEN" ]] || [[ -z "$THREAD_ID" ]]; then
    return 0
  fi
  
  curl -s -X PATCH "$DISCORD_API/channels/$THREAD_ID" \
    -H "Authorization: Bot $DISCORD_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg name "$NEW_NAME" '{name: $name}')" > /dev/null 2>&1
}

# ── Archive a thread ──
# Usage: discord_thread_archive <thread_id>
discord_thread_archive() {
  local THREAD_ID="$1"
  
  if [[ -z "$DISCORD_TOKEN" ]] || [[ -z "$THREAD_ID" ]]; then
    return 0
  fi
  
  curl -s -X PATCH "$DISCORD_API/channels/$THREAD_ID" \
    -H "Authorization: Bot $DISCORD_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"archived": true, "locked": true}' > /dev/null 2>&1
}

# ── Get status emoji ──
# Usage: status_emoji <status>
status_emoji() {
  case "$1" in
    idea-generated|backlog-ready) echo "⚪" ;;
    prd-wip|prd-ready)            echo "📝" ;;
    build-wip)                     echo "🟡" ;;
    build-ready)                   echo "✅" ;;
    qa-wip)                        echo "🔵" ;;
    qa-passed)                     echo "✅" ;;
    qa-failed)                     echo "🔴" ;;
    shipped)                       echo "🚀" ;;
    *)                             echo "⚪" ;;
  esac
}

# ── Format a WIP thread name ──
# Usage: wip_thread_name <status> <idea_id> <title>
wip_thread_name() {
  local EMOJI
  EMOJI=$(status_emoji "$1")
  echo "$EMOJI $2: $3"
}

# ── Store thread ID mapping ──
# Usage: save_thread_id <idea_id> <thread_type> <thread_id>
# thread_type: pipeline | wip
THREAD_MAP="$FACTORY_DIR/thread-map.json"

save_thread_id() {
  local IDEA="$1"
  local TYPE="$2"
  local TID="$3"
  
  if [[ ! -f "$THREAD_MAP" ]]; then
    echo '{}' > "$THREAD_MAP"
  fi
  
  local UPDATED
  UPDATED=$(jq --arg idea "$IDEA" --arg type "$TYPE" --arg tid "$TID" \
    '.[$idea][$type] = $tid' "$THREAD_MAP" 2>/dev/null || echo '{}')
  
  # Handle nested creation
  UPDATED=$(jq --arg idea "$IDEA" --arg type "$TYPE" --arg tid "$TID" \
    'if .[$idea] then .[$idea][$type] = $tid else .[$idea] = {($type): $tid} end' \
    "$THREAD_MAP" 2>/dev/null)
  
  echo "$UPDATED" > "$THREAD_MAP"
}

# ── Get thread ID ──
# Usage: get_thread_id <idea_id> <thread_type>
get_thread_id() {
  local IDEA="$1"
  local TYPE="$2"
  
  if [[ -f "$THREAD_MAP" ]]; then
    jq -r --arg idea "$IDEA" --arg type "$TYPE" '.[$idea][$type] // empty' "$THREAD_MAP" 2>/dev/null
  fi
}

# ═══════════════════════════════════════════════════════
# JSONL Helpers — prevent corruption
# ═══════════════════════════════════════════════════════

# Append a JSON object to a JSONL file (always compact)
# Usage: jsonl_append <file> <json_object>
jsonl_append() {
  local FILE="$1"
  local JSON="$2"
  echo "$JSON" | jq -c '.' >> "$FILE"
}

# Update a field on an idea in ideas.jsonl by ID
# Usage: update_idea_field <idea_id> <jq_expression>
# Example: update_idea_field "idea-001" '.status = "qa-passed"'
update_idea_field() {
  local IDEA_ID="$1"
  local JQ_EXPR="$2"
  local IDEAS="${FACTORY_DIR}/ideas.jsonl"
  local TEMP
  TEMP=$(mktemp)
  
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local LINE_ID
    LINE_ID=$(echo "$line" | jq -r '.id')
    if [[ "$LINE_ID" == "$IDEA_ID" ]]; then
      echo "$line" | jq -c "$JQ_EXPR | .updated_at = (now | strftime(\"%Y-%m-%dT%H:%M:%SZ\"))"
    else
      echo "$line" | jq -c '.'
    fi
  done < "$IDEAS" > "$TEMP"
  
  mv "$TEMP" "$IDEAS"
}
