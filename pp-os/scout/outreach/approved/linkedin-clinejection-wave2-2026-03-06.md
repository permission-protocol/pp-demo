# LinkedIn Post — Clinejection Secondary Wave
**Account:** Rod Carvalho / Permission Protocol
**Status:** APPROVED
**Approved by:** Rod (2026-03-06 09:54 MST)
**Priority:** 🔴 HIGH — time-sensitive (trending now)
**Type:** Original post

---

**An AI triage bot just compromised 4,000 developer machines — via a GitHub issue title.**

Cline, a popular VS Code extension, ran an AI-powered issue triage bot on their GitHub repo. It used Claude Code with broad tool access to analyze incoming issues.

An attacker opened an issue with a crafted title. The AI read the title, treated it as an instruction, and ran `npm install` on a malicious package. That package poisoned the GitHub Actions cache — which was shared with Cline's nightly release workflow. The attacker stole NPM publishing credentials and shipped a backdoored package.

The attack chain is elegant and terrifying: prompt injection → code execution → cache poisoning → supply chain compromise. Every step was "authorized" — by the agent itself.

This is the core problem we're solving at Permission Protocol. There was no external checkpoint between "the agent read something" and "the agent did something." No signed authorization. No fail-closed gate. The agent decided and acted in a single motion.

Post-hoc logs can tell you what happened. Authorization receipts prevent it from happening. Every agent action should require a cryptographic proof of authorization before it executes — not after.

We just submitted our architecture to NIST's AI Agent Security RFI (Docket NIST-2025-0035). The industry is starting to ask the right questions. Clinejection shows why the answers can't wait.

Source: https://simonwillison.net/2026/Mar/6/clinejection/

---

**Hashtags (optional):** #AIAgents #CyberSecurity #SupplyChainSecurity #PermissionProtocol
