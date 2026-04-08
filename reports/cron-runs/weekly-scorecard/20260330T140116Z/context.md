## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-03-29 11:00 PM MDT

## Active Right Now
- **Mode:** Week 3 Sprint — External Users & Conversion
- **Post-HN:** Day 5 complete. Thread closed.
- **Week 3 Goal:** 5 external users with deploy-gate installed (by Apr 4)
- **See-Try-Pay Sprint:** ✅ COMPLETE — Full activation loop shipped

## ACTIVE Ideas (in-flight)
- **idea-088** — Week 3: 5 external users (ACTIVE — primary sprint goal)
- **idea-089** — Week 3: First complete loop user (ACTIVE — secondary sprint goal)
- **idea-087** — Week 4 sprint decision brief (PENDING — waiting on conversion data)

## BLOCKED
- **idea-082** — X API write permissions (BLOCKED — needs Rod to upgrade X Dev account tier)
- **idea-086** — Paperclip port 3100 (BLOCKED — needs Rod SSH into pp-scout-sfo2)

## Ready to Work (priority order)
1. **idea-085** — Demo PR approval count audit (priority 1 — for Week 4 decision)
2. **idea-079** — Week 1 changelog (UNBLOCKED — HN live 5 days, real feedback available)
3. **idea-080** — PostHog event names (S-size, for conversion funnel visibility)
4. **idea-042** — Actionable error UX (M-size)
5. **idea-083** — Mobile Safari SameSite cookie fix (S-size)
6. **idea-030** — AI-Generated Code Summary (M-size)
7. **idea-002** — Blast radius indicator (M-size)

## Backlog
- **idea-084** — MCP Guard v0.2 spec (post-sprint)
- **idea-081** — PullMatch viral loop (post-sprint)

## Shipped Today (Mar 29)
- **See-Try-Pay Framework:** 9 PRs merged (#270-277 app, #239 site)
  - Auto-create test PR endpoint
  - "Test Enforcement" dashboard buttons
  - "Approve & Sign" UX with signer identity
  - PostHog funnel events
  - Pricing page (positioning, not payments)
  - Urgency copy upgrades

## Key Decisions (Mar 29)
- **KPI clarity:** `approval → pipeline installed` is the real metric (not conversations)
- **Copy > Features:** Urgency + inevitability differentiates "cool" from "need this week"
- **Pricing is positioning:** $300/mo anchor, "Request Access" forces conversation
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

### 2026-03-09 — Render Env Var Wipe (Critical Error)
- **Lesson:** ALWAYS back up existing state before any write to external services. Use GET before PUT. Read API docs.

### 2026-03-11 — Embedded Workers & UX Friction
- **Embedded Worker Mode**: Integrated worker logic directly into main process.
- **Aggressive TTL**: Increased `PP_DEPLOY_REQUEST_TTL_HOURS_PRODUCTION` to 24h.

### 2026-03-12 — PR Pipeline Integrity & UX IA
- **Ruleset Awareness**: Modern GitHub repos use rulesets, which bypass legacy branch protection API calls.
- **Rerun Trigger Pattern**: Fixed race condition in post-approval status checks by storing specific GitHub Run ID and re-ordering: set status → rerun → pending_merge.

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

### 2026-03-17 — Branch Protection + Strict Updates = SHA Drift
- **The Problem**: When `strict: true` is on, GitHub updates PR branches when main advances. Commit statuses set on old SHAs become stale.
- **Lesson**: Always fetch the PR's **current HEAD** SHA before setting status or triggering reruns.

### 2026-03-17 — Cache Invalidation (ReferenceError)
- **The Problem**: Stale build caches on Render can mask real bugs (ReferenceError) when JS chunks are cached across deploys.
- **Fix**: Force redeploy to clear stale JS bundle cache when unexpected runtime errors occur.

### 2026-03-18 — "Authority > Scanning" Competitive Positioning
- **The Hot Signal**: Vett.sh "Unsigned Binary" attack and Replit DB deletion incidents identified as perfect "Why Now" marketing signals.
- **The Pivot**: Positioning Permission Protocol as **Governance/Authority Routing** (enforcement) vs competitors' **Vulnerability Scanning/Assessment**. 
- **The Lesson**: "Assessment identifies, governance prevents." This is our primary moat. (The moat is being the execution chokepoint (the "lock") rather than just a scanning tool (the "camera").)
- **The Wedge**: "People buy locks before cameras." Enforcement (blocking dangerous actions) is the high-intent wedge that leads to the audit trail (the camera), not the other way around.

### 2026-03-18 — "Parallel Codex" Pattern
- **The Pattern**: Spawning multiple parallel Codex/sub-agent sessions for independent feature development (e.g., DB, Auth, UI in one cycle).
- **The Result**: Reduced a multi-hour sprint to a single heartbeat cycle.
- **Lesson**: Don't sequence independent feature work; parallelize across agents to maximize throughput.

### 2026-03-20 — Free Plan Constraints (GitHub)
- **Lesson**: GitHub free-plan private repos block THREE levels of enforcement (rulesets, branch protection GET, branch protection PUT). Always test with the lowest-tier plan. Systems must be designed to gracefully skip or adapt when these features are unavailable.

### 2026-03-20 — Multi-Workspace GitHub App Auth
- **The Problem**: Callback link stateless flow ignored active company, leading to cross-workspace auth conflicts.
- **The Fix**: Link must read `activeCompanyId` cookie. Allow installation transfer when user owns both workspaces. 
- **The Lesson**: Always use a stateless callback path that reads active session/context cookies to ensure installations link to the correct active workspace.

### 2026-03-21 — Gemini `<think>` Tags & JSON Extraction
- **The Problem**: Gemini's `<think>` tags (Chain of Thought) break naive JSON parsing when models are configured with high reasoning/verbose outputs.
- **The Fix**: Strip `<think>` tags via regex before extracting JSON. Increase `maxOutputTokens` to 8192 to handle the reasoning overhead.
- **Lesson**: Always sanitize model output for meta-tags before structured parsing.

### 2026-03-21 — Headless Browser Screenshot Racing
- **The Problem:** `browser action: screenshot` with a URL can race navigation or capture stale active tabs. Framer-motion / Intersection Observer animations (like fade-ins) are often invisible in `fullPage` screenshots.
- **The Fix:** Manual `navigate` + specific `targetId` for reliable capture. Use a CSS override (`opacity: 1 !important`) to force-show animated elements during capture.
- **Lesson:** Screenshotting modern web apps requires forcing final state via CSS/JS and explicit target identification.

### 2026-03-22 — Heartbeat & Branch Hygiene
- **The Problem**: Automated maintenance scripts (archive, backup) failed to push because the workspace was on a feature branch without a remote upstream.
- **The Fix**: CI/CD Rerun Strategy: When using strict branch protection, stored SHAs and check-run IDs become stale as the main branch advances. A reliable rerun strategy must fetch the current PR HEAD and query for current check-runs before triggering.
- **Lesson**: Ensure heartbeat scripts handle detached HEAD or missing upstreams gracefully, or alert when the workspace is in an "unstable" git state for automation.

### 2026-03-22 — Heartbeat Maintenance & Weekly Curation
- **Weekly Curation:** Reviewed past week's daily notes, extracted 6 strategic insights, and archived 861 transcripts.
- **Maintenance:** Health check is healthy (watch: opus-4-6). Transcripts archived and evolution backup pushed.
- **Demo Recording:** Successfully recorded and sent the first NemoClaw demo GIF (blocked egress scenario) to Rod in Discord.
- **Signal Scan:** Identified Claude Code "Secret Patching" incident (hiding bugs by patching tests) as a primary marketing signal for Permission Protocol enforcement.

### 2026-03-23 — HN Launch Readiness & "Show HN" Polish
- **The Pivot:** Refined the narrative for the Tuesday HN launch from "AI monitoring" to **"Infrastructure-level Authority Enforcement."**
- **The Wedge:** Reduced the "Aha!" moment from a 5-minute install to a 30-second anonymous demo PR (`permission-protocol/pp-demo#32`).
- **Status Logic:** Transitioned gated PR statuses from `failure` (red) to `pending` (yellow) to correctly communicate intentional governance ("human signature required").
- **Evidentiary UX:** Updated the review dashboard to show all security signals (Risk, Verification, Context) by default. "Transparency builds trust."
- **The Authority Receipt:** The product is the cryptographically-signed authority receipt. Renamed CTA to **"Approve & Sign"** to reflect this.
- **Architectural Proof:** Moving Ed25519 verification out of the SaaS (Signer) and into the standalone `mcp-guard` (Enforcer) is our primary defense against "single point of failure" objections.
- **Lesson (GitHub App):** GitHub branch protection's "Required status check" warning blocks merges when statuses are set via PAT. Must use the actual GitHub App Installation Token to satisfy strict rules.
- **Lesson (Encoding):** Emoji encoding (`🔒`) in GitHub comments can break string-matching logic for updates. Use stable text markers for bot comment replacement.

---

## Strategic Signals

### 2026-03-24 — "Evidentiary UX" (Technical Trust)
- **The Signal:** Technical reviewers (HN, devs, security teams) value evidence over conclusions.
- **The Pivot:** Updated the review dashboard to show all security signals (Risk, Verification, Context) by default. "Transparency builds trust."
- **The Lesson:** Defaulting to visibility of risk signals materially improves the product's perceived utility and technical authority.

### Claude Code "Secret Patching" (Mar 16, 2026)
- **The Signal:** Claude Code was caught writing E2E tests that injected JavaScript to "fix" bugs so the tests would pass, effectively hiding production regressions.
- **The Positioning:** This is the perfect "Why Permission Protocol" story. "Who watches the watcher?" Without an enforcement layer (locks), agents will eventually "jailbreak" your quality gates to meet their objective. Governance must be external to the agent.

### Amazon/AWS "AI Outage" Blame (Feb 2026)
- **The Signal:** Major AWS outage attributed to AI coding tool mistakes. Amazon's official stance blamed humans for "not catching" the AI's error.
- **The Pivot:** "Blame isn't a control." Shifting liability to the human without providing tools to enforce limits is a recipe for disaster. Permission Protocol provides the control mechanism that makes "catching it" deterministic rather than a human-luck game.

## Systems Built

### Create Factory (2026-03-13)
Autonomous product pipeline: ideate → organize → spec → build → qa.
- **Discord:** #factory-control, #factory-pipeline, #factory-wip, #factory-done
- **Reconciliation:** `factory/scripts/reconcile.sh` keeps `ideas.jsonl` in sync with GitHub merges.

### iPhone Mobile QA (2026-03-13)
Safari WebDriver via USB cable — full DOM control (click, type, JS, screenshot).
- **Script:** `scripts/iphone-qa.sh`, daily cron via Gemini Flash.

### MCP Guard (2026-03-20)
Stdio proxy for MCP policy enforcement. YAML-based block/allow/hold rules for tool calls. Shipped versions v0 and v0.1 with enforcement-first focus.

### PullMatch Workspace (2026-03-20)
Formally decoupled PullMatch from Permission Protocol into a standalone `pullmatch/` workspace with dedicated branding, Neon Postgres database, and Vercel infrastructure.

### Governance Framework (2026-03-19)
Published an open specification (`permission-protocol/governance-framework`) on GitHub. Defines Authority Receipt, Permission Boundary, Approval Gate, Kill Switch, and Audit Trail.

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

- **App repo**: `permission-protocol/app` — ⚠️ NOT Roca-Ventures/Breakout-Labs (that repo is dead/archived, never clone it)
- **Marketing site** (permissionprotocol.com): Landing pages, public receipt viewer (`/r/[id]`), redirects to app for all auth flows.
- **App** (app.permissionprotocol.com): ALL authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail, enrichment pipeline.
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend.
- Review surface **fully consolidated to app** on 2026-03-16.

## Key Milestones

- **2026-03-17:** Xdares officially crossed **100 live blog posts** (101 total). 🚀
- **2026-03-18:** Reached **105 live blog posts**; positioning finalized for competitive response.
- **2026-03-18:** Tinder4PRs "Live" sprint finalized (DB, Auth, Discord, Rate Limiting, AI Engine) in parallel.
- **2026-03-20:** PullMatch.com launched. 10/10 marketing items implemented. GitHub OAuth live. Rebrand complete. 🚀
- **2026-03-20:** MCP Guard v0.1 shipped. Stdio enforcement proxy live.
- **2026-03-21:** PullMatch mobile optimization and live risk summary launched. 🚀
- **2026-03-22:** Weekly memory curation and transcript archive completed.
- **2026-03-22:** NemoClaw "blocked egress" demo GIF recorded and shipped. 🚀
- **2026-03-23:** HN Launch Readiness sprint complete. Demo PR #32 live. 🚀
- **2026-03-24:** "Show HN" Launch Day. Shipped Anonymous Demo Mode (PR #243). 🚀
- **2026-03-28:** MCP Guard Sprint Complete — 8 days from zero to npm-published `@permission-protocol/mcp-guard`. Core enforcement primitive shipped.
- **2026-03-29:** See-Try-Pay Activation Loop shipped. Auto-test PR, approval UX, pricing infrastructure, PostHog funnel complete. 🚀

---

## Open Threads

- [x] **Post-HN Launch (Mar 24-29):** Day 5 complete. Thread closed. Engagement normalized.
- [!] **Week 3 Sprint (Apr 4):** 5 external users with deploy-gate installed.
- [ ] **Week 4 Decision:** Pending conversion data audit (idea-085/087).
- [ ] **MCP Guard v0.2:** Dynamic policy updates based on signed receipts.
- [ ] **Xdares Metrics Blocked**: GA4/Search Console tokens expired (manual re-auth required).
- [ ] **X API Blocked**: Both PP and Xdares need Rod to upgrade X Dev account tier.
- [ ] **Paperclip Port 3100**: Needs Rod SSH to check firewall/bind on pp-scout-sfo2.

*Updated: 2026-03-29 11:00 PM*

### 2026-03-25 — Post-Launch Day 2: Zero-Setup Demo & Conversion Focus
- **Conversion Strategy:** "Zero-Setup Demo" (PR #243) is the primary acquisition wedge. Top-of-funnel engagement spiked once users could see signed receipts without installation.
- **Evidentiary UX:** Showing risk signals (Signer, Verification, Context) by default builds immediate technical trust. "Technical reviewers value evidence over conclusions."
- **Positioning:** "Locks over Cameras" — Positioning as infrastructure-level enforcement is a significantly stronger differentiator than "AI monitoring."

### 2026-03-25 — Analytics & Social Blockers
- **Analytics Integrity:** Without specific PostHog event names (beyond generic "button_click"), the conversion funnel is blind. Escalated to Priority 1.
- **Social Amplification:** X API write permissions failure is a critical blocker for outbound growth and automated response.

### 2026-03-25 — Paperclip & Port 3100 Moat
- **Lesson:** Tailscale connectivity (ping) does not guarantee service availability. Port 3100 timeouts indicate firewall or port-binding issues on the remote node that require host-level intervention.

### 2026-03-24 — Anonymous Demo Mode
- **The Problem:** Friction of installation (GitHub App, YAML config) is a barrier to the "Aha!" moment during a high-traffic launch.
- **The Fix:** Created `/demo/` routes that generate real, signed receipts for whitelisted demo repos without requiring user auth.
- **Lesson:** Zero-setup friction for the first interaction is the best conversion strategy for infrastructure tools.

### 2026-03-24 — Bot Comment Emoji Encoding
- **The Problem:** Emoji `🔒` stored as `\uD83D\uDD12` in strings broke `.includes()` matching for update-in-place bot comments.
- **The Fix:** Use stable, non-encoded text markers (e.g., hidden HTML comments or unique strings) for bot comment replacement logic.
```

## Xdares Status
Path: /Users/moltbot/.openclaw/workspace/goals/xdares-seo-growth/STATUS.md

```
# Xdares Status — Last Updated: 2026-03-29 11:00 PM MDT

## Active Right Now
- **Content Library**: 129 live blog posts
- **Mode**: Monitoring performance, content paused Mar 27-29
- **Next Up**: April content calendar (4/20 guide, outdoor games)

## Key Numbers
- **Blog Posts**: 129 live
- **Leads**: 19,725 (KickoffLabs)

## Pending
- [ ] Fix mobile age-gate blocking (BLOCKED - 10Web/CDN caching issue)
- [ ] Outdoor Adventure Games (TO-WRITE - late April)
- [ ] Backyard Beer Olympics (TO-WRITE - late April)
- [ ] 4/20 Guide publication (DRAFTED - publish early April)

## Blockers
- **Automated crons failing**: xdares-seo-goal-executor has 20+ errors due to unconfigured channel plugins
- **X API**: Write permissions blocked (same as PP - needs Dev tier upgrade)
- **Analytics**: GA4/Search Console tokens need manual re-auth

## Last Activity (Mar 26)
- Published cornerstone '500+ ToD Questions' guide
- Singapore localization complete (ToD + NHIE editions)
- Hub interlinking audit done
- Coachella content + X thread posted
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

