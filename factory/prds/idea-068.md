# PRD: idea-068 — Deploy Queue: Inline Approve on Cards + Batch Approve API

**Issue:** permission-protocol/site#195
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** L

## Problem
To approve a deploy request, Sarah must click into the detail page, review, then approve. For low-risk or familiar requests, this is unnecessary friction. She should be able to approve directly from the queue card. For multiple similar requests, she should be able to batch-approve.

## Current State
- `app/review/ReviewDashboard.tsx` — cards link to `/review/{id}` for detail
- Individual approve API: `app/api/review/[id]/approve/route.ts`
- No batch endpoint exists
- Cards show status, repo, PR title, risk tier, actor

## Requirements

### 1. Inline Approve Button on Queue Cards
- Add a small "Approve" button on each pending card (right side, or swipe-to-reveal on mobile)
- Button only shows for `status === "pending"` cards
- On click: call existing `/api/review/{id}/approve` with POST
- Show inline spinner → checkmark on success
- For critical/high risk: show a confirmation tooltip ("Approve production deploy?") before proceeding
- Card should also still be clickable to go to detail view

### 2. Batch Approve
- Add checkbox on each pending card (left side)
- When 1+ cards selected, show a floating "Approve Selected (N)" bar at bottom
- Clicking batch approve sends parallel requests to individual approve endpoints (no new batch API needed — just Promise.all the individual calls)
- Progress indicator: "Approving 3/5..." → "5/5 approved ✓"
- If any fail: show which ones failed with retry option

### 3. Selection UX
- "Select All Pending" checkbox in queue header
- Selection persists across page (not across refresh)
- Deselect on successful batch approve
- Risk-tier filter on selection: "Select all low-risk" option

## User Journey
### Quick single approve:
1. Sarah sees a low-risk staging deploy from a trusted author
2. Clicks "Approve" on the card → confirmed in 1 second
3. Never left the queue

### Batch approve:
1. Sarah sees 4 pending staging deploys, all low-risk
2. Checks "Select All Pending" → selects 4
3. Clicks "Approve Selected (4)" → bar shows progress
4. All approved, cards update → she's done in 10 seconds instead of 4 separate page visits

## Files to Change
- `app/review/ReviewDashboard.tsx` — inline approve button, checkbox selection, batch bar
- No new API routes needed (reuse individual approve endpoint)

## Technical Notes
- Inline approve reuses existing approve API — no backend changes
- Batch = client-side parallel calls with `Promise.allSettled`
- Confirmation for high-risk is client-only (tooltip/popover)
- Checkbox state is local React state (array of selected IDs)

## What NOT to Change
- Approve API logic or authorization
- Detail page approve flow (keep both paths)
- Card content layout (add button, don't rearrange)
