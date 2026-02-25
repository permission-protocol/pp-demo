#!/bin/bash
# Usage: echo "prompt" | ./scripts/spark-query.sh [--tokens 4000] [--temp 0.7]
set -euo pipefail

SPARK_URL="http://100.111.31.56:11434/api/generate"
MODEL="deepseek-r1:70b"
TOKENS="4000"
TEMP="0.7"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tokens)
      TOKENS="${2:-}"
      shift 2
      ;;
    --temp)
      TEMP="${2:-}"
      shift 2
      ;;
    *)
      echo "Usage: echo \"prompt\" | ./scripts/spark-query.sh [--tokens 4000] [--temp 0.7]" >&2
      exit 1
      ;;
  esac
done

PROMPT="$(cat -)"
if [[ -z "${PROMPT// }" ]]; then
  echo "ERROR: prompt is empty" >&2
  exit 1
fi

echo "⚠️ Sending to local R1 model (no data leaves your network)" >&2

if ! curl -s --max-time 5 "$SPARK_URL" >/dev/null 2>&1; then
  echo "ERROR: DGX Spark not reachable at $SPARK_URL" >&2
  exit 1
fi

RESPONSE="$(
  curl -s "$SPARK_URL" \
    --max-time 600 \
    -d "$(python3 -c "
import json, sys
print(json.dumps({
    'model': '$MODEL',
    'prompt': sys.stdin.read(),
    'stream': False,
    'options': {'num_predict': int('$TOKENS'), 'temperature': float('$TEMP')}
}))" <<< "$PROMPT")"
)"

TEXT="$(
  echo "$RESPONSE" | python3 -c "
import json, sys, re
try:
    data = json.load(sys.stdin)
    text = data.get('response', '')
    text = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL).strip()
    print(text)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"
)"

if [[ -z "${TEXT// }" ]]; then
  echo "ERROR: R1 returned empty response" >&2
  exit 1
fi

printf '%s\n' "$TEXT"
