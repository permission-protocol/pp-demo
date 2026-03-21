---
name: discord-ops
description: >
  Manage Discord thread lifecycles with structured commands. Use when a message
  starts with /cheatsheet, /topic, /triage, /extract, /close-review, /archive,
  /promote, or /reopen. Implements a topic lifecycle system where channels are
  streams and threads are finite work items with states (ACTIVE, BLOCKED, PARKED,
  EXPIRED, ARCHIVED). Tracks state in ops/threads.yaml, decisions in
  ops/decisions.md.
---

# Discord Ops

Thread lifecycle management for Discord. Channels = streams. Threads = topics with tracked state.

## State Files

- **Thread state:** `ops/threads.yaml` — git-backed, updated by commands
- **Decision log:** `ops/decisions.md` — extracted decisions linked to source threads
- **PRD:** `ops/discord-ops-prd.md` — full system design

## Server Info

- **Guild:** 1479269120334762008
- **Archive category:** 1480410017080545313
- **Archive log channel:** 1480410018062012586

## Commands

All commands operate on the **current thread** unless specified otherwise.
Read the full thread history before executing any command that requires analysis (triage, extract, close-review).

### /cheatsheet

Post this to the current channel:

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

### /topic <name>

1. Create thread in the current channel using `message` tool (`action: thread-create`)
2. Add entry to `ops/threads.yaml` with status `ACTIVE`, today's date, the thread creator as owner
3. Post a context message in the new thread with relevant links or STATUS.md info if applicable
4. If creating from a message, use that message as the thread starter

### /triage

Analyze the current thread and post a structured status:

```
📋 Triage: <thread title>

Status: <STATE>
Owner: <name>
Started: <date>

Summary:
<2-3 sentence summary of where things stand>

Blockers:
- <list or "None">

Next step:
- <concrete next action>
```

Update `ops/threads.yaml` with current summary and status.

### /extract

Read full thread history. Extract structured data and post:

```
📦 Extraction: <thread title>

Decisions:
1. <decision>
2. <decision>

Tasks:
- [ ] <task>
- [ ] <task>

Open questions:
- <question>

References:
- <links, PRs, issues>
```

Write extracted data to:
- `ops/threads.yaml` → update decisions and open_tasks arrays
- `ops/decisions.md` → append new decisions with date and thread source

### /close-review

Read full thread history. Check archive gate — ALL must pass:

- [ ] Primary question is resolved
- [ ] Decisions are captured
- [ ] Open tasks are completed, deferred, or moved
- [ ] Memory-worthy facts are saved
- [ ] No orphaned work living only in chat

**If gate passes:**
```
🔍 Closure Review: <thread title>

Outcome: <what was resolved>

Completed:
✅ <item>
✅ <item>

Open items: None remaining

Decisions captured:
- <decision>

Archive recommendation: ✅ YES

Are you ready to archive — final?
```

**If gate fails:**
```
🔍 Closure Review: <thread title>

Archive recommendation: ❌ NO

Reason: <why>
- [ ] <remaining item>
- [ ] <remaining item>

Suggested: <what to do next>
```

Update thread status to `PARKED` if gate passes and the thread is waiting for final archive.

### /archive

Only execute after explicit confirmation from Rod.

Actions in order:
1. Run `/extract` if not already done — capture final decisions and tasks
2. Move any remaining open tasks to a new thread or backlog
3. Update `MEMORY.md` if thread produced durable knowledge
4. Update today's daily note (`memory/YYYY-MM-DD.md`) with thread summary
5. Update relevant `STATUS.md` files if applicable
6. Post archive receipt to `#archive-log` (channel 1480410018062012586):

```
📁 Archived: <thread title>

Thread: #<channel> › <thread title>
Archived: <date>
Duration: <days>

Outcome:
<1-2 sentences>

Decisions:
- <key decisions>

Tasks extracted: <count remaining>
Memory updated: <Yes/No>
```

7. **Store key decisions and facts to long-term memory** using `memory_store`. For each significant decision or fact from the thread, call `memory_store` with category `decision` or `fact`. This ensures all future sessions — including other threads — have instant access to archived context without needing to read files.
8. Post the resolution artifact to the thread.
9. Update `ops/threads.yaml` → status `ARCHIVED`
10. **Discord-archive the thread** — set `archived: true` and `locked: true` via Discord API. This removes it from the sidebar. Use direct API call:
   ```
   curl -X PATCH "https://discord.com/api/v10/channels/<thread_id>" \
     -H "Authorization: Bot $DISCORD_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"name": "✅ <title>", "archived": true, "locked": true}'
   ```
   Requires MANAGE_THREADS permission for threads owned by others. Can always archive own threads.
   **CRITICAL: Never post in a thread after archiving it.** Discord auto-unarchives threads when any message is sent. Post final confirmation to `#archive-log` only.

### /promote <type>

Convert thread content into a durable artifact.

Types:
- `spec` → write to `ops/specs/<slug>.md`
- `issue` → create GitHub issue via `gh` CLI
- `decision` → append to `ops/decisions.md` (same as extract, but focused)
- `doc` → write to relevant project directory

Read thread history, synthesize content into the target format, post confirmation with link/path.

### /reopen

Restore an archived thread to active status.

1. Update `ops/threads.yaml` → status `ACTIVE`
2. Post context message in thread with last archive summary
3. Log reopen event in `#archive-log`:
```
🔄 Reopened: <thread title>
Reason: <why>
Previous archive: <date>
```

## Thread Status Definitions

| Status | Meaning |
|---|---|
| `ACTIVE` | Work is happening |
| `BLOCKED` | Cannot proceed — needs decision or dependency |
| `PARKED` | Intentionally paused without active execution |
| `EXPIRED` | Timed out and needs explicit re-triage |
| `ARCHIVED` | Reconciled, extracted, closed |

## Automation Notes

These are NOT part of the command set — they run during heartbeats:

- **Thread health digest:** Scan `ops/threads.yaml`, post summary to daily-log if threads are idle >72h
- **Idle nudge:** Post lightweight status check in stale threads (max once per 72h per thread)

## Important Rules

- Never archive without running close-review first
- Never archive without explicit confirmation from Rod
- Always read full thread history before triage/extract/close-review
- Keep ops/threads.yaml as source of truth — update it on every command
- Decisions go to ops/decisions.md with date + source thread link
- Use the `message` tool with `channel: "discord"` for all Discord operations
