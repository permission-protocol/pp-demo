# PRD: Polish V3 — Grid Overlay Texture

## Summary
Add the DESIGN.md-specified subtle grid pattern overlay to hero/dashboard sections and code areas to reinforce the developer-centric HUD aesthetic.

## Problem
DESIGN.md specifies: "For hero sections or code areas, use a subtle 24px repeating grid pattern in `outline-variant` at 5% opacity to reinforce the 'developer-centric' theme." Currently zero grid overlays exist.

## Changes

### 1. Add CSS utility in `globals.css`
Add a new utility class:
```css
.grid-overlay {
  position: relative;
}
.grid-overlay::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(60, 74, 66, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(60, 74, 66, 0.05) 1px, transparent 1px);
  background-size: 24px 24px;
  pointer-events: none;
  z-index: 0;
  border-radius: inherit;
}
```

### 2. Apply to key sections
- **Dashboard header area** (`src/app/pp/page.tsx`) — the top section with "Permission Protocol" heading and stats
- **Quickstart wizard** (`src/app/pp/page.tsx`) — the onboarding card
- **Code snippet containers** — the YAML workflow snippet in the quickstart and agent detection card
- **Deploy request detail hero** (`src/app/pp/deploy-requests/page.tsx`) — the detail header area
- **Sign-in page** (`src/app/auth/signin/page.tsx`) — the auth container

Apply by adding `grid-overlay` className to the outer container of each section. Ensure `position: relative` and children have `position: relative; z-index: 1` so content sits above the grid.

### Do NOT Apply To
- Sidebar or header (layout chrome)
- Card interiors (too busy)
- Demo pages
- Marketing pages
- Dropdown menus

## Implementation Notes
- The grid uses `outline-variant` color (#3C4A42) at 5% opacity — extremely subtle
- The `pointer-events: none` ensures the overlay doesn't block clicks
- `border-radius: inherit` keeps it rounded inside cards
- `z-index: 0` keeps it behind content
- Children of grid-overlay containers need `relative z-[1]` to stay above the grid

## Verification
- Grid lines faintly visible on dashboard hero when looking closely
- No layout shifts or click interference
- `next build` passes
