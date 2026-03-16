# Feature: idea-041 — Zero-scroll mobile review: compact layout for above-the-fold decisions

## Summary
Compress the deploy request review page so Marco and Sarah can make approval decisions WITHOUT scrolling on mobile (390×844 iPhone viewport, ~720px usable after Safari chrome). Currently, 160px of header chrome + verbose banners + expanded sections push action buttons and decision data below the fold.

## Goal
Both personas see everything they need above the fold:
- **Marco (EM)**: Verdict color + PR title + Approve/Deny buttons = done in 5 seconds
- **Sarah (Security)**: Verdict + blast radius + status + quorum + GitHub review status = informed decision

## Affected Files
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — ALL changes are in this file

## Changes Required (5 items, all in page.tsx)

### 1. Merge EnvironmentBanner into VerdictBanner (saves ~50px)
**Current:** Two separate components — VerdictBanner (line ~60) and EnvironmentBanner (line ~109), rendered at lines ~1425 and ~1430.
**Target:** Single line: `🟢 ROUTINE · PRODUCTION` or `🟡 REVIEW CAREFULLY · STAGING`

Implementation:
- Modify `VerdictBanner` to accept `environment` and `isProduction` props
- When `isProduction`, append ` · PRODUCTION` to the verdict label and use amber border tint
- When not production, append ` · ${environment}` in a muted style
- Remove the separate `EnvironmentBanner` component and its render call at line ~1430
- Keep the verdict's existing color coding (red/yellow/green)

### 2. Truncate verdict description to 1 line (saves ~80px)
**Current:** `assessmentSummary.what` renders full text that can be 4-5 lines on mobile (e.g., "This change introduces an end-to-end test designed to verify that the Permission Protocol...")
**Target:** Truncate with `line-clamp-1` CSS and "..." overflow. Add click-to-expand if user wants full text.

Implementation:
- In VerdictBanner's return JSX, wrap the `{assessmentSummary.what}` text in a `<span className="line-clamp-1">` 
- Add a `useState` toggle for expanded. When expanded, remove line-clamp.
- Make the banner clickable (or add a small ▸ indicator)

### 3. Compact expired state (saves ~170px)
**Current:** Expired requests show a 200px card with explanation paragraph + "Re-run Workflow" button + "Workflow rerun: not started (0 attempts)" — all expanded by default.
**Target:** Single compact line: `⏰ Expired · [Re-run Workflow]` with inline button.

Implementation:
- Find the expired state rendering (around line ~1780, search for "This approval request expired after"). Currently it's a large card with `div` containing text + button.
- Replace with a compact single-line bar similar to the verdict banner:
```tsx
<div className="flex items-center justify-between gap-3 border-b border-amber-400/20 bg-amber-500/5 px-4 py-2 text-sm">
  <span className="text-amber-200">⏰ Expired after {expiredDuration}</span>
  <Button size="sm" onClick={handleRerun} className="h-7 rounded-lg bg-blue-500 px-3 text-xs text-white">
    {rerunActing ? 'Re-running...' : 'Re-run'}
  </Button>
</div>
```
- Remove the "Workflow rerun: not started (0 attempts)" line and the separate Workflow Rerun card (around line ~2418). Move its status into the compact bar if rerun is in progress.

### 4. Add compact status line under PR title (saves Sarah 2 scrolls)
**Current:** "At a Glance" card with Status, Quorum, Expires, Blast Radius, GitHub Review, After Approval — all in a large card at line ~2321, requiring 2+ scrolls to reach.
**Target:** Compact inline summary right under the PR title: `Pending · 2 files · No review · Prod`

Implementation:
- After the PR title + repo/PR metadata line (around line ~1850-1860), add a new compact status row:
```tsx
<div className="flex flex-wrap items-center gap-2 text-xs text-[var(--muted)]">
  <span className={statusColor}>{request.status}</span>
  <span>·</span>
  <span>{changedFiles.length} file{changedFiles.length !== 1 ? 's' : ''}</span>
  <span>·</span>
  <span>{contextDetails?.githubReviewSummary?.state === 'approved' ? '✅ Reviewed' : contextDetails?.githubReviewSummary ? `${contextDetails.githubReviewSummary.state}` : 'No review'}</span>
  {request.env ? <><span>·</span><span>{request.env}</span></> : null}
</div>
```
- Keep the full "At a Glance" card further down for Sarah to expand if needed, but the critical info is now above the fold.

### 5. Collapse Request Details and Workflow Rerun by default on mobile (saves ~500px scroll depth)
**Current:** Request Details card (~400px) and Workflow Rerun card (~100px) are expanded by default, pushing Audit Trail far down.
**Target:** Both collapsed by default on mobile. Use existing `ReferenceAccordion` pattern.

Implementation:
- The Request Details card around line ~2257 renders as an always-open `<Card>`. Wrap it in a collapsible: either use the existing `ReferenceAccordion` component (already used elsewhere in the file for AI Summary and Risk Signals) or add `defaultOpen={false}`.
- Similarly for the Workflow Rerun card at line ~2418.
- For the full "At a Glance" card at ~2321: keep it open (it's Sarah's key data if she scrolls), but it's less critical now that the compact status line exists above the fold.

## What NOT to change
- Don't move the approve/deny buttons (already done in idea-036)
- Don't change button styling, handlers, or state logic
- Don't change the AI Summary, Risk Signals, or Changed Files accordion behavior
- Don't remove any data — just compress/collapse it

## Acceptance Criteria
- [ ] On mobile (390px wide), verdict + PR title + status line + approve buttons are ALL visible without scrolling
- [ ] Verdict banner shows environment inline (no separate EnvironmentBanner)
- [ ] Verdict description truncated to 1 line, expandable on tap
- [ ] Expired state is 1 compact line with inline Re-run button
- [ ] Request Details collapsed by default on mobile
- [ ] Desktop layout still looks reasonable (nothing broken)
- [ ] `tsc --noEmit` passes
- [ ] `npx next lint` passes

## Codex Prompt
You are compressing the deploy request review page for mobile-first UX. The goal: Marco and Sarah see verdict + title + status + action buttons without scrolling on a 390px iPhone screen.

In `src/app/pp/deploy-requests/[requestId]/page.tsx`:

**Change 1: Merge environment into verdict banner**
- Modify `VerdictBanner` (line ~60) to accept `environment: string` and `isProduction: boolean` props
- In the return JSX, change the label from `${verdict.emoji} ${verdict.label} — ${assessmentSummary.what}` to separate the label and description:
  - First part: `${verdict.emoji} ${verdict.label}${isProduction ? ' · PRODUCTION' : environment ? ` · ${environment}` : ''}`
  - Second part: the description (assessmentSummary.what) on the same line but truncated
- Remove `EnvironmentBanner` component entirely (line ~109-130)
- Remove the `<EnvironmentBanner .../>` render call (search for `<EnvironmentBanner`, around line ~1430)

**Change 2: Truncate verdict description**
- In VerdictBanner, add a `const [expanded, setExpanded] = useState(false)` state
- Render the verdict like:
```tsx
<div onClick={() => setExpanded(e => !e)} className={`w-full border-b px-4 py-2 text-center text-sm font-semibold cursor-pointer ${verdict.className}`}>
  <span>{verdict.emoji} {verdict.label}{isProduction ? ' · PRODUCTION' : environment ? ` · ${environment.toUpperCase()}` : ''}</span>
  <span className={`block text-xs font-normal opacity-80 ${expanded ? '' : 'line-clamp-1'}`}>{assessmentSummary.what}</span>
</div>
```

**Change 3: Compact expired state**
- Find the expired overlay section (search for "This approval request expired after"). It's a large card/div with paragraph text + "Re-run Workflow" button + "Workflow rerun:" status line.
- Replace the entire block with a compact single line:
```tsx
<div className="flex items-center justify-between gap-3 rounded-xl border border-amber-400/20 bg-amber-500/5 px-4 py-2 text-sm">
  <span className="text-amber-200">⏰ Expired after {expiredDuration}</span>
  <Button size="sm" variant="secondary" onClick={() => void handleRerunWorkflow()} disabled={rerunActing} className="h-7 rounded-lg px-3 text-xs">
    {rerunActing ? 'Re-running...' : 'Re-run'}
  </Button>
</div>
```
- Also remove or collapse the separate "Workflow Rerun" card further down (search for "Workflow Rerun" heading at ~line 2418). If rerun is in progress, show status inline in the compact bar instead.

**Change 4: Add compact status line**
- After the PR title and repo/PR metadata (search for `request.prNumber` rendered as "PR #"), add:
```tsx
<div className="flex flex-wrap items-center gap-1.5 text-xs text-[var(--muted)]">
  <span className={request.status === 'approved' ? 'text-emerald-400' : request.status === 'pending' ? 'text-amber-400' : request.status === 'denied' ? 'text-red-400' : 'text-[var(--muted)]'}>
    {request.status}
  </span>
  <span>·</span>
  <span>{changedFiles.length} file{changedFiles.length !== 1 ? 's' : ''}</span>
  {request.env ? <><span>·</span><span>{request.env}</span></> : null}
</div>
```

**Change 5: Collapse Request Details by default**
- Find the Request Details card that's always expanded (search for `<CardTitle className="text-white">Request Details</CardTitle>` around line ~2257). It should be inside a Card component.
- Wrap it in a collapsible section. The simplest way: convert it to use the same `ReferenceAccordion` component used for AI Summary and Risk Signals. Search for how `ReferenceAccordion` is used (e.g., `<ReferenceAccordion title="AI Summary">`) and follow the same pattern for Request Details.
- Also do the same for the Workflow Rerun card if it still exists as a standalone card.

Before finishing: run `npx tsc --noEmit` and `npx next lint` — fix any errors.
