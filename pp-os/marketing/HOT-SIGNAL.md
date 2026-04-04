# 🚨 HOT SIGNAL — AI Coding Agent Deploys (2026-04-03)

## 1. 🔥 INCIDENT: Claude Code Source Leak (March 31, 2026)
**URL:** [Kilo Blog: Claude Code Source Leak - A Timeline](https://blog.kilo.ai/p/claude-code-source-leak-a-timeline)
**Summary:**
A debug source map file was accidentally included in the public `npm` package for **Claude Code**. This exposed ~390,000 lines of original TypeScript source.

**Why this matters for Permission Protocol:**
- **The "Harness Gap":** The leak revealed that Claude Code's own harness scores significantly lower (77%) than third-party harnesses like **Cursor** (93%) for the same Opus model. This proves that the *infrastructure* (the harness/enforcement layer) is just as critical as the model itself.
- **Agent Mimicry:** The source code revealed Claude Code referencing and imitating behavior from **OpenCode**, showing how competitive the "agent orchestration" layer has become.
- **Supply Chain Risk:** The root cause was a bug in the **Bun** runtime. This highlights the vulnerability of AI agents to low-level infrastructure bugs, reinforcing the need for external governance (Permission Protocol).

---

## 2. ⚡️ NEW TOOL: Optio (AI Orchestration to Merge)
**URL:** [GitHub: jonwiggins/optio](https://github.com/jonwiggins/optio)
**Summary:**
A new open-source system that automates the entire lifecycle from a GitHub issue to a **merged Pull Request**.

**Key Features:**
- Spins up isolated K8s pods for Claude Code or Codex.
- **PR Monitoring:** Watches CI checks and merge readiness every 30 seconds.
- **Self-Healing:** Feeds CI failures back into the agent for automated fixes.
- **Auto-Merge:** Squash-merges the PR and closes the issue without human intervention.

**Strategic Insight:**
This is exactly the "autonomous agent" behavior that enterprises will fear—and where Permission Protocol can act as the **enforcement gate** between "Agent ready" and "Merge to production."

---

## 3. 🛡️ GOVERNANCE: Microsoft/GitHub "APM" (Agent Package Manager)
**URL:** [GitHub: microsoft/apm](https://github.com/microsoft/apm)
**Summary:**
Microsoft and GitHub have launched an open-source tool to manage agent configuration (prompts, skills, rules) as dependencies with lockfiles and audits.

**Strategic Insight:**
The industry is moving toward "Agent Dependency Management." APM scans for hidden Unicode attacks and pins versions. This signals that the "Wild West" of agents is ending, and structured governance is becoming a requirement for enterprise adoption.
