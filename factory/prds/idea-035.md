# PRD: idea-035 — Mobile-first deploy queue in PP app

## Summary
Replace the pending approvals section on the PP dashboard with a mobile-first card-based queue. Each card shows the AI verdict, one-line summary, environment, and a one-tap approve button. This is the "review 5 PRs from your phone in 2 minutes" feature.

## Problem
The current dashboard shows pending deploy requests in lane groups with small text and requires navigating to each request's review page to approve. On mobile, this means: see list → tap request → wait for page load → read → scroll to approve button → tap → navigate back → repeat. That's 5+ taps and 30+ seconds per approval.

## Solution
Add a `DeployQueueCards` component that renders pending deploy requests as swipeable cards directly on the dashboard. Each card is a self-contained decision unit — verdict, summary, and action all visible without navigating away.

### Card Layout
```
┌──────────────────────────────────────┐
│ 🟢 ROUTINE                    2m ago │
│ Added production env banner          │
│ permission-protocol/app • production │
│ PR #105 • 1 file • +59/-38          │
│                                      │
│  [ Approve ✅ ]    [ Review → ]      │
└──────────────────────────────────────┘
```

### Key Design Decisions
- **Approve from the card** — no navigation required for routine (green) changes
- **"Review →" for yellows/reds** — links to the full review page with visual preview
- **Cards sorted by urgency** — production first, then oldest, then AI-flagged
- **Mobile-first** — cards are full-width on mobile, 2-column on desktop
- **Quick-approve requires the verdict** — if enrichment hasn't loaded yet, the approve button is disabled

## User Journey
1. Rod gets Discord notification: "3 PRs pending review"
2. Taps link → PP dashboard on phone
3. Sees 3 cards: two green (🟢 ROUTINE), one yellow (🟡 REVIEW CAREFULLY)
4. Taps "Approve ✅" on both green cards — done in 10 seconds
5. Taps "Review →" on the yellow card → full review page → reads → approves
6. Total: 45 seconds for 3 PRs

## Personas
- **Marco**: Approves green cards without thinking. "If the AI says routine and tests pass, ship it."
- **Sarah**: Always taps "Review →" regardless of color. But the queue shows her which ones need attention first.

## Technical Approach

### Data source
The dashboard already fetches pending deploy requests:
```typescript
fetch('/api/v1/deploy-requests?status=pending&groupBy=lane&limit=5')
```
The response includes `pendingGroups` with `latestPending` per lane. We need the enrichment data (AI summary/verdict) for each pending request.

### Enrichment per card
Each card needs the AI verdict. Options:
1. **Fetch enrichment per card** — N+1 requests, but enrichment is cached
2. **Bulk enrichment endpoint** — new endpoint that returns enrichment for multiple requests
3. **Include enrichment in the pending response** — modify the existing endpoint

Option 1 is simplest for v1. Each card fetches its own enrichment on mount (same endpoint the review page uses). The enrichment is cached server-side so subsequent loads are instant.

### Quick approve from card
The approve action already exists — it's the same API the review page uses:
```
POST /api/v1/deploy-requests/{requestId}/approve
```
After approve, the card animates out and the dashboard refreshes.

## Files to Change
- `src/app/pp/page.tsx` — add DeployQueueCards component, replace or augment the pending section

## Acceptance Criteria
- [ ] Pending deploy requests show as cards on the dashboard
- [ ] Each card shows: AI verdict (🟢/🟡/🔴), one-line summary, repo, environment, PR number, file count, time waiting
- [ ] Green cards have a prominent "Approve" button that triggers approval without leaving the page
- [ ] Yellow/red cards have a "Review →" link to the full review page
- [ ] Cards sort by: production > staging, then oldest first
- [ ] Approve button is disabled until enrichment loads (prevents blind approval)
- [ ] After approving, the card animates out (fade + slide) and the dashboard stats update
- [ ] Cards are full-width on mobile, 2-column grid on tablet+
- [ ] Empty state: "No pending approvals 🎉" when queue is empty
- [ ] Loading state: shimmer cards while data loads
- [ ] `tsc --noEmit` passes
- [ ] Existing tests pass

## Edge Cases
- Enrichment fails for a card → show card without verdict, disable quick-approve, show "Review →" only
- Approve fails (network error) → show error toast, card stays in queue
- Many pending requests (>10) → show first 5 with "View all →" link
- Request approved by someone else while viewing → card disappears on next refresh

## Out of Scope
- Swipe gestures (v2)
- Batch "approve all green" button (v2 — after this proves the card UX works)
- Merge from the card (approve only, merge happens on the review page or automatically)

## Codex Prompt
Add a mobile-first deploy queue card UI to the PP dashboard. Read FACTORY-PRD.md for full context.

In `src/app/pp/deploy-requests/[requestId]/page.tsx` note how `parseAiSummary()` works and how enrichment is fetched — you'll need the same pattern.

In `src/app/pp/page.tsx`:

1. Create a `DeployQueueCard` component (in the same file). Props:
   - `request: DeployRequestListItem` (type already defined in page.tsx)
   - `companySlug: string`
   - `onApproved: (requestId: string) => void`

   The card:
   - Fetches enrichment on mount: `GET /api/v1/deploy-requests/${request.id}/enrichment`
   - Parses the AI summary using the same `parseAiSummary` logic from `review-page-helpers.tsx` — import it: `import { parseAiSummary } from './deploy-requests/[requestId]/review-page-helpers'` (adjust path as needed)
   - Shows verdict badge (🟢/🟡/🔴) + label + one-line `what` from parsed summary
   - Shows: repo name, environment badge (amber for production, sky for others), PR number if available, time since creation (use relative time like "2m ago", "1h ago")
   - "Approve" button: calls `POST /api/v1/deploy-requests/${request.id}/approve` with appropriate headers. On success, calls `onApproved(request.id)`. Button disabled while enrichment loading or if verdict is null.
   - "Review →" link: navigates to `/pp/c/${companySlug}/deploy-requests/${request.id}`
   - Card styling: `rounded-2xl border border-[var(--border)] bg-[var(--card)] p-4` with left border accent matching verdict color

2. Create a `DeployQueueCards` component. Props:
   - `requests: DeployRequestListItem[]` (the pending requests)
   - `companySlug: string`
   - `onApproved: (requestId: string) => void`

   - Sorts requests: production env first, then by `createdAt` ascending (oldest first)
   - Shows max 5 cards, with "View all pending →" link if more exist
   - Empty state: centered "No pending approvals 🎉" message
   - Grid: `grid gap-3` on mobile (single column), `grid-cols-2 gap-4` on `md:` breakpoint

3. In the main dashboard render (around line 700), find the "Pending Approvals" section that shows `pendingGroups`. Replace or add below it:
   - Extract all pending requests from `pendingGroups` into a flat array
   - Render `<DeployQueueCards requests={flatPendingRequests} companySlug={companySlug} onApproved={handleQuickApprove} />`
   - The `companySlug` is available from the dashboard data (check how the existing pending links are constructed)
   - The `handleQuickApprove` callback should: remove the request from state, decrement `stats.pending`, show a success toast

4. For the approve API call in DeployQueueCard, look at how the review page handles approval (in `src/app/pp/deploy-requests/[requestId]/page.tsx` — search for "approve"). Replicate the same fetch call and headers.

IMPORTANT: The `parseAiSummary` function is in `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx`. Import it. If the import path doesn't work due to the bracket in the path, copy the function into page.tsx (it's small).

Before finishing, run `npx tsc --noEmit` and fix any type errors.
