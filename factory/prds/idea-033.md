# PRD: idea-033 — AI "Should I worry?" verdict on deploy requests

## Summary
Add a prominent single-line AI verdict banner at the very top of the review page that instantly tells the approver whether this deploy request needs careful attention or is routine. This is the #1 feature for enabling fast phone-based approvals.

## Problem
The review page shows an AI summary section with risk level, signals, and analysis. But the approver has to READ it and mentally synthesize "should I care about this?" That takes 15-30 seconds. For routine changes (most factory PRs), that's wasted time.

## Solution
Add a `VerdictBanner` component that renders ABOVE everything else on the review page — before the environment banner, before the header. One line, impossible to miss.

Three states:
- 🟢 **ROUTINE** — "UI change only, no API/auth/data impact" → approve confidently in 2 seconds
- 🟡 **REVIEW CAREFULLY** — "Touches API routes / auth logic / environment config" → read the AI summary
- 🔴 **HIGH RISK** — "Changes payment, secrets, or security-critical paths" → read everything, consider denying

## User Journey
1. Rod opens PP review page on his phone
2. First thing he sees: 🟢 **ROUTINE — UI component added, no backend changes**
3. Glances at the visual preview (future feature) → looks right
4. Taps Approve → done. 5 seconds total.

For a yellow:
1. Sees: 🟡 **REVIEW CAREFULLY — Modifies authentication token handling**
2. Scrolls to AI summary → reads the risk signals
3. Checks the diff section → makes decision
4. Approve or deny. 30-60 seconds.

## Personas
- **Marco**: Wants to approve 5 routine PRs in 2 minutes. Green verdict = instant approve.
- **Sarah**: Needs to know WHICH PRs deserve attention. Yellow/red verdicts are her filter.

## Technical Approach
The data already exists. The enrichment response includes:
- `parsedSummary.riskLevel` — 'high' | 'medium' | 'low' (from `parseAiSummary()`)
- `parsedSummary.action` — 'Safe to proceed' | 'Review carefully' | 'Block recommended'
- `parsedSummary.what` — one-line description of the change
- `riskSignals[]` — array of detected risk signals with severity

The verdict combines these:
```typescript
function getVerdict(summary: ParsedAiSummary, signals: RiskSignal[]) {
  if (summary.riskLevel === 'high' || summary.action === 'Block recommended') {
    return { level: 'high', emoji: '🔴', label: 'HIGH RISK', tone: 'red' };
  }
  if (summary.riskLevel === 'medium' || summary.action === 'Review carefully') {
    return { level: 'medium', emoji: '🟡', label: 'REVIEW CAREFULLY', tone: 'yellow' };
  }
  return { level: 'low', emoji: '🟢', label: 'ROUTINE', tone: 'green' };
}
```

The description text comes from `parsedSummary.what` — e.g., "Added production environment warning banner to review page."

## Files to Change
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — add VerdictBanner component, render as first element

## Acceptance Criteria
- [ ] VerdictBanner shows at the top of the review page, above all other content
- [ ] Shows 🟢 ROUTINE / 🟡 REVIEW CAREFULLY / 🔴 HIGH RISK based on enrichment data
- [ ] Includes one-line description from the AI summary `what` field
- [ ] Shows loading shimmer while enrichment is loading
- [ ] Shows nothing (returns null) if enrichment fails or is unavailable
- [ ] Green: `bg-emerald-500/10 border-emerald-500/30 text-emerald-100`
- [ ] Yellow: `bg-yellow-500/10 border-yellow-500/30 text-yellow-100`
- [ ] Red: `bg-red-500/10 border-red-500/30 text-red-200`
- [ ] Banner is sticky (visible while scrolling)
- [ ] Works on mobile viewport (text wraps gracefully)
- [ ] `tsc --noEmit` passes
- [ ] Existing tests pass

## Out of Scope
- Batch review (separate feature)
- Visual preview thumbnails (idea-034)
- Mobile queue (idea-035)
- Custom verdict rules per tenant

## Codex Prompt
Add an AI verdict banner to the PP deploy request review page. Read FACTORY-PRD.md for full context.

In `src/app/pp/deploy-requests/[requestId]/page.tsx`:

1. Create a `VerdictBanner` component (define near the top of the file, after imports). Props:
   - `enrichment: ReviewEnrichment | null`
   - `enrichmentLoading: boolean`
   - `assessmentSummary: { riskLevel: string; action: string; what: string } | null`

2. Logic:
   - If `enrichmentLoading`: return a subtle shimmer bar (same width, 40px height)
   - If no `assessmentSummary`: return null
   - Determine verdict from `assessmentSummary.riskLevel` and `assessmentSummary.action`:
     - riskLevel 'high' OR action 'Block recommended' → 🔴 HIGH RISK (red styling)
     - riskLevel 'medium' OR action 'Review carefully' → 🟡 REVIEW CAREFULLY (yellow styling)
     - else → 🟢 ROUTINE (green styling)
   - Display: `{emoji} {LABEL} — {assessmentSummary.what}`

3. Styling:
   - `sticky top-0 z-50 w-full border-b px-4 py-3 text-center text-sm font-semibold backdrop-blur-sm`
   - Green: `border-emerald-500/30 bg-emerald-500/10 text-emerald-100`
   - Yellow: `border-yellow-500/30 bg-yellow-500/10 text-yellow-100`
   - Red: `border-red-500/30 bg-red-500/10 text-red-200`

4. Render the VerdictBanner as the VERY FIRST element in the main return of the `DeployRequestReviewPage` component. Pass `enrichment`, `enrichmentLoading`, and `assessmentSummary` (which is already computed around line 800 via `parseAiSummary()`).

5. The `assessmentSummary` variable is currently computed inside a conditional block. You may need to hoist it so it's available at the top level of the component for the VerdictBanner. The `enrichment` and `enrichmentLoading` state variables are already at the top level (lines ~431-432).

IMPORTANT: The `parseAiSummary` function and `assessmentSummary` computation is inside `AiSummaryCard` component (line ~152). You need to also compute it in the parent `DeployRequestReviewPage` component from `enrichment?.summary`. Look at how `AiSummaryCard` does it and replicate that logic in the parent.

Before finishing, run `npx tsc --noEmit` and fix any type errors.
