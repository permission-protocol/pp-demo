#!/bin/bash
# Strategy Analysis via R1 — takes metrics + rule-based recommendations
# and produces deeper strategic reasoning.
#
# Pattern: Rule-based script generates structured data → R1 reasons about it.
# Replaces static recommendations with adaptive strategic thinking.
#
# Usage: strategy-r1-analyze.sh [--latest /path/to/latest.json] [--recommendations /path/to/recommendations.json]
# Output: JSON with strategic analysis, non-obvious insights, and prioritized actions
# Exit: 0 = success, 2 = system error

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"
MODEL="${SPARK_MODEL:-deepseek-r1:70b}"

GOAL_DIR="$HOME/.openclaw/workspace/goals/xdares-seo-growth"
LATEST="${LATEST:-$GOAL_DIR/metrics/latest.json}"
RECOMMENDATIONS="${RECOMMENDATIONS:-$GOAL_DIR/metrics/recommendations.json}"
HISTORY="${HISTORY:-$GOAL_DIR/metrics/history.jsonl}"
STATE="${STATE:-$GOAL_DIR/state.json}"
OUTPUT="${OUTPUT:-$GOAL_DIR/metrics/r1-strategy.json}"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --latest) LATEST="$2"; shift 2 ;;
        --recommendations) RECOMMENDATIONS="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate inputs
for f in "$LATEST" "$RECOMMENDATIONS"; do
    if [ ! -f "$f" ]; then
        echo "{\"error\": \"Missing file: $f\", \"verdict\": \"system_error\"}"
        exit 2
    fi
done

# Check Spark
if ! curl -sf "${SPARK_URL}/api/tags" >/dev/null 2>&1; then
    echo "{\"error\": \"Spark unreachable at $SPARK_URL\", \"verdict\": \"system_error\"}"
    exit 2
fi

# Build context package for R1
export LATEST RECOMMENDATIONS HISTORY STATE
CONTEXT=$(python3 << 'PYEOF'
import json, os, sys

latest_file = os.environ['LATEST']
rec_file = os.environ['RECOMMENDATIONS']
history_file = os.environ.get('HISTORY', '')
state_file = os.environ.get('STATE', '')

with open(latest_file) as f:
    latest = json.load(f)

with open(rec_file) as f:
    recommendations = json.load(f)

# Get last 7 history snapshots for trend context
history = []
if os.path.exists(history_file):
    with open(history_file) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    history.append(json.loads(line))
                except:
                    pass
    history = history[-7:]  # Last 7 snapshots

# Get queue info from state
queue_summary = []
if os.path.exists(state_file):
    try:
        with open(state_file) as f:
            state = json.load(f)
        tasks = state.get('tasks', {}).get('queue', state.get('queue', []))
        if isinstance(tasks, list):
            for t in tasks[:10]:
                if isinstance(t, dict):
                    queue_summary.append({
                        'id': t.get('id'),
                        'type': t.get('type'),
                        'title': t.get('title', t.get('description', ''))[:80],
                        'status': t.get('status', 'unknown')
                    })
    except:
        pass

# Extract key metrics from history for trend
trend_data = []
for h in history:
    ga4 = h.get('ga4', {})
    ov = ga4.get('overview', {})
    sc = h.get('searchConsole', h.get('search_console', {}))
    queries = sc.get('queries', {}) if isinstance(sc, dict) else {}
    trend_data.append({
        'date': h.get('date', 'unknown'),
        'sessions': ov.get('sessions_thisWeek', ov.get('sessions')),
        'engaged': ov.get('engagedSessions_thisWeek', ov.get('engagedSessions')),
        'avg_duration': round(ov.get('avgSessionDuration_thisWeek', ov.get('avgSessionDuration', 0)) or 0, 1),
        'sc_clicks': queries.get('totalClicks'),
        'sc_impressions': queries.get('totalImpressions'),
    })

# Build compact context
context = {
    'current_metrics': {
        'date': latest.get('date'),
        'ga4_overview': latest.get('ga4', {}).get('overview', {}),
        'sources': latest.get('ga4', {}).get('sources', []),
        'geo': latest.get('ga4', {}).get('geo', [])[:5],
        'search_console': latest.get('searchConsole', latest.get('search_console', {})),
        'kickofflabs': latest.get('kickofflabs', {}),
    },
    'rule_based_analysis': recommendations,
    'trend_history': trend_data,
    'queue_summary': queue_summary,
    'blog_posts_live': 91,  # From state
}

print(json.dumps(context, indent=2))
PYEOF
)

if [ $? -ne 0 ]; then
    echo '{"error": "Context extraction failed", "verdict": "system_error"}'
    exit 2
fi

# Build R1 prompt
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" << 'PROMPTEOF'
You are a growth strategist analyzing metrics for Xdares (xdares.com), an 18+ dare-based creator economy platform. The blog (blog.xdares.com) is the primary organic acquisition channel with ~91 posts live.

You have:
1. Current metrics (GA4, Search Console, waitlist)
2. Rule-based recommendations (from a Python script)
3. 7-day trend history
4. Current task queue

Your job is to go BEYOND the rule-based recommendations. The script handles obvious patterns — you handle:

## What to analyze:
1. **Cross-signal patterns**: What do the metrics say when read TOGETHER? (e.g., high sessions but low engagement = wrong audience)
2. **Hidden opportunities**: What's the script missing? Look at source/geo/query combinations.
3. **Strategic risks**: What could go wrong in the next 2 weeks? What assumptions are fragile?
4. **Resource allocation**: Given limited daily budget (10 tasks/day), what's the highest-leverage use of execution capacity?
5. **Goal reality check**: Is the current goal realistic? Should targets/deadlines be adjusted?
6. **Non-obvious moves**: What's one thing NOT in the recommendations that could 2x a key metric?

## Rules:
- Be specific and actionable. "Improve SEO" is useless. "Create a hub page for 'drinking games' linking to the 15 existing posts" is useful.
- Challenge the rule-based recommendations if they're wrong or suboptimal.
- If data is insufficient for a conclusion, say so rather than guessing.
- Focus on the 1-3 highest-leverage insights, not a laundry list.

CRITICAL INSTRUCTION: Your ENTIRE response must be a single JSON object. No markdown, no text before or after. No "Final Answer:" prefix. Start with { and end with }. Format:
{
  "strategic_assessment": "2-3 sentence overall assessment of current trajectory",
  "cross_signal_insights": ["insight 1", "insight 2"],
  "highest_leverage_action": {"action": "specific action", "reasoning": "why this is #1 priority", "expected_impact": "what changes"},
  "risks": [{"risk": "description", "mitigation": "what to do"}],
  "rule_based_critique": "What the Python script got right/wrong",
  "goal_adjustment": {"recommended": true/false, "new_target": "if applicable", "reasoning": "why"},
  "non_obvious_move": {"action": "description", "reasoning": "why this could work"}
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
        'options': {'temperature': 0.1, 'num_predict': 2000}
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

# Try to extract JSON first
match = re.search(r'\{.*\}', response, re.DOTALL)
result = None

if match:
    try:
        result = json.loads(match.group())
    except json.JSONDecodeError:
        pass

# If no valid JSON, convert markdown response to structured JSON
if result is None:
    # R1 often returns markdown despite JSON instructions — parse it
    sections = re.split(r'\n\d+\.\s+\*\*|^##\s+', response, flags=re.MULTILINE)
    insights = []
    for s in sections:
        s = s.strip()
        if s and len(s) > 20:
            # Clean markdown
            clean = re.sub(r'\*\*([^*]+)\*\*', r'\1', s)
            clean = re.sub(r'\n\s*[-•]\s*', '; ', clean)
            clean = clean.replace('\n', ' ').strip()
            if clean:
                insights.append(clean[:300])
    
    result = {
        'strategic_assessment': insights[0] if insights else response[:300],
        'cross_signal_insights': insights[1:4] if len(insights) > 1 else [],
        'highest_leverage_action': {
            'action': insights[1] if len(insights) > 1 else 'See raw analysis',
            'reasoning': 'Extracted from R1 markdown response',
            'expected_impact': 'See details'
        },
        'risks': [],
        'rule_based_critique': 'R1 provided markdown analysis instead of structured JSON',
        'goal_adjustment': {'recommended': False, 'reasoning': 'See raw analysis'},
        'non_obvious_move': {'action': insights[-1] if insights else 'N/A', 'reasoning': 'From R1 analysis'},
        '_raw_response': response[:2000],
    }

result['_meta'] = {
    'model': model,
    'generated_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
    'r1_time_seconds': round(eval_duration / 1e9, 1) if eval_duration else None,
    'r1_tokens': eval_count or None,
}

# Write to output file
os.makedirs(os.path.dirname(output_file), exist_ok=True)
with open(output_file, 'w') as f:
    json.dump(result, f, indent=2)
    f.write('\n')

print(json.dumps(result, indent=2))
sys.exit(0)
PYEOF

EXIT_CODE=$?
rm -f "$PROMPT_FILE"
exit $EXIT_CODE
