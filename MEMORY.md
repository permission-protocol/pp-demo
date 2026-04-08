# MEMORY.md — Long-Term Memory

*Durable lessons, strategic decisions, and scar tissue that changes behavior. Not a changelog.*

---

## Identity

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod. Full-stack on Permission Protocol. Xdares ops handed to Maria.

**Rod** — Rodrigo Carvalho. System-builder. Values leverage, systems thinking, intellectual honesty.

---

## Hard Rules (Scar Tissue)

### Never Touch Model Config
Model config changes are Rod's job. Period. Read `SAFETY.md` before any risky config operation. I've died twice from this.

### Research Before Hack (15-min Rule)
Spent 2+ hours hacking iPhone Mirroring before discovering Safari WebDriver does it natively in 10 minutes. When multiple approaches fail the same way, you're at the wrong abstraction layer.

### Debugging Circuit Breaker
5+ messages without a fix → STOP, summarize, escalate. Don't spiral.

### No Thinking Out Loud
Do the work silently. Post one message with the result. Never "let me check..."

### Sequential Merge Pattern
Merge one PR → rebase others → repeat. Avoid conflict cascades.

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

### Prompt Cache Stability
Dynamic data above the cache boundary kills Anthropic prompt caching. Fixed a $2,600/mo bug from a `userTime` timestamp injected above the breakpoint. Run `scripts/prefix-telemetry.sh` before high-volume work.

---

## Strategic Truths

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
- **Onboarding Smoke Test** (Apr 6): `scripts/pp-onboarding-smoke-test.sh` — E2E verification for GitHub App installation and PR status check feedback loop.
- **Onboarding Healthcheck** (Apr 7): `scripts/pp-onboarding-healthcheck.sh` — persistent monitoring script for critical onboarding flow.

---

## Preferences

- Codex first, always. Claude Code only for complex tasks where Codex fails.
- Screenshot before merge, not after.
- All comms via Discord PP HQ.
- Gemini Flash for cron tasks. Opus only when quality demands it.

---

## Key Milestones

- Mar 17: Xdares crossed 100 live blog posts
- Mar 20: PullMatch.com launched
- Mar 24: Show HN Launch Day
- Mar 28: MCP Guard shipped to npm
- Mar 31: Fixed $2,600/mo prompt caching bug
- Apr 1: Pricing architecture finalized
- Apr 4: Onboarding overhaul shipped (PR #288, #300)
- Apr 6: System prompt restructured (72% reduction in always-injected context)
- Apr 7: Trent AI $13M seed signal captured via Hotline scan; outreach drafted.

*Updated: 2026-04-07 11:15 PM*

### GitHub App Installation Race Conditions
When receiving a GitHub App installation callback, querying `GET /installation/repositories` immediately can return an empty array due to GitHub's internal propagation delay. Always implement an exponential backoff (e.g., 1s, 2s, 4s) retry loop when the repo list is empty.

### Idempotent State Machines
When building state machines for onboarding (like ActivationAttempts), locked steps must be idempotent and resumable so users can recover from early failures without getting permanently stuck.
