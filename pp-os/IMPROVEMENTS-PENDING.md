# IMPROVEMENTS PENDING — Rod's Review — 2026-03-31

## URGENT BLOCKERS (Week 4 Final Sprint)
1. **X API Upgrade:** Outreach is currently 100% blocked on Permission Protocol side. Need X Developer account upgrade (Basic/Pro) to allow write access.
2. **Paperclip Port 3100:** SSH into `pp-scout-sfo2` needed to fix port 3100 timeout for telemetry monitoring.
3. **HN Login:** Need Rod to verify login for automated HN comment work on `idea-079`.

## SUGGESTED AUDITS
- **Cron Failures:** 16 cron jobs are persistently failing due to "Unsupported channel" or Gemini rate limits. Requesting a 15-minute sync to either:
  - (a) Fix the channel plugin config (discord/telegram)
  - (b) Disable/prune low-value crons that are just wasting context/rate limits.

## COST SAVINGS REPORT
- **Prompt Prefix Cache Fix:** Successfully identified and patched the `userTime` cache-busting bug.
- **Projected Savings:** Based on March spend ($5,300 total, ~$2.6k wasted on cache misses), this fix should reduce monthly burn by ~40-50% for high-volume Anthropic runs.
- **Telemetry:** Implemented `scripts/prefix-telemetry.sh` to proactively monitor prefix stability going forward.

## PROCESS UPDATES
- Added **Prompt Cache Stability Protocol** to `AGENTS.md` to prevent future regressions.
- Added **Middleware Path Normalization** rule to `AGENTS.md` (fixes `/demo` vs `/demo/` mismatch).
