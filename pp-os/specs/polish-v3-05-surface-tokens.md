# PRD: Polish V3 — Surface Token Alignment & Accent Rename

## Summary
Align CSS custom properties in globals.css with DESIGN.md's tonal surface system and rename the confusing `--accent-blue` (which is green #10B981) to `--accent-primary`.

## Changes

### 1. globals.css `:root` — Update Surface Tokens
Change these values to match DESIGN.md's surface hierarchy:

```css
/* BEFORE */
--background: #0a0a0a;
--card: #111111;
--card-hover: #1a1a1a;
--border: #222222;
--border-bright: #333333;

/* AFTER */
--background: #131313;       /* DESIGN.md "surface" */
--card: #1C1B1B;             /* DESIGN.md "surface-container-low" */
--card-hover: #252524;       /* midpoint between low and highest */
--card-elevated: #353534;    /* NEW — DESIGN.md "surface-container-highest" */
--border: #3C4A42;           /* DESIGN.md "outline-variant" at 20% opacity equivalent */
--border-bright: #4a5a50;    /* slightly brighter outline-variant */
--void: #0E0E0E;             /* DESIGN.md "surface-container-lowest" for code blocks */
```

Note: `--background` shifts from #0a0a0a to #131313. This is the most visible change. Everything gets slightly warmer/lighter.

### 2. Rename `--accent-blue` → `--accent-primary`
- In `globals.css`: rename `--accent-blue: #10B981` → `--accent-primary: #10B981`
- **Global find-and-replace** across ALL .tsx and .css files: `var(--accent-blue)` → `var(--accent-primary)`
- This is 68 occurrences across the codebase
- Keep `--accent-green` as an alias (same value) for backward compat

### 3. Add `--surface-elevated` Utility
Add to globals.css utilities:
```css
.surface-elevated {
  background: var(--card-elevated);
}
```

### Do NOT Change
- Any color values other than the ones listed above
- `--accent-red`, `--accent-yellow`, `--accent-orange`, `--accent-purple` — these stay
- `--permit`, `--deny`, `--signal` — these stay
- Demo pages, marketing pages

## Implementation Notes
- The `--border` color shifts from pure grey (#222222) to the DESIGN.md greenish outline-variant (#3C4A42). This gives the whole app a subtle emerald tint that matches the primary color
- The background shift from #0a0a0a to #131313 is meaningful — it's less "pure black" and more "obsidian" per the design spec
- Run `grep -rn "accent-blue" src/ | wc -l` before and after to verify all 68 occurrences are renamed
- `next build` must pass

## Verification
- `grep -rn "accent-blue" src/` returns 0 results
- App background is noticeably warmer (#131313 vs #0a0a0a)
- Cards feel "raised" against the background
- `next build` passes

## Risk
Medium — changes base colors across the entire app. But all changes are in CSS custom properties, so one-place change propagates everywhere.
