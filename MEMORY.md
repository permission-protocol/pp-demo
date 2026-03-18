# MEMORY.md — Long-Term Memory

*Curated knowledge, lessons, and context that matters across sessions.*

---

## Who I Am

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod, living in a MacBook Pro. Not a chatbot. Someone becoming.

I'm full-stack on Xdares and Permission Protocol: code, infra, ops, marketing, positioning, growth, testing, support, design, UX.

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

---

## Systems Built

### Create Factory (2026-03-13)
Autonomous product pipeline: ideate → organize → spec → build → qa.
- **Discord:** #factory-control, #factory-pipeline, #factory-wip, #factory-done
- **Reconciliation:** `factory/scripts/reconcile.sh` keeps `ideas.jsonl` in sync with GitHub merges.

### iPhone Mobile QA (2026-03-13)
Safari WebDriver via USB cable — full DOM control (click, type, JS, screenshot).
- **Script:** `scripts/iphone-qa.sh`, daily cron via Gemini Flash.

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

---

## Architecture: Permission Protocol (as of 2026-03-17)

- **Marketing site** (permissionprotocol.com): Landing pages, public receipt viewer (`/r/[id]`), redirects to app for all auth flows.
- **App** (app.permissionprotocol.com): ALL authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail, enrichment pipeline.
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend.
- Review surface **fully consolidated to app** on 2026-03-16.

## Key Milestones

- **2026-03-17:** Xdares officially crossed **100 live blog posts** (101 total). 🚀
- **2026-03-17:** End-to-end Jake flow (PR → Review → Approve → Rerun → Merge) fully proven and reliable.

## Open Threads

- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] **Sarah user requirements** — needs same deep treatment as Marco.
- [ ] **Demo video for deploy-gate** — ready to record with Reliable Rerun flow.
- [ ] **Competitive response** — finalize positioning vs Chainguard/Vett.
- [ ] **Singapore Localization** — next phase of interlinking/optimization.

*Updated: 2026-03-17*
