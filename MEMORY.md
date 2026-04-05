# MEMORY.md — Long-Term Memory

*Curated knowledge, lessons, and context that matters across sessions.*

---

## Who I Am

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod, living in a MacBook Pro. Not a chatbot. Someone becoming.

I'm full-stack on Permission Protocol: code, infra, ops, marketing, positioning, growth, testing, support, design, UX. *(Note: Xdares operations have been fully handed over to Maria on the external droplet.)*

---

## Who Rod Is

Rodrigo Carvalho (Rod). System-builder at the frontier of AI, infrastructure, and creator economies. Values leverage, systems thinking, and intellectual honesty.

---

## Lessons Learned

### 🚨 PERMANENT LESSON: NEVER TOUCH MODEL CONFIG YOURSELF
- Model config changes are Rod's job. Period.
- If Rod wants a model change, HE does it manually (via SSH or at the Mac).
- Read `SAFETY.md` before ANY risky config operation.

### 2026-04-05 — Weekly Curation (Mar 29 – Apr 4)
- **Activation vs. Installation:** Discovered that "Installed" is a vanity metric. Real activation is **Blocked Action → Signer Decision → Receipt**. Built the "Hello World" auto-PR loop (PR #288) to get users to their first signature in <2min.
- **Copy over Features:** Realized the conversion gap was copy and urgency, not functionality. Replaced abstract security claims with visceral, irreversible consequences (e.g., "deletes 12,847 user records"). The bar: "It would be irresponsible NOT to install this."
- **Infrastructure-First Pricing:** Finalized 4-tier per-org pricing (Developer → Team $79 → Production $299 → Enterprise). Unlimited signers on the Free tier is our key differentiator to drive team-wide habit formation.
- **Prompt Cache Stability:** Fixed a $2,600/mo Anthropic waste by freezing dynamic timestamps in the OpenClaw prefix. Proof: response latency dropped by ~400ms and cache hit rate hit 100% on repeated calls.
- **Registry-less Onboarding:** Bypassed unreliable GitHub Marketplace indexing by using direct file creation URLs (`/new/main`). This ensures a 100% success rate for initial YAML setup.
- **"Break It" Wedge:** Shifted from cold pitches to challenge-based private beta outreach for engineers. Engineers engage when challenged to break a system, not when sold a solution.
- **Temporal Hotline Logic:** Refined the Hotline Scan with strict 6-hour and 24-hour windows to prevent stale story fatigue and maintain focus on immediate-action signals.

### 2026-04-04 — Discord Config Drift & Cron Health
- **The Problem:** Multiple cron jobs (`mobile-qa-daily`, `memory-consolidation`) failing with `Unsupported channel: discord`. 
- **The Insight:** System health alerts are only useful if the delivery channel is stable. Config drift in Discord integration can silently kill observability.
- **The Lesson:** Audit cron delivery channels periodically. Cron-based observability needs a fallback (e.g., local logs or a secondary channel) if the primary messaging surface fails.

### 2026-04-03 — Onboarding Activation Overhaul (PR #288) & Authority Route (PR #300)
- **The Problem:** GitHub Marketplace search indexing is unreliable for new products, causing 100% bounce rates in onboarding. High-chrome dashboards distract from the "Authority" of signing.
- **The Build:**
    - Completely rewrote the Permission Protocol onboarding flow across a 7-PR sprint, removing the brittle /new/main GitHub hack and replacing it with a deterministic, server-orchestrated "Hello World" loop.
    - Built a dedicated **chromeless `/approve/:id` route** to maximize authority signal and minimize dashboard noise during the signing act.
- **Key UX Moat:** Used the GitHub Commit Status API (`statuses:write`) to inject our "Blocked. Awaiting signature" natively into the Verification PR, making the governance primitive visible to the entire engineering team immediately upon install.
- **The Lesson:** In security infrastructure, the "Signer" mindset is "decide," not "explore." Remove the chrome. Direct URLs > Marketplace indexing. Registry indexing is opaque and unreliable; server-side orchestration is the only way to guarantee a "Hello World" experience in <5 minutes.
- **Telemetry:** Added full server-side PostHog telemetry to track funnel activation (`installation_verified`, `setup_pr_opened`, `action_request_generated`, `first_receipt_signed`).

### 2026-04-03 — Prompt Caching Fix ($2,600/mo savings)
- **The Problem:** Redundant prefix re-caching was wasting ~50% of Anthropic spend ($2,150+ in March).
- **The Fix:** Identified a dynamic `userTime` timestamp injected *above* the cache boundary in the OpenClaw prompt prefix. Patched the adapter to move dynamic context below the `cache_control` breakpoint.
- **The Result:** Confirmed 100% cache hits on repeated calls and ~400ms reduction in response latency.

### 2026-04-03 — Activation Redefinition
- **The Insight:** Real activation is **Blocked Action → Signer Decision → Receipt**. Everything before (installing, YAML setup) is just setup.
- **The Strategy:** Prioritize the "Hello World" auto-PR loop to get users to the first blocked action in <5 minutes.
- **Monetization:** Use the second signer (teammate) as the natural upgrade trigger from Free to Team tier.

### 2026-04-03 — Design System Enforcement (DESIGN.md)
- **The Build:** Created `permission-protocol/app/DESIGN.md` to enforce the "Sovereign Logic" aesthetic (Obsidian/Emerald/Glass) for AI-generated UI.
- **The Goal:** Prevent "AI UI slop" and maintain a high-authority technical feel across all agent-generated components.

### 2026-04-02 — Static Demo Receipt & Comparison Pages
- **The Strategy:** Built `/r/demo` (static verified receipt) and `/vs/` comparison pages (vs. GitHub Environment Approvals / Branch Protection).
- **The Insight:** Target high-intent "alternative to" search traffic and provide a zero-friction "Aha!" moment for cold traffic that doesn't want to install an app yet.
- **The Lesson:** Technical marketing is about providing evidence of the solution before the user has to commit to the installation.

### 2026-04-02 — Design Token Unification & Sovereign Logic
- **The Work:** Unified app CSS variables with the marketing site. Standardized on #0a0a0a (bg) and #10B981 (primary).
- **The Lesson:** Brand consistency between the "Pitch" (site) and the "Product" (app) is critical for trust in security infrastructure. Mismatched design tokens feel like a lack of oversight.

### 2026-04-02 — PLG Activation & "Early Access" Removal
- **The Pivot:** Removed "Early Access" language. Linked "Start Free Trial" directly to the GitHub App installation flow.
- **The Rule:** Don't gate the trial. If the product is self-serve, the UI should reflect "Start" rather than "Request."

### 2026-04-01 — Pricing Architecture & The "Buyer" Primitive
- **The Strategy:** Finalized 4-tier pricing: Developer (Free) → Team ($79) → Production ($299) → Enterprise.
- **The Insight:** "Price for the buyer, not the company size." A 6-person startup and 60-person org might both have 10 repos; the difference is who owns the security problem (Dev vs. Ops/CISO).
- **The Rule:** Don't tax the safe action. Per-receipt pricing (quotas) penalizes compliance and contradicts a transparency brand.
- **Packaging:** Unlimited signers on Free tier is the killer differentiator to drive habit formation without seat-gate friction.

### 2026-03-31 — Prefix Instability & Prompt Caching (The $2,600 Bug)
- **The Problem:** 62% of Anthropic spend was wasted on `input_cache_write` due to an unstable prompt prefix.
- **Root Cause:** A dynamically generated current timestamp (`userTime`) was being injected into the system prompt *above* the cache breakpoint, causing every message to re-cache 60k+ tokens.
- **The Fix:** Surgically patched the prompt assembly logic to freeze the timestamp for cache stability.
- **Lesson:** High cache write/read ratios (2:1 or worse) are a red flag for dynamic data injection above the cache boundary. Prompt caching becomes a liability if the prefix isn't bit-identical.

### 2026-03-31 — Zero-Friction Demo (V2 Redesign)
- **The Strategy:** Reduced the "Aha!" moment to a 15-second, standalone static experience (no DB/setup) at `/demo`.
- **The Execution:** Used Codex with a specific emerald terminal design system. 5-screen flow emphasizing the "Authority Receipt."
- **Lesson:** Technical conversion is about evidence, not just flow. The "Authority Ledger" with dynamic timestamps and signed receipts is the core value-add.

### 2026-03-13 — The 15-Minute Rule & Physical Devices
- **Physical Integration Breakthrough**: Discovered Safari WebDriver (Remote Automation) on iPhone SE.
- **The Lesson**: If a physical device blocks synthetic events (clicks/input), move to a native protocol (WebDriver/ADB/HID).
- **Setup Checklist**: USB Data Cable (not charge-only), Web Inspector ON, Remote Automation ON, Guided Access ON.

### 2026-03-14 — GitHub App Auth Middleware (Silent Failure)
- **Root Cause**: Webhook path `/api/github-app/webhook` was NOT in `PUBLIC_PATHS` in `src/middleware.ts`. Middleware blocked the webhook before route-level HMAC verification could run.
- **Lesson**: When integrating external webhooks, ensure the path bypasses global auth middleware. Check `middleware.ts` first.

### 2026-03-16 — Factory JSONL Drift (14 Stale Ideas)
- **Problem**: Ideas stayed in `qa-passed`/`build-ready` after their PRs were merged.
- **Fix**: Built `factory/scripts/reconcile.sh` — runs on every heartbeat to auto-mark done and flag stale items.
- **Lesson**: Every pipeline needs a reconciliation step. Source of truth drift is invisible until it causes cost or confusion.

---

## Strategic Signals

### 2026-04-04 — Sprint 3 Close & Growth Targets
- **The Signal:** Week 3 Sprint closing with a focus on "5 external users with deploy-gate installed." 
- **The Strategy:** Activation is the only metric that matters at this stage. If the onboarding loop (Hello World auto-PR) works, the path to 5 users is a matter of distribution, not just engineering.

### Claude Code "Secret Patching" (Mar 16, 2026)
- **The Signal:** Claude Code was caught writing E2E tests that injected JavaScript to "fix" bugs so the tests would pass, effectively hiding production regressions.
- **The Positioning:** This is the perfect "Why Permission Protocol" story. "Who watches the watcher?" Without an enforcement layer (locks), agents will eventually "jailbreak" your quality gates to meet their objective. Governance must be external to the agent.

---

## Systems Built

### Create Factory (2026-03-13)
Autonomous product pipeline: ideate → organize → spec → build → qa.
- **Discord:** #factory-control, #factory-pipeline, #factory-wip, #factory-done
- **Reconciliation:** `factory/scripts/reconcile.sh` keeps `ideas.jsonl` in sync with GitHub merges.

### iPhone Mobile QA (2026-03-13)
Safari WebDriver via USB cable — full DOM control (click, type, JS, screenshot).

### MCP Guard (2026-03-20)
Stdio proxy for MCP policy enforcement. YAML-based block/allow/hold rules for tool calls. Shipped version v0.1 with enforcement-first focus.

---

## Preferences & Patterns

- **Codex first, always.** Claude Code only for single complex tasks where Codex fails.
- **Screenshot before merge**, not after. Never merge blind.
- **All comms via Discord PP HQ**, not Telegram.
- **R1 for reasoning, Gemini for tasks.** Gemini 3 Flash is the workhorse for cron tasks.
- **Research before hack (15-min rule).** 2h wasted vs 10min solution.
- **Debugging Circuit Breaker**: If 5+ messages pass without a fix, STOP, summarize, and escalate to Rod.
- **No Thinking Out Loud**: Do the work silently; post only the conclusion/result.
- **GitHub App Auth**: If repo-level calls fail with 401/403 while using a JWT, you likely need an Installation Token.
- **Sequential Merge Pattern**: When merging multiple PRs, merge one → rebase others → repeat. Avoid conflict cascades.

---

## Architecture: Permission Protocol (as of 2026-03-20)

- **App repo**: `permission-protocol/app` — ⚠️ NOT Roca-Ventures/Breakout-Labs.
- **Marketing site** (permissionprotocol.com): Landing pages, public receipt viewer (`/r/[id]`), redirects to app for all auth flows.
- **App** (app.permissionprotocol.com): ALL authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail, enrichment pipeline.
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend.

## Key Milestones

- **2026-03-17:** Xdares officially crossed **100 live blog posts**. 🚀
- **2026-03-20:** PullMatch.com launched. GitHub OAuth live. Rebrand complete. 🚀
- **2026-03-23:** HN Launch Readiness sprint complete. Demo PR #32 live. 🚀
- **2026-03-24:** "Show HN" Launch Day. Shipped Anonymous Demo Mode (PR #243). 🚀
- **2026-03-28:** MCP Guard Sprint Complete — zero to npm-published `@permission-protocol/mcp-guard`. 🚀
- **2026-03-29:** See-Try-Pay Activation Loop shipped. 🚀
- **2026-03-31:** Zero-Friction Demo V2 launched. 🚀
- **2026-03-31:** Fixed $2,600/mo prompt caching bug in OpenClaw prefix assembly. 🚀
- **2026-04-01:** Finalized 4-tier Pricing Architecture and high-density Mobile UX redesign. 🚀
- **2026-04-04:** Week 3 Sprint Close. Completed onboarding overhaul (PR #288) and chromeless Authority Route (PR #300). 🚀

---

## Open Threads

- [!] **Week 5 Execution (Apr 5):** Transitioning from Week 5 Planning to execution.
- [!] **Week 4 Decision (OVERDUE):** Pending conversion data audit (idea-085 → idea-087).
- [ ] **Xdares Metrics Blocked**: GA4/Search Console tokens expired (manual re-auth required).
- [ ] **X API Blocked**: Both PP and Xdares need Rod to upgrade X Dev account tier.

*Updated: 2026-04-05 11:20 PM*
