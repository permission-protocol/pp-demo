# PRD: Polish V3 — No-Line Rule (Border-to-Background Shift)

## Summary
Replace explicit 1px borders on cards and section containers with tonal background shifts per DESIGN.md's "No-Line Rule." Cards should be defined by background contrast, not outlines.

## Problem
DESIGN.md says: "Do not use 1px solid borders to define sections. Layout boundaries must be achieved through background shifts." The app has 200+ instances of `border border-[var(--border)]` on card-like containers.

## Scope — Phased Approach

### Phase 1: Card Component (highest leverage)
**`src/components/ui/card.tsx`** — Remove the default border from the Card component:

Change:
```tsx
'bg-[var(--card)] border border-[var(--border)] rounded-md'
```
to:
```tsx
'bg-[var(--card)] rounded-md'
```

And change hover state from:
```tsx
hover && 'transition-colors hover:border-[var(--border-bright)]'
```
to:
```tsx
hover && 'transition-colors hover:bg-[var(--card-hover)]'
```

### Phase 2: Global CSS `.card` class
**`src/app/globals.css`** — Change `.card`:
```css
/* BEFORE */
.card {
  @apply bg-[var(--card)] border border-[var(--border)] rounded-md;
}
.card:hover {
  @apply border-[var(--border-bright)];
}

/* AFTER */
.card {
  @apply bg-[var(--card)] rounded-md;
}
.card:hover {
  @apply bg-[var(--card-hover)];
}
```

### Phase 3: Inline card-like borders in pages
Search for `border border-[var(--border)]` on **card-like containers** (not layout boundaries) in these files and remove the border:

**Dashboard (`src/app/pp/page.tsx`):**
- Stat cards
- Queue cards (the `DeployQueueCard` component)
- Recent activity list items
- Connected repos cards

**Deploy requests list (`src/app/pp/deploy-requests/page.tsx`):**
- Stat summary cards at the top
- Request list items / rows
- Detail view cards

**Other pages:**
- `src/app/pp/api-keys/page.tsx` — key cards
- `src/app/pp/repos/page.tsx` — repo cards
- `src/app/pp/deploy-providers/page.tsx` — provider cards
- `src/app/activity/page.tsx` — activity items
- `src/app/audit/page.tsx` — audit items
- `src/app/account/page.tsx` — settings cards
- `src/app/companies/page.tsx` — company cards
- `src/components/ui/empty-state.tsx` — next-step link borders

### KEEP Borders On (Layout Boundaries)
Do NOT remove borders from:
- **Sidebar** `border-r` — this is a layout boundary
- **Header** `border-b` — layout boundary
- **Dropdown menus** — they use glassmorphism ghost borders now (from previous PR)
- **Status badges** — they use semantic colored borders
- **Environment badges** — semantic colored borders
- **Form inputs** — they need visible boundaries for usability
- **Code blocks / pre elements** — need visual containment
- **Modal overlays** — need separation from background
- **Tooltip containers** — need separation
- **The deploy request detail page mobile sticky action bar** — needs clear separation
- **Any element where `border-l-4` or colored left/top borders are used for semantic meaning** (like the DeployQueueCard accent border)

### Ghost Border Fallback
For interactive card-like elements where removing the border entirely makes them invisible against the background, replace with a ghost border:
```
border border-[var(--border)]/10
```
This gives 10% opacity — barely visible, just enough to define the edge without feeling like a line.

## Implementation Notes
- The key insight: cards on `--card` (#1C1B1B from the surface tokens PR) sitting on `--background` (#131313) already have natural contrast. The border is redundant.
- For hover states, use `hover:bg-[var(--card-hover)]` instead of `hover:border-[var(--border-bright)]`
- Some cards use `bg-[var(--background)]` inside a `bg-[var(--card)]` section — these reversed-nesting cards should keep their borders or get ghost borders since the contrast reverses
- Be conservative: if removing a border makes something genuinely hard to see, use the ghost border fallback

## Verification
- Cards are visually distinct through background contrast, not outlines
- Interactive cards still feel clickable (hover state changes background)
- `next build` passes
- No "invisible" elements — everything is still visually distinguishable
- Status badges, env badges, and form inputs still have their borders

## Risk
High — this touches the visual appearance of every card in the app. But the changes are all in className strings and the design spec is clear.
