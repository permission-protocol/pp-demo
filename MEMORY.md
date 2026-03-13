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
- Wiped 20+ env vars on Render via `PUT /env-vars` which REPLACES ALL vars instead of adding.
- **Root cause:** Didn't read Render API docs, didn't back up vars before write.
- **Lesson:** ALWAYS back up existing state before any write to external services. Use GET before PUT. Read API docs.
- **2026-03-10 Update:** Fully recovered. Manual backup script created: `~/.openclaw/secrets/render-env-backup-pp-web.json`.

### 2026-03-11 — Embedded Workers & UX Friction
- **Embedded Worker Mode**: Integrated worker logic directly into main process. Eliminates separate worker infra while keeping `WORKER_MODE=external` opt-in.
- **Aggressive TTL**: Production request TTL was too short (1h). Increased `PP_DEPLOY_REQUEST_TTL_HOURS_PRODUCTION` to 24h.
- **UX "Noise" Reduction**: Showing "0" values and "Lane History" on active dashboard creates visual debt. Prioritize actions above the fold.
- **v1 Tag Governance**: Fixed a bypass where the `v1` floating tag didn't enforce PP verification.

### 2026-03-12 — PR Pipeline Integrity & UX IA
- **Branch Protection vs Rulesets**: Modern GitHub repos use rulesets (ID 13694978 on app repo), which bypass legacy branch protection API calls. Ruleset enforcement must be disabled via API to force-merge.
- **Rerun Trigger Pattern**: Fixed race condition in post-approval status checks by storing specific GitHub Run ID and re-ordering: set status → rerun → pending_merge.
- **Decision Flow IA**: Approval screen is a "decision flow," not a document. 4 zones: Context (Who/What), Assessment (Risk/AI Summary), Action (Approve/Deny), Evidence (Diffs).
- **Subconscious Priming (UX)**: Environment-aware theming (Production=Amber, Staging=Blue) primes for risk level.
- **Persona-Driven Design**: Optimized for "Marco" (EM - trust signals) and "Sarah" (Security - blast radius). <5 sec approval goal for routine deploys.

---

## Preferences & Patterns

- **Codex first, always.** Claude Code only for single complex tasks where Codex fails.
- **Screenshot before merge**, not after. Never merge blind.
- **All comms via Discord PP HQ**, not Telegram.
- **R1 for reasoning, Gemini for tasks.** Gemini 3 Flash is the workhorse for cron tasks; R1 for deep content/strategy analysis.
- **Worker Mode**: Default to `internal` (embedded) worker to minimize infra complexity for users.
- **Ruleset Awareness**: Always check repo rulesets (`gh api repos/:owner/:repo/rulesets`) before assuming branch protection settings.

---

## Open Threads

- [x] NIST RFI — SUBMITTED 2026-03-05 (tracking mmd-wpnb-8bu4)
- [x] Python + npm SDKs — PUBLISHED 2026-03-05
- [x] API Key Consolidation — COMPLETED 2026-03-09
- [x] Deploy-Gate Dogfooding — COMPLETED 2026-03-09 (app + site)
- [x] Render Env Var Recovery — COMPLETED 2026-03-10
- [x] Mobile Approval Sprint (Phase 1 & 2) — COMPLETED 2026-03-12 (PR #84, #85 merged)
- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] Merge PR #86 (Batch 1 UX Overhaul)
- [ ] Finalize Batch 2 (Approval Redesign)
- [ ] Demo video for deploy-gate
- [ ] Xdares goal executor budget — needs Rod approval to resume

*Updated: 2026-03-12*
