#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: ./scripts/spark-company-research.sh <company-name> [--output <file>]" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

COMPANY="$1"
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

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

SLUG="$(slugify "$COMPANY")"
if [[ -z "$SLUG" ]]; then
  echo "ERROR: invalid company name" >&2
  exit 1
fi

if [[ -z "$OUTPUT" ]]; then
  OUTPUT="outreach/companies/${SLUG}-brief.md"
fi

mkdir -p outreach/companies

read -r -d '' PROMPT <<EOF || true
Create a practical outreach research brief for the company "$COMPANY".

Use your training knowledge and clearly mark uncertain items as assumptions.
Do not invent private data, secrets, or personal email addresses.

Include:
1) What they do and likely product lines.
2) Likely tech stack and developer tooling.
3) Whether they likely use AI coding agents and why.
4) Likely CI/CD setup (GitHub Actions, Jenkins, ArgoCD, etc.).
5) Compliance/security requirements likely relevant (SOC2, HIPAA, ISO 27001, etc.).
6) Recent incidents or security concerns likely to matter.
7) Best decision-maker role to target (CTO, VP Eng, Head of Platform, etc.).
8) Public channels where these roles are typically reachable (LinkedIn, Twitter/X, GitHub).
9) Personalized cold email drafts in 3 variants: direct, technical, fear-based.
10) Top likely objections and concise counters.

Format with clear section headers and concise bullets.
EOF

RESULT="$(printf '%s\n' "$PROMPT" | ./scripts/spark-query.sh --tokens 4000 --temp 0.7)"

printf '%s\n' "$RESULT" > "$OUTPUT"

echo "Saved company brief to $OUTPUT"
echo "Summary:"
printf '%s\n' "$RESULT" | sed -n '1,20p'
