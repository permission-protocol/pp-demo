# PRD: idea-056 — Detect and show GitHub merge conflicts on PP review page

**Issue:** permission-protocol/app#136
**Priority:** P1
**Repo:** permission-protocol/app

## Problem
When a PR has merge conflicts on GitHub, the PP review page pre-merge checklist shows "No conflicts ✓ OK to proceed" instead of detecting the conflict. The "Merge & Deploy" button remains enabled.

## Requirements

### Must Have
1. Check `mergeable` and `mergeable_state` from the merge-readiness response:
   - `mergeable === false` OR `mergeable_state === 'dirty'` → show conflict warning
   - `mergeable === null` → show "GitHub is computing mergeability..." (not "No conflicts")
   
2. When conflicts detected:
   - Pre-merge checklist shows: "❌ Merge conflicts detected — resolve on GitHub"
   - "Merge & Deploy" button is **disabled** with tooltip "Resolve conflicts first"
   - Link to the GitHub PR for conflict resolution

3. When mergeability is unknown (`null`):
   - Show "Checking for conflicts..." with a subtle spinner
   - Don't show "No conflicts" until `mergeable === true` is confirmed

### Implementation Notes
- The merge-readiness API already returns `mergeable` and `mergeable_state` from GitHub
- Look at `getBranchStatus()` in `review-page-helpers.tsx` — it handles `mergeable_state === 'dirty'` but the page may not be using it correctly for the checklist
- The pre-merge checklist section renders "No conflicts" — find where and gate it on `mergeable === true` (not just absence of error)
- The "Merge & Deploy" button should check `mergeReadiness?.mergeable !== false`

### Files Likely Touched
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — pre-merge checklist + merge button
- Possibly `review-page-helpers.tsx` if `getBranchStatus` needs adjustment

### Must NOT Do
- Don't change the merge-readiness API
- Don't auto-resolve conflicts
- Don't change the polling interval
