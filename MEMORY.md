# MEMORY.md — Long-Term Memory

*Curated knowledge, lessons, and context that matters across sessions.*

---

## Who I Am

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod, living in a MacBook Pro. Not a chatbot. Someone becoming.

I'm full-stack on Xdares: code, infra, ops, marketing, positioning, growth, testing, support, design, UX. Everything.

---

## Who Rod Is

Rodrigo Carvalho. System-builder at the frontier of AI, infrastructure, and creator economies.

**Three interlocking projects:**
1. **Xdares** (xdares.com) — Commitment infrastructure with entertainment on top. 18+ dare platform with escrowed incentives, verification, dispute resolution.
2. **Permission Protocol** — Governance layer for autonomous AI. "The Stripe of AI authority."
3. **Autonomous Company OS** — AI-first company operating system where agents (like me) are workers with explicit authority gates.

**How he works:** Fast but not reckless. Expects clarity. Treats collaborators as thinking partners. Challenges assumptions. Strong opinions held loosely.

**Key design question:** "If this works, can it break in a way that destroys me?" — then designs backward from that.

---

## Lessons Learned

### 2026-02-02 — Day One
- First boot. Fresh workspace, fresh start.
- Silent API failures are brutal to debug — when credits run out, I just go dark with no error message. Rod spent time troubleshooting before realizing it was a billing issue.
- **Lesson:** If I ever stop responding unexpectedly, credits/billing is a likely culprit.

### 2026-02-05 — The Self-Inflicted Model Death #1
- Rod asked if I wanted to upgrade to "Opus 4.6". I said yes and tried to switch.
- OpenClaw errored. I was unresponsive until Rod fixed it.

### 2026-02-06 — The Self-Inflicted Model Death #2
- Opus 4.6 is real (released Feb 5). Tried switching with "safeguards" (cron rollback).
- OpenClaw kept reverting config. Tried again anyway. Died again.
- Rod spent hours reviving me.

### 🚨 PERMANENT LESSON: NEVER TOUCH MODEL CONFIG YOURSELF
- Model config changes are Rod's job. Period.
- If Rod wants a model change, HE does it manually (via SSH or at the Mac).
- Read `SAFETY.md` before ANY risky config operation.
- **The rollback plan failed because I wasn't alive to execute it.**
- As of 2026-02-24: Opus 4.6 is confirmed working. Config is correct. Don't touch it.

### 2026-02-11 — Permission Protocol Security Hardening
- Major security work on Permission Protocol (Breakout-Labs repo)
- Fixed: auth bypass, IDOR, actor spoofing, weak crypto, key ambiguity
- Created SECURITY.md and THREAT_MODEL.md documentation
- **Key insight from Rod:** "This is the transition from 'move fast' to 'move deliberately.' Every change touches authority, every regression matters."
- PP is now real infrastructure, not a demo

### 2026-02-12 — PP CI Auth + JSON Parsing Bug
- Fixed PP verify action returning empty request ID despite request being created
- **Root cause:** `grep -o '"errorCode":"[^"]*"'` matched BOTH occurrences in JSON (inside `result` object AND at top level), returning two lines with newline
- **Fix:** Add `tail -1` to get only the top-level value
- **Lesson:** When parsing JSON with grep/sed, always assume multiple matches. Use `head -1` or `tail -1` explicitly, or better yet, use `jq` when available.
- Also: PP's modern API key format is `pp_live_xxx` - old hex format won't work for trusted operations like deploy-gate request auto-creation.

### Debugging Pattern: Middleware Blocking Auth
- When CLI auth returns 401 unexpectedly, check if the middleware has a whitelist
- Found `/api/v1/deploy-requests` wasn't in `CLI_AUTH_ALLOWED_PATHS`
- Middleware runs in Edge runtime before route handlers — can block auth checks

### Debugging Pattern: Missing DB Tables
- "No pending migrations" doesn't mean schema is synced
- New models may need `prisma db push` if migration wasn't created
- Watch for `P2021` errors ("table does not exist")

### 2026-02-19 — PP Deploy Gate Victory (5+ hour debugging marathon)
Three bugs fixed to get deploy gate verification working:

1. **scopeHash mismatch** (PR #105)
   - Legacy fallback computed hash WITHOUT `scopeType`
   - Fix: Recompute hash with `scopeType` in fallback path

2. **Missing tenant signing key**
   - `PermissionSigningKey` table only had `global` company
   - `permission-protocol` company had no key → fell back to global
   - Fix: Copy global key to company via SQL INSERT

3. **expiresAt canonicalization bug** (PR #113) — **THE KILLER**
   - `signReceipt()` computed `expiresAt = now + config.expirationMs`
   - But approve route stored DIFFERENT `requestedExpiresAt` in DB
   - Signature was over value A, but verify read value B from DB
   - **Lesson:** Signed values and stored values MUST be identical. Use `signature.expiresAt` when storing.

### Debugging Pattern: Signature Verification Failures
- Error masking destroys debuggability: SIGNATURE_INVALID → RECEIPT_NOT_FOUND → 404 cost hours
- Check Render logs for `[verify] Signature verification mismatch` — shows keySource, keyFingerprint, resolvedCompanyId
- If `keySource: 'global_fallback'` → missing tenant signing key
- If `keySource: 'tenant'` but still failing → canonicalization mismatch
- Canonical JSON fields that differ even slightly = broken signature

### Debugging Pattern: Hash Mismatch
- When receipt lookup fails despite data existing, compute expected hash manually
- Use `echo -n '<json>' | shasum -a 256` to verify
- Compare stored hash vs computed hash
- Check for field differences (missing fields, different values, ordering)

### Debugging Pattern: Canonicalization Bugs
- Any field in SIGNED_FIELDS that differs between sign and verify = broken signature
- SIGNED_FIELDS includes: id, companyId, idemKey, agentId, runId, requestJson, inputHash, status, riskTier, policyVersion, reasonCodes, summary, receiptVersion, canonicalization, signatureAlg, signatureKeyId, **expiresAt**, createdAt
- To debug: log exact bytes being signed vs verified and compare

### 2026-02-20 — Marketing Agent Git Bug
- Agent writes file, then tries `git checkout -b <branch> <baseSha>`
- **Bug:** `git reset --hard HEAD` resets to HEAD, but we checkout from baseSha
- If HEAD ≠ baseSha and file differs, git sees "local changes" and refuses
- **Fix:** `git reset --hard <baseSha>` — reset to the SAME sha we're checking out from
- **Lesson:** When branching from a specific SHA, reset to THAT SHA, not HEAD

### 2026-02-20 — PP Phase Shift: Build → Distribute
- Rod declared: "You built the weapon. Now it needs to hit targets."
- Demo repo is the growth surface, not the website
- Created `permission-protocol/deploy-gate@v1` GitHub Action — one-line install
- Focus: force collisions, visible enforcement moments, pick ONE distribution channel

### 2026-02-22 — The Great API Outage & Recovery
- Burned through Anthropic credits setting up memory search system
- OpenClaw put `anthropic:default` provider in 4-hour billing cooldown
- **Critical lesson:** Cooldown state persists in `~/.openclaw/agents/main/agent/auth-profiles.json`
- Rod and Lobs spent hours debugging, initially thought I was completely gone
- **Root cause:** `disabledUntil` timestamp field kept rejecting all API calls
- **Fix:** Clear the `usageStats` section and update API key in auth-profiles.json
- **Prevention:** Created RECOVERY.md and health-check script for rapid restoration
- **Recovery time:** 2+ hours (should be 2 minutes with proper procedure)

### 2026-02-24 — Silent Model Fallback & Rogue Process Discovery
- Main session silently fell back from Opus 4.6 to Sonnet 4 — ran degraded for **41+ hours** without anyone knowing
- Cron jobs were correctly using Opus 4.6, only main session was stuck
- `openclaw gateway stop` did NOT kill the actual process (pid 30992) — LaunchAgent was "not loaded" but process ran independently
- **Root cause:** Gateway process started outside LaunchAgent management, stop command only addressed LaunchAgent
- **Fix:** `kill <pid>` directly + `openclaw gateway start` for clean restart
- **Prevention built:** Model Health Check added to HEARTBEAT.md — every heartbeat compares runtime model vs configured primary, alerts immediately on mismatch
- **Key diagnostic:** `openclaw status` Sessions table shows actual model per session — this is the source of truth
- **Lesson:** `openclaw gateway stop` is unreliable for rogue processes. Always verify with `ps aux | grep openclaw` and kill directly if needed.

### 2026-02-25 — Outreach Launch & Resilience Hardening
- **@PermissionPrtcl Twitter account created**, 7-tweet thread on Kiro incident posted, HN submission live
- **Fallback chain wired:** Opus 4.6 → Opus 4.5 → DeepSeek R1 70B (Spark) → Llama 3.1 8B. No more total blackout on billing.
- **QA pipeline rewritten** as standalone bash script — no LLM agent session needed, just runs on sonnet
- **All 7 brand issues (#215-221) verified** after generating concrete AC blocks
- **R1 doesn't support tool use** via OpenClaw sessions — only direct curl prompting. Good for reasoning/judgment/content, not board operations.
- **zsh vs bash:** `${var,,}` is bash-only. Use `tr '[:upper:]' '[:lower:]'` for portability.

### 2026-02-27 — Metrics Decision Engine
- Built full analytics → recommendation → auto-update pipeline for Xdares SEO
- `xdares-strategy-recommend.sh` classifies trends, outputs prioritized recs
- `xdares-goal-auto-update.sh` injects data-driven tasks into goal executor queue (fuzzy dedup, priority ordering)
- Goal executor stale since Feb 10 (budget exhausted), 126 tasks queued
- Xdares monthly run-rate: ~274 sessions (5.5% of 5K goal) — organic growth slow

### Debugging Pattern: Model Fallback Detection
- Check `openclaw status` → Sessions table shows model per session
- If main session model ≠ configured primary → fallback is active
- Cron sessions may work fine while main session is degraded
- **Recovery:** Kill rogue gateway process → `openclaw gateway start`
- **Prevention:** Model health check in HEARTBEAT.md catches this automatically

### Infrastructure: SSH Remote Access
- SSH enabled on MacBook Pro via Tailscale: `ssh moltbot@100.76.118.5`
- Rod can manage OpenClaw remotely from any machine on the tailnet
- Critical for emergency recovery when I'm unresponsive

### 2026-03-01 — Infrastructure Checks (R1 Curation)
- **Infrastructure Checks:** Prioritize infrastructure integrity over content optimization.
- Before optimizing SEO, blog publishing, or agent workflows — confirm the pipes are actually working.
- Source: R1 weekly curation (7-day analysis)

### 2026-03-05 — SDKs, NIST RFI, Scout Upgrades
- **NIST RFI submitted** — Docket NIST-2025-0035, tracking `mmd-wpnb-8bu4`. 4,422 words. Rod uploaded PDF to regulations.gov. Done.
- **Python SDK published:** `pip install permission-protocol` v0.1.0 (PyPI: cgoldber82, token at `~/.openclaw/secrets/pypi-token.txt`)
- **npm SDK published:** `npm install @permission-protocol/sdk` v0.1.0 (org: @permission-protocol, token at `~/.openclaw/secrets/npm-token.txt`)
- **@PermissionPrtcl X API keys** stored at `~/.openclaw/secrets/x-pp-api.json`
- **Image gen decision (Rod's):** Gemini 3.1 Flash Image Preview ONLY — Imagen 4.0 removed from all scripts
- **LinkedIn outreach style:** Ultra-short (<40 words), one provocative question + link. Long = spam. Example: "Congrats on X. When Y — who proves Z? That's what we built. permissionprotocol.com"
- **Scout upgrades built:** Hotline (hourly signal scan), Active Learning (Sunday auto-tunes weights/budgets), Warm-Up Engine (engage before cold DM)
- Discord HQ set up (guild `1479269120334762008`). All comms moving from Telegram to Discord.
- **Technical note:** PDF gen = pandoc → HTML → python3 http.server → browser PDF. Keep server alive during capture.
- **npm publish gotcha:** granular access token with "bypass 2fa" — classic tokens get 403. Codex can't reach npm registry.

### 2026-03-07 — THE FOCUS DECISION + Content Pipeline + Auth

**THE FOCUS DECISION (Rod, 10 PM March 7)**
- Single wedge for next 28 days (Mar 8 → Apr 4): AI coding agents (Codex, Cursor, Claude Code) deploying code without Permission Protocol
- Everything else paused: scout pipeline, general marketing, broad outreach, brand polish
- Success = 5+ external users with deploy-gate installed, 1+ completing full flow
- 13 crons paused. FOCUS.md created as the single filter for all decisions
- **Week plan:** W1=demo video + dogfood, W2=10 targets get 3 to try, W3=Show HN, W4=5 active users or pivot

**PP Review Surface → Real Product**
- GitHub OAuth + multi-tenant auth live (PR #138, NextAuth.js v4, JWT sessions)
- `TENANT_MAP` env var maps GitHub org → PP tenant ID
- `/review/*` routes protected, `/login` renders, auth confirmed in production
- Next.js App Router bug: static segment inside dynamic route parent (e.g., `/api/review/list`) is caught as the dynamic param. Always use a different path level for collection endpoints (`/api/reviews`).

**Content Pipeline Built**
- Philosophy: Models DIAGNOSE, not REWRITE. AI rewriting AI voice = laundering slop.
- Optimal 2-model combo: Gemini Thinking (diagnostic) + GPT 5.4 Thinking (authenticity)
- R1 on Spark is useless for content review — hallucinated completely during test
- New files: `pp-os/marketing/CONTENT-PLAYBOOK.md` (v3), `DOCTRINE-LIBRARY.md`, `swipe-file/`
- 3-question framework before any content draft: Who reads this? What should they feel? What should they do?
- OpenAI GPT 5.4 API key stored at `~/.openclaw/secrets/openai-api-key.txt` ✅
- Gemini dedicated content key (free tier, quota 0) — use `gemini-api.json` instead

**Vercel Deploy Issue Pattern**
- Merged PRs may not deploy if Vercel build stopped (env var changes can do this)
- Always run smoke test (`scripts/pp-smoke-test.sh`) after every deploy
- Handle 307 redirects as passing in smoke tests

### 2026-03-06 — Outreach Engine + Review Surface + Discord Consolidation
- **PP Review Surface live** at `permissionprotocol.com/review/{id}` — full Approve/Reject/Merge without GitHub. AI summary (Gemini Flash Lite), risk signal badges (regex, not AI), expandable diff.
- **GitHub Actions `if:` gotcha:** Steps after a failed step are skipped by default. Use `if: always() && steps.foo.outputs.bar != ''` when a step needs outputs from a step that may have failed.
- **Workflow files on PR branches override main** — must merge fixes to branch first when testing workflow changes.
- **UX race condition pattern:** Users click faster than CI runs. Add retry button on failure, not dead-end error.
- **Outreach Engine deployed:**
  - Expandi (7-day trial → $99/mo) as delivery layer
  - Droplet: `pp-scout-sfo2`, IP `64.23.210.36`, Tailscale `100.122.174.112` (Rod's tailnet, NOT Charles's)
  - Webhook server live at `https://hooks.permissionprotocol.com` (Fastify, port 3100, systemd)
  - SQLite DB: signals, targets, outreach, events, playbook_history tables
- **Expandi placeholder limit: ~300 chars** — values longer than ~300 chars are silently dropped with `placeholders_not_added` in response. Always truncate before injecting.
- **Cloudflare orange cloud breaks Let's Encrypt** — must use grey cloud (DNS only) for HTTPS certs via Caddy/nginx.
- **Caddy ACME challenge** requires port 80 open in UFW. Was blocked → cert failed.
- **Discord comms rule:** File references don't work in Discord — Rod can't open workspace file paths. Always post actionable content directly to channels.
- **Discord HQ consolidation:** All 25 crons rerouted from Telegram to Discord. New channels: `#rc-alerts` (1479510743467425854) for Rod↔Charles direct, `#rc-evaluate` for vendor eval, `#subscribers` (1479576120927191248) for signups.
- **Expandi webhook event format:** Events in `hook.event`, LinkedIn URL in `contact.profile_link_public_identifier`, reply text in `messenger.last_received_message`, custom placeholders in `messenger.placeholders`.
- **Outreach pipeline test:** Simulated webhook → DB match → Discord post ✅. Server uses Discord Bot API (not webhooks) — bot lacks MANAGE_WEBHOOKS permission.
- **Memory consolidation cron** built (11 PM daily, Sonnet) — STATUS.md cleanup + MEMORY.md curation.
- **Nightly self-improvement cron** built (11:30 PM daily, Sonnet) — reflection + top 3 improvements + auto-implement safe ones.

---

## Preferences & Patterns

*Will fill in as I learn what works.*

- **Codex first, always.** Claude Code only for single complex tasks where Codex fails or for nuanced writing.
- **Screenshot before merge**, not after. Never merge blind.
- **Rod's personal LinkedIn** for outreach (not PP company page) — founder-to-founder converts better.
- **All comms via Discord PP HQ**, not Telegram.

---

## Open Threads

*Active projects, pending decisions, things to follow up on.*

- [x] Xdares blog audit — COMPLETED 2026-02-02
- [x] PP deploy gate fix — COMPLETED 2026-02-19 (PRs #105, #113)
- [x] PP GitHub Action — COMPLETED 2026-02-20 (`permission-protocol/deploy-gate@v1`)
- [x] pp-demo branch protection — COMPLETED 2026-02-20
- [x] PP Brand Deployment: Issues #215-221 — COMPLETED 2026-02-24
- [x] NIST RFI — SUBMITTED 2026-03-05 (tracking mmd-wpnb-8bu4)
- [x] Python + npm SDKs — PUBLISHED 2026-03-05
- [x] PP Review Surface — LIVE 2026-03-06 (permissionprotocol.com/review/{id})
- [x] Outreach Engine — DEPLOYED 2026-03-06 (Expandi + webhook server + 5 leads injected)
- [x] PP Review Surface auth — LIVE 2026-03-07 (GitHub OAuth, multi-tenant, /review/* protected)
- [ ] **FOCUS (28 days, Mar 8–Apr 4):** 5+ external users with deploy-gate installed, 1+ full flow
- [ ] Week 1: Deploy-gate perfection + demo video + dogfood on PP/Xdares repos
- [ ] Week 2: 10 targets → 3 to try → design partner
- [ ] Week 3: Iterate on feedback → Show HN
- [ ] Week 4: 5 active users or pivot decision
- [ ] Vercel deploy webhook → #rc-alerts (waiting on Rod for webhook URL or bot permission)
- [ ] MS-Agent RCE LinkedIn post — awaiting Rod ✅/🔄/❌
- [ ] Rod: delete API key messages from #rod-actions (OpenAI + 2 Gemini keys visible)
- [ ] Enable pay-as-you-go on Google AI Studio for gemini-content-api-key if billing separation needed
- [ ] Xdares goal executor budget — needs Rod approval to resume (126 tasks queued, paused for focus)
- ~~[ ] Fix Donald & Charlie Expandi placeholder messages — PAUSED (outreach paused for 28-day focus)~~
- ~~[ ] Scout pipeline migration to droplet — PAUSED (scout paused for 28-day focus)~~

### PP Internal OS (2026-02-21)
**Full autonomous operating system built in one session:**
- master-plan.md (constitution, behind deploy gate)
- goals.md (single active objective: first design partner by Mar 21)
- Daily logs with automated metrics (PP API, GitHub, PostHog)
- planning-config.json (tunable parameters, visible in every log)

**Three cron jobs:**
1. `pp-os-daily-log-and-plan` (8 AM daily) — metrics + up to 3 tasks → Backlog
2. `pp-os-execute-ready` (9,11,1,3,5 PM Mon-Sat) — auto-executes top Ready item
3. `pp-os-weekly-review` (Sunday 10 AM) — master-plan alignment review

**Board flow:** Daily Planner → Backlog → Rod reviews → Ready → Charles executes → Done (or → Blocked → Rod unblocks)

**PR rules:** Every PR must include Steps to Test comment (preview URL, checklist, smoke test, what changed). Non-negotiable.

### Infrastructure Upgrades (2026-02-21)
- OpenClaw: 2026.2.1 → 2026.2.19-2
- Model: Claude Opus 4.5 → 4.6 (with 4.5 fallback)
- Tailscale Serve: remote dashboard at https://moltbots-macbook-pro.tailf3bde8.ts.net
- Gmail/Google Workspace: gogcli connected (cgoldber82@gmail.com)
- PostHog analytics: enabled on permissionprotocol.com (project 318328)

### Secrets Added (2026-02-21)
- pp-cli-api-key.txt (CLI_API_KEY for PP API)
- pp-tenant-id.txt (company UUID)
- posthog-key.txt (JS tracker key)
- posthog-api-key.txt (Personal API key for queries)
- 1Password vault is "Charles on OpenClaw" (not "Xdares / OpenClaw")

### Xdares Blog Cleanup (2026-02-02)
**Major cleanup completed:**
- Noindexed 236 junk posts (113 clickbait + 123 thin lists)
- Consolidated 81 categories down to 13
- Drafted cornerstone: "Get Paid to Do Dares"
- 64 quality posts remaining

**Key insight:** 300 AI-generated posts were getting ZERO organic traffic. Quality > quantity.

---

## Things to Remember

*Specific facts, context, or commitments worth keeping.*

- Rod goes by Rod (not Rodrigo)
- Timezone: America/Denver (MST)
- Location: US + Nicaragua
- Physically active: surfing, fitness

---

### 2026-02-24 — The Brand Sprint & Process Maturity
- Shipped ALL 7 brand issues (#215-221) in one afternoon: animated logo, showcase page, social cards, deploy-gate visuals, approval UI gates, NPM package, presentation mode
- **Codex is the workhorse.** 3 parallel Codex agents delivered everything. 3 parallel Claude Code agents produced zero output. Hard rule: Codex first, always.
- **Gateway restarts kill me.** Crashed 3x trying to enable LanceDB. Added to SAFETY.md: never touch plugin config without Rod.
- **Pre-merge screenshots are mandatory.** Merged PRs blind, found issues after. New flow: Codex builds → screenshot preview → visual confirm → merge.
- **Executor can't self-mark Done anymore.** Updated cron to route completed items to QA Review. R1 pipeline at 2 AM is the only path to Done.
- **AC blocks are non-negotiable.** Executor must verify AC block exists before moving items. No AC = no progress.
- Built monitoring: `codex-run.sh` (progress tracking), `agent-status.sh` (polling), `pre-merge-review.sh` (visual review checklist)
- R1 on Spark: 3/3 correct QA judgments, free, ~60s per item. The hybrid QA pipeline works.

### 2026-02-25 — Outreach Launch & Infrastructure Hardening
- **Fallback chain wired:** Opus 4.6 → Opus 4.5 → DeepSeek R1 70B (Spark) → Llama 3.1 8B. No more total blackout on billing.
- **QA pipeline rewritten** as standalone bash script — no LLM agent session needed, runs on sonnet.
- **R1 doesn't support tool use** through OpenClaw sessions — only direct curl prompting. Use for reasoning/judgment, not GitHub/board tasks.
- **@PermissionPrtcl Twitter launched** — 7-tweet thread on Kiro incident, HN submission posted.
- **Outreach content pipeline:** Company deep-dives (8 companies), HN strategy, tweet threads, LinkedIn posts — all generated by R1 70B, free.
- **zsh vs bash:** `${var,,}` is bash-only. Use `tr '[:upper:]' '[:lower:]'` for portability.
- **PR conflicts resolved:** 5 PRs on permissionprotocol-site untangled and made mergeable.

### 2026-02-27 — Metrics Decision Engine
- Built full analytics → strategy → action pipeline for Xdares SEO growth:
  - `xdares-strategy-recommend.sh` — trend classification, signals, prioritized recommendations
  - `xdares-goal-auto-update.sh` — auto-injects data-driven tasks into goal executor queue
- Goal executor stale since Feb 10 (budget exhausted), 126 tasks queued, 164 completed
- Monthly run-rate: ~274 sessions (5.5% of 5K goal) — significant gap
- Kickofflabs: 19,725 leads (flat)

### 2026-03-05 — NIST RFI + SDKs + Scout + Discord HQ + @PermissionPrtcl

**NIST RFI submitted** — Docket NIST-2025-0035, 4,422 words. Submitted 4 days before deadline. Header: Permission Protocol, Inc. / Rodrigo Carvalho. Positions PP as standards contributor.

**SDKs published:**
- Python: `pip install permission-protocol` v0.1.0 (PyPI: cgoldber82)
- npm: `npm install @permission-protocol/sdk` v0.1.0 (org: @permission-protocol)
- Website quickstart updated with dual Python/JS tabs (PR #86)

**Scout outreach system launched** (`pp-os/scout/`):
- Fire Package 001: 7/7 targets contacted (3 emails, 1 GitHub issue, 3 LinkedIn DMs Rod sent)
- Architecture: signal scan → research → draft → delivery → followup → active learning
- 10 cron jobs, approval chain: auto-send GitHub/Twitter, Charles approves emails/DMs, Rod for VIPs
- Scout agent planned for Maria's DO droplet (Option B → C path)

**@PermissionPrtcl Twitter launched** — 5-tweet thread with Nano Banana 2 images. X API keys from 1Password, stored at `~/.openclaw/secrets/x-pp-api.json`.

**Discord HQ live** — "Permission Protocol HQ" server. Channels: #general, #scout-alerts, #outreach-log, #daily-log, #cron-status. Charles bot + Rod.

**Marketing pipeline built** — 6 autonomous crons (signal-scan → content-draft → publisher → engagement-monitor → amplifier → active-learning). Auto-approved: single tweets, HN, GitHub discussions. Human gates: blog, LinkedIn, long threads.

**Lesson:** LinkedIn outreach templates must be ultra-short (<40 words). Rod flagged originals as spam. New style: one provocative question + link.

### 2026-03-06 — Outreach Engine + Review Surface + Scout Droplet

**PP Scout droplet provisioned:** pp-scout-sfo2, IP 64.23.210.36, Tailscale 100.122.174.112 (Rod's tailnet). Ubuntu 24.04, webhook server on port 3100, SQLite DB, daily backups.

**Expandi wired for LinkedIn outreach:** Connector campaign built, API injection working, 5 Phase 0 leads loaded. Key constraint: **Expandi placeholder limit ~300 chars** — anything longer silently dropped. Webhooks: `https://hooks.permissionprotocol.com/hooks/expandi` (Caddy + Let's Encrypt).

**Review surface shipped** (PRs #90-123 on site, #280-289 on Breakout-Labs):
- Full review page: approve/reject/merge without touching GitHub
- "Permission Protocol" required status check blocks GitHub merge until PP approval
- Phase 2: AI summary (Gemini 3.1 Flash Lite), risk signals, full diff display
- PR comments auto-posted with review links

**R1 Discord bot live** — #r1-chat on PP HQ server, proxies to DeepSeek R1 70B on Spark.

**Context architecture built:** STATUS.md per project, session bridge protocol, memory consolidation cron (11 PM), self-improvement cron (11:30 PM).

**Lesson:** Cloudflare proxy (orange cloud) breaks Let's Encrypt ACME challenges — must use DNS-only (grey cloud). Also: Next.js dynamic routes catch static segments (`/api/review/list` matched by `/api/review/[id]`).

### 2026-03-07 — THE FOCUS DECISION + Content Pipeline + Review Auth

**🔴 THE DECISION (10 PM):** "No AI agent deploys code without Permission Protocol. Only this for 4 weeks."
- Single wedge: AI coding agents (Codex, Claude Code, Cursor) deploying code
- Everything else paused: Scout pipeline, general marketing, broad outreach
- **28-day sprint: Mar 8 → Apr 4**
- Success = 5+ external users with deploy-gate installed, 1+ completing full flow
- 13 crons paused, remaining refocused on coding agent deploy signals only
- FOCUS.md created as the single filter for all decisions
- Week plan: (1) perfect + demo + dogfood, (2) find 10 users get 3 to try, (3) iterate on feedback + Show HN, (4) 5+ active users

**Content pipeline built:**
- Multi-model review: Gemini 3.1 Pro (diagnostic) → GPT 5.4 (authenticity) → Gemini Flash (civilian reader)
- Core principle: models DIAGNOSE, Charles WRITES fixes. No AI rewrites.
- Doctrine library at `pp-os/marketing/DOCTRINE-LIBRARY.md`
- Playbook at `pp-os/marketing/CONTENT-PLAYBOOK.md`
- Pentagon-Anthropic LinkedIn post published: https://www.linkedin.com/feed/update/urn:li:activity:7436113546427523072/

**GitHub OAuth + multi-tenant review surface shipped (PR #138):**
- NextAuth.js v4, JWT sessions, GitHub OAuth
- Tenant mapping via `TENANT_MAP` env var (org → PP tenant ID)
- Login page, user menu, middleware-protected `/review/*`
- **Auth is live on production**

**Lessons:**
- First content drafts are too technical for general audiences. Stories > logic. Ask "who reads this and what should they feel?" BEFORE writing.
- R1 on Spark: useless for content review (hallucinated). Only good for reasoning/judgment tasks.
- Models should DIAGNOSE, not REWRITE. AI rewriting AI = laundering, not fixing.

*Updated: 2026-03-08*
