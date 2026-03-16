# Bugfix: idea-032 — Prisma FK violation on supersededByRequestId

## Symptom
Deploy request creation fails with: `Foreign key constraint violated: DeployGateRequest_supersededByRequestId_fkey`. This means NO new deploy requests can be created, which completely blocks the PP approval flow.

## Affected Files
- `src/app/api/v1/receipts/verify/route.ts` — the supersede logic around line 582-598

## Root Cause Analysis
In the verify endpoint's transaction, the supersede logic runs BEFORE the new request is created:

```
1. updateMany: set old requests' supersededByRequestId = newRequestId  ← FK points to non-existent ID!
2. create: create the new request with id = newRequestId               ← this is where the ID is born
```

`supersededByRequestId` is a foreign key to `DeployGateRequest.id`. Setting it to `newRequestId` before that request exists violates the FK constraint.

## Fix Approach
Reorder the operations inside the transaction:
1. **First** create the new deploy request
2. **Then** update old pending requests to set `supersededByRequestId` to the newly created request's ID

This is safe because both operations are in the same Prisma transaction — either both succeed or neither does.

## Acceptance Criteria
- [ ] New deploy requests are created successfully (no FK violation)
- [ ] Old pending requests in the same lane are still superseded correctly
- [ ] `supersededByRequestId` points to the newly created request's actual ID
- [ ] Existing tests pass
- [ ] `tsc --noEmit` passes

## Codex Prompt
You are fixing a critical Prisma foreign key violation in the deploy request creation flow.

In `src/app/api/v1/receipts/verify/route.ts`, find the transaction block around line 580-600 that:
1. Updates old pending requests with `supersededByRequestId: newRequestId`
2. Creates the new deploy request

The bug: step 1 sets a FK to an ID that doesn't exist yet (step 2 hasn't run).

Fix: Swap the order.
1. First, create the new deploy request (the `tx.deployGateRequest.create(...)` call)
2. Then, update old pending requests with `supersededByRequestId: created.id` (using the actual created record's ID)

You'll need to:
- Move the `tx.deployGateRequest.create(...)` block BEFORE the `tx.deployGateRequest.updateMany(...)` block
- Change `supersededByRequestId: newRequestId` to use the actual created record's `id` (e.g., `created.id`)
- Make sure the variable holding the created request is available for the updateMany
- Keep both operations inside the same `tx` (transaction)

Also check: is `newRequestId` generated with `cuid()` or similar? If so, you can keep generating it upfront and pass it as `id` in the create call — that way the ID is known before create. Either approach works.

Before finishing, run `npx tsc --noEmit` and fix any type errors.
