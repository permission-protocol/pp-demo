# Spec: Fix AI Summary Flicker on Poll

## Problem
The AI Summary section visibly flickers/re-renders every few seconds. This happens because the page polls for status updates and re-renders the entire component tree, including the AI Summary — which never changes after initial generation.

## Root Cause
Likely one of:
1. The poll response replaces the entire deploy request object in state, causing React to re-render all children even if AI Summary data hasn't changed
2. The AI Summary component doesn't have stable keys or memoization
3. The poll fetches the full deploy request (including summary text) and React detects a "new" string reference even though the content is identical

## Solution

### Option A: Memoize the AI Summary Component (Simplest)
- Wrap the AI Summary section in `React.memo()` with a custom comparator that only checks `summary` text
- If summary text hasn't changed, skip re-render entirely

```tsx
const AISummary = React.memo(({ summary }: { summary: string }) => {
  // render summary
}, (prev, next) => prev.summary === next.summary);
```

### Option B: Exclude Static Fields from Poll Response
- The status poll endpoint should return only fields that change (status, mergeStatus, rerunStatus, checkResults)
- AI summary, risk signals, changed files — these are static after creation
- Separate the "mutable status" from "immutable analysis" in the component state

### Option C: Use `useMemo` on Derived Data
- If the component derives display data from the deploy request object, memoize it:
```tsx
const summaryContent = useMemo(() => request.aiSummary, [request.aiSummary]);
```

## Recommendation
**Option A + B combined.** Memo the static sections (AI Summary, Risk Signals, Changed Files, Request Details) and slim down the poll response to only status fields. This also reduces bandwidth.

## Files Likely Changed
- Deploy request detail page component — add React.memo to static sections
- Poll API endpoint — return only mutable fields (or add a `?fields=status` param)

## Priority
Medium — it's visually distracting and makes the page feel janky, but doesn't block functionality.
