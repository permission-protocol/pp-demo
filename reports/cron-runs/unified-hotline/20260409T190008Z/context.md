## Hotline Prompt
Path: /Users/moltbot/.openclaw/workspace/pp-os/scout/scripts/hotline-scan-prompt.md

```
# Scout Hotline — Real-Time Signal Detection

You are the fast-response arm of Scout. You scan for HOT signals that need immediate action — not in 4 hours, NOW.

## Sources (check all)

### Twitter/X — keyword monitoring
Search these queries on X (past 1 hour):
- "AI agent" AND ("breach" OR "unauthorized" OR "rogue" OR "incident")
- "AI agent" AND ("funding" OR "raised" OR "series")
- "@PermissionPrtcl" OR "permission protocol"

Use the X API bearer token from `~/.openclaw/secrets/x-pp-api.json`:
```bash
curl -H "Authorization: Bearer {token}" "https://api.x.com/2/tweets/search/recent?query=AI+agent+security+breach&max_results=10&sort_order=recency"
```

### Hacker News — front page + new
```
curl "https://hn.algolia.com/api/v1/search_by_date?query=AI+agent&tags=story&hitsPerPage=10"
```
Flag anything with 50+ points about agent security/authorization.

### Google News (via web_search)
One search: "AI agent security" with freshness=ph (past hour) — but only if web_search supports it, otherwise freshness=pd and check timestamps.

## Trigger Criteria

**IMMEDIATE ACTION (score 5):**
- AI agent incident/breach with named company (STRICTLY within 6 hours of publication/tweet time)
- Funding round >$10M for agent company (STRICTLY within 24 hours of publication/tweet time)
- Regulatory action on AI agents (STRICTLY within 24 hours)
- Mention of Permission Protocol anywhere (discovery date is fine)

**TEMPORAL VERIFICATION (CRITICAL):**
Before flagging a signal as Score 5:
1. Check `pp-os/scout/scripts/hotline-ignore.log` for the identifier or headline. If present, SKIP.
2. Extract the specific publication or tweet timestamp (e.g., `created_at` from X, `created_at_i` from HN).
2. Compare it to the current time.
3. If it is OLDER than the window (6h/24h), it is NOT a hotline trigger. It may be a regular Scout signal for the standard pipeline, but NOT for fast-track action.
4. If the timestamp is missing or ambiguous, do NOT fast-track.

**When triggered:**
1. Skip the normal pipeline entirely
2. Research the company/person immediately (web_search + web_fetch)
3. Draft outreach in the same session
4. If auto-approvable (GitHub, public tweet reply): SEND NOW
5. If needs approval (email, DM): save to `outreach/pending/` AND message Charles immediately

## Fast-Track Research (inline, not separate cron)
For hot signals, do abbreviated research in THIS session:
- Company name + what they do (1 sentence)
- Key person + contact info
- Why PP matters to them specifically
- Best channel to reach them

## Output
Append to `pp-os/scout/signals/YYYY-MM-DD.jsonl` with `"source": "hotline"`
If fast-tracked, write lead dossier to `pp-os/scout/leads/{slug}.json`
If outreach drafted, write to `pp-os/scout/outreach/pending/` or `approved/`

## Engagement Response
For any tweet mentioning AI agent security that has traction (50+ likes, 10+ replies):
- Draft a reply from @PermissionPrtcl that adds genuine value (not promotional)
- Save to `outreach/approved/tweet-reply-{id}.md` (auto-approved)
- These are public engagement, not cold outreach

## Rules
- This runs every HOUR, not every 4 hours — speed matters
- Max 2 fast-track actions per run (don't blow daily limits)
- Never DM someone who just had an incident — engage publicly first, DM later
- If nothing hot found, update state.json and exit silently
```

## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-04-09 12:58 PM MDT

## Active Right Now
- **Mode:** Week 5 Sprint — Outreach & Polish V2 (Apr 9–15)
- **Sprint Goal:** 10 active external installations + Product Hunt launch.
- **Outreach Drought:** Day 48. 🔴 CRITICAL. Zero installs. Signer Decision required.
- **Onboarding status:** OPTIMIZED (Branded zero-auth landing page + headless provisioning).

## P0 — Requires Action Today

### 🔴 ROD ACTION REQUIRED
- **OUTREACH DROUGHT (Day 48)** — Stale drafts pending >24h:
    - `idea-092` (Sycamore/Sri Viswanath)
    - `Trent AI Outreach` (Eno Thereska)
- **Signer Decision** — Approve/Deny Sycamore draft (Day 48 stall).
- **Loom Recording** — Script provided in #wedges. Ready to record on `demo-repository`.
- **Homepage Review** — Final site branch `feat/consequence-engine-site` ready for review.

### Charles (READY to execute)
- **Site Deploy** — Push `feat/consequence-engine-site` once Rod approves.
- **Outreach Send** — Ship Sycamore/Trent AI once Loom is done.
- **Merge PR #328** — Success page latest repo fix (needs Rod PP approval).
- **Merge PR #327** — Always-comment fix (needs Rod PP approval).
- **Merge PR #326** — Surgical comment update (needs Rod PP approval).
- **Merge PR #325** — Receipt page redesign & logo fix (needs Rod PP approval).
- **Merge PR #324** — Branded success page & emoji fix (needs Rod PP approval).
- **Merge PR #323** — Activation setup PR skip (needs Rod PP approval).

## BLOCKED (needs Rod)
- **idea-092** — Sycamore/Sri Viswanath outreach (approval pending — Day 48)
- **idea-098** — Trent AI/Eno Thereska outreach (approval pending — Day 48)
- **idea-085** — PostHog/Stripe conversion audit (GA4 token expired)
- **idea-082** — X API write permissions (tier upgrade)
- **idea-086** — Paperclip port 3100 on pp-scout-sfo2 (SSH needed)

## Backlog
- **idea-042** — Actionable error UX: every error has a fix path (M)
- **idea-080** — Fix PostHog generic event names (S)
- **idea-084** — MCP Guard v0.2 spec (M)

## Recent Decisions
- (Apr 8) Consequence Engine SHIPPED. 5-day sprint compressed into 1 day.
- (Apr 8) Denied status = hard stop (no authorize button). Path: fix code.
- (Apr 8) Per-repo comment quieting. First 5 cleared PRs comment, then silent.
- (Apr 7) Critical Fix Pattern established: every high-impact bug fix requires a persistent monitoring script and a daily cron.

## Recently Shipped
- Consequence Engine (Engine, Router, Routing, Receipts, Design v2) ✅
- PR #314: Launch alerts ✅
- Onboarding smoke test script ✅
- PKCS#8 GitHub App auth fix ✅
```

## Recent Memory
Path: /Users/moltbot/.openclaw/workspace/memory/2026-04-04.md

```
# Saturday, April 4, 2026

## Heartbeat Checks
- **System Health**: Alerted on persistent `mobile-qa-daily` (5 errors) and `memory-consolidation` (3 errors, Discord channel issue).
- **Discord Config Drift**: Multiple cron jobs failing with `Unsupported channel: discord`. Needs audit.
- **Thread Hygiene**: Nudged `GIF VIDEO - OPUS` (1485726442888233136) — idle >9 days.
- **Factory Pipeline**: Reconciled `ideas.jsonl`. 18 active items, 0 reconciled, 0 stuck.

## Factory Error Sensor Run
- **Action**: Ran `bash ~/.openclaw/workspace/factory/scripts/error-sensor.sh`.
- **Result**: Polled Sentry (`permission-protocol/javascript-nextjs`) for new runtime errors.
- **Outcome**: No unresolved issues found in the last 24h. 0 new bounties created in `factory/ideas.jsonl`.

## Daily Planning (8:20 AM MDT)
- **Sprint Status**: Week 3 sprint (Mar 29–Apr 4) closes TODAY. Sprint retro + Week 5 planning is the primary task.
- **Primary Focus**: idea-093 (sprint retro), idea-087 (Week 4 decision brief), idea-079 (Week 1 changelog).
- **Waiting on Rod**: idea-085 (PostHog approval count + Stripe conversions), idea-088/089 sprint goal verification.
- **BLOCKED items unchanged**: idea-082 (X API), idea-086 (Paperclip port), idea-092 (Sycamore pitch).
- **Next up after retro**: idea-094 (Product Hunt launch prep) transitions to ACTIVE.
- **Ideas updated**: Stamped Apr 4 notes on idea-085, idea-087, idea-088, idea-089, idea-093, idea-094.

## Memory Consolidation Run (10:15 AM MDT)
- **MEMORY.md updated**: Integrated 2026-04-03 learnings (Onboarding Activation, Prompt Caching, Authority Route) and 2026-04-04 insights (Discord Config Drift, Sprint Close).
- **STATUS.md cleaned**: Removed shipped PR context from "Active Right Now" in `pp-os/STATUS.md` (redundant with "Recently Shipped").
- **SESSION-STATE.md cleared**: Archived stale state (was already cleared from previous run) and reset for today.
- **Discord Report**: Sent summary to #daily-log.

## Heartbeat Update (11:00 AM MDT)
- **System Health Alert**: `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) are persistent.
- **Provider Issue**: Widespread `Unsupported channel: discord` errors in cron jobs indicate a systemic Discord integration failure. `scripts/discord-health-check.sh` confirms "stuck awaiting gateway readiness." Needs audit/restart.
- **Thread Hygiene**: `GIF VIDEO - OPUS` (id: 1485726442888233136) remains idle for >9 days.
- **Board Status**: PP Product Board "Ready" queue is empty.

## Heartbeat Update (2:00 PM MDT)
- **Persistent Alerts**: `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) remain unresolved.
- **Discord Provider Block**: Systemic failure across multiple cron jobs reporting `Unsupported channel: discord`.
- **Thread Health**: `GIF VIDEO - OPUS` (1485726442888233136) is still ACTIVE/Idle (>9 days).
- **Factory Pipeline**: Reconciled `ideas.jsonl`. 18 active items, 0 reconciled, 0 stuck.

## Heartbeat Update (4:00 PM MDT)
- **Alerts**: `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) are still persistent.
- **Provider Drift**: `Unsupported channel: discord` continues across several cron jobs.
- **Thread Hygiene**: `GIF VIDEO - OPUS` (id: 1485726442888233136) remains idle (>9 days).
- **Board Status**: PP Product Board "Ready" queue is empty.

## Heartbeat Update (4:49 PM MDT)
- **System Health**: No change. `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) persistent.
- **Provider Status**: Systemic Discord failure continues (`Unsupported channel: discord`).
- **Factory Pipeline**: Reconciled `ideas.jsonl`. 18 active items, 0 reconciled, 0 stuck.

## Heartbeat Update (8:05 PM MDT)
- **Persistent Errors**: `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) remain unresolved.
- **Provider Status**: Multiple cron jobs still failing with `Unsupported channel: discord`.
- **Thread Health**: `GIF VIDEO - OPUS` (1485726442888233136) is still ACTIVE/Idle (>9 days).
- **Factory Pipeline**: Reconciled `ideas.jsonl`. 18 active items, 0 reconciled, 0 stuck.

## Heartbeat Update (9:05 PM MDT)
- **Status Summary**: Persistent alerts on `mobile-qa-daily` and `memory-consolidation`.
- **Discord Provider**: Widespread `Unsupported channel: discord` errors indicate a systemic issue.
- **Project Hygiene**: `GIF VIDEO - OPUS` thread (1485726442888233136) remains idle (>9 days).
- **Board Status**: PP Product Board "Ready" queue is empty.
- **Factory Pipeline**: Reconciled `ideas.jsonl`. 18 active items, 0 reconciled, 0 stuck.

## Heartbeat Update (10:05 PM MDT)
- **Health Snapshot**: `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) persistent.
- **Process Health**: `Unsupported channel: discord` warnings continue for scorecard and factory QA jobs.
- **Continuity**: No new Ready items on PP Product Board. Pipeline reconciled (18 active).

## Heartbeat Update (8:05 PM MDT)
- **Attention**: `mobile-qa-daily` (6 errors) and `memory-consolidation` (4 errors) persistent.
- **Discord Provider**: Multiple cron jobs reporting `Unsupported channel: discord`. Systemic issue.
- **Thread Hygiene**: `GIF VIDEO - OPUS` (id: 1485726442888233136) is ACTIVE/Idle (>9 days).
- **Board Status**: Ready queue empty.
- **Factory**: Reconciled ideas.jsonl (18 active).

## Hotline Scan Correction (5:02 PM MDT / 2026-04-04T23:02:09Z)
- **Action**: Re-ran the unified hotline scan and re-validated live web/HN signals against strict hotline timing rules.
- **Outcome**: No fresh score-5 trigger. No new Permission Protocol mention, no named AI-agent breach inside the 6-hour window, no >$10M agent-company funding round inside the 24-hour window, and no HN agent-security story above 50 points.
- **Correction**: Downgraded the Nicholas Carlini / FreeBSD exploit from fresh fast-track to watch-only because the underlying publication dates back to Mar 31 / Apr 1 and does not qualify as a new April 4 hotline trigger.
- **Carry-forward**: Sycamore remains the active lead pending Rod approval. Outbound blockers unchanged: X API write permissions and HN login.

## Nightly Self-Improvement Run (11:55 PM MDT)
- **Discord Provider**: Diagnosed systemic failure as a plugin initialization hang. Created health check script.
- **Scan Logic**: Added temporal verification to Hotline Scan to prevent stale story triggers.
- **Project Hygiene**: Archived idle 'GIF VIDEO - OPUS' thread.
- **Process Change**: Authorized self to promote S/M backlog items when Ready queue is empty.
```

## Yesterday's Memory
Path: /Users/moltbot/.openclaw/workspace/memory/2026-04-03.md

```
# Friday, April 3, 2026

## Technical Work
- **Onboarding Flow Fix**: Identified and resolved a critical dead-end in the Permission Protocol onboarding. The "Set up deploy gate" button was redirecting to a GitHub Actions template search (`actions/new?category=security&query=permission-protocol`) that returned 0 results. 
- **Direct File Creation**: Patched `src/app/install/complete/page.tsx` in `permission-protocol-repo` to instead use GitHub's direct file creation URL (`/new/main?filename=.github/workflows/deploy-gate.yml&value=...`) with a pre-populated V2 YAML template.
- **PR Created**: Opened [PR #288](https://github.com/permission-protocol/app/pull/288) with the fix.
- **Dedicated Approval Page**: Built the new `/approve/:id` route from scratch using a chromeless layout. 
- **PR Created**: Opened [PR #300](https://github.com/permission-protocol/app/pull/300) with 1,400+ lines of code and updated all entry points (Slack, GitHub comments, link builders).

## Insights
- **Don't depend on GitHub Marketplace/Registry for onboarding**: Registry indexing is opaque and unreliable for new products. Direct file creation URLs provide a 100% success rate for initial setup.
- **Visual Evidence in QA**: Screenshots from the user (greenlian00) were critical in identifying the "Found 0 workflows" dead-end that was otherwise invisible in backend logs.
- **Authority > Dashboard**: A signer arriving from GitHub is in a "decide" mindset, not an "explore" mindset. Removing the app chrome reduces cognitive load and increases the perceived authority of the signing act.
- **Moat is the Payload**: Showing the exact execution payload (`deploy_code`) makes the cryptographic nature of the signature undeniable. It's not just a "green checkmark," it's a signed authorization.

## Strategic Work
- **API Burn & Cache Audit**: Analyzed March's $5,300 API spend. Identified ~50% waste ($2,150+) in Anthropic costs due to redundant prefix re-caching of 60k+ tokens.
- **Root Cause**: A dynamic `userTime` timestamp was being injected *above* the cache boundary in the OpenClaw prompt prefix, causing a 100% cache-miss rate.
- **Verification Proof**: Ran a 5-call test hitting `claude-sonnet-4-6` with the dynamic time moved **below** the `cache_control` breakpoint. Confirmed 100% cache hits on repeated calls and a ~400ms reduction in response latency.
- **Patch Proposed**: Splitting the system prompt assembly in the OpenClaw adapter to separate the large stable `stablePrefix` (cached) from the `dynamicContext` (uncached).
- **Focused Authorization Flow**: Defined and spec'd a new chromeless authorization route (`/approve/:id`) to replace the dashboard-embedded review flow. The goal is to maximize "authority signal" while minimizing "dashboard noise."

## Next Steps
- Apply the OpenClaw source patch and restart the gateway to finalize the cache fix.
- Investigate `mobile-qa-daily` cron errors (5 consecutive failures).
- Review `1485726442888233136` (GIF VIDEO - OPUS) for final end card from Rod.
- Unified hotline scan rerun at 1:02 PM MDT: no new score-5 triggers. No fresh Permission Protocol mention, no named AI-agent breach inside the 6-hour window, no >$10M agent funding inside 24 hours, and no HN agent-security story above 50 points. Microsoft Agent Governance Toolkit remains a watch signal, not an immediate-action event. Sycamore stays the only carry-forward fast-track lead, still blocked on Rod approval. X API write and HN login remain the outbound blockers.
- **Thread:** #rc-main › Separate demo mode (1487892319309926563)
- **Duration:** Mar 29 – Apr 3 (5 days)
- **Outcome:** Complete self-contained demo mode across 3 repos. 6-screen interactive demo, terminal emerald design, responsive desktop, /demo/start entry, demo-first homepage rewrite, public /install/complete removing auth wall. 14+ PRs merged.
- **Key decisions:** Static fixture, Space Grotesk design system, client-side nav, /demo/start with src params, text-first hero, public install flow via App JWT.

### Thread Archived: Pricing
- **Thread:** #rc-main › Pricing (1488935930277662991)
- **Duration:** Apr 3 (same day)
- **Outcome:** Redefined PP activation metric. Activation = blocked → sign → receipt (not install). Hello World auto-PR is Priority 1 build. Reddit warmup strategy with seed comments drafted. Teardown analysis of full funnel with two-phase commit sequencing identified.
- **Key decisions:** Kill /new/main hack, two-phase activation (gate YAML → test PR), contents:write permission upgrade needed, teammate = monetization trigger, Reddit comment-first strategy.

### Thread Archived: Design.md
- **Outcome:** Created the initial `DESIGN.md` for Permission Protocol based on the "Sovereign Logic" strategy document.
- **Decisions:** Enforce the Obsidian/Emerald, Glass & Gradient, and Editorial Brutalism aesthetic for AI agents generating UI.

## 2026-04-03 — Onboarding Activation Overhaul
- **The Build**: Completely rewrote the Permission Protocol onboarding flow across a 7-PR sprint, removing the brittle /new/main GitHub hack and replacing it with a deterministic, server-orchestrated "Hello World" loop.
- **The Sequence**: 1) App Installation -> 2) Control Room Handshake -> 3) Engine idempotently opens Setup PR -> 4) Webhook listens for Setup PR merge -> 5) Engine automatically fires Verification PR -> 6) Verification PR blocks, demanding a signature.
- **Key UX Moat**: Used the GitHub Commit Status API (`statuses:write`) to inject our "Blocked. Awaiting signature" natively into the Verification PR, making the governance primitive visible to the entire engineering team immediately upon install.
- **Telemetry**: Added full server-side PostHog telemetry to track funnel progression (e.g., `installation_verified`, `setup_pr_opened`, `action_request_generated`, `first_receipt_signed`) and calculate time-to-value deltas (`t_system_setup`, `t_user_full`).
- **Hotfix Learnings**: 1) GitHub App User Tokens vs OAuth Tokens: The `/user/installations` endpoint requires a true GitHub App User Token. To bypass this for NextAuth OAuth users, we now fetch the installation via the App JWT and verify ownership via `/user/orgs`. 2) Idempotency is critical for state machines: If a user encounters an error in step 1, the `startActivationAttempt` lock must be resumable so they aren't permanently stuck with an old error message.
```

## Scout State
Command: `sed -n '1,220p' "/Users/moltbot/.openclaw/workspace/pp-os/scout/state.json"`

```
{
  "last_research_run": "2026-03-08T02:00:00Z",
  "last_hotline_run": "2026-04-09T15:06:58Z",
  "last_outreach_run": "2026-03-07T15:00:00Z",
  "last_response_check": "2026-03-07T23:00:00Z",
  "last_signal_count": 0,
  "fast_tracked_this_run": 0,
  "pending_approvals": [
    "lio-ai-email",
    "email-lio-vlad-keil",
    "meta-sev1-reachout-strategy",
    "interloom-founder-outreach",
    "sycamore-sri-viswanath-linkedin",
    "nicholas-carlini-dm",
    "trent-ai-eno-thereska-linkedin"
  ],
  "blocked": {
    "tweet_write": {
      "issue": "X API 403 Forbidden on create_tweet \u2014 app missing write permissions",
      "fix": "developer.twitter.com \u2192 App settings \u2192 User auth settings \u2192 enable Read+Write \u2192 regenerate access tokens \u2192 update ~/.openclaw/secrets/x-pp-api.json",
      "affected": [
        "tweet-reply-2029949555169710488 (regtech/kill-switch, @MelodyLishuo)",
        "tweet-reply-2029982761310732480 (@DavidElze, 7th layer governance)",
        "tweet-reply-2030008301334016474 (@Absolcasso, bi-directional receipt / response poisoning)",
        "tweet-reply-2030013150754373637 (@EUAIACTGUY, 3rd reply \u2014 game-day drills) \u2014 SEND THIS ONE FIRST",
        "tweet-reply-2030028270549295248 (@wickedpands, dynamic capability-based auth / 'why' framing)",
        "tweet-reply-mit-study-2026-03-06 (MIT study original tweet)",
        "tweet-reply-al-grigor-db-wipe-2029889772181934425 (SCORE 5, 2.4M impressions \u2014 SEND URGENTLY)",
        "tweet-reply-bitcoinnewscom-alibaba-2026-03-07 (SCORE 5, Alibaba Cloud rogue agent \u2014 spreading)",
        "tweet-reply-absolcasso-response-layer-2030087847471141006 (response layer poisoning)"
      ],
      "flagged": "2026-03-06T17:05Z",
      "re-flagged": "2026-03-07T03:00Z",
      "status": "X API fix is #1 operational blocker."
    }
  },
  "auto_sent_this_run": [],
  "open_leads": [
    "lio-ai",
    "interloom",
    "sycamore",
    "nicholas-carlini",
    "trent-ai"
  ],
  "hn_queue": [
    "hn-comment-ietf-aiagent-auth-47262775 (IETF RFC draft, PP-adjacent, needs HN login)"
  ],
  "watching": [
    "permit.io",
    "cisco-ai-defense-skill-scanner",
    "oculi-security",
    "orchesis",
    "oath-protocol",
    "grantex",
    "agentseal"
  ],
  "notes": "2026-04-09 15:06Z hotline scan: no actionable hotline trigger validated. Fresh web recency checks plus local state review did not validate any new Permission Protocol mention, named AI-agent breach inside the 6-hour window, new >$10M agent-company funding round for an agent company inside the 24-hour window, or HN agent-security/authorization story above 50 points. Nava's $22M round was published Apr 09, 2026 09:45:46 AM IST (2026-04-09T04:15:46Z), which is inside 24 hours but does not qualify as an agent-company trigger; Sycamore and Trent AI remain aged out of the strict hotline window. Direct shell fetches to X/HN remain blocked by network resolution in this environment, so hotline validation relied on available web recency checks, the ignore log, and timestamp cross-checks. Existing outbound blockers still halt blocked channels: X API write access is blocked and HN login is unavailable. Rod approval is still required before any Trent or Sycamore outbound."
}
```

## Recent Hotline Signals
Command: `python3 -c "from datetime import date; from pathlib import Path; p = Path('/Users/moltbot/.openclaw/workspace/pp-os/scout/signals') / f'{date.today().isoformat()}.jsonl'; print(p.read_text() if p.exists() else '[]')"`

```
[]
```

