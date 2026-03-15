# PP Status — Last updated 2026-03-14 23:00 MDT

## Active
- **GitHub App E2E Flow (PR #119)** — Webhook 401 & Callback repo-fetch fixes. This is the blocker for the entire PP product loop.
- **Factory Verification** — Batch 1 (12 PRs) merged. Monitoring `ship.sh` development for automated PR cleanup.
- **Mobile Review UX** — Phase 2 live. Final mobile age-gate fix for Xdares pending.

## Pending
- **Merge PR #119** (webhook + callback fix) ← **HIGH PRIORITY**.
- Merge PR #115 (hide unfixable errors) & PR #117 (actionable error messages).
- Redeliver GitHub App webhooks after PR #119 merge to register repos.
- Merge PR #32 (Prisma FK fix) + test full PP flow on phone.
- Build `ship.sh` for "Done" transitions and PR cleanup.
- Demo video → GTM distribution.

## Recent Decisions
- **GitHub App Auth**: Add webhook path to PUBLIC_PATHS in middleware to prevent silent 401s.
- **Callback Pattern**: Installation Access Token is required to fetch repos, not the App JWT.
- **Factory Strategy**: Ideate/Organize via cron, Spec interactive, Build/QA via cron.

## Blockers
- **GitHub App Connection**: Repos won't show on dashboard until PR #119 is live and webhooks are redelivered.
- **Prisma FK Bug**: Blocks all PP dashboard approvals (PR #32).
- **Deploy Gate URL**: Needs PR #20 merged to fix redirect routing.
