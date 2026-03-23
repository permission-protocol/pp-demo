# Decision Log

Extracted from Discord threads by `/extract` and `/close-review` commands.
Linked to source threads for traceability.

## 2026-03-18 — Big Daddy (rc-main)
- Sonnet stays on control-room-2 with guardrails (circuit breaker + no thinking out loud)
- Force-push stale checks: set PP status on old SHA + re-request check suites (PR #195)
- `git add -A` banned in shared worktrees — always add specific files
- `git diff --stat` before pushing — verify file count matches intent
- Debugging circuit breaker: 5+ messages on same bug without fix → stop and escalate
- No "thinking out loud" in chat — do the work silently, post one message with result

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
- **Thread lifecycle:** ACTIVE → BLOCKED → PARKED/EXPIRED → ARCHIVED
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

## 2026-03-13 — Upgrade MacOs (thread: #rc-main › Upgrade MacOs)
- macOS Tahoe 26.3.1 chosen over Sonoma 14.8.4 patch — Peekaboo required macOS 15+
- Charles (MacBook) = visual/creative workstation (Peekaboo, demos, screenshots); Maria (droplet) = headless workhorse
- Workspace backup repo: Roca-Ventures/charles-workspace-backup (private)
- M1/8GB is fine for Tahoe; trim background processes if sluggish

## 2026-03-11 — Analytics Pipeline (Thread: #rc-product › Analytics)
- PostHog is the analytics platform (free tier: 1M events/mo, 5K recordings/mo)
- All custom events use `pp_` prefix for easy filtering
- UTM params stored in `sessionStorage` — clears on tab close (correct attribution behavior)
- Contact form alerts route to 📬 Inbound Leads thread in #rc-main via webhook `?thread_id=`
- Discord `thread_name` only works in forum channels — use `?thread_id=` query param for regular channels
- Vercel env vars: `DISCORD_CONTACT_WEBHOOK` + `DISCORD_CONTACT_THREAD_ID`
- PRD at `pp-os/specs/prd-analytics-pipeline.md`
- Issue 5 (PostHog funnels/dashboard) deferred — UI config, no code

## 2026-03-13 — Ideal Approval Screen (thread: #rc-product › Ideal Approval Screen)
- **Approval = trust decision, not code review.** Mobile approver answers "should this go live?" — AI summary + trust signals replace code reading.
- **Hold-to-confirm for production + high-risk**: 1-second press with progress indicator instead of confirmation modals.
- **5-second undo window on approve**: Optimistic UI, card disappears immediately.
- **Hybrid rerun strategy**: Try `check_run` rerequest first (lighter), fall back to `actions/runs` rerun.
- **Batch approve safety gate**: Only when ALL pending are low-risk + non-production.
- **Urgency-based sort** (not chronological): Production + high risk + oldest → top of queue.
- **blast_radius = AI-generated string**, not file path array.
- **AI prompt returns JSON**: `{"summary","blast_radius","dangerous_operations"}` via Gemini.
- **SHA-based enrichment caching**: Keyed by `repo#prNumber@headSha`.
- **Large diff fallback**: PRs with >500 files or >10000 lines skip AI, get deterministic summary.
- **Reconciliation is display-only**: Site can't write to PP DB; use sessionStorage for stale IDs.
- **Timeline built client-side**: From existing request data, no new API; updates on 15s poll.
- **Extract `triggerGitHubRerun` to shared lib** (`app/api/review/lib/rerun.ts`) for reuse.
- **Monthly "steal audit"**: Diff PP app vs site feature sets, file issues for gaps.
- **Process rules**: Never use `/tmp` for agent worktrees. Store prompts in workspace. Sequential agents for shared files. Pre-merge build gate (next build + layout.tsx check + push + no conflict markers).
- PRs: #175 (Phase 1), #178 (Phase 2), #180 (auto-rerun), #190 (superseded+rerun), #191 (timeline+reconcile) — all merged.
- Issues: #171-174 (4 phases), #181, #183-184 (closed), #194-196 (queue enhancements, backlog).

## 2026-03-13 — Fix Issues (thread: #rc-product › Fix Issues)
- Monitor Codex agents via `git status`/`git log`, NOT `process log` (PTY buffering makes process logs unreliable)
- Use persistent worktree directories (`~/Projects/worktrees/`), never `/tmp/` — OS cleanup wipes them
- Always check remote branches before re-launching agents — previous run may have auto-pushed
- Pre-flight batch Codex: verify package manager, check existing branches, use persistent dirs
- Codex auto-creates PRs sometimes — check remote before assuming failure
- One type-fix commit after Codex is fine — don't re-run whole agent for minor issues

## 2026-03-13 — iPhone Mirroring / Mobile QA Pipeline
**Thread:** #rc-main › iPhone Mirroring

1. **Safari WebDriver via USB > iPhone Mirroring for automation** — iPhone Mirroring blocks all synthetic input (clicks, drags, swipes) as a security boundary. WebDriver operates at the DOM layer, bypassing the entire display pipeline.
2. **Research before hack (15-minute rule)** — spent 2+ hours pixel-hacking before discovering WebDriver does it natively in 10 min. Wrong abstraction layer (pixel/screen) vs right one (DOM/WebDriver) = 10x time difference.
3. **Physical device checklist** — data cable (not charge-only), Trust This Computer, Web Inspector ON, Remote Automation ON, Guided Access ON, Auto-Lock Never.
4. **iPhone 14 Pro preferred over SE** — 6.1" screen (393×695 viewport, 3x DPR) more representative of real users than SE (375×495, 2x DPR).
5. **Gemini Flash for cron QA** — daily mobile audit at 9 AM MST costs ~$0.01/run. Same audit on Opus = 100x more.
6. **One-script-per-session for stateful drivers** — safaridriver dies between separate script invocations. Bundle all WebDriver commands into one continuous script.
7. **Demo video still needed** — deploy-gate e2e worked (PR #18 → gate blocked → approve → merge) but was never recorded. Separate task.

## 2026-03-16 — URL Consolidation: Marketing Vs App [UNIFY]
**Thread:** #rc-main › Marketing Vs App [UNIFY]

1. **All authenticated review/approve workflows consolidated to app.permissionprotocol.com** — marketing site no longer has any auth, review pages, or API proxy layer
2. **Marketing site = selling only** — landing, pricing, docs, blog, public receipts
3. **Receipt page (/r/[id]) stays on marketing** — public, unauthenticated, already canonical URL
4. **GitHub CI status check URLs point to app** — no more redirect hop through marketing
5. **next-auth removed from marketing site** — no auth dependency remaining
6. **5 permanent redirects** — /review, /review/:id, /login, /approve/:id, /replay/:id → app
7. **"Two surfaces for one thing = tech debt"** — enforced, 6,116 lines deleted

## 2026-03-17 — Claude Dependency / Cross-Provider Fallback
**Thread:** #rc-main › Claude Dependency (1483556834756530306)
- **All-Anthropic fallback is fake redundancy** — one auth profile cooldown cascades to all three models (opus-4-6, opus-4-5, sonnet-4-6)
- **Added google/gemini-3-flash-preview as 4th fallback** — cross-provider safety net
- **Keep Opus as primary** — quality justifies it; outages are rare enough
- **Config change applied via `config.patch`** — no manual file editing needed
- **LanceDB plugin broken** (`@lancedb/lancedb` not installed) — separate issue, memory_store/recall degraded but not blocking agent replies

## 2026-03-17 — Deploy Request Deduplication
**Source:** #rc-main › Push to main (1483223048499892425)
- PR merges reuse existing PR receipt via PR_HEAD scope passthrough (no duplicate deploy request)
- Direct pushes to main still create new deploy requests (safety net for unreviewed code)
- `verify/action.yml` gained `pr_number` + `pr_head_sha` inputs for explicit PR scope override
- Both merge commit and squash merge patterns handled
- **PR #174** merged 2026-03-16

## 2026-03-18 — PP Merge Loop Fix (bugs thread)

- **Authorization checks should never use strict mode.** PP approval is an authorization gate, not a code quality check — it doesn't go stale when main advances.
- **Two-ruleset pattern for all PP users.** Ruleset 1: PP status check, strict OFF. Ruleset 2: Build/test checks, strict ON.
- **Carry-forward must issue new signed receipts.** Old receipts fail signature verification against new scope hashes. The verify endpoint now auto-creates properly-signed receipts when a prior approval exists for the same PR.
- **This is a product footgun.** Every user who installs deploy-gate with strict ON will hit this. Docs updated to prevent it.

### 2026-03-19
- **Agent Roles:** Maria handles headless external operations (Telegram, public APIs). Charles handles local browser operations and auth-gated dashboards via 1Password, avoiding the need for Chrome Extension Relay. (Source: [Thread 1484231245125648606](https://discord.com/channels/1479269120334762008/1484231245125648606))
- **OpenClaw Plugins:** OpenClaw 2026.3.13+ requires explicit plugin installs for heavy dependencies like `memory-lancedb` and `diffs`.

### 2026-03-19
- **Where's Risk:** Placeholder comment must be posted immediately before enrichment, then updated with results or explicit failure state. (Source: [Thread 1484220042735517869](https://discord.com/channels/1479269120334762008/1484220042735517869))

## 2026-03-19
- **Popup window escape hatch:** When an app is opened in a chromeless popup window, `target="_blank"` links inherit the popup style instead of opening a proper tab. The fix is to programmatically create a detached `<a>` element, append it, click it, and remove it. [Source: Back to PR Button](https://discord.com/channels/1479269120334762008/1483894208656969850)

## 2026-03-19 — KOL
- Permission Protocol uses Discord webhooks for `/contact` leads, routing them to the #inbound-leads thread. KickoffLabs is only used for the Xdares waitlist.

### 2026-03-19
- **PP Msg Broken:** Gemini 3 Flash chain-of-thought (`<think>` blocks) breaks naive JSON parsing (`indexOf('{')`); explicitly strip tags before parsing. ([Thread](https://discord.com/channels/1479269120334762008/1484330892015960286))
- **PP Msg Broken:** Increase Gemini `maxOutputTokens` to 8192 to prevent payload + reasoning truncation. ([Thread](https://discord.com/channels/1479269120334762008/1484330892015960286))

### 2026-03-20 — [Tinder for PR (1483323537057120370)]
- Rebranded "Tinder for PRs" to **PullMatch** (pullmatch.com) across the codebase and GitHub org.
- Set default primary model for Charles to `google/gemini-3.1-pro-preview` at Rod's request (overriding SAFETY.md).
- Security Fix: API key validation and deploy request GET route now explicitly filter out archived companies to prevent ghost deploy requests from deleted companies.

## 2026-03-20 — Multi-Company Cookie Race (#opus-org-3)
- Company switch must set `activeCompanyId` cookie client-side via `document.cookie` before navigation, not rely solely on server `Set-Cookie` header
- `switchCompany()` navigates to `/c` instead of `window.location.reload()` to avoid cross-company resource access on detail pages
- Deploy requests from archived companies show "Archived Company" state — never offer "Switch to" for archived companies
- Detail page per-request isolation check is the safety net — list-level leak was read-only only
- Render deployment "success" status on GitHub doesn't guarantee an actual rebuild — always verify via CSS/JS bundle hash changes

### 2026-03-20 — [PullMatch (1484644007521812662)]
- Transitioning PullMatch from a Permission Protocol demo environment to a standalone product. Created dedicated workspace folder for it.

### 2026-03-20 — Opus GH PR Page (1484406326183596124)
- **Duplicate PR comments:** GitHub App webhook handler must own PR comments if active; GitHub Action `post-comment` must be disabled (`false`) to prevent race conditions and duplicate comments.
- **Next.js query params:** `useSearchParams()` does not react to native `window.history.replaceState()`. Must use `router.replace()` to clear query parameters and correctly update React state.
- **Token sizing:** Gemini `maxOutputTokens` should be sized appropriately to the expected JSON payload (e.g., 1024 or 512) rather than maxed out (8192), to avoid wasting token buffers and latency, even when using reasoning models.

## 2026-03-20 — Orgs 2 (Multi-Workspace GitHub App)
- **Source:** Discord thread #rc-main › Orgs 2
- Stateless GitHub App link route must read `activeCompanyId` cookie to target the correct workspace
- Allow installation transfer across workspaces when the user is a member of both (not a hard 409)
- GitHub App Setup URL must point to `/api/github-app/callback`, not deleted `/c/setup`
- `console.error` in callback state-parse → `console.warn` to avoid Next.js dev error overlay
- Step 3: one-click auto-setup (workflow + secret + ruleset) as primary path; manual instructions as fallback
- PP deploy gate correctly flagged dirty PR #215 — validates the product enforcement loop
- `git add .` in shared worktrees remains permanently banned (use `git add <specific files>`)

## 2026-03-21 — LinkedIn Outreach V2 Pivot (#rc-linkedin-automation)
- LinkedIn automation pivot: From selling infrastructure ("authorization receipts") to recruiting enterprise Design Partners / CAB members ("Tear our architecture apart").
- Replaced the 4 abstract pitch angles with a single `design_partner_critique` angle to qualify the market through ego + expertise.
- Updated `scan-signals.sh` to search for "MCP", "CISO", "agent security", prioritizing enterprise liability and security breaches over generic "AI agent" news.
- Target personas shifted to CISOs, VP Engineering, CTOs, and Head of AI Security at mid-market/enterprise SaaS companies.
## 2026-03-22 — Demo Videos
- Shift demo narrative to "deploy authority" to highlight value over scanning.
- Use Option A for HN Title: "Show HN: AI agents can’t deploy to production without a human signer"
- Delay HN launch to Tuesday 7:30–9:00am PST for optimal visibility.
### 2026-03-22
- **Enforcement is the wedge, not just audit/receipts.** (from thread [Atomic Loop](discord://-/channels/1479269120334762008/1485322840319197369))
- **Execution must depend only on a cryptographically verified token, never DB approval state.** (from thread [Atomic Loop](discord://-/channels/1479269120334762008/1485322840319197369))
- **Replay protection implemented via atomic Redis set with auto-TTL matching token expiry.** (from thread [Atomic Loop](discord://-/channels/1479269120334762008/1485322840319197369))
- **Policy layer enforces required signers, roles, multi-sig, conditions, and max TTL.** (from thread [Atomic Loop](discord://-/channels/1479269120334762008/1485322840319197369))
- **First real-world execution integration is GitHub Workflow dispatch (deploy_code).** (from thread [Atomic Loop](discord://-/channels/1479269120334762008/1485322840319197369))
