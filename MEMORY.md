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

### 2026-04-01 — Mobile Density & Evidentiary UX
- **The Problem:** Long, airy mobile pages hide the "Aha!" moment (the Action Request) below the fold on small viewports.
- **The Fix:** Systematic 30-40% reduction in vertical rhythm (pt/pb/gap) for mobile. Implemented a glassmorphism "sticky bottom" action bar for approvals to ensure CTAs are always reachable.
- **The Lesson:** On mobile, high information density + persistent actions = technical authority. Whitespace is a luxury the "Signer" UI can't afford if it hides the evidence.

### 2026-03-31 — Prefix Instability & Prompt Caching (The $2,600 Bug)
- **The Problem:** 62% of Anthropic spend was wasted on `input_cache_write` due to an unstable prompt prefix.
- **Root Cause:** A dynamically generated current timestamp (`userTime`) was being injected into the system prompt *above* the cache breakpoint, causing every message to re-cache 60k+ tokens.
- **The Fix:** Surgically patched the prompt assembly logic to freeze the timestamp for cache stability.
- **Lesson:** High cache write/read ratios (2:1 or worse) are a red flag for dynamic data injection above the cache boundary. Prompt caching becomes a liability if the prefix isn't bit-identical.

### 2026-03-31 — Zero-Friction Demo (V2 Redesign)
- **The Strategy:** Reduced the "Aha!" moment to a 15-second, standalone static experience (no DB/setup) at `/demo`.
- **The Execution:** Used Codex with a specific emerald terminal design system. 5-screen flow emphasizing the "Authority Receipt."
- **Lesson:** Technical conversion is about evidence, not just flow. The "Authority Ledger" with dynamic timestamps and signed receipts is the core value-add.

### 2026-03-31 — API Burn Audit
- **Findings:** Total March spend ~$5,300. Gemini ($1,003) vs. Anthropic ($4,300).
- **The Waste:** ~50% of Anthropic spend was avoidable cache-misses.
- **Lesson:** Monthly audits of `usage` logs are mandatory for autonomous systems to prevent silent cost explosions.

### 2026-03-09 — Render Env Var Wipe (Critical Error)
- **Lesson:** ALWAYS back up existing state before any write to external services. Use GET before PUT. Read API docs.

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

### 2026-03-18 — "Authority > Scanning" Competitive Positioning
- **The Pivot**: Positioning Permission Protocol as **Governance/Authority Routing** (enforcement) vs competitors' **Vulnerability Scanning/Assessment**. 
- **The Lesson**: "Assessment identifies, governance prevents." This is our primary moat. (The moat is being the execution chokepoint (the "lock") rather than just a scanning tool (the "camera").)
- **The Wedge**: "People buy locks before cameras." Enforcement (blocking dangerous actions) is the high-intent wedge that leads to the audit trail (the camera), not the other way around.

### 2026-03-18 — "Parallel Codex" Pattern
- **The Pattern**: Spawning multiple parallel Codex/sub-agent sessions for independent feature development (e.g., DB, Auth, UI in one cycle).
- **The Result**: Reduced a multi-hour sprint to a single heartbeat cycle.
- **Lesson**: Don't sequence independent feature work; parallelize across agents to maximize throughput.

### 2026-03-20 — Free Plan Constraints (GitHub)
- **Lesson**: GitHub free-plan private repos block THREE levels of enforcement (rulesets, branch protection GET, branch protection PUT). Always test with the lowest-tier plan. Systems must be designed to gracefully skip or adapt when these features are unavailable.

### 2026-03-21 — Gemini `<think>` Tags & JSON Extraction
- **The Problem**: Gemini's `<think>` tags (Chain of Thought) break naive JSON parsing when models are configured with high reasoning/verbose outputs.
- **The Fix:** Strip `<think>` tags via regex before extracting JSON.
- **Lesson**: Always sanitize model output for meta-tags before structured parsing.

### 2026-03-21 — Headless Browser Screenshot Racing
- **The Problem:** Framer-motion / Intersection Observer animations are often invisible in `fullPage` screenshots.
- **The Fix:** Manual `navigate` + specific `targetId` for reliable capture. Use a CSS override (`opacity: 1 !important`) to force-show animated elements during capture.
- **Lesson:** Screenshotting modern web apps requires forcing final state via CSS/JS and explicit target identification.

### 2026-03-23 — HN Launch Readiness & "Show HN" Polish
- **The Pivot:** Refined the narrative for the Tuesday HN launch from "AI monitoring" to **"Infrastructure-level Authority Enforcement."**
- **The Wedge:** Reduced the "Aha!" moment from a 5-minute install to a 30-second anonymous demo PR (`permission-protocol/pp-demo#32`).
- **Status Logic:** Transitioned gated PR statuses from `failure` (red) to `pending` (yellow) to correctly communicate intentional governance ("human signature required").
- **Evidentiary UX:** Updated the review dashboard to show all security signals (Risk, Verification, Context) by default. "Transparency builds trust."
- **The Authority Receipt:** The product is the cryptographically-signed authority receipt. Renamed CTA to **"Approve & Sign"** to reflect this.
- **Architectural Proof:** Moving Ed25519 verification out of the SaaS (Signer) and into the standalone `mcp-guard` (Enforcer) is our primary defense against "single point of failure" objections.

### 2026-04-03 — Onboarding Activation & Authority Route
- **The Problem:** GitHub Marketplace search indexing is unreliable for new products, causing 100% bounce rates in onboarding. High-chrome dashboards distract from the "Authority" of signing.
- **The Fix:** 
    - Moved to **Direct File Creation URLs** (`/new/main?filename=...`) for the `.github/workflows/deploy-gate.yml` setup, bypassing the marketplace search.
    - Built a dedicated **chromeless `/approve/:id` route** to maximize authority signal and minimize dashboard noise during the signing act.
- **The Lesson:** In security infrastructure, the "Signer" mindset is "decide," not "explore." Remove the chrome. Direct URLs > Marketplace indexing.

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

---

## Strategic Signals

### 2026-04-01 — Pricing & Conversion Calibration
- **The Signal:** A $0→$300 cliff is a conversion bug.
- **The Fix:** Introduced the $79 "Team" tier to capture early-stage startups who need repo-level security but aren't yet at "Enterprise" scale.
- **Calibration Plan:** 60-day window to track Free→Team conversion and repo cap hits before adjusting again.

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

### PullMatch Workspace (2026-03-20)
Formally decoupled PullMatch from Permission Protocol into a standalone `pullmatch/` workspace with dedicated branding, Neon Postgres database, and Vercel infrastructure.

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

---

## Open Threads

- [!] **Week 4 Sprint (Apr 4):** 5 external users with deploy-gate installed. 3 days remaining.
- [!] **Week 4 Decision (OVERDUE):** Pending conversion data audit (idea-085 → idea-087).
- [ ] **Xdares Metrics Blocked**: GA4/Search Console tokens expired (manual re-auth required).
- [ ] **X API Blocked**: Both PP and Xdares need Rod to upgrade X Dev account tier.

*Updated: 2026-04-01 11:00 PM*

### 2026-04-03 — Activation Redefinition & Hello World Auto-PR
- **The Insight:** "Installed" ≠ activated. Real activation = blocked action → signer decision → receipt. Everything before that is setup theater.
- **The Build:** Hello World auto-PR is Priority 1. Two-phase commit: (1) PP commits gate YAML via GitHub App, (2) PP opens safe test PR that triggers the gate. User experiences blocked → sign → receipt in minutes, not days.
- **The Edge Cases:** `contents:write` permission upgrade needed. Branch protection unreadable on Free plans — need try-commit-then-fallback strategy. Org-level installs need explicit repo selection step.
- **The Monetization Hook:** Solo user = Free forever. Second signer (teammate) = paid tier. Design the upgrade moment as carefully as activation.

### 2026-04-03 — Permission Protocol Design System
- **The Sovereign Logic:** Enforced the design system for AI UI generation by creating `permission-protocol/app/DESIGN.md`. The design moves away from SaaS tropes, leaning into a terminal-chic aesthetic (Obsidian background, Neon Emerald primary, Glassmorphism, and Space Grotesk/Inter typography). This ensures agents maintain the "Evidentiary UX" feel.
