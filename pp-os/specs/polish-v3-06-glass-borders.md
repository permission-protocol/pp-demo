# PRD: Polish V3 — Glassmorphism Dropdowns + CardHeader Border Removal

## Summary
Two related changes: (1) Replace solid backgrounds on floating dropdowns with glassmorphism. (2) Remove the `border-b` divider from CardHeader, replacing with padding/spacing.

## Part A: Glassmorphism Dropdowns

### Target: `src/components/layout/header.tsx`

**Company Switcher Dropdown** — find the div with:
```
className="absolute top-full left-0 mt-2 w-64 bg-[var(--card)] border border-[var(--border)] rounded-md shadow-xl z-50"
```
Change to:
```
className="absolute top-full left-0 mt-2 w-64 bg-[var(--card)]/80 border border-[var(--border)]/20 rounded-md shadow-[0_20px_40px_rgba(0,0,0,0.4)] backdrop-blur-xl z-50"
```

**User Menu Dropdown** — find the div with:
```
className="absolute top-full right-0 mt-2 w-56 bg-[var(--card)] border border-[var(--border)] rounded-md shadow-xl z-50"
```
Change to:
```
className="absolute top-full right-0 mt-2 w-56 bg-[var(--card)]/80 border border-[var(--border)]/20 rounded-md shadow-[0_20px_40px_rgba(0,0,0,0.4)] backdrop-blur-xl z-50"
```

### Target: `src/components/ui/command-palette.tsx`
If this component has a modal/overlay container, apply the same glassmorphism treatment:
- `bg-[var(--card)]/80 backdrop-blur-xl`
- Ghost border: `border-[var(--border)]/20`
- Ambient shadow: `shadow-[0_20px_40px_rgba(0,0,0,0.4)]`

### Target: `src/components/ui/tooltip.tsx`
Apply glassmorphism to tooltip containers if they use solid `bg-[var(--card)]`.

## Part B: CardHeader Border Removal

### Target: `src/components/ui/card.tsx`

Change CardHeader from:
```tsx
<div className={clsx('px-6 py-4 border-b border-[var(--border)]', className)}>
```
to:
```tsx
<div className={clsx('px-6 pt-6 pb-2', className)}>
```

This removes the divider and uses vertical padding to create separation. The `pt-6` aligns with CardContent's `p-6`, and `pb-2` creates a natural gap before content without a visible line.

### Do NOT Change
- Demo pages
- Marketing pages
- The sidebar border-right (layout boundary, not content divider)
- The header border-bottom (layout boundary)
- Modal overlays in the deploy request detail page (already have glassmorphism)

## Implementation Notes
- `bg-[var(--card)]/80` works in Tailwind — it applies 80% opacity to the CSS variable
- `backdrop-blur-xl` = `backdrop-filter: blur(24px)` which is close to DESIGN.md's spec of `blur(12px)` — use `backdrop-blur-md` if `xl` feels too strong. `md` = 12px.
- Actually, use `backdrop-blur-md` to match DESIGN.md exactly: `backdrop-filter: blur(12px)`
- The shadow `0 20px 40px rgba(0,0,0,0.4)` matches DESIGN.md's ambient shadow spec
- Ghost border: `border-[var(--border)]/20` means 20% opacity on the border color

## Verification
- Company switcher dropdown shows backdrop blur when opened
- User menu dropdown shows backdrop blur when opened  
- Cards no longer have horizontal lines between header and content
- `next build` passes
- No visual regression on mobile (test mobile menu)
