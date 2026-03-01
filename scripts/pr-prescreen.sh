#!/bin/bash
# PR Pre-Screen — Two-tier code review via Spark.
# Tier 1: Llama 8B (fast) — linting, style, obvious issues
# Tier 2: DeepSeek R1 70B (deep) — logic bugs, security, architecture
#
# Usage: pr-prescreen.sh <owner/repo> <pr-number>
# Output: JSON review with findings per tier
# Exit: 0 = clean, 1 = issues found, 2 = system error

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"

REPO="${1:?Usage: pr-prescreen.sh <owner/repo> <pr-number>}"
PR="${2:?Missing PR number}"

echo "=== PR Pre-Screen: $REPO #$PR ===" >&2

# Get PR diff
DIFF=$(gh pr diff "$PR" -R "$REPO" 2>/dev/null)
if [ -z "$DIFF" ]; then
    echo '{"error": "Could not fetch PR diff"}'
    exit 2
fi

# Get PR metadata
PR_META=$(gh pr view "$PR" -R "$REPO" --json title,body,files,additions,deletions 2>/dev/null)
TITLE=$(echo "$PR_META" | python3 -c "import json,sys; print(json.load(sys.stdin).get('title',''))" 2>/dev/null)
ADDITIONS=$(echo "$PR_META" | python3 -c "import json,sys; print(json.load(sys.stdin).get('additions',0))" 2>/dev/null)
DELETIONS=$(echo "$PR_META" | python3 -c "import json,sys; print(json.load(sys.stdin).get('deletions',0))" 2>/dev/null)
FILES=$(echo "$PR_META" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for f in d.get('files',[]):
    print(f.get('path',''))
" 2>/dev/null)

echo "Title: $TITLE" >&2
echo "Changes: +$ADDITIONS -$DELETIONS" >&2
echo "Files: $(echo "$FILES" | wc -l | tr -d ' ')" >&2

# Truncate diff for context window (keep first 6000 chars)
DIFF_TRUNCATED=$(echo "$DIFF" | head -c 6000)

# Check Spark
if ! curl -sf "${SPARK_URL}/api/tags" >/dev/null 2>&1; then
    echo '{"error": "Spark unreachable", "verdict": "system_error"}'
    exit 2
fi

# ─── Tier 1: Llama 8B — Fast Lint ───
echo "" >&2
echo "--- Tier 1: Llama 8B Quick Lint ---" >&2

LINT_PROMPT="Review this PR diff for obvious issues ONLY. Check for:
1. Hardcoded secrets, API keys, passwords, tokens
2. Console.log/print statements left in
3. TODO/FIXME/HACK comments
4. Obvious syntax errors
5. Missing error handling (try/catch around async, unchecked nulls)
6. Unused imports or variables

PR: $TITLE
Files: $FILES

Diff:
$DIFF_TRUNCATED

Respond with ONLY a JSON array of findings. If nothing found, respond with [].
Format: [{\"severity\": \"high|medium|low\", \"file\": \"filename\", \"issue\": \"description\"}]"

LINT_FILE=$(mktemp)
echo "$LINT_PROMPT" > "$LINT_FILE"
export LINT_FILE SPARK_URL

LINT_RESULT=$(python3 << 'PYEOF'
import json, re, os, urllib.request, sys

with open(os.environ['LINT_FILE']) as f:
    prompt = f.read()

spark_url = os.environ['SPARK_URL']
payload = json.dumps({
    'model': 'llama3.1:8b',
    'prompt': prompt,
    'stream': False,
    'options': {'temperature': 0.1, 'num_predict': 500}
}).encode()

try:
    req = urllib.request.Request(f'{spark_url}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
    resp = urllib.request.urlopen(req, timeout=60)
    data = json.loads(resp.read())
    response = data.get('response', '')
    time_s = round(data.get('eval_duration', 0) / 1e9, 1)
except Exception as e:
    print(json.dumps({'error': str(e), 'findings': []}))
    sys.exit(0)

# Parse JSON array from response
response = re.sub(r'```(?:json)?\s*', '', response).strip()
match = re.search(r'\[.*\]', response, re.DOTALL)
if match:
    try:
        findings = json.loads(match.group())
        print(json.dumps({'findings': findings, 'time_seconds': time_s, 'model': 'llama3.1:8b'}))
    except:
        print(json.dumps({'findings': [], 'time_seconds': time_s, 'model': 'llama3.1:8b', 'parse_note': 'Could not parse response'}))
else:
    # Check if response indicates no issues
    if any(w in response.lower() for w in ['no issues', 'no findings', 'looks good', 'clean']):
        print(json.dumps({'findings': [], 'time_seconds': time_s, 'model': 'llama3.1:8b'}))
    else:
        print(json.dumps({'findings': [], 'time_seconds': time_s, 'model': 'llama3.1:8b', 'raw': response[:300]}))
sys.exit(0)
PYEOF
)

export LINT_FILE SPARK_URL
rm -f "$LINT_FILE"

LINT_COUNT=$(echo "$LINT_RESULT" | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('findings',[])))" 2>/dev/null || echo "0")
echo "Lint findings: $LINT_COUNT" >&2

# ─── Tier 2: R1 70B — Deep Logic Review ───
echo "" >&2
echo "--- Tier 2: R1 Deep Logic Review ---" >&2

# Write diff to temp file to avoid bash escaping issues
DIFF_FILE=$(mktemp)
echo "$DIFF_TRUNCATED" > "$DIFF_FILE"

export DIFF_FILE SPARK_URL
export PR_TITLE="$TITLE" PR_ADDITIONS="$ADDITIONS" PR_DELETIONS="$DELETIONS" PR_FILES="$FILES"

LOGIC_RESULT=$(python3 << 'PYEOF'
import json, re, os, urllib.request, sys

spark_url = os.environ['SPARK_URL']

with open(os.environ['DIFF_FILE']) as f:
    diff = f.read()

title = os.environ.get('PR_TITLE', '')
additions = os.environ.get('PR_ADDITIONS', '0')
deletions = os.environ.get('PR_DELETIONS', '0')
files = os.environ.get('PR_FILES', '')

prompt = f"""You are a senior code reviewer. Analyze this PR diff for LOGIC and SECURITY issues that a linter cannot catch:

1. Logic bugs: Race conditions, off-by-one errors, incorrect state transitions, broken control flow
2. Security: Auth bypasses, injection vulnerabilities, IDOR, data leaks, insecure defaults
3. Architecture: Breaking changes, tight coupling, missing abstractions, API contract violations
4. Data integrity: Unchecked mutations, missing validation, inconsistent state updates

DO NOT flag style issues, missing comments, or nitpicks. Only real bugs or security risks.

PR: {title} (+{additions}/-{deletions})
Files: {files}

Diff:
{diff}

Respond with a JSON object. Format:
{{"findings": [{{"severity": "critical|high|medium", "file": "filename", "issue": "description", "suggestion": "fix"}}], "summary": "one sentence overall assessment", "approval": "approve|request_changes|comment"}}

If no issues: {{"findings": [], "summary": "Clean PR", "approval": "approve"}}"""

payload = json.dumps({
    'model': 'deepseek-r1:70b',
    'prompt': prompt,
    'stream': False,
    'options': {'temperature': 0.1, 'num_predict': 4000}
}).encode()

try:
    req = urllib.request.Request(f'{spark_url}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
    resp = urllib.request.urlopen(req, timeout=400)
    data = json.loads(resp.read())
    response = data.get('response', '')
    time_s = round(data.get('eval_duration', 0) / 1e9, 1)
    tokens = data.get('eval_count', 0)
except Exception as e:
    print(json.dumps({'findings': [], 'summary': f'R1 error: {e}', 'approval': 'comment', 'time_seconds': 0}))
    sys.exit(0)

# Strip thinking tags and markdown fences
response = re.sub(r'<think>.*?</think>', '', response, flags=re.DOTALL).strip()
response = re.sub(r'```(?:json)?\s*', '', response).strip()

# Try full JSON parse
match = re.search(r'\{.*\}', response, re.DOTALL)
if match:
    try:
        result = json.loads(match.group())
        result['time_seconds'] = time_s
        result['tokens'] = tokens
        result['model'] = 'deepseek-r1:70b'
        print(json.dumps(result))
        sys.exit(0)
    except:
        pass

# Fallback: recover individual finding objects from truncated/malformed JSON
findings = []
finding_pattern = re.findall(
    r'\{\s*"severity"\s*:\s*"([^"]+)"\s*,\s*"file"\s*:\s*"([^"]+)"\s*,\s*"issue"\s*:\s*"([^"]*)"',
    response, re.DOTALL
)
for sev, fpath, issue in finding_pattern:
    findings.append({'severity': sev, 'file': fpath, 'issue': issue[:200], 'suggestion': ''})

# Keyword scan fallback
if not findings:
    for line in response.split('\n'):
        line = line.strip()
        if any(kw in line.lower() for kw in ['bug', 'vuln', 'security', 'race', 'inject', 'bypass', 'leak', 'idor', 'missing validation', 'auth']):
            clean = re.sub(r'\*\*([^*]+)\*\*', r'\1', line)
            if len(clean) > 10:
                findings.append({'severity': 'medium', 'file': '?', 'issue': clean[:200], 'suggestion': ''})

summary_match = re.search(r'"summary"\s*:\s*"([^"]*)"', response)
summary = summary_match.group(1)[:200] if summary_match else response[:200] if response else 'No response from R1'

has_issues = len(findings) > 0 or any(w in response.lower() for w in ['critical', 'vulnerability', 'security risk', 'request_changes'])
approval = 'request_changes' if has_issues else 'approve'

print(json.dumps({
    'findings': findings[:5],
    'summary': summary,
    'approval': approval,
    'time_seconds': time_s,
    'tokens': tokens,
    'model': 'deepseek-r1:70b',
    '_parsed_from': 'partial_json_recovery' if finding_pattern else 'markdown_fallback'
}))
PYEOF
)

rm -f "$DIFF_FILE"

LOGIC_COUNT=$(echo "$LOGIC_RESULT" | python3 -c "
import json,sys,re
raw = sys.stdin.read().strip()
# Find last JSON line
for line in reversed(raw.split('\n')):
    line = line.strip()
    if line.startswith('{'):
        try:
            print(len(json.loads(line).get('findings',[])))
            sys.exit(0)
        except: pass
print(0)
" 2>/dev/null || echo "0")
APPROVAL=$(echo "$LOGIC_RESULT" | python3 -c "
import json,sys
raw = sys.stdin.read().strip()
for line in reversed(raw.split('\n')):
    line = line.strip()
    if line.startswith('{'):
        try:
            print(json.loads(line).get('approval','comment'))
            sys.exit(0)
        except: pass
print('comment')
" 2>/dev/null || echo "comment")
APPROVAL=$(echo "$APPROVAL" | head -1 | tr -d '[:space:]')
APPROVAL=${APPROVAL:-comment}
echo "Logic findings: $LOGIC_COUNT" >&2
echo "R1 approval: $APPROVAL" >&2

# ─── Combined Report ───
LINT_TMP=$(mktemp)
LOGIC_TMP=$(mktemp)
echo "$LINT_RESULT" > "$LINT_TMP"
echo "$LOGIC_RESULT" > "$LOGIC_TMP"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 "$SCRIPT_DIR/pr-prescreen-report.py" "$LINT_TMP" "$LOGIC_TMP" "$REPO" "$PR" "$TITLE" "$ADDITIONS" "$DELETIONS"

rm -f "$LINT_TMP" "$LOGIC_TMP"

# Exit based on findings (sanitize to integers)
LINT_COUNT=$(echo "$LINT_COUNT" | grep -oE '[0-9]+' | head -1)
LOGIC_COUNT=$(echo "$LOGIC_COUNT" | grep -oE '[0-9]+' | head -1)
LINT_COUNT=${LINT_COUNT:-0}
LOGIC_COUNT=${LOGIC_COUNT:-0}
TOTAL=$((LINT_COUNT + LOGIC_COUNT))
if [ "$TOTAL" -gt 0 ] || [ "$APPROVAL" = "request_changes" ]; then
    exit 1
fi
exit 0
