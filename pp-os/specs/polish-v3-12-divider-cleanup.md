# PRD: Polish V3 — Internal Divider Cleanup + Whitespace

## Summary
Replace remaining `border-b`/`border-t` dividers inside content sections with spacing, and increase whitespace on key sections per DESIGN.md's "20% more whitespace" rule.

## Part A: Divider-to-Spacing Conversion

### Target files with internal `border-b` dividers:
Search for `border-b border-[var(--border)]` and `border-t border-[var(--border)]` in content areas (NOT layout boundaries like header/sidebar).

**Convert these to spacing:**
- Section separators in `src/app/pp/page.tsx` (the header area `border-b` before stats) → Replace with `pb-8` (more whitespace)
- Section separators in `src/app/pp/deploy-requests/page.tsx` (detail header border-b, action footer border-t) → Replace with `pt-6 mt-6` / `pb-6 mb-6`
- Bulk approve modal `border-b` and `border-t` → Replace with spacing
- Table header borders in `src/app/pp/api-keys/page.tsx` → KEEP (tables need horizontal lines for readability)
- Awaiting merge section `border-b` headers → KEEP (section within a card needs a divider when content follows)

### Rules
- **KEEP** `border-b` in: table headers/rows, section headers followed by a scrollable list, modal header/footer separators (structural)
- **REMOVE** `border-b` that separates: page sections on the main canvas, stat areas from content areas, header areas from body in full-page layouts
- Replace with: padding (`pb-6`/`pt-6`) and optional background shift

## Part B: Whitespace Expansion

DESIGN.md says: "The sophisticated Protocol look requires 20% more whitespace than a standard consumer app."

### Key changes:
- **Main content padding** in `src/components/layout/app-shell.tsx`: change `p-6` → `p-8` on the `<main>` element
- **Dashboard hero** in `src/app/pp/page.tsx`: increase vertical padding from `py-8` to `py-10`
- **Card padding**: CardContent `p-6` is fine, but stat cards and info cards should have `p-8`
- **Page headings**: ensure `mb-8` (currently some have `mb-4` or `mb-6`) after the page title section
- **Between major dashboard sections**: ensure `gap-8` instead of `gap-6`

### Do NOT Change
- Sidebar padding (already tight, correct)
- Header height (16, correct)
- Demo pages
- Marketing pages
- Mobile padding (keep `p-4` on mobile, only increase on `sm:` and up)

## Verification
- Page sections feel more spacious
- No horizontal lines between major content blocks
- Tables still have row dividers
- `next build` passes
- Mobile layout not broken (padding only increases on sm+)
