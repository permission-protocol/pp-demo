# Spec: Post-Approval Loading Indicators

## Problem
After approval, the deploy request detail page shows static text ("Attempting to merge PR...", "Waiting for checks to re-run...", "Checks re-running after approval...") with no visual motion. Users have no indication that background work is happening and may think the page is stuck.

## Solution
Add animated loading indicators to all "in-progress" states on the post-approval screen.

## Requirements

### 1. Spinner Animation on Status Banners
- The yellow "⟳ Attempting to merge PR..." banner should have an **animated spinning icon** (CSS animation on the ⟳ character or replace with a proper spinner SVG)
- Use `animation: spin 1s linear infinite` or equivalent

### 2. Pre-Merge Checklist — Pulsing/Spinning Items
- Each checklist item that shows "⟳" prefix ("Waiting for checks to re-run...", "Checks re-running after approval...") should have:
  - Animated spinner replacing the static ⟳ text
  - OR a pulsing dot/glow effect to indicate activity
- Items that complete should transition to a ✓ with green color (no animation)

### 3. Merge & Deploy Button — Loading State
- While checks are pending, the button should show a **subtle pulse animation** or a shimmer effect to indicate "almost ready"
- When disabled: muted pulse
- When enabled: solid highlight (no pulse — ready to click)

### 4. Auto-Polling Indicator
- Add a small "Checking..." or "Updated Xs ago" text near the status area that updates on each poll cycle
- This tells the user the page is actively refreshing data, not stale

### 5. Progress Timeline (Optional Enhancement)
- Consider adding a vertical step indicator:
  ```
  ✅ Approved
  ⏳ Setting commit status...  (spinning)
  ○  Re-running checks
  ○  Ready to merge
  ```
- Each step transitions from ○ → ⏳ (spinning) → ✅ as it completes

## Implementation Notes
- All animations should be CSS-only (no JS timers for visual effects)
- The page already polls for status updates — animations just need to reflect the current state
- Use Tailwind's `animate-spin`, `animate-pulse`, or custom keyframes
- Keep it subtle — professional, not flashy

## Files Likely Changed
- `src/app/pp/c/[slug]/deploy-requests/[id]/page.tsx` (or the component rendering the post-approval view)
- Possibly shared components for status badges/banners

## Priority
High — this is the screen users stare at during the demo. Dead-looking UI = lost confidence.
