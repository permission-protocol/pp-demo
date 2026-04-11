You are running the daily-briefing orchestration wrapper.

Mandatory execution pattern:
1. load
2. fetch
3. validate
4. invoke agent
5. write
6. log

Write only the requested final report. Do not describe the wrapper itself.

## Job
Generate Rod's daily briefing.

## Instructions
Produce a short daily briefing with system health, active focus, and immediate actions. Use the heartbeat output and validated thread state as operational inputs. End with a single highest-leverage next step.

## Loaded Context
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
# PP Status — Last Updated: 2026-04-11 05:20 AM MDT

## Active Right Now
- **Mode:** Week 5 Sprint — Outreach & Polish V3 (Apr 9–15)
- **Sprint Goal:** 10 active external installations + Product Hunt launch.
- **Polish V3 COMPLETE:** 12 PRs (#337-#348) merged and deployed. Typography, Gradients, Radius, and Glassmorphism tightening live. ✅
- **Outreach Drought:** Day 50. 🔴 CRITICAL. Zero installs. Signer Decision required.

## P0 — Requires Action Today

### 🔴 ROD ACTION REQUIRED
- **OUTREACH DROUGHT (Day 50)** — Stale drafts pending >48h:
    - `idea-092` (Sycamore/Sri Viswanath)
    - `idea-098` (Trent AI/Eno Thereska)
- **Signer Decision** — Approve/Deny Sycamore draft (Day 50 stall).
- **Loom Recording** — Script provided in #wedges. Ready to record on `demo-repository`.
- **Homepage Review** — Final site branch `feat/consequence-engine-site` ready for review.

### Charles (READY to execute)
- **Site Deploy** — Push `feat/consequence-engine-site` once Rod approves.
- **Outreach Send** — Ship Sycamore/Trent AI once Loom is done.
- **idea-097** — Shortlist 5 warm leads + draft personalized messages.
- **idea-095** — PH hunter identification (2-3 hunters) + draft DMs.
- **idea-096** — Draft HN unban email to dang@.

## BLOCKED (needs Rod)
- **idea-092** — Sycamore/Sri Viswanath outreach (approval pending — Day 50)
- **idea-098** — Trent AI/Eno Thereska outreach (approval pending — Day 50)
- **idea-085** — PostHog/Stripe conversion audit (GA4 token expired)
- **idea-082** — X API write permissions (tier upgrade)
- **idea-086** — Paperclip port 3100 on pp-scout-sfo2 (SSH needed)

## Backlog
- **idea-042** — Actionable error UX: every error has a fix path (M) - STALE in PRD-WIP (58.0h).
- **idea-080** — Fix PostHog generic event names (S)
- **idea-084** — MCP Guard v0.2 spec (M)

## Recent Decisions
- (Apr 11) Daily capture incremented. Outreach drought hits 50 days.
- (Apr 10) Parallel Batch Pattern: 12 PRs in 3h with 11 Codex agents + worktrees.
- (Apr 9) Chad Bayer Signal: Safety > Crypto for engineering leaders.
- (Apr 9) Comment quieting removed. PP always posts a comment on every PR.
- (Apr 9) Surgical comment updates (preserve consequence brief).
- (Apr 8) Consequence Engine SHIPPED.

## Recently Shipped
- Polish V3 (Batch 1-4, PR #337-#348): DESIGN.md alignment (Typography, Gradients, Radius, Glassmorphism). ✅
- Polish V2 (PR #322-#330): Onboarding success page, headless provisioning, surgical comments, branding. ✅
- Consequence Engine (Engine, Router, Routing, Receipts, Design v2) ✅
- PR #314: Launch alerts ✅
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
    "cron:hn-recovery-article-finder - 1 error(s): cron: job execution timed out",
    "cron:pp-os-weekly-review - 1 error(s): cron: job execution timed out"
  ],
  "cron_errors": 2,
  "gateway_processes": 1,
  "disk_usage_pct": 14,
  "cooldown": "unknown"
}
```

## Thread State Validation
Command: `python3 "/Users/moltbot/.openclaw/workspace/ops/threads_manager.py" validate "/Users/moltbot/.openclaw/workspace/ops/threads.yaml"`

```
VALID 50 threads
```

## Workspace Git Status
Command: `git -C "/Users/moltbot/.openclaw/workspace" status --short --branch`

```
## log/2026-04-09
 M ACTIVE_CONTEXT.md
 m Xdares
 M company-os/governance/approval-log.jsonl
 M company-os/governance/drift-log.jsonl
 M company-os/governance/snapshots/gov_scan_latest.json
 M factory/.last_sentry_scan
 M factory/ideas.jsonl
 M logs/crons/daily-briefing.log
 M logs/crons/unified-hotline.log
 m mcp-guard
 M memory/2026-04-11.md
 M memory/heartbeat-state.json
 M ops/decisions.md
 M ops/threads.yaml
 ? permission-protocol-repo
 M pp-os/marketing/HOT-SIGNAL.md
 M pp-os/scout/system-health.log
 M reports/cron-runs/daily-briefing/latest.json
 M reports/cron-runs/daily-briefing/latest.md
 M reports/cron-runs/unified-hotline/latest.json
 M reports/cron-runs/unified-hotline/latest.md
?? .cron_list.json
?? .learnings/2026-04-10.md
?? company-os/governance/snapshots/gov_scan_20260411_1300.json
?? issues_app.json
?? pp-os/marketing/signals/2026-04-11.jsonl
?? pp-os/master-log/2026-04-11.md
?? reports/cron-runs/daily-briefing/20260410T143011Z/
?? reports/cron-runs/daily-briefing/20260411T143012Z/
?? reports/cron-runs/daily-briefing/20260411T143047Z/
?? reports/cron-runs/daily-briefing/20260411T143116Z/
?? reports/cron-runs/daily-briefing/20260411T143134Z/
?? reports/cron-runs/unified-hotline/20260410T150011Z/
?? reports/cron-runs/unified-hotline/20260410T190005Z/
?? reports/cron-runs/unified-hotline/20260410T230012Z/
```
