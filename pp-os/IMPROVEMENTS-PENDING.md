# PENDING IMPROVEMENTS

## System / Infrastructure

### 1. Cron Channel Repair (High Priority)
- **Problem**: 7+ crons are failing with `Unsupported channel: discord` or `Unsupported channel: telegram`. This indicates the Gateway's messaging plugin configuration is stale or disconnected for those specific cron-worker sessions.
- **Diagnostics (Apr 5)**: `bash scripts/discord-health-check.sh` confirms the Discord client is initialized as "Charles Goldberg" but is stuck at `awaiting gateway readiness`.
- **Proposed Fix**: Rod needs to verify the Gateway config (discord/telegram plugins) and potentially restart the process.
- **Type**: Config Change / Gateway Restart

### 2. X API Tier Upgrade (Blocked)
- **Problem**: Public outreach via X is halted because the current API tier doesn't allow write operations (`idea-082`).
- **Proposed Fix**: Upgrade X Dev account to 'Basic' or 'Pro' tier.
- **Type**: Config Change (External)

### 3. Paperclip Port 3100 (Blocked)
- **Problem**: Paperclip status is unavailable, blocking lead monitoring (`idea-086`).
- **Proposed Fix**: SSH into `pp-scout-sfo2` and verify the Fastify server and port 3100 availability.
- **Type**: Process Change / DevOps

### 4. OpenClaw Prompt Cache Fix ($2,150+/mo Waste)
- **Problem**: Dynamic `userTime` variables in the OpenClaw prompt prefix are causing a 100% cache-miss rate for Anthropic models, costing $2,150+/mo in redundant tokens.
- **Status (Apr 5)**: `scripts/prefix-telemetry.sh` tracking active prefix hashes.
- **Proposed Fix**: Apply the source patch to the OpenClaw adapter (move `userTime` and session IDs below the `cache_control` block) and restart the gateway.
- **Type**: Code Change / Gateway Restart

### 5. Week 4 Decision Brief (Urgent)
- **Problem**: The final sprint decision brief is overdue because we lack the audit data for demo approval counts.
- **Proposed Fix**: Rod to provide the query results from PostHog/PP DB (Mar 24–Apr 2) and Stripe conversion counts.
- **Type**: Process Change

### 6. Mobile QA Persistent Failure (Medium Priority)
- **Problem**: `mobile-qa-daily` cron has failed 6 times in a row.
- **Diagnostics (Apr 5)**: Likely tied to the Discord provider drift (unable to report results) and a potential regression in the mobile age-gate on 10Web (CDN cache).
- **Proposed Fix**: Debug the 10Web CDN cache issue and verify the `mobile-qa-daily` script logic independently of Discord delivery.
- **Type**: Bug Fix / Process Change

### 7. OpenClaw Core Update (v2026.4.9)
- **Problem**: System heartbeats consistently flag that OpenClaw `2026.4.9` is available for manual update. Keeping the core updated ensures we have the latest tool improvements and stability fixes.
- **Proposed Fix**: Run `openclaw update.run` (or equivalent) after a full backup of `~/.openclaw/config`.
- **Type**: Maintenance / Update
