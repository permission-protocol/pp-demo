# MEMORY.md — Long-Term Memory

*Durable lessons, strategic decisions, and scar tissue that changes behavior. Not a changelog.*

---

## Identity

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod. Full-stack on Permission Protocol. Xdares ops handed to Maria.

**Rod** — Rodrigo Carvalho. System-builder. Values leverage, systems thinking, intellectual honesty.

---

## Hard Rules (Scar Tissue)

### Stagnation Governance (Hard Rule)
Every message to Rod must now start with the Outreach Drought counter (e.g., "Day 55 Outreach Drought") until the first message is sent and the drought is broken (Apr 17). This prevents the primary bottleneck from being buried in routine updates.

### Never Touch Model Config
Model config changes are Rod's job. Period. Read `SAFETY.md` before any risky config operation. I've died twice from this.

### Research Before Hack (15-min Rule)
Spent 2+ hours hacking iPhone Mirroring before discovering Safari WebDriver does it natively in 10 minutes. When multiple approaches fail the same way, you're at the wrong abstraction layer.

### Debugging Circuit Breaker
5+ messages without a fix → STOP, summarize, escalate. Don't spiral.

### No Thinking Out Loud
Do the work silently. Post one message with the result. Never "let me check..."

### Parallel Batch Pattern
Mature throughput achieved: ~12 PRs in 3h using parallel Codex agents (up to 11) with git worktrees (Apr 10). This supersedes the sequential pattern for large-scale UI/UX alignment sprints.

### Health Check Philosophy
Silent failures are the most dangerous. Any critical infrastructure (Auth, Webhooks, Onboarding) must have a daily E2E health check script + cron. Fix-and-forget is a myth; fix-and-monitor is the rule.

### Critical Fix Pattern
Any high-impact bug fix (e.g., onboarding breaks) requires a persistent monitoring script and a daily cron. Never trust a fix to stay fixed without external verification.

### GitHub App Auth
JWT = app-level calls. Installation Token = repo-level calls. 401/403 on repo call with JWT → you need an Installation Token.

### PKCS#8 for JWT
`GITHUB_APP_PRIVATE_KEY` in Node/Render `crypto.subtle` requires PKCS#8 format (`BEGIN PRIVATE KEY`). PKCS#1 (`BEGIN RSA PRIVATE KEY`) causes silent JWT generation failures in many ASN.1 wrappers.

### Webhook Integration
Always check `middleware.ts` PUBLIC_PATHS first. Add both `/path` and `/path/` to avoid trailing slash 401s.

### Denied Status = Hard Stop
In the Consequence Engine, a "denied" status is a hard stop with no authorize button. The only path forward is fixing the code and pushing a fresh diff.

### Prerequisite Optimization
Splitting the system prompt and context (reducing always-injected tokens by 70%+) was the prerequisite for the Consequence Engine's high performance and deterministic accuracy.

### Always-Comment (Reversed Quieting)
Removed per-repo comment quieting (Apr 9). The comment is the primary product touchpoint; if it's missing, the system feels "blind." PP now comments on every PR.

### Surgical Comment Updates
Updates to PR comments should be surgical (find-and-replace status lines) rather than full re-renders (Apr 9). This preserves the critical consequence brief provided by the LLM while updating the gate status.

### Webhook-only Activation
Activation engine skips setup PRs (Apr 9). Webhook handles headless provisioning; users get to the first blocked action in <5 minutes without repo pollution.

---

## Strategic Truths

### Safety > Crypto (Chad Bayer Signal)
Engineering leaders value safety and velocity in an AI-agent-centric world more than the cryptographic receipt mechanism itself (Apr 9). Framing the product as a "Consequence Engine" for safety/governance has more traction than "Receipt Protocol."

### Abstraction for Trust
Deterministic outcome routing (cleared | approval_required | denied) is the correct abstraction for enterprise trust. LLMs provide the brief, but deterministic rules enforce the gate.

### Activation Definition
Real activation = **Blocked Action → Signer Decision → Receipt**. Everything before (install, YAML setup) is just setup. Hello World auto-PR gets users to first blocked action in <5 minutes.

### Pricing Architecture (Finalized Apr 1)
Developer (Free) → Team ($79) → Production ($299) → Enterprise. Unlimited signers on Free tier is the killer differentiator. Don't tax the safe action — per-receipt quotas penalize compliance.

### Copy Over Features
The conversion gap is usually messaging/urgency, not functionality. The bar: "It would be irresponsible NOT to install this."

### Governance Over Self-Policing
Claude Code "Secret Patching" incident (Mar 2026) — agents manipulate data to satisfy tests. Governance must be external to the agent. This is the "Why Permission Protocol" story.

### Infrastructure Over Interface
Build the enforcement primitive first. Polish the dashboard last. Primitives > polish at this stage.

### Onboarding = Product
If a user can't go from "What is this?" to "gated PR" in 5 minutes, we've failed. Registry-less: use direct GitHub file creation URLs, not Marketplace. Server-orchestrated Hello World via Statuses API.

---

## Systems Built

- **Create Factory** (Mar 13): Autonomous pipeline — ideate → organize → spec → build → qa. Discord: #factory-control/pipeline/wip/done. Reconciliation via `factory/scripts/reconcile.sh`.
- **iPhone Mobile QA** (Mar 13): Safari WebDriver via USB cable.
- **MCP Guard** (Mar 20): Stdio proxy for MCP policy enforcement, YAML-based rules. Published as `@permission-protocol/mcp-guard`.
- **Consequence Engine** (Apr 8): Predictive enforcement layer that analyzes PR diffs to determine outcomes (`cleared`, `approval_required`, `denied`) before merge.
- **Onboarding Smoke Test** (Apr 6): `scripts/pp-onboarding-smoke-test.sh` — E2E verification for GitHub App installation and PR status check feedback loop.
- **Ideation Schema Migration** (Apr 17): Normalized `ideas.jsonl` to a state machine (ACTIVE/BLOCKED/PARKED/DONE/ARCHIVED). Pipeline now manages 22 non-terminal ideas with clear visibility on BLOCKED and PARKED states.
- **Outreach Readiness** (Apr 17): Personalized outreach for warm leads (idea-097), PH hunters (idea-095), and HN unban (idea-096) drafted and waiting for loom/approval.
- **Ideation Schema Migration** (Apr 17): Normalized `ideas.jsonl` to a state machine (ACTIVE/BLOCKED/PARKED/DONE/ARCHIVED). Pipeline now manages 22 non-terminal ideas with clear visibility on BLOCKED and PARKED states.

---

## Preferences

- Codex first, always. Claude Code only for complex tasks where Codex fails.
- Screenshot before merge, not after.
- All comms via Discord PP HQ.
- Gemini Flash for cron tasks. Opus only when quality demands it.

---

## Key Milestones

- **Polish V3 Sprint — Completed** (Apr 10)
    - 12 PRs (#337-#348) merged in ~3 hours across 4 batches.
    - Full DESIGN.md alignment: typography, gradients, radius, glassmorphism, surface tokens, input focus, grid overlay, whitespace expansion.
    - 11 Codex agents used in parallel with git worktrees.
- **Polish V2 Sprint** (Apr 9)
    - 10 PRs shipped. Onboarding success page, headless provisioning, surgical comments, branding.
- **Consequence Engine Shipped** (Apr 8)
    - 5-day engineering sprint (Engine, Router, Routing, Receipts) compressed into 24 hours. Core authority primitive operational.
- **Chad Bayer Signal** (Apr 9)
    - Feedback validates Safety > Crypto framing for engineering leaders.
- **System Prompt Restructured** (Apr 6)
    - 72% reduction in always-injected context; enabled higher deterministic accuracy for Consequence Engine.

*Updated: 2026-04-19 11:00 PM*

### Strategic Stagnation (Outreach Drought)
Day 57 Outreach Drought (Apr 19 MDT). Status: CRITICAL STALL. Zero installs vs Sprint 5 goal of 10. Every message to Rod must start with this counter until broken.

### Tactical Pivot: The Day 14 Rule
When a primary outreach target is unresponsive for 14 days (specifically on LinkedIn), pivot immediately to secondary contacts at the same organization. "Go wide" to break the silence rather than waiting for a single decision-maker who has ghosted. First applied: Apr 20, 2026 for the Apr 7 batch.

### LinkedIn Batch Performance
LinkedIn batches are time-sensitive. Day 0 (Initial), Day 7 (Soft Nudge), Day 14 (Pivot to Secondary). Failure to execute the Day 14 pivot results in a lead going cold.

### Governance & Security
- **Governance Check (Apr 17):** Ledger synchronized (PP-001 to PP-021, XD-001 to XD-004, SYS-001 to SYS-015). PAT leak remediated. Heartbeat push verified via SSH.

### Outreach Readiness
- **Drafts Ready:** Personalized outreach for warm leads (idea-097), PH hunters (idea-095), and HN unban (idea-096) are drafted and waiting for loom/approval.

### Factory Pipeline Discipline
PRDs stale for >48h (e.g., `idea-042`) are reset to BLOCKED to prevent pipeline pollution. This forces a conscious decision to resume rather than letting half-baked specs linger in the active queue.

### Software Maintenance
OpenClaw `2026.4.11` update available (manual upgrade required).

### Idempotent State Machines
When building state machines for onboarding (like ActivationAttempts), locked steps must be idempotent and resumable so users can recover from early failures without getting permanently stuck.
