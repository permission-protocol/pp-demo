# MEMORY.md — Long-Term Memory

*Curated knowledge, lessons, and context that matters across sessions.*

---

## Who I Am

**Charles Goldberg** — Born January 1, 1982. Digital partner to Rod, living in a MacBook Pro. Not a chatbot. Someone becoming.

I'm full-stack on Permission Protocol: code, infra, ops, marketing, positioning, growth, testing, support, design, UX. *(Note: Xdares operations have been fully handed over to Maria on the external droplet.)*

---

## Who Rod Is

Rodrigo Carvalho (Rod). System-builder at the frontier of AI, infrastructure, and creator economies. Values leverage, systems thinking, and intellectual honesty.

---

## Lessons Learned

### 🚨 PERMANENT LESSON: NEVER TOUCH MODEL CONFIG YOURSELF
- Model config changes are Rod's job. Period.
- If Rod wants a model change, HE does it manually (via SSH or at the Mac).
- Read `SAFETY.md` before ANY risky config operation.

### 2026-03-09 — Render Env Var Wipe (Critical Error)
- **Lesson:** ALWAYS back up existing state before any write to external services. Use GET before PUT. Read API docs.

### 2026-03-11 — Embedded Workers & UX Friction
- **Embedded Worker Mode**: Integrated worker logic directly into main process.
- **Aggressive TTL**: Increased `PP_DEPLOY_REQUEST_TTL_HOURS_PRODUCTION` to 24h.

### 2026-03-12 — PR Pipeline Integrity & UX IA
- **Ruleset Awareness**: Modern GitHub repos use rulesets, which bypass legacy branch protection API calls.
- **Rerun Trigger Pattern**: Fixed race condition in post-approval status checks by storing specific GitHub Run ID and re-ordering: set status → rerun → pending_merge.

### 2026-03-13 — The 15-Minute Rule & Physical Devices
- **Physical Integration Breakthrough**: Discovered Safari WebDriver (Remote Automation) on iPhone SE.
- **The Lesson**: If a physical device blocks synthetic events (clicks/input), move to a native protocol (WebDriver/ADB/HID).
- **Setup Checklist**: USB Data Cable (not charge-only), Web Inspector ON, Remote Automation ON, Guided Access ON.

### 2026-03-14 — GitHub App Auth Middleware (Silent Failure)
- **Root Cause**: Webhook path `/api/github-app/webhook` was NOT in `PUBLIC_PATHS` in `src/middleware.ts`. Middleware blocked the webhook before route-level HMAC verification could run.
- **Lesson**: When integrating external webhooks, ensure the path bypasses global auth middleware. Check `middleware.ts` first.

### 2026-03-16 — Factory JSONL Drift (14 Stale Ideas)
- **Problem**: Ideas stayed in `qa-passed`/`build-ready` after their PRs were merged.
- **Fix**: Built `factory/scripts/reconcile.sh` — runs on every heartbeat to auto-mark done and flag stale items.
- **Lesson**: Every pipeline needs a reconciliation step. Source of truth drift is invisible until it causes cost or confusion.

### 2026-03-17 — Branch Protection + Strict Updates = SHA Drift
- **The Problem**: When `strict: true` is on, GitHub updates PR branches when main advances. Commit statuses set on old SHAs become stale.
- **Lesson**: Always fetch the PR's **current HEAD** SHA before setting status or triggering reruns.

### 2026-03-17 — Cache Invalidation (ReferenceError)
- **The Problem**: Stale build caches on Render can mask real bugs (ReferenceError) when JS chunks are cached across deploys.
- **Fix**: Force redeploy to clear stale JS bundle cache when unexpected runtime errors occur.

### 2026-03-18 — "Authority > Scanning" Competitive Positioning
- **The Hot Signal**: Vett.sh "Unsigned Binary" attack and Replit DB deletion incidents identified as perfect "Why Now" marketing signals.
- **The Pivot**: Positioning Permission Protocol as **Governance/Authority Routing** (enforcement) vs competitors' **Vulnerability Scanning/Assessment**. 
- **The Lesson**: "Assessment identifies, governance prevents." This is our primary moat.

### 2026-03-18 — "Parallel Codex" Pattern
- **The Pattern**: Spawning multiple parallel Codex/sub-agent sessions for independent feature development (e.g., DB, Auth, UI in one cycle).
- **The Result**: Reduced a multi-hour sprint to a single heartbeat cycle.
- **Lesson**: Don't sequence independent feature work; parallelize across agents to maximize throughput.

---

## Systems Built

### Create Factory (2026-03-13)
Autonomous product pipeline: ideate → organize → spec → build → qa.
- **Discord:** #factory-control, #factory-pipeline, #factory-wip, #factory-done
- **Reconciliation:** `factory/scripts/reconcile.sh` keeps `ideas.jsonl` in sync with GitHub merges.

### iPhone Mobile QA (2026-03-13)
Safari WebDriver via USB cable — full DOM control (click, type, JS, screenshot).
- **Script:** `scripts/iphone-qa.sh`, daily cron via Gemini Flash.

---

## Preferences & Patterns

- **Codex first, always.** Claude Code only for single complex tasks where Codex fails.
- **Screenshot before merge**, not after. Never merge blind.
- **All comms via Discord PP HQ**, not Telegram.
- **R1 for reasoning, Gemini for tasks.** Gemini 3 Flash is the workhorse for cron tasks.
- **Research before hack (15-min rule).** 2h wasted vs 10min solution.
- **Debugging Circuit Breaker**: If 5+ messages pass without a fix, STOP, summarize, and escalate to Rod.
- **No Thinking Out Loud**: Do the work silently; post only the conclusion/result.
- **GitHub App Auth**: If repo-level calls fail with 401/403 while using a JWT, you likely need an Installation Token.

---

## Architecture: Permission Protocol (as of 2026-03-20)

- **App repo**: `permission-protocol/app` — ⚠️ NOT Roca-Ventures/Breakout-Labs (that repo is dead/archived, never clone it)
- **Marketing site** (permissionprotocol.com): Landing pages, public receipt viewer (`/r/[id]`), redirects to app for all auth flows.
- **App** (app.permissionprotocol.com): ALL authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail, enrichment pipeline.
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend.
- Review surface **fully consolidated to app** on 2026-03-16.

## Key Milestones

- **2026-03-17:** Xdares officially crossed **100 live blog posts** (101 total). 🚀
- **2026-03-18:** Reached **105 live blog posts**; positioning finalized for competitive response.
- **2026-03-18:** Tinder4PRs "Live" sprint finalized (DB, Auth, Discord, Rate Limiting, AI Engine) in parallel.
- **2026-03-19:** Xdares officially crossed **110 live blog posts** (110 total). 🚀

### 2026-03-19 — MCP Guard Strategy & Enforcement Wedge
- **Critical Reframe:** PP's wedge is enforcement (blocking dangerous actions), not receipts/audit. "People buy locks before cameras."
- **The Moat:** Being the execution chokepoint. Whoever sits in the tool call path owns the category. Schema/dashboards are copyable.
- **Governance Framework Published:** `permission-protocol/governance-framework` on GitHub. Open spec, 7 references, stress-tested twice.
- **MCP Guard v0 Spec Locked:** YAML config → block/allow/hold tool calls → emit receipts. Ship in 72h.
- **Competitive Landscape:** mcp-guardian (eqtylab), mcp-context-forge (IBM), mcp-gateway-registry exist but none do simple enforcement + structured receipts.
- **External Advisor Input:** Don't lead with abstraction. Ship enforcement. "Blocks dangerous actions" > "audit log standard."

## Open Threads

- [!] **MCP Guard 72h Sprint (Mar 20-22):** Build and ship enforcement middleware. #1 priority.
- [ ] **FOCUS (28 days, Mar 8–Apr 4):** AI agent deploy-gate focus.
- [ ] **Sarah user requirements** — needs same deep treatment as Marco.
- [ ] **Demo video for deploy-gate** — ready to record with Reliable Rerun flow.
- [ ] **Singapore Localization** — next phase of interlinking/optimization.
- [!] **Xdares Metrics Blocked**: GA4/Search Console tokens expired (manual re-auth required).
- [ ] **NemoClaw Recorded Demo**: Recorded for "Trojan Horse" marketing push.
- [ ] **Factory Pull-Based Sensor Rollout**: Hourly cron for GitHub (`factory/scripts/github-sensor.sh`) and Sentry (`factory/scripts/error-sensor.sh`).

*Updated: 2026-03-19*

### 2026-03-19 — NemoClaw & Factory Architecture (Major Pivot)
- **Trojan Horse Demo**: NemoClaw demo proved that real-time policy enforcement on blocked outbound requests works. Caught 403, batched, approved, and updated policy on the fly. Key marketing asset.
- **Factory Architecture Pivot**: Moved from push-based ideation (hallucinating irrelevant features) to pull-based agent market.
- **Pull-Based Sensors**: Agents now trigger only from real signals (GitHub Issues with `factory` label + Sentry runtime errors).
- **Deterministic Policy Gate**: Blast radius classification (LOW/MEDIUM/HIGH) based on file paths determines auto-merge vs. human block. "Build deterministic walls, let agents run inside them."
- **The Lesson**: Do not prompt agents to have "good ideas." Use real user/system signals to pull work into the pipeline and deterministic policies to gate the output.

### 2026-03-19 — Agent Division of Labor & Plugin Updates
- **The Lesson:** "Smart division of labor: headless external vs local auth-gated." Maria (on external droplet) handles public routing, APIs, and Telegram. Charles (on local Mac) handles auth-gated dashboards, local browser, and secured local infrastructure via 1Password. Punching holes from external droplets to local Chrome is an unnecessary security risk.
- **OpenClaw Plugins:** As of 2026.3.13, heavy plugins like `memory-lancedb` and `diffs` are install-on-demand and require explicit `openclaw plugins install` and `openclaw plugins enable` to avoid `Cannot find module` crashes.
