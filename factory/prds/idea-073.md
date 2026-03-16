# PRD: idea-073 — Dashboard Deploy History View

**Issue:** permission-protocol/site#18
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** M

## Problem
Dashboard only shows pending/recent requests. Sarah (compliance) needs a historical audit trail: who approved what, when, for which repo. Currently no way to search or filter past deploys.

## Current State
- `GET /api/reviews` returns all requests (likely includes completed ones)
- `app/review/ReviewDashboard.tsx` shows the queue
- Receipt pages exist at `/r/[id]` for individual requests

## Requirements

### 1. History Tab/Section
Add a "History" tab to the dashboard alongside the current queue view:
- Tab bar: "Pending (3)" | "History"
- History shows completed requests (approved, denied, merged, expired)
- Default sort: newest first

### 2. Filters
- **Date range:** Quick picks (Today, Last 7 days, Last 30 days, Custom)
- **Status:** All | Approved | Denied | Expired
- **Repository:** Dropdown of connected repos
- **Approver:** Text search or dropdown
- **Risk tier:** All | Critical | High | Medium | Low
- Filters apply immediately (client-side filtering if dataset is small, or query params to API)

### 3. History Cards
Similar to pending cards but with:
- Status badge (green=approved, red=denied, gray=expired)
- Approved/denied by: name + timestamp
- Time from request to decision
- Link to receipt page (`/r/{id}`)

### 4. Export (Nice to Have)
- "Export CSV" button in history view
- Columns: date, repo, PR, risk tier, actor, approver, decision, time-to-decision
- For compliance audits

## User Journey
1. Sarah clicks "History" tab on dashboard
2. Sets filter: Last 30 days, Production only
3. Sees 47 deploys, all approved, average 8 min approval time
4. Clicks one → goes to receipt page for details
5. Clicks "Export CSV" → downloads for compliance report

## Files to Change
- `app/review/ReviewDashboard.tsx` — add tab bar, render history view conditionally
- New: `src/components/DeployHistory.tsx` — history list with filters
- May need to adjust `/api/reviews` to support status/date filters (query params)

## API Considerations
If `/api/reviews` doesn't support filtering:
- Add optional query params: `?status=approved&since=2026-03-01&repo=permission-protocol/app`
- Or do client-side filtering if total count is manageable (<500 requests)

## What NOT to Change
- Pending queue view
- Receipt page
- Authentication
