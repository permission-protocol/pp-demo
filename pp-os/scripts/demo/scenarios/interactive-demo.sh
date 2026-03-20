#!/usr/bin/env bash
# Interactive PP demo — press Enter at each beat
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

clear
echo ""
printf "${BOLD}${BLUE}━━━ Permission Protocol — MCP Guard Demo ━━━${NC}\n"
printf "${DIM}Agent sandbox with default-deny network policy${NC}\n"
echo ""
sleep 0.96

prompt; sleep 0.32
typeit "curl -s https://api.openai.com/v1/chat/completions -d '{\"model\":\"gpt-4\"}'"
echo ""
sleep 0.48

printf "${RED}${BOLD}⛔ BLOCKED${NC} ${RED}— Outbound connection denied by sandbox policy${NC}\n"
printf "${DIM}  dst_host=api.openai.com  dst_port=443  binary=curl${NC}\n"
printf "${DIM}  policy: default-deny egress${NC}\n"
sleep 1.28

echo ""
printf "${YELLOW}📡 PP Adapter: Blocked egress detected${NC}\n"
printf "${YELLOW}  → Submitting approval request to Permission Protocol...${NC}\n"
sleep 0.64

printf "\n${BOLD}┌───────────────────────────────────────────────┐${NC}\n"
printf "${BOLD}│${NC} ${YELLOW}PP Request #a3f8c1${NC}                            ${BOLD}│${NC}\n"
printf "${BOLD}│${NC} Action: ${RED}Egress → api.openai.com:443${NC}            ${BOLD}│${NC}\n"
printf "${BOLD}│${NC} Status: ${YELLOW}⏳ PENDING APPROVAL${NC}                   ${BOLD}│${NC}\n"
printf "${BOLD}└───────────────────────────────────────────────┘${NC}\n"

echo ""
printf "${DIM}  Waiting for administrator approval...${NC}\n"
echo ""
read -s -p "$(printf "${DIM}  [Press ENTER after you approve on dashboard]${NC}")"
echo ""

printf "\n${GREEN}${BOLD}✅ APPROVED${NC} ${GREEN}— Egress to api.openai.com:443${NC}\n"
printf "${DIM}  receipt_id=r-7b2e4f  approved_by=rod@permissionprotocol.com${NC}\n"
sleep 0.64
printf "${GREEN}  → Policy updated. Retrying...${NC}\n"
sleep 0.96

echo ""
prompt; sleep 0.32
typeit "curl -s https://api.openai.com/v1/chat/completions -d '{\"model\":\"gpt-4\"}'"
echo ""
sleep 0.64

printf "${GREEN}${BOLD}✓${NC} ${GREEN}200 OK${NC}\n"
printf "${DIM}  {\"id\":\"chatcmpl-9x...\",\"choices\":[{\"message\":{\"content\":\"Hello!\"}}]}${NC}\n"
sleep 1.28

echo ""
printf "${BOLD}${BLUE}━━━ Audit Receipt ━━━${NC}\n"
printf "${DIM}  receipt:   r-7b2e4f${NC}\n"
printf "${DIM}  action:    egress api.openai.com:443${NC}\n"
printf "${DIM}  decision:  approved${NC}\n"
printf "${DIM}  authority: rod@permissionprotocol.com${NC}\n"
printf "${DIM}  hash:      sha256:e4b2...f91a${NC}\n"
printf "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━${NC}\n"
sleep 1.92

echo ""
printf "${BOLD}Nothing touches the real world without permission.${NC}\n"
printf "${DIM}permissionprotocol.com${NC}\n"
echo ""
sleep 1.28
