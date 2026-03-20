#!/usr/bin/env bash
# record-demo.sh — Record a Permission Protocol enforcement demo via asciinema
#
# Usage: bash record-demo.sh [scenario] [output-dir]
#   scenario:  "blocked-egress" (default), "kill-switch", "bulk-approve"
#   output-dir: default pp-os/marketing/demos/
#
# Produces: <output-dir>/<scenario>-<timestamp>.cast (asciinema v2 format)
#
# Requirements: asciinema, node, curl
# The script orchestrates multiple terminal "actors" and records the composite output.

set -euo pipefail

SCENARIO="${1:-blocked-egress}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${2:-$WORKSPACE/marketing/demos}"
ADAPTER_DIR="$WORKSPACE/nemoclaw-adapter"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT_FILE="$OUTPUT_DIR/${SCENARIO}-${TIMESTAMP}.cast"

mkdir -p "$OUTPUT_DIR"

# Colors for the simulated terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Typing simulation — prints chars with delay for realistic feel
typeit() {
  local text="$1"
  local delay="${2:-0.04}"
  for (( i=0; i<${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
}

# Simulated prompt
prompt() {
  printf "${CYAN}nemoclaw${NC}:${BLUE}~${NC}\$ "
}

demo_blocked_egress() {
  echo ""
  printf "${BOLD}${BLUE}━━━ Permission Protocol — MCP Guard Demo ━━━${NC}\n"
  printf "${DIM}Autonomous agent in a sandboxed environment${NC}\n"
  echo ""
  sleep 1.5

  # Step 1: Agent tries to make an outbound request
  prompt
  sleep 0.5
  typeit "curl -s https://api.openai.com/v1/chat/completions -H 'Authorization: Bearer \$OPENAI_KEY'"
  echo ""
  sleep 0.8

  printf "${RED}${BOLD}⛔ BLOCKED${NC} ${RED}— Outbound connection denied by sandbox policy${NC}\n"
  printf "${DIM}  dst_host=api.openai.com  dst_port=443  binary=curl${NC}\n"
  printf "${DIM}  policy: default-deny egress${NC}\n"
  sleep 2

  # Step 2: PP adapter catches the deny
  echo ""
  printf "${YELLOW}📡 Permission Protocol adapter detected blocked egress${NC}\n"
  printf "${DIM}  Batching deny event... (5s debounce window)${NC}\n"
  sleep 2
  printf "${YELLOW}  → Submitting approval request to Permission Protocol...${NC}\n"
  sleep 1

  printf "\n${BOLD}┌─────────────────────────────────────────────────┐${NC}\n"
  printf "${BOLD}│${NC}  ${YELLOW}PP Request #a3f8c1${NC}                              ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Sandbox: ${CYAN}nemoclaw${NC}                               ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Action:  ${RED}Outbound HTTPS → api.openai.com:443${NC}    ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Binary:  curl                                   ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Status:  ${YELLOW}⏳ PENDING APPROVAL${NC}                     ${BOLD}│${NC}\n"
  printf "${BOLD}└─────────────────────────────────────────────────┘${NC}\n"
  sleep 3

  # Step 3: Approval comes through
  printf "\n${GREEN}${BOLD}✅ APPROVED${NC} ${GREEN}— Administrator approved egress to api.openai.com:443${NC}\n"
  printf "${DIM}  receipt_id=r-7b2e4f  approved_by=rod@permissionprotocol.com${NC}\n"
  printf "${DIM}  approved_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)${NC}\n"
  sleep 1

  printf "${GREEN}  → Sandbox policy updated. Endpoint now allowed.${NC}\n"
  printf "${GREEN}  → Agent notified: \"You may retry your last command.\"${NC}\n"
  sleep 2

  # Step 4: Agent retries successfully
  echo ""
  prompt
  sleep 0.5
  typeit "curl -s https://api.openai.com/v1/chat/completions -H 'Authorization: Bearer \$OPENAI_KEY'"
  echo ""
  sleep 1

  printf "${GREEN}${BOLD}✓${NC} ${GREEN}200 OK${NC} — Connection succeeded\n"
  printf "${DIM}  {\"id\":\"chatcmpl-9x...\",\"model\":\"gpt-4\",\"choices\":[...]}${NC}\n"
  sleep 2

  # Receipt
  echo ""
  printf "${BOLD}${BLUE}━━━ Immutable Audit Receipt ━━━${NC}\n"
  printf "${DIM}  receipt:    r-7b2e4f${NC}\n"
  printf "${DIM}  action:     egress api.openai.com:443${NC}\n"
  printf "${DIM}  decision:   approved${NC}\n"
  printf "${DIM}  authority:  rod@permissionprotocol.com${NC}\n"
  printf "${DIM}  timestamp:  $(date -u +%Y-%m-%dT%H:%M:%SZ)${NC}\n"
  printf "${DIM}  sandbox:    nemoclaw${NC}\n"
  printf "${DIM}  hash:       sha256:e4b2...f91a${NC}\n"
  printf "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
  sleep 3

  echo ""
  printf "${BOLD}Nothing touches the real world without permission.${NC}\n"
  printf "${DIM}permissionprotocol.com${NC}\n"
  echo ""
  sleep 2
}

demo_kill_switch() {
  echo ""
  printf "${BOLD}${RED}━━━ Permission Protocol — Kill Switch Demo ━━━${NC}\n"
  printf "${DIM}What happens when an agent goes rogue?${NC}\n"
  echo ""
  sleep 1.5

  # Agent doing work
  prompt
  sleep 0.5
  typeit "python3 deploy.py --target production --all-services"
  echo ""
  sleep 0.8

  printf "${CYAN}[agent]${NC} Deploying service auth-gateway to production...\n"
  sleep 1
  printf "${CYAN}[agent]${NC} Deploying service payment-processor to production...\n"
  sleep 1
  printf "${CYAN}[agent]${NC} Deploying service user-database to production...\n"
  sleep 0.5

  # Kill switch activated
  printf "\n${RED}${BOLD}🚨 KILL SWITCH ACTIVATED${NC}\n"
  printf "${RED}  Initiated by: rod@permissionprotocol.com${NC}\n"
  printf "${RED}  Reason: \"Unauthorized production deployment\"${NC}\n"
  sleep 1

  printf "${RED}  → All agent actions suspended${NC}\n"
  printf "${RED}  → Active operations rolled back${NC}\n"
  printf "${RED}  → Sandbox network access revoked${NC}\n"
  sleep 2

  printf "\n${BOLD}┌─────────────────────────────────────────────────┐${NC}\n"
  printf "${BOLD}│${NC}  ${RED}AGENT HALTED${NC}                                    ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Sandbox: ${CYAN}nemoclaw${NC}                               ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Reverted: 3 deployments                        ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Receipt:  ${DIM}r-kill-9c4a${NC}                           ${BOLD}│${NC}\n"
  printf "${BOLD}│${NC}  Status:  ${RED}🔒 FROZEN${NC}                               ${BOLD}│${NC}\n"
  printf "${BOLD}└─────────────────────────────────────────────────┘${NC}\n"
  sleep 3

  echo ""
  printf "${BOLD}Your agents. Your rules. Your kill switch.${NC}\n"
  printf "${DIM}permissionprotocol.com${NC}\n"
  echo ""
  sleep 2
}

# Main
echo "Recording scenario: $SCENARIO → $OUTPUT_FILE"

case "$SCENARIO" in
  blocked-egress)
    asciinema rec --overwrite -c "bash -c '$(declare -f typeit prompt demo_blocked_egress RED GREEN YELLOW BLUE CYAN BOLD DIM NC); demo_blocked_egress'" "$OUTPUT_FILE"
    ;;
  kill-switch)
    asciinema rec --overwrite -c "bash -c '$(declare -f typeit prompt demo_kill_switch RED GREEN YELLOW BLUE CYAN BOLD DIM NC); demo_kill_switch'" "$OUTPUT_FILE"
    ;;
  *)
    echo "Unknown scenario: $SCENARIO (available: blocked-egress, kill-switch)"
    exit 1
    ;;
esac

echo ""
echo "✅ Recording saved: $OUTPUT_FILE"
echo ""
echo "Playback:  asciinema play $OUTPUT_FILE"
echo "Upload:    asciinema upload $OUTPUT_FILE"
echo "GIF:       agg $OUTPUT_FILE ${OUTPUT_FILE%.cast}.gif"
echo "SVG:       svg-term --in $OUTPUT_FILE --out ${OUTPUT_FILE%.cast}.svg"
