# Bugfix: idea-027 — Pre-merge checklist stuck on 'Checking'

## Symptom
After PP approval and all GitHub checks passing (6/6 green), the PP review page pre-merge checklist still shows "Checking" for branch status and "Waiting for GitHub mergeability status..." The Merge & Deploy button stays disabled even though GitHub shows the PR is mergeable.

## Affected Files
- `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts` — the API endpoint
- `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/cache.ts` — cache layer
- `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx` — `getBranchStatus()` function (line ~411)
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — the review page that polls this endpoint

## Root Cause Analysis
Two related issues:

1. **Cache staleness**: `getCachedMergeReadiness()` returns stale data after approval. When the PP status changes to "approved", GitHub re-runs checks (due to `strict: true` branch protection). But the cached merge-readiness from BEFORE approval still shows the old state. The cache TTL may be too long or there's no invalidation on status change.

2. **Retry gives up too early**: `fetchPullRequestWithRetry()` only retries 3 times with 1s delay when `mergeable === null`. After GitHub re-runs checks post-approval, `mergeable` goes back to `null` temporarily. If the client polls during this window and retries fail, it returns `mergeable: null` which the frontend shows as "Checking..."

The `getBranchStatus()` function's default case (line ~430) returns `{ tone: 'pending', label: 'GitHub is still computing mergeability' }` — this is the stuck state.

## Fix Approach
1. **Invalidate cache on approval**: When the deploy request status changes to "approved", call `invalidateCachedMergeReadiness()` so the next poll gets fresh data
2. **Increase retry count and delay**: Change `MAX_MERGEABLE_RETRIES` from 3 to 5 and `MERGEABLE_RETRY_DELAY_MS` from 1000 to 2000 — gives GitHub more time to compute mergeability after check re-runs
3. **Add a "Refresh" action in the UI**: When `mergeable_state` is stuck on unknown/null for >30s, show a "Refresh" button that calls `invalidateCachedMergeReadiness()` via a POST endpoint, then re-polls
4. **Handle the "approved + blocked" state**: In `getBranchStatus()`, when `requestStatus === 'approved'` and `mergeable_state` is null/unknown, show "Checks re-running after approval..." instead of generic "Checking"

## Acceptance Criteria
- [ ] Cache is invalidated when deploy request is approved
- [ ] MAX_MERGEABLE_RETRIES increased to 5, delay to 2000ms
- [ ] `getBranchStatus()` shows "Checks re-running after approval..." when approved + unknown state
- [ ] Pre-merge checklist resolves within 30s of all checks passing
- [ ] Existing tests still pass
- [ ] `tsc --noEmit` passes on changed files

## Files to Change
- `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts` — increase retries
- `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/cache.ts` — add cache invalidation hook
- `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx` — improve getBranchStatus default case
- `src/app/api/v1/deploy-requests/[requestId]/approve/route.ts` (or equivalent) — trigger cache invalidation on approval

## Test Plan
1. Run `npx tsc --noEmit` — should pass
2. Run existing tests — should pass
3. Full verification requires deployed instance with GitHub App + branch protection

## Codex Prompt
You are fixing a bug where the pre-merge checklist gets stuck showing "Checking" after PP approval.

**Root cause**: The merge-readiness cache returns stale data after approval, and the retry logic gives up too early when GitHub is recomputing mergeability.

**Changes needed:**

1. In `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/route.ts`:
   - Change `MAX_MERGEABLE_RETRIES` from 3 to 5
   - Change `MERGEABLE_RETRY_DELAY_MS` from 1000 to 2000

2. In `src/app/api/v1/deploy-requests/[requestId]/merge-readiness/cache.ts`:
   - Export a function to invalidate cache by requestId (if not already exported)

3. Find the approval endpoint (likely `src/app/api/v1/deploy-requests/[requestId]/approve/route.ts` or similar action handler). After setting status to "approved", call `invalidateCachedMergeReadiness(companyId, requestId)`.

4. In `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx`:
   - In `getBranchStatus()`, change the default case: when `requestStatus === 'approved'`, return `{ tone: 'pending', label: 'Checks re-running after approval, refreshing...' }` instead of generic "GitHub is still computing mergeability"

Before finishing, run `npx tsc --noEmit` and fix any type errors.
