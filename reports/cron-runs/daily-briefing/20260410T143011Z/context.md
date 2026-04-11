## Focus
Path: /Users/moltbot/.openclaw/workspace/FOCUS.md

```
# FOCUS.md — 28-Day Sprint Filter

**Period:** March 8 → April 4, 2026  
**Single wedge:** AI coding agents (Codex, Cursor, Claude Code) deploying code **without Permission Protocol**

---

## The Question

Before doing ANY task, ask:

> **"Does this directly help AI coding agents use Permission Protocol's deploy-gate?"**

If no → it's paused. If yes → do it.

---

## Success Criteria

- 5+ external users with deploy-gate installed
- 1+ completing the full flow (install → request → approve → deploy)

---

## In Scope

- Deploy-gate product (webhook, review surface, API)
- Demo video of the deploy-gate flow
- Dogfooding on PP + Xdares repos
- Finding + onboarding design partners (AI agent users, devs)
- GitHub App for one-click repo connection (Phase B)
- Show HN post (Week 3)

## Out of Scope (Paused)

- Scout pipeline / outreach to general founders
- Marketing content, social posting (unless directly about deploy-gate)
- Xdares SEO / blog publishing
- Any new features unrelated to deploy-gate
- Brand polish, website redesign, etc.

---

## Week Plan

| Week | Focus |
|------|-------|
| 1 (Mar 8-14) | Deploy-gate perfection + demo video + dogfood on our repos |
| 2 (Mar 15-21) | Find 10 potential users, get 3 to try. Design partner deadline. |
| 3 (Mar 22-28) | Iterate on user feedback. Show HN. |
| 4 (Mar 29-Apr 4) | 5+ active users. Decision: double down or pivot. |

---

## Paused Crons (13 total)

scout-response-monitor, scout-delivery, scout-followup, scout-outreach-draft, scout-research, scout-active-learning, scout-campaign-monitor, marketing-publisher, marketing-engagement-monitor, marketing-content-draft, marketing-active-learning, unified-engagement

---

_Created: 2026-03-07. Update weekly with sprint progress._
```

## PP Status
Path: /Users/moltbot/.openclaw/workspace/pp-os/STATUS.md

```
# PP Status — Last Updated: 2026-04-09 11:00 PM MDT

## Active Right Now
- **Mode:** Week 5 Sprint — Outreach & Polish V2 (Apr 9–15)
- **Sprint Goal:** 10 active external installations + Product Hunt launch.
- **Outreach Drought:** Day 48. 🔴 CRITICAL. Zero installs. Signer Decision required.
- **Onboarding status:** OPTIMIZED (Branded success page, headless provisioning, surgical comments).

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
- **idea-097** — Shortlist 5 warm leads + draft personalized messages.
- **idea-095** — PH hunter identification (2-3 hunters) + draft DMs.
- **idea-096** — Draft HN unban email to dang@.

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
- (Apr 9) Chad Bayer Signal: Safety > Crypto for engineering leaders.
- (Apr 9) Comment quieting removed. PP always posts a comment on every PR.
- (Apr 9) Surgical comment updates (preserve consequence brief).
- (Apr 8) Consequence Engine SHIPPED. 5-day sprint compressed into 1 day.
- (Apr 8) Denied status = hard stop (no authorize button). Path: fix code.

## Recently Shipped
- Polish V2 (PR #322-#330): Onboarding success page, headless provisioning, surgical comments, branding. ✅
- Consequence Engine (Engine, Router, Routing, Receipts, Design v2) ✅
- PR #314: Launch alerts ✅
- Onboarding smoke test script ✅
- PKCS#8 GitHub App auth fix ✅
```

## Heartbeat Rules
Path: /Users/moltbot/.openclaw/workspace/HEARTBEAT.md

```
# HEARTBEAT.md Template

```markdown
# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.
```
```

## Heartbeat Check
Command: `bash "/Users/moltbot/.openclaw/workspace/scripts/heartbeat-check.sh"`

```
{
  "status": "watch",
  "alerts": [],
  "warnings": [
    "cron:pp-os-weekly-review - 1 error(s): cron: job execution timed out"
  ],
  "cron_errors": 1,
  "gateway_processes": 1,
  "disk_usage_pct": 12,
  "cooldown": "unknown"
}
```

## Thread State Validation
Command: `python3 "/Users/moltbot/.openclaw/workspace/ops/threads_manager.py" validate "/Users/moltbot/.openclaw/workspace/ops/threads.yaml"`

```
VALID 49 threads
```

## Workspace Git Status
Command: `git -C "/Users/moltbot/.openclaw/workspace" status --short --branch`

```
## log/2026-04-09
 m Xdares
 M factory/.last_sentry_scan
 M logs/crons/daily-briefing.log
 m mcp-guard
 M memory/heartbeat-state.json
 ? permission-protocol-repo
?? reports/cron-runs/daily-briefing/20260410T143011Z/
```

