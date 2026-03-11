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

### 2026-03-10 — Approval State & UX Patterns
- **Carry-forward Approvals**: Carry approval from a PR's old SHA to the new one (if scopeHash matches) to reduce re-approval friction.
- **Auto-Supersede**: When a new deploy request arrives for a PR, automatically mark the old one as superseded to reduce dashboard clutter.
- **Scope Separation**: Production-grade agents should use separate keys for `create` and `approve` scopes to prevent self-approval.

### 2026-03-09 — Gemini Migration & Speed
- Switched 13 cron jobs to `google/gemini-3-flash-preview` for massive cost/speed savings.
- Flash 3 is capable of tool use (20s vs 235s for hotline workflow).
- **Gemini Flash is faster/cheaper for routine agent tasks than Anthropic.**

### 2026-03-09 — End-to-End "Approve and Merge" Success
- Verified full flow: PR → Deploy Gate → Approval in PP UI → CI Pass → Merge from PP UI.

---

## Preferences & Patterns

- **Codex first, always.** Claude Code only for single complex tasks where Codex fails.
- **Screenshot before merge**, not after. Never merge blind.
- **All comms via Discord PP HQ**, not Telegram.
- **R1 for reasoning, Gemini for tasks.** Gemini 3 Flash is the workhorse for cron tasks; R1 for deep content/strategy analysis.

---

## Open Threads

- [x] NIST RFI — SUBMITTED 2026-03-05 (tracking mmd-wpnb-8bu4)
- [x] Python + npm SDKs — PUBLISHED 2026-03-05
- [x] API Key Consolidation — COMPLETED 2026-03-09
- [x] Deploy-Gate Dogfooding — COMPLETED 2026-03-09 (app + site)
- [x] Render Env Var Recovery — COMPLETED 2026-03-10
- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] Demo video for deploy-gate
- [ ] Xdares goal executor budget — needs Rod approval to resume

*Updated: 2026-03-10*
