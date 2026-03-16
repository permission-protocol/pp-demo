# PRD: idea-054 — Fix check-status spinner race condition

**Issue:** permission-protocol/app#134
**Priority:** P2
**Repo:** permission-protocol/app

## Problem
"Setting up checks..." spinner shows alongside "All checks passed ✓" in the pre-merge checklist. Contradictory UI.

## Root Cause
Race condition: `mergeReadiness.checks_passing === checks_total` (all passed) while `mergeable_state` is still `unknown` or refreshing. The spinner is gated on mergeable_state, not check results.

## Requirements
- If all checks are passing (`checks_passing === checks_total && checks_total > 0`), hide the "Setting up checks..." spinner regardless of `mergeable_state`
- Only show "Setting up checks..." when `checks_total === 0` AND `mergeReadiness` is still loading
- If `mergeable_state === 'unknown'` but checks are passing, show "Waiting for GitHub to confirm mergeability..." (no spinner, just subtle text)

## Files Likely Touched
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — the pre-merge checklist rendering section

## Must NOT Do
- Don't change the merge-readiness API
- Don't change the polling interval
