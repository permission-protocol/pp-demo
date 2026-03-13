# Spec: Post-Approval Lifecycle & Merge Tracking

## Problem
PP treats "Approved" as a terminal state. But users care about "did it ship?" — not just "did someone click approve." When a PR is approved but not merged (build failure, branch conflict, branch outdated), PP gives no signal. The dashboard shows it in "Recently Approved" with no indication that action is still needed.

Additionally, two separate GitHub checks ("Permission Protocol" commit status + "PR Gate / Permission Protocol" workflow) create confusion — one green, one red.

## Changes

### 1. Track Merge Status on Approved Requests

**Data model:** Add `mergeStatus` field to `DeployGateRequest`:
```
mergeStatus: "not_applicable" | "pending_merge" | "merged" | "merge_failed" | "closed_without_merge"
mergedAt: DateTime?
mergeSha: String?
```

Default: `"not_applicable"` (for non-PR requests or pre-existing records).

When a request is approved:
- If it has a PR number → set `mergeStatus = "pending_merge"`
- Post-approval action attempts merge → on success: `"merged"` + `mergedAt` + `mergeSha`
- Post-approval merge fails → `"merge_failed"` (branch conflict, build failing, etc.)
- PR closed without merge (webhook or reconciliation) → `"closed_without_merge"`

**Dashboard changes:**
- **"Needs Attention" section** surfaces:
  - Approved requests where `mergeStatus = "pending_merge"` for >10 min
  - Approved requests where `mergeStatus = "merge_failed"`
  - Card shows: PR title, time since approval, reason (if known)
  - Action button: "Retry Merge" or "View on GitHub"
- **"Recently Approved" cards** show merge indicator:
  - 🟢 Merged (with relative timestamp)
  - 🟡 Awaiting merge
  - 🔴 Merge failed

**Stats bar update:**
- Current: Pending | Approved | Denied
- New: Pending | Approved (Unmerged) | Shipped | Denied
- "Shipped" = approved + merged. This is the number that matters.

### 2. Gate Action: Exit 0 After Approval

**Problem:** Two checks show on the PR:
- "Permission Protocol" (commit status) → ✅ set by PP after approval
- "PR Gate / Permission Protocol" (workflow job) → ❌ because the gate action exits 1

The gate action currently: verify → no receipt → exit 1 (fail). After approval, the commit status is set to success externally, but the *workflow run* that originally failed still shows red. Users see one green check and one red check.

**Fix in deploy-gate action (`action.yml`):**
After setting commit status to `success`, the gate should exit 0:
```bash
if [ "$VALID" = "true" ]; then
  set_commit_status "success" ...
  exit 0  # ← already does this
fi
```

The issue is that the *first* run exits 1 (no receipt yet), and that run stays red forever. When the commit status is later set to success (by PP after approval), GitHub re-evaluates the required status check — but the workflow badge stays red.

**Real fix:** The gate needs to be **re-run** after approval so the workflow shows green too. This already happens via `rerun_workflow` in post-approval actions. The fix is ensuring `rerun_workflow` actually fires reliably:
- Verify it's called in `deploy-gate-post-approval.ts`
- If rerun fails (permissions, API error), log but don't block

**Short-term:** Document that the workflow badge may show red even when the commit status is green. The *required check* is the commit status, not the workflow badge.

**Long-term (GitHub App):** The App sets commit status directly as a trusted integration. No workflow needed for the status check — the gate workflow becomes optional (just for the PR comment UX).

### 3. Dashboard Merge Indicator on Approved Cards

**Deploy requests list page** (`/pp/deploy-requests`):
Each card gets a merge status pill next to the approval status:
```
✅ Approved · 🟢 Merged 2m ago
✅ Approved · 🟡 Awaiting merge
✅ Approved · 🔴 Merge failed
```

**Review detail page** (`/pp/deploy-requests/[requestId]`):
After the approval section, add a "Deployment Status" section:
```
📦 Deployment Status
├─ ✅ Approved by rod — 5 minutes ago
├─ 🔄 Merge attempted — failed (branch out of date)
└─ 🟡 PR still open on GitHub
    [Retry Merge] [View on GitHub]
```

Or if merged:
```
📦 Deployment Status
├─ ✅ Approved by rod — 5 minutes ago
├─ ✅ Merged — 3 minutes ago (abc1234)
└─ 🟢 Shipped
```

**Marketing site review page** (`permissionprotocol.com/review/{id}`):
Same merge status indicator. The API already returns `pr_merged` and `pr_merge_sha` — just need to surface it more prominently when the request is approved.

## Implementation Plan

### Issue A: Merge tracking data model + post-approval update
- Add `mergeStatus`, `mergedAt`, `mergeSha` to Prisma schema
- Update post-approval service to set merge status on success/failure
- Update reconciliation service to set `closed_without_merge` on PR close
- Update webhook handler (PR close) to set merge status
- Migration

### Issue B: Dashboard merge indicators
- Update stats endpoint to include "shipped" count
- Update dashboard "Needs Attention" to surface stuck approvals
- Update "Recently Approved" cards with merge status pill
- Update deploy requests list page with merge indicator

### Issue C: Review detail page deployment status
- Add "Deployment Status" timeline section to detail page
- Show merge attempt history (success/failure/retry)
- "Retry Merge" button for failed merges
- "View on GitHub" link

### Issue D: Gate action rerun reliability
- Audit `rerun_workflow` in post-approval service
- Ensure it fires and logs failures gracefully
- Add "Re-run Gate" button to dashboard for manual retry

## Dependencies
- Issue A is foundation (must land first)
- Issues B, C, D can be parallel after A
- GitHub App (#39-#44) will improve rerun reliability (App token > PAT)
