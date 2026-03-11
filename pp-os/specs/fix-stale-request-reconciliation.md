# Stale Request Reconciliation

## Problem
When a PR is merged or closed on GitHub outside of PP (directly on GitHub, via CLI, or by another tool), PP's pending deploy requests for that PR remain in the queue forever. Users see stale "pending" requests for PRs that no longer exist.

## Solution
Add a reconciliation endpoint that checks pending requests against GitHub PR state and auto-expires stale ones. Also add inline reconciliation in the dashboard API so the queue is always fresh.

## Changes

### 1. New utility: `src/lib/services/reconcile-stale-requests.ts`

```typescript
export async function reconcileStaleRequests(companyId: string): Promise<{
  checked: number;
  expired: number;
  errors: string[];
}>
```

**Logic:**
1. Query all `DeployGateRequest` where `status = 'pending'` AND `prNumber IS NOT NULL` for the given `companyId`
2. Group by unique `(repo, prNumber)` pairs to minimize GitHub API calls
3. For each unique pair, call GitHub API: `GET /repos/{owner}/{repo}/pulls/{prNumber}` using the company's stored `GITHUB_TOKEN`
4. If PR state is `closed` or `merged`: update all pending requests for that (repo, prNumber) to `status = 'expired'`, set `decidedAt = NOW()`, set `reason = 'PR merged/closed on GitHub'`
5. Return counts of checked and expired

**GitHub token resolution:**
- Use the same `GITHUB_TOKEN` env var that post-approval actions use (already available in `process.env.GITHUB_TOKEN`)
- If no token available, skip reconciliation silently (don't break the flow)

**Rate limiting:**
- Max 10 GitHub API calls per reconciliation run (batch the first 10 unique repo/PR pairs)
- If more than 10, process oldest-first (by `createdAt`) and leave the rest for next run

### 2. New API endpoint: `src/app/api/v1/deploy-requests/reconcile/route.ts`

```
POST /api/v1/deploy-requests/reconcile
```

- Auth: requires session auth (owner/admin role) — same as deploy-requests list
- Calls `reconcileStaleRequests(companyId)`
- Returns: `{ checked: number, expired: number, errors: string[] }`
- This is the manual trigger / cron-callable endpoint

### 3. Inline reconciliation in deploy-requests list endpoint

**File:** `src/app/api/v1/deploy-requests/route.ts`

When `status=pending` or `status=all` is requested, trigger a **background** reconciliation:
- Call `reconcileStaleRequests(companyId)` with `void ... .catch()` (fire-and-forget)
- Don't block the response — the current request returns stale data, next refresh shows cleaned data
- Add a simple throttle: store last reconciliation time in-memory (module-level `Map<companyId, timestamp>`), skip if last run was < 5 minutes ago

### 4. Dashboard "Reconcile" button (optional, low priority)

In `src/app/pp/deploy-requests/page.tsx`, add a small "🔄 Refresh" button near the filter bar that calls `POST /api/v1/deploy-requests/reconcile` then refetches the list.

## What NOT to change
- Don't touch the verify endpoint or the supersede logic
- Don't add GitHub webhooks (that's the GitHub App, separate feature)
- Don't expire requests without a `prNumber` (non-PR requests like direct pushes to main have different lifecycle)
- Don't expire requests for PRs that are still OPEN

## Edge cases
- If GitHub API returns 404 (repo deleted or made private): do NOT expire — could be a permissions issue. Log and skip.
- If GitHub API returns 401/403: skip silently, don't break the flow
- Requests with `prNumber` but no `repo`: skip (shouldn't exist but be defensive)

## Tests
Add `tests/reconcile-stale-requests.test.ts`:
1. Pending request for merged PR → expires
2. Pending request for closed PR → expires  
3. Pending request for open PR → stays pending
4. GitHub API 404 → request not expired (defensive)
5. GitHub API unreachable → graceful skip, no crash
6. Throttle: second call within 5 min returns early
7. Multiple pending requests for same merged PR → all expired

## Commit message
```
feat: auto-expire stale pending requests for merged/closed PRs

Adds reconciliation that checks pending deploy requests against GitHub
PR state. Merged/closed PRs get their pending requests auto-expired.

- New service: src/lib/services/reconcile-stale-requests.ts
- New endpoint: POST /api/v1/deploy-requests/reconcile
- Background reconciliation on deploy-requests list (throttled, 5 min)
- Rate limited to 10 GitHub API calls per run
```
