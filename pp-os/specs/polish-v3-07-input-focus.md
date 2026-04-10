# PRD: Polish V3 — Input Focus Style Overhaul

## Summary
Replace the standard `focus:ring-2` blue ring on inputs with DESIGN.md's specified narrow bottom-border glow. Make inputs feel sharp and terminal-like rather than generic SaaS.

## Changes

### 1. Input Component (`src/components/ui/input.tsx`)
Change the focus styles from:
```
'transition-colors focus:outline-none focus:ring-2 focus:ring-[var(--accent-primary)] focus:border-transparent hover:border-[var(--border-bright)]'
```
to:
```
'transition-all focus:outline-none focus:border-[var(--accent-primary)] focus:shadow-[0_1px_0_0_var(--accent-primary)] hover:border-[var(--border-bright)]'
```

This replaces the ring with:
- A colored bottom border (via `focus:border-[var(--accent-primary)]`)
- A subtle 1px glow beneath via box-shadow

### 2. Global CSS Input Styles (`src/app/globals.css`)
Change `.input` from:
```css
@apply ... focus:outline-none focus:border-[var(--accent-blue)];
```
to:
```css
@apply ... focus:outline-none focus:border-[var(--accent-primary)] focus:shadow-[0_1px_0_0_var(--accent-primary)];
```

Note: If the surface tokens PR (polish-v3-05) has already renamed `--accent-blue` to `--accent-primary`, use `--accent-primary`. Otherwise use `--accent-blue` and it will be caught by the rename.

Change `.textarea` similarly.

### 3. Inline Input Styles
Search for any inline `focus:ring` on input/textarea elements:
- `src/components/layout/header.tsx` — company name input in create flow
- `src/app/pp/deploy-providers/page.tsx` — provider config inputs
- `src/app/pp/api-keys/page.tsx` — key name input
- `src/app/companies/page.tsx` — company name input
- Any other files with `focus:ring` on input elements

Replace all `focus:ring-2 focus:ring-*` patterns on inputs/textareas with:
```
focus:border-[var(--accent-primary)] focus:shadow-[0_1px_0_0_var(--accent-primary)]
```

### Do NOT Change
- Focus-visible outlines on buttons (those are accessibility, not styling)
- The global `*:focus-visible` outline (accessibility requirement)
- Demo or marketing page inputs

## Implementation Notes
- `focus:shadow-[0_1px_0_0_var(--accent-primary)]` creates a 1px emerald line that appears at the bottom — this matches DESIGN.md's "bottom border transforms into a primary glow"
- We keep `focus:outline-none` to suppress the default browser outline
- The `transition-all` (instead of `transition-colors`) ensures the shadow animates in smoothly
- This is subtler than the ring approach — test that it's still visible enough for accessibility
- Keep the `*:focus-visible` global rule for keyboard navigation (that's separate from styled inputs)

## Verification
- Click into any input → see emerald bottom glow instead of ring
- Tab through form → inputs still clearly show focus state
- `grep -rn "focus:ring" src/ --include="*.tsx"` returns 0 results on input/textarea elements (some may remain on buttons — that's OK)
- `next build` passes
