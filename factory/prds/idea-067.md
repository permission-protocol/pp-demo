# PRD: idea-067 — Deploy Queue: Skeleton Loading + Pull-to-Refresh + Optimistic UI

**Issue:** permission-protocol/site#196
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** M

## Problem
Deploy queue shows a spinner while loading. On mobile, there's no pull-to-refresh. After approving/denying, the user waits for a full re-fetch before seeing the update.

## Current State
- `app/review/ReviewDashboard.tsx` (888 lines)
- Fetches from `/api/reviews` on mount
- Re-fetches after approve/deny actions
- No skeleton loading, likely a spinner or blank state
- Has TouchEvent import — may already have some touch handling

## Requirements

### 1. Skeleton Loading
Replace any spinner/blank state with skeleton cards:
- Match the card layout: rectangle for repo name, pill for risk badge, line for PR title, small text for actor/time
- 3 skeleton cards by default
- Use CSS `animate-pulse` (Tailwind built-in) with `bg-border/50` color
- Skeleton shows on initial load AND on refresh

### 2. Pull-to-Refresh (Mobile)
- On touch pull-down > 60px threshold, trigger a refresh
- Show a small refresh indicator at top (rotating arrow or simple spinner)
- Release triggers re-fetch
- Only active on mobile viewports (or touch devices)
- Use the existing TouchEvent handling pattern if present

### 3. Optimistic UI
When user approves/denies a request:
1. **Immediately** update the card's status pill to "approved"/"denied" (with slight opacity to indicate pending)
2. Send the API request
3. On success: remove opacity, card is confirmed
4. On failure: revert the card to previous state, show error toast/inline message

## User Journey
1. Sarah opens queue → sees skeleton cards (200ms) → content fades in
2. Pulls down on phone → refresh indicator → queue updates
3. Approves a request → card instantly shows ✅ approved → no wait → moves on to next

## Files to Change
- `app/review/ReviewDashboard.tsx` — skeleton component, pull-to-refresh handler, optimistic state management

## Technical Notes
- Skeleton cards should be a separate component or inline JSX block for reusability
- Optimistic UI: use local state to override the server state temporarily. On re-fetch, server state takes over.
- Pull-to-refresh: simple touchstart/touchmove/touchend handler with transform translateY

## What NOT to Change
- API routes
- Card design (just add skeleton variant)
- Authentication
