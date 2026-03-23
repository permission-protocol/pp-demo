# PRD: idea-072 — Mobile Approval Phase 4: Polish + Advanced UX

**Issue:** permission-protocol/site#174
**Priority:** P3
**Repo:** permission-protocol/site
**Size:** M
**Depends on:** idea-071 (Phase 3)

## Problem
After Phase 3 adds PWA + push notifications, the mobile experience needs final polish: gestures, haptics, animations, and edge case handling.

## Requirements

### 1. Swipe Gestures on Queue Cards
- **Swipe right** → Approve (green background reveals, release triggers approve)
- **Swipe left** → Deny (red background reveals, release triggers deny flow)
- Threshold: 40% of card width to trigger action
- Below threshold: card snaps back
- On trigger: haptic feedback (if available) + card slides off screen
- Only on touch devices (no mouse drag)

### 2. Haptic Feedback
- Use `navigator.vibrate()` API where available
- Light vibrate (10ms) on swipe threshold reached
- Medium vibrate (25ms) on approve/deny confirmed
- No haptic on unsupported browsers (graceful degradation)

### 3. Animation Polish
- Card transitions: stagger animation when queue loads (each card 50ms delay)
- Card removal: slide + fade when approved/denied
- Pull-to-refresh: rubber-band overscroll effect
- Tab/view transitions: crossfade (not instant swap)

### 4. Edge Cases
- **Empty queue:** Friendly illustration + "All clear! No pending requests." (not just blank space)
- **Error states:** Retry button + friendly error message (not raw error text)
- **Long PR titles:** Truncate with ellipsis at 2 lines, full title in tooltip/long-press
- **Rapid taps:** Debounce approve/deny buttons (300ms)
- **Session expiry:** If 401 on any API call, redirect to login with "Session expired" message

### 5. Accessibility
- All swipe actions also available via buttons (swipe is enhancement, not requirement)
- Focus traps on modals/overlays
- Screen reader labels on dynamic status changes

## User Journey
1. Sarah opens PP app on phone
2. Queue loads with staggered card animation
3. Familiar request → swipes right → feels haptic buzz → card slides away → approved
4. Risky request → taps into detail → reviews → approves via button
5. All done → sees "All clear!" illustration

## Files to Change
- `app/review/ReviewDashboard.tsx` — swipe handlers, stagger animations, empty state
- `src/components/SwipeableCard.tsx` (new) — reusable swipe gesture component
- May touch `app/review/[id]/ReviewPageClient.tsx` for animation consistency

## What NOT to Change
- API routes
- Desktop layout
- Push notification logic (Phase 3)

## Code Review Findings (Retry #1)
**Critical issues that MUST be fixed:**

**CRITICAL** (blocks merge):
- [app/review/ReviewDashboard.tsx:255] `JSON.parse()` on `localStorage` input without try/catch can crash the app if data is corrupted.
  Fix: Wrap `JSON.parse` in a try/catch block and fallback to an empty array on error.

**INFORMATIONAL** (non-blocking):

Fix every CRITICAL issue listed above. Run `npx tsc --noEmit` after fixing.
