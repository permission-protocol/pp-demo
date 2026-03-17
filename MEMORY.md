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

### 2026-03-14 — Cron Timeout ≠ Cron Failure
- `cron run` with short `timeoutMs` returns "gateway timeout" but the job still launches. Verify with a second `cron run` — if "already-running", it's fine.

### 2026-03-15 — Documentation Hygiene
- Maintain detailed records of fixes, updates, and decisions for consistency and clarity. (R1 Curation)

### 2026-03-15 — PR Factory: Batch Conflict Management
- **Conflict Cascades**: Merging many PRs (10+) into the same repo creates conflict cascades.
- **Lesson**: Merge in dependency order and rebase remaining branches after each merge to keep pipeline moving.
- **Factory Retries**: Blind retries without error context fail. Pipe actual `stderr` into the Codex retry prompt.

### 2026-03-16 — Factory JSONL Drift (14 Stale Ideas)
- **Problem**: 14 ideas stayed in `qa-passed`/`build-ready` after their PRs were merged. 3 ideas duplicated already-built features. Backlog looked 2x larger than reality.
- **Root Cause**: No feedback loop from GitHub merges → `ideas.jsonl`. Manual merges and factory merges both left JSONL untouched.
- **Fix**: Built `factory/scripts/reconcile.sh` — runs on every heartbeat, cross-refs merged PRs against JSONL, auto-marks done, flags stale items.
- **Lesson**: Every pipeline needs a reconciliation step. Source of truth drift is invisible until it causes cost or confusion.

### 2026-03-15 — Environment Visibility Fixes
- **Silent Config Bugs**: `pr-gate.yml` was targeting `staging` instead of `production` for months.
- **Lesson**: Adding UI environment badges (Wave 2 of audit) made the config bug visible. UX polish surfaces technical debt.

---

## Systems Built

### Create Factory (2026-03-13)
Autonomous product pipeline: ideate → organize → spec → build → qa.
- **Cron:** ideate+organize Mondays 6AM, build+qa weekdays 10AM
- **Spec stays manual** — quality gate, Charles writes PRDs
- **Stress tested:** 5/5 builds successful, avg 9m 25s, 12 PRs merged in one batch
- **Type-aware:** bugs get lightweight bugfix.md template, features get full PRD
- **Config:** `factory/config.json`, shared helpers in `discord-helper.sh`
- **Discord:** #factory-control, #factory-pipeline, #factory-wip, #factory-done

### iPhone Mobile QA (2026-03-13)
Safari WebDriver via USB cable — full DOM control (click, type, JS, screenshot).
- **Script:** `scripts/iphone-qa.sh`, daily cron via Gemini Flash
- **Wired into factory qa.sh** — non-blocking, disabled by default (`mobile_qa_enabled: false`)
- **Flip to true** after 5 clean daily cron runs

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
- **JSONL hygiene:** Always `jq -c` (compact), never pretty-print. Spaces after colons break grep patterns.
- **Batch Codex:** Use `~/Projects/worktrees/` not `/tmp`. Poll git status, not process logs. Check remote branches before re-launching.

---

## Architecture: Permission Protocol (as of 2026-03-16)

- **Marketing site** (permissionprotocol.com): Landing pages, public receipt viewer (`/r/[id]`), redirects to app for all auth flows
- **App** (app.permissionprotocol.com): ALL authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail, enrichment pipeline
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend
- Review surface **fully consolidated to app** on 2026-03-16 (6,116 lines removed from site repo, 301 redirects added)

## Key Milestones

- **2026-03-09 (or before):** NIST RFI submitted by Rod before deadline. PP is on record with federal AI agent authorization standards. 🎯

## Open Threads

- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] **Sarah user requirements** — needs same deep treatment as Marco
- [ ] Fix Prisma FK bug (idea-032) — **CRITICAL** (deploy request creation broken)
- [ ] Create 60-second demo video for deploy-gate
- [ ] Create design partner quick-start guide
- [ ] Draft and send 5 personalized outreach messages
- [ ] Build ship.sh for factory "Done" transitions
- [ ] Enable mobile QA in factory config (after 5 clean cron runs)
- [x] ~~Xdares goal executor budget~~ — approved Mar 17, re-enabled
- [ ] McKinsey Lilli breach — content opportunity (alert sent 2026-03-15)

*Updated: 2026-03-16*
col.com): Landing pages, public receipt viewer (`/r/[id]`), redirects to app for all auth flows
- **App** (app.permissionprotocol.com): ALL authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail, enrichment pipeline
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend
- Review surface **fully consolidated to app** on 2026-03-16 (6,116 lines removed from site repo, 301 redirects added)

## Open Threads

- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] **Marco user requirements DONE** — `pp-os/specs/marco-user-requirements.md` (29 reqs, 5 sprints)
- [ ] **Sarah user requirements** — needs same deep treatment as Marco
- [ ] **Sprint 1 implementation specs** — break Marco M1-M6 into buildable tickets
- [ ] Fix Prisma FK bug (idea-032) — **CRITICAL** (deploy request creation broken)
- [ ] Demo video for deploy-gate
- [ ] Build ship.sh for factory "Done" transitions
- [ ] Enable mobile QA in factory config (after 5 clean cron runs)
- [ ] Xdares goal executor budget — needs Rod approval to resume
- [ ] McKinsey Lilli breach — content opportunity (alert sent 2026-03-15)

*Updated: 2026-03-16*
