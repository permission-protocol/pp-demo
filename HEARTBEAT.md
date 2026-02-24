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
Check `Ready` column in [PP Product](https://github.com/orgs/Roca-Ventures/projects/2):
```bash
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh api graphql -f query='
query {
  organization(login: "Roca-Ventures") {
    projectV2(number: 2) {
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

## Goal Executor Watchdog
Check `goals/xdares-seo-growth/state.json`:
- If `tick_log` shows no ticks in last 2 hours → alert Rod
- If `execution.status` != "running" → report status
- If queue is empty and no replan happened → trigger `/goal plan`

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

## Xdares Metrics Review (Daily)
**Full analytics stack monitoring for ar-pwa-prod:**

### Google Analytics (Web Traffic)
- Active users, sessions, bounce rate (7d vs previous period)
- Top traffic sources (Direct, Organic Search, Referral, Social)
- Geographic breakdown (Singapore, US, China, etc.)
- Page views and user flows
- Conversion events and goals

### Firebase Analytics (App Behavior) 
- Real-time active users (30min window)
- User engagement and retention cohorts
- App events and feature usage
- Session duration and quality metrics
- Push notification performance

### Kickofflabs (Waitlist Growth)
- Total leads across campaigns (~19,725 baseline)
- New signups in last 24h/7d
- Referral performance and viral coefficient
- Campaign-specific metrics (Active vs Old)

### Google Search Console (SEO)
- Search impressions, clicks, CTR
- Average position for key queries 
- Indexing status for blog.xdares.com
- Core Web Vitals and technical issues

**Key question:** What patterns across platforms suggest strategy adjustments for growth acceleration?

## Evolution Backup (Daily)
- Run `./scripts/backup-evolution.sh` once per day
- Keeps GitHub backup current with my growth
- If backup push fails → alert Rod (needs auth fix)
- Critical for disaster recovery (Mac destruction scenario)
