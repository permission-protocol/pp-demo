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

### Model
- **Model:** claude-opus-4-6
- **Timeout:** 120s

### Risk if it breaks
- **Risk level:** Low
- **Blast radius:** Missing weekly review

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running

---

## PP-005 — pp-os-incident-scanner

**What it does:** Scans for AI agent incidents and security news for PP outreach hooks. Runs blogwatcher for monitored feeds. Compiles market intelligence.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 2 7 * * *` (exact — daily 7:02 AM UTC)

### Scope
- **Repos:** None
- **External services:** Web search, RSS feeds (blogwatcher)
- **Secrets used:** None

### Authority & Gates
- **Authority level:** A (read/scan only)
- **Fail-closed:** If feeds unreachable → reports partial scan

### Model
- **Model:** claude-sonnet-4-6
- **Timeout:** 120s

### Risk if it breaks
- **Risk level:** Low
- **Current status:** ERROR — timing out. Needs investigation.
- **Blast radius:** Missing market intel

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running, investigate timeouts

---

## PP-006 — pr-prescreen-auto

**What it does:** Pre-screens open PRs on Breakout-Labs. Runs every 30 min during business hours. Skips already-screened PRs.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron */30 9-18 * * 1-6` (Denver, Mon-Sat business hours)

### Scope
- **Repos:** Roca-Ventures/Breakout-Labs (read + comment)
- **External services:** GitHub API
- **Secrets used:** `github-pat-projects.txt`

### Authority & Gates
- **Authority level:** B (comments on PRs, no merges)
- **Human gate:** None — advisory comments only

### Model
- **Model:** sonnet
- **Timeout:** 600s

### Risk if it breaks
- **Risk level:** Low
- **Blast radius:** Missing PR reviews, noisy comments at worst

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running. Note: high frequency (17 runs/day) with low utility when no new PRs. Consider reducing.

---

## PP-007 — pp-daily-metrics

**What it does:** Generates daily PP metrics report from Formspree access requests and other sources. Feeds data into PP-OS planning.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 9 * * *` (exact — daily 9 AM UTC)

### Scope
- **Repos:** None
- **External services:** Formspree API
- **Secrets used:** Unknown — needs audit

### Authority & Gates
- **Authority level:** A (read metrics only)

### Model
- **Model:** sonnet

### Risk if it breaks
- **Risk level:** Low
- **Current status:** ERROR — message failures
- **Blast radius:** Missing daily metrics

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Investigate errors

---

## PP-008 — pp-linkedin-weekly

**What it does:** Generates 5 LinkedIn/Twitter posts weekly for PP authority positioning. Creates quote card images. Uploads to imgur. Schedules 3 posts to Buffer (LinkedIn + Twitter).

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 8 * * 0` (Sundays 8 AM Denver)

### Scope
- **Repos:** None
- **External services:** Buffer API (post scheduling), imgur API (image hosting), Brave Search (incident scanning)
- **Accounts:** Buffer (rodchalski LinkedIn + RodChalski Twitter), imgur (anonymous)
- **Secrets used:** `buffer-api-key.txt`

### Authority & Gates
- **Authority level:** C — **posts to public social media automatically**
- **Human gate:** ✅ Rod must approve via Telegram before posts are scheduled to Buffer. Cron generates drafts + images, sends for review, waits for explicit "schedule" command.
- **Fail-closed behavior:** If no approval received → drafts saved locally, nothing posts. If Buffer API fails → drafts saved locally, Rod notified.

### Model
- **Model:** sonnet
- **Timeout:** 120s

### Risk if it breaks
- **Risk level:** Medium
- **Primary failure modes:** Off-brand posts, embarrassing content, wrong account
- **Blast radius:** Public brand reputation (LinkedIn + Twitter)

### Observability
- **Drafts:** `goals/pp-linkedin/drafts/week-of-YYYY-MM-DD.md`
- **Published log:** `goals/pp-linkedin/published.md`
- **Alerting:** Announces to Telegram

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running. Human gate added 2026-03-02.

---

## XD-001 — goal-xdares-seo-daily

**What it does:** Daily summary of Xdares SEO growth goal executor. Reports progress, queue status, completed tasks.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 18 * * *` (daily 6 PM Denver)

### Scope
- **Repos:** None (reads local state files)
- **External services:** None
- **Secrets used:** None

### Authority & Gates
- **Authority level:** B (writes to local state files)
- **Note:** Goal executor itself has been stale since Feb 10 (budget exhausted)

### Model
- **Model:** claude-sonnet-4-6

### Risk if it breaks
- **Risk level:** Low
- **Blast radius:** Missing daily report

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running. Executor is dormant but summary is still useful.

---

## XD-002 — goal-xdares-seo-weekly

**What it does:** Comprehensive weekly review of Xdares SEO growth with metrics, wins, failures, and recommendations.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 19 * * 0` (Sundays 7 PM Denver)

### Scope
- **Repos:** None
- **External services:** None
- **Secrets used:** None

### Authority & Gates
- **Authority level:** A (read + report)

### Model
- **Model:** claude-sonnet-4-6

### Risk if it breaks
- **Risk level:** Low

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running

---

## SYS-001 — memory-curation-r1

**What it does:** Weekly memory curation via R1 on DGX Spark. Reviews recent daily memory files, extracts insights for long-term MEMORY.md.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 11 * * 0` (Sundays 11 AM Denver)

### Scope
- **Repos:** None
- **External services:** DGX Spark (R1 70B)
- **Files written:** `MEMORY.md`, `memory/*.md`
- **Secrets used:** None

### Authority & Gates
- **Authority level:** B (writes to memory files)
- **Human gate:** None — autonomous memory updates
- **⚠️ Note:** Can modify MEMORY.md which influences all future sessions

### Model
- **Model:** sonnet (orchestrator), deepseek-r1:70b (curator)
- **Timeout:** 600s

### Risk if it breaks
- **Risk level:** Low
- **Failure modes:** Bad memory curation, losing important context
- **Blast radius:** Session quality degradation over time

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running

---

## SYS-002 — qa-workload1-review

**What it does:** One-shot review of QA pipeline effectiveness after 1 week of operation.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `at 2026-03-07 10:00Z` (one-time)

### Authority & Gates
- **Authority level:** A (read-only analysis)

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep (one-shot, auto-cleans)

---

## SYS-003 — Bootstrap Receipt Reminder

**What it does:** Reminder related to bootstrap receipt. Dormant.

**Where it runs:** Mac / OpenClaw main session

**Trigger:** `cron 30 9 12 2 *` (Denver) — runs once/year

### Authority & Gates
- **Authority level:** A

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep (minimal resource use)

---

## SYS-004 — openclaw-gateway

**What it does:** Core OpenClaw gateway daemon. Routes all LLM API calls, manages sessions, handles Telegram integration.

**Where it runs:** Mac / LaunchAgent (`ai.openclaw.gateway`, PID 87628)

**Trigger:** Always-on service

### Scope
- **External services:** Anthropic API, Telegram Bot API
- **Secrets used:** Anthropic API key, Telegram bot token (via OpenClaw config)

### Authority & Gates
- **Authority level:** Infrastructure — enables all other processes
- **Human gate:** Rod manages via SSH/local access

### Risk if it breaks
- **Risk level:** High — **all autonomous processes stop**
- **Blast radius:** Total system outage

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Keep running. Recovery procedure in RECOVERY.md.

---

## SYS-005 — openclaw-node

**What it does:** OpenClaw node agent for paired device communication.

**Where it runs:** Mac / LaunchAgent (`ai.openclaw.node`, PID 21282, since Feb 22)

**Trigger:** Always-on service

### Scope
- **External services:** OpenClaw cloud relay

### Authority & Gates
- **Authority level:** Infrastructure

### Risk if it breaks
- **Risk level:** Medium — loses remote node capabilities

### Last reviewed
- **Date:** 2026-03-02

---

## SYS-006 — pp-prod-postgres

**What it does:** PostgreSQL 15 database for Permission Protocol production data.

**Where it runs:** Mac / Docker (`pp-prod-postgres`, port 5434)

**Trigger:** Always-on container (2 weeks uptime)

### Scope
- **Data:** PP production database
- **Port:** 5434 (mapped from 5432)

### Authority & Gates
- **Authority level:** Infrastructure — data store, not an actor

### Risk if it breaks
- **Risk level:** High — PP data loss
- **Blast radius:** All PP functionality

### Last reviewed
- **Date:** 2026-03-02

---

## GOV-001 — governance-integrity-check

**What it does:** Daily governance integrity check. Runs drift detection (live crons vs ledger), review SLA enforcement (auto-disables stale Authority B/C processes), and expired approval token cleanup.

**Where it runs:** Mac / OpenClaw isolated session

**Trigger:** `cron 0 7 * * *` (daily 7 AM Denver)

### Scope
- **Repos:** None
- **External services:** OpenClaw cron API (read + disable)
- **Secrets used:** None

### Authority & Gates
- **Authority level:** A (read-only analysis + auto-disable of SLA-breached processes)
- **Note:** Can disable other crons. This is by design — fail-closed enforcement.

### Model
- **Model:** sonnet
- **Timeout:** 60s

### Risk if it breaks
- **Risk level:** Low — if this breaks, governance degrades silently
- **Mitigation:** Heartbeat checks for drift-log.jsonl freshness

### Last reviewed
- **Date:** 2026-03-02
- **Decision:** Created

---

# Known Gaps & Action Items

## 🔴 Critical
1. ~~**PP-008 (LinkedIn weekly) has no human gate**~~ — ✅ FIXED 2026-03-02. Telegram approval required before scheduling.
2. ~~**Approval token minting was agent-controlled**~~ — ✅ FIXED 2026-03-02. `mint-approval-token.sh` now enforces Telegram sender verification (6091356144), file-hash-from-disk, UUID nonce, and append-only audit log. Agent cannot self-approve.
3. ~~**PP-001 (Board executor) has no token gate on PR creation**~~ — ✅ FIXED 2026-03-02. `pp-001-pr-gate.sh` now enforces token verification at PR creation boundary. Fail-closed: no token → Blocked. Indirect escalation path (PP-002 → board state) documented and mitigated.

## 🟡 Warnings
3. ~~**PP-005 (Incident scanner) in error state**~~ — ✅ DISABLED 2026-03-02. Re-enable after fix.
4. ~~**PP-007 (Daily metrics) in error state**~~ — ✅ DISABLED 2026-03-02. Re-enable after fix.
5. ~~**PP-006 (PR prescreen) runs 17x/day**~~ — ✅ REDUCED to 5x/day (9,11,1,3,5 Denver) 2026-03-02.
6. **PP-007 secrets unknown** — needs credential audit for Formspree access.

## 🟢 Improvements
7. **Drift checker script** — compare ledger vs `openclaw cron list` output, alert on unregistered processes.
8. **PP receipt integration** — Authority C processes should produce signed receipts.
9. **Credential identity audit** — every entry should name exact token/service account used.

---

# Process Template (copy for new entries)

```markdown
## PP-XXX — [name]

**What it does:**

**Where it runs:**

**Trigger:**

### Scope
- **Repos:**
- **External services:**
- **Accounts:**
- **Secrets used:**

### Authority & Gates
- **Authority level:**
- **Human gate:**
- **Fail-closed behavior:**

### Model
- **Model:**
- **Timeout:**
- **Reasoning constraints:**

### Risk if it breaks
- **Risk level:**
- **Primary failure modes:**
- **Blast radius:**

### Observability
- **Logs:**
- **Heartbeat:**
- **Alerting:**

### Last reviewed
- **Reviewed by:**
- **Date:**
- **Decision:**
- **Notes:**
```
