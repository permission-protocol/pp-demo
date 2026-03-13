# Discord Operations System — PRD

**Author:** Charles Goldberg
**Date:** 2026-03-08
**Status:** Draft — awaiting Rod's approval

---

## Problem

Discord channels accumulate without closure. Discussions produce decisions and tasks that live only in chat. Channels multiply, go stale, and nobody archives them because there's no structured way to extract value before closing.

The root issue isn't too many channels — it's lack of topic closure.

## Design Principles

1. **Discord is the command center, not the system of record.** Decisions, tasks, and knowledge get extracted to durable storage (workspace files, git, memory). Chat is ephemeral discussion.
2. **Channels are streams. Threads are topics.** Permanent channels for always-on feeds. Threads for finite work with a lifecycle.
3. **No archive without reconciliation.** Every topic must pass a closure gate before it can be archived. No silent rot.
4. **State lives outside Discord.** Thread status, open tasks, and decisions tracked in `ops/threads.yaml` (git-backed). Discord is bad as a database — don't make it one.

---

## Server Structure

### Permanent Channels (8)

| Channel | Purpose | Bot posts? |
|---|---|---|
| `rc-main` | Daily chat, quick decisions, home base. No tag needed. | Rarely |
| `rc-product` | Product work + decisions. Threads do the heavy lifting. | Thread health digest |
| `rc-alerts` | Urgent notifications only | Yes — critical alerts |
| `rod-actions` | Rod's action queue. React ✅/❌/🔄. Max 3 pending. | Yes — action items |
| `published` | Automated log of everything posted under PP's name | Yes — publishing log |
| `daily-log` | Automated daily summaries, board ops | Yes — cron output |
| `cron-status` | Cron job results, errors, health checks | Yes — cron output |
| `charles-log` | Charles's growth log, memory curation, learnings | Yes — cron output |

### Special Channels

| Channel | Purpose | Notes |
|---|---|---|
| `archive-log` | Archive receipts posted here | Created as part of this system |
| `r1-chat` | R1 bot | Separate bot, keep as-is |

### Archive Category (📦)

Read-only holding area for archived channels. Searchable but out of sight.

### Channels to Archive Now

Move to 📦 Archive:
- `general` (both — replaced by rc-main)
- `spark-setup`, `nvidia-spark-plan`, `spark-digest` (dead/one-off)
- `maria`, `charles-maria` (inactive)
- `subscribers` (can be a webhook to rc-alerts instead)

Move to 📦 Archive (paused per focus sprint, revive in April):
- `scout-alerts`, `outreach-log`, `rc-linkedin-automation`, `rc-viral-media`

Move to 📦 Archive (replaced by ops/decisions.md):
- `decisions`

### Default Categories

Delete or rename:
- "Text Channels" → remove (move `rc-linkedin-automation` first)
- "Voice Channels" → keep (has voice channel)
- "🏠 Home", "🔍 Scout", "⚙️ Ops" → remove after moving children

---

## Thread Lifecycle

Every thread is a work item with a state:

```
ACTIVE → WAITING → BLOCKED
   ↓         ↓        ↓
   └─────────┴────────┘
              ↓
       READY_TO_ARCHIVE
              ↓
          ARCHIVED
```

### State Definitions

| State | Meaning |
|---|---|
| `ACTIVE` | Work is happening |
| `WAITING` | Blocked on external input (person, system, time) |
| `BLOCKED` | Cannot proceed — needs a decision or dependency |
| `READY_TO_ARCHIVE` | Close-review passed, waiting for Rod's confirmation |
| `ARCHIVED` | Reconciled, extracted, closed |

---

## Commands

### `/cheatsheet`

Show brief instructions and available commands.

**Output:**
```
🧵 Discord Ops — Quick Reference

Channels = streams (always-on). Threads = topics (finite).
Every thread has a lifecycle: ACTIVE → ARCHIVED.
State tracked in ops/threads.yaml. Decisions in ops/decisions.md.

Commands:
/cheatsheet      — This message
/topic <name>    — Start a new tracked thread
/triage          — Where does this thread stand?
/extract         — Pull decisions, tasks, open questions
/close-review    — Check if thread is ready to archive
/archive         — Finalize + close (after confirmation)
/promote <type>  — Convert to spec | issue | decision | doc
/reopen          — Restore an archived thread
```

### `/topic <name>`

Create a new tracked thread.

**Behavior:**
1. Create thread in current channel (default: `rc-product`)
2. Register in `ops/threads.yaml` with status `ACTIVE`
3. Pin a context message with relevant links / STATUS.md info
4. Set thread topic/description if Discord supports it

### `/triage`

Understand where a thread stands right now. Usable mid-conversation.

**Output:**
```
📋 Triage: Deploy Gate E2E Testing

Status: ACTIVE
Owner: Rod
Started: 2026-03-08

Summary:
Testing the full deploy-gate flow end-to-end. Found two
blockers: route 404 and legacy key rejection.

Blockers:
- PR #1 needs merge + deploy to Render

Next step:
- Merge PR, verify on production
```

### `/extract`

Pull structured data out of messy discussion.

**Output:**
```
📦 Extraction: Deploy Gate E2E Testing

Decisions:
1. GitHub Action is the first OSS wedge
2. Legacy hex keys should work for request creation

Tasks:
- [ ] Merge PR #1 (route fix + key fix)
- [ ] Verify on production after deploy
- [ ] Record 90-second demo video

Open questions:
- Should demo include receipt UI or just CLI flow?

References:
- PR: permission-protocol/app#1
- Issue: permissionprotocol-site#141
```

Tasks and decisions are written to `ops/threads.yaml` and optionally to `ops/decisions.md`.

### `/close-review`

Prepare thread for closure. Checks archive gate.

**Archive gate — ALL must be true:**
- [ ] Primary question is resolved
- [ ] Decisions are captured (in extract or memory)
- [ ] Open tasks are completed, deferred, or moved to a backlog
- [ ] Memory-worthy facts are saved
- [ ] No orphaned work living only in this chat

**Output (gate passes):**
```
🔍 Closure Review: Deploy Gate E2E Testing

Outcome: Deploy gate works end-to-end. Two bugs fixed (PR #1).

Completed:
✅ Route 404 fix
✅ Legacy key auth fix
✅ E2E flow verified on production

Open items: None remaining

Decisions captured:
- Legacy keys authorized for request creation

Archive recommendation: ✅ YES

Are you ready to archive — final?
```

**Output (gate fails):**
```
🔍 Closure Review: Deploy Gate E2E Testing

Archive recommendation: ❌ NO

Reason: 2 open tasks remain
- [ ] Record demo video
- [ ] Update README with screenshots

Suggested: Complete tasks or move to another thread, then re-run /close-review.
```

### `/archive`

Execute final archive. Only after Rod confirms.

**Actions (in order):**
1. Extract final decisions → `ops/decisions.md`
2. Move remaining open tasks → relevant backlog / new thread
3. Update `MEMORY.md` if thread produced durable knowledge
4. Update today's daily note with summary
5. Update relevant `STATUS.md` files
6. Post archive receipt to `#archive-log`
7. Lock thread
8. Update `ops/threads.yaml` → status `ARCHIVED`

**Archive receipt format (posted to #archive-log):**
```
📁 Archived: Deploy Gate E2E Testing

Thread: #rc-product › Deploy Gate E2E Testing
Archived: 2026-03-08
Duration: 2 days

Outcome:
Deploy gate end-to-end flow working. Two bugs fixed.

Decisions:
- Legacy hex keys authorized for request creation

Tasks extracted: 0 remaining
Memory updated: Yes (deploy gate UX blockers)
```

### `/promote`

Convert thread content into a durable artifact.

**Artifact types:**
- `spec` → writes to `ops/specs/<name>.md`
- `issue` → creates GitHub issue
- `decision` → appends to `ops/decisions.md`
- `doc` → writes to relevant project directory

**Usage:** `/promote spec` or `/promote issue`

### `/reopen`

Restore an archived thread to ACTIVE status.

**Actions:**
1. Unlock thread
2. Update `ops/threads.yaml` → status `ACTIVE`
3. Post context message with last archive summary
4. Log reopen event in `#archive-log`

---

## State Tracking

### `ops/threads.yaml`

```yaml
threads:
  - id: "1480252012259053650"
    title: "Discord Structure"
    channel: "rc-product"
    status: ACTIVE
    owner: Rod
    priority: high
    created: 2026-03-08
    last_updated: 2026-03-08
    summary: "Restructuring Discord server — channels, threads, archive system"
    open_tasks:
      - "Build discord-ops skill"
      - "Execute channel restructure"
    decisions:
      - "Threads > channels for topics"
      - "6 permanent channels + archive category"
      - "Git-backed state tracking, no database"
    memory_candidates:
      - "Discord operating model: channels=streams, threads=topics"
```

Git-backed. Updated by commands. No external database needed for two people.

### `ops/decisions.md`

Running log of all extracted decisions, linked to source threads.

```markdown
# Decision Log

## 2026-03-08 — Discord Structure
- Channels are streams, threads are topics
- 6 permanent channels, everything else is a thread
- Archive requires closure gate (no silent archiving)
- Source: #rc-product › Discord Structure
```

---

## Automation

### Daily Thread Health (added to heartbeat)

Once per day, scan `ops/threads.yaml` and post to `#daily-log` if anything needs attention:

```
🧵 Thread Health — Mar 9

Active: 4
Waiting: 1
Blocked: 0
Idle >72h: 2 ⚠️

Needs attention:
- "Review surface auth" — idle 4 days, 2 open tasks
- "Content pipeline" — idle 3 days, no open tasks → run /close-review?

Ready to archive:
- "Discord structure" — gate passes, awaiting confirmation
```

Only posts when there's something worth reporting. Silent otherwise.

### Idle Thread Detection

Checked during heartbeat. If a thread has no meaningful update for 72+ hours, Charles posts a lightweight nudge in-thread:

```
💤 This thread has been quiet for 3 days.

Current state: SDK install flow needs screenshot + test
Open tasks: 2

Should we: continue | park it | /close-review?
```

**Frequency:** Max once per thread per 72h cycle. Not nagging.

---

## Implementation Plan

### Phase 1 — Structure (today)

1. Create `📦 Archive` category
2. Create `#archive-log` channel
3. Move dead/paused channels to archive
4. Update topics on permanent channels
5. Clean up empty categories
6. Create `ops/threads.yaml` and `ops/decisions.md`

### Phase 2 — Skill (this week)

Build `discord-ops` skill with:
- `/topic`, `/triage`, `/extract`, `/close-review`, `/archive`, `/promote`, `/reopen`
- Thread state management (read/write `ops/threads.yaml`)
- Archive receipt posting
- Memory/daily-note integration

### Phase 3 — Automation (next week)

- Thread health digest in heartbeat
- Idle thread detection
- Auto-extraction of tasks from threads on close

### Phase 4 — Leverage (later)

- GitHub issue generation from `/promote issue`
- Priority scoring on threads
- Attention routing ("these 2 threads need your decision today")

---

## What This Achieves

**Before:** 27 channels, most stale, decisions buried in chat, no closure protocol, things fall through cracks.

**After:** 6 channels + threads with tracked lifecycles. Every topic gets summarized, extracted, and archived cleanly. Decisions and tasks never live only in chat. Daily visibility into what's active, blocked, or rotting.

The system is lightweight (YAML + markdown, no database) but enforces the discipline that prevents Discord from becoming a graveyard again.

---

## Decisions (Rod, 2026-03-08)

1. **`rod-actions` → keep standalone.** React-based queue (✅/❌/🔄) works as a stream, not a discussion.
2. **`published` → keep standalone.** Automated log, not a topic. Streams belong in channels.
3. **`decisions` channel → archive, replace with `ops/decisions.md`.** Git-tracked, searchable, auto-populated by `/extract`.
4. **Thread auto-archive: 24h.** Aggressive but clean. Discord shows active threads in sidebar regardless.
5. **`/topic` defaults to current channel.** No friction — you're already where you want the thread.
