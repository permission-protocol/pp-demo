# PRD: idea-065 — Approval Flow Polish

**Issue:** permission-protocol/site#145
**Priority:** P1
**Repo:** permission-protocol/site
**Size:** M

## Problem
The approval flow works but feels mechanical. For demo prospects (Sarah = Security Lead, Marco = EM), it needs to feel effortless and confidence-inspiring. Small polish details compound into trust signals.

## Current State
- `app/approve/[id]/` has ApprovePageClient.tsx (if it exists) or similar
- `app/review/[id]/ReviewPageClient.tsx` is the main review surface
- Basic approve/deny works

## Polish Items (in priority order)

### Must Have
1. **Loading → content transition**: Smooth fade-in when data loads (not a hard pop). Use framer-motion `AnimatePresence` consistent with rest of site.
2. **Approve button feedback**: On click → button shows spinner → success checkmark animation → redirect/update. Currently just sends request.
3. **Deny flow**: Smooth collapse animation when expanding deny reason textarea. Currently instant show/hide.
4. **Status pill animations**: When status changes (pending → approved), animate the color transition.

### Nice to Have
5. **Skeleton loading**: While review data fetches, show skeleton cards matching the layout (context zone, assessment zone, action zone).
6. **Confetti or subtle celebration**: On successful approval, a brief micro-animation (NOT over the top — subtle green pulse or checkmark scale-up).
7. **Error recovery**: If approve/deny API fails, shake the button and show inline retry — don't redirect to error page.

## User Journey
1. Sarah gets notification → clicks review link
2. Page loads with skeleton → content fades in smoothly (200ms)
3. Reads context (2 sec), assessment (15 sec)
4. Clicks Approve → button animates to spinner → checkmark → status updates
5. Feels: "That was easy. I trust this tool."

## Files to Change
- `app/review/[id]/ReviewPageClient.tsx` — main polish target
- `app/approve/[id]/ApprovePageClient.tsx` — if separate approve flow exists
- May need shared animation constants in `src/lib/` or component-level

## Technical Notes
- Site already uses framer-motion — use consistent patterns
- Existing design tokens: `text-permit` (brand green), `bg-void`, `border-border`
- Don't add new dependencies — framer-motion handles everything needed

## What NOT to Change
- API routes or business logic
- Layout structure (4 zones: Context, Assessment, Action, Evidence)
- Authentication flow
