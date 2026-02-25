#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: ./scripts/spark-cold-email.sh --name \"Jane Doe\" --title \"VP Engineering\" --company \"Acme Corp\" --angle \"ai-incident\" [--output <file>]" >&2
}

NAME=""
TITLE=""
COMPANY=""
ANGLE=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="${2:-}"
      shift 2
      ;;
    --title)
      TITLE="${2:-}"
      shift 2
      ;;
    --company)
      COMPANY="${2:-}"
      shift 2
      ;;
    --angle)
      ANGLE="${2:-}"
      shift 2
      ;;
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

if [[ -z "$NAME" || -z "$TITLE" || -z "$COMPANY" || -z "$ANGLE" ]]; then
  usage
  exit 1
fi

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

COMPANY_SLUG="$(slugify "$COMPANY")"
if [[ -z "$COMPANY_SLUG" ]]; then
  echo "ERROR: invalid company value" >&2
  exit 1
fi

ANGLE_TEMPLATE=""
case "$ANGLE" in
  ai-incident)
    ANGLE_TEMPLATE="Fear angle: \"Your AI agent just pushed to main.\" Highlight blast radius, rollback pain, and prevention with approval gates."
    ;;
  compliance)
    ANGLE_TEMPLATE="Compliance angle: emphasize SOC2/audit trail, immutable approvals, and policy evidence for security reviews."
    ;;
  speed)
    ANGLE_TEMPLATE="Speed angle: emphasize 3-minute install, zero-config defaults, and fast path to safer deploys."
    ;;
  technical)
    ANGLE_TEMPLATE="Technical architecture angle: discuss policy checks, signed receipts, CI/CD integration, and low operational overhead."
    ;;
  peer-proof)
    ANGLE_TEMPLATE="Peer proof angle: \"companies like yours are adding deploy gates\" with social validation and competitive pressure."
    ;;
  *)
    echo "ERROR: invalid angle '$ANGLE'. Use: ai-incident, compliance, speed, technical, peer-proof" >&2
    exit 1
    ;;
esac

if [[ -z "$OUTPUT" ]]; then
  OUTPUT="outreach/emails/${COMPANY_SLUG}-${ANGLE}.md"
fi

mkdir -p outreach/emails

read -r -d '' PROMPT <<EOF || true
Generate personalized cold outreach email variants.

Target context:
- Name: $NAME
- Title: $TITLE
- Company: $COMPANY
- Angle: $ANGLE
- Guidance: $ANGLE_TEMPLATE

Requirements:
1) Provide 3 variants: short, medium, long.
2) For each variant include:
   - Subject line
   - Email body
   - Follow-up message for no reply after 5 days
3) Word limits:
   - Short body max 150 words
   - Medium body max 250 words
   - Long body can exceed 250 but stay concise
4) Keep the style specific, credible, and non-generic.
5) Do not include private data, credentials, or fabricated personal contact details.
EOF

RESULT="$(printf '%s\n' "$PROMPT" | ./scripts/spark-query.sh --tokens 4000 --temp 0.7)"

printf '%s\n' "$RESULT" > "$OUTPUT"

echo "Saved cold email variants to $OUTPUT"
echo "Summary:"
printf '%s\n' "$RESULT" | sed -n '1,20p'
