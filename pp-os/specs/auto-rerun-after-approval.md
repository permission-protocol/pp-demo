# Spec: Auto-Rerun GitHub Action After PP Approval

**Status:** In Progress
**Date:** 2026-03-12
**Context:** [Discord thread — Ideal Approval Screen](https://discord.com/channels/1479269120334762008/1481392726070005770)

---

## Problem

After approving a deploy request in PP's review surface, the GitHub Action (Deploy Gate) still shows ❌ because it failed during the initial "pending approval" phase. The approver has to manually go to GitHub and re-run the action — which defeats the purpose of PP being the single approval surface.

## Existing Solution (PP App)

The PP app (`permission-protocol/app`) already has a complete rerun system:

1. **`src/lib/post-approval-actions.ts`** — Sets commit status → retries merge with backoff
2. **`src/lib/services/github-rerun.ts`** — Hybrid rerun: `check_run` rerequest → `actions/runs` rerun fallback. Retry with backoff, audit trail.
3. **`src/lib/services/deploy-gate-post-approval.ts`** — Orchestrator: post-approval → enqueue rerun job → auto-deploy triggers
4. **`src/components/ui/rerun-status-badge.tsx`** — UI status badge

The PP app uses a worker queue (`enqueueJob`) to process reruns asynchronously with DB-backed state tracking.

## Solution for Marketing Site

The marketing site (`permission-protocol/site`) can't use the worker queue or Prisma. Instead:

### Approach: Call PP API's rerun endpoint directly

After the site's approve route succeeds:
1. Fetch the deploy request's `runId` and `checkRunId` from the PP API response
2. Trigger a rerun via GitHub API (same hybrid strategy as the PP app)
3. Show rerun status in the UI

### Implementation

**Modify `app/api/review/[id]/approve/route.ts`:**

After Step 2 (set commit status), add Step 2.5:

```
// Step 2.5: Trigger GitHub Action rerun
// The deploy-gate action run failed with "pending approval" —
// now that we've approved, re-run it so it passes.
```

Use the same hybrid strategy as `github-rerun.ts`:
1. Try `POST /repos/{owner}/{repo}/check-runs/{checkRunId}/rerequest` (check run rerun)
2. If 404 or no checkRunId, try `POST /repos/{owner}/{repo}/actions/runs/{runId}/rerun` (workflow rerun)
3. If neither ID is available, look up the failed run from the PR's check suites

**Getting runId/checkRunId:**
- The deploy request record in PP API contains `runId` and `checkRunId` (set by the deploy-gate action)
- Fetch from `fetchRequestDetails()` which already returns the full request record
- Fallback: query GitHub's check-runs API for the PR's head SHA, find the "Deploy Gate" run

**UI changes in `ReviewPageClient.tsx`:**
- After approve succeeds, show rerun status: "⟳ Re-running Deploy Gate..." → "✅ Deploy Gate re-triggered"
- If rerun fails: "⚠️ Manual rerun needed — [Re-run on GitHub](link)"

## What We're Stealing from the PP App

| Pattern | PP App | Site Implementation |
|---------|--------|-------------------|
| Hybrid rerun strategy | `check_run` → `actions_run` fallback | Same |
| Retry with backoff | 3 attempts, 1s/4s/9s | 2 attempts, 1s/3s (simpler, synchronous) |
| Audit trail | DB audit events | PP API approval already creates audit |
| Status tracking | DB field `githubRerunStatus` | Response field + UI state |
| Error classification | transient vs permanent | Same (simplify to success/failed/manual) |

## Non-Goals
- No worker queue (site has no background jobs)
- No DB state tracking (site is stateless, uses PP API)
- No merge from the rerun (merge is already handled separately via the merge button)
