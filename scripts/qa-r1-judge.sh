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

# Call R1 70B
PROMPT_FILE=$(mktemp)
echo "$PROMPT" > "$PROMPT_FILE"

R1_RESPONSE=$(python3 -c "
import json, urllib.request, sys

with open('$PROMPT_FILE') as f:
    prompt = f.read()

payload = json.dumps({
    'model': '$MODEL',
    'prompt': prompt,
    'stream': False,
    'options': {'temperature': 0.1, 'num_predict': 500}
}).encode()

req = urllib.request.Request('${SPARK_URL}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
try:
    resp = urllib.request.urlopen(req, timeout=300)
    data = json.loads(resp.read())
    print(data.get('response', 'ERROR: no response field'))
except Exception as e:
    print(f'ERROR: {e}')
" 2>/dev/null || echo "ERROR: Python call failed")

rm -f "$PROMPT_FILE"

# Parse R1 response — extract JSON
VERDICT=$(python3 -c "
import json, re, sys

response = '''$R1_RESPONSE'''

# Try to find JSON array in response
match = re.search(r'\[.*\]', response, re.DOTALL)
if match:
    try:
        verdicts = json.loads(match.group())
        # Validate structure
        for v in verdicts:
            if 'verdict' not in v or v['verdict'] not in ('pass', 'fail'):
                raise ValueError(f'Invalid verdict: {v}')
        has_fail = any(v['verdict'] == 'fail' for v in verdicts)
        print(json.dumps({
            'verdict': 'fail' if has_fail else 'pass',
            'criteria': verdicts,
            'model': '$MODEL'
        }, indent=2))
    except (json.JSONDecodeError, ValueError) as e:
        print(json.dumps({
            'verdict': 'system_error',
            'error': f'Failed to parse R1 response: {str(e)}',
            'raw_response': response[:500],
            'model': '$MODEL'
        }, indent=2))
else:
    print(json.dumps({
        'verdict': 'system_error',
        'error': 'No JSON array found in R1 response',
        'raw_response': response[:500],
        'model': '$MODEL'
    }, indent=2))
" 2>/dev/null)

echo "$VERDICT"

# Determine exit code
EXIT_CODE=$(echo "$VERDICT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
v = d.get('verdict', 'system_error')
if v == 'pass': print(0)
elif v == 'fail': print(1)
else: print(2)
" 2>/dev/null || echo 2)

exit "$EXIT_CODE"
