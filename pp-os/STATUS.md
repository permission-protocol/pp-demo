# PP Status — Last Updated: 2026-03-07 23:00 MST

## 🎯 28-DAY FOCUS (Mar 8 → Apr 4)
**Single wedge: AI coding agents (Codex, Cursor, Claude Code) deploying code without Permission Protocol**
- Success = 5+ external users with deploy-gate installed, 1+ completing full flow
- Everything else is paused. FOCUS.md is the filter.

## Active Right Now
- **Review Surface**: Live at permissionprotocol.com/review/{id} + dashboard at /review
  - Auth: GitHub OAuth, multi-tenant (PR #138). `/review/*` protected, `/login` live.
  - PR title as heading, AI summary, risk badges, expandable diff
- **Subscribe webhook**: Live on #subscribers via Discord webhook
- **Content Pipeline**: Gemini Thinking + GPT 5.4 combo. CONTENT-PLAYBOOK.md v3 + DOCTRINE-LIBRARY.md built.
- **Daily OS crons**: pp-os-daily-log-and-plan, pp-os-execute-ready, pp-os-weekly-review (active)

## Paused (Focus Sprint)
- Scout pipeline (13 crons off): scout-response-monitor, scout-delivery, scout-followup, scout-outreach-draft, scout-research, scout-active-learning, scout-campaign-monitor
- Marketing pipeline: marketing-publisher, marketing-engagement-monitor, marketing-content-draft, marketing-active-learning, unified-engagement

## Pending
- [ ] Demo video for deploy-gate
- [ ] Dogfood deploy-gate on PP + Xdares repos
- [ ] Find 10 potential users, get 3 to try (Week 2)
- [ ] MS-Agent RCE LinkedIn post — awaiting Rod ✅/🔄/❌
- [ ] Vercel deploy webhook → #rc-alerts (waiting on Rod for webhook URL or bot permission)
- [ ] Rod: delete API key messages from #rod-actions (OpenAI + 2 Gemini keys visible)
- [ ] Fix Gemini content API key (free tier, quota 0) — enable pay-as-you-go if needed
- [ ] hn-resubmit-cursor — one-shot Sunday Mar 8

## Recent Decisions
- **THE FOCUS DECISION (Mar 7):** 28-day sprint, AI coding agent deploy-gate only. Everything else secondary.
- All comms via Discord PP HQ, not Telegram
- Exec config: `security=full`, `ask=off`
- Image gen: Gemini Flash (not Imagen 4.0)
- Content pipeline: Models DIAGNOSE, not REWRITE. Gemini Thinking + GPT 5.4 = optimal combo.
- NextAuth.js v4 (JWT, no DB) for Review Surface auth. `TENANT_MAP` env var for org → tenant.

## Blockers
- (none)
