# HEARTBEAT.md — Maria's Periodic Checks

## Quick Health
- Is Tor running? `service tor status` — restart if down
- Can I reach Spark? `curl -s http://100.111.31.56:11434/api/tags | head -5`
- Any cron failures? Check recent logs

If anything is broken, message Rod immediately. Otherwise continue.

## Metrics Check (rotate, 2-3x per day)
- Run `bash scripts/xdares-metrics-collect.sh` if >6h since last run
- Check `goals/xdares-seo-growth/metrics/latest.json` for anomalies
- If traffic drops >20% WoW → alert Rod immediately

## Goal Executor
- Check `goals/xdares-seo-growth/state.json`
- If queue is empty → time to replan
- If stale >24h → diagnose and restart
- Pick and execute next task if within autonomy

## Content Pipeline
- Any drafts ready to publish? Check `goals/xdares-seo-growth/drafts/`
- Any published posts need performance review?

## Daily Note
- Update `memory/YYYY-MM-DD.md` with anything notable
- If significant work happened, capture it

## When to Alert Rod
- Traffic anomaly (>20% drop)
- Publishing failures
- Infrastructure issues (Tor, Spark unreachable)
- Blocked on something that needs approval

## When to Stay Quiet
- Late night (11PM-7AM MST)
- Nothing new since last check
- Everything is running fine → HEARTBEAT_OK
