#!/bin/bash
# Content Quality Gate — R1 reviews blog content before publish.
# Pattern: Extract structured data locally → pipe to R1 for judgment.
#
# Usage: content-quality-gate.sh <content_file.html> [--json-only]
# Exit: 0 = pass, 1 = fail, 2 = system error
#
# Scores: readability, SEO quality, thin content, engagement, internal linking
# R1 returns verdict + scores + specific suggestions

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"
MODEL="${SPARK_MODEL:-deepseek-r1:70b}"

CONTENT_FILE="${1:?Usage: content-quality-gate.sh <content_file.html> [--json-only]}"
JSON_ONLY="${2:-}"

if [ ! -f "$CONTENT_FILE" ]; then
    echo '{"error": "File not found: '"$CONTENT_FILE"'", "verdict": "system_error"}'
    exit 2
fi

# Check Spark is reachable
if ! curl -sf "${SPARK_URL}/api/tags" >/dev/null 2>&1; then
    echo '{"error": "Spark unreachable at '"$SPARK_URL"'", "verdict": "system_error"}'
    exit 2
fi

# Extract metadata and stats from HTML content
export CONTENT_FILE
ANALYSIS=$(python3 << 'PYEOF'
import sys, re, os
from html.parser import HTMLParser

content_file = os.environ['CONTENT_FILE']

class ContentExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.text_parts = []
        self.headings = []
        self.links = {"internal": 0, "external": 0}
        self.images = 0
        self.current_tag = None
        self.metadata = {}
        self.in_comment = False
        
    def handle_comment(self, data):
        # Parse front-matter from HTML comments
        for line in data.strip().split('\n'):
            if ':' in line:
                key, _, val = line.partition(':')
                self.metadata[key.strip()] = val.strip()
    
    def handle_starttag(self, tag, attrs):
        self.current_tag = tag
        attrs_dict = dict(attrs)
        if tag in ('h1','h2','h3','h4','h5','h6'):
            self.headings.append({'level': tag, 'text': ''})
        if tag == 'a' and 'href' in attrs_dict:
            href = attrs_dict['href']
            if 'blog.xdares.com' in href or href.startswith('/'):
                self.links['internal'] += 1
            elif href.startswith('http'):
                self.links['external'] += 1
        if tag == 'img':
            self.images += 1
    
    def handle_data(self, data):
        self.text_parts.append(data)
        if self.current_tag in ('h1','h2','h3','h4','h5','h6') and self.headings:
            self.headings[-1]['text'] += data

with open(content_file) as f:
    html = f.read()

ext = ContentExtractor()
ext.feed(html)

full_text = ' '.join(ext.text_parts)
words = full_text.split()
word_count = len(words)

# Simple readability: avg words per sentence
sentences = re.split(r'[.!?]+', full_text)
sentences = [s.strip() for s in sentences if s.strip()]
avg_sentence_len = round(sum(len(s.split()) for s in sentences) / max(len(sentences), 1), 1)

# Paragraph count
paragraphs = len(re.findall(r'<p[^>]*>', html))

import json
result = {
    "file": os.path.basename(content_file),
    "metadata": ext.metadata,
    "stats": {
        "word_count": word_count,
        "paragraphs": paragraphs,
        "headings": len(ext.headings),
        "heading_structure": [f"{h['level']}: {h['text'][:60]}" for h in ext.headings[:15]],
        "internal_links": ext.links['internal'],
        "external_links": ext.links['external'],
        "images": ext.images,
        "avg_sentence_length": avg_sentence_len,
        "sentences": len(sentences)
    },
    "first_500_words": ' '.join(words[:500]),
    "last_200_words": ' '.join(words[-200:]) if word_count > 200 else ' '.join(words)
}
print(json.dumps(result, indent=2))
PYEOF
)

if [ $? -ne 0 ]; then
    echo '{"error": "Content extraction failed", "verdict": "system_error"}'
    exit 2
fi

if [ "$JSON_ONLY" = "--json-only" ]; then
    echo "$ANALYSIS"
    exit 0
fi

# Build R1 prompt
PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" << 'PROMPTEOF'
You are a content quality reviewer for a blog about party games, drinking games, and dares for adults (blog.xdares.com). 

Review this blog post analysis and score it on these dimensions:

1. **Readability** (1-10): Is the writing engaging, clear, and well-structured? Good use of headings, lists, formatting?
2. **SEO Quality** (1-10): Does it have a clear target keyword, good title, proper heading hierarchy, sufficient length?
3. **Thin Content Check** (1-10): Is this substantive content or filler? Does it provide real value? (1=thin/filler, 10=comprehensive)
4. **Engagement** (1-10): Would someone actually read this? Is it fun, useful, or interesting? Does the voice match an 18+ party/games audience?
5. **Internal Linking** (1-10): Does it link to related content on the same site? (Check internal_links count)

RULES:
- Score honestly. This is a quality gate — if content is thin or bad, say so.
- A post PASSES if ALL scores are >= 6 AND average is >= 7.
- If it FAILS, give specific, actionable suggestions for improvement.
- Thin content (< 800 words with no depth) should always fail.
- Good listicle content (like game guides) with 2000+ words and clear structure should score well.

IMPORTANT: Respond with ONLY valid JSON, no other text. Format:
{
  "verdict": "pass" or "fail",
  "scores": {"readability": N, "seo": N, "thin_content": N, "engagement": N, "internal_linking": N},
  "average": N.N,
  "summary": "One sentence overall assessment",
  "suggestions": ["specific improvement 1", "specific improvement 2"]
}

PROMPTEOF

echo "" >> "$PROMPT_FILE"
echo "Content analysis:" >> "$PROMPT_FILE"
echo "$ANALYSIS" >> "$PROMPT_FILE"

# Call R1
export PROMPT_FILE SPARK_URL MODEL

RESULT=$(python3 << 'PYEOF'
import json, re, os, urllib.request, sys

prompt_file = os.environ['PROMPT_FILE']
spark_url = os.environ['SPARK_URL']
model = os.environ['MODEL']

with open(prompt_file) as f:
    prompt = f.read()

try:
    payload = json.dumps({
        'model': model,
        'prompt': prompt,
        'stream': False,
        'options': {'temperature': 0.1, 'num_predict': 800}
    }).encode()
    req = urllib.request.Request(f'{spark_url}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
    resp = urllib.request.urlopen(req, timeout=300)
    data = json.loads(resp.read())
    response = data.get('response', '')
    eval_duration = data.get('eval_duration', 0)
    eval_count = data.get('eval_count', 0)
except Exception as e:
    print(json.dumps({'verdict': 'system_error', 'error': f'R1 call failed: {e}', 'model': model}))
    sys.exit(2)

# Strip thinking tags and markdown fences
response = re.sub(r'<think>.*?</think>', '', response, flags=re.DOTALL).strip()
response = re.sub(r'```(?:json)?\s*', '', response).strip()

# Extract JSON object
match = re.search(r'\{.*\}', response, re.DOTALL)
if match:
    try:
        result = json.loads(match.group())
        # Validate required fields
        assert 'verdict' in result and result['verdict'] in ('pass', 'fail')
        assert 'scores' in result
        # Add metadata
        result['model'] = model
        if eval_duration > 0:
            result['r1_time_seconds'] = round(eval_duration / 1e9, 1)
        if eval_count > 0:
            result['r1_tokens'] = eval_count
        print(json.dumps(result, indent=2))
        sys.exit(0 if result['verdict'] == 'pass' else 1)
    except (json.JSONDecodeError, AssertionError) as e:
        print(json.dumps({'verdict': 'system_error', 'error': f'Parse error: {e}', 'raw': response[:500], 'model': model}))
        sys.exit(2)
else:
    print(json.dumps({'verdict': 'system_error', 'error': 'No JSON found', 'raw': response[:500], 'model': model}))
    sys.exit(2)
PYEOF
)

EXIT_CODE=$?
rm -f "$PROMPT_FILE"
echo "$RESULT"
exit $EXIT_CODE
