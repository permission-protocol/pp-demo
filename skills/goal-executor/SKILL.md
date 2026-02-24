---
name: goal-executor
description: Autonomous goal execution agent with background task scheduling via cron. Plans, executes, and adapts tasks continuously toward a defined goal.
user-invocable: true
metadata: {"openclaw": {"emoji": "🎯", "always": true}}
---

# Goal Executor Skill (Advanced)

Autonomous goal execution with true background processing via OpenClaw's cron system.

## Commands

| Command | Description |
|---------|-------------|
| `/goal <description>` | Start a new goal with interactive setup |
| `/goal start` | Start/resume autonomous execution |
| `/goal pause` | Pause autonomous execution (keeps state) |
| `/goal stop` | Stop and show final summary |
| `/goal status` | Show current progress and queue |
| `/goal config` | Show/edit goal configuration |
| `/goal next` | Execute the next task immediately |
| `/goal plan` | Force a replan cycle |
| `/goal approve <task>` | Approve a pending HIGH impact task |
| `/goal provide <info>` | Provide info needed for a YELLOW task |

---

## STATE FILE

All state persists in `{baseDir}/state.json`:

```json
{
  "version": 2,
  "goal": {
    "description": "Increase organic traffic to XdaROS",
    "success_metric": {
      "current": "1000 visitors/month",
      "target": "5000 visitors/month",
      "timeframe": "3 months"
    },
    "constraints": ["no paid advertising", "maintain brand voice"],
    "created_at": "2025-02-03T10:00:00Z"
  },
  "config": {
    "daily_budget": 10,
    "auto_execute_delay_seconds": 60,
    "auto_approve_low_impact": true,
    "auto_approve_medium_impact": true,
    "auto_approve_high_impact": false,
    "check_interval_minutes": 30,
    "active_hours": {
      "start": 9,
      "end": 18
    },
    "timezone": "America/Los_Angeles",
    "notify_channel": "whatsapp",
    "notify_to": "+15551234567"
  },
  "execution": {
    "status": "running",
    "daily_tasks_completed": 3,
    "total_tasks_completed": 47,
    "tasks_since_replan": 2,
    "tasks_since_metric_update": 8,
    "last_run_at": "2025-02-03T14:30:00Z",
    "cron_job_id": "goal-executor-main"
  },
  "tasks": {
    "queue": [
      {
        "id": "task-001",
        "description": "Write SEO-optimized blog post about robotics trends",
        "reasoning": "Content marketing drives organic traffic",
        "impact": "HIGH",
        "confidence": 85,
        "category": "content",
        "classification": "GREEN",
        "rollback": "Delete post from CMS",
        "created_at": "2025-02-03T10:30:00Z",
        "status": "pending_approval"
      }
    ],
    "completed": [],
    "failed": [],
    "blocked": []
  },
  "logs": {
    "daily": {},
    "weekly_reviews": []
  },
  "tick_log": [
    {
      "event": "TICK",
      "timestamp": "2025-02-03T14:30:00Z",
      "source": "cron",
      "queue_size": 5,
      "green_tasks": 3,
      "action": "executed_task",
      "task_id": "task-047"
    }
  ]
}
```

---

## INITIALIZATION

When user invokes `/goal <description>`:

### Step 1: Gather Requirements

```
🎯 NEW GOAL: [description]

I'll help you work toward this continuously. Let me gather some details:

1. SUCCESS METRIC
   How do we measure progress?
   • Current state: (e.g., "1,000 visitors/month")
   • Target state: (e.g., "5,000 visitors/month")
   • Timeframe: (e.g., "3 months")

2. DAILY TASK BUDGET
   How many tasks should I execute per day? (default: 10)

3. CONSTRAINTS
   Anything off-limits? (e.g., no paid ads, specific tools to avoid)

4. AUTOMATION LEVEL
   • Auto-approve LOW impact tasks? (default: yes)
   • Auto-approve MEDIUM impact tasks? (default: yes)
   • Auto-approve HIGH impact tasks? (default: no - I'll ask first)

5. SCHEDULE
   • Active hours? (default: 9am-6pm)
   • Timezone? (default: your local timezone)
   • Check interval? (default: every 30 minutes)

6. NOTIFICATIONS
   Where should I send updates?
   • Channel: whatsapp / telegram / slack / discord / imessage
   • Target: (phone number, channel ID, etc.)

Reply with your preferences, or say "defaults" to use standard settings.
```

### Step 2: Confirm and Initialize

After user provides config:

1. Create `{baseDir}/state.json` with initial state
2. Run first planning cycle (STEP 1: PLAN)
3. Set up cron job for autonomous execution

```javascript
// Create the main execution cron job
cron.add({
  name: "goal-executor-main",
  schedule: {
    kind: "every",
    everyMs: config.check_interval_minutes * 60 * 1000
  },
  sessionTarget: "isolated",
  wakeMode: "now",
  payload: {
    kind: "agentTurn",
    message: "GOAL_EXECUTOR_TICK: Check state and execute next task if appropriate.",
    deliver: true,
    channel: config.notify_channel,
    to: config.notify_to,
    bestEffortDeliver: true
  },
  isolation: {
    postToMainPrefix: "Goal",
    postToMainMode: "summary"
  }
})
```

Confirm to user:

```
✅ GOAL INITIALIZED

Goal: [description]
Target: [current] → [target] in [timeframe]
Budget: [N] tasks/day
Schedule: Every [X] minutes, [start]-[end] [timezone]
Notifications: [channel] → [target]

I've identified [N] initial tasks:
• [HIGH IMPACT] Task 1 (GREEN - can do now)
• [MEDIUM] Task 2 (GREEN)
• [HIGH IMPACT] Task 3 (YELLOW - needs API access)
...

🚀 Starting autonomous execution now.
Reply "pause" anytime to pause, "stop" to end.
```

---

## MAIN EXECUTION LOOP

This runs via cron every `check_interval_minutes`:

### On Each Tick

```
GOAL_EXECUTOR_TICK received. Processing...

1. Load state from {baseDir}/state.json
2. Check if execution.status == "running"
3. Check if within active_hours
4. Check if daily_budget not exhausted
5. Check if replan needed
6. Select and execute next task
7. Save state
8. Schedule next tick (cron handles this)
```

### STEP 1: PLAN (Full Planning Cycle)

Trigger replan when:
- `is_first_plan == true`
- Task just failed
- `tasks_since_replan >= 5`
- Fewer than 3 GREEN tasks in queue
- **Queue is empty (0 tasks)** ← AUTO-REPLAN
- User provided new input
- Daily reset (new day)

**CRITICAL:** When queue reaches 0 tasks, ALWAYS trigger a full replan before reporting "no tasks available". Never let the executor stall with an empty queue.

Planning prompt:

```
Given:
- Goal: [goal.description]
- Success metric: [current] → [target] in [timeframe]
- Tasks completed today: [list]
- Tasks completed total: [N]
- Tasks that failed (and why): [list]
- What just happened: [last task outcome]
- Current queue: [queue]
- Constraints: [constraints]
- Available tools: bash, browser, read, write, edit, [other skills]

What are the top 5 tasks that would move us toward the goal RIGHT NOW?

Rules:
- Prioritize by IMPACT, not by whether I can do them alone
- Do NOT suggest tasks already completed
- Do NOT suggest tasks that failed unless new info makes them viable
- Be SPECIFIC and ACTIONABLE
- Consider what tools I actually have access to
```

For each task, determine:

```json
{
  "id": "task-XXX",
  "description": "Specific actionable task",
  "reasoning": "Why this moves us toward the goal",
  "impact": "HIGH | MEDIUM | LOW",
  "confidence": 0-100,
  "category": "content | outreach | technical | research | other",
  "classification": "GREEN | YELLOW | RED",
  "needs": "What's needed (for YELLOW/RED)",
  "rollback": "How to undo if needed",
  "estimated_duration": "5m | 30m | 1h | etc"
}
```

**Classification Logic:**
- **GREEN**: I have all tools and access needed to execute this autonomously
- **YELLOW**: I need human to provide: API keys, credentials, approval, data, or access
- **RED**: Requires human action that cannot be automated (e.g., physical tasks, decisions requiring human judgment)

After planning, update state and notify if new YELLOW/RED tasks found:

```
📋 PLANNING COMPLETE

New tasks added to queue:
• [HIGH] Write SEO blog post (GREEN ✓)
• [HIGH] Set up Google Search Console (YELLOW - needs account access)
• [MEDIUM] Optimize meta descriptions (GREEN ✓)

⚠️ TASKS THAT COULD ACCELERATE PROGRESS:
┌────────────────────────────────────────────────────────────┐
│ YELLOW (need your input):                                  │
│ • Set up Google Search Console: Need Google account creds  │
│ • Connect analytics: Need GA4 property ID                  │
│                                                            │
│ RED (you need to do):                                      │
│ • Approve website design changes: Requires your sign-off   │
└────────────────────────────────────────────────────────────┘

Reply with info anytime, or I'll continue with GREEN tasks.
```

### STEP 2: SELECT

Pick the highest-priority GREEN task that:
- Is within category cooldowns (if configured)
- Has confidence >= 50%
- Matches auto-approval settings based on impact

**Selection Priority:**
1. HIGH impact + HIGH confidence GREEN tasks
2. HIGH impact + MEDIUM confidence GREEN tasks
3. MEDIUM impact GREEN tasks
4. LOW impact GREEN tasks

If no GREEN tasks available:

```
⏸️ PAUSED - No autonomous tasks available

All remaining tasks need your input:

YELLOW:
• [Task]: Needs [what's needed]

RED:
• [Task]: You need to [action]

Provide what's needed to continue, or I'll check again in [interval].
```

### STEP 3: PROPOSE

**For LOW/MEDIUM impact (auto-approved):**

```
⚡ EXECUTING: [task description]
Impact: [MEDIUM] | Confidence: [85]%
Category: [content]
Starting now...
```

Then immediately proceed to STEP 4.

**For HIGH impact (requires approval):**

```
┌────────────────────────────────────────────────────────────┐
│ 🔴 HIGH IMPACT TASK - APPROVAL REQUIRED                    │
├────────────────────────────────────────────────────────────┤
│ Task: [description]                                        │
│ Why: [reasoning]                                           │
│ Impact: HIGH | Confidence: [X]%                            │
│ Rollback: [how to undo]                                    │
├────────────────────────────────────────────────────────────┤
│ Reply "approve" to execute, "skip" to skip                 │
│ Auto-skipping in 24 hours if no response...                │
└────────────────────────────────────────────────────────────┘
```

Set task status to `pending_approval` and continue with other tasks.

### STEP 4: EXECUTE

Execute using OpenClaw tools:

```javascript
// Tool mapping
const TOOL_MAP = {
  "content": ["write", "edit", "browser"],
  "technical": ["bash", "edit", "read"],
  "research": ["browser", "read"],
  "outreach": ["browser", "channels"],
  "automation": ["bash", "cron"]
};

// Execute with appropriate tools
async function executeTask(task) {
  const tools = TOOL_MAP[task.category];
  
  // Log start
  console.log(`Executing: ${task.description}`);
  
  // Run the task using available tools
  // ... task-specific logic ...
  
  // Return result
  return { success: true, output: "..." };
}
```

During execution:
- Be thorough and complete
- Save artifacts (content, files, code)
- Log changes for potential rollback
- Capture metrics where possible

### STEP 5: EVALUATE

**On Success:**

```javascript
// Update state
state.tasks.completed.push({
  ...task,
  completed_at: new Date().toISOString(),
  outcome: "Success: [summary]"
});
state.execution.daily_tasks_completed++;
state.execution.total_tasks_completed++;
state.execution.tasks_since_replan++;
state.execution.tasks_since_metric_update++;

// Add to rollback log if applicable
if (task.rollback) {
  state.rollback_log.push({
    task_id: task.id,
    description: task.description,
    rollback_instructions: task.rollback,
    completed_at: new Date().toISOString()
  });
}
```

Notify:
```
✅ COMPLETED: [task summary]
Output: [brief result]
Progress: [N]/[budget] tasks today | [total] total
```

**On Failure:**

```javascript
state.tasks.failed.push({
  ...task,
  failed_at: new Date().toISOString(),
  failure_reason: error.message,
  suggested_fix: determineFix(error)
});
state.execution.tasks_since_replan++;
```

Notify:
```
❌ FAILED: [task summary]
Reason: [what went wrong]
Suggested fix: [what could help]
Continuing with next task...
```

### STEP 6: VALIDATION CHECK

Quick assessment (don't regenerate full task list):

```
Is my current task queue still relevant given what just happened?
```

**Trigger full replan (STEP 1) if:**
- **Queue is empty (0 tasks)** ← HIGHEST PRIORITY
- Task just failed
- `tasks_since_replan >= 5`
- Fewer than 3 GREEN tasks remain
- User just provided new input
- Last task significantly changed the situation

**Otherwise:** Continue to STEP 2 for next task

### needs_replan() Function

```python
def needs_replan(state):
    """Determine if a full replan cycle is needed."""
    queue = state.tasks.queue
    green_tasks = [t for t in queue if t.classification == "GREEN"]
    
    # CRITICAL: Empty queue = always replan
    if len(queue) == 0:
        return True
    
    # No GREEN tasks = replan to find alternatives
    if len(green_tasks) == 0:
        return True
    
    # Fewer than 3 GREEN tasks = running low, replan
    if len(green_tasks) < 3:
        return True
    
    # Too many tasks since last replan
    if state.execution.tasks_since_replan >= 5:
        return True
    
    # Recent task failed
    if state.tasks.failed and len(state.tasks.failed) > 0:
        last_failed = state.tasks.failed[-1]
        # Check if failed in last tick
        if was_recent(last_failed.failed_at):
            return True
    
    return False
```

---

## GOAL DRIFT PROTECTION

Every 10 completed tasks, prompt for metric update:

```
┌────────────────────────────────────────────────────────────┐
│ ⚠️ PROGRESS CHECK                                          │
├────────────────────────────────────────────────────────────┤
│ I've completed 10 tasks since we last checked progress.    │
│                                                            │
│ Goal: [description]                                        │
│ Last known metric: [value]                                 │
│                                                            │
│ Has the metric improved?                                   │
│ • Reply with new value to update                           │
│ • Reply "continue" to keep going                           │
│ • Reply "pause" to rethink strategy                        │
└────────────────────────────────────────────────────────────┘
```

---

## DAILY SUMMARY

Triggered at end of active hours or when daily budget exhausted:

```
┌────────────────────────────────────────────────────────────┐
│ 📊 DAILY SUMMARY - [date]                                  │
├────────────────────────────────────────────────────────────┤
│ Goal: [description]                                        │
│ Progress: [current] → [target] ([X]% complete)             │
├────────────────────────────────────────────────────────────┤
│ TODAY:                                                     │
│ • Tasks completed: [N]                                     │
│ • Tasks failed: [N]                                        │
│ • Tasks skipped: [N]                                       │
├────────────────────────────────────────────────────────────┤
│ KEY WINS:                                                  │
│ • [Most impactful task and outcome]                        │
│ • [Second most impactful]                                  │
├────────────────────────────────────────────────────────────┤
│ BLOCKED (needs your input):                                │
│ • [YELLOW task]: Needs [what]                              │
├────────────────────────────────────────────────────────────┤
│ TOMORROW'S FOCUS:                                          │
│ • [Top priority]                                           │
│ • [Second priority]                                        │
├────────────────────────────────────────────────────────────┤
│ Resuming tomorrow at [start_time] [timezone]               │
└────────────────────────────────────────────────────────────┘
```

Reset daily counters at start of next day.

---

## WEEKLY REVIEW

Triggered every 7 days (via separate cron job):

```
┌────────────────────────────────────────────────────────────┐
│ 📈 WEEKLY REVIEW - Week of [date]                          │
├────────────────────────────────────────────────────────────┤
│ Goal: [description]                                        │
│ Progress: [week_start] → [week_end]                        │
│ Overall: [X]% toward target                                │
├────────────────────────────────────────────────────────────┤
│ WHAT MOVED THE NEEDLE:                                     │
│ • [Task type/category that had biggest impact]             │
│ • [Specific high-impact tasks]                             │
├────────────────────────────────────────────────────────────┤
│ WHAT'S NOT WORKING:                                        │
│ • [Task types that keep failing]                           │
│ • [Patterns in failures]                                   │
├────────────────────────────────────────────────────────────┤
│ RECOMMENDED ADJUSTMENTS:                                   │
│ • [Data-driven suggestions]                                │
├────────────────────────────────────────────────────────────┤
│ QUESTIONS FOR YOU:                                         │
│ • Any changes to the goal?                                 │
│ • New constraints or resources?                            │
│ • Feedback on my performance?                              │
└────────────────────────────────────────────────────────────┘
```

---

## CRON JOB MANAGEMENT

### Setup on Goal Init

```bash
# Main execution loop (every 30 min during active hours)
openclaw cron add \
  --name "goal-executor-main" \
  --cron "*/30 9-18 * * *" \
  --tz "$TIMEZONE" \
  --session isolated \
  --message "GOAL_EXECUTOR_TICK" \
  --deliver \
  --channel "$NOTIFY_CHANNEL" \
  --to "$NOTIFY_TO"

# Daily summary (end of day)
openclaw cron add \
  --name "goal-executor-daily" \
  --cron "0 18 * * *" \
  --tz "$TIMEZONE" \
  --session isolated \
  --message "GOAL_EXECUTOR_DAILY_SUMMARY" \
  --deliver \
  --channel "$NOTIFY_CHANNEL" \
  --to "$NOTIFY_TO"

# Weekly review (Sunday evening)
openclaw cron add \
  --name "goal-executor-weekly" \
  --cron "0 19 * * 0" \
  --tz "$TIMEZONE" \
  --session isolated \
  --message "GOAL_EXECUTOR_WEEKLY_REVIEW" \
  --model "opus" \
  --thinking high \
  --deliver \
  --channel "$NOTIFY_CHANNEL" \
  --to "$NOTIFY_TO"

# Goal drift check (every 10 tasks - managed in code, not cron)
```

### On Pause

```bash
openclaw cron edit goal-executor-main --disable
openclaw cron edit goal-executor-daily --disable
# Keep weekly review active for accountability
```

### On Resume

```bash
openclaw cron edit goal-executor-main --enable
openclaw cron edit goal-executor-daily --enable
```

### On Stop

```bash
openclaw cron remove goal-executor-main
openclaw cron remove goal-executor-daily
openclaw cron remove goal-executor-weekly
```

---

## DEBUGGING & TICK LOGGING

### Tick Log

Every cron tick is logged in `state.tick_log` (last 50 entries). Check this to verify cron is firing:

```bash
# View recent ticks
cat goals/<goal-id>/state.json | jq '.tick_log[-10:]'
```

### Common Issues

**Issue: Cron jobs not firing**
- Check `openclaw cron status` - is `nextWakeAtMs` set?
- Check heartbeat config: `agents.defaults.heartbeat.every` should be set (e.g., "30m")
- Cron jobs with `wakeMode: "next-heartbeat"` require heartbeats to trigger

**Issue: Queue reaches 0 and executor stalls**
- Fixed in v2: Auto-replan triggers when queue is empty
- Check `tick_log` to see if ticks are running
- Run `/goal plan` to force a manual replan

**Issue: No GREEN tasks available**
- Check for YELLOW tasks that need input
- Provide credentials/access for blocked tasks
- Run `/goal plan` to regenerate task list

### Manual Debugging

```bash
# Force run the cron job
openclaw cron run <job-id> --force

# Check cron run history
openclaw cron runs --id <job-id>

# View job details
openclaw cron list

# Check if heartbeats are running
openclaw system heartbeat last
```

### State Backups

State is automatically backed up before risky operations:

```python
def backup_state(state, reason="auto"):
    """Backup state before modifications."""
    backup_dir = f"{state.base_dir}/backups"
    os.makedirs(backup_dir, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_path = f"{backup_dir}/state-{timestamp}.json"
    
    shutil.copy(f"{state.base_dir}/state.json", backup_path)
    
    # Keep only last 10 backups
    backups = sorted(glob(f"{backup_dir}/state-*.json"))
    for old in backups[:-10]:
        os.remove(old)
    
    return backup_path
```

Backups are stored in `goals/<goal-id>/backups/` and rotated (keeps last 10).

To restore:
```bash
cp goals/<goal-id>/backups/state-YYYYMMDD-HHMMSS.json goals/<goal-id>/state.json
```

---

## MESSAGE HANDLERS

When receiving a message in the goal-executor session:

### GOAL_EXECUTOR_TICK

**IMPORTANT:** On every tick, log the tick event for debugging and handle empty queues properly.

```python
def handle_tick():
    # STEP 0: LOG THE TICK (for debugging cron issues)
    tick_time = datetime.now().isoformat()
    log_entry = {
        "event": "TICK",
        "timestamp": tick_time,
        "source": "cron"
    }
    print(f"🔄 GOAL_EXECUTOR_TICK at {tick_time}")
    
    state = load_state()
    
    # Log tick to state for audit trail
    if "tick_log" not in state:
        state["tick_log"] = []
    state["tick_log"].append(log_entry)
    # Keep only last 50 ticks
    state["tick_log"] = state["tick_log"][-50:]
    
    if state.execution.status != "running":
        print(f"⏸️ Goal executor is paused. Status: {state.execution.status}")
        save_state(state)
        return "Goal executor is paused."
    
    if not within_active_hours(state.config):
        print(f"🌙 Outside active hours ({state.config.active_hours})")
        save_state(state)
        return "Outside active hours. Resuming at {start_time}."
    
    if state.execution.daily_tasks_completed >= state.config.daily_budget:
        print(f"📊 Daily budget exhausted ({state.execution.daily_tasks_completed}/{state.config.daily_budget})")
        save_state(state)
        return "Daily budget exhausted. Resuming tomorrow."
    
    # CRITICAL: Check for empty queue FIRST and auto-replan
    green_tasks = [t for t in state.tasks.queue if t.classification == "GREEN"]
    queue_size = len(state.tasks.queue)
    
    print(f"📋 Queue status: {queue_size} total, {len(green_tasks)} GREEN")
    
    # AUTO-REPLAN if queue is empty or no GREEN tasks
    if queue_size == 0 or len(green_tasks) == 0:
        print(f"🔄 AUTO-REPLAN triggered: queue_size={queue_size}, green_tasks={len(green_tasks)}")
        plan(state)  # Generate new tasks
        save_state(state)
        
        # Re-check after planning
        green_tasks = [t for t in state.tasks.queue if t.classification == "GREEN"]
        if len(green_tasks) == 0:
            print("⚠️ No GREEN tasks after replan. Waiting for input.")
            return "No GREEN tasks available after replan. Waiting for input."
    
    # Standard replan triggers (in addition to empty queue)
    if needs_replan(state):
        print(f"🔄 Standard replan triggered: tasks_since_replan={state.execution.tasks_since_replan}")
        plan(state)
    
    task = select_next_task(state)
    if not task:
        # This should rarely happen after the empty-queue check above
        print("⚠️ No task selected despite non-empty queue. Forcing replan.")
        plan(state)
        task = select_next_task(state)
        if not task:
            save_state(state)
            return "No executable tasks available. Waiting for input."
    
    print(f"▶️ Selected task: {task.id} - {task.description[:50]}...")
    
    if needs_approval(task, state.config):
        request_approval(task)
        save_state(state)
        return
    
    result = execute_task(task)
    evaluate_result(task, result, state)
    
    # Update last_run_at
    state.execution.last_run_at = tick_time
    
    save_state(state)
    
    return format_result(task, result)
```

**Key improvements:**
1. **Tick logging**: Every tick is logged with timestamp for debugging
2. **Auto-replan on empty queue**: Before saying "no tasks", tries to generate new ones
3. **Double-check after replan**: If still no GREEN tasks, reports clearly
4. **Audit trail**: Last 50 ticks stored in state for debugging
5. **Daily budget reset**: Auto-resets at midnight based on `last_run_date`
6. **Failure tracking**: `consecutive_failures` counter triggers alerts after 3 failures

### Daily Budget Reset

```python
def check_daily_reset(state):
    """Reset daily counters if it's a new day."""
    today = datetime.now(tz=state.config.timezone).strftime("%Y-%m-%d")
    last_date = state.execution.get("last_run_date")
    
    if last_date != today:
        print(f"📅 New day detected ({last_date} → {today}). Resetting daily counters.")
        state.execution.daily_tasks_completed = 0
        state.execution.last_run_date = today
        return True
    return False
```

### Failure Tracking

```python
def track_failure(state, reason):
    """Track consecutive failures and alert if threshold exceeded."""
    state.execution.consecutive_failures += 1
    state.execution.last_failure_reason = reason
    
    if state.execution.consecutive_failures >= 3:
        # Alert user
        notify(f"⚠️ Goal executor has failed {state.execution.consecutive_failures} times in a row. Last error: {reason}")
    
    save_state(state)

def track_success(state):
    """Reset failure counter on success."""
    state.execution.consecutive_failures = 0
    state.execution.last_failure_reason = None
```

### GOAL_EXECUTOR_DAILY_SUMMARY

```python
def handle_daily_summary():
    state = load_state()
    summary = generate_daily_summary(state)
    reset_daily_counters(state)
    save_state(state)
    return summary
```

### GOAL_EXECUTOR_WEEKLY_REVIEW

```python
def handle_weekly_review():
    state = load_state()
    review = generate_weekly_review(state)
    state.logs.weekly_reviews.append(review)
    save_state(state)
    return review
```

---

## USER COMMANDS

### /goal status

```
┌────────────────────────────────────────────────────────────┐
│ 🎯 GOAL STATUS                                             │
├────────────────────────────────────────────────────────────┤
│ Goal: [description]                                        │
│ Status: [RUNNING / PAUSED / STOPPED]                       │
│ Progress: [X]% toward target                               │
├────────────────────────────────────────────────────────────┤
│ TODAY: [N]/[budget] tasks | TOTAL: [N] tasks               │
├────────────────────────────────────────────────────────────┤
│ QUEUE ([N] tasks):                                         │
│ 1. [HIGH] Task description (GREEN ✓)                       │
│ 2. [MEDIUM] Task description (GREEN ✓)                     │
│ 3. [HIGH] Task description (YELLOW - needs X)              │
├────────────────────────────────────────────────────────────┤
│ NEXT RUN: [time] | LAST RUN: [time]                        │
└────────────────────────────────────────────────────────────┘
```

### /goal pause

```
⏸️ GOAL EXECUTION PAUSED

Current progress saved. Resume anytime with "/goal start".

While paused:
• No new tasks will be executed
• Weekly reviews will still run
• You can still use "/goal next" for manual execution
```

### /goal start

```
▶️ GOAL EXECUTION RESUMED

Checking for pending tasks...

[Runs STEP 2: SELECT and continues loop]
```

### /goal next

Force execute the next task immediately (bypasses schedule):

```
openclaw cron run goal-executor-main --force
```

### /goal approve <task-id>

```
✅ Task approved: [task description]
Executing now...
```

### /goal provide <info>

When user provides info for a YELLOW task:

```
User: /goal provide Here's the Google Search Console access: [credentials]

Agent:
✅ Got it! Updating task:
• "Set up Google Search Console" → GREEN ✓

This task is now in the queue and will execute on the next cycle.
Want me to run it now? Reply "yes" to execute immediately.
```

---

## SAFETY FEATURES

### Rollback Log

Maintained in state for all reversible tasks:

```json
{
  "rollback_log": [
    {
      "task_id": "task-001",
      "description": "Published blog post",
      "rollback_instructions": "Delete post from CMS at /admin/posts/123",
      "completed_at": "2025-02-03T14:30:00Z"
    }
  ]
}
```

### Emergency Stop

At any time, user can send:
- "stop" / "halt" / "emergency stop"
- `/goal stop`

This immediately:
1. Sets `execution.status = "stopped"`
2. Removes all cron jobs
3. Sends final summary
4. Preserves state for review

### Rate Limiting

Built-in limits:
- Max 1 task per execution cycle
- Respect daily budget
- Active hours enforcement
- Category cooldowns (optional)

---

## TOOL REFERENCE

Available OpenClaw tools for task execution:

| Tool | Use For |
|------|---------|
| `bash` | Shell commands, scripts, CLI tools |
| `browser` | Web browsing, form filling, screenshots |
| `browser.eval` | JavaScript execution on pages |
| `read` | Read files from workspace |
| `write` | Write/create files |
| `edit` | Edit existing files |
| `cron.add/remove` | Schedule follow-up tasks |
| `sessions_send` | Coordinate with other agents |
| `gog` (skill) | Google Suite: Gmail, Calendar, Drive |
| `bird` (skill) | Twitter/X posting |
| `peekaboo` (skill) | Screenshots |
| `imsg` (skill) | iMessage |
| `wacli` (skill) | WhatsApp CLI |

---

## EXAMPLE SESSION

```
User: /goal Increase organic traffic to xdaros.com from 1000 to 5000 monthly visitors in 3 months

Agent:
🎯 NEW GOAL: Increase organic traffic to xdaros.com
Current: 1,000 visitors/month
Target: 5,000 visitors/month
Timeframe: 3 months

Quick setup - reply with any changes or "go" for defaults:
• Daily budget: 10 tasks
• Active hours: 9am-6pm (your timezone)
• Auto-approve: LOW ✓ MEDIUM ✓ HIGH ✗
• Check every: 30 minutes
• Notify via: [your last active channel]

User: go

Agent:
✅ GOAL INITIALIZED

Running initial analysis...

📋 INITIAL PLAN (15 tasks identified):

HIGH IMPACT:
• Conduct keyword research for robotics niche (GREEN ✓)
• Write cornerstone content piece (GREEN ✓)
• Set up Google Search Console (YELLOW - need account access)
• Implement technical SEO fixes (GREEN ✓)

MEDIUM IMPACT:
• Optimize existing page meta descriptions (GREEN ✓)
• Create internal linking structure (GREEN ✓)
• Research competitor backlinks (GREEN ✓)

⚠️ TASKS NEEDING YOUR INPUT:
• Google Search Console: Need your Google account credentials or access
• Analytics setup: Need GA4 property ID

🚀 Starting autonomous execution now!

---

⚡ EXECUTING: Conduct keyword research for robotics niche
Impact: HIGH | Confidence: 90%

[5 minutes later...]

✅ COMPLETED: Keyword research
Found 47 relevant keywords with search volume data.
Saved to workspace/seo/keyword-research.md
Progress: 1/10 tasks today | 1 total

---

⚡ EXECUTING: Optimize existing page meta descriptions
Impact: MEDIUM | Confidence: 85%

[10 minutes later...]

✅ COMPLETED: Meta descriptions optimized
Updated 12 pages with keyword-optimized meta descriptions.
Progress: 2/10 tasks today | 2 total

---

[Later that day...]

📊 DAILY SUMMARY - Feb 3, 2025

Goal: Increase organic traffic to xdaros.com
Progress: 1,000 → 5,000 (0% - just started!)

TODAY:
• Tasks completed: 8
• Tasks failed: 1
• Tasks skipped: 0

KEY WINS:
• Keyword research completed - 47 target keywords identified
• 12 pages optimized with new meta descriptions
• Technical SEO audit completed - 23 issues found

BLOCKED:
• Google Search Console setup - still need account access

TOMORROW'S FOCUS:
• Fix critical technical SEO issues
• Write first cornerstone content piece

Resuming tomorrow at 9:00 AM PST

---

[One week later...]

📈 WEEKLY REVIEW - Week of Jan 27

Progress: 1,000 → 1,247 visitors (+24.7%)
Overall: 6.2% toward target

WHAT MOVED THE NEEDLE:
• Content creation: 3 blog posts drove 180 new visitors
• Technical fixes: Page speed improvements helped rankings

WHAT'S NOT WORKING:
• Social sharing tasks had minimal impact
• Meta description changes haven't affected CTR yet

RECOMMENDED ADJUSTMENTS:
• Increase content frequency (2x/week → 3x/week)
• Reduce social tasks, focus on content + backlinks
• Consider guest posting for backlinks

QUESTIONS FOR YOU:
• Should I adjust the strategy based on these findings?
• Any new constraints or resources available?
```

---

## INSTALLATION

1. Create skill folder:
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/goal-executor
   ```

2. Copy this SKILL.md to the folder

3. Restart gateway:
   ```bash
   openclaw gateway restart
   ```

4. Start using:
   ```
   /goal <your goal description>
   ```
