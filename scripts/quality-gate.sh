#!/bin/bash
# Quality gate for blog posts — Structural checks + R1 deep review.
# Phase 1: Fast deterministic structural checks (no LLM)
# Phase 2: DeepSeek R1 70B on Spark for readability/SEO/thin content scoring
#
# Exits: 0 = pass, 1 = reject, 2 = system error
# On reject, writes report to /tmp/quality-gate-report.txt
#
# Usage: quality-gate.sh <html-file>
# Environment: SPARK_HOST, SPARK_PORT, SPARK_MODEL

set -uo pipefail

SPARK_HOST="${SPARK_HOST:-100.111.31.56}"
SPARK_PORT="${SPARK_PORT:-11434}"
SPARK_URL="http://${SPARK_HOST}:${SPARK_PORT}"

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

TEXT=$(python3 -c "
import html, re, sys
with open('$INPUT') as f:
    content = f.read()
text = re.sub(r'<[^>]+>', ' ', content)
text = html.unescape(text)
text = re.sub(r'\s+', ' ', text).strip()
print(text)
" 2>/dev/null)

WORD_COUNT=$(echo "$TEXT" | wc -w | tr -d ' ')
CONTENT=$(cat "$INPUT")

if [ "$WORD_COUNT" -lt 300 ]; then
    ISSUES+=("FAIL:word_count — Only $WORD_COUNT words (minimum 300)")
fi

H2_COUNT=$(echo "$CONTENT" | grep -ci '<h2' || true)
if [ "$H2_COUNT" -eq 0 ]; then
    ISSUES+=("FAIL:no_h2 — No H2 headings found")
fi

INTERNAL_LINKS=$(echo "$CONTENT" | grep -ci 'href=.*xdares\|href=.*blog\.xdares\|href="/' || true)
if [ "$INTERNAL_LINKS" -eq 0 ]; then
    ISSUES+=("WARN:no_internal_links — No internal links to xdares.com")
fi

TITLE=$(echo "$CONTENT" | grep -oi '<title>[^<]*</title>\|<h1[^>]*>[^<]*</h1>' | head -1 || true)
if [ -z "$TITLE" ]; then
    ISSUES+=("FAIL:no_title — No title or H1 found")
fi

STRUCTURAL_FAILS=$(printf '%s\n' "${ISSUES[@]:-}" | grep -c "^FAIL:" || true)

echo "Word count: $WORD_COUNT"
echo "H2 headings: $H2_COUNT"
echo "Internal links: $INTERNAL_LINKS"
echo "Structural issues: ${#ISSUES[@]}"

if [ "$STRUCTURAL_FAILS" -gt 0 ]; then
    echo ""
    echo "=== REJECTED (structural) ==="
    printf '%s\n' "${ISSUES[@]}"
    
    REPORT="🚫 **Quality Gate REJECTED**: \`$FILENAME\`\n\n**Structural failures:**\n"
    for issue in "${ISSUES[@]}"; do
        REPORT="$REPORT• $issue\n"
    done
    REPORT="$REPORT\nWord count: $WORD_COUNT | H2s: $H2_COUNT | Links: $INTERNAL_LINKS"
    echo "$REPORT" > /tmp/quality-gate-report.txt
    exit 1
fi

# ─── Phase 2: R1 Deep Review ───
echo ""
echo "=== R1 Deep Review (DeepSeek R1 70B) ==="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CONTENT_FILE="$INPUT"
R1_RESULT=$("$SCRIPT_DIR/content-quality-gate.sh" "$INPUT" 2>&1)
R1_EXIT=$?

if [ "$R1_EXIT" -eq 2 ]; then
    # System error (Spark down, etc.) — pass on structural only
    echo "WARN: R1 review unavailable — passing on structural checks only"
    echo "R1 error: $R1_RESULT"
    exit 0
fi

echo "$R1_RESULT"

if [ "$R1_EXIT" -eq 1 ]; then
    echo ""
    echo "=== REJECTED (R1) ==="
    
    # Extract summary and suggestions from JSON
    SUMMARY=$(echo "$R1_RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('summary','No summary'))" 2>/dev/null || echo "Review failed")
    SUGGESTIONS=$(echo "$R1_RESULT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for s in d.get('suggestions',[]):
    print(f'• {s}')
" 2>/dev/null || echo "No suggestions")
    SCORES=$(echo "$R1_RESULT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
s=d.get('scores',{})
print(f\"Readability: {s.get('readability','?')}/10 | SEO: {s.get('seo','?')}/10 | Depth: {s.get('thin_content','?')}/10 | Engagement: {s.get('engagement','?')}/10 | Links: {s.get('internal_linking','?')}/10\")
" 2>/dev/null || echo "No scores")
    
    REPORT="🚫 **Quality Gate REJECTED**: \`$FILENAME\`\n\n**R1 Review:**\n$SUMMARY\n\n**Scores:** $SCORES\n\n**Suggestions:**\n$SUGGESTIONS\n\n**Structural:** Word count: $WORD_COUNT | H2s: $H2_COUNT | Links: $INTERNAL_LINKS"
    echo "$REPORT" > /tmp/quality-gate-report.txt
    exit 1
fi

echo ""
echo "=== PASSED ==="
exit 0
