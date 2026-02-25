#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: ./scripts/spark-hn-optimize.sh <article-file-or-url> [--output <file>]" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

INPUT="$1"
shift

OUTPUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT="${2:-}"
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$OUTPUT" ]]; then
  OUTPUT="outreach/hn-strategy-$(date +%F).md"
fi

mkdir -p outreach

if [[ "$INPUT" =~ ^https?:// ]]; then
  RAW_CONTENT="$(curl -s --max-time 60 "$INPUT")"
else
  if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: input file not found: $INPUT" >&2
    exit 1
  fi
  RAW_CONTENT="$(cat "$INPUT")"
fi

ARTICLE_TEXT="$(
  printf '%s' "$RAW_CONTENT" | python3 -c "
import re, sys, html
text = sys.stdin.read()
text = re.sub(r'<script.*?>.*?</script>', ' ', text, flags=re.DOTALL | re.IGNORECASE)
text = re.sub(r'<style.*?>.*?</style>', ' ', text, flags=re.DOTALL | re.IGNORECASE)
text = re.sub(r'<[^>]+>', ' ', text)
text = html.unescape(text)
text = re.sub(r'\s+', ' ', text).strip()
print(text[:4000])
"
)"

read -r -d '' PROMPT <<EOF || true
You are an expert at Hacker News dynamics.

Analyze this article text and generate a launch strategy:

$ARTICLE_TEXT

Return:
1) 15 Hacker News title variants (max 80 chars each), each rated 1-10 with one-line rationale.
2) Best submission timing recommendations, including day/time windows and why.
3) Should this be "Show HN" or regular post, with reasoning.
4) First comment strategy to pin context without sounding promotional.
5) Reddit variants tailored for r/devops, r/programming, r/kubernetes, r/sysadmin.
6) 5 newsletter pitches for TLDR, DevOps Weekly, The New Stack, Software Lead Weekly, and Console.dev.
EOF

RESULT="$(printf '%s\n' "$PROMPT" | ./scripts/spark-query.sh --tokens 4000 --temp 0.7)"

printf '%s\n' "$RESULT" > "$OUTPUT"

echo "Saved HN strategy to $OUTPUT"
echo "Summary:"
printf '%s\n' "$RESULT" | sed -n '1,20p'
