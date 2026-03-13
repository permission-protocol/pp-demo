# PRD: Deploy Queue Row Redesign

**Status:** Draft
**Author:** Charles + Rod (QA Sprint #2)
**Date:** 2026-03-11
**Target Repo:** `permission-protocol/app`
**Target File:** `src/app/pp/deploy-requests/page.tsx` (RequestCard component)

---

## Problem

The queue row (`RequestCard`) shows too much information with equal visual weight. Every field competes for attention — author hashes nobody reads, "risk: none" that's always none, SHA hashes that belong in the detail view, and a "Verification failed" status that's circular (you're here to approve, so of course it's not approved yet). The result: it takes 5-10 seconds to parse a row instead of <2 seconds.

## Decision (from QA Sprint)

Strip the row down to 5 elements with intentional visual hierarchy. The row itself is the click target — no buttons.

### The Row

```
●  permission-protocol/site  Update hero copy (#167)  ✓  8m
```

1. **Status dot** — colored circle, no text label. Orange=pending, green=approved, grey=expired/superseded.
2. **Repo** — secondary text color, muted weight. Context, not headline.
3. **PR title (#number)** — primary text, heaviest weight. The number is a subtle inline link to GitHub. This is what you're reading. Clicking the row opens the review detail page.
4. **CI health dot** — tiny green ✓ or red ✗ showing status of *other* checks (not PP's own check). Invisible when healthy, loud when broken.
5. **Age** — lightest weight, right-aligned, tertiary color. "8m" not "8 minutes ago."

### What Gets Removed

| Element | Reason |
|---------|--------|
| Status badge (text) | Replaced by status dot — color communicates faster than text |
| Environment badge | Only gates production today; redundant. Re-add when multi-env ships |
| Risk indicator (● none) | Always "none" — zero signal. Only show when elevated (medium+) |
| Author hash | Unreadable machine ID. Resolve to human name or drop |
| SHA | Belongs in detail view, not queue scan |
| Rerun status ("no rerun") | Only meaningful when a rerun IS available |
| "Verification failed" | Circular — you're here to approve, that IS the verification |
| Review button | Whole row is clickable → opens detail |
| Open PR button | PR #number is a link |
| Queue history label | Move to a subtle expandable, not inline text |

### What Gets Added

| Element | Reason |
|---------|--------|
| PR title | **Currently missing from rows.** Most important context for approval decision |
| CI health (non-PP checks) | Answers "is everything else green?" before you approve |

---

## Design Spec

### Visual Hierarchy (left → right, by decision weight)

```
┌─────────────────────────────────────────────────────────────────────┐
│ ●  permission-protocol/site   Update hero copy (#167)    ✓    8m  │
│                                                                     │
│ [2px left border: amber for pending, green for approved]           │
└─────────────────────────────────────────────────────────────────────┘
```

**Element styles:**

1. **Status dot** (far left)
   - 10px circle, no text
   - Pending: `#F59E0B` (amber)
   - Approved: `#10B981` (green)
   - Denied: `#EF4444` (red)
   - Expired/Superseded: `#6B7280` (grey)

2. **Repo** (after dot)
   - `text-sm`, `text-[var(--muted)]`, normal weight
   - Truncate with ellipsis if >30 chars

3. **PR title (#number)** (main content, flex-grow)
   - `text-sm`, `text-[var(--foreground)]`, `font-medium`
   - Title truncates with ellipsis
   - `(#167)` is a subtle link to GitHub PR (opens in new tab)
   - Fallback if no PR: show capability name + ref

4. **CI dot** (right zone)
   - Green `✓` if all non-PP checks pass
   - Red `✗` with count if checks failing: `✗ 2`
   - Grey `–` if no check data available
   - Tooltip on hover: list of check names + statuses

5. **Age** (far right)
   - `text-xs`, `text-[var(--muted)]`, right-aligned
   - Compact format: "8m", "2h", "1d"

### Row Behavior

- **Entire row is clickable** → navigates to detail page
- **Hover state:** subtle background shift (`var(--card-hover)`)
- **Left border accent:** 2px, color matches status dot
- **No borders between rows** — use `gap-2` spacing
- **One line always** — no wrapping. Title truncates with ellipsis
- **Pending rows** feel elevated: slightly brighter background or stronger shadow vs history

### Conditional Elements (appear only when relevant)

- **Risk badge** — only shows for `medium`, `high`, `critical`. Hidden for `low`/`none`.
- **Rerun indicator** — only shows when rerun is in progress or failed
- **"Blocking CI"** — only shows when `checkRunId` is present

These appear as small pills between the CI dot and age, only when they have signal.

### PR Number Link

The `(#167)` inside the title is a link to GitHub. To prevent the link click from also triggering row navigation:
- `e.stopPropagation()` on the anchor
- Opens in new tab (`target="_blank"`)

---

## Queue History (Lane Expand)

Keep the existing lane expand for superseded/expired history, but:
- History rows use the same compact format (dot + repo + title + age)
- Trigger: small "2 previous" text link below the main row
- No card-within-card nesting — flat list with subtle indent

---

## Technical Notes

### Files to Modify

1. **`src/app/pp/deploy-requests/page.tsx`**
   - Rewrite `RequestCard` component → `QueueRow`
   - Simplify lane history rendering
   - Remove `Open PR` button, `Review` button
   - Make row a clickable `<Link>`

2. **`src/components/ui/status-badge.tsx`** (optional)
   - Add a `dot` variant that renders just the colored circle

3. **No API changes needed** — all data already available in `DeployRequestListItem`:
   - `prTitle` ✓
   - `prNumber` ✓ (+ fallback parser)
   - `riskLevel` ✓
   - `status` ✓
   - `createdAt` ✓
   - `prUrl` ✓

### CI Health Data

Need to check: does the current API return other GitHub check statuses? If not, this is a Phase 2 addition. For Phase 1, we can show `verificationStatus` in a useful way (skip it for pending, show for decided).

**Decision:** Phase 1 ships without CI health dot if the API doesn't expose it yet. The row is still dramatically cleaner without it.

---

## Phases

### Phase 1: Row Cleanup (this PR)
- New `QueueRow` component replacing `RequestCard`
- Strip to 5 elements: dot, repo, title(#), age
- Whole row clickable
- Conditional risk badge (medium+)
- Simplified lane history

### Phase 2: CI Health
- API endpoint or field to expose non-PP check statuses
- Green/red CI dot in row
- Tooltip with check details

---

## Success Metrics

- Row scannable in <2 seconds (visual test)
- Zero buttons visible in queue list
- Title visible for every row (no more "what does PR #167 even do?")
