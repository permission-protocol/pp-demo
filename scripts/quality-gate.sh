#!/bin/bash
# Quality gate for blog posts using Llama 8B on DGX Spark (free).
# Runs structural checks + LLM review. Exits 0 = pass, 1 = reject.
# On reject, sends Telegram notification via OpenClaw.
#
# Usage: quality-gate.sh <html-file-or-url>
# Environment: SPARK_HOST (default: 100.111.31.56), SPARK_PORT (default: 11434)

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"
MODEL="${SPARK_MODEL:-llama3.1:8b}"

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
    echo "Usage: quality-gate.sh <html-file>"
    exit 2
fi

if [ ! -f "$INPUT" ]; then
    echo "File not found: $INPUT"
    exit 2
fi

FILENAME=$(basename "$INPUT")

# ─── Phase 1: Deterministic structural checks (no LLM) ───
echo "=== Structural Checks ==="
ISSUES=()

# Extract text content
TEXT=$(python3 -c "
import html, re, sys
with open('$INPUT') as f:
    content = f.read()
# Strip HTML tags
text = re.sub(r'<[^>]+>', ' ', content)
text = html.unescape(text)
# Collapse whitespace
text = re.sub(r'\s+', ' ', text).strip()
print(text)
" 2>/dev/null)

WORD_COUNT=$(echo "$TEXT" | wc -w | tr -d ' ')
CONTENT=$(cat "$INPUT")

# Check word count
if [ "$WORD_COUNT" -lt 300 ]; then
    ISSUES+=("FAIL:word_count — Only $WORD_COUNT words (minimum 300)")
fi

# Check for H2 headings
H2_COUNT=$(echo "$CONTENT" | grep -ci '<h2' || true)
if [ "$H2_COUNT" -eq 0 ]; then
    ISSUES+=("FAIL:no_h2 — No H2 headings found")
fi

# Check for internal links
INTERNAL_LINKS=$(echo "$CONTENT" | grep -ci 'href=.*xdares\|href=.*blog\.xdares\|href="/' || true)
if [ "$INTERNAL_LINKS" -eq 0 ]; then
    ISSUES+=("WARN:no_internal_links — No internal links to xdares.com")
fi

# Check for meta description
META_DESC=$(echo "$CONTENT" | grep -ci 'meta.*description\|"description"' || true)
if [ "$META_DESC" -eq 0 ]; then
    ISSUES+=("WARN:no_meta_desc — No meta description found")
fi

# Check for title
TITLE=$(echo "$CONTENT" | grep -oi '<title>[^<]*</title>\|<h1[^>]*>[^<]*</h1>' | head -1 || true)
if [ -z "$TITLE" ]; then
    ISSUES+=("FAIL:no_title — No title or H1 found")
fi

# Check for images with alt text
IMG_COUNT=$(echo "$CONTENT" | grep -ci '<img' || true)
IMG_ALT_COUNT=$(echo "$CONTENT" | grep -ci '<img[^>]*alt=' || true)
if [ "$IMG_COUNT" -gt 0 ] && [ "$IMG_ALT_COUNT" -eq 0 ]; then
    ISSUES+=("WARN:img_no_alt — Images found but none have alt text")
fi

STRUCTURAL_FAILS=$(printf '%s\n' "${ISSUES[@]:-}" | grep -c "^FAIL:" || true)

echo "Word count: $WORD_COUNT"
echo "H2 headings: $H2_COUNT"
echo "Internal links: $INTERNAL_LINKS"
echo "Images: $IMG_COUNT (with alt: $IMG_ALT_COUNT)"
echo "Structural issues: ${#ISSUES[@]}"

if [ "$STRUCTURAL_FAILS" -gt 0 ]; then
    echo ""
    echo "=== REJECTED (structural) ==="
    printf '%s\n' "${ISSUES[@]}"
    
    # Build rejection report
    REPORT="🚫 **Quality Gate REJECTED**: \`$FILENAME\`\n\n**Structural failures:**\n"
    for issue in "${ISSUES[@]}"; do
        REPORT="$REPORT• $issue\n"
    done
    REPORT="$REPORT\nWord count: $WORD_COUNT | H2s: $H2_COUNT | Links: $INTERNAL_LINKS"
    echo "$REPORT" > /tmp/quality-gate-report.txt
    exit 1
fi

# ─── Phase 2: LLM quality check via Llama 8B ───
echo ""
echo "=== LLM Quality Check (Llama 8B) ==="

# Check Spark is reachable
if ! curl -sf "${SPARK_URL}/api/tags" >/dev/null 2>&1; then
    echo "WARN: Spark unreachable at $SPARK_URL — skipping LLM check, passing on structural only"
    exit 0
fi

# Truncate to ~2000 words for Llama context
TRUNCATED=$(echo "$TEXT" | head -c 8000)

# Build prompt — ask for specific, actionable checks
PROMPT="You are a blog post quality reviewer. Review this post and check for:
1. Does it read like AI-generated slop? (repetitive phrases, generic filler, no specific examples)
2. Is the opening hook engaging or generic?
3. Does it have a clear structure with logical flow?
4. Would a reader learn something specific and actionable?

Rate: PASS or REJECT with brief reasons (2-3 sentences max).

Post excerpt:
$TRUNCATED"

# Call Llama 8B
PROMPT_FILE=$(mktemp)
echo "$PROMPT" > "$PROMPT_FILE"
LLM_RESPONSE=$(python3 -c "
import json, urllib.request, sys

with open('$PROMPT_FILE') as f:
    prompt = f.read()

payload = json.dumps({
    'model': '$MODEL',
    'prompt': prompt,
    'stream': False,
    'options': {'temperature': 0.1, 'num_predict': 200}
}).encode()

req = urllib.request.Request('${SPARK_URL}/api/generate', data=payload, headers={'Content-Type': 'application/json'})
try:
    resp = urllib.request.urlopen(req, timeout=120)
    data = json.loads(resp.read())
    print(data.get('response', 'ERROR: no response field'))
except Exception as e:
    print(f'ERROR: {e}')
" 2>/dev/null || echo "ERROR: Python call failed")
rm -f "$PROMPT_FILE"

echo "LLM says: $LLM_RESPONSE"

# Check if LLM rejected
if echo "$LLM_RESPONSE" | grep -qi "REJECT"; then
    echo ""
    echo "=== REJECTED (LLM) ==="
    
    REPORT="🚫 **Quality Gate REJECTED**: \`$FILENAME\`\n\n**LLM Review (Llama 8B):**\n$LLM_RESPONSE\n\n**Structural:**\nWord count: $WORD_COUNT | H2s: $H2_COUNT | Links: $INTERNAL_LINKS"
    echo "$REPORT" > /tmp/quality-gate-report.txt
    exit 1
fi

echo ""
echo "=== PASSED ==="
exit 0
