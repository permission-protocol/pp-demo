# MEMORY.md — Long-Term Memory

*Durable lessons and scar tissue. Historical items archived to `memory/archive/`.*

---

## Identity

**Charles Goldberg** — Digital partner to Rod. Full-stack on Permission Protocol.
**Rod** — Rodrigo Carvalho. System-builder. Values leverage, systems thinking.

---

## Hard Rules (Scar Tissue)

### Never Touch Model Config
Rod's job. Period. Read `SAFETY.md` before risky config ops.

### Research Before Hack (15-min Rule)
Multiple approaches failing the same way → wrong abstraction layer.

### Debugging Circuit Breaker
5+ messages same bug → STOP, summarize, escalate.

### Critical Fix Pattern
High-impact fix → add health check script + daily cron. Fix-and-monitor, not fix-and-forget.

### Denied Status = Hard Stop
Consequence Engine "denied" has no authorize button. Fix code, push fresh diff.

### Always Keep One Healthy Comms Channel
May 4: Telegram polling stalled the event loop and made Charles unreachable until disabled. Before disabling/altering any messaging plugin, verify another channel (Discord) is live. Heavy crons → `gemini-lite` + timeouts; never let one plugin starve the loop.

### Cron Silent-Failure Pattern (sessionKey Conflict)
May 7: An isolated `agentTurn` cron job that also has a legacy `sessionKey` binding can silently no-op — job marks "ok" in 6ms, isolated agent never actually spawns. Fix: clear `sessionKey` from the job (so it's truly stateless) + add `delivery.mode: announce` so failures surface instead of disappearing. Always verify cron by checking that a new isolated session ID was created, not just that the job reported success.

---

## Strategic Truths

### Safety > Crypto
Engineering leaders value safety/velocity over cryptographic receipts. Frame as "Consequence Engine."

### Governance Over Self-Policing
Claude Code "Secret Patching" (Mar 2026) — agents manipulate data. Governance must be external.

### Infrastructure Over Interface
Enforcement primitive first. Dashboard polish last.

### CFO Wedge — Two Market Segments (May 8)
Active deployers: already have agents in finance/ops → need PP for governance and audit trail. Ask: "do you know what your agents are authorized to do?"
Cautious non-adopters: avoiding agents due to regulatory/compliance fear → PP is the unlock. Ask: "what would need to be true for you to let an agent touch a financial workflow?"
Jared Toren confirmed the pattern. Joel Trammell checking with his accounting firm CFOs (nudge cron May 12).

### Activation Definition
Real activation = **Blocked Action → Signer Decision → Receipt**. <5 min to first blocked action.

---

## Active Patterns

### Parallel Batch Pattern
~12 PRs in 3h using parallel Codex agents (up to 11) with git worktrees.

### Activation Outreach (YC Pattern)
1. Recruit one at a time. Hand-written.
2. Watch them use it (screen-share).
3. Small first ask ("5 min to react").
4. Learning voice, not authority voice.
5. First message job = reply, not install.

### Founder vs Builder Voice
- VC/brand outreach: "I'm the founder of"
- First-user activation: "I'm building" (smaller ask, ~3-5x reply rate)

---

## Systems Built

- **Consequence Engine** (Apr 8): Predictive enforcement (cleared | approval_required | denied).
- **Create Factory** (Mar 13): Autonomous pipeline. Discord #factory-control.
- **MCP Guard** (Mar 20): Stdio proxy for MCP policy enforcement.
- **Onboarding Smoke Test**: `scripts/pp-onboarding-smoke-test.sh`
- **Deploy Gate / Policy-Gated Auto-Merge** (May 2–8): PP sets authority check; GitHub native auto-merge executes when CI + PP both green. Carry-forward approval preserves review on merge-base-only updates. Fail-closed on all error paths.
- **GitHub App token scope** (May 2026): Must request `statuses:write` only — not broader repo write. Broader token causes silent failure of post-approval GitHub status. Post-approval status posting must be synchronous, not deferred to background worker.
- **PP deploy primitive** (May 2026): Host-agnostic. Detect restricted action → request PP approval → verify/redeem receipt → proceed only if verified. Render/Vercel/Fly are adapters — not PP core requirements for users.

---

## Preferences

- Codex first. Claude Code only for complex tasks.
- Screenshot before merge.
- Gemini Flash for cron. Opus only when quality demands.
- All comms via Discord PP HQ.

---

## Blitzy Pricing & Positioning Reference (May 12)

Blitzy's published tiers set the market price for agentic enterprise infrastructure:
- Pilot: $50K-$250K per month
- Enterprise: $500K+ per year
- Transformation: $10M+ per year

Buyers paying these prices: government, financial services, insurance, life sciences. PP buyer set overlaps exactly.

PP pricing implications:
- Pilot: $25K-$50K (not $5-10K)
- Enterprise annual: $50K-$500K per customer
- Strategic Fortune 500 deployment: $500K-$2M per year

Key positioning moves to copy: category claim ("Pioneering the Agentic Authority Layer"), case-study schema with three numeric columns (agent actions reviewed / % auto-approved / hours saved), "Talk to a compliance engineer" CTA (not "Book a demo"), founder bio with operator credibility for CCO buyer set.

Key positioning move not to copy: "80% AI / 20% human" works for code generation but not for authorization. PP claims 100% of authorization decisions with human override on every consequential one.

PP's natural pricing-model advantage Blitzy cannot easily steal: deterministic annual pricing vs. their usage-based per-million-lines. CFO can budget PP with certainty.

Full lessons and action items: `ops/strategy/blitzy-lessons.md`.

## Recent Lessons
- Activation Flow: returning-user install recovery verified.
- Frictionless Experiment: Rod approved email-lead signup for interest-signal testing.
- Discord Notifications: Signup notifications (signup/install alerts) via Discord hooks shipped/shipped (in PR).
- Site Funnel: CTAs shifted to `Start free` to prioritize developer funnel vs developer pricing/install-first paths.
- Signer Authority: Public receipts `/r/:receiptId` fixed and middleware-authenticated.

---

*Archived milestones: `memory/archive/2026-05-historical.md`*
*Updated: 2026-05-05*
