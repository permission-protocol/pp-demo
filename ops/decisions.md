# Decision Log

Extracted from Discord threads by `/extract` and `/close-review` commands.
Linked to source threads for traceability.

## 2026-03-11 — Render Deploy Speed II (#rc-product › Render Deploy Speed)
- PP verification removed from Render pre-deploy script — receipts use PR head SHA but Render deploys merge commit SHA (always mismatches)
- PP enforcement is solely in `production-deploy.yml` GitHub workflow — single gate point
- Pre-deploy script (`scripts/pre-deploy-gate.sh`) now only runs `prisma migrate deploy`
- Auto-deploy must stay **off** — deploys only via GitHub workflow or manual dashboard trigger
- Build command must include standalone static asset copy (`cp -r public .next/standalone/public && cp -r .next/static .next/standalone/.next/static`)
- Emergency bypass for chicken-and-egg (app down → can't approve → can't deploy): temporarily change pre-deploy command in Render dashboard to `npx prisma migrate deploy`, manual deploy, then restore
- PRs: #59 (trim redundant Prisma calls), #62 (remove PP verify from pre-deploy)

## 2026-03-11 — Render Deploy Speed (#rc-product › Render Deploy Speed)
- Render Professional tier doesn't affect build/deploy speed — instance type does
- Next.js `output: 'standalone'` requires post-build copy of `public/` and `.next/static/`
- All API routes should export `force-dynamic` (they all use headers)
- Prisma schema setup should run once (postinstall), not 3× during build
- Sentry webpack wrapper removed — runtime SDK still works, only build instrumentation dropped
- Standalone start command: `node .next/standalone/server.js` (not `npm run start`)

## 2026-03-09 — Cleanup API Keys (rc-product)
- One deploy-gate key for all PP infra (receipts.verify + deployRequests.create scopes)
- Render uses 3 env var names but all point to same key
- Local secrets consolidated to pp-api-key.txt + pp-tenant-id.txt only
- PP_REQUEST_CREATE_TOKEN was missing on permission-protocol/app — caught and fixed during cleanup

---

## 2026-03-08 — Discord Structure (#rc-product › Discord Structure)

- **Channels are streams, threads are topics.** Permanent channels for always-on feeds. Threads for finite work with a lifecycle.
- **8 permanent channels:** rc-main, rc-product, rc-alerts, rod-actions, published, daily-log, cron-status, charles-log
- **Special channels:** archive-log (receipts), r1-chat (R1 bot)
- **Archive category (📦)** for dead, paused, and completed channels
- **rod-actions stays standalone** — react-based queue works as a stream
- **published stays standalone** — automated log, not a discussion
- **decisions channel → archived**, replaced by this file (ops/decisions.md)
- **Thread auto-archive: 24h** — Discord shows active threads in sidebar regardless
- **`/topic` defaults to current channel** — no friction
- **Git-backed YAML state tracking** (ops/threads.yaml), no database
- **Thread lifecycle:** ACTIVE → WAITING → BLOCKED → READY_TO_ARCHIVE → ARCHIVED
- **Archive gate:** question resolved + decisions captured + tasks extracted + memory saved + no orphaned work
- **Commands:** /help, /topic, /triage, /extract, /close-review, /archive, /promote, /reopen

## 2026-03-09 — Website Messaging (Thread: #rc-main › Website Messaging)

- **Hero headline:** "Who authorized that AI action?" chosen over "AI agents shouldn't authorize their own actions." Question form plants the problem; PP is the answer.
- **Subheadline:** "Every consequential AI action needs a receipt. Permission Protocol issues it." — concrete over abstract.
- **Primary CTA:** "See the receipt" → /r/demo. Curiosity-driven, not work-implied. "Get Started" implies effort; "See the receipt" implies a reveal.
- **Page flow:** Problem → How it works → Social proof (was Problem → Social proof → How it works). Tighter narrative arc.
- **Comparison section:** "What happens when an AI agent deploys without you?" over "Add separation of powers to your AI systems." Concrete > metaphorical.
- **General principle:** Keep messaging agent-agnostic even during deploy-gate focus sprint.
- **PR:** #147 on permissionprotocol-site

## 2026-03-09 — PP API Scope Bug (Thread: #rc-product › PP API Scope Bug)

- **Scope selector should be checkboxes, not single-select dropdown.** The `<select>` with hardcoded combos prevented users from picking individual scopes.
- **Active PP app repo is `permission-protocol/app`**, NOT `Roca-Ventures/Breakout-Labs`. Forked March 7, 2026.
- **`receipts.verify` scope is sufficient** when `X-PP-Request-Create-Token` header provides trust for request auto-creation — `deployRequests.create` scope not needed on the key itself.
- **PR:** #3 on permission-protocol/app

## 2026-03-09 — Reconcile (Thread: #rc-product › Reconcile)

- **Discord-archive threads on `/archive`** — set `archived: true`, `locked: true`, prefix with `✅`. Threads vanish from sidebar; findable via "Browse Archived Threads."
- **`/archive` stores decisions/facts to `memory_store`** — ensures cross-thread context propagation without file reads. All future sessions get archived knowledge via `<relevant-memories>`.
- **Bot granted MANAGE_THREADS permission** — can archive any thread, not just self-owned.
- **Secret hygiene: save locally first, distribute second.** Write to `~/.openclaw/secrets/` before setting on GitHub/Render/services. GitHub secrets can't be read back.

## 2026-03-09 — Repo Consolidation (Thread: #rc-product › repos)
- **All PP repos consolidated into `permission-protocol` org.** No more Breakout-Labs or Roca-Ventures for PP.
- Canonical repos: app (backend), site (Vercel), deploy-gate (Action), pp-demo (template), python-sdk (PyPI), docs (spec/playbooks), brand-components (React lib)
- `site` + `brand-components` = private. `docs`, `deploy-gate`, `pp-demo`, `python-sdk` = public.
- `reference` renamed to `docs`, README updated
- Breakout-Labs frozen with `company-os-snapshot-2026-03-07` tag
- All scripts updated from `Roca-Ventures/Breakout-Labs` → `permission-protocol/app`
- New PP Product board at `permission-protocol/projects/1` (replaces Roca-Ventures board)
- Roca-Ventures org: only Xdares + charles remain active

### 2026-03-09 — Page after login (rc-product)
- Post-login default is `/pp` (deploy queue dashboard), not `/onboarding`
- Company OS onboarding wizard fully removed from codebase (843 lines deleted)
- `/onboarding` redirects to `/pp/setup` for stale links
- PR #12 on permission-protocol/app

### 2026-03-11 — Branch protection on permission-protocol/app
**Source:** #rc-product › Merged Out of date
- Added branch protection to `permission-protocol/app` main: required check "Permission Protocol", `strict: true`, admin bypass allowed
- Triggered by PR #47 race condition (update branch + PP merge clicked simultaneously, merge went through before CI finished)
- Now matches `permissionprotocol-site` protection config
