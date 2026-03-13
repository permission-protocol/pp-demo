# Spec: PP App Post-Approval Flow Fix

**Status:** Building NOW
**Date:** 2026-03-12
**Priority:** Blocks Rod's daily workflow + demo

---

## Problems

Rod's current flow after approving in the PP app Control Plane:

1. "Merge & Deploy" button never activates — shows "No check runs reported (0/0)"
2. Approved_by shows raw internal ID (e.g. "cmkrc6fib000090cjwvvrstlq") not username
3. GitHub Action doesn't auto-rerun after approval
4. No indication anything is happening post-approval
5. "Back to Queue" loses the approved PR — no way to get back without GitHub
6. No clarity on whether deploy is automatic or manual

## Root Cause Analysis

The code for post-approval actions EXISTS in the PP app:
- `src/lib/post-approval-actions.ts` — sets commit status + retries merge
- `src/lib/services/deploy-gate-post-approval.ts` — orchestrates post-approval
- `src/lib/services/github-rerun.ts` — hybrid rerun strategy
- approve route enqueues `deploy_gate_post_approval` job

**Likely failure point:** The in-memory queue's `.start()` may not be called, or the worker handlers aren't registered for `deploy_gate_post_approval` and `deploy_gate_github_rerun` job types. Jobs get enqueued but never processed.

## Investigation Needed

1. Check if queue `.start()` is called on app boot
2. Check if handlers are registered for deploy_gate_post_approval and deploy_gate_github_rerun
3. Check Render logs for `[Queue] Enqueued deploy_gate_post_approval` entries
4. Check if there are corresponding `[Queue] Processing` entries

## Fixes

### Fix 1: Ensure worker processes post-approval jobs
- Verify queue.start() is called
- Verify handlers are registered for both job types
- If not, register them in the worker initialization

### Fix 2: Approved_by should show GitHub username
- The approve route uses `signerActorKey` which is `user:{userId}` 
- Need to resolve userId to GitHub username via the User table
- Show "Approved by @rodcarvalho" not "cmkrc6fib000090cjwvvrstlq"

### Fix 3: Post-approval status UI
- After approval, show real-time status: "Setting commit status..." → "Re-running checks..." → "Merging..." → "Deployed"
- Poll the request's postApprovalActionStatus field
- If merge fails, show error + retry button

### Fix 4: "Merge & Deploy" button should poll checks
- Fetch PR check status from GitHub
- Show check run progress
- Enable merge button when checks pass
- If auto-merge is configured, show "Auto-merging..." state

### Fix 5: Navigation after approval
- Don't lose the request when going "Back to Queue"
- Show "Recently Approved" section or keep approved items visible briefly
- Or stay on the request detail page with live status updates
