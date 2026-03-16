# PRD: idea-031 — Distinct Production Environment Alert

## Summary
Add a prominent amber warning banner at the top of the approval page for production deployments. The page already has subtle environment-specific panel colors (amber/sky), but there's no unmissable top-of-page alert that primes the approver: "This is production."

## Problem
When reviewing a deploy request, the environment info is visible but not prominent. A tired approver at 2am could approve a production deploy without fully registering it's production. The environment badge exists but it's small and below the fold.

## Solution
Add a sticky `EnvironmentBanner` component at the very top of the review page (above the header). For production: amber background, shield icon, "⚠️ PRODUCTION DEPLOYMENT" text. For non-production: no banner (clean UI for routine staging deploys).

## User Journey
1. Approver opens a production deploy request
2. Immediately sees amber banner: "⚠️ PRODUCTION DEPLOYMENT — Review carefully"
3. Banner stays visible while scrolling (sticky)
4. Non-production deploys have no banner (no visual noise)

## Personas
- **Sarah (Security)**: Wants unmistakable production indicators
- **Marco (EM)**: Doesn't want noise on staging deploys

## Files to Change
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — add EnvironmentBanner component, render conditionally based on `isProduction` (line ~745)

## Acceptance Criteria
- [ ] Production deploys show a sticky amber banner at the top of the review page
- [ ] Banner text: "⚠️ PRODUCTION DEPLOYMENT" with environment name
- [ ] Non-production deploys show no banner
- [ ] Banner uses existing amber color tokens (border-amber-400, bg-amber-500, text-amber-100)
- [ ] Banner stays visible while scrolling (sticky positioning)
- [ ] Existing tests still pass
- [ ] `tsc --noEmit` passes

## Edge Cases
- Environment string could be "Production", "production", "PRODUCTION" — already handled by `isProduction` using `.toLowerCase()`
- Very long environment names — truncate or wrap gracefully

## Out of Scope
- Banner for other risk levels (that's a separate idea)
- Sound or animation effects
- Changing the existing environment badge or panel colors

## Codex Prompt
Add a production environment warning banner to the PP deploy request review page.

In `src/app/pp/deploy-requests/[requestId]/page.tsx`:

1. Create an `EnvironmentBanner` component near the top of the file (after the imports). It should:
   - Accept `environment: string` and `isProduction: boolean` props
   - Return `null` if `!isProduction`
   - Render a full-width sticky banner with amber styling when production
   - Use classes: `sticky top-0 z-50 w-full border-b border-amber-400/40 bg-amber-500/15 px-4 py-2.5 text-center text-sm font-semibold text-amber-100 backdrop-blur-sm`
   - Text: `⚠️ PRODUCTION DEPLOYMENT — {environment}`

2. Render `<EnvironmentBanner environment={request.env} isProduction={isProduction} />` as the FIRST element inside the main return, before the existing page layout.

The `isProduction` variable already exists at line ~745: `const isProduction = request?.env.toLowerCase() === 'production';`

Do NOT modify existing environment badge or panel styling — this banner is additive.

Before finishing, run `npx tsc --noEmit` and fix any type errors.
