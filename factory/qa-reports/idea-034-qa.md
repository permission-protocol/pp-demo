# QA Report: idea-034 — Visual preview screenshots in PP review page
**Date:** 2026-03-14 00:18 UTC
**PR:** https://github.com/permission-protocol/app/pull/108
**Retry:** #0

## Automated Checks
- [x] TypeScript: clean (0 errors in PR files, 115 pre-existing)
- [x] Lint: clean
- [x] Tests: passed
## Diff Summary
Files changed: 3
```
 .../[requestId]/preview-url/cache.ts               |  41 +++++
 .../[requestId]/preview-url/route.ts               | 187 +++++++++++++++++++++
 src/app/pp/deploy-requests/[requestId]/page.tsx    | 137 +++++++++++++++
 3 files changed, 365 insertions(+)
```

## File Coverage
- [x] File coverage: skipped (no paths in PRD)
## Visual Capture
Peekaboo screenshots pending — Charles to capture
## Mobile QA
Mobile QA: disabled

## PRD Acceptance Criteria
- [ ] New API endpoint returns Vercel preview URL for deploy requests with PR context
- [ ] VisualPreview section appears on the review page below the AI summary
- [ ] Shows an interactive iframe of the preview deployment
- [ ] Shows loading state while fetching preview URL
- [ ] Shows fallback message when no preview URL is available
- [ ] "Open in new tab" link opens the preview in a new window
- [ ] iframe has a reasonable height (500px desktop, 400px mobile) with a resize handle or expand button
- [ ] Works on mobile viewport
- [ ] `tsc --noEmit` passes
- [ ] Existing tests pass
## Verdict
Automated checks: PASSED
Visual review: PENDING
PRD criteria: PENDING
