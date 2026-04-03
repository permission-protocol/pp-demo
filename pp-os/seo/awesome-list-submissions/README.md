# Awesome List Submissions for Permission Protocol

## Target Lists

### 1. kyrolabs/awesome-agents (best fit — tools to BUILD agents)
- Category: "Security & Governance" or "Infrastructure"
- Entry: `[Permission Protocol](https://github.com/permission-protocol/deploy-gate) - Cryptographic approval gates for AI agent actions. Ed25519-signed receipts that prove every deploy, data access, or tool call was authorized by a human before execution.`
- PR title: "Add Permission Protocol — approval gates for AI agent actions"

### 2. e2b-dev/awesome-ai-agents (large list, broad)
- Category: "Developer Tools" or "Safety & Governance"
- Entry: `[Permission Protocol](https://permissionprotocol.com) - Human approval gates for AI agents. Block deploys, data access, and tool calls until a named signer approves. Ed25519-signed receipts.`

### 3. slavakurilyak/awesome-ai-agents (300+ resources)
- Category: "Agent Safety" or "Governance"
- Entry: same as above

### 4. jim-schwoebel/awesome_ai_agents (1500+ resources)
- Category: "Security" or "Governance"

## Reddit Posts (Draft)

### r/AI_Agents
Title: "How do you handle approvals for AI agent actions that touch production?"
Body: We've been running AI coding agents (Codex, Claude Code) that can open PRs and trigger deploys. The problem: who approves the deploy? We built an open-source deploy gate that blocks execution until a human signs off with a cryptographic receipt. GitHub Action, 5 min install. Curious how others handle this.

Link: https://github.com/permission-protocol/deploy-gate

### r/devops  
Title: "We added a human-in-the-loop gate to our CI/CD pipeline for AI-generated PRs"
Body: AI coding agents are great at writing code. But when they open a PR that triggers a deploy to production, we wanted a hard gate — not just a code review, but a cryptographic receipt that proves a human authorized the specific deploy. Built it as a GitHub Action. Open source, MIT licensed.

Link: https://github.com/permission-protocol/deploy-gate
