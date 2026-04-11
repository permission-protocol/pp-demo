# PRD: Polish V3 — Rounded-Full Audit

## Summary
Audit all 157 instances of `rounded-full` and reduce usage to only: status badges, avatar images, small dot/pulse indicators, and progress bar track/fill. Everything else should use `rounded-md`.

## Problem
DESIGN.md says: "Avoid `full` (pill-shape) except for tiny status tags." The app uses `rounded-full` on many non-tag elements.

## Scope

### KEEP `rounded-full` on:
- **StatusBadge** (`src/components/ui/status-badge.tsx`) — correct per spec
- **EnvironmentBadge** (`src/components/ui/environment-badge.tsx`) — correct (tiny tag)
- **Avatar images** — `<Image>` elements with user/company photos (circles are standard for avatars)
- **Small indicator dots** — like the live pulse dot, notification dot, pending count badge
- **Progress bar tracks and fills** — `.rounded-full` on thin bars is fine
- **Scrollbar thumb** — fine
- **Risk level badges** — tiny status-like tags
- **The red pending count badge** in the sidebar — small circle notification

### CHANGE `rounded-full` → `rounded-md` on:
- **Pill-shaped section labels/tags** that are wider than a few words — e.g., "Deploy Gate" chip, "Agent Detection" chip, "Company Setup" chip in the header
- **Onboarding progress indicator container** — the outer container in header
- **Filter/tab pills** — if any filter buttons use rounded-full, change to rounded-md
- **"Next steps" labels** in empty-state — section label text
- **Large interactive buttons** that happen to be rounded-full — any button wider than ~100px

### How to identify what to change
For each `rounded-full` instance:
1. Is it a small badge/tag (< 100px wide, status-like)? → KEEP
2. Is it a circular element (avatar, dot, icon container)? → KEEP  
3. Is it a progress bar? → KEEP
4. Is it a wider pill/chip/label? → CHANGE to `rounded-md`
5. Is it a button or interactive element wider than a badge? → CHANGE to `rounded-md`

## Implementation Notes
- Do NOT do a blind find-and-replace. Each instance needs context evaluation.
- The change from `rounded-full` to `rounded-md` on wider elements makes them look more "professional/terminal" and less "consumer app"
- Focus on files in `src/components/` and `src/app/pp/` — these are the main app surfaces
- Do NOT touch `src/app/demo/`, `src/app/(marketing)/`, or `src/app/r/`

## Verification
- Status badges still look like pills (small, rounded-full)
- Avatars still circular
- Wider chips/labels look tighter with rounded-md
- `next build` passes
- Count `grep -rn "rounded-full" src/ --include="*.tsx" | wc -l` — should be noticeably lower than 157

## Risk
Low-medium. Each change is isolated. The main risk is changing something that looks better as a pill.
