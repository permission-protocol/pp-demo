# Pending Improvements (Mar 19, 2026)

## 1. Automated NemoClaw Demo Pipeline
- **Problem**: Today's demo was recorded manually in tmux. It was successful, but repeating it for different marketing "hooks" is manual.
- **Proposed Fix**: Create a script `scripts/record-pp-demo.sh` that uses `peekaboo` or `asciinema` to automate the E2E flow (Blocked Action -> Webhook -> Approval -> Success) for consistent marketing collateral.
- **Category**: new script / new cron

## 2. Dynamic Blast Radius Tuning
- **Problem**: The new `policy-gate.sh` is binary (low vs high). It might be too aggressive, blocking Rod for simple config changes, or too lax on complex UI components.
- **Proposed Fix**: Implement a scoring system in `policy-gate.sh` based on file depth and "danger keywords" (e.g., `process.env`, `eval`, `auth`).
- **Category**: process change / script update

## 3. Post-Merge "Health Check" Cron
- **Problem**: We assume a Vercel deploy is healthy after merge, but we've seen stale chunks.
- **Proposed Fix**: A cron job that fires 5 minutes after a PR merge to specifically `curl` the affected routes and check for 200 OK + expected content.
- **Category**: new cron
