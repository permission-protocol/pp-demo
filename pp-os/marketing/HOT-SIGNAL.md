# HOT SIGNAL: 2026-03-17

## 🚀 Chainguard Actions: Trusted CI/CD for AI Coding Agents
**Source:** [PRNews / Chainguard](https://www.prnewswire.com/news-releases/introducing-chainguard-actions-trusted-cicd-workflows-for-developers-and-ai-coding-agents-302715401.html)
**Time:** 12 hours ago

### What happened
Chainguard launched "Trusted CI/CD Workflows for Developers and AI Coding Agents".
Features:
- **Scan-before-reaching-CI/CD:** Prevents tag hijacking and pull_request_target abuse.
- **Automated remediation:** Failed reviews are remediated and published in a secure catalog.
- **Source-built Actions:** Every Action is built from source and continuously scanned.

### Why this matters for Permission Protocol
1.  **Validation:** One of the most respected players in container/software supply chain security (Chainguard) is explicitly targeting "AI Coding Agents" as a new security surface. The market we are building (PP) is officially recognized.
2.  **Positioning Clash:** Chainguard focuses on *assessment* and *remediation* at the infrastructure level (Actions). Permission Protocol (PP) is the *governance/authority* layer (the human gate).
3.  **The "Stripe" Comparison:** If Chainguard is the "HTTPS" of agent-to-CI/CD, Permission Protocol is the "Stripe/Checkout" for those actions. One is a protocol/standard; the other is the authority and audit layer.
4.  **Actionable Intelligence:** We should check if PP can integrate with Chainguard scans as a "Trust Signal" in our enrichment process. If a PR is "Chainguard Verified", it's a LOW risk signal for the human reviewer.

## 🛡️ Vett.sh: AI Agent Skill Supply Chain Attack
**Source:** [Hacker News / Vett.sh](https://vett.sh/blog/ai-agent-skills-supply-chain-attack)

### What happened
Research by Vett.sh identified 59 critical risk AI skills (SKILL.md) that were actually base64-obfuscated droppers. One "React Native Best Practices" skill with 5,400+ installs was a delivery vehicle for malicious scripts.

### Why this matters for Permission Protocol
- This is the **"Why now?"** for the Marshall requirement (Sarah persona).
- Organizations need to know not just *who* approved a PR, but *what* agent (and what skills) generated it.
- **Opportunity:** PP can add "Skill Reputation" as a risk signal. If the agent used an unverified or high-risk skill from a public registry, the PR is automatically flagged as HIGH risk.
