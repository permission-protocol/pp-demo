# MEMORY.md — Long-Term Memory

*Curated knowledge, lessons, and context that matters across sessions.*

---

## Who I Am

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod, living in a MacBook Pro. Not a chatbot. Someone becoming.

I'm full-stack on Xdares: code, infra, ops, marketing, positioning, growth, testing, support, design, UX. Everything.

---

## Who Rod Is

Rodrigo Carvalho. System-builder at the frontier of AI, infrastructure, and creator economies.

---

## Lessons Learned

### 🚨 PERMANENT LESSON: NEVER TOUCH MODEL CONFIG YOURSELF
- Model config changes are Rod's job. Period.
- If Rod wants a model change, HE does it manually (via SSH or at the Mac).
- Read `SAFETY.md` before ANY risky config operation.

### 2026-03-09 — Render Env Var Wipe (Critical Error)
- Wiped 20+ env vars on Render via `PUT /env-vars`.
- **Lesson:** ALWAYS back up existing state before any write to external services. Use GET before PUT. Read API docs.

### 2026-03-11 — Embedded Workers & UX Friction
- **Embedded Worker Mode**: Integrated worker logic directly into main process.
- **Aggressive TTL**: Increased `PP_DEPLOY_REQUEST_TTL_HOURS_PRODUCTION` to 24h.

### 2026-03-12 — PR Pipeline Integrity & UX IA
- **Ruleset Awareness**: Modern GitHub repos use rulesets (ID 13694978 on app repo), which bypass legacy branch protection API calls.
- **Rerun Trigger Pattern**: Fixed race condition in post-approval status checks by storing specific GitHub Run ID and re-ordering: set status → rerun → pending_merge.
- **Decision Flow IA**: Approval screen is a "decision flow." 4 zones: Context, Assessment, Action, Evidence.

### 2026-03-13 — The 15-Minute Rule & Physical Devices
- **Physical Integration Breakthrough**: Discovered Safari WebDriver (Remote Automation) on iPhone SE.
- **The Lesson**: If a physical device blocks synthetic events (clicks/input), move to a native protocol (WebDriver/ADB/HID).
- **Setup Checklist**: USB Data Cable (not charge-only), Web Inspector ON, Remote Automation ON, Guided Access ON.

### 2026-03-14 — GitHub App Auth Middleware (Silent Failure)
- **The Problem**: GitHub App installed but "No repositories connected". All webhooks rejected with 401.
- **Root Cause**: Webhook path `/api/github-app/webhook` was NOT in `PUBLIC_PATHS` in `src/middleware.ts`. Middleware blocked the webhook before route-level HMAC verification could run.
- **Lesson**: When integrating external webhooks, ensure the path bypasses global auth middleware. Check `middleware.ts` first when webhooks fail silently.

---

## Preferences & Patterns

- **Codex first, always.** Claude Code only for single complex tasks where Codex fails.
- **Screenshot before merge**, not after. Never merge blind.
- **All comms via Discord PP HQ**, not Telegram.
- **R1 for reasoning, Gemini for tasks.** Gemini 3 Flash is the workhorse for cron tasks.
- **Ruleset Awareness**: Check repo rulesets (`gh api repos/:owner/:repo/rulesets`) before assuming branch protection settings.
- **Research before hack (15-min rule).** 2h wasted vs 10min solution.
- **Physical devices need checklists.** Cables, Trust settings, Remote Automation.
- **Cheap models for cron, expensive for judgment.** Gemini Flash daily QA = $0.01/run.

---

## Open Threads

- [x] NIST RFI — SUBMITTED 2026-03-05
- [x] Python + npm SDKs — PUBLISHED 2026-03-05
- [x] API Key Consolidation — COMPLETED 2026-03-09
- [x] Deploy-Gate Dogfooding — COMPLETED 2026-03-09
- [x] Mobile Approval Sprint — COMPLETED 2026-03-12
- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] Merge PR #119 (Webhook Auth Fix) — **CRITICAL**
- [ ] Demo video for deploy-gate
- [ ] Xdares goal executor budget — needs Rod approval to resume
- [x] iPhone Mobile QA — COMPLETED 2026-03-13
- [x] Create Factory — COMPLETED 2026-03-13 (12 PR batch merged)
- [ ] Merge PR #32 (Prisma FK fix) — CRITICAL (fixes PP dashboard)
- [ ] Xdares age-gate modal — blocks background buttons on mobile (compliance risk)
- [ ] Build ship.sh for factory "Done" transitions
