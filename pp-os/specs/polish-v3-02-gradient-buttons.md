# PRD: Polish V3 — Gradient Primary CTAs

## Summary
Replace flat primary buttons with the DESIGN.md signature gradient: a subtle linear gradient from emerald `#10B981` to a deeper teal `#0d9668` at 135°. This makes CTAs feel "lit from within."

## Problem
DESIGN.md specifies: "Primary CTAs should not be flat. Use a subtle linear gradient from `primary` to `primary-container` at a 135-degree angle." Currently all primary buttons use flat `bg-[var(--accent-blue)]`.

## Scope

### 1. Button Component (`src/components/ui/button.tsx`)
Change the `primary` variant style from:
```
'bg-[var(--accent-blue)] text-white hover:opacity-90'
```
to:
```
'bg-gradient-to-br from-[#10B981] to-[#0d9668] text-white hover:brightness-110 active:brightness-95'
```

Also change `success` variant from:
```
'bg-[var(--accent-green)] text-white hover:opacity-90'
```
to:
```
'bg-gradient-to-br from-[#22c55e] to-[#10B981] text-white hover:brightness-110 active:brightness-95'
```

### 2. Global CSS Button Styles (`src/app/globals.css`)
Change `.btn-primary` from:
```css
@apply bg-[var(--accent-blue)] text-white hover:opacity-90;
```
to:
```css
@apply bg-gradient-to-br from-[#10B981] to-[#0d9668] text-white hover:brightness-110;
```

Change `.btn-success` similarly.

### 3. Inline Primary Buttons
Search for any inline `bg-[var(--accent-blue)]` or `bg-[#10B981]` on buttons that don't use the Button component:
- `src/app/pp/page.tsx` — QuickstartWizard buttons, "Test Enforcement Now" button
- `src/app/approve/[id]/page.tsx` — approve button
- Any other file with inline primary-colored buttons on `<button>` or `<Button>` elements

Replace flat bg with gradient classes.

### Do NOT Change
- Secondary, ghost, outline, danger, warning button variants
- Link-styled buttons
- Badge/tag colors
- Status indicator colors

## Implementation Notes
- Use `hover:brightness-110` instead of `hover:opacity-90` — gradients look washed out at reduced opacity, brightness looks better
- Use `active:brightness-95` for pressed state
- The gradient angle (`bg-gradient-to-br`) maps to ~135°
- Keep `text-white` (high contrast on gradient background)
- The `disabled:opacity-50` still works fine on gradients

## Verification
- All primary and success buttons show gradient in browser
- Hover and active states feel responsive
- Disabled state dims correctly
- `next build` passes
- No broken button styling in dark mode

## Customer Test
"Do the CTAs feel like they belong to a premium protocol, or a Bootstrap template?" — gradient = protocol.
