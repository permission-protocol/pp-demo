#!/bin/bash
# R1 Judgment Script — sends unproven criteria to DeepSeek R1 70B on Spark.
# Input: proof map JSON file or stdin
# Output: JSON verdict per unproven criterion
# Exit: 0 = all pass, 1 = any fail, 2 = system error

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"
MODEL="${SPARK_MODEL:-deepseek-r1:70b}"

INPUT="${1:-/dev/stdin}"

# Read proof map
if [ "$INPUT" = "/dev/stdin" ]; then
    PROOF_MAP=$(cat)
else
    PROOF_MAP=$(cat "$INPUT")
fi

# Check Spark is reachable
if ! curl -sf "${SPARK_URL}/api/tags" >/dev/null 2>&1; then
    echo '{"error": "Spark unreachable at '$SPARK_URL'", "verdict": "system_error"}'
    exit 2
fi

# Extract unproven criteria
UNPROVEN=$(echo "$PROOF_MAP" | python3 -c "
import json, sys
data = json.load(sys.stdin)
unproven = [c for c in data.get('criteria', []) if c['status'] == 'unproven']
if not unproven:
    print('NONE')
else:
    print(json.dumps({
        'issue': data['issue'],
        'title': data['title'],
        'unproven_criteria': unproven
    }, indent=2))
")

if [ "$UNPROVEN" = "NONE" ]; then
    echo '{"verdict": "pass", "reason": "No unproven criteria to judge", "criteria": []}'
    exit 0
fi

# Build prompt
PROMPT="You are a QA reviewer for a software project. Below are acceptance criteria that could not be verified by automated tests, along with the available evidence.

For each criterion, judge whether it PASSES or FAILS based on the evidence available.

RULES:
- If evidence shows the work was done but a specific detail can't be measured, that's a PASS (benefit of the doubt).
- FAIL only when evidence suggests the criterion is actually NOT met, or when the work clearly wasn't done.
- 'Cannot verify X deterministically' is NOT grounds for failure — it means the check is limited, not that the work is wrong.

IMPORTANT: Respond with ONLY a JSON array, no other text. Format:
[{\"ac\": \"criterion text\", \"verdict\": \"pass\" or \"fail\", \"reason\": \"one sentence\"}]

Unproven criteria:
$UNPROVEN"

# Call R1 70B + parse response in single Python block (avoids bash variable mangling)
PROMPT_FILE=$(mktemp)
echo "$PROMPT" > "$PROMPT_FILE"
export PROMPT_FILE SPARK_URL MODEL

python3 << 'PYEOF'
import json, re, os, urllib.request, sys

prompt_file = os.environ['PROMPT_FILE']
spark_url = os.environ['SPARK_URL']
model = os.environ['MODEL']

with open(prompt_file) as f:
    prompt = f.read()

# Call R1
try:
    payload = json.dumps({
        'model': model,
        'prompt': prompt,
        'stream': False,
        'options': {'temperature': 0.1, 'num_predict': 1000}
    }).encode()
    req = urllib.request.Request(f'{spark_url}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
    resp = urllib.request.urlopen(req, timeout=300)
    data = json.loads(resp.read())
    response = data.get('response', '')
except Exception as e:
    print(json.dumps({'verdict': 'system_error', 'error': f'R1 call failed: {e}', 'model': model}, indent=2))
    sys.exit(2)

# Strip markdown code fences
response = re.sub(r'```(?:json)?\s*', '', response).strip()

# Extract JSON array
match = re.search(r'\[.*\]', response, re.DOTALL)
if match:
    try:
        verdicts = json.loads(match.group())
        for v in verdicts:
            if 'verdict' not in v or v['verdict'] not in ('pass', 'fail'):
                raise ValueError(f'Invalid verdict: {v}')
        has_fail = any(v['verdict'] == 'fail' for v in verdicts)
        result = {'verdict': 'fail' if has_fail else 'pass', 'criteria': verdicts, 'model': model}
        print(json.dumps(result, indent=2))
        sys.exit(1 if has_fail else 0)
    except (json.JSONDecodeError, ValueError) as e:
        print(json.dumps({'verdict': 'system_error', 'error': f'Parse error: {e}', 'raw_response': response[:500], 'model': model}, indent=2))
        sys.exit(2)
else:
    print(json.dumps({'verdict': 'system_error', 'error': 'No JSON array found', 'raw_response': response[:500], 'model': model}, indent=2))
    sys.exit(2)
PYEOF

EXIT_CODE=$?
rm -f "$PROMPT_FILE"
exit "$EXIT_CODE"
