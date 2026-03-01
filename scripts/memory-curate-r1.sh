#!/bin/bash
# Memory Curation via R1 — reads daily memory files, distills insights for MEMORY.md
# Better reasoning = better curation than a quick Sonnet pass.
#
# Usage: memory-curate-r1.sh [--days 7] [--dry-run]
# Output: Suggested additions/removals for MEMORY.md
# Exit: 0 = success, 2 = system error

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"
MODEL="${SPARK_MODEL:-deepseek-r1:70b}"

MEMORY_DIR="$HOME/.openclaw/workspace/memory"
MEMORY_MD="$HOME/.openclaw/workspace/MEMORY.md"
DAYS="${DAYS:-7}"
DRY_RUN="${DRY_RUN:-false}"
OUTPUT="/tmp/memory-curation-result.json"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --days) DAYS="$2"; shift 2 ;;
        --dry-run) DRY_RUN="true"; shift ;;
        *) shift ;;
    esac
done

echo "=== Memory Curation (R1) ===" >&2
echo "Looking back $DAYS days" >&2

# Check Spark
if ! curl -sf "${SPARK_URL}/api/tags" >/dev/null 2>&1; then
    echo '{"error": "Spark unreachable", "verdict": "system_error"}'
    exit 2
fi

# Gather daily memory files from the last N days
export MEMORY_DIR MEMORY_MD DAYS
CONTEXT=$(python3 << 'PYEOF'
import json, os, glob
from datetime import datetime, timedelta

memory_dir = os.environ['MEMORY_DIR']
memory_md = os.environ['MEMORY_MD']
days = int(os.environ['DAYS'])

# Collect recent daily files
daily_content = {}
today = datetime.now()
for i in range(days):
    d = today - timedelta(days=i)
    fname = d.strftime('%Y-%m-%d') + '.md'
    fpath = os.path.join(memory_dir, fname)
    if os.path.exists(fpath):
        with open(fpath) as f:
            content = f.read().strip()
        if content and len(content) > 50:
            daily_content[fname] = content[:3000]  # Cap per file

# Read current MEMORY.md
current_memory = ''
if os.path.exists(memory_md):
    with open(memory_md) as f:
        current_memory = f.read()

# Get section headers from MEMORY.md for structure awareness
sections = [line.strip() for line in current_memory.split('\n') if line.startswith('##')]

output = {
    'daily_files': daily_content,
    'daily_file_count': len(daily_content),
    'memory_md_sections': sections,
    'memory_md_length': len(current_memory),
    'memory_md_last_500': current_memory[-500:] if len(current_memory) > 500 else current_memory,
}

print(json.dumps(output, indent=2))
PYEOF
)

if [ $? -ne 0 ]; then
    echo '{"error": "Context extraction failed"}'
    exit 2
fi

FILE_COUNT=$(echo "$CONTEXT" | python3 -c "import json,sys; print(json.load(sys.stdin)['daily_file_count'])")
echo "Found $FILE_COUNT daily files" >&2

if [ "$FILE_COUNT" -eq 0 ]; then
    echo '{"verdict": "skip", "reason": "No daily memory files found in last '"$DAYS"' days"}'
    exit 0
fi

# Build R1 prompt
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" << 'PROMPTEOF'
You are curating long-term memory for an AI assistant named Charles (partner to Rod, a startup founder).

You have:
1. Recent daily memory files (raw logs of what happened)
2. The current structure and tail of MEMORY.md (curated long-term memory)

Your job is to identify what from the daily files should be ADDED to or UPDATED in MEMORY.md. Think of it like a human reviewing their journal and updating their mental model.

## What belongs in MEMORY.md:
- Strategic decisions and their reasoning
- Lessons learned (especially from failures)
- Debugging patterns that save time
- Project milestones and status changes
- Infrastructure changes (new tools, configs, integrations)
- People/relationship context that matters long-term
- Process improvements and workflow changes

## What does NOT belong:
- Routine task completions (published blog post #87)
- Temporary debugging info (already resolved)
- Raw metrics (belongs in metrics files)
- Duplicate info already in MEMORY.md

## Rules:
- Be selective. MEMORY.md should be curated wisdom, not a dump.
- Each addition should be something future-Charles would thank you for remembering.
- If daily files just show routine work with no insights, say "nothing to curate."
- Flag anything in MEMORY.md that looks outdated and should be removed.

CRITICAL: Respond with ONLY valid JSON. Start with { end with }.
Format:
{
  "verdict": "curate" or "skip",
  "additions": [{"section": "which MEMORY.md section", "content": "what to add", "source": "which daily file"}],
  "updates": [{"section": "section to update", "old_summary": "what's there now", "new_content": "updated version", "reason": "why"}],
  "removals": [{"section": "section", "content_summary": "what to remove", "reason": "why it's outdated"}],
  "summary": "one sentence about what changed this week"
}
PROMPTEOF

echo "" >> "$PROMPT_FILE"
echo "Data:" >> "$PROMPT_FILE"
echo "$CONTEXT" >> "$PROMPT_FILE"

# Call R1
export PROMPT_FILE SPARK_URL MODEL OUTPUT

python3 << 'PYEOF'
import json, re, os, urllib.request, sys
from datetime import datetime

prompt_file = os.environ['PROMPT_FILE']
spark_url = os.environ['SPARK_URL']
model = os.environ['MODEL']
output_file = os.environ['OUTPUT']

with open(prompt_file) as f:
    prompt = f.read()

try:
    payload = json.dumps({
        'model': model,
        'prompt': prompt,
        'stream': False,
        'options': {'temperature': 0.1, 'num_predict': 1500}
    }).encode()
    req = urllib.request.Request(f'{spark_url}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
    resp = urllib.request.urlopen(req, timeout=600)
    data = json.loads(resp.read())
    response = data.get('response', '')
    eval_duration = data.get('eval_duration', 0)
    eval_count = data.get('eval_count', 0)
except Exception as e:
    print(json.dumps({'error': f'R1 call failed: {e}', 'model': model}))
    sys.exit(2)

# Strip thinking tags and markdown
response = re.sub(r'<think>.*?</think>', '', response, flags=re.DOTALL).strip()
response = re.sub(r'```(?:json)?\s*', '', response).strip()

result = None
match = re.search(r'\{.*\}', response, re.DOTALL)
if match:
    try:
        result = json.loads(match.group())
    except:
        pass

# Fallback: parse markdown to structured format
if result is None:
    # Extract actionable items from markdown
    additions = []
    lines = response.split('\n')
    for line in lines:
        line = line.strip()
        if line and len(line) > 30 and not line.startswith('#'):
            clean = re.sub(r'\*\*([^*]+)\*\*', r'\1', line)
            clean = re.sub(r'^[-•*]\s*', '', clean)
            if any(kw in clean.lower() for kw in ['lesson', 'decision', 'pattern', 'milestone', 'important', 'remember', 'infrastructure']):
                additions.append({
                    'section': 'Lessons Learned',
                    'content': clean[:200],
                    'source': 'R1 analysis'
                })
    
    has_content = len(additions) > 0 or 'nothing to curate' in response.lower() or 'skip' in response.lower()
    result = {
        'verdict': 'skip' if not additions else 'curate',
        'additions': additions[:5],
        'updates': [],
        'removals': [],
        'summary': response[:200] if response else 'No actionable curation found',
        '_parsed_from': 'markdown_fallback'
    }

result['_meta'] = {
    'model': model,
    'generated_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
    'r1_time_seconds': round(eval_duration / 1e9, 1) if eval_duration else None,
    'r1_tokens': eval_count or None,
}

with open(output_file, 'w') as f:
    json.dump(result, f, indent=2)
    f.write('\n')

print(json.dumps(result, indent=2))
sys.exit(0)
PYEOF

EXIT_CODE=$?
rm -f "$PROMPT_FILE"
exit $EXIT_CODE
