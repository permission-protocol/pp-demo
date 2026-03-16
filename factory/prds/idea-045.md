# PRD: idea-045 — Dashboard Merge Status Context

**Issue:** permission-protocol/app#121
**Priority:** P1
**Repo:** permission-protocol/app

## Problem
Dashboard "Merge Status: 81 — 30 failed · 51 awaiting" with no explanation. "30 failed" triggers alarm for new users.

## Requirements

### Must Have
- Add tooltip on "Merge Status" card explaining what the states mean
- Rename "failed" to "expired" if those are TTL expirations (check the data model — if `status === 'expired'` or `status === 'failed'` based on TTL timeout, use the correct label)
- Make the numbers clickable — link to filtered deploy queue view
- Add time scope: show "Last 30 days" label or add a time filter

### Implementation Notes
- The dashboard stats cards are in the overview/dashboard page component
- Look at how `mergeStatus` is computed — if it counts requests that exceeded TTL as "failed", relabel to "expired"
- Tooltip: use existing UI tooltip component (likely Radix or similar)
- Click handler: navigate to `/c/deploy-requests?status=failed` or equivalent

### Must NOT Do
- Don't change the card grid layout
- Don't modify the underlying data/API
