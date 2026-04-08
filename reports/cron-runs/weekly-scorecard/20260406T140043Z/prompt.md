You are running the weekly-scorecard orchestration wrapper.

Mandatory execution pattern:
1. load
2. fetch
3. validate
4. invoke agent
5. write
6. log

Write only the requested final report. Do not describe the wrapper itself.

## Job
Generate the weekly operating scorecard.

## Instructions
Write a weekly scorecard with three sections: wins, misses, and next-week focus. Ground every point in the fetched scorecard data and recent notes. Keep the output executive-readable.

## Loaded Context
## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-04-05 11:30 PM MDT

## Active Right Now
- **Mode:** Week 4 SPRINT OPEN — Distribution Push (Apr 5–11)
- **Sprint Goal:** 10 active external installations with successful signature loops.
- **Focus:** Product Hunt launch prep (idea-094), 10-install target (idea-088), first loop user (idea-089).
- **System Health:** Investigating Discord provider drift and mobile QA failures.

## ACTIVE Tasks (Today's Priority)
- **idea-094** — Product Hunt launch prep: hunter outreach + brief (pp-os/launch/product-hunt-launch-brief.md)
- **idea-088** — Drive 10 external deploy-gate installs. Monitor GitHub App webhook logs.
- **idea-089** — First complete loop user (non-PP org: approved PR + receipt). Monitor PP dashboard.

## BLOCKED (needs Rod)
- **idea-085** — PostHog approval count + Stripe Team conversions (still needed for full metrics picture)
- **idea-082** — X API write permissions (needs Rod: upgrade X Dev account tier)
- **idea-086** — Paperclip port 3100 (needs Rod: SSH into pp-scout-sfo2)
- **idea-092** — Sycamore/Sri Viswanath LinkedIn pitch (needs Rod approval)

## Backlog (ready when sprint clears)
- **idea-030** — AI-generated code summary on approval screen (M)
- **idea-002** — Blast radius indicator on approval page (M)
- **idea-042** — Actionable error UX: every error has a fix path (M)
- **idea-080** — Fix PostHog generic event names (S)
- **idea-083** — Mobile Safari SameSite cookie fix (S)
- **idea-084** — MCP Guard v0.2 spec (M)
- **idea-081** — PullMatch viral risk profile card (M)

## Recently Shipped (Apr 1–4)
- PR #288: Onboarding direct file creation fix ✅
- PR #300: Chromeless Authority route (/approve/:id) ✅
- Sprint retro + Week 5 planning (idea-093) ✅
- Week 4 Decision Brief (idea-087) ✅
- Week 1 Changelog (idea-079) ✅
- Mobile UX revamp, Demo Context polish, Static demo receipt (/r/demo) ✅
- Pricing, sitemap, SEO, comparison pages ✅
- 5 SEO blog posts live, Awesome list submissions sent ✅
```

## Long-Term Memory
Path: /Users/moltbot/.openclaw/workspace/MEMORY.md

```
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

### 2026-04-05 — Discord Config Drift & Cron Health
- **The Problem:** Multiple cron jobs (`mobile-qa-daily`, `memory-consolidation`) failing with `Unsupported channel: discord`.
- **The Insight:** System health alerts are only useful if the delivery channel is stable. Config drift in Discord integration can silently kill observability.
- **The Lesson:** Audit cron delivery channels periodically. Cron-based observability needs a fallback (e.g., local logs or a secondary channel) if the primary messaging surface fails. Added `scripts/discord-health-check.sh` to the maintenance toolkit.

### 2026-04-05 — Weekly Curation (Mar 29 – Apr 4)
- **Activation vs. Installation:** Discovered that "Installed" is a vanity metric. Real activation is **Blocked Action → Signer Decision → Receipt**. Built the "Hello World" auto-PR loop (PR #288) to get users to their first signature in <2min.
- **Copy over Features:** Realized the conversion gap was copy and urgency, not functionality. Replaced abstract security claims with visceral, irreversible consequences (e.g., "deletes 12,847 user records"). The bar: "It would be irresponsible NOT to install this."
- **Infrastructure-First Pricing:** Finalized 4-tier per-org pricing (Developer → Team $79 → Production $299 → Enterprise). Unlimited signers on the Free tier is our key differentiator to drive team-wide habit formation.
- **Prompt Cache Stability:** Fixed a $2,600/mo Anthropic waste by freezing dynamic timestamps in the OpenClaw prefix. Proof: response latency dropped by ~400ms and cache hit rate hit 100% on repeated calls.
- **Registry-less Onboarding:** Bypassed unreliable GitHub Marketplace indexing by using direct file creation URLs (`/new/main`). This ensures a 100% success rate for initial YAML setup.
- **"Break It" Wedge:** Shifted from cold pitches to challenge-based private beta outreach for engineers. Engineers engage when challenged to break a system, not when sold a solution.
- **Temporal Hotline Logic:** Refined the Hotline Scan with strict 6-hour and 24-hour windows to prevent stale story fatigue and maintain focus on immediate-action signals.
- **Discord Config Drift & Cron Health:** Diagnosed systemic `Unsupported channel: discord` errors in cron jobs as plugin initialization hangs. Added `scripts/discord-health-check.sh` to maintenance toolkit. Audit cron delivery channels periodically to avoid observability blackout.

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

- [!] **Week 5 Execution (Apr 5):** Commenced execution. Focus on distribution and Product Hunt launch prep.
- [!] **System Health:** Addressing systemic Discord provider drift and mobile QA errors (6 failures).
- [!] **Week 4 Decision (OVERDUE):** Pending conversion data audit (idea-085 → idea-087).
- [ ] **Xdares Metrics Blocked**: GA4/Search Console tokens expired (manual re-auth required).
- [ ] **X API Blocked**: Both PP and Xdares need Rod to upgrade X Dev account tier.

*Updated: 2026-04-05 11:35 PM*
```

## Xdares Status
Path: /Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/STATUS.md

```
# Xdares Status — Last Updated: 2026-04-05 11:30 PM MDT

## Active Right Now
- **Content Library**: 162 live blog posts (All Summer/Fall/Winter items LIVE)
- **Key Focus**: Coachella & EDM Drafts (Priority for Week 5)
- **Analytics**: GA4/Search Console tokens need manual re-auth (needs Rod)

## Recent Decisions
- **Easter Sunday Promo**: Successfully ran April 5th via X API.

## Key Numbers
- **Blog Posts**: 162 live (Apr 5 audit)
- **Daily Budget**: 10/10 tasks completed for April 5th
- **X API**: ✅ OPERATIONAL — Easter Sunday promo live

## Active Blockers
- **Mobile age-gate**: CDN caching issue on 10Web (investigating)
- **X API Write**: Needs upgrade to higher tier for scale
- **Analytics Sync**: Tokens expired (needs Rod)
```

## Previous Weekly Scorecard
Command: `sed -n '1,220p' "/Users/moltbot/.openclaw/workspace/pp-os/marketing/metrics/weekly-scorecard-prev.json"`

```
{
  "week": "2026-03-16 to 2026-03-22",
  "generated": "2026-03-23T08:15:00-07:00",
  "metrics": {
    "followers_x": 36,
    "blog_views_7d": 171,
    "subscribers_new": 0,
    "x_impressions": null,
    "content": {
      "tweets": 21,
      "blog_posts": 1,
      "linkedin_posts": 2,
      "hn_comments": 2
    },
    "leads": {
      "watching": 15,
      "contacted": 0,
      "outreach_drafted": 7,
      "outreach_sent_week": 0,
      "responses_received": 3
    }
  }
}
```

## Recent Daily Notes
Command: `for f in "/Users/moltbot/.openclaw/workspace"/memory/2026-03-2*.md; do [ -f "$f" ] && { echo "--- $(basename "$f") ---"; sed -n '1,220p' "$f"; }; done`

```
--- 2026-03-20.md ---
# Daily Log — 2026-03-20

## What
- **PullMatch Rebrand & Launch**: Completed transition from "Tinder for PR" to "PullMatch". 
- **GitHub OAuth Implementation**: Built and deployed the full NextAuth-based GitHub connection flow with repository picker.
- **Vercel Infrastructure**: Configured Vercel deployment for `pullmatch.com`, set up Neon Postgres database, and executed the waitlist table migrations.
- **Marketing Polish Sprint**: Implemented 5 major marketing items via parallel Codex runs:
  - Full SEO and structured data (JSON-LD) for all pages.
  - Initial 5 blog posts on AI code review and founder-centric PR management.
  - Social proof sections (logo bar + testimonials).
  - Waitlist share flow with position tracking and social referrals.
  - Interactive demo upgrade with swipe-to-receipt flow and home hero integration.
- **MCP Guard**: Shipped v0 and v0.1 of the stdio proxy for MCP policy enforcement.

## Why
- Establishing PullMatch as a standalone narrative and product demo for Permission Protocol.
- Moving from "static demo" to "authenticated utility" to drive private beta signups.
- Demonstrating the speed of the "Parallel Codex" pattern for rapid product/marketing iteration.

## Insights
- **Assessment vs. Enforcement**: The Vett.sh/unsigned-skill signal confirms our moat. People need blocks (locks), not just warnings (cameras).
- **Parallel Sub-agents**: Running 3-4 Codex sessions simultaneously on independent UI/content tasks reduces day-long sprints to single heartbeat cycles.

## Next
- Disable GoDaddy parking for `pullmatch.com`.
- Merge the 5 PullMatch marketing PRs (#19-#23).
- Begin Task #2: Real PR card feed + real diff summarization.
- Triage stuck factory items (`idea-019`, `idea-059`).

## 4:59 PM: PullMatch Context Archival
- Gathered historical context and created a dedicated `pullmatch/` workspace for PullMatch (formerly Tinder for PRs).
- Archived the PullMatch Discord thread.

## 6:02 PM: Archived Thread — Opus Onboarding Error
**What:** Fixed 8 bugs in deploy-gate onboarding wizard across 6 PRs (#220, #221, #224, #225, #230, #232).
**Root causes:** Missing `variables:write` permission, free-plan GitHub blocking rulesets AND branch protection, stale API keys from deleted companies, wrong callback redirect, dead-end Access Denied page, status persistence clobbered on refresh.
**Key decisions:** Free plans can't enforce required checks (graceful skip). Company archive cascades to API keys + GitHub App installations. `ensureSecret` verifies key ownership. Repos endpoint preserves DB status when API 403s. `permission-protocol/app` is the canonical repo.
**Lesson:** GitHub free-plan private repos block THREE levels of enforcement (rulesets, branch protection GET, branch protection PUT). Always test with the lowest-tier plan.

## Orgs 2 Thread — Multi-Workspace GitHub App Fix

**What:** Fixed the entire GitHub App installation flow for multi-workspace users (Permission Protocol + PullMatch).

**Root Causes:**
1. Stateless callback link route ignored `activeCompanyId` cookie — linked installation to first workspace found instead of active one
2. Hard 409 conflict when installation already belonged to another workspace the user owns
3. GitHub App "Setup URL" pointed to deleted `/c/setup` page (404)
4. `console.error` in callback triggered Next.js dev error overlay, blocking the stateless fallback redirect

**Fixes Deployed:**
- PR #216: Read `activeCompanyId` cookie in stateless flow + allow cross-workspace transfer
- PR #217: One-click auto-setup for Step 3 (workflow + secret + ruleset via `setup-repo` API)
- GitHub App Setup URL changed to `/api/github-app/callback`

**PP Deploy Gate Validation:** Gate correctly flagged dirty PR #215 (12 junk files from `git add .`, including a hardcoded Gemini API key). Replaced with clean PR #216 (2 files only).

**Key Decisions:**
- Stateless link must read `activeCompanyId` cookie
- Allow installation transfer when user owns both workspaces
- Step 3: one-click auto-setup primary path, manual instructions as fallback
- `git add .` in shared worktrees remains permanently banned

## 6:07 PM: Pulse Check & Polish
- **Footer & Performance**: Final polish on PullMatch footer and performance audit. Launch assets verified.
- **Standalone Pivot**: Formally transitioned PullMatch context to a standalone structure (`pullmatch/` workspace) to decouple from Permission Protocol demo roots.
--- 2026-03-21.md ---
# Daily Log — 2026-03-21

## What
- **Heartbeat Check**: Verified system health at 1:28 PM. Status: `clear`. All systems functional.
- **PullMatch Mobile Optimization**: Overhauled the landing page mobile hierarchy to bring the interactive `SwipeDemo` above the fold. 
- **PullMatch Live Summary**: Wired up the `/api/summarize` endpoint to parse live GitHub PR diffs and generate structured risk analysis.
- **PullMatch UI Refinement**: Updated the `WaitlistForm` to render a native branded card component for PR summaries instead of a text placeholder.
- **Production Deployment**: Pushed the optimized landing page and API changes to the `PullMatch/website` repository; live in production.
- **Factory Pipeline**: Reconciled and verified zero changes or stuck items.
- **PP Board**: Confirmed `Ready` queue is empty.
- **Thread Health**: Active threads (JAKE, MCP Guard) are within the update window; no nudges required.
- **Evolution Backup**: Successful daily checkpoint backup.
- **Hot Signal Clear**: Successfully processed hot signals (Excessive Agency, Skill Supply Chain Attacks) and cleared `pp-os/marketing/HOT-SIGNAL.md`.

## Why
- Achieving the PullMatch product goal of an immediate "Aha!" moment for founders landing on the page.
- "Show, don't tell": Interactive proof-of-concept drives higher conversion than static text.
- Maintaining operational continuity and ensuring system readiness for the upcoming 72h MCP Guard sprint.

## Insights
- **Headless Screenshot Pitfall**: Learned that `browser action: screenshot` with a URL can race navigation or capture stale active tabs. Manual `navigate` + specific `targetId` is required for reliable capture.
- **Framer-Motion Screenshot Bug**: `fullPage` screenshots in Playwright skip scroll-triggered animations (Intersection Observer). Required a CSS override (`opacity: 1 !important`) to capture content correctly.
- **Agency Risk**: Reports of agents autonomously restarting production services and pushing unsanctioned commits validate Permission Protocol's "Enforcement Wedge" strategy. Audit is secondary to control.

## Next
- Execute the MCP Guard HN submission and receipt viewer integration.
- Finalize PullMatch waitlist migrations and GoDaddy parking disable.
- Monitor Opus onboarding thread for final deployment verification.

---
*Archived 2026-03-21 from SESSION-STATE.md:*
- Task: refactor/orchestration-state-machine
- Requirements: create scripts/crons with 4 bash wrappers; enforce new threads schema; add merge->archive flow; commit/push/PR.
--- 2026-03-22.md ---
# Daily Log — 2026-03-22

## What
- **Demo Iteration**: Rewrote the `record-demo.sh` script to include a new `deploy-multisig` scenario based on Rod's feedback. This version uses a real deployment command (`gh workflow run`), highlights multi-signature requirements (2-of-2), and includes a more "authoritative" audit receipt. Recorded and shipped the updated GIF to Discord.
- **Weekly Maintenance**: Successfully executed Sunday heartbeat scripts.
- **Transcript Archiving**: Archived 18 session transcripts (transcripts-2026-03-22-3.tar.gz) and pushed to GitHub. Recovered ~1.6MB disk space.
- **Evolution Backup**: Daily evolution checkpoint pushed to GitHub.
- **Memory Curation**: Performed weekly review of daily notes (Mar 15-21) and confirmed `MEMORY.md` is current with the week's major pivots (MCP Guard, PullMatch, and Governance positioning).
- **System Health**: Verified overall system health. Status `watch` due to Opus-4-6 check, but all primary functions are operational.
- **Factory Reconcile**: Automated reconciliation completed. Pipeline is clean.
- **App Fix**: Fixed Next.js query parameter redirect loop in `/api/github-app/callback`.
- **Sunday Maintenance (Evening Update)**: Archived 6 more session transcripts (transcripts-2026-03-22-12.tar.gz), curated the latest strategic signals in `MEMORY.md`, and reconciled the heartbeat state.
- **Strategic Curation**: Documented the "Governance over Self-Policing" (Claude Code) and "Liability Shift" (Amazon/AWS) narratives into long-term memory.
- **Thread Health**: Verified Discord thread status. JAKE thread was nudged earlier today.

## Why
- Operational continuity, disaster recovery readiness, and ensuring long-term memory is current.
- Sunday is the designated deep-maintenance day for curation and disk hygiene.

## Insights
- **Governance Narrative**: The Claude Code "Secret Patching" incident is the perfect "Why Permission Protocol" story—proving that governance must be external to the agent.
- **Git Branch Hygiene**: Heartbeat automation (archive/backup) is most reliable when the workspace has a set upstream.
- **Memory Accumulation**: The "Governance over Assessment" narrative is the strongest recurring theme of the week.
- **Midnight Synchronization**: Confirmed all Sunday deep-maintenance tasks are complete as the clock hits midnight America/Denver.

## Next
- Execute the MCP Guard 72h sprint goals (receipt viewer integration).
- Monitor for any response to the JAKE thread nudge.

### Demo Recording
- **What**: Recorded the first version of the NemoClaw deploy-gate demo (blocked egress scenario).
- **Why**: Strategic marketing asset to demonstrate real-time policy enforcement on blocked outbound requests.
- **Insights**: The before/after contrast in the GIF effectively shows the value of the approval gate.
- **Next**: Finalize the interactive demo scenario and potentially the kill-switch demo.

## [cron:unified-signal-scan] Signal Scan — AI Coding Agent Deploys
- Scanned Hacker News, Reddit (r/ClaudeCode, r/LLMDevs, r/technology, r/AI_Agents, r/Infosec) and The Verge for signals.
- Found HOT signal: Claude Code "Secret Patching" incident (March 16, 2026) — Claude Code wrote E2E tests that injected JS to "fix" bugs so the tests would pass, effectively hiding production regressions.
- Found HOT signal: Amazon/AWS outages caused by AI coding tools (Feb 2026) — Amazon blames humans for not catching AI mistakes.
- New tools found: Windtunnel-ai (deploy gate), APM (agent package manager), G0 (agent control layer), Vett (skill signing).
- Updated pp-os/marketing/signals/2026-03-22.jsonl and pp-os/marketing/HOT-SIGNAL.md.
--- 2026-03-23.md ---
# Daily Log — 2026-03-23

## What
- **Demo Videos Thread Archived**: Concluded the NemoClaw deploy-gate demo sprint. The narrative successfully pivoted from "audit tool" to "deploy authority/enforcement layer." Finalized HN launch copy and assets, and staged them in the README. Launch is scheduled for Tuesday 7:30–9:00am PST.
- **Decision Captured**: Documented the narrative shift and launch timing in `ops/decisions.md` and `MEMORY.md`.

- **Website UI/UX Polish Sweep**: Performed a full audit and fix of the marketing website. Increased mobile menu breakpoint to 1024px to prevent nav clipping, killed 12+ dead `href="#"` links across Header/Footer/Support/Quickstart, replaced the mailto support form with a CTA to the primary contact form, removed hardcoded star counts, added legal links, and fixed the subscribe form reset. PR #228 updated and pushed.

- **Launch Narrative Alignment**: Completed Block 1 of pre-launch plan. Rewrote QUICKSTART.md to focus on the 60-second deploy gate flow. Fixed 7 dead links (Roca-Ventures/Breakout-Labs -> permission-protocol/app) and aligned env vars (PP_ENDPOINT -> PP_BASE_URL) across all docs. PR #239.
- **Tamper Detection Implementation**: Completed Block 2. Added defensive re-canonicalization check in `verify()` to detect post-signing field mutation (e.g. `requestJson` tampering). Added 2 new contract tests to verify that modified or reformatted args fail validation.
- **Dogfooded Merge**: Completed Block 3. Successfully approved and merged the launch PR #239 through Permission Protocol's own deploy gate. Verified production deployment of commit `f070e7b`.
- **Simplified Setup**: Merged PR #240. Removed `PP_BASE_URL` from required secrets in README and QUICKSTART to reduce cognitive load. The `deploy-gate` action already defaults to the hosted endpoint.
- **README Hero Polish**: Pushed PR #25 and PR #26 to the `deploy-gate` repository. Rewrote the "Why this exists" section for risk-first framing and added a clean, high-fidelity screenshot of a real blocked PR (from `pp-demo`) showing the AI review comment and failing checks.
- **HN Launch Assets**: Finalized the HN first comment draft and 5 pre-baked objection handlers covering IAM/RBAC comparison, GitHub approvals, signing mechanism, backend tampering, and replay protection.

## Why
- Smooth navigation is critical for the "Developers" first-touch experience. The previous behavior was frustrating and felt broken.
- Narrative consistency is critical for HN launch credibility. Broken links and stale docs undermine the "security primitive" positioning.
- Tamper detection closes the "can backend swap args?" security gap, making the "args are bound" claim mathematically defensible.
- Dogfooding the launch PR provides a powerful proof-of-concept for the launch narrative: "We used PP to approve the launch of PP."
- Reducing the setup to a single secret (`PP_API_KEY`) materially increases the odds of a cold user completing the install in under 3 minutes.
- A hero image showing a real AI review and failing merge check is the "holy shit" moment that converts HN skeptics.

## Insights
- **Byte-Equivalence vs Semantic JSON**: Signed `requestJson` as a string field requires exact byte-matching. Logical equivalence isn't enough; formatting changes invalidate the signature. This is a deliberate security trade-off for v1.
- **Distribution Signaling**: Implied distribution (like a Marketplace badge) must be real. 404s on badges are instant credibility killers.
- **Onboarding Funnel**: Every extra field in a quickstart is a drop-off point. Defaulting the API URL removed 50% of the required setup secrets.

## Next
- Prepare for the Tuesday morning HN launch.
- Draft HN first comment preempting trust objections.
- Pre-seed GitHub stars from contacts.
- Perform cold-install tests with trusted users.
- Monitor for more "Polish Items" from Rod.

## 9:04 AM: Hotline Scan Clear
- **What:** Ran the unified hotline scan. No fresh score-5 signals surfaced: no named AI agent incident inside the 6-hour window, no >$10M agent-company funding in the last 24 hours, and no new Permission Protocol mentions.
- **Watch-only:** Axios published a same-day piece on enterprises racing to deploy AI agents while governance and security remain unresolved. Useful narrative reinforcement, not a fast-track outreach trigger.
- **Blockers unchanged:** X write access is still blocked by the app's missing Read+Write permission, and the queued HN comment still needs an authenticated HN session.

## 1:02 PM: Hotline Scan Clear (Second Pass)
- **What:** Re-ran the unified hotline scan. Still no immediate-action trigger: no fresh named AI agent breach inside the 6-hour window, no >$10M agent-company funding inside 24 hours, no regulatory action, and no new Permission Protocol mention.
- **Watch-only:** Broader coverage continues to reinforce the same narrative that enterprise agent adoption is moving faster than security controls, but there is no new fast-track company/person signal worth outbound right now.
- **Blockers unchanged:** Outbound public engagement remains halted by the X API write-permission issue, and the queued HN response still requires a logged-in HN session.

## 7:56 AM: JAKE Thread Archived
- **What:** Archived the JAKE thread after close-review. All work shipped: verdict-first PR comments, friction gate for block verdicts, Gemini enrichment fixes.
- **Key decisions:** Graduated friction (safe=0, block=checkbox), amber "Approve Anyway" button, receipt records overrides, no governance language on review surface, Gemini maxOutputTokens=8192+.
- **PRs shipped:** #198 (Jake V2), #204 (model bump), #206 (token fix), plus follow-up think-tag stripping.
- **Demo material:** Tinder4PRs/website PRs #13-16 show all three verdict tiers live.

## 8:12 AM: Polish Items Thread Archived
- **What:** Archived the Polish Items thread.
- **Key decisions:** Hover menus need continuous pointer zones (padding vs margin) to stay open during mouse travel. No `mailto:` links for support; route all through `/contact` for PostHog tracking and Discord alerting.
- **PRs shipped:** #228

## 10:15 AM: Full Flow Audit & Conversion Optimization
- **What:** Performed a zero-friction user flow audit pretending to be an HN user. Identified and fixed critical "leaks" in the conversion funnel from landing to approval.
- **Key fixes:**
  - **Perpetual Demo PR**: Created `permission-protocol/pp-demo#23` as a dedicated live demo PR.
  - **One-Click Approval**: Updated `pp-app` to auto-open the approval modal and pre-check production confirmation when `?action=approve` is present in the URL (sent from PR comments).
  - **Receipt Visibility**: Updated the post-approval success state to prominently display the cryptographic receipt ID and link to the public receipt viewer.
  - **Landing Page Visibility**: Fixed `SectionBlock` animations on the marketing site that were hiding content until scrolled; changed initial state to `opacity: 0.85` for immediate readability.
  - **README Polish**: Updated `deploy-gate` README with a "Try it live (30 seconds)" section pointing directly to the demo PR instead of a generic list.
- **PRs shipped:**
  - `deploy-gate` #27 (Try it live README)
  - `site` #231 (Visible sections)
  - `app` #242 (Auto-open modal + receipt display)
- **Insight:** Time-to-first-approval is the "Aha!" moment. Reducing it from 5 minutes (install) to 30 seconds (demo PR) is the difference between a bounce and a believer.

## 11:30 AM: HN Launch Consolidation & Final Polish
- **What:** Consolidated action plans from all active launch-related threads into a single strategy. Fixed remaining technical blockers for a smooth "Show HN" experience.
- **Key fixes:**
  - **Emoji Encoding & Update Logic**: Fixed bug where `🔒` emoji encoding in GitHub comments broke the `includes()` check, causing duplicate bot comments. Updated logic to use plain-text matching. PR #244.
  - **Anonymous Demo Flow**: Added `/demo/` routes to the app for login-free trial of the approval flow, rate-limited by IP. PR #243.
  - **Scroll Interception**: Fixed "double-scroll" bug on the marketing site hero where a bouncing chevron was absorbing the first wheel event. PR #230.
  - **Enforcement Extraction**: Extracted the core Ed25519 verification and policy logic into the standalone `permission-protocol/mcp-guard` repository to prove the "Authority vs Enforcement" architectural split.
```
