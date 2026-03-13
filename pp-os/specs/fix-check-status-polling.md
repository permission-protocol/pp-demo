# Spec: Fix Pre-Merge Checklist — Poll Actual Check Status

## Problem
After approval + successful rerun, the pre-merge checklist shows "⟳ Waiting for checks to re-run..." even though GitHub shows "All checks have passed" (2 successful checks). The Control Plane isn't reading the actual check status from GitHub — it's stuck on a stale internal state.

## Root Cause
The checklist items appear to be derived from internal `githubRerunStatus` fields, not from live GitHub check status. Once the rerun is triggered, the app sets "waiting for checks" but never polls GitHub to confirm they actually passed.

## Expected Behavior
The pre-merge checklist should reflect **real GitHub check status**:

1. **Rerun triggered, checks running:**
   ```
   ⏳ Checks re-running... (1 of 2 passed)
   ```

2. **All checks passed:**
   ```
   ✅ All checks passed (2 of 2)
   ```
   Green checkmark, no spinner.

3. **Some checks failed:**
   ```
   ❌ 1 check failed — Deploy Gate / Permission Protocol
   ```

## Solution

### Option A: Poll GitHub Check Runs (Recommended)
- After rerun is triggered, poll `GET /repos/{owner}/{repo}/commits/{sha}/check-runs` on the server side (every 5-10s via the existing scheduler or a dedicated poller)
- Update the deploy request record with actual check results
- Frontend renders from the updated record

### Option B: Use GitHub Webhooks
- Listen for `check_run` and `check_suite` webhook events
- Update deploy request status in real-time
- More responsive but requires webhook infrastructure

### Option C: Client-Side Polling
- The detail page polls a lightweight API endpoint that fetches GitHub check status
- Less ideal (auth tokens exposed to client) but simplest to implement

## Recommendation
**Option A** — the scheduler already runs every 5s. Add a step that checks GitHub check status for requests in `pending_merge` state with `githubRerunStatus: 'success'`.

## Pre-Merge Checklist Items
The checklist should show these actual items:
- [ ] Checks passed (poll GitHub)
- [x] Branch is up to date with base (already working)
- [ ] No merge conflicts (check GitHub mergeable state)

Each item should have a real pass/fail state, not just static text.

## Files Likely Changed
- Scheduler/poller service — add check-status polling step
- Deploy request model — add fields for check results if needed
- Detail page component — render actual check status

## Priority
High — directly contradicts what GitHub shows. Makes the product look broken.
