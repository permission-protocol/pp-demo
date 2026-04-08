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
# PP Status — Last Updated: 2026-04-07 8:20 AM MDT

## Active Right Now
- **Mode:** Week 5 Sprint — Distribution Push (Apr 5–11)
- **Sprint Goal:** 10 active external installations + Product Hunt launch.
- **Day 46 outreach drought:** The only thing that matters is unblocking outreach.
- **Onboarding status:** OPERATIONAL (PKCS#8 fix verified Apr 6).

## P0 — Requires Action Today

### 🔴 ROD ACTION REQUIRED
- **idea-092** — Sycamore/Sri Viswanath LinkedIn pitch is drafted and waiting approval. Day 46 at zero outreach. Approve or deny.
- **idea-085** — Re-auth GA4/Search Console tokens (expired).

### Charles (READY to execute)
- **idea-094** — Merge PR #314. Begin Product Hunt hunter identification (idea-095).
- **idea-097** — Shortlist 5 warm leads from 123-person list. Draft messages. Queue for Rod batch-approval.
- **idea-096** — Email dang@ycombinator.com re: HN account unban.

## BLOCKED (needs Rod)
- **idea-092** — Sycamore outreach (approval pending — Day 46)
- **idea-085** — PostHog/Stripe conversion audit (GA4 token expired)
- **idea-082** — X API write permissions (tier upgrade)
- **idea-086** — Paperclip port 3100 on pp-scout-sfo2 (SSH needed)

## Backlog
- **idea-030** — AI-generated code summary on approval screen (M)
- **idea-002** — Blast radius indicator on approval page (M)
- **idea-042** — Actionable error UX: every error has a fix path (M)
- **idea-080** — Fix PostHog generic event names (S)
- **idea-083** — Mobile Safari SameSite cookie fix (S)
- **idea-084** — MCP Guard v0.2 spec (M)
- **idea-081** — PullMatch viral risk profile card (M)

## Recent Decisions
- (Apr 7) ideas.jsonl created with proper state machine schema. 17 ideas tracked.
- (Apr 6) System prompt restructured (72% reduction). PKCS#8 auth fix deployed.
- (Apr 4) Sprint 3 closed. Onboarding overhaul (PR #288, #300) shipped.

## Recently Shipped
- PR #314: Launch alerts (READY to merge) ✅
- PR #309–#313: Race conditions, startup checks, logging, UX ✅
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
    "cron:Token Health Check - 1 error(s): ",
    "cron:unified-hotline - 1 error(s): cron: job execution timed out",
    "cron:memory-consolidation - 2 error(s): ?? ?? Message failed",
    "cron:nightly-self-improvement - 2 error(s): ?? ? Edit failed",
    "cron:hn-recovery-article-finder - 1 error(s): Channel is required when multiple channels are configured: telegram, discord Set delivery.channel ex",
    "cron:pp-os-weekly-review - 1 error(s): cron: job execution timed out"
  ],
  "cron_errors": 6,
  "gateway_processes": 1,
  "disk_usage_pct": 12,
  "cooldown": "unknown"
}
```

## Thread State Validation
Command: `python3 "/Users/moltbot/.openclaw/workspace/ops/threads_manager.py" validate "/Users/moltbot/.openclaw/workspace/ops/threads.yaml"`

```
VALID 46 threads
```

## Workspace Git Status
Command: `git -C "/Users/moltbot/.openclaw/workspace" status --short --branch`

```
## main...origin/main
 M ACTIVE_CONTEXT.md
 m Xdares
 M factory/.last_sentry_scan
 M logs/crons/daily-briefing.log
 m mcp-guard
 M ops/threads.yaml
 M ops/threads_manager.py
 M permission-protocol-repo
 M pp-os/STATUS.md
 M pp-os/master-log/2026-04-07.md
?? .auth/
?? .learnings/2026-03-29.md
?? .learnings/2026-03-30.md
?? .learnings/2026-04-01.md
?? company-os/governance/snapshots/gov_scan_20260329_1300.json
?? company-os/governance/snapshots/gov_scan_20260330_1300.json
?? company-os/governance/snapshots/gov_scan_20260401_1300.json
?? company-os/governance/snapshots/gov_scan_20260402_1300.json
?? company-os/governance/snapshots/gov_scan_20260403_1300.json
?? company-os/governance/snapshots/gov_scan_20260404_1300.json
?? company-os/governance/snapshots/gov_scan_20260404_1301.json
?? company-os/governance/snapshots/gov_scan_20260405_1300.json
?? company-os/governance/snapshots/gov_scan_20260406_1300.json
?? company-os/governance/snapshots/gov_scan_20260407_1300.json
?? deploy-gate/
?? e2e-failure.png
?? full_system_prompt_dump.txt
?? github-auth-fail.png
?? hn_recent.json
?? hn_top.json
?? logs/crons/codex-issue-264.log
?? logs/crons/weekly-scorecard.log
?? node_modules/.bin/playwright
?? node_modules/.bin/playwright-core
?? node_modules/@playwright/
?? node_modules/playwright-core/
?? node_modules/playwright/
?? pavan-call-prep.pdf
?? permission-protocol/app/
?? pp-call-prep.pdf
?? pp-demo/
?? pp-os/ideas.jsonl
?? pp-os/marketing/signals/2026-04-07.jsonl
?? pp-os/outreach/signals/2026-04-07.json
?? pp-outreach-final.csv
?? pp-outreach-pipeline.csv
?? pp-outreach-send-tomorrow.csv
?? pp-war-room.pdf
?? ref/
?? reports/cron-runs/daily-briefing/20260329T143019Z/
?? reports/cron-runs/daily-briefing/20260330T143020Z/
?? reports/cron-runs/daily-briefing/20260330T143109Z/
?? reports/cron-runs/daily-briefing/20260401T143002Z/
?? reports/cron-runs/daily-briefing/20260401T143020Z/
?? reports/cron-runs/daily-briefing/20260402T143007Z/
?? reports/cron-runs/daily-briefing/20260403T143006Z/
?? reports/cron-runs/daily-briefing/20260404T143001Z/
?? reports/cron-runs/daily-briefing/20260405T143002Z/
?? reports/cron-runs/daily-briefing/20260406T143004Z/
?? reports/cron-runs/daily-briefing/20260406T143031Z/
?? reports/cron-runs/daily-briefing/20260406T143218Z/
?? reports/cron-runs/daily-briefing/20260407T143007Z/
?? reports/cron-runs/daily-briefing/20260407T143048Z/
?? reports/cron-runs/execute-ready/20260329T150518Z/
?? reports/cron-runs/execute-ready/20260329T170618Z/
?? reports/cron-runs/execute-ready/20260329T190518Z/
?? reports/cron-runs/execute-ready/20260329T210518Z/
?? reports/cron-runs/execute-ready/20260329T230518Z/
?? reports/cron-runs/execute-ready/20260330T150546Z/
?? reports/cron-runs/execute-ready/20260330T170518Z/
?? reports/cron-runs/execute-ready/20260330T190517Z/
?? reports/cron-runs/execute-ready/20260330T210518Z/
?? reports/cron-runs/execute-ready/20260330T230518Z/
?? reports/cron-runs/execute-ready/20260331T170501Z/
?? reports/cron-runs/execute-ready/20260331T190503Z/
?? reports/cron-runs/execute-ready/20260331T212931Z/
?? reports/cron-runs/execute-ready/20260331T230501Z/
?? reports/cron-runs/execute-ready/20260401T150702Z/
?? reports/cron-runs/execute-ready/20260401T170502Z/
?? reports/cron-runs/execute-ready/20260401T190713Z/
?? reports/cron-runs/execute-ready/20260401T210501Z/
?? reports/cron-runs/execute-ready/20260401T230501Z/
?? reports/cron-runs/unified-hotline/20260330T150048Z/
?? reports/cron-runs/unified-hotline/20260330T190043Z/
?? reports/cron-runs/unified-hotline/20260330T230043Z/
?? reports/cron-runs/unified-hotline/20260331T190024Z/
?? reports/cron-runs/unified-hotline/20260331T230021Z/
?? reports/cron-runs/unified-hotline/20260401T150350Z/
?? reports/cron-runs/unified-hotline/20260401T190247Z/
?? reports/cron-runs/unified-hotline/20260401T230013Z/
?? reports/cron-runs/unified-hotline/20260402T150002Z/
?? reports/cron-runs/unified-hotline/20260402T190007Z/
?? reports/cron-runs/unified-hotline/20260402T230001Z/
?? reports/cron-runs/unified-hotline/20260403T150003Z/
?? reports/cron-runs/unified-hotline/20260403T190001Z/
?? reports/cron-runs/unified-hotline/20260403T230001Z/
?? reports/cron-runs/unified-hotline/20260404T150027Z/
?? reports/cron-runs/unified-hotline/20260404T190001Z/
?? reports/cron-runs/unified-hotline/20260404T230002Z/
?? reports/cron-runs/unified-hotline/20260406T150003Z/
?? reports/cron-runs/unified-hotline/20260406T190004Z/
?? reports/cron-runs/unified-hotline/20260406T230004Z/
?? reports/cron-runs/weekly-scorecard/
?? screen.png
?? system_prompt_dump.txt
?? tmp/li-post-visual.html
?? tmp/li-post-visual.png
?? tmp/mobile-qa-daily/20260402-permissionprotocol-com/
?? tmp/mobile-qa-daily/20260402-xdares-com/
?? tmp/mobile-qa-daily/20260404-permissionprotocol-com/
?? tmp/mobile-qa-daily/20260404-xdares-com/
?? tmp/pavan-call-prep.html
?? tmp/pavan-call-prep.pdf
?? tmp/pp-call-prep.html
?? tmp/pp-outreach-final-50.csv
?? tmp/pp-outreach-master-list.csv
?? tmp/pp-war-room.html
?? tmp/pp-war-room.pdf
?? tmp/system-prompt-rewrite-review.md
```
