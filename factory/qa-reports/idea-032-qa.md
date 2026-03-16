# QA Report: idea-032 — Prisma FK violation on supersededByRequestId during deploy request creation
**Date:** 2026-03-14 01:25 UTC
**PR:** https://github.com/permission-protocol/app/pull/111
**Retry:** #0

## Automated Checks
- [x] TypeScript: clean (0 errors in PR files, 115 pre-existing)
- [x] Lint: clean
- [x] Tests: passed
## Diff Summary
Files changed: 2
```
 src/app/api/v1/receipts/verify/route.ts  | 34 ++++++++++++++++----------------
 tests/deploy-gate-verify-request.test.ts |  4 ++++
 2 files changed, 21 insertions(+), 17 deletions(-)
```

## File Coverage
- [x] File coverage: skipped (no paths in PRD)
## Visual Capture
Peekaboo screenshots pending — Charles to capture
## Mobile QA
Mobile QA: disabled

## PRD Acceptance Criteria
- [ ] New deploy requests are created successfully (no FK violation)
- [ ] Old pending requests in the same lane are still superseded correctly
- [ ] `supersededByRequestId` points to the newly created request's actual ID
- [ ] Existing tests pass
- [ ] `tsc --noEmit` passes
## Verdict
Automated checks: PASSED
Visual review: PENDING
PRD criteria: PENDING
