You are running the execute-ready orchestration wrapper.

Mandatory execution pattern:
1. load
2. fetch
3. validate
4. invoke agent
5. write
6. log

Write only the requested final report. Do not describe the wrapper itself.

## Job
Execute up to three PP Ready items.

## Instructions
Use the fetched Ready board items as the source of truth. If the queue is empty, output a short no-op report. If work exists, state which items should be executed now, which approvals still gate them, and the next action for each.

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
# PP Status — Last Updated: 2026-03-23

## Active — MCP Guard (Sprint Post-Launch)
- **v0.1 Shipped:** Stdio proxy for MCP policy enforcement live.
- **Mar 22:** HN post — "We built an MCP guardrail that blocks dangerous agent actions using a simple config file"
- **Product sentence:** "Permission Protocol decides whether AI actions are allowed to happen."
- **Next:** Receipt viewer integration and post-HN feedback loop.

## Active — PullMatch (Product Demo)
- **Launched:** PullMatch.com is live. Rebrand from "Tinder for PR" complete.
- **Mar 21 Update:** Optimized mobile landing page (SwipeDemo above fold). Wired live `/api/summarize` for real GitHub diff risk analysis.
- **Next:** Real PR card feed + real diff summarization.

## Active — Governance Framework
- **Repo live:** https://github.com/permission-protocol/governance-framework
- **Publish cadence:** Stagger blog posts 1/week.

## Parked
- Singapore localization, Sarah/Marco requirements, Factory triage.

## Recent Decisions (Mar 22)
- **Demo Scenario:** Created `deploy-multisig` scenario for `record-demo.sh` using `gh workflow run` to highlight 2-of-2 signature requirements and authoritative receipts.
- **Governance Narrative:** Adopting "Governance over Self-Policing" (Claude Code incident) as the core marketing wedge.
- **Weekly Hygiene:** Completed Sunday maintenance (archived 861 transcripts, backed up evolution).
```

## Governance Ledger
Path: /Users/moltbot/.openclaw/workspace/company-os/governance/AUTONOMOUS_PROCESS_LEDGER.md

```
# Autonomous Process Ledger

> **Rule:** No new autonomous process without a ledger entry + Rod review date.
>
> **Authority C Rule:** Any process with Authority C requires **explicit human approval** before executing the external/public action. No exceptions. Approval must be verified programmatically (approval token with content hash, expiry, and approver identity). Prompt-level instructions are not enforcement.
>
> **Review SLA:** Every Authority B/C process must be reviewed every 30 days. If `Last Reviewed` > 30 days → **auto-disabled** by governance check. Warning at 21 days. To re-enable: review the process, update Last Reviewed, then `openclaw cron edit <id> --enable`.
>
> **Drift Detection:** Daily governance check (7 AM Denver) compares live cron state vs ledger. Alerts on: unregistered processes, disabled-but-running, schedule drift, SLA breaches. Log: `company-os/governance/drift-log.jsonl`.
>
> **Governance hook:** Any process with Authority C must either produce a signed PP receipt for the action, or be hard-blocked from the action path. This is not a diary. This is governance.

> **Recursive Governance Problem (documented 2026-03-04):** GOV-001 is the process that checks all other processes. But if GOV-001 itself fails silently — Mac offline, OpenClaw crash, cron error — there is no internal mechanism to detect it. Charles cannot monitor its own monitor; that creates a closed loop with no exit.
>
> **Dead Man's Switch (GOV-001):** GOV-001 pushes a heartbeat to `Roca-Ventures/charles:governance/heartbeat.txt` after each successful daily run. An external GitHub Action (`gov-001-dead-mans-switch.yml` in `Roca-Ventures/Breakout-Labs`) checks this file every 6h and alerts if no update in 48h. The watchdog runs on GitHub's infrastructure — independent of Charles, OpenClaw, and the Mac entirely.
>
> **Invariant:** Governance of autonomous agents cannot rely solely on those agents to report their own failures. The dead man's switch is the enforcement layer for this invariant.
>
> **Current status (2026-03-04):** Heartbeat file live at `Roca-Ventures/charles:governance/heartbeat.txt`. GitHub Action YAML ready at `company-os/governance/gov-001-dead-mans-switch.yml.pending` — requires workflow-scope PAT to deploy. Pending Rod action: add `CHARLES_READ_TOKEN` secret to Breakout-Labs repo and push the workflow.

> **Token Minting Boundary (hardened 2026-03-02):** Approval tokens MUST be minted via `mint-approval-token.sh` only. The script:
> - Verifies Telegram sender ID = 6091356144 (Rod) — hardcoded, not agent-configurable
> - Computes file hash from the actual draft file (does not accept hash as parameter)
> - Generates a UUID nonce per token (prevents replay)
> - Appends every issuance to `approval-log.jsonl` (append-only audit trail)
> - Logs unauthorized mint attempts with claimed sender ID
>
> Old `approve.sh` accepted content_hash as parameter — **removed**. Any code passing a hash directly is now broken by design.

**Purpose:** Single source of truth for every autonomous process that can act (cron, timers, services, GitHub Actions, long-running agents).

**Last full audit:** 2026-03-02

---

## Authority Levels

| Level | Description | Examples |
|-------|-------------|----------|
| **A** | Read-only — can read data, no writes | Metrics collection, incident scanning |
| **B** | Internal write — can write to internal repos/db, no public actions | PR creation, board moves, memory curation |
| **C** | External/public action — can post publicly, merge PRs, deploy infra, touch user data | Social posting, PR merges, deploys |
| **D** | Prohibited — must not exist autonomously | Payment, access control changes, secret rotation |

## Risk Types

- **Embarrassment:** public posts, brand harm
- **Data loss:** deletes, schema changes, migrations
- **Financial:** payments, infra spend, ads
- **Security:** secrets, permissions, access control
- **Reliability:** outages, deploys, paging

---

# Process Index

| ID | Name | Authority | Human Gate | Risk | Runs On | Schedule | Status | Last Reviewed |
|----|------|-----------|------------|------|---------|----------|--------|---------------|
| PP-001 | pp-os-execute-ready | C | Approval for merges | High | Mac/OpenClaw | 5 9,11,13,15,17 * * * | ok | 2026-03-02 |
| PP-002 | pp-os-daily-log-and-plan | B | None | Low | Mac/OpenClaw | 3 8 * * * | ok | 2026-03-02 |
| PP-003 | pp-os-qa-review | B | None | Low | Mac/OpenClaw | 0 2 * * * | ok | 2026-03-02 |
| PP-004 | pp-os-weekly-review | A | None | Low | Mac/OpenClaw | 0 10 * * 0 (Denver) | ok | 2026-03-02 |
| PP-005 | pp-os-incident-scanner | A | None | Low | Mac/OpenClaw | 2 7 * * * | **disabled** | 2026-03-02 |
| PP-006 | pr-prescreen-auto | B | None | Low | Mac/OpenClaw | 0 9,11,13,15,17 * * 1-6 (Denver) | ok | 2026-03-02 |
| PP-007 | pp-daily-metrics | A | None | Low | Mac/OpenClaw | 0 9 * * * | **disabled** | 2026-03-02 |
| PP-008 | pp-linkedin-weekly | C | Telegram approval | Med | Mac/OpenClaw | 0 8 * * 0 (Denver) | idle | 2026-03-02 |
| XD-001 | goal-xdares-seo-daily | B | None | Low | Mac/OpenClaw | 0 18 * * * (Denver) | ok | 2026-03-02 |
| XD-002 | goal-xdares-seo-weekly | A | None | Low | Mac/OpenClaw | 0 19 * * 0 (Denver) | ok | 2026-03-02 |
| SYS-001 | memory-curation-r1 | B | None | Low | Mac/OpenClaw | 0 11 * * 0 (Denver) | ok | 2026-03-02 |
| SYS-002 | qa-workload1-review | A | None | Low | Mac/OpenClaw | at 2026-03-07 10:00Z | idle | 2026-03-02 |
| SYS-003 | Bootstrap Receipt Reminder | A | None | Low | Mac/OpenClaw | 30 9 12 2 * (Denver) | idle | 2026-03-02 |
| GOV-001 | governance-integrity-check | A | None | Low | Mac/OpenClaw | 0 7 * * * (Denver) | ok | 2026-03-02 |
| SYS-004 | openclaw-gateway | — | — | High | Mac/LaunchAgent | always-on | running | 2026-03-02 |
| SYS-005 | openclaw-node | — | — | Med | Mac/LaunchAgent | always-on | running | 2026-03-02 |
| SYS-006 | pp-prod-postgres | — | — | High | Mac/Docker | always-on | running | 2026-03-02 |

---

# Processes

## PP-001 — pp-os-execute-ready

**What it does:** Executes up to 3 items from the PP Product Board "Ready" column per run. Moves items through board statuses, creates PRs, writes code, comments on issues.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 5 9,11,13,15,17 * * *` (exact — 5x daily Mon-Sat)

### Scope: what it can touch
- **Repos:** Roca-Ventures/Breakout-Labs (write), Roca-Ventures/permissionprotocol-site (write)
- **External services:** GitHub API (issues, PRs, project board)
- **Accounts:** GitHub PAT (projects scope)
- **Secrets used:** `github-pat-projects.txt`

### Authority & Gates
- **Authority level:** C
- **Human gate (gate 1):** Items must be in "Ready" column (Rod reviews Backlog → Ready manually).
- **Human gate (gate 2 — added 2026-03-02):** PR creation requires a valid approval token issued by `mint-approval-token.sh`. Gate enforced by `pp-001-pr-gate.sh` at execution boundary (git push / PR create), not at intent stage.
- **Fail-closed behavior:** If gate denied → move item to "Blocked (Human Input Required)", notify Rod with draft hash. Do NOT create PR. Creating a draft PR is acceptable as a fallback.
- **Gate script:** `company-os/governance/scripts/pp-001-pr-gate.sh --draft-file <pr-description-file>`

### Indirect Escalation Path (documented 2026-03-02)
PP-002 (daily planner, Authority B) can add items to Backlog via board API. PP-001 executes items from Ready. The escalation path:
> PP-002 writes board state → Rod moves Backlog→Ready → PP-001 executes

**Mitigations:**
1. PP-002 scope is Backlog only — it cannot move items to Ready. Rod is the sole bridge.
2. PP-001 gate 2 (approval token) is independent of board state — a compromised PP-002 that somehow moved items to Ready would still require Rod's explicit Telegram approval.
3. Ledger review SLA: both PP-001 and PP-002 require 30-day review — stale processes auto-disabled.
4. Audit trail: all gate events logged to `approval-log.jsonl`.

### Model
- **Model:** claude-sonnet-4-6
- **Timeout:** 900s
- **Reasoning constraints:** Must announce what it's starting before doing work

### Risk if it breaks
- **Risk level:** High
- **Primary failure modes:** Bad PRs, incorrect board state, stale items stuck in progress
- **Blast radius:** Repo history + board integrity

### Observability
- **Logs:** OpenClaw cron run logs
- **Heartbeat:** Board Ready queue checked every heartbeat
- **Alerting:** Announces results to Telegram

### Last reviewed
- **Reviewed by:** Rod
- **Date:** 2026-03-02
- **Decision:** Keep running
- **Notes:** Initial ledger entry

---

## PP-002 — pp-os-daily-log-and-plan

**What it does:** Generates daily PP OS log entry with metrics (PP API, GitHub, PostHog). Plans up to 3 tasks and moves them to Backlog.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 3 8 * * *` (exact — daily 8:03 AM UTC)

### Scope
- **Repos:** Reads Breakout-Labs (no writes)
- **External services:** GitHub API, PostHog API, PP API
- **Secrets used:** `github-pat-projects.txt`, `posthog-api-key.txt`, `pp-cli-api-key.txt`

### Authority & Gates
- **Authority level:** B
- **Human gate:** Plans go to Backlog only (Rod reviews → Ready)
- **Fail-closed:** If APIs unreachable → logs partial data, continues

### Model
- **Model:** opus
- **Timeout:** 600s

### Risk if it breaks
- **Risk level:** Low
- **Failure modes:** Missing daily log, bad planning recommendations
- **Blast radius:** Planning quality only

### Observability
- **Logs:** Daily logs at `pp-os/master-log/YYYY-MM-DD.md`
- **Alerting:** Announces to Telegram

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running

---

## PP-003 — pp-os-qa-review

**What it does:** Runs standalone QA review script. Checks items in "QA Review" column, verifies acceptance criteria, uses R1 70B on DGX Spark for judgment calls. Moves items to Verified or bounces back.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 2 * * *` (exact — daily 2 AM UTC)

### Scope
- **Repos:** Roca-Ventures/Breakout-Labs (read + comment)
- **External services:** GitHub API, DGX Spark (R1 70B via Ollama)
- **Secrets used:** `github-pat-projects.txt`

### Authority & Gates
- **Authority level:** B
- **Human gate:** None — autonomous verification, but can only move to Verified (not Done)
- **Fail-closed:** If R1/Spark unreachable → flags items, doesn't auto-verify

### Model
- **Model:** claude-sonnet-4-6 (orchestrator), deepseek-r1:70b (judge)
- **Timeout:** 600s

### Risk if it breaks
- **Risk level:** Low
- **Failure modes:** False positive verification, items stuck in QA Review
- **Blast radius:** Board state accuracy

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running

---

## PP-004 — pp-os-weekly-review

**What it does:** Weekly master-plan alignment review. Reads all daily logs for the week, evaluates objective progress, checks Non-Negotiables, may recommend pivots.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 10 * * 0` (Sundays 10 AM Denver)

### Scope
- **Repos:** None (reads local files only)
- **External services:** None
- **Secrets used:** None

### Authority & Gates
- **Authority level:** A (read-only analysis)
- **Human gate:** Recommendations only — Rod decides
```

## Ready Board Items
Command: `bash "/Users/moltbot/.openclaw/workspace/scripts/board-ready-items.sh"`

```
[]
```

## Git Status
Command: `git -C "/Users/moltbot/.openclaw/workspace" status --short --branch`

```
## feature/orchestration-state-machine...origin/feature/orchestration-state-machine [ahead 4]
 m Xdares
 M company-os/governance/approval-log.jsonl
 M factory/.last_sentry_scan
 M factory/ideas.jsonl
 m mcp-guard
 M memory/2026-03-23.md
 M ops/threads.yaml
 m permission-protocol-repo
 M pp-os/scout/signals/latest-scan.json
 M pp-os/scout/state.json
 M scripts/crons/common.sh
 M scripts/crons/unified-hotline.sh
?? logs/crons/
?? pp-os/scout/signals/2026-03-23.jsonl
?? reports/cron-runs/
?? tmp/mobile-qa-daily/20260323-permissionprotocol-com/
?? tmp/mobile-qa-daily/20260323-xdares-com/
```
