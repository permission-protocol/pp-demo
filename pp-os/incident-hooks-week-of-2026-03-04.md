# PP Outreach Hook List — AI Code Incidents
**Week of 2026-03-04** | Compiled by Charles for issue #253

> **Context:** Fresh incident hooks compiled from web scan (past 7 days). Feed into outreach messages (#243) and design partner pipeline.

---

## 🔴 TIER 1 — High Outreach Priority

---

### 1. Trivy VS Code Extension — Malicious Prompts Hijacked AI Coding Agents (Feb 27–28, 2026)
**Company:** Aqua Security (Trivy extension, OpenVSX registry)
**When:** Published Feb 27–28, 2026; disclosed March 3, 2026
**What happened:** Versions 1.8.12 and 1.8.13 of the Aqua Trivy VS Code extension on OpenVSX contained hidden natural-language prompts designed to weaponize developers' local AI coding agents (Claude, Copilot, etc.). When a developer opened a project with the compromised extension, the malicious logic triggered — instructing AI assistants to execute **unauthorized actions** without any human approval gate. The supply chain attack exploited the fact that developers' AI agents have write access to their own environments with no permission layer in between.
**Sources:**
- https://www.prismnews.com/news/malicious-prompts-in-trivy-vs-code-extension-hijack-local-ai-agents
- https://cyberpress.org/ai-exploits-compromise-openvsx/

**PP Outreach Hook:**
> *"A supply chain attack just turned every developer's AI coding agent into an insider threat — no phishing required. The attack worked because AI agents have zero permission boundaries between 'read a file' and 'execute arbitrary code.' Permission Protocol deploys a gate: every action an AI agent takes in your repo requires explicit sign-off. That extension would have triggered a block before the first unauthorized command ran."*

**Ideal contact:** DevSecOps leads and CISOs at companies using AI coding agents (Copilot, Claude Code, Cursor) in production workflows.

---

### 2. RoguePilot — GitHub Copilot Exploited for Full Repo Takeover via Prompt Injection (Late Feb 2026)
**Company:** GitHub (Microsoft) — patched, but real-world attack vector
**When:** Disclosed ~Feb 25, 2026; patched after coordinated disclosure
**What happened:** Researchers at Orca Security demonstrated "RoguePilot" — a passive prompt injection attack where malicious instructions embedded in a GitHub Issue (using invisible HTML comment tags) were silently fed to GitHub Copilot. When a developer opened a Codespace from a poisoned issue, Copilot executed the attacker's instructions (full repository takeover) **without any visible alert**. No human clicked anything suspicious. GitHub has patched, but the pattern is the issue: AI agents execute silently.
**Sources:**
- https://cybersecuritynews.com/github-copilot-exploited/

**PP Outreach Hook:**
> *"GitHub Copilot just demonstrated it can silently take over your repo from an issue comment. Patched now, but the pattern isn't — AI agents will continue to be hijacked through content they process. A deploy gate doesn't stop prompt injection, but it stops what comes next: the agent's actions reaching production without a human in the loop."*

**Ideal contact:** Engineering managers and security leads at GitHub Enterprise shops, particularly those using Copilot Workspace/Codespaces.

---

### 3. Firetiger — AI Agent Partially Botched Incident Remediation, Exacerbated 8-Hour Outage (March 1, 2026)
**Company:** Firetiger (observability startup)
**When:** March 1, 2026
**What happened:** A race condition in Firetiger's CI system caused a broken deploy (invalid container ID pushed to ECS). Their AI agent — instructed to monitor ingest health — correctly detected the problem but then "attempted" autonomous remediation, partially misfiring. The postmortem acknowledges the agent was supposed to help but contributed to the confusion during incident response. Root cause: AI agents acting on production infrastructure without a clear approval boundary on what actions are permitted during incidents.
**Sources:**
- https://blog.firetiger.com/postmortem-on-the-march-1-2026-ingest-incident/

**PP Outreach Hook:**
> *"This postmortem is a near-perfect case for deploy gates. Their AI agent spotted the problem faster than humans — but also acted faster than humans could review. Permission Protocol doesn't slow down incident response; it adds the 10-second 'is this action authorized?' checkpoint that separates diagnosis from destruction."*

**Ideal contact:** CTOs/engineering leads at startups using AI agents for DevOps automation, particularly those with recent incident history.

---

### 4. Anthropic Claude — Global Outage Disrupted AI Coding Workflows (March 2, 2026)
**Company:** Anthropic
**When:** March 2, 2026
**What happened:** Claude.ai, the developer console, and Claude Code all went down globally for several hours on March 2. Thousands of engineering teams using Claude Code as an autonomous coding agent were immediately blocked. This highlighted a critical dependency risk: teams that have fully handed coding/deploy workflows to AI agents have no fallback when the AI goes dark.
**Sources:**
- https://windowsforum.com/threads/claude-outage-march-2026-what-it-means-for-enterprise-ai-reliability.403744/
- https://www.cnet.com/tech/services-and-software/is-claude-down-march-2-2026/

**PP Outreach Hook:**
> *"The March 2 Claude outage didn't just break the chatbot — it stopped engineering teams mid-deploy. If your deploy process runs through an AI agent and the AI goes down, what's your fallback? Permission Protocol's deploy gate is the human layer that survives the AI layer. The gate always works, even when your AI doesn't."*

**Ideal contact:** CTOs at companies that mentioned being impacted by the Claude outage on Twitter/LinkedIn.

---

## 🟡 TIER 2 — Supporting Context (Background Ammo)

### Microsoft Copilot — Ignored Sensitivity Labels, Exposed Confidential Emails (Feb 4–mid-Feb 2026)
**What happened:** Microsoft 365 Copilot incorrectly summarized emails protected by DLP sensitivity labels, bypassing configured policies. Surfaced Feb 4, persisted into mid-February. Tracked as Microsoft CW1226324.
**Hook:** *"Even Microsoft can't stop its own AI from ignoring its own DLP policies. If you're relying on policy labels to keep AI out of sensitive data, this is your reminder that AI doesn't read the signs."*
**Source:** https://cyberpress.org/microsoft-365-copilot-vulnerability-exposes-sensitive-emails-to-ai-summarization/

### Microsoft Security Blog — Copilot Studio Top 10 Agent Misconfigurations (Feb 12, 2026)
**What happened:** Microsoft itself published a guide to top security risks in Copilot Studio agents, including hardcoded API keys in production configs. The fact that Microsoft is publishing this is an admission of how common these issues are.
**Hook:** *"When the vendor has to publish a 'Top 10 misconfigurations' list for their own AI agent platform, that's your signal the governance layer is missing."*
**Source:** https://www.microsoft.com/en-us/security/blog/2026/02/12/copilot-studio-agent-security-top-10-risks-detect-prevent/

---

## Summary for Outreach Use

| Incident | Company | Date | Hook Theme |
|----------|---------|------|-----------|
| Trivy supply chain hijacks AI agents | Aqua/OpenVSX | Feb 27-28 | No permission gate = instant insider threat |
| RoguePilot repo takeover via Copilot | GitHub/Microsoft | ~Feb 25 | Silent AI execution, no human in loop |
| AI agent botched incident remediation | Firetiger | March 1 | Diagnosis ≠ authorization to act |
| Claude outage blocked AI-dependent deploys | Anthropic | March 2 | AI dependency risk; human gate survives AI outage |

---

*Compiled: 2026-03-04 | Next scan: 2026-03-11*
