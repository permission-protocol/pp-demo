# IMPROVEMENTS-PENDING.md — Mar 29, 2026

The following improvements require your approval or additional access.

## [Critical] Fix Failing Cron Jobs — Channel Plugin Configuration
- **Problem**: 6 cron jobs are persistently failing (100+ errors total) because `telegram`/`discord` channels aren't configured in gateway config. Jobs: xdares-seo-goal-executor, factory-error-sensor, goal-xdares-seo-main, unified-signal-scan, pp-os-execute-ready, unified-hotline.
- **Proposed Fix**: Either (A) configure channel plugins in gateway config, or (B) update crons to not require messaging channels.
- **Status**: Pending Rod to decide on channel config.
- **Risk**: Low (config change), but HIGH accumulated error noise.

## [Blocked] X API Write Permissions
- **Problem**: X API write access is blocked. Prevents automated posting to @xdares_ and any PP/engagement content.
- **Proposed Fix**: Upgrade X Developer account to Pro/Elevated access tier.
- **Status**: Pending Rod action.
- **Risk**: None (account setting).

## [Blocked] Paperclip Port 3100
- **Problem**: Paperclip webhook server on pp-scout-sfo2 not responding on port 3100.
- **Proposed Fix**: SSH into pp-scout-sfo2 and check ufw + Fastify bind configuration.
- **Status**: Pending Rod SSH access.
- **Risk**: Low (diagnostics only).

---

## Previously Filed (Mar 24)

### [PP/Xdares] Automated CDN/Cache Purge Tooling
- **Problem**: The Xdares mobile age-gate has been blocked for days by 10Web/CDN caching.
- **Proposed Fix**: Create a dedicated `infra` skill or `scripts/purge-cache.sh` with 10Web/Cloudflare API tokens.
- **Status**: Pending Rod to provide API tokens.

### [PP] Browser Session Persistence (Login Automation)
- **Problem**: Launch day engagement limited by lack of logged-in sessions.
- **Proposed Fix**: Use Playwright persistent profiles for HN/X/GitHub sessions.
- **Status**: Pending Rod to confirm persistent profile approach.
