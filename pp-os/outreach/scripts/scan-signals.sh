#!/usr/bin/env bash
#
# PP Signal Scanner — Detects outreach-worthy signals from HN, GitHub, Twitter
#
# Run daily via cron. Outputs JSON signals to stdout and posts top hits to Discord.
#
# Usage: ./scan-signals.sh [--dry-run]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${SCRIPT_DIR}/../.."
SIGNALS_DIR="${WORKSPACE}/outreach/signals"
LEADS_DIR="${WORKSPACE}/scout/leads"
TODAY=$(date +%Y-%m-%d)
DRY_RUN="${1:-}"

mkdir -p "$SIGNALS_DIR" "$LEADS_DIR"

# --- HN Scan ---
# Search HN for relevant stories from last 24h
echo "📡 Scanning Hacker News..."

HN_KEYWORDS=("MCP" "Model Context Protocol" "CISO" "agent security" "AI enterprise deployment" "AI incident" "prompt injection" "rogue agent" "LLM guardrails bypass" "AI agent security" "AI risk" "VP Engineering")

HN_RESULTS=""
for keyword in "${HN_KEYWORDS[@]}"; do
  # Use HN Algolia API — search last 24h
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$keyword'))")
  result=$(curl -s "https://hn.algolia.com/api/v1/search_by_date?query=${encoded}&tags=story&numericFilters=created_at_i%3E$(date -v-48H +%s 2>/dev/null || date -d '48 hours ago' +%s)&hitsPerPage=10" 2>/dev/null || echo '{"hits":[]}')
  
  # Extract hits with >5 points (filter noise)
  hits=$(echo "$result" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for h in data.get('hits', []):
        if h.get('points', 0) >= 3:
            print(json.dumps({
                'source': 'hn',
                'title': h.get('title', ''),
                'url': h.get('url', f\"https://news.ycombinator.com/item?id={h.get('objectID', '')}\"),
                'hn_url': f\"https://news.ycombinator.com/item?id={h.get('objectID', '')}\",
                'points': h.get('points', 0),
                'comments': h.get('num_comments', 0),
                'author': h.get('author', ''),
                'keyword': '$keyword',
                'created': h.get('created_at', '')
            }))
except:
    pass
" 2>/dev/null)
  
  if [ -n "$hits" ]; then
    HN_RESULTS="${HN_RESULTS}${hits}"$'\n'
  fi
done

# Deduplicate by URL
HN_DEDUPED=$(echo "$HN_RESULTS" | python3 -c "
import sys, json
seen = set()
results = []
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        item = json.loads(line)
        url = item.get('hn_url', item.get('url', ''))
        if url not in seen:
            seen.add(url)
            results.append(item)
    except: pass
# Sort by points descending
results.sort(key=lambda x: x.get('points', 0), reverse=True)
for r in results[:20]:  # Top 20
    print(json.dumps(r))
" 2>/dev/null)

echo "  Found $(echo "$HN_DEDUPED" | grep -c . || echo 0) HN signals"

# --- GitHub Trending Scan ---
echo "📡 Scanning GitHub trending..."

GH_RESULTS=""
GH_KEYWORDS=("AI agent" "agent framework" "autonomous agent" "agent security")

for keyword in "${GH_KEYWORDS[@]}"; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$keyword'))")
  result=$(curl -s "https://api.github.com/search/repositories?q=${encoded}+created:>${TODAY}&sort=stars&order=desc&per_page=5" 2>/dev/null || echo '{"items":[]}')
  
  hits=$(echo "$result" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for r in data.get('items', []):
        if r.get('stargazers_count', 0) >= 10:
            print(json.dumps({
                'source': 'github',
                'title': r.get('full_name', ''),
                'url': r.get('html_url', ''),
                'stars': r.get('stargazers_count', 0),
                'description': (r.get('description', '') or '')[:200],
                'language': r.get('language', ''),
                'keyword': '$keyword',
                'created': r.get('created_at', '')
            }))
except:
    pass
" 2>/dev/null)
  
  if [ -n "$hits" ]; then
    GH_RESULTS="${GH_RESULTS}${hits}"$'\n'
  fi
done

echo "  Found $(echo "$GH_RESULTS" | grep -c . || echo 0) GitHub signals"

# --- Compile & Score ---
echo "📊 Scoring signals..."

ALL_SIGNALS=$(cat << 'PYEOF' | python3 - "$HN_DEDUPED" "$GH_RESULTS"
import sys, json

hn_raw = sys.argv[1] if len(sys.argv) > 1 else ''
gh_raw = sys.argv[2] if len(sys.argv) > 2 else ''

signals = []

# Parse HN
for line in hn_raw.strip().split('\n'):
    if not line.strip(): continue
    try:
        item = json.loads(line)
        # Score: points + comments weight + keyword relevance
        score = 0
        score += min(item.get('points', 0) / 50, 3)  # Up to 3 points for HN score
        score += min(item.get('comments', 0) / 20, 2)  # Up to 2 for discussion
        
        # Keyword relevance boost
        title_lower = item.get('title', '').lower()
        high_relevance = ['mcp', 'model context protocol', 'agent security', 'rogue agent', 'llm guardrails', 'prompt injection', 'ai enterprise deployment', 'ciso']
        med_relevance = ['ai authorization', 'agent framework', 'ai risk', 'ai deployment', 'ai incident']
        
        if any(k in title_lower for k in high_relevance):
            score += 3
        elif any(k in title_lower for k in med_relevance):
            score += 1.5
        
        item['relevance_score'] = round(score, 1)
        item['signal_type'] = 'discussion' if item.get('comments', 0) > 20 else 'news'
        signals.append(item)
    except:
        pass

# Parse GitHub
for line in gh_raw.strip().split('\n'):
    if not line.strip(): continue
    try:
        item = json.loads(line)
        score = min(item.get('stars', 0) / 100, 3)
        desc_lower = (item.get('description', '') or '').lower()
        if any(k in desc_lower for k in ['security', 'governance', 'authorization', 'permission']):
            score += 2
        item['relevance_score'] = round(score, 1)
        item['signal_type'] = 'new_repo'
        signals.append(item)
    except:
        pass

# Sort by relevance score
signals.sort(key=lambda x: x.get('relevance_score', 0), reverse=True)

# Output top signals
output = {
    'scan_date': '%(date)s',
    'total_signals': len(signals),
    'top_signals': signals[:10],
    'all_signals': signals
}

print(json.dumps(output, indent=2))
PYEOF
)

# Save to file
echo "$ALL_SIGNALS" > "${SIGNALS_DIR}/${TODAY}.json"
echo "💾 Saved $(echo "$ALL_SIGNALS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total_signals', 0))" 2>/dev/null || echo '?') signals to ${SIGNALS_DIR}/${TODAY}.json"

# --- Output top signals for Discord ---
TOP_FOR_DISCORD=$(echo "$ALL_SIGNALS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
top = data.get('top_signals', [])[:5]
if not top:
    print('No signals detected today.')
    sys.exit(0)

lines = ['📡 **Daily Signal Scan — $(date +%Y-%m-%d)**\n']
for i, s in enumerate(top, 1):
    emoji = '🔥' if s.get('relevance_score', 0) >= 4 else '⚡' if s.get('relevance_score', 0) >= 2 else '📋'
    source = s.get('source', '?').upper()
    title = s.get('title', 'Untitled')[:80]
    url = s.get('url', s.get('hn_url', ''))
    score = s.get('relevance_score', 0)
    
    if source == 'HN':
        meta = f\"⬆️ {s.get('points', 0)} | 💬 {s.get('comments', 0)}\"
    else:
        meta = f\"⭐ {s.get('stars', 0)}\"
    
    lines.append(f\"{emoji} **{i}. [{source}]** {title}\")
    lines.append(f\"   {meta} | Relevance: {score}/8 | <{url}>\")
    lines.append('')

lines.append('React 👍 on signals worth pursuing → I will enrich targets and draft messages.')
print('\n'.join(lines))
" 2>/dev/null)

echo ""
echo "$TOP_FOR_DISCORD"

if [ "$DRY_RUN" != "--dry-run" ]; then
  echo ""
  echo "📤 Would post to #scout-alerts (use cron to enable)"
fi
"📤 Would post to #scout-alerts (use cron to enable)"
fi
