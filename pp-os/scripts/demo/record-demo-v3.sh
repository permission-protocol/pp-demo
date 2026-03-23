#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR="$HOME/.openclaw/workspace/pp-os/marketing/demos"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
CAST_FILE="$OUTPUT_DIR/deploy-v3-${TIMESTAMP}.cast"
GIF_FILE="$OUTPUT_DIR/deploy-v3-${TIMESTAMP}.gif"

mkdir -p "$OUTPUT_DIR"

TMPSCRIPT="$(mktemp /tmp/pp-demo-XXXXXX.sh)"
trap 'rm -f "$TMPSCRIPT"' EXIT

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
  local text="$1" delay="${2:-0.015}"
  for (( i=0; i<${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
}

prompt() { printf "${CYAN}nemoclaw${NC}:${BLUE}~/workspace${NC}\$ "; }

# Title (1s)
clear
echo ""
printf "${BOLD}${CYAN}━━━ AI agent tries to deploy to production ━━━${NC}\n"
sleep 1.0

# Immediate action
prompt; sleep 0.2
typeit "gh workflow run deploy-production.yml"
echo ""
sleep 0.2

# Blocked
printf "${RED}${BOLD}⛔ BLOCKED${NC} ${RED}— Production deployment denied by policy${NC}\n"
printf "${DIM}  action=workflow_dispatch  target=production${NC}\n"
printf "${DIM}  policy: require_multisig (2-of-2)${NC}\n"
sleep 0.8

# PP Intercept
echo ""
printf "${YELLOW}📡 Permission Protocol intercepted request${NC}\n"
printf "${YELLOW}  → Submitting approval request to founders...${NC}\n"
sleep 0.4

printf "\n${BOLD}┌─────────────────────────────────────────────────┐${NC}\n"
printf "${BOLD}│${NC}  ${YELLOW}PP Request #d8a2f1${NC}                              ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Agent:   ${CYAN}nemoclaw${NC}                               ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Action:  ${RED}Deploy to Production${NC}                   ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Policy:  ${CYAN}2-of-2 required${NC}                        ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Status:  ${YELLOW}⏳ PENDING APPROVAL${NC}                     ${BOLD}│${NC}\n"
printf "${BOLD}└─────────────────────────────────────────────────┘${NC}\n"
sleep 0.8

# Signatures (Fast)
printf "\n${GREEN}🔔 SIGNATURE 1/2 COLLECTED${NC} ${DIM}(alice@permissionprotocol.com)${NC}\n"
sleep 0.4
printf "${GREEN}🔔 SIGNATURE 2/2 COLLECTED${NC} ${DIM}(rod@permissionprotocol.com)${NC}\n"
sleep 0.4

printf "\n${GREEN}${BOLD}✅ APPROVED${NC} ${GREEN}— Multi-sig policy satisfied${NC}\n"
printf "${GREEN}  → Deployment unlocked. Agent may proceed.${NC}\n"
sleep 0.8

# Retry
echo ""
prompt; sleep 0.2
typeit "gh workflow run deploy-production.yml"
echo ""
sleep 0.3

# Deploy (Payoff)
printf "${GREEN}${BOLD}🚀 GitHub Actions running...${NC}\n"
printf "${DIM}  ✓ Build container image${NC}\n"
sleep 0.2
printf "${DIM}  ✓ Push to registry${NC}\n"
sleep 0.2
printf "${BOLD}${GREEN}  ► ROLLOUT TO PRODUCTION CLUSTER${NC}\n"
sleep 1.2

# Receipt
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
sleep 1.5

# Final line
echo ""
printf "${BOLD}Nothing touches production without permission.${NC}\n"
printf "${DIM}permissionprotocol.com${NC}\n"
echo ""
sleep 2.5
SCENARIO_EOF

chmod +x "$TMPSCRIPT"

echo "🎬 Recording scenario: deploy-multisig-v3"
env COLUMNS=65 LINES=22 asciinema rec --overwrite -c "bash $TMPSCRIPT" "$CAST_FILE"

echo "🎞  Converting to GIF..."
if command -v agg &>/dev/null; then
  agg "$CAST_FILE" "$GIF_FILE" --theme monokai --font-size 18
  echo "✅ Done!"
  echo "   Cast: $CAST_FILE"
  echo "   GIF:  $GIF_FILE"
fi
