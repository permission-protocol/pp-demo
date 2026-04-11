# PRD: Polish V3 — Accent-Blue Straggler Cleanup

## Summary
15 inline `accent-blue` references survived the tokens rename PR. Replace all with `accent-primary`.

## Scope
Global find-and-replace: `accent-blue` → `accent-primary` in ALL files under `src/`.

Files with remaining references:
- `src/app/pp/deploy-providers/page.tsx` (3 instances)
- `src/app/pp/api-keys/page.tsx` (1)
- `src/app/pp/deploy-requests/[requestId]/page.tsx` (3)
- `src/app/approve/[id]/page.tsx` (3)
- `src/app/account/page.tsx` (1)
- `src/app/wizards/github-connection/page.tsx` (1)
- `src/app/companies/page.tsx` (2)
- `src/components/layout/header.tsx` (1)

## Verification
- `grep -rn "accent-blue" src/` returns 0 results
- `npx next build` passes
- Commit: `fix: replace remaining accent-blue with accent-primary`
