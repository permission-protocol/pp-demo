import sys

with open('pp-os/scripts/demo/record-demo.sh', 'r') as f:
    content = f.read()

new_scenario = r'''  deploy-multisig)
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
'''

content = content.replace('case "$SCENARIO" in\n', 'case "$SCENARIO" in\n' + new_scenario)
content = content.replace('SCENARIO="${1:-blocked-egress}"', 'SCENARIO="${1:-deploy-multisig}"')

with open('pp-os/scripts/demo/record-demo.sh', 'w') as f:
    f.write(content)

print("Updated script.")
