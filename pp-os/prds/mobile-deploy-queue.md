# PRD: Mobile Deploy Queue

**Status:** Draft
**Author:** Charles + Rod
**Date:** 2026-03-11
**Context:** [Discord thread — Ideal Approval Screen](https://discord.com/channels/1479269120334762008/1481392726070005770)
**Related:** [Mobile Approval Screen PRD](./mobile-approval-screen.md)

---

## Problem

Deploy queues on every existing platform are tables. Tables on mobile are hostile — horizontal scrolling, tiny tap targets, information overload. The result: approvers only clear their queue from a laptop. Deploys wait hours for someone to sit down.

The queue isn't a report. It's a **decision inbox.** Every second the approver spends parsing the UI is a second their team is blocked. The current ReviewDashboard works on desktop but fails the "clear 3 staging deploys while waiting for coffee" test.

**PP's opportunity:** A queue so fast that approvers *prefer* checking it on their phone. Clear the queue in 15 seconds. Make pending = 0 feel like inbox zero.

---

## Design Principles

1. **Urgency-first, not chronology-first.** Sort by what matters most, not what arrived most recently.
2. **Cards, not rows.** Each pending request is a self-contained decision unit with inline actions.
3. **Act from the list.** Routine approvals shouldn't require navigating to a detail page.
4. **Pending is the default.** History is one tap away, not competing for attention.
5. **The queue should feel like an inbox.** Clearing it should feel satisfying. Empty state = accomplishment.

---

## User Persona

Same as the Approval Screen PRD: **VP Eng / Team Lead / Senior Dev** checking deploys on mobile between meetings, in transit, or during breaks. They have 15–60 seconds of attention. They manage 3–15 deploy requests per day across 1–5 repos.

---

## Screen Anatomy (Top → Bottom)

### 1. Pulse Bar (The Queue's Heartbeat)

Always visible at the top. One glance tells you if you need to act.

```
┌─────────────────────────────────────┐
│  🔴 3 waiting on you                │
│  Oldest: 47 min · Avg wait: 22 min  │
└─────────────────────────────────────┘
```

**States:**

| Condition | Color | Message |
|-----------|-------|---------|
| Any pending > 60 min | 🔴 Red (pulsing dot) | `N waiting on you · Oldest: Xh Ym` |
| Any pending < 60 min | 🟡 Amber | `N waiting on you · Oldest: Xm` |
| Zero pending | 🟢 Green | `All clear — nothing pending` |

**Fields:**
- **Count:** Number of pending requests for this user's org
- **Oldest:** Age of the oldest pending request (the bottleneck metric)
- **Avg wait:** Mean wait time across all pending (pattern detection)

**Behavior:**
- Sticky on scroll (collapses to compact mode: just the count + color dot)
- Tapping the pulse bar when pending = 0 scrolls to "Recently completed" section
- Oldest wait > 4 hours: add a subtle "⚠️ Team may be blocked" subtext

---

### 2. Batch Action Bar (Conditional)

Appears ONLY when safe bulk action is possible.

```
┌─────────────────────────────────────┐
│  ⚡ Approve all 4 staging deploys   │
│  All low risk · All tests passing   │
└─────────────────────────────────────┘
```

**Visibility conditions (ALL must be true):**
- 2+ pending requests
- ALL pending are non-production (staging, dev, preview)
- ALL pending are risk tier "low"
- ALL pending have CI checks passing (or no checks configured)

**Behavior:**
- Single tap → hold-to-confirm (1s hold, progress bar fills)
- On confirm: all cards slide up simultaneously, toast "Approved N deploys ✓" with undo
- Each approval generates its own UAR (not a batch receipt)
- If any individual approval fails, the failed card slides back with error shake; successful ones stay cleared

**When conditions aren't met:** Bar is completely hidden. No disabled state, no "you can't do this because..." — just absent. Clean.

---

### 3. Filter Chips

Two rows of horizontally scrollable chips. Compact, swipeable.

**Row 1: Environment**
```
  [All]  [🔴 Prod (1)]  [🟡 Staging (3)]  [Dev]
```

**Row 2: Status**
```
  [⏳ Pending (4)]  [✅ Approved]  [❌ Denied]  [All]
```

**Behavior:**
- Default selection: `All` environments + `Pending` status
- Active chip: filled with accent color. Inactive: outlined.
- Counts shown on chips with pending items
- Chips with zero items: shown but dimmed (not hidden — prevents layout shift)
- Tapping an already-active chip deselects it (returns to "All")
- If user has 5+ connected repos, add a third row for repo filter

**Smart defaults:**
- On first load: Pending only. The approver came to act.
- Filters persist during the session (don't reset on pull-to-refresh)
- Deep link support: `/review?status=pending&env=production` applies filters on load

---

### 4. Pending Request Cards

The core of the queue. Each card is a complete decision unit.

```
┌─────────────────────────────────────┐
│ 🔴 PROD    permission-protocol/app  │
│                                     │
│ Add rate limiting to /auth          │
│ Sarah Chen · 47 min ago             │
│                                     │
│ 🟡 Medium risk · 3 files (+82/-3)   │
│ ✅ Tests (14/14) · ✅ 2 reviews     │
│                                     │
│  ┌──────────┐  ┌────────────────┐   │
│  │  Reject  │  │   ✅ Approve   │   │
│  └──────────┘  └────────────────┘   │
└─────────────────────────────────────┘
```

**Card fields (top to bottom):**

| Field | Source | Display |
|-------|--------|---------|
| Environment badge | Deploy request metadata | Colored pill: 🔴 `PROD`, 🟡 `STAGING`, 🔵 `DEV`/`PREVIEW` |
| Repository | Deploy request `resource` field | `org/repo` format. Truncate org if screen is narrow. |
| PR title | `github_pr.title` or `action` | Primary text. Bold. Truncate at 2 lines with ellipsis. |
| Author | `actor` or `requested_by` | Name + relative time. "Sarah Chen · 47 min ago" |
| Risk tier | `risk_tier` | Colored: 🟢 Low, 🟡 Medium, 🔴 High/Critical |
| Change size | From enrichment `diff` | "N files (+additions/-deletions)" |
| Trust signals | Merge readiness + enrichment | Inline summary: "✅ Tests (14/14) · ✅ 2 reviews" or "❌ Tests failing · ⚠️ No reviews" |
| Action buttons | — | Approve (green, prominent) + Reject (outlined, secondary) |

**Card interactions:**

| Gesture | Action |
|---------|--------|
| Tap card body | Navigate to detail page (`/review/[id]`) |
| Tap Approve button | Inline approve (with friction rules below) |
| Tap Reject button | Opens reject reason sheet |
| Swipe right | Quick approve (same friction rules as button) |
| Swipe left | Quick reject (opens reason sheet) |
| Long press | Shows quick-actions menu: Approve, Reject, Delegate, Snooze |

**Inline approve friction rules:**
- Low/medium risk + non-production: Single tap. Instant.
- High risk OR production: Hold-to-confirm (1s). Progress indicator on the button.
- Critical risk + production: Blocked from inline. Tap navigates to detail page with full context.
- Tests failing: Single tap opens a confirmation: "Tests are failing. Approve anyway?" with justification field.

**Post-action animation:**
- Approve: Card slides up and fades out (200ms). Next card moves up to fill the gap.
- Reject: Card slides left and fades. Feels like dismissing.
- Toast at bottom: "Approved ✓" or "Rejected" with 5-second undo link.
- Optimistic UI: animation starts immediately. If API fails within the undo window, card slides back with error shake.

---

### 5. Card Sort Order

Default sort is **urgency-weighted**, not chronological.

**Sort algorithm (descending priority):**

| Priority | Criteria | Rationale |
|----------|----------|-----------|
| 1 | Production + Critical/High risk + oldest | The "someone's really waiting" case |
| 2 | Production + any risk, by age | All production is urgent |
| 3 | Any environment + age > 30 min | Staleness matters |
| 4 | Staging/Dev by age (oldest first) | Natural FIFO for routine deploys |

**Future enhancement (not v1):** Learn from the approver's patterns. If they always approve staging for `repo-x` instantly, rank those lower (they'll batch-approve anyway).

---

### 6. Recently Completed (Collapsed Section)

Below pending cards, a collapsible section for history.

```
┌─────────────────────────────────────┐
│ ▸ Recently completed (7 today)      │
└─────────────────────────────────────┘
```

**Behavior:**
- Collapsed by default when pending > 0
- Auto-expanded when pending = 0 (the queue is clear, so show what happened)
- Shows today's approved + denied requests
- Compact card format (no action buttons — just status icon, title, time, who acted)
- Tapping a completed card navigates to its detail page (for audit trail, receipt link)
- "View all history →" link at bottom for full paginated history

**Compact completed card:**
```
┌─────────────────────────────────────┐
│ ✅ Update pricing page copy         │
│    staging · Sarah · approved 2h ago│
└─────────────────────────────────────┘
```

---

### 7. Empty State

When pending = 0 and no filters are hiding anything:

```
┌─────────────────────────────────────┐
│                                     │
│          ✅  All clear              │
│                                     │
│    No pending deploy requests.      │
│    Last approved: 23 min ago        │
│                                     │
│    Your team deployed 12 times      │
│    today. Avg approval: 4 min.      │
│                                     │
│    ▸ View recent activity           │
│                                     │
└─────────────────────────────────────┘
```

**Details:**
- Celebratory but not obnoxious (no confetti on empty state — save that for batch approve)
- Show org stats: deploys today, average approval time
- "Last approved" gives temporal context — "am I checking too often or not enough?"
- "View recent activity" expands the completed section

**Empty state with filters active:**
```
┌─────────────────────────────────────┐
│    No production requests pending.  │
│    [Clear filters]                  │
└─────────────────────────────────────┘
```

Different message. Makes it clear that filters are hiding things, not that the queue is truly empty.

---

## Pull-to-Refresh

- Standard pull-to-refresh gesture on the card list
- Shows last refresh timestamp: "Updated just now" / "Updated 2 min ago"
- Refreshes all data: pending count, card contents, merge readiness
- Spinner at top during refresh — cards stay visible (don't flash to loading state)

---

## Skeleton Loading

On initial page load, show ghost cards that match the real card layout:

```
┌─────────────────────────────────────┐
│ ████ ████    ██████████████████████  │
│                                     │
│ ████████████████████████            │
│ █████████ · ████████                │
│                                     │
│ ██████████ · ██████████             │
│                                     │
│  ┌──────────┐  ┌────────────────┐   │
│  │ ████████ │  │ ██████████████ │   │
│  └──────────┘  └────────────────┘   │
└─────────────────────────────────────┘
```

- Show 3 skeleton cards (matches most common queue size)
- Pulse animation on skeleton blocks
- Skeleton → real cards transition: fade in with stagger (50ms per card)
- If data loads in < 200ms, skip skeleton entirely (no flash)

---

## Real-Time Updates

The queue must stay fresh without manual refresh.

**Polling strategy:**
- While pending > 0: poll every 15 seconds (matches current implementation)
- While pending = 0: poll every 60 seconds (less urgent)
- On visibility change (tab/app becomes visible): immediate refresh
- On push notification tap: immediate refresh

**Live update behavior:**
- New request arrives: card slides in from top with subtle highlight pulse
- Request resolved by someone else: card fades out with "Approved by [name]" toast
- CI status changes: trust signal updates in-place (no card re-render)
- Stale summary detected: yellow dot appears on affected card

---

## Repository Display Logic

Smart repo name display to save horizontal space:

| Scenario | Display |
|----------|---------|
| Single org, all repos unique | `app`, `site`, `docs` (repo name only) |
| Multiple orgs OR ambiguous names | `pp/app`, `rv/site` (abbreviated org) |
| Full name needed (settings, search) | `permission-protocol/app` |

Abbreviation rules:
- Use first 2-3 chars of org name if unambiguous within the user's repos
- If org abbreviation is ambiguous, use more chars or full name
- Always show full name on long-press / hover (tooltip)

---

## Technical Architecture

### Data Requirements

The queue needs these fields per request (most already available):

| Field | Source | Currently Available? |
|-------|--------|---------------------|
| Request ID | PP API | ✅ |
| Status | PP API | ✅ |
| PR title | PP API (`github_pr.title`) | ✅ |
| Repository | PP API (`resource`) | ✅ |
| Environment | PP API or enrichment | ✅ (from deploy request) |
| Risk tier | PP API | ✅ |
| Actor/Author | PP API | ✅ |
| Created at | PP API | ✅ |
| CI checks | GitHub API (merge readiness) | ✅ (via enrichment) |
| Review count | GitHub API | ⚠️ Needs adding |
| File count / diff stats | GitHub API (enrichment) | ✅ |
| Blast radius | AI enrichment | 🆕 Phase 1 adds this |

### API Changes

**Modified: `GET /api/reviews`**

Current response:
```json
{
  "requests": [{ "id", "status", "repo", "env", "pr_number", "pr_title", "actor", "capability", "risk_tier", "created_at" }]
}
```

Enhanced response:
```json
{
  "requests": [...],
  "stats": {
    "pending_count": 4,
    "oldest_pending_minutes": 47,
    "avg_wait_minutes": 22,
    "today_approved": 12,
    "today_denied": 1,
    "avg_approval_seconds": 240,
    "batch_approvable": true,
    "batch_approvable_ids": ["req_1", "req_2"]
  }
}
```

New fields on each request:
```json
{
  "trust_signals_summary": {
    "checks_passing": 14,
    "checks_total": 14,
    "review_count": 2,
    "has_failing_checks": false
  },
  "diff_stats": {
    "files_changed": 3,
    "additions": 82,
    "deletions": 3
  }
}
```

**New: `POST /api/reviews/batch-approve`**
```json
{
  "request_ids": ["req_1", "req_2", "req_3"],
  "reason": "Batch approve — all low risk staging"
}
```
Response: array of individual results (some may fail).

### Component Architecture

```
ReviewPage (page.tsx)
├── PulseBar
│   └── stats from /api/reviews response
├── BatchActionBar (conditional)
│   └── visible only when stats.batch_approvable
├── FilterChips
│   ├── EnvironmentFilters
│   └── StatusFilters
├── PendingSection
│   ├── RequestCard (×N)
│   │   ├── EnvironmentBadge
│   │   ├── CardBody (title, author, risk, signals)
│   │   ├── InlineApproveButton
│   │   ├── InlineRejectButton
│   │   └── SwipeHandler
│   └── EmptyState (when filtered to zero)
├── CompletedSection (collapsible)
│   └── CompactCard (×N)
└── UndoToast (floating, bottom)
```

---

## Phased Implementation

### Phase 1 — Core Queue (aligns with Approval Screen Phase 1)
- [ ] Pulse bar with pending count, oldest wait, avg wait
- [ ] Request cards with env badge, title, author, time, risk, inline trust signals
- [ ] Inline approve/reject on cards (with friction rules)
- [ ] Urgency-based sort order
- [ ] Mobile-responsive card layout (no tables, no horizontal scroll)
- [ ] Filter chips (environment + status)
- [ ] Recently completed section (collapsed)
- [ ] Empty state with org stats
- [ ] Skeleton loading
- [ ] Post-action animation (slide up/away + undo toast)

### Phase 2 — Intelligence (aligns with Approval Screen Phase 2)
- [ ] Batch approve with safety checks
- [ ] Smart repo name abbreviation
- [ ] Author track record badge on cards
- [ ] Stale summary indicator (yellow dot)
- [ ] Sort learning (future — flag only, don't implement yet)

### Phase 3 — Real-Time (aligns with Approval Screen Phase 3)
- [ ] Visibility-based refresh
- [ ] Live card updates (new request slides in, resolved slides out)
- [ ] Pull-to-refresh with last-updated timestamp
- [ ] PWA badge count (pending requests on app icon)

### Phase 4 — Gestures & Polish (aligns with Approval Screen Phase 4)
- [ ] Swipe-right to approve, swipe-left to reject
- [ ] Long-press quick-action menu
- [ ] Haptic feedback on actions
- [ ] Optimistic UI with error recovery
- [ ] Card re-order animation when sort changes

---

## Success Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| Time to clear 3 routine staging deploys | < 15 seconds | The "coffee line" benchmark |
| % of sessions that clear all pending | > 70% | People finish what they start |
| Inline approve rate (vs navigating to detail) | > 60% for low-risk | Validates that cards have enough info |
| Queue check frequency | > 3x per day per approver | People voluntarily check (not just via notifications) |
| Time-to-zero (from 1+ pending → 0) | < 5 minutes median | Approvals happen fast |
| Batch approve usage | > 30% of eligible sessions | Power feature gets adopted |

---

## What We're NOT Building

- **Table/grid view for mobile.** Cards only. Table is desktop-only if ever.
- **Complex sort controls.** Urgency sort is the default and only option on mobile.
- **Request creation from queue.** The "Create Request" button moves to a settings/admin area, not the action queue.
- **Org-wide analytics.** The pulse bar gives at-a-glance stats. Full analytics is a different page.
- **Approval chains visualization.** Single-approver for v1.
- **Real-time WebSocket.** Polling is fine for v1. WebSocket upgrade when polling latency becomes a complaint.

---

## Open Questions

1. **Swipe gestures — collision with mobile browser back gesture?** iOS swipe-from-edge = back navigation. Need to ensure card swipe only activates on swipe starting from card center, not screen edge.
2. **Batch approve receipt — one aggregate receipt or N individual receipts?** Individual receipts maintain the UAR-per-action primitive. Batch is a UI convenience, not a new receipt type.
3. **Queue across multiple orgs?** If an approver belongs to 2 orgs, do they see one merged queue or switch between orgs? V1: single org. Multi-org is a settings/auth concern.
4. **Inline approve latency — what if the API takes > 2 seconds?** Optimistic UI handles this, but need a clear pattern for "undo expired + API still pending" edge case. Probably: disable undo after 5s, show spinner until API confirms.
5. **Should denied requests stay visible in the pending section briefly?** After inline reject, the card disappears. But the author might immediately re-push and create a new request. Should we show "Re-requested" linkage? Probably Phase 2.

---

## Appendix: Card Variants

### Standard Pending Card
Full card with all fields and action buttons. Used for most pending requests.

### Compact Completed Card
No action buttons. Status icon + title + author + time. Single line where possible.

### Critical Alert Card
For critical-risk production requests. Red left border + red environment badge + expanded risk rationale visible by default (not collapsed). No inline approve — must tap into detail page.

```
┌─────────────────────────────────────┐
│ 🔴 PROD  ║  permission-protocol/app │
│          ║                          │
│ Drop users table migration          │
│ New contributor · 3 min ago         │
│                                     │
│ 🔴 CRITICAL: Database migration     │
│    deletes user data. First deploy  │
│    from this author.                │
│                                     │
│  ┌───────────────────────────────┐  │
│  │     Review before deciding →  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

Forces navigation to detail page. No shortcut. Some decisions shouldn't be fast.
