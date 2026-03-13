# Spec: PP App Patterns → Marketing Site (Batch)

**Status:** In Progress
**Date:** 2026-03-12
**Source:** `permission-protocol/app` codebase analysis

---

## 1. Superseded Request Handling

**Problem:** When a new push creates a new deploy request, the old one becomes stale. Approving a stale request is dangerous.

**PP App Pattern:** `supersededByRequestId` field on requests. Old requests marked as `superseded` status.

**Site Implementation:**
- On `/review/[id]` page: check if `requestDetails.supersededByRequestId` exists
- If yes: show a warning banner above the AI summary:
  ```
  ⚠️ This request has been superseded by a newer deploy request.
  [View Latest Request →]
  ```
- Disable the Approve button on superseded requests (Reject still works for audit)
- On the dashboard: filter superseded requests out of "Pending" by default
- Add `superseded` to the status filter chips

**API Changes:**
- `fetchRequestDetails` already returns the full request — check for `supersededByRequestId` field
- Add `status === 'superseded'` handling in ReviewPageClient status display

---

## 2. Manual Rerun Button

**Problem:** Auto-rerun (PR #180) may fail. Need a fallback.

**PP App Pattern:** `/api/v1/deploy-requests/[id]/rerun` endpoint + `RerunStatusBadge` component + rate limiting.

**Site Implementation:**
- New API route: `POST /api/review/[id]/rerun`
  - Calls `triggerGitHubRerun()` (already implemented in approve route — extract to shared lib)
  - Rate limit: max 5 attempts per request per 5 minutes (in-memory, simple)
- UI: After approval, if `rerunResult` shows failure:
  - Show "Retry Deploy Gate" button
  - On click → POST `/api/review/[id]/rerun`
  - Show spinner → success/failure status
  - Disable after 5 attempts ("Too many retries — rerun manually on GitHub")
- Also show rerun status on the dashboard cards for approved requests

---

## 3. Request Timeline

**Problem:** After approval, the user has no visibility into what's happening (merge, rerun, deploy).

**PP App Pattern:** `getTimelineEvents()` builds ordered events from request fields + audit events. Timeline API returns events from `AuditEvent` table.

**Site Implementation (simplified — no DB access):**
- Build timeline client-side from the request data we already have:
  - Created → `request.created_at`
  - Approved/Denied → `request.decided_at` + `request.decided_by`
  - Commit Status Set → infer from `commit_status` response
  - Rerun Triggered → from `rerun_result`
  - Merge Attempted → if merge button was clicked
  - Merged → `request.pr_state === 'merged'` or merge readiness
- Display as a vertical timeline below the action section:
  ```
  ● Created                    2:15 PM
  │
  ● Approved by reviewer       2:47 PM
  │  Receipt: abc123...
  │
  ● Deploy Gate re-triggered   2:47 PM
  │  Strategy: check_run
  │
  ○ Awaiting merge             —
  ```
- Timeline updates on poll (every 15s already happening)
- Collapsed by default on mobile, one tap to expand

---

## 4. Stale Request Reconciliation

**Problem:** Pending requests for PRs that have been merged/closed on GitHub litter the queue.

**PP App Pattern:** `reconcile-stale-requests.ts` — queries GitHub for PR status, expires stale requests.

**Site Implementation:**
- New API route: `POST /api/reviews/reconcile`
  - For each pending request with PR context: check GitHub PR status
  - If PR is `closed` or `merged`: mark request as reconciled/stale in local state
  - Return list of reconciled request IDs
- Dashboard calls this on load (debounced, max once per 5 minutes)
- Reconciled requests show as "PR Closed" with grey badge, filtered out of pending by default
- Since the site can't write to PP's DB, reconciliation is display-only:
  - Store reconciled IDs in sessionStorage
  - Show "This PR has been merged/closed on GitHub" banner on affected request pages
  - Filter them out of the pending queue

---

## Implementation Plan

**PR A: Superseded + Manual Rerun** (safety-critical, interconnected)
- Extract `triggerGitHubRerun` to shared lib
- Add superseded detection + UI
- Add `/api/review/[id]/rerun` route
- Add retry button in UI

**PR B: Timeline + Reconciliation** (UX improvements)
- Build timeline component
- Add timeline section to ReviewPageClient
- Add `/api/reviews/reconcile` route
- Add reconciliation to dashboard
