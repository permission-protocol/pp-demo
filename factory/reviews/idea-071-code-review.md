# Code Review: idea-071 — Mobile approval Phase 3: push notifications + PWA
**Date:** 2026-03-16 23:08 UTC
**Branch:** factory/idea-071
**Files:** 13 changed

REVIEW_SUMMARY: 6 issues (6 critical, 9 informational)

**CRITICAL** (blocks merge):
- [app/api/reviews/route.ts:5] New API route without authentication check.
  Fix: Add `getServerSession` or auth middleware to protect the endpoint.
- [app/review/ReviewDashboard.tsx:88] `JSON.parse()` on `localStorage` item without try/catch.
  Fix: Wrap `JSON.parse()` in a try/catch block to handle malformed data.
- [app/review/ReviewDashboard.tsx:96] Type assertion `as ReviewsResponse` on external API response.
  Fix: Use a Zod schema or similar runtime validation for the API response.
- [app/review/ReviewDashboard.tsx:100] Type assertion `as string[]` on `localStorage` item.
  Fix: Use a Zod schema or similar runtime validation for `localStorage` data.
- [public/sw.js:95] External notification data (`event.notification.data?.url`) used for navigation without validation.
  Fix: Validate `targetUrl` to ensure it's a safe, internal path before navigating.
- [src/components/InstallPrompt.tsx:40] Type assertion `event as BeforeInstallPromptEvent` on external browser event.
  Fix: Add runtime checks for expected properties of `event` or use a more robust type guard.

**INFORMATIONAL** (non-blocking):
- [app/review/ReviewDashboard.tsx:126] Generic error message returned to UI without logging the actual error.
  Fix: Log `nextError` to a structured logger for debugging.
- [app/review/ReviewDashboard.tsx:158] Generic error message returned to UI without logging the actual error.
  Fix: Log the error to a structured logger for debugging.
- [src/components/ServiceWorkerRegistrar.tsx:13] Bare `catch(e)` that swallows the error without logging.
  Fix: Log the service worker registration error for debugging purposes.
- [app/review/ReviewDashboard.tsx:21] `urlBase64ToUint8Array` is a utility function that could be extracted.
  Fix: Move `urlBase64ToUint8Array` to a shared utility file (e.g., `src/lib/utils.ts`).
- [app/review/ReviewDashboard.tsx:32] `riskClasses` is a utility function that could be extracted.
  Fix: Move `riskClasses` to a shared utility file or a dedicated UI helper.
- [app/api/reviews/route.ts] New API route with no corresponding test file.
  Fix: Add a test file for `/api/reviews` endpoint.
- [public/sw.js] New Service Worker logic with no corresponding test file.
  Fix: Add tests for service worker caching and notification handling logic.
- [app/review/ReviewDashboard.tsx:124] Error/failure path for API fetch has no negative test.
  Fix: Add a test case that simulates a failed API fetch and verifies error handling.
- [app/review/ReviewDashboard.tsx:266] Large component (>200 lines) that should be split.
  Fix: Refactor `ReviewDashboard` into smaller, more focused components.
