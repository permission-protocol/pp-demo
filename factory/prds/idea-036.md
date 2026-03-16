# Feature: idea-036 — Move approve/deny buttons directly below verdict banner

## Summary
On mobile, the approve/deny buttons are below the fold — Marco has to scroll past PR title, metadata, and request details before he can take action. Move the action buttons to immediately after the verdict banner so approval takes <5 seconds.

## Affected Files
- `src/app/pp/deploy-requests/[requestId]/page.tsx`

## Current Layout (mobile, top-to-bottom)
1. Header bar (company, nav)
2. Tab bar (Dashboard, Deploy, Repositories)
3. Verdict banner (🟢 ROUTINE — description)
4. Environment banner (⚠️ PRODUCTION)
5. "Updated just now"
6. Expired overlay / Re-run Workflow (if expired)
7. PR title ("feat: Phase 1 approval surface visual alignment")
8. Repo/PR/commit metadata
9. Request Details card
10. At a Glance card
11. **Approve / Deny buttons** ← TOO FAR DOWN

## Target Layout
1. Header bar
2. Verdict banner
3. **Approve / Deny buttons** ← MOVED HERE (or Re-run Workflow if expired)
4. Environment banner (merged into verdict if idea-037 also ships)
5. At a Glance card (status, blast radius, quorum)
6. PR title + metadata
7. Request Details
8. Audit Trail

## Implementation

The approve/deny button group currently renders inside a larger decision section around line ~1496-1530. Extract it into its own component or JSX block and render it IMMEDIATELY after the verdict banner.

Key constraints:
- The buttons depend on: `handleApprove`, `handleDeny`, `approveDisabled`, `decisionState`, `decisionMode`, `showDenyOptions`, `decisionNote`, `showDecisionNote`
- All these are already defined at the top of the component via useState/useCallback — moving the JSX is safe
- Only show the buttons when `request.status === 'pending'`
- When expired, show the "Re-run Workflow" button in the same position instead
- When already approved, show the green "Approved by @user" bar

Find the VerdictBanner rendering (around line ~1415-1420) and the EnvironmentBanner rendering (around line ~1417). Insert the action buttons JSX block right after them.

The existing button block around lines 1496-1530 should be MOVED (cut from its current location, paste after verdict). Don't duplicate it.

## Acceptance Criteria
- [ ] Approve/Deny buttons visible without scrolling on mobile (390px wide)
- [ ] Buttons appear directly after the verdict banner
- [ ] Expired requests show "Re-run Workflow" in the same position
- [ ] Approved requests show "Approved by" bar in the same position
- [ ] Desktop layout still looks good (buttons don't look weird in wide viewport)
- [ ] All existing approve/deny functionality still works (no broken handlers)
- [ ] `tsc --noEmit` passes

## Codex Prompt
You are reorganizing the layout of the deploy request review page for mobile-first UX.

In `src/app/pp/deploy-requests/[requestId]/page.tsx`:

1. Find the VerdictBanner rendering (search for `<VerdictBanner` or the verdict banner div). It's around line 1415-1420.
2. Find the approve/deny button group. Search for `handleApprove` button onClick — there are TWO sets of approve/deny buttons (one in the main decision section around line 1496, and one in a mobile/desktop variant around line 1950). Focus on the PRIMARY set.
3. MOVE (not copy) the approve/deny buttons to render immediately AFTER the VerdictBanner and EnvironmentBanner.
4. Wrap the moved buttons in a container: `<div className="px-4 py-3">` (or similar padding matching the page).
5. Keep all the same conditional rendering: only show when status === 'pending', show approved bar when approved, etc.
6. Remove the buttons from their OLD location to avoid duplication.

Don't change any button styling, handlers, or state logic — just move the JSX.

Before finishing, run `npx tsc --noEmit` and fix any type errors. Also run `npx next lint` and fix any lint errors.
