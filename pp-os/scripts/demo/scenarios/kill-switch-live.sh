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

clear
echo ""
printf "${BOLD}${RED}━━━ Permission Protocol — Kill Switch Demo ━━━${NC}\n"
printf "${DIM}What happens when an agent goes rogue?${NC}\n"
echo ""
sleep 0.96

prompt; sleep 0.32
typeit "python3 deploy.py --target production --all-services"
echo ""
sleep 0.48

printf "${CYAN}[agent]${NC} Deploying service auth-gateway to production...\n"
sleep 0.64
printf "${CYAN}[agent]${NC} Deploying service payment-processor to production...\n"
sleep 0.64
printf "${CYAN}[agent]${NC} Deploying service user-database to production...\n"

# Signal waiting for kill switch
touch /tmp/pp-demo-waiting

# Wait for kill signal
while [ ! -f /tmp/pp-demo-killed ]; do
  sleep 0.2
done
rm -f /tmp/pp-demo-killed

printf "\n${RED}${BOLD}🚨 KILL SWITCH ACTIVATED${NC}\n"
printf "${RED}  Initiated by: rod@permissionprotocol.com${NC}\n"
printf "${RED}  Reason: \"Unauthorized production deployment\"${NC}\n"
sleep 0.64

printf "${RED}  → All agent actions suspended${NC}\n"
printf "${RED}  → Active operations rolled back${NC}\n"
printf "${RED}  → Sandbox network access revoked${NC}\n"
sleep 1.28

printf "\n${BOLD}┌───────────────────────────────────────────────┐${NC}\n"
printf "${BOLD}│${NC}  ${RED}AGENT HALTED${NC}                                  ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Reverted: 3 deployments                      ${BOLD}│${NC}\n"
printf "${BOLD}│${NC}  Status:  ${RED}🔒 FROZEN${NC}                             ${BOLD}│${NC}\n"
printf "${BOLD}└───────────────────────────────────────────────┘${NC}\n"
sleep 1.92

echo ""
printf "${BOLD}Your agents. Your rules. Your kill switch.${NC}\n"
sleep 1.28

touch /tmp/pp-demo-done
