# PRD: idea-055 — Hide merge failure UI when PR is already merged

**Issue:** permission-protocol/app#135
**Priority:** P1
**Repo:** permission-protocol/app

## Problem
When a PR is already merged on GitHub (badge shows "✓ PR merged on GitHub"), the page still displays:
- "⚠ Merge failed" warning banner
- "Merge & Deploy" button
- Pre-merge checklist with "All checks passed"

User sees "merged" and "failed" simultaneously — contradictory and trust-eroding.

## Requirements
1. Detect when the PR is already merged on GitHub
   - Check `mergeReadiness?.merged === true` or the GitHub PR state
   - Or check if the "PR merged on GitHub" badge is already rendering (the data is there)

2. When PR is merged:
   - **Hide** the "Merge failed" / post-approval error banner entirely
   - **Hide** the "Merge & Deploy" button
   - **Hide** or collapse the pre-merge checklist
   - **Show** a clean terminal state: "✓ Merged on GitHub" with timestamp
   - If the merge was external (not via PP), optionally note: "Merged externally"

3. If `mergeStatus === 'merge_failed'` BUT PR is merged on GitHub:
   - Update the internal status to reflect reality (mark as merged)
   - Or at minimum, don't show the failure banner

## Implementation Notes
- The page already has the "PR merged on GitHub" badge logic — look at what condition triggers it
- Gate the `postApprovalBanner` rendering on `!prIsMerged`
- Gate the merge button on `!prIsMerged`
- The pre-merge checklist section should collapse or show "Complete" when merged

## Files Likely Touched
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — main review page

## Must NOT Do
- Don't change the merge-readiness API response
- Don't auto-close the deploy request (that's a separate flow)
