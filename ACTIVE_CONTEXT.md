# ACTIVE_CONTEXT.md — What Matters Right Now

*Updated: 2026-04-08 3:34 PM MDT. Overwrite this file, don't append.*

## Pushing Now
- **Consequence Engine SHIPPED.** All 5 sprint days compressed into 1 day. PRs #315-#319 merged and deployed.
- **Artifacts LOCKED.** 3 screenshot-ready artifacts produced on `demo-repository` (#12, #6, #8/9).
- **Rod recording Loom demo** now. Script provided in #wedges. 60 seconds, no narration fluff.
- **OUTREACH DROUGHT: Day 47.** Critical. 2 hot drafts (Sycamore, Trent AI) pending Rod approval.

## Architecture (Locked)
- **Outcomes:** cleared | approval_required | denied
- **Receipt types:** clearance | authorization | execution
- **Trust boundary:** LLM writes brief, deterministic rules decide gate
- **Denied = hard stop.** No authorize button. Fix code, push again.
- **Comment quieting:** Per-repo, first 5 cleared PRs, then silent.

## Demo Repo
- `permission-protocol/demo-repository` (Public) — All 3 artifact types now live on one repo.
- Cleared (#12), Approval Required (#6), Denied (#8, #9).
- Ready for unified demo recording.

## Rod Actions Required
1. **Record Loom** using provided script on `demo-repository`
2. **Review homepage copy** (`feat/consequence-engine-site` branch)
3. **Approve outreach** — Sycamore, Trent AI, warm leads (Day 47 drought)

## Charles Queue
1. Deploy site branch with real screenshots after Rod approves homepage
2. Send outreach after Loom + screenshots locked
3. Fix enrichment timeout on large repos (app repo Gemini failures)
4. Remove legacy deploy-gate workflows from demo repos

## Key Files
- `pp-os/plans/consequence-engine-sprint.md` — sprint plan
- `pp-os/outreach/consequence-engine-templates.md` — 5 new templates
- `pp-os/plans/consequence-engine-gold-standard.md` — 30-fixture test set

## Optimize For
- Loom → Homepage → Outreach. That sequence. Don't skip steps.
