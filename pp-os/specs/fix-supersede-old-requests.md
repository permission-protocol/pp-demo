# Fix: Auto-Supersede Old Requests Per PR

## Problem
Every SHA creates a new deploy request. Branch updates → new request → old request lingers as "pending". User sees 9 pending for 5 PRs. Confusing, no flow.

## Backend Change

**File:** `src/app/api/v1/receipts/verify/route.ts` (the request creation path)

When creating a new deploy request, BEFORE the insert:
1. Query `deployGateRequest` for existing `pending` requests with same `(companyId, repo, prNumber)` and different `commitSha`
2. Update those to `status: 'superseded'`, set `supersededByRequestId: newRequest.id`
3. Then create the new request

The `deployGateRequest` model already has `supersededByRequestId` field (used by reapprove). Just need to use it in the creation path.

**File:** `src/app/api/v1/deploy-requests/route.ts` (the list endpoint)

Default filter should EXCLUDE `superseded` status. Add `includeSuperseded=true` query param to show them.

## Frontend Change

**File:** `src/app/pp/deploy-requests/page.tsx`

1. Hide superseded requests by default (backend handles this)
2. Show "N older versions hidden" link to expand if curious
3. Sort: pending first, then by createdAt desc (newest first within pending)

## What NOT to change
- Approved/redeemed/denied requests stay visible
- The supersede only happens for `pending` → `superseded` (never touch resolved requests)
- The verify endpoint's carry-forward logic (separate concern)

## Test
- Push two commits to same PR → first request becomes superseded, only latest shows
- Queue count matches open PR count
