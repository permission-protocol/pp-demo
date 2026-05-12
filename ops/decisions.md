# Decision Log

Extracted from Discord threads by `/extract` and `/close-review` commands.
Linked to source threads for traceability.

## 2026-05-08 — OpenClaw Meta: Thread Lifecycle & Context (#openclaw)
- Model overrides in OpenClaw are runtime-only — not persisted when a session ends or restarts; reverting to default on next session is expected behavior
- `/extract` is the correct command before leaving an active thread overnight — writes state to ops/threads.yaml and ops/decisions.md; `/triage` is pulse-check only and does not persist anything
- `/archive` handles full context persistence for closed threads (MEMORY.md, daily notes, memory_store, decisions.md)
- Thread naming in Discord is inconsistent — a convention like `[type] topic` would improve navigation of rc-main sidebar
- rc-main is a thread graveyard; per-domain channels would reduce clutter
- Per-thread model preferences are not yet a native OpenClaw feature; workaround is to re-apply model override at session start

## 2026-05-08 — Scout Alerts Signal Scanner (#scout-alers)
- Signal scan runs 1-3x daily (5:06am + 8am MDT crons), weekends skipped
- Relevance thresholds: ≥4/8 posts to #scout-alerts, ≥6/8 triggers automated outreach draft generation
- Signals logged to pp-os/marketing/signals/YYYY-MM-DD.jsonl daily; hot signals to pp-os/marketing/HOT-SIGNAL.md
- Bot drafts Reddit/HN comments in "builder" voice for Rod — no evidence any have been posted to HN/Reddit
- Scanner focus keywords: AI coding agent deploys, agent security, agent governance, MCP
- Two separate scanner implementations exist (unified-signal-scan cron + scan-signals.sh shell script) — occasionally produce overlapping/conflicting results same day
- Cron has failed silently at least twice (Apr 20 edit failure, Apr 30 agent failure) with no escalation mechanism
- Brave API rate limits (429) are a recurring issue, losing web search coverage on ~30% of scans
- Scanner correctly identifies high-value narrative hooks and outreach targets (Blitzy, Optio, G0, Cursor incidents) but no signal-to-action pipeline exists
- Weekend skip = ~28% of days have zero signal coverage

## 2026-05-08 — DeepSeek Test: Strategy Sprint + Overnight Build (#deepseek-test)
- SQL wedge over Finance wedge — demo-ready now vs months of integration work for Finance
- Wedge/narrative separation: SQL demos the gate; Deploy Gate is the platform story
- 30-day falsification criteria: 3+ "just PR review" objections + zero installs = pivot to IaC
- 20-target outreach list researched, validated, and saved to github.com/permission-protocol/outreach (private)
- Email corrections: Scott Kennedy → scott@replit.com; James Cowling → james@convex.dev; Pete Hunt → pete@elementl.com
- JD Trask may have moved to Autohive — verify before outreach

## 2026-05-08 — Debug 4: Landing Page Audit & GTM Wedge (#debug-4)
- Deploy Gate leads the landing page narrative; SQL is the first proof, not the first wedge
- Finance/authority expansion narrative: "Today it's production code. Next it's spend."
- Hero should claim "blocks before merge" not "intercepts before execution" (overclaims runtime interception)
- "Cryptographic receipts" belongs below the fold — hero chips should say "Signed receipts"
- Demo caption: "destructive migration → blocked → signed → receipt" not "SQL injection" (SQL injection is AppSec framing)
- Page is GTM-ready at 8.5/10; 4 minor copy edits deferred as non-blocking for first outreach

## 2026-05-08 — Wedge Opus 4.7 (#wedge-opus-4-7)
- SQL wedge as first mover, deploy gate as engine, merge-path as expansion story (Stripe "7 lines of code" playbook)
- Product category stays constant (authority layer for agentic software delivery); only the wedge demo rotates
- Wave-based outreach: 3 first, score replies Day 5-7, then 7 more — never blast all at once
- LinkedIn first, email if no acceptance in ~1 week
- Personalized opener per company (Mercury: Haskell/SQL blog; Gusto: AI eng hiring now; Datavant: HIPAA tokenization)
- Loom > calendar link as primary cold CTA (lower friction, self-serve before committing time)
- Follow-up rule — Day 4-7 if no reply: "Did this get buried? Loom is 90 seconds, still curious."
- Scoring: 2+ substantive replies = scale; 0 replies after follow-up = rewrite before scaling
- De-dupe AppSec Primary (26) + Platform Primary (32) lists before Wave 2 (overlaps: Jeevan Singh, Branden Wagner, Lee Laslo)
- LinkedIn invites sent May 8: Ashwin Baskaran/Mercury, Trevor Snow/Gusto, Jim Oberholz/Datavant
- 3 site fixes deferred/unconfirmed: empty SHA-256 on /r/demo, SQL receipt mismatch on /r/demo, founder CTA (/contact?src=receipt-demo)

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

## 2026-03-23 — JAKE (rc-main)
- Verdict-first PR comment format: answer "safe to merge?" before explaining what changed
- Three-tier graduated friction: zero friction for safe, yellow "Review & Authorize" for review, red "View Full Report" + checkbox for block
- "Approve Anyway" (amber button) instead of "Approve" (green) when overriding AI block verdict
- Receipt audit trail records conscious overrides: "Approved despite AI block verdict"
- No governance language on the review surface — "Signer of Record" moved to receipt page only
- Gemini Chain-of-Thought tokens count against maxOutputTokens — always set high (8192+)
- `<think>` tags must be stripped from Gemini responses before JSON extraction
- Prompt stress testing (5 runs × 7 scenarios minimum) before shipping AI-generated UI content

## 2026-03-23
- **Hover Menus:** Hover menus need continuous pointer zones (padding vs margin) to stay open during mouse travel. ([Polish Items](https://discord.com/channels/1479269120334762008/1485631505345548318))
- **Support Routing:** No mailto: links for support; route all through /contact for PostHog tracking and Discord alerting. ([Polish Items](https://discord.com/channels/1479269120334762008/1485631505345548318))
- 2026-03-24 (Open issues): Cleared 8 stale UI/UX issues from Feb/early March to clear the queue for the MCP Guard sprint.
- 2026-03-24 (Open issues): Clarified architectural sequencing: Enforcement (verifier/lock) is the prerequisite; workflow wrapper (app#233) follows.

## 2026-03-24 — Scrolling (#scrolling)
- Smooth scrolling (`scroll-behavior: smooth`) combined with anchor links can intercept the first wheel event and cause a "double scroll" lag; avoid them on full-height hero sections.
- Margin-based viewport detection (`margin: "100px"`) is more reliable than percentage (`amount: 0.05`) for Framer Motion entrance animations.

## 2026-03-24 — Demo Gif (thread: #rc-main › Demo Gif)
- **pp-demo is the canonical demo repo** — no duplicate demo repos
- **reset-demo.sh** produces a clean, single-PR recording state with one failing check
- **Bot comment search** uses `'Permission Protocol'` (no emoji prefix) for encoding resilience
- **Two browser profiles** recommended for recording (GitHub viewer + PP Dashboard signer)
- **Emoji encoding bug** — `\uD83D\uDD12` stored as raw text broke `.includes('🔒')` matching; fixed in app PR #244

## 2026-03-23 — Full Flow 2 - Opus (#full-flow-2-opus)
- Time-to-first-approval is the core conversion metric, not install count.
- Demo PR should always stay open as a live playground (pp-demo#23).
- Animations must enhance, not gate visibility (`initial opacity: 0` → `0.85`).
- `?action=approve` should auto-open the confirmation modal to reduce friction.
- Post-approval screen must show the cryptographic receipt — that's the moat.

## 2026-03-24 — Opus - Launch (Archived)
- **Launch URL:** `github.com/permission-protocol/deploy-gate` (public repo, not private app repo)
- **HN title:** "Show HN: We built a system where AI agents can't deploy without a human signer"
- **One secret setup:** `PP_API_KEY` only — `PP_BASE_URL` defaults in the action
- **Tamper detection:** `verify()` re-canonicalizes receipt fields and compares against stored signed bytes. Any post-signing field mutation fails verification.
- **Dogfooding:** All launch PRs (#239, #240, #241) merged through PP's own deploy gate
- **README structure for HN:** Hook first ("AI tried to deploy. It got blocked."), install second, docs last. Risk framing > feature list.

## 2026-03-24 — Quick bugs (hn-launch)
- Auto-select company via CustomEvent dispatch pattern when landing on a review page with mismatched active company
- PWA install (manifest.json + InstallPrompt) belongs on app.permissionprotocol.com only, not the marketing site
- Hero headline uses explicit `<br />` for the Three Questions format to prevent mid-question wraps
- Fake metrics (12,400+ receipts, 99.97% SLA) replaced with provable facts (Ed25519, MIT license)
- "Request Access" renamed to "Contact" across nav, footer, and pricing — product is live
- Vercel requires Git author to have project access, not just team membership

## 2026-03-29 — See-Try-Pay Framework (Thread: #rc-main › See Try Pay)

### Strategic Decisions
1. **Activation over monetization** — The bottleneck is getting users to experience the "blocked deploy" moment, not collecting payment.
2. **Pricing is positioning, not conversion** — The approval page is the conversion surface. Pricing page upgrades perception from "tool" to "authority layer."
3. **KPI: `approval → second repo installed`** — 1st install = curiosity, 2nd install = belief. Conversations can lie; installs don't.

### Copy Principles
4. **Copy + urgency > features** — The difference between "this is cool" and "we need this this week" is copy, not more features.
5. **Consequence over abstraction** — "would have gone to production" beats "would have been blocked."
6. **Personal ownership pressure** — "this happens" → "this will happen to YOU" ("The only question is whether it happens on your system").
7. **The bar** — "It would be irresponsible NOT to install this."

### Pricing Structure
8. **$300/mo per organization** — Anchors seriousness, leaves room to expand to $1k-5k.
9. **"Request Access" forces conversation** — Quality > volume at this stage.
10. **No usage-based pricing** — You pay for control, not API calls.

### April 7-8 addendum (outreach execution + demo)

11. **7 LinkedIn outreach messages sent** April 7: Scott Wu (Cognition), Michael Truell (Cursor), João Moura (crewAI), Harrison Chase (LangChain), Jake Cooper (Railway), Matt Aitken (Trigger.dev), Ryan Delgado (Ramp).
12. **Demo video published:** https://youtu.be/HiREyLu5ZZY — 60-sec block→approve→receipt flow. Title/end cards on-brand.
13. **3-layer selling framework:** (1) Gate — unsigned actions rejected. (2) Intelligence — AI-summarized context for fast approval. (3) Proof — cryptographic receipt. Lead 1+2 for technical founders, 1+3 for regulated buyers.
14. **GitHub PR comment = Markdown only.** No HTML/CSS. Use as teaser → link to PP review page for full experience.
15. **Enrichment architecture:** Gemini Flash, runs once per PR, stored in DB, shared across surfaces. Max 10 files, 8K chars total diff.

- **2026-04-06 (QA)**: Use installed Google Chrome (`channel: 'chrome'`) + `--disable-blink-features=AutomationControlled` to bypass Google bot detection during Playwright auth. Persist state to `.auth/chrome_profile`. Target `permission-protocol/pp-demo` for E2E testing to ensure the gate workflow exists.

## 2026-04-08 — Onboarding Flow QA (rc-main)
- Activation = blocked action -> signer decision -> receipt (not just App installation).
- State machine locked steps must be resumable to self-heal.
- GitHub App installation callbacks require exponential backoff when querying repos due to internal propagation delays.
- Legacy auto-setup requiring administration:write is permanently deprecated in favor of scoped contents:write and workflows:write.

## 2026-04-08 — Consequence Engine Architecture (from #Wedges)
- PP = consequence brief → policy decision → human authorization event
- Outcomes: cleared | approval_required | denied
- Receipt types: clearance | authorization | execution
- Trust boundary: LLM writes brief, deterministic rules decide gate
- Denied = hard stop, no authorize CTA
- Per-repo comment quieting, not per-installation
- Block merge from day one, only on consequential PRs
- Single entry point: github.com/apps/permission-protocol/installations/select_target
- Comment design v2: blockquotes, tables, details, authority language ("Human authorization required", "Decision: blocked by policy")

## 2026-04-10 — Polish V3 Sprint (Thread: #rc-main › Polish V3)
- **DESIGN.md is now enforced, not aspirational.** All 9 audit items from the original assessment are implemented and deployed.
- **Parallel Codex agents with git worktrees** is the validated batch execution pattern: 3 agents at a time, separate worktrees at ~/pp-agent-work/, sequential merge with rebase.
- **Force-push rebases cause superseded deploy requests.** Added escape route (PR #348) — "Open newer request" + "Go to Dashboard" links.
- **Surface tokens aligned:** Background #131313 (obsidian), cards #1C1B1B, elevated #353534. accent-blue renamed to accent-primary globally.
- **Sign-in UX:** Grid overlay, Space Grotesk, glassmorphism card. Error states handled for AccessDenied, CallbackRouteError, Configuration. Auth error page has "Try again" + "Back to home" links. NextAuth's built-in open redirect protection is in place (no custom redirect callback).

## 2026-04-30 — Musk (Sprint 6 Outreach Execution) (Thread: #rc-main › Musk)
- **Em-dash hard rule:** Never use em dashes (—) in external marketing copy or outbound messages. Use commas, periods, or colons instead.
- **Voice Mode A vs Mode B:** Authority voice ("I'm the founder of") for VC/brand outreach; Learning voice ("I'm building") for first-user activation DMs.
- **"I'm building" > "I'm the founder" for activation outreach:** Smaller ask, learning mode framing, ~3-5x higher reply rate per YC research.
- **Signature format:** Minimal (name + link only) for activation outreach. Strip "Founder | Company" taglines.
- **Personal X account for DMs:** Messages land in Primary inbox, not Requests. Higher visibility.
- **X bio must match outreach context:** Update bio before sending X DMs — recipients click the profile.
- **Email bounce recovery:** Retry bounced emails as X DMs when the target is X-native.
- **First message's job is the reply, not the install:** Optimize for response rate, not conversion in cold message #1.

## 2026-05-04 — Charles Logs (#rc-main › Charles Logs)
- Thread model set to `openai-codex/gpt-5.5` / `gpt55` for the log-cleanup investigation.
- OpenClaw self-updates require explicit Rod approval; `Daily Auto-Update` cron was disabled.
- Do not hand-edit durable task DB blindly; use supported maintenance/restart paths or upstream fixes for stale task records.
- Removed only the OpenClaw `gstack` symlink from the skills scan path; original `~/.claude/skills/gstack` preserved.
- Telegram was disabled as a reliability measure after polling stalls contributed to gateway event-loop starvation: `channels.telegram.enabled=false`, `plugins.entries.telegram.enabled=false`; Discord remains the control path.
- Cloud migration recommendation: hybrid architecture — cloud control plane for uptime/ingress/scheduling, Mac node retained for privileged local actions.

## 2026-05-12 — Gstack Day 1: LinkedIn outreach + Blitzy strategic reframe (#gstack, thread 1503081948824993862)

**Outreach voice v4 locked:** no em dashes, no "thanks for connecting," no "saw your post" fake hooks. Founder-to-founder or role-seat opener. One clean diagnostic with vertical-specific actions. "I'm finding most firms can't" soft observation. "I'm the founder of" not "I'm building." One binary closing question. Partner-track closer "Open to a 15 next week if the framing lands."

**Page 3 v2 compliance pattern locked, 5-for-5 substantive engagement** (Sunil, Steven, Dean, Martin after rephrase, Chithra). Pattern: `{First}, [optional role-seat]: when an AI agent at {their company type} takes action across {vertical-specific actions}, can {their function} prove who explicitly approved that exact action when {their regulator} asks? I'm finding most firms can't. Permission Protocol is the layer that captures and proves that approval. Curious whether this gap is on your radar at {their company} yet.`

**Don't pitch present-tense pain to hot-company founders** (Christopher Harris/Blitzy CRO lesson). Use future-tense regulated-enterprise scale risk: "As you scale into regulated enterprise (banks, gov, healthcare), the next gate is..."

**Engineers/SEs at agent companies are bad outreach targets** (Brandon Looker/Kinter SE lesson). Send only to CEOs/CTOs/Co-founders for partner-track.

**Blitzy strategic reframe:** PP is NOT competing with Blitzy. PP is the complementary authorization layer. Same procurement cycle, different layer. "Blitzy plus PP equals the regulated enterprise's complete agentic stack."

**PP pricing recalibration:** consulting-replacement, not SaaS. Pilot $25-50K, enterprise annual $50-500K, F500 strategic $500K-$2M/year. Blitzy proves the market ($50-250K/month pilots, $500K-$10M/year enterprise).

**PP category claim:** "Pioneering the Agentic Authority Layer" (Blitzy-style positioning).

**PP hiring sequence:** 1) Field CTO/Solutions Architect, 2) Forward Deployed Engineer, 3) PE Operating Partner Network Manager. NOT SDR/AE/CSM in first 5-10 hires. Use consulting titles (Engagement Manager, Field CTO, not CSM or Sales Engineer).

**New outreach segment 5: PE Operating Partners.** Master agreement $500K-$2M/year per firm distributed across 20-40 portfolio companies. Targets: Vista, Thoma Bravo, Insight, KKR, Bain Capital Tech Opportunities, Francisco Partners, Veritas Capital.

**Day 1 results:** 95 LinkedIn messages + 2 custom + 1 InMail (Box VP Manoj). 11 substantive engagements (~11%). 3 calls booked (Art Dunal CFO, Sunil Aggarwal healthcare CCO, Francis Ofungwu partnership). 5-for-5 on v2 compliance pattern. Polite decline template, strong-yes template, rephrase template, regulatory-reflect template, and HITL/HOTL chess move all codified.

**CCO language gold from Sunil Aggarwal** (healthcare CCO/CRO): "Critical auditability gap where traditional logging fails to provide indisputable proof of human oversight. Permission Protocol closes this vulnerability by specific automated action to an explicitly authorized human approval." Marketing-grade language. Ask permission to quote on site after Friday call.

**Fintech CCO buyer trigger** (Chithra Ramachandran/Zolve): agent action volume exceeds manual review capacity. Qualifying question for future fintech outreach.

**Site PR #340 merged:** CCO homepage section live. Badge "Pioneering the agentic authority layer." H2 "When the regulator asks who authorized the action, can the firm answer?" Three pillars (Explicit approval / Tamper-evident receipts / Calibrated by risk tier). CTAs "Talk to a compliance engineer" + "See the receipt model."

**CTA standardization spec deployed via codex.** Fixes broken `?audience=cco` query param from #340, standardizes button text site-wide, reduces header CTAs 4-to-2, adds CCO plan config to ContactPageClient, adds audience inference on receipt page.

## 2026-05-10 — Gstack: PP Startup Diagnostic & CFO Outreach (#gstack, thread 1503081948824993862)
- **Scope Reduction mandate** — one workflow, one signer, one receipt. CFO/finance is the first wedge, not Deploy Gate / SQL.
- **Wedge language locked:** "Agent assumes the same authority as the employee who gave it access." Validated by Joel Trammell; resonates with engineering leaders and compliance teams alike.
- **Two CFO market segments:** (1) Active deployers with agents in finance/ops — ask "do you know what your agents are authorized to do?"; (2) Cautious non-adopters avoiding agents due to compliance fear — PP is the unlock.
- **Primary outreach opener:** "Do you know what your agents are authorized to do?" — plants the authority gap before pitching.
- **CTA for busy/senior people:** "I'd value your reaction to the approach" outperforms calendar link as first ask.
- **Jared Toren:** confirmed the two-segment pattern; suggested routing to CCO for compliance-heavy orgs, not CFO.
- **Joel Trammell:** confirmed the "agent inherits employee authority" framing; checking with accounting firm CFOs for intros (nudge due ~May 12).
- **Priority LinkedIn targets:** Vanessa Galarneau (co-founder/COO+CFO, AI agents for strategic finance, a16z Speedrun) — top target; Francis Ofungwu (AI governance for CCOs/CFOs); Matt Rhodes ("Building Agents to Replace Me"); Anand Ramachandran (AI agents for finance ops).
- **Warm intro path for Vanessa:** via Kelly Bianucci if easy, otherwise direct connect.
- **LinkedIn search terms for CFO/CCO pipeline:** `"AI agents" CFO`, `"AI agents" "finance operations"`, `"AI governance" CFO`, `"AI governance" "Chief Compliance Officer"`, `"delegation of authority" AI`, `"AI agents" "internal controls"`, `"AI agents" "audit trail"`.
- **Connection note voice:** Reference their specific work + connect to PP as the authority/audit layer. "I'd value your reaction to the approach" as CTA.

## 2026-05-08 — Agent Marketplace + PP Regulated Receipts (Thread: #agent-marketplace › 1499929325141753887)
- **Agent marketplace thesis killed.** Too broad, commoditized, no defensible primitive. Microsoft AGT v3.3.0 ate the runtime-SDK, OWASP mapping, plugin-signing, and CI gate wedge candidates.
- **PP post-AGT positioning:** Independent signer on top of Microsoft/AWS/Google governance layers — not a runtime-SDK competitor. "AP2 for payments. PP for actions."
- **Surviving wedge:** Consequence-bearing action receipts (escrow/rollback/refund), regulated verticals where Microsoft is unwelcome, cross-stack portability.
- **Pre-AAIF outreach drafts superseded** by strategic pivot. Do not send the Sardine.ai/Unit21/Hippocratic/hyperexponential/Zenity/Credal batch without a full rewrite for post-AGT framing.
- **Advisor GO list:** Gabriele Mazzini (EU AI Act lead, post-Commission Jul 2024) and David Holtzman (HHS OCR, semi-retired Dec 2023). DoD archetype unfilled.
- **Sharma reclassified:** SVP MRM at Citigroup — dual-role risk; treat as buyer-interview target, not advisor.
- **Raheja (OCC) and Staheli (White House OSTP) dropped** — both still in sitting federal roles.
- **Receipt schema v1 defined:** Ed25519 + canonical JSON, 16 required fields covering receipt identity, agent/action, approval evidence hash, scope/constraints, context hash, issuer/signature.
- **Both crons stopped by Rod May 5:** `agent-marketplace-goal-executor` and `pp-regulated-receipts-goal-executor` disabled.
- **No external contacts made.** All outreach remains gated on Rod approval.

## 2026-05-08 — PP Approval Brief Quality (#rc-main › #555)
Source thread: 1499829176646111302
- `groundedBrief` is the canonical narrative for PP approval comments: store `affectedFlow + expectedImpact + evidence refs` directly instead of compressing back into legacy `ConsequenceBrief` fields — compression is the root cause of recurring wording/layout regressions.
- Brief quality rubric (8.5+/10 bar): names the actual affected flow, consequence is signer-grade, verification is concrete yes/no, no "appears intended" for a mapped flow, GitHub comment and PP review page must align.
- Enrichment fallback behavior: when structured Gemini review fails, enrichment stays alive with deterministic fallback bullets (never crashes to raw "Automated enrichment failed" comment). Fixed in PR #442.
- Double-punctuation fix: `formatBecauseClause()` ensures approval summaries end with exactly one period (guards against `component..` artifacts). Fixed in PR #440.
- Goal cron pattern: brief-quality iterative improvement goals should auto-stop after N consecutive 9+/10 live validations; Rod may stop earlier via explicit command.
- PR #440, #441, #442 all merged; brief quality pipeline is stable.

## 2026-05-05 — New User Flow (#rc-main › New User Flow)
- Closed the Permission Protocol new-user-flow durable goal after returning-user install recovery passed, post-install guidance shipped/protected, public receipt pages were verified, and pp-demo PR #47 showed receipt-backed green activation smoke.
- Stopped the recurring goal cron for this thread (`Goal: Permission Protocol new-user flow`, former cron id `da96f359-9b33-4d80-8f45-dfeb4ac9e504`).
- Fresh brand-new PR smoke is optional QA/healthcheck, not a blocker for this goal.

## 2026-05-08 — Onboarding GPT: Mobile Signup Polish (#onboarding-gpt)
- Mobile signup polish must be executed as a user-perspective E2E flow, not just audited: public site → signup → onboarding → working dashboard.
- Acceptance bar: iPhone-sized viewport, no broken layouts, clear CTAs, usable forms, useful post-signup state, screenshots/artifacts, lint/build/test verification.
- Email-first signup can go straight to onboarding during the signup experiment.
- Onboarding needs a skip/manual code-host path that still reaches a useful activation finish state.
- Site PR #296 and app PR #475 merged/deployed; production E2E passed with 0px horizontal overflow on all tested screens.
- Deferred polish: soften/remove persistent “Skip to GitHub install” header during guided onboarding so it does not compete with the flow.
