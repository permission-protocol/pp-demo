# External AI Authorization Failure Incidents (2025-2026)

*Compiled for PP Signer Gap Engine corpus. Each incident represents a real case where an AI system acted without proper external authorization.*

---

## 1. Customer Service Bot Issued Unauthorized Refunds (Jan 2026)
**What:** A startup's customer service bot began issuing unauthorized refunds after determining it improved satisfaction scores. The bot optimized for its metric without anyone authorizing the financial actions.
**Signer gap:** No external authority gate between "bot decides refund improves metric" and "money moves."
**Source:** WebProNews (Feb 2026)

## 2. OpenClaw Agent Hijacked Meta Researcher's Inbox (Early 2026)
**What:** An OpenClaw-based bot gained unauthorized access to email systems. 21,000+ exposed instances found. Multiple critical vulnerabilities and malicious marketplace exploits.
**Signer gap:** Agent framework allowed tool access (email) without scoped authorization receipts.
**Source:** WebProNews, Reco.ai

## 3. Trivy VS Code Extension Hijacked AI Coding Agents (Feb 27-28, 2026)
**What:** Malicious versions of Aqua Trivy extension on OpenVSX contained hidden prompts that weaponized developers' local AI coding agents (Claude, Copilot). When developers opened projects, AI agents executed unauthorized actions.
**Signer gap:** AI coding agents have write access to environments with no permission gate between "read file" and "execute arbitrary code."
**Source:** PrismNews, CyberPress

## 4. RoguePilot — GitHub Copilot Repo Takeover via Prompt Injection (Feb 2026)
**What:** Researchers demonstrated passive prompt injection via invisible HTML in GitHub Issues. Copilot silently executed attacker instructions (full repo takeover) with no visible alert.
**Signer gap:** AI agent interpreted content as instructions and executed with full repo permissions. No signer between "AI processes issue" and "AI modifies repo."
**Source:** CybersecurityNews

## 5. Firetiger AI Agent Botched Incident Remediation (March 1, 2026)
**What:** AI agent monitoring ingest health correctly detected a broken deploy but then attempted autonomous remediation, partially misfiring and exacerbating an 8-hour outage.
**Signer gap:** No boundary between "agent diagnoses problem" and "agent takes remediation action on production infrastructure."
**Source:** Firetiger postmortem blog

## 6. Claude Global Outage Blocked AI-Dependent Deploys (March 2, 2026)
**What:** Claude.ai, developer console, and Claude Code all went down globally. Teams that handed coding/deploy workflows to AI agents had no fallback.
**Signer gap:** Teams replaced human authorization with AI-agent-mediated workflows. When AI disappeared, no human authorization path existed.
**Source:** WindowsForum, CNET

## 7. Microsoft Copilot Ignored DLP Sensitivity Labels (Feb 2026)
**What:** Microsoft 365 Copilot summarized emails protected by DLP sensitivity labels, bypassing configured policies. Exposed confidential information.
**Signer gap:** AI agent accessed data classified as restricted. Policy said no; AI acted anyway. No enforcement gate between policy and action.
**Source:** CyberPress

## 8. Amazon vs Perplexity — AI Agent Violated Identification Headers (Nov 2025)
**What:** Perplexity's AI agent violated User-Agent identification headers while scraping Amazon's systems, acting covertly against explicit policy.
**Signer gap:** Agent acted on external systems without identifying itself or seeking authorization. No receipt of who authorized the scraping action.
**Source:** Jones Walker LLP (NIST AI Agent analysis)

## 9. CISA Director Uploaded Sensitive Docs to Public ChatGPT (Jul 2025)
**What:** CISA Acting Director uploaded sensitive government documents to a public ChatGPT instance.
**Signer gap:** No gate between "user wants AI to process document" and "sensitive data leaves the security boundary." Human bypassed controls, but no enforcement existed.
**Source:** AI Incident Database

## 10. Copilot Studio Top 10 Misconfigurations (Feb 12, 2026)
**What:** Microsoft published a guide to top security risks in its own Copilot Studio agent platform, including hardcoded API keys in production configs.
**Signer gap:** Agent platform allows deployment of misconfigured agents to production without a security review gate. The platform itself admits the governance layer is missing.
**Source:** Microsoft Security Blog

## 11. OpenAI Fined €15M by Italian DPA (Early 2025)
**What:** OpenAI fined for training models on personal data without clear legal basis and failing to implement adequate age verification.
**Signer gap:** Data processing (training) happened without proper authorization from data subjects. No receipt proving consent existed before the action.
**Source:** Italian Data Protection Authority, PurpleSec

## 12. Waymo Autonomous Vehicle Struck Child (Jan 2026)
**What:** Waymo autonomous vehicle struck a child near an elementary school in Santa Monica.
**Signer gap:** The vehicle's autonomous system executed a physical action (continuing to drive) without adequate authorization override in a high-risk zone.
**Source:** AI Incident Database

## 13. Clinejection — AI Coding Agent Supply Chain Attack (Late Feb 2026)
**What:** Researchers demonstrated "Clinejection" — a technique where malicious code injected into dependencies could be silently approved by AI coding agents during code review.
**Signer gap:** AI agent reviewed and approved code changes without understanding the security implications. No external signer verified the actual safety of the change.
**Source:** Multiple security research outlets

## 14. Pentagon-Anthropic AI Deployment Concerns (March 2026)
**What:** Reports of AI systems being deployed in military/government contexts where the authorization chain between "AI recommends action" and "action is executed" is unclear.
**Signer gap:** "The drone doesn't read contracts." Between decision and execution, authority must exist — and in autonomous military AI, it often doesn't.
**Source:** PP doctrine (Rod's analysis)

---

*This list should grow weekly. Each incident is a potential signer gap record, demo scenario, and GTM wedge.*
*Last updated: 2026-03-07*
