# QA Report: idea-036 — Move approve/deny buttons directly below verdict banner
**Date:** 2026-03-14 02:25 UTC
**PR:** https://github.com/permission-protocol/app/pull/113
**Retry:** #0

## Automated Checks
- [x] TypeScript: clean (0 errors in PR files, 115 pre-existing)
- [x] Lint: clean
- [x] Tests: passed
## Diff Summary
Files changed: 1
```
 src/app/pp/deploy-requests/[requestId]/page.tsx | 755 ++++++++++++------------
 1 file changed, 379 insertions(+), 376 deletions(-)
```

## File Coverage
- [x] File coverage: skipped (no paths in PRD)
## Visual Capture
Peekaboo screenshots pending — Charles to capture
## Mobile QA
Mobile QA: disabled

## PRD Acceptance Criteria
- [ ] Approve/Deny buttons visible without scrolling on mobile (390px wide)
- [ ] Buttons appear directly after the verdict banner
- [ ] Expired requests show "Re-run Workflow" in the same position
- [ ] Approved requests show "Approved by" bar in the same position
- [ ] Desktop layout still looks good (buttons don't look weird in wide viewport)
- [ ] All existing approve/deny functionality still works (no broken handlers)
- [ ] `tsc --noEmit` passes
## Verdict
Automated checks: PASSED
Visual review: PENDING
PRD criteria: PENDING
