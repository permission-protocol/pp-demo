#!/bin/bash
# Batch content quality review — runs R1 quality gate on all content files.
# Usage: content-batch-review.sh [--limit N] [--dir /path/to/content]
# Output: JSON report + summary to stdout

set -uo pipefail

LIMIT="${LIMIT:-5}"
CONTENT_DIR="${CONTENT_DIR:-$HOME/.openclaw/workspace/goals/xdares-seo-growth/content}"
REPORT_FILE="/tmp/content-batch-report.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --limit) LIMIT="$2"; shift 2 ;;
        --dir) CONTENT_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

echo "=== Content Batch Review ==="
echo "Directory: $CONTENT_DIR"
echo "Limit: $LIMIT"
echo ""

PASS=0
FAIL=0
ERROR=0
RESULTS="["

FILES=$(ls "$CONTENT_DIR"/*.html 2>/dev/null | shuf | head -n "$LIMIT")

for file in $FILES; do
    fname=$(basename "$file")
    echo "Reviewing: $fname ..."
    
    RESULT=$(bash "$SCRIPT_DIR/content-quality-gate.sh" "$file" 2>&1)
    EXIT_CODE=$?
    
    if [ "$EXIT_CODE" -eq 0 ]; then
        PASS=$((PASS + 1))
        echo "  ✅ PASS"
    elif [ "$EXIT_CODE" -eq 1 ]; then
        FAIL=$((FAIL + 1))
        echo "  ❌ FAIL"
    else
        ERROR=$((ERROR + 1))
        echo "  ⚠️ ERROR"
    fi
    
    # Add to results
    if [ "$RESULTS" != "[" ]; then
        RESULTS="$RESULTS,"
    fi
    RESULTS="$RESULTS{\"file\":\"$fname\",\"exit_code\":$EXIT_CODE,\"result\":$RESULT}"
    echo ""
done

RESULTS="$RESULTS]"

# Write report
echo "$RESULTS" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(json.dumps(data, indent=2))
" > "$REPORT_FILE" 2>/dev/null

echo "=== Summary ==="
echo "Reviewed: $((PASS + FAIL + ERROR))"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Errors: $ERROR"
echo "Report: $REPORT_FILE"
