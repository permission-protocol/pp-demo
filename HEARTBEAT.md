# HEARTBEAT.md

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

## Quick Health Check
- If any cron jobs show repeated failures → alert
- Run `./scripts/health-check.sh` weekly (Sunday heartbeats)
- If cooldown detected → alert Rod immediately
- Otherwise: HEARTBEAT_OK

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
