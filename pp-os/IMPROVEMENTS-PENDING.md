# Pending Improvements (Mar 23, 2026)

## 1. Daily Signal Digest (New Cron)
- **Problem**: Signal scanning finds "HOT signals" (marketing hooks), but they are currently buried in `pp-os/marketing/HOT-SIGNAL.md`.
- **Proposed Fix**: Create a daily cron job that summarizes the day's signals and posts them to #daily-log or #marketing.
- **Category**: new cron / process change

## 2. Dynamic Blast Radius Tuning
- **Problem**: The current `policy-gate.sh` is binary (low vs high). It might be too aggressive, blocking Rod for simple config changes, or too lax on complex UI components.
- **Proposed Fix**: Implement a scoring system in `policy-gate.sh` based on file depth and "danger keywords" (e.g., `process.env`, `eval`, `auth`).
- **Category**: process change / script update

## 3. Post-Merge "Health Check" Cron
- **Problem**: We assume a Vercel deploy is healthy after merge, but we've seen stale chunks.
- **Proposed Fix**: A cron job that fires 5 minutes after a PR merge to specifically `curl` the affected routes and check for 200 OK + expected content.
- **Category**: new cron

## 5. Bot Comment "Locking" Feature (Webhook Code Change)
- **Problem**: In high-stakes demo recordings or PRs, manual edits are clobbered by re-enrichment when a new commit is pushed.
- **Proposed Fix**: Add logic to the webhook to respect a `<!-- skip-enrich -->` hidden comment and skip re-enrichment.
- **Category**: code change (webhook)
