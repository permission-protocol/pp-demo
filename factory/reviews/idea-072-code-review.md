# Code Review: idea-072 — Mobile approval Phase 4: polish + advanced UX
**Date:** 2026-03-19 23:09 UTC
**Branch:** factory/idea-072
**Files:** 4 changed

REVIEW_SUMMARY: 6 issues (1 critical, 5 informational)

**CRITICAL** (blocks merge):
- [app/review/ReviewDashboard.tsx:255] `JSON.parse()` on `localStorage` input without try/catch can crash the app if data is corrupted.
  Fix: Wrap `JSON.parse` in a try/catch block and fallback to an empty array on error.

**INFORMATIONAL** (non-blocking):
- [app/login/page.tsx:7] Missing React error boundary (`error.tsx`) for the new page component.
  Fix: Add an `error.tsx` file to handle rendering errors for the login route.
- [app/review/ReviewDashboard.tsx:193] Large component exceeds 200 lines and should be split into smaller sub-components.
  Fix: Extract tab content and dialogs into separate component files.
- [app/review/ReviewDashboard.tsx:545] Inline `style={{}}` object created on every render.
  Fix: Extract to a CSS class or a memoized constant outside the render loop.
- [src/components/SwipeableCard.tsx:181] Inline `style={{}}` object created on every render.
  Fix: Extract to a CSS class or a memoized constant.
- [app/review/ReviewDashboard.tsx:438] Magic number `72` used in multiple places for the pull-to-refresh threshold.
  Fix: Extract to a named constant like `PULL_REFRESH_THRESHOLD`.
