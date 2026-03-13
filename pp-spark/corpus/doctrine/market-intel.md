# PP Market Intelligence

*Auto-generated tasks and planning should reference this document.*
*Updated: 2026-02-21*

---

## The Moment

AI agent governance is THE story in security right now. OpenClaw's security crisis (42K exposed instances, 6 CVEs, 824+ malicious skills) has made every security publication write about the exact problem PP solves. NIST just launched an AI Agent Standards Initiative. Proofpoint acquired an AI governance startup. The market is being created this month.

**PP's positioning:** Not detection (that's Astrix, Cisco). Not policy (that's RBAC, IAM). PP is **authorization infrastructure** — cryptographic proof that an action was approved. No receipt, no action.

---

## Key Narrative: The OpenClaw Crisis

The OpenClaw security crisis is PP's origin story. Use it in all content and outreach.

### Facts to cite:
- 42,665 publicly exposed OpenClaw instances (ClawHunter scan)
- 93.4% had critical auth bypass vulnerabilities
- 26% of third-party skills contained security vulnerabilities
- 770,000 agents on Moltbook at risk from unsecured database
- 35,000 emails + 1.5M agent tokens leaked via Supabase
- Supply chain attack: malicious npm package silently installed OpenClaw on Cline users
- 6 CVEs documented in Feb 2026 alone

### Key quotes:
- Cisco: "From a capability perspective, groundbreaking. From a security perspective, an absolute nightmare."
- The Register: "Massive access and identity problem created by poorly secured automation at scale"
- Netsync: "If an agent cannot be constrained, it should not be trusted with production authority."
- Strata: "Less than half feel confident they could pass a compliance review focused on agent behavior."

### Source articles:
- Astrix Security: https://astrix.security/learn/blog/openclaw-moltbot-the-rise-chaos-and-security-nightmare-of-the-first-real-ai-agent/
- SecurityWeek: https://www.securityweek.com/openclaw-security-issues-continue-as-secureclaw-open-source-tool-debuts/
- Cisco: https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare
- The Register: https://www.theregister.com/2026/02/09/openclaw_instances_exposed_vibe_code/
- Bitsight: https://www.bitsight.com/blog/openclaw-ai-security-risks-exposed-instances
- Aikido: https://www.aikido.dev/blog/why-trying-to-secure-openclaw-is-ridiculous
- DarkReading (supply chain): https://www.darkreading.com/application-security/supply-chain-attack-openclaw-cline-users
- TechRadar: https://www.techradar.com/pro/security/openclaw-ai-agents-targeted-by-infostealer-malware-for-the-first-time
- Conscia: https://conscia.com/blog/the-openclaw-security-crisis/
- Reddit roundup: https://www.reddit.com/r/selfhosted/comments/1r9yrw1/

---

## Competitive / Adjacent Landscape

| Company | What they do | Relationship to PP |
|---------|-------------|-------------------|
| **Astrix Security** | Detect AI agent activity in orgs | Adjacent — they detect, we authorize. Potential partner. |
| **Acuvity** (acquired by Proofpoint Feb 12) | AI enterprise security | Validates market. Proofpoint paid real money for AI governance. |
| **Redpanda** | Agentic Data Plane with auth/authz | Building governance layer for data plane. Different surface, same thesis. |
| **Gravitee** | API management + AI agent security report | Published "State of AI Agent Security 2026" (900+ executives). Data to cite. |
| **Strata** | Identity orchestration | Published "AI Agent Identity Crisis" research. Data to cite. |
| **StepSecurity** | GitHub Actions security hardening | Natural partner/integration. Already in GH Actions security. |
| **SecureClaw** | OSS tool for OpenClaw security | Reactive security, not proactive authorization. |

---

## Policy & Standards

### NIST AI Agent Standards Initiative (Feb 18, 2026)
- **RFI on AI Agent Security: due March 9, 2026**
- ITL AI Agent Identity and Authorization Concept Paper: due April 2, 2026
- Goal: "identify, manage, and authorize access and actions taken by software agents"
- PP should submit response positioning Deploy Gate + receipts as reference implementation
- Link: https://www.nist.gov/news-events/news/2026/02/announcing-ai-agent-standards-initiative-interoperable-and-secure

### Gravitee Report
- "State of AI Agent Security 2026" — 900+ executives surveyed
- Key finding: adoption outpacing governance controls
- Link: https://www.gravitee.io/blog/state-of-ai-agent-security-2026-report-when-adoption-outpaces-control

### Microsoft Security Blog
- "Four priorities for AI-powered identity and network access security in 2026"
- Includes extending Zero Trust to agent actions
- Link: https://www.microsoft.com/en-us/security/blog/2026/01/20/four-priorities-for-ai-powered-identity-and-network-access-security-in-2026/

---

## Outreach Angles

### For AI-native startups (design partner targets):
"You saw what happened with 42K exposed OpenClaw instances — AI agents are shipping code without governance. Deploy Gate adds cryptographic proof to every deploy. 2 min install. Want to try it on one repo?"

### For security companies (partnership):
"You detect agent activity. We authorize it. Together: full coverage. Want to explore an integration?"

### For NIST response:
"PP's receipt model provides cryptographic, immutable evidence of authorization — exactly the 'authorize access and actions' framework NIST is looking for."

### For content/blog:
"OpenClaw proved AI agents work. The security crisis proved they can't be trusted without governance. PP is that governance."

---

## Deadlines

| What | When | Priority |
|------|------|----------|
| NIST RFI response | March 9, 2026 | 🔴 HIGH |
| NIST Concept Paper | April 2, 2026 | 🟡 MEDIUM |
| First design partner | March 21, 2026 | 🔴 HIGH |

---

*This file is read by the daily planner. Keep it updated with new intel.*
