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
# PP Status — Last Updated: 2026-04-02 8:20 AM MDT

## Active Right Now
- **Mode:** Week 4 (FINAL sprint week) — **Apr 4 deadline is 2 DAYS AWAY**
- **Sprint Goal:** 5 external users with deploy-gate installed + 1 complete loop
- **Pricing Redesign:** ✅ COMPLETE — 4-tier pricing (Free, $79, $299, Enterprise) live.
- **Mobile UX:** ✅ COMPLETE — PR #284 merged Apr 1. Sticky action bar + VerdictBanner polish.
- **Demo Polish:** ✅ COMPLETE — PR #285 merged Apr 1. Progress indicators + speed copy.

## ACTIVE Ideas (in-flight, do today)
- **idea-085** — Demo PR approval count audit (URGENT — Rod: query PostHog/PP DB + Stripe)
- **idea-087** — Week 4 decision brief (OVERDUE — write after idea-085 data, 2 days left)
- **idea-088** — 5 external users (primary sprint goal — HN follow-up, Discord, alumni)
- **idea-089** — First complete loop user (secondary — monitor non-PP orgs in PP app)

## BLOCKED (needs Rod)
- **idea-082** — X API write permissions (needs Rod: upgrade X Dev account tier)
- **idea-086** — Paperclip port 3100 (needs Rod: SSH into pp-scout-sfo2)
- **idea-092** — Sycamore/Sri Viswanath LinkedIn pitch (needs Rod approval to send)

## Backlog Ready (priority order)
1. **idea-042** — Actionable error UX (M-size)
2. **idea-079** — Week 1 changelog (HN feedback, S-size)
3. **idea-080** — PostHog event names (S-size)
4. **idea-083** — Mobile Safari SameSite cookie fix (S-size)
5. **idea-030** — AI-Generated Code Summary (M-size)
6. **idea-002** — Blast radius indicator (M-size)
7. **idea-084** — MCP Guard v0.2 spec (M-size)
8. **idea-081** — PullMatch viral loop feature (M-size)

## Key Decisions & Recent
- **4-Tier Pricing:** $0 / $79 / $299 / Custom. Optimized for "Buyer" segmentation.
- **Mobile Density:** ~30% reduction in vertical rhythm shipped.
- **Demo UX:** Zero-friction static demo is core wedge. No DB, <1s LCP.
- **Apr 4 deadline:** Final decision point — double down, feature pivot, or channel pivot.
```

## Heartbeat Rules
Path: /Users/moltbot/.openclaw/workspace/HEARTBEAT.md

```
# HEARTBEAT.md

## Step 0: Deterministic Health Check (ALWAYS RUN FIRST)
```bash
bash ~/.openclaw/workspace/scripts/heartbeat-check.sh
```
- If `status: "clear"` → skip to PP Board check, then HEARTBEAT_OK if nothing in Ready queue
- If `status: "watch"` → note warnings but don't alert unless persistent (3+ consecutive)
- If `status: "attention"` → alerts need action, report to Rod immediately
- **This replaces manual model health checks, gateway checks, and cooldown checks**

## PP Product Board — Ready Queue
Check `Ready` column in [PP Product](https://github.com/orgs/permission-protocol/projects/1):
```bash
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh api graphql -f query='
query {
  organization(login: "permission-protocol") {
    projectV2(number: 1) {
      items(first: 50) {
        nodes {
          id
          fieldValueByName(name: "Status") {
            ... on ProjectV2ItemFieldSingleSelectValue { name }
          }
          content {
            ... on DraftIssue { title body }
            ... on Issue { title number }
          }
        }
      }
    }
  }
}'
```
- If items in "Ready" status → execute them, move to "In Progress", then "Done"
- Report what was completed

## Daily Work Capture (Every 3rd Heartbeat)
Increment counter in `memory/heartbeat-state.json`. If `dailyCaptureCounter % 3 == 0`, check if significant work happened since last documentation:

**Strategic Work:**
- Major planning sessions or decisions
- New systems or processes designed
- Strategic pivots or insights
- Roadmap changes or prioritization

**Technical Work:**  
- Major implementations or launches
- Problem-solving breakthroughs
- System fixes or improvements
- New integrations or components

**If significant work occurred:**
- Update `memory/YYYY-MM-DD.md` with:
  - **What:** Key accomplishments and decisions
  - **Why:** Strategic importance and impact
  - **Insights:** Lessons learned or breakthroughs
  - **Next:** Follow-up actions or next steps
- Update `lastDailyCapture` in `memory/heartbeat-state.json`

**Otherwise:** Continue with normal heartbeat checks.

## Thread Health Check (Discord Ops)
Scan `ops/threads.yaml` for thread hygiene:

```bash
cat ~/.openclaw/workspace/ops/threads.yaml
```

**Check for:**
1. **Idle threads:** Any thread with `status: ACTIVE` and `updated_at` >72h ago → post nudge in-thread:
   ```
   💤 This thread has been quiet for <N> days.
   Current state: <summary>
   Open tasks: <count>
   Should we: continue | park it | /close-review?
   ```
   Max one nudge per thread per 72h. Track in `memory/heartbeat-state.json` under `threadNudges: { "<thread_id>": "<last_nudge_iso>" }`.

2. **Thread health digest:** If any threads need attention (idle, blocked, or ready to archive), post to `#daily-log` (1479273618876792893):
   ```
   🧵 Thread Health — <date>
   Active: <N> | Parked: <N> | Blocked: <N>
   Idle >72h: <N> ⚠️
   Ready to archive: <N>

   Needs attention:
   - "<title>" — idle <N> days, <N> open tasks
   ```
   Only post if there's something worth reporting. Silent otherwise.

3. **Status drift:** If a thread's Discord activity contradicts its YAML status (e.g., marked PARKED or BLOCKED but has new messages), update the YAML status.

## Factory Pipeline Health

### Auto-Reconcile (run every heartbeat)
```bash
bash ~/.openclaw/workspace/factory/scripts/reconcile.sh
```
- Cross-references `ideas.jsonl` against merged GitHub PRs
- Auto-marks merged factory ideas as `done`
- Flags stale items (qa-passed >48h, build-ready >7d, build-failed >48h, prd-wip >7d)
- If `changes > 0`: report what was reconciled
- If `warnings > 0`: report stale items that need attention

### Stuck Item Check
Check `factory/ideas.jsonl` for stuck items. Use `updated_at` timestamps vs current time.

```bash
python3 -c "
import json, datetime
now = datetime.datetime.utcnow()
stuck = []
for line in open('$HOME/.openclaw/workspace/factory/ideas.jsonl'):
    idea = json.loads(line.strip())
    status = idea.get('status','')
    updated = datetime.datetime.fromisoformat(idea['updated_at'].replace('Z','+00:00')).replace(tzinfo=None)
    age_h = (now - updated).total_seconds() / 3600
    thresholds = {'build-wip': 2, 'qa-wip': 1, 'prd-wip': 48, 'build-ready': 24}
    if status in thresholds and age_h > thresholds[status]:
        stuck.append({'id': idea['id'], 'status': status, 'hours': round(age_h,1), 'title': idea['title'][:50]})
for s in stuck: print(json.dumps(s))
"
```

**Actions by status:**
| Status | Threshold | Action |
|---|---|---|
| `build-wip` | > 2h | ⚠️ Alert `#factory-pipeline` — stuck build, may need manual intervention |
| `qa-wip` | > 1h | ⚠️ Alert — QA should never take >1h with timeout wrappers |
| `prd-wip` | > 48h | 💤 Post nudge in WIP thread (via thread-map.json) — continue or park? |
| `build-ready` | > 24h | ℹ️ Remind Rod in `#factory-pipeline` — PR waiting for review |

- **Max 1 alert per idea per heartbeat cycle** — don't spam
- If no stuck items and no ideas updated in 8+ days → factory cron may be dead, alert Rod

## Quick Health Check
- If any cron jobs show repeated failures → alert
- Run `./scripts/health-check.sh` weekly (Sunday heartbeats)
- If cooldown detected → alert Rod immediately
- Otherwise: HEARTBEAT_OK

## Transcript Archive (Sunday Heartbeats)
Archive new session transcripts and clean orphans:
```bash
./scripts/archive-transcripts.sh --clean
```
- Incrementally archives only NEW transcripts since last run
- Pushes compressed archive to GitHub backup repo
- Cleans orphan transcripts from disk (frees space)
- If push fails → alert Rod

## Memory Curation (Sunday Heartbeats)
Weekly review and curation of accumulated knowledge:
- Review past week's `memory/YYYY-MM-DD.md` files
- Extract strategic insights and lessons for `MEMORY.md`
- Archive completed projects and decisions
- Update processes based on learnings
- Clean up outdated information
- Update `lastMemoryCuration` in `memory/heartbeat-state.json`

## Evolution Backup (Daily)
- Run `./scripts/backup-evolution.sh` once per day
- Keeps GitHub backup current with my growth
- If backup push fails → alert Rod (needs auth fix)
- Critical for disaster recovery (Mac destruction scenario)
```

## Heartbeat Check
Command: `bash "/Users/moltbot/.openclaw/workspace/scripts/heartbeat-check.sh"`

```
{
  "status": "attention",
  "alerts": [
    "cron:mobile-qa-daily - 3 consecutive errors: ?? ?? Message failed"
  ],
  "warnings": [
    "cron:unified-hotline - 2 error(s): Unsupported channel: discord",
    "cron:factory-build-qa - 1 error(s): Unsupported channel: discord",
    "cron:memory-consolidation - 1 error(s): Unsupported channel: discord",
    "cron:nightly-self-improvement - 1 error(s): Unsupported channel: discord",
    "cron:weekly-transcript-archive - 1 error(s): Unsupported channel: telegram",
    "cron:weekly-scorecard - 1 error(s): Unsupported channel: discord"
  ],
  "cron_errors": 7,
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
 m Xdares
 M company-os/governance/approval-log.jsonl
 M company-os/governance/drift-log.jsonl
 M company-os/governance/snapshots/gov_scan_latest.json
 M factory/.last_sentry_scan
 M factory/ideas.jsonl
 M goals/xdares-seo-growth/state.json
 M logs/crons/daily-briefing.log
 M logs/crons/execute-ready.log
 M logs/crons/unified-hotline.log
 m mcp-guard
 M ops/threads.yaml
 M ops/threads_manager.py
 M permission-protocol-repo
 M pp-os/STATUS.md
 M reports/cron-runs/daily-briefing/latest.json
 M reports/cron-runs/daily-briefing/latest.md
 M reports/cron-runs/execute-ready/latest.json
 M reports/cron-runs/execute-ready/latest.md
 M reports/cron-runs/unified-hotline/latest.json
 M reports/cron-runs/unified-hotline/latest.md
?? .learnings/2026-03-29.md
?? .learnings/2026-03-30.md
?? .learnings/2026-04-01.md
?? company-os/governance/snapshots/gov_scan_20260329_1300.json
?? company-os/governance/snapshots/gov_scan_20260330_1300.json
?? company-os/governance/snapshots/gov_scan_20260401_1300.json
?? company-os/governance/snapshots/gov_scan_20260402_1300.json
?? deploy-gate/
?? logs/crons/codex-issue-264.log
?? logs/crons/weekly-scorecard.log
?? memory/2026-04-02.md
?? permission-protocol/app/
?? pp-demo/
?? pp-os/master-log/2026-04-02.md
?? reports/cron-runs/daily-briefing/20260329T143019Z/
?? reports/cron-runs/daily-briefing/20260330T143020Z/
?? reports/cron-runs/daily-briefing/20260330T143109Z/
?? reports/cron-runs/daily-briefing/20260401T143002Z/
?? reports/cron-runs/daily-briefing/20260401T143020Z/
?? reports/cron-runs/daily-briefing/20260402T143007Z/
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
?? reports/cron-runs/weekly-scorecard/
```
