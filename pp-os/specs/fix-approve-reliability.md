# Fix: Approve Endpoint Reliability

**File:** `src/app/api/v1/deploy-requests/[requestId]/approve/route.ts`

## Problem
1. Receipt created in separate transaction from status update → `approved` with no receipt possible
2. `executePostApprovalActions()` runs synchronously → blocks HTTP response → Render 30s timeout kills it
3. Risk acceptance fields required for failed-verification requests → CLI/API callers hit 3 validation errors

## Changes

### 1. Atomic receipt (merge finalizeIfQuorumMet into main transaction)
- Move receipt creation + signing into the SAME `$transaction` as the approval decision
- Never set `status: 'approved'` without also setting `receiptId`
- Delete the standalone `finalizeIfQuorumMet()` function — it's now inline

### 2. Async post-approval
- After the transaction commits and response is ready, fire post-approval as fire-and-forget
- Use existing `enqueueJob('deploy_gate_post_approval', ...)` pattern (worker already exists for reruns)
- Return the response IMMEDIATELY with `post_approval_result: { status: 'queued' }`
- The worker handles: commit status, merge attempt, GitHub workflow rerun
- If enqueue fails, log warning but still return success (approval is the critical path, not side effects)

### 3. Default risk acceptance
- If `verificationStatus === 'FAILED'` and caller omits `riskAcceptanceCategory`, default to `'OTHER'`
- If caller omits `riskAcceptanceReason`, default to `'Approved via Permission Protocol'`
- Remove the hard validation that blocks approval without these fields
- Still store whatever the caller provides if they DO send values

## What NOT to change
- Quorum logic (works fine)
- Signing logic (works fine)
- Rate limiting (works fine)
- The reapprove endpoint (separate file, separate fix if needed)

## Test
- Approve a pending request via CLI with just `{ productionConfirmed: true }` — should succeed
- Receipt must exist after approval (not null)
- Post-approval actions should complete async (check worker logs)
- Response time should be < 2s (was timing out at 30s)
