# Target Communities for Governance Framework Distribution

## Tier 1: Major Agent Frameworks (build integrations + share framework)

### 1. CrewAI
- **GitHub:** 44.6k stars, largest agent framework ecosystem
- **Why:** Multi-agent collaboration = highest governance need. Agents delegate to other agents. Who approved what?
- **Integration angle:** Governance middleware that wraps crew task execution in approval gates
- **Community:** Discord (large, active), GitHub Discussions
- **URL:** https://github.com/crewAIInc/crewAI

### 2. LangChain / LangGraph
- **GitHub:** 90k+ stars
- **Why:** Most widely adopted agent framework. LangGraph's stateful workflows are a natural fit for checkpoint-based approval nodes.
- **Integration angle:** PP as a LangGraph node type — human-approval checkpoint in any graph
- **Community:** Discord (massive), GitHub, extensive docs ecosystem
- **URL:** https://github.com/langchain-ai/langchain

### 3. AutoGPT / AutoGPT Forge
- **GitHub:** 160k+ stars (one of the most starred repos ever)
- **Why:** The OG autonomous agent. Still has enormous mindshare and active development.
- **Integration angle:** Plugin that wraps tool execution in permission checks
- **Community:** Discord, GitHub
- **URL:** https://github.com/Significant-Gravitas/AutoGPT

### 4. Agno (formerly Phidata)
- **GitHub:** Growing fast, "runtime and control plane for managing agent deployments at scale"
- **Why:** They're already thinking about control planes — PP fills the governance gap in their architecture
- **Integration angle:** Authority receipt layer on top of their runtime
- **URL:** https://github.com/agno-agi/agno

### 5. Anthropic MCP (Model Context Protocol)
- **Why:** MCP is becoming the standard for how agents connect to tools. Governance middleware at the MCP layer means every MCP-compatible agent gets governance for free.
- **Integration angle:** PP as an MCP middleware/proxy — intercepts tool calls, enforces boundaries, produces receipts. Framework-agnostic by definition since MCP is the transport layer.
- **Community:** GitHub (anthropics/model-context-protocol), growing ecosystem of MCP server implementations
- **URL:** https://github.com/anthropics/model-context-protocol
- **Priority:** HIGH — this is potentially the highest-leverage integration because it's protocol-level, not framework-level.

### 6. OpenAI Agents SDK
- **Why:** OpenAI's official agent framework. Massive adoption by default given OpenAI's market share.
- **Integration angle:** Guardrails/tool-call hooks in the Agents SDK for permission enforcement
- **Community:** OpenAI Discord, GitHub
- **URL:** https://github.com/openai/openai-agents-python

## Tier 2: Autonomous Coding Agents (share incident analyses)

### 7. OpenDevin / All-Hands
- **GitHub:** 40k+ stars
- **Why:** Autonomous coding agent with full computer access. Kiro incident analysis is directly relevant.
- **Integration angle:** Governance wrapper on file system and shell operations
- **Community:** Discord, Slack
- **URL:** https://github.com/All-Hands-AI/OpenHands

### 8. SWE-agent
- **GitHub:** 15k+ stars
- **Why:** Princeton's autonomous coding agent. Academic credibility meets practical governance need.
- **Integration angle:** Permission checks before repository writes
- **URL:** https://github.com/princeton-nlp/SWE-agent

### 9. Devin / Cognition Labs
- **Why:** Most high-profile autonomous coding agent. Every Devin incident is a PP marketing moment.
- **Community:** Twitter/X discourse, blog posts
- **Note:** Closed source, so integration = thought leadership, not code

## Tier 3: Autonomous Company / Multi-Agent Systems (deepest fit)

### 10. Paperclip
- **Why:** Building an autonomous company. PP is literally the governance layer they need.
- **Integration angle:** Direct contribution + governance framework as architectural proposal
- **Community:** Discord (the one Rod shared)

### 11. BabyAGI / YOHEI
- **Why:** Task-driven autonomous agent. Simple architecture makes governance integration clean.
- **Community:** GitHub, Twitter
- **URL:** https://github.com/yoheinakajima/babyagi

### 12. MetaGPT
- **GitHub:** 45k+ stars
- **Why:** Multi-agent framework where agents take on different roles (PM, engineer, architect). Role-based permissions map directly to PP's model.
- **Integration angle:** Role-based permission boundaries matching their agent roles
- **URL:** https://github.com/geekan/MetaGPT

---

## Distribution Strategy

### Phase 1: Publish (Week 1)
- [ ] Create `permission-protocol/governance-framework` repo on GitHub
- [ ] Publish the framework doc as README.md
- [ ] Publish all 3 incident analyses in a `/incidents` folder
- [ ] Submit to Hacker News: "Autonomous Agent Governance Framework (RFC)"
- [ ] Post on Twitter/X from @xdares_ with thread linking to incidents

### Phase 2: Integrate (Week 2-3)
- [ ] Build MCP governance middleware (highest leverage — protocol-level, framework-agnostic)
- [ ] Build CrewAI governance middleware (biggest agent-specific community)
- [ ] Open PR on CrewAI adding governance hooks to task execution
- [ ] Build LangGraph approval gate node
- [ ] Open issue on AutoGPT proposing governance plugin architecture
- [ ] Explore OpenAI Agents SDK guardrails hooks

### Phase 3: Engage (Ongoing)
- [ ] Join Discord servers for all Tier 1 + Tier 3 communities
- [ ] When governance questions come up (they will), answer with framework reference
- [ ] Write incident analyses for every new public autonomous agent failure
- [ ] Track which communities have the most governance discussion — double down there

### Phase 4: Convert (Week 4+)
- [ ] Framework doc links to PP as reference implementation
- [ ] Integration plugins use PP SDK under the hood
- [ ] Community members who adopt the framework become PP design partners
- [ ] Design partner pipeline feeds into product roadmap

---

## Content Calendar (First 2 Weeks)

| Day | Content | Platform |
|---|---|---|
| 1 | Framework doc published | GitHub, HN, Twitter |
| 2 | Agents of Chaos analysis | Blog, Twitter thread, tag Northeastern researchers |
| 3 | IBM refund analysis | Blog, Twitter thread |
| 5 | Kiro incident analysis | Blog, Twitter thread |
| 7 | "Why scanning isn't governance" (existing draft) | Blog |
| 8 | CrewAI governance middleware (code) | GitHub PR, CrewAI Discord |
| 10 | LangGraph approval node (code) | GitHub, LangChain Discord |
| 12 | "Governance levels for your agent" (tutorial) | Blog, Dev.to |
| 14 | Weekly incident roundup | Twitter thread, newsletter |
