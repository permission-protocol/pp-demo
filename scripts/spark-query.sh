#!/bin/bash
# Usage: echo "prompt" | ./scripts/spark-query.sh [--tokens 4000] [--temp 0.7]
set -euo pipefail

SPARK_URL="http://100.111.31.56:11434/api/generate"
MODEL="deepseek-r1:70b"
TOKENS="4000"
TEMP="0.7"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tokens) TOKENS="${2:-}"; shift 2 ;;
    --temp) TEMP="${2:-}"; shift 2 ;;
    *) echo "Usage: echo \"prompt\" | ./scripts/spark-query.sh [--tokens 4000] [--temp 0.7]" >&2; exit 1 ;;
  esac
done

PROMPT="$(cat -)"
if [[ -z "${PROMPT// }" ]]; then
  echo "ERROR: prompt is empty" >&2
  exit 1
fi

echo "⚠️ Sending to local R1 model (no data leaves your network)" >&2

# Build JSON payload via python (avoids bash quoting hell)
PAYLOAD=$(printf '%s' "$PROMPT" | python3 -c "
import json, sys
prompt = sys.stdin.read()
print(json.dumps({
    'model': '$MODEL',
    'prompt': prompt,
    'stream': False,
    'options': {'num_predict': $TOKENS, 'temperature': $TEMP}
}))
")

RESPONSE=$(curl -s --max-time 600 "$SPARK_URL" -d "$PAYLOAD" 2>/dev/null)

if [[ -z "$RESPONSE" ]]; then
  echo "ERROR: DGX Spark not reachable or empty response" >&2
  exit 1
fi

# Extract response, strip <think> blocks
python3 -c "
import json, sys, re
data = json.load(sys.stdin)
text = data.get('response', '')
text = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL).strip()
if not text:
    print('ERROR: R1 returned empty response', file=sys.stderr)
    sys.exit(1)
print(text)
" <<< "$RESPONSE"

