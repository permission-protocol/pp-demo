# PRD: Polish V3 — Border Radius Tightening

## Summary
Systematically replace `rounded-lg` (0.5rem) with `rounded-md` (0.375rem) across the app to match DESIGN.md's "professional terminal-chic" specification. Keep `rounded-full` only on status badges and avatar images.

## Problem
DESIGN.md says: "Keep it professional with `md` (0.375rem) or `sm` (0.125rem). Avoid `full` (pill-shape) except for tiny status tags." The app currently uses `rounded-lg` as the default for everything — cards, buttons, inputs, dropdowns, modals.

## Scope

### 1. Component Files (highest priority)
These components set the default radius for the whole app:

**`src/components/ui/button.tsx`**
- Change `rounded-lg` → `rounded-md` in `baseStyles`

**`src/components/ui/card.tsx`**
- Change `rounded-lg` → `rounded-md` in the Card component

**`src/components/ui/input.tsx`**
- Change `rounded-md` (already correct) — verify, leave as-is if already `rounded-md`

**`src/components/ui/empty-state.tsx`**
- Change `rounded-lg` → `rounded-md` on the next-step links

**`src/components/ui/status-badge.tsx`**
- KEEP `rounded-full` — this is status tags, which DESIGN.md permits

**`src/components/ui/tooltip.tsx`**
- Change `rounded-lg` → `rounded-md`

### 2. Global CSS (`src/app/globals.css`)
- Change `.card` from `rounded-lg` → `rounded-md`
- Change `.btn` from `rounded-lg` → `rounded-md`
- Change `.input` from `rounded-lg` → `rounded-md`
- Change `.textarea` from `rounded-lg` → `rounded-md`

### 3. Layout Components
**`src/components/layout/sidebar.tsx`**
- Nav items: `rounded-lg` → `rounded-md`
- Logo container: `rounded-lg` → `rounded-md`
- Mobile menu button: `rounded-lg` → `rounded-md`

**`src/components/layout/header.tsx`**
- Company switcher button: `rounded-lg` → `rounded-md`
- Dropdown container: `rounded-lg` → `rounded-md`
- Company items in dropdown: `rounded-md` (already correct or change from lg)
- User menu button: `rounded-lg` → `rounded-md`
- User dropdown: `rounded-lg` → `rounded-md`
- Command palette hint: `rounded-lg` → `rounded-md`

### 4. Page Files — Batch Replace
Do a find-and-replace in these directories for `rounded-lg` → `rounded-md`, but **only on container/card/button elements** — NOT on `rounded-full`:
- `src/app/pp/` (all page files)
- `src/app/activity/`
- `src/app/audit/`
- `src/app/account/`
- `src/app/companies/`
- `src/app/auth/`
- `src/app/install/`
- `src/app/wizards/`
- `src/app/c/` (all page files)

### Preserve As-Is
- `rounded-full` on: StatusBadge, avatar images (`.rounded-full` on `<Image>` for user/company avatars), small dot indicators
- `rounded-2xl` or `rounded-[28px]` in the demo or receipt pages — those have their own design
- Any `rounded-xl` in the deploy request detail page's mobile floating action areas — review case by case
- Marketing pages under `(marketing)/`

## Implementation Notes
- This is a high-volume find-and-replace but each change is trivial
- DANGER: Don't blindly replace ALL `rounded-lg` — check context. For example:
  - `rounded-lg` on a scrollbar `::-webkit-scrollbar-thumb` → leave as-is (4px is fine)
  - `rounded-lg` inside a third-party component → leave as-is
- Test one page visually after changes to confirm the tighter radius looks right

## Verification
- `grep -rn "rounded-lg" src/components/ | wc -l` should be < 5 (down from ~30+)
- `next build` passes
- No broken pill/circle shapes on status badges
- Cards and buttons look tighter and more professional

## Customer Test
"Does this look like a security product or a consumer app?" — tighter radius = security product.
