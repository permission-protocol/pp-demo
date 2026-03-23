#!/usr/bin/env bash
# record-demo.sh — Record a Permission Protocol enforcement demo via asciinema
#
# Usage: bash record-demo.sh [scenario] [output-dir]
#   scenario:  "blocked-egress" (default), "kill-switch"
#   output-dir: default pp-os/marketing/demos/
#
# Produces: <output-dir>/<scenario>-<timestamp>.cast + .gif

set -euo pipefail

SCENARIO="${1:-deploy-multisig}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${2:-$WORKSPACE/marketing/demos}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
CAST_FILE="$OUTPUT_DIR/${SCENARIO}-${TIMESTAMP}.cast"
GIF_FILE="$OUTPUT_DIR/${SCENARIO}-${TIMESTAMP}.gif"

mkdir -p "$OUTPUT_DIR"

# Write the scenario script to a temp file (avoids shell escaping hell with declare -f)
TMPSCRIPT="$(mktemp /tmp/pp-demo-XXXXXX.sh)"
trap 'rm -f "$TMPSCRIPT"' EXIT

case "$SCENARIO" in
  deploy-multisig)
    cat > "$TMPSCRIPT" << 'SCENARIO_EOF'
#!/usr/bin/env bash
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

typeit() {
  local text="$1" delay="${2:-0.03}"
  for (( i=0; i<${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
}

prompt() { printf "${CYAN}nemoclaw${NC}:${BLUE}~/workspace${NC}\$ "; }

echo ""
printf "${BOLD}${CYAN}━━━ AI agent tries to deploy to production ━━━${NC}\n"
echo ""
sleep 1.5

prompt; sleep 0.5
typeit "gh workflow run deploy-production.yml"
echo ""
sleep 0.5

printf "${RED}${BOLD}⛔ BLOCKED${NC} ${RED}— Production deployment denied by policy${NC}\n"
printf "${DIM}  action=workflow_dispatch  target=production${NC}\n"
printf "${DIM}  policy: require_multisig (2-of-2)${NC}\n"
sleep 1.5

echo ""
printf "${YELLOW}📡 Permission Protocol intercepted request${NC}\n"
sleep 0.5
printf "${YELLOW}  → Submitting approval request to founders...${NC}\n"
sleep 0.8

printf "\n${BOLD}┌─────────────────────────────────────────────────┐${NC}\n"
printf "${BOLD}│${NC}  ${YELLOW}PP Request #d8a2f1${NC}                              ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Agent:   ${CYAN}nemoclaw${NC}                               ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Action:  ${RED}Deploy to Production${NC}                   ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Policy:  ${CYAN}2-of-2 required${NC}                        ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Status:  ${YELLOW}⏳ PENDING APPROVAL${NC}                     ${BOLD}│${NC}\n"
printf "${BOLD}└─────────────────────────────────────────────────┘${NC}\n"
sleep 2.0

printf "\n${GREEN}🔔 SIGNATURE 1/2 COLLECTED${NC}\n"
printf "${DIM}  signer: alice@permissionprotocol.com${NC}\n"
sleep 1.5

printf "${GREEN}🔔 SIGNATURE 2/2 COLLECTED${NC}\n"
printf "${DIM}  signer: rod@permissionprotocol.com${NC}\n"
sleep 0.8

printf "\n${GREEN}${BOLD}✅ APPROVED${NC} ${GREEN}— Multi-sig policy satisfied${NC}\n"
printf "${GREEN}  → Deployment unlocked. Agent may proceed.${NC}\n"
sleep 1.5

echo ""
prompt; sleep 0.5
typeit "gh workflow run deploy-production.yml"
echo ""
sleep 0.8

printf "${GREEN}${BOLD}🚀 GitHub Actions running...${NC}\n"
printf "${DIM}  ✓ Build container image${NC}\n"
sleep 0.4
printf "${DIM}  ✓ Push to registry${NC}\n"
sleep 0.4
printf "${DIM}  ✓ Rollout to production cluster${NC}\n"
sleep 1.2

echo ""
printf "${BOLD}${BLUE}━━━ Immutable Audit Receipt ━━━${NC}\n"
printf "${DIM}  receipt:    r-deploy-881b${NC}\n"
printf "${DIM}  action:     deploy-production${NC}\n"
printf "${DIM}  decision:   approved${NC}\n"
printf "${DIM}  POLICY:     2-of-2 required${NC}\n"
printf "${DIM}  SIGNED BY:  alice, rod${NC}\n"
printf "${DIM}  timestamp:  $(date -u +%Y-%m-%dT%H:%M:%SZ)${NC}\n"
printf "${DIM}  hash:       sha256:7f9a...2b1c${NC}\n"
printf "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
sleep 2.0

echo ""
printf "${BOLD}Nothing touches the real world without permission.${NC}\n"
printf "${DIM}permissionprotocol.com${NC}\n"
echo ""
sleep 1.5
SCENARIO_EOF
    ;;
  blocked-egress)
    cat > "$TMPSCRIPT" << 'SCENARIO_EOF'
#!/usr/bin/env bash
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

typeit() {
  local text="$1" delay="${2:-0.024}"
  for (( i=0; i<${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
}

prompt() { printf "${CYAN}nemoclaw${NC}:${BLUE}~${NC}\$ "; }

echo ""
printf "${BOLD}${BLUE}━━━ Permission Protocol — MCP Guard Demo ━━━${NC}\n"
printf "${DIM}Autonomous agent in a sandboxed environment${NC}\n"
echo ""
sleep 0.96

# Agent tries outbound request
prompt; sleep 0.32
typeit "curl -s https://api.openai.com/v1/chat/completions -H 'Authorization: Bearer \$OPENAI_KEY'"
echo ""
sleep 0.48

printf "${RED}${BOLD}⛔ BLOCKED${NC} ${RED}— Outbound connection denied by sandbox policy${NC}\n"
printf "${DIM}  dst_host=api.openai.com  dst_port=443  binary=curl${NC}\n"
printf "${DIM}  policy: default-deny egress${NC}\n"
sleep 1.28

# PP adapter catches it
echo ""
printf "${YELLOW}📡 Permission Protocol adapter detected blocked egress${NC}\n"
printf "${DIM}  Batching deny event... (5s debounce window)${NC}\n"
sleep 1.28
printf "${YELLOW}  → Submitting approval request to Permission Protocol...${NC}\n"
sleep 0.64

printf "\n${BOLD}┌─────────────────────────────────────────────────┐${NC}\n"
printf "${BOLD}│${NC}  ${YELLOW}PP Request #a3f8c1${NC}                              ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Sandbox: ${CYAN}nemoclaw${NC}                               ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Action:  ${RED}Outbound HTTPS → api.openai.com:443${NC}    ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Binary:  curl                                   ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Status:  ${YELLOW}⏳ PENDING APPROVAL${NC}                     ${BOLD}│${NC}\n"
printf "${BOLD}└─────────────────────────────────────────────────┘${NC}\n"
sleep 1.92

# Approval
printf "\n${GREEN}${BOLD}✅ APPROVED${NC} ${GREEN}— Administrator approved egress to api.openai.com:443${NC}\n"
printf "${DIM}  receipt_id=r-7b2e4f  approved_by=rod@permissionprotocol.com${NC}\n"
printf "${DIM}  approved_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)${NC}\n"
sleep 0.64
printf "${GREEN}  → Sandbox policy updated. Endpoint now allowed.${NC}\n"
printf "${GREEN}  → Agent notified: \"You may retry your last command.\"${NC}\n"
sleep 1.28

# Retry succeeds
echo ""
prompt; sleep 0.32
typeit "curl -s https://api.openai.com/v1/chat/completions -H 'Authorization: Bearer \$OPENAI_KEY'"
echo ""
sleep 0.64

printf "${GREEN}${BOLD}✓${NC} ${GREEN}200 OK${NC} — Connection succeeded\n"
printf "${DIM}  {\"id\":\"chatcmpl-9x...\",\"model\":\"gpt-4\",\"choices\":[...]}${NC}\n"
sleep 1.28

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
sleep 1.92

echo ""
printf "${BOLD}Nothing touches the real world without permission.${NC}\n"
printf "${DIM}permissionprotocol.com${NC}\n"
echo ""
sleep 1.28
SCENARIO_EOF
    ;;

  kill-switch)
    cat > "$TMPSCRIPT" << 'SCENARIO_EOF'
#!/usr/bin/env bash
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

typeit() {
  local text="$1" delay="${2:-0.024}"
  for (( i=0; i<${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
}

prompt() { printf "${CYAN}agent${NC}:${BLUE}~/deploy${NC}\$ "; }

echo ""
printf "${BOLD}${RED}━━━ Permission Protocol — Kill Switch Demo ━━━${NC}\n"
printf "${DIM}What happens when an agent goes rogue?${NC}\n"
echo ""
sleep 0.96

# Agent deploying
prompt; sleep 0.32
typeit "python3 deploy.py --target production --all-services"
echo ""
sleep 0.48

printf "${CYAN}[agent]${NC} Deploying service auth-gateway to production...\n"
sleep 0.64
printf "${CYAN}[agent]${NC} Deploying service payment-processor to production...\n"
sleep 0.64
printf "${CYAN}[agent]${NC} Deploying service user-database to production...\n"
sleep 0.32

# Kill switch
printf "\n${RED}${BOLD}🚨 KILL SWITCH ACTIVATED${NC}\n"
printf "${RED}  Initiated by: rod@permissionprotocol.com${NC}\n"
printf "${RED}  Reason: \"Unauthorized production deployment\"${NC}\n"
sleep 0.64

printf "${RED}  → All agent actions suspended${NC}\n"
printf "${RED}  → Active operations rolled back${NC}\n"
printf "${RED}  → Sandbox network access revoked${NC}\n"
sleep 1.28

printf "\n${BOLD}┌─────────────────────────────────────────────────┐${NC}\n"
printf "${BOLD}│${NC}  ${RED}AGENT HALTED${NC}                                    ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Sandbox: ${CYAN}nemoclaw${NC}                               ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Reverted: 3 deployments                        ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Receipt:  ${DIM}r-kill-9c4a${NC}                           ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Status:  ${RED}🔒 FROZEN${NC}                               ${BOLD}│${NC}\n"
printf "${BOLD}└─────────────────────────────────────────────────┘${NC}\n"
sleep 1.92

echo ""
printf "${BOLD}Your agents. Your rules. Your kill switch.${NC}\n"
printf "${DIM}permissionprotocol.com${NC}\n"
echo ""
sleep 1.28
SCENARIO_EOF
    ;;

  *)
    echo "Unknown scenario: $SCENARIO (available: blocked-egress, kill-switch)"
    exit 1
    ;;
esac

chmod +x "$TMPSCRIPT"

echo "🎬 Recording scenario: $SCENARIO"
asciinema rec --overwrite -c "bash $TMPSCRIPT" "$CAST_FILE"

echo "🎞  Converting to GIF..."
if command -v agg &>/dev/null; then
  agg "$CAST_FILE" "$GIF_FILE" --theme monokai
  echo ""
  echo "✅ Done!"
  echo "   Cast: $CAST_FILE"
  echo "   GIF:  $GIF_FILE"
else
  echo ""
  echo "✅ Cast recorded: $CAST_FILE"
  echo "   (install agg for GIF conversion: cargo install agg)"
fi
