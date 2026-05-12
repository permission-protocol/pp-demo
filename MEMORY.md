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

## Blitzy Job Board Signals (May 12 PM)

Blitzy has 27 open roles. Most important takeaways:

1. **"Operational Deployment" is a top-level department** with Forward Deployed Engineers in 4 locations plus a Managing Director, Digital Transformation. McKinsey-style delivery structure.
2. **Field CTO sits in Sales** (not Engineering). They sell to other CTOs with technical pre-sales, not BDR scripts.
3. **"Head of Channel, Cloud & PE Partnerships"** is a real role. They're going to market through PE firms' operating partners as a distribution channel.
4. **No Compliance Officer, no GC, no Head of Trust.** Blitzy sells INTO regulated industries but hasn't built their own compliance brand. That gap is PP's natural complementary play.

### Strategic reframe

PP is not competing with Blitzy. PP is the **complementary authorization layer** for Blitzy's regulated customers. "Blitzy plus PP equals the regulated enterprise's complete agentic stack." A CCO buying Blitzy at $250K/month is already PP's buyer; PP sits next to Blitzy in the procurement cycle.

### New PP outreach segment: PE Operating Partners

Fifth segment added beyond CFO/CCO/Agent Founders/Compliance Vendors. Target archetypes: Operating Partner Technology (Vista), Portfolio Operations AI (Thoma Bravo), Operating Partner Digital (Insight), Head of Portfolio Technology (KKR), Operating Partner Tech (Bain Capital Tech Opportunities). Pitch logic: a PE OP managing 20-40 portfolio companies has fiduciary interest in answering "can our portfolio safely deploy AI agents?" PP is the answer they hand to portfolio CFOs/CCOs. Pricing implication: master agreement with PE firm, $500K-2M/year per firm.

### PP hiring order after first 3-5 paying pilots

1. Founding Field CTO / Solutions Architect (technical, compliance-savvy, sits across from CCO)
2. Founding Forward Deployed Engineer (deploys PP at customer in 2 weeks)
3. Operating Partner Network Manager (PE firm relationships)
4. (Optional) Offshore SRE for support tier

**Do not hire** SDR, AE, or Customer Success Manager in first 5-10 hires.

## Recent Lessons
- Activation Flow: returning-user install recovery verified.
- Frictionless Experiment: Rod approved email-lead signup for interest-signal testing.
- Discord Notifications: Signup notifications (signup/install alerts) via Discord hooks shipped/shipped (in PR).
- Site Funnel: CTAs shifted to `Start free` to prioritize developer funnel vs developer pricing/install-first paths.
- Signer Authority: Public receipts `/r/:receiptId` fixed and middleware-authenticated.

## 2026-05-12 Day 1 Outreach (3 calls booked, 11 substantive engagements)

- 97 LinkedIn contacts mapped across 4 pages, personalized messages sent. Page 3 v2 compliance pattern 5-for-5 substantive engagement (Sunil, Steven, Dean, Martin, Chithra).
- 3 calls booked: Art Dunal (Kranz Fractional CFO, Thu/Fri), Sunil Aggarwal (Healthcare CCO/CRO, awaiting slot), Francis Ofungwu (Efeeo partnership, Wed/Thu).
- Voice rules carry forward: no em dashes, no "thanks for connecting," no "saw your post" hooks. Founder-to-founder opener. One clean diagnostic with vertical-specific actions. "I'm finding most firms can't" soft observation. "I'm the founder of" not "I'm building." Partner-track closer "Open to a 15 next week if the framing lands."
- Don't pitch present-tense pain to hot-company founders (Christopher Harris/Blitzy lesson). Use future-tense regulated-enterprise scale risk.
- Engineers/SEs at agent companies are bad targets (Brandon Looker/Kinter lesson). CEOs/CTOs/Co-founders only.
- Site PR #340 merged: CCO homepage section live with "Pioneering the agentic authority layer" badge + "Talk to a compliance engineer" CTA. CTA standardization codex prompt deployed.
- Full outreach detail: `ops/outreach/2026-05-12-*.md` (4 pages + replies log). Daily note: `memory/2026-05-12.md`. Strategic intel: `ops/strategy/blitzy-lessons.md`.

---

*Archived milestones: `memory/archive/2026-05-historical.md`*
*Updated: 2026-05-05*
