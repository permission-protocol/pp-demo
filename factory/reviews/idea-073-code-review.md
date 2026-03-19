# Code Review: idea-073 — Dashboard deploy history view — approval audit trail
**Date:** 2026-03-17 23:08 UTC
**Branch:** factory/idea-073
**Files:** 4 changed

REVIEW_SUMMARY: 3 issues (0 critical, 3 informational)

**INFORMATIONAL** (non-blocking):
- [app/review/ReviewDashboard.tsx:39] `riskClasses` logic is duplicated in `ReviewDashboard.tsx` and `DeployHistory.tsx`.
  Fix: Extract `riskClasses` into a shared utility function.
- [src/components/DeployHistory.tsx:291] Magic numbers used for date range calculations (e.g., `7 * 24 * 60 * 60 * 1000`, `60000`).
  Fix: Define named constants for time durations (e.g., `ONE_DAY_MS`, `ONE_MINUTE_MS`).
- [src/components/DeployHistory.tsx:1] `DeployHistory` component is large (395 lines).
  Fix: Consider splitting `DeployHistory` into smaller, more focused components.
