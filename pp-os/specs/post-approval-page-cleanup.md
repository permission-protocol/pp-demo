# Spec: Post-Approval Page Cleanup — Actions Above the Fold

## Problem
After approval, the user's only goal is: **merge**. But the page still shows the full pre-approval review layout — AI Summary, Risk Signals, Changed Files, Decision note — all of which Marco already read before he clicked Approve. It's dead weight now.

## What Marco Needs Post-Approval
1. Confirmation it was approved ✅
2. Status of the rerun / checks
3. The Merge button
4. Receipt link

That's it. Everything else is reference material that should collapse or move below the fold.

## What's Currently Noise Post-Approval
- **"Decision note: Approved via Permission Protocol"** — he knows, he just did it
- **AI Summary** — already read it. Doesn't change. Taking up a huge block
- **Risk Signals** — already evaluated. Irrelevant post-approval
- **Changed Files** — already reviewed
- **"Attempting to merge PR..."** banner — wrong state (covered in spec #3)
- **Pre-merge checklist** — stale (covered in spec #4)
- **Three green badges** — redundant (covered in spec #6)

## Proposed Post-Approval Layout

### Above the fold (all Marco needs):
```
✅ Approved by rodchalski · 2m ago          [Receipt ↗]

┌─────────────────────────────────────────┐
│  ✅ All checks passed                   │
│  ✅ Branch up to date                   │
│  ✅ No conflicts                        │
└─────────────────────────────────────────┘

        [ 🔀 Merge & Deploy ]
```

### Below the fold (collapsed by default):
```
▸ AI Summary
▸ Risk Signals  
▸ Changed Files (1)  +5 -0
▸ Request Details
```

Each section collapsed into a single clickable line. Expand on click if someone wants to review.

## Key Principle
**The page layout should change based on state.** Pre-approval: review information is primary, action buttons secondary. Post-approval: action/status is primary, review information is secondary (collapsible).

## Implementation Notes
- Detect `status === 'approved'` and switch to the post-approval layout
- Move AI Summary, Risk Signals, Changed Files into collapsible `<details>` elements or accordion
- Keep them accessible but not in the way
- The PR title + repo link should stay visible (context)

## Files Likely Changed
- Deploy request detail page — conditional layout based on status
- Possibly extract a `PostApprovalView` component vs `ReviewView` component

## Priority
High — this is what the user stares at during the demo. Clean = professional.
