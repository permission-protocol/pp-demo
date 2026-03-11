# PRD: Dashboard Redesign — Deploy Gate Home

**Status:** Draft
**Author:** Charles
**Date:** 2026-03-10
**Target:** permission-protocol/app `/pp` (page.tsx)

---

## Problem

After login, users land on a "Control Plane / Founder View" dashboard built for autonomous agent governance — kill switches, policy snapshots, capability digests. None of this is relevant to deploy-gate users. It's confusing, empty, and screams "template."

The dashboard is the first thing a user sees after signup. It needs to answer three questions in 3 seconds:
1. **Do I have anything to approve right now?**
2. **What's been happening across my repos?**
3. **Is deploy-gate working?**

## Users

- **Primary:** Developer who just installed deploy-gate on their repo (Day 1 user)
- **Secondary:** Team lead checking in on deployment approvals
- **Tertiary:** New signup who hasn't installed anything yet (empty state)

## Design Principles

- **Data-driven, not template-driven** — every element shows real data from the user's tenant
- **Action-oriented** — pending approvals have approve/deny right on the dashboard, no click-through required
- **Progressive disclosure** — empty state guides setup, active state shows activity
- **Dark, minimal, sharp** — matches the approval page aesthetic (`.approval-surface` tokens)

## Layout

### Empty State (No Repos Connected)

Full-page onboarding:

```
┌─────────────────────────────────────────────────┐
│                                                  │
│  🛡️  Welcome to Permission Protocol              │
│                                                  │
│  Gate your first repo in 3 minutes.              │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │ Step 1: Add the workflow to your repo     │   │
│  │ ┌──────────────────────────────────┐      │   │
│  │ │ name: Permission Protocol        │ 📋   │   │
│  │ │ on: pull_request                 │      │   │
│  │ │ jobs:                            │      │   │
│  │ │   gate:                          │      │   │
│  │ │     uses: permission-protocol/   │      │   │
│  │ │       deploy-gate@v1             │      │   │
│  │ └──────────────────────────────────┘      │   │
│  │                                            │   │
│  │ Step 2: Add your API key as a secret       │   │
│  │ PP_API_KEY → repo Settings → Secrets       │   │
│  │ Your key: pp_live_••••••••  [Copy] [Docs]  │   │
│  │                                            │   │
│  │ Step 3: Open a PR and watch it work        │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
└─────────────────────────────────────────────────┘
```

Detection: query deploy requests for tenant. If zero results → show empty state.

### Active State (Has Deploy Requests)

```
┌─────────────────────────────────────────────────┐
│ Permission Protocol                    [Refresh] │
│                                                  │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────┐ │
│ │ 47       │ │ 3        │ │ 12       │ │ 2m  │ │
│ │ PRs Gated│ │ Pending  │ │ Approved │ │ Avg │ │
│ │          │ │          │ │ Today    │ │ Time│ │
│ └──────────┘ └──────────┘ └──────────┘ └─────┘ │
│                                                  │
│ ⚡ Needs Attention (3)                           │
│ ┌──────────────────────────────────────────────┐ │
│ │ fix: auth redirect loop          repo/app    │ │
│ │ PR #42 · opened 15m ago · medium risk        │ │
│ │ [Approve ✓]  [View Details →]                │ │
│ ├──────────────────────────────────────────────┤ │
│ │ feat: add webhook retry          repo/api    │ │
│ │ PR #108 · opened 2h ago · low risk           │ │
│ │ [Approve ✓]  [View Details →]                │ │
│ ├──────────────────────────────────────────────┤ │
│ │ chore: update deps               repo/site   │ │
│ │ PR #77 · opened 4h ago · low risk            │ │
│ │ [Approve ✓]  [View Details →]                │ │
│ └──────────────────────────────────────────────┘ │
│                                                  │
│ Recent Activity                                  │
│ ┌──────────────────────────────────────────────┐ │
│ │ ✅ feat: new landing page    repo/site  12m  │ │
│ │ ✅ fix: rate limiter         repo/api   1h   │ │
│ │ ❌ test: break prod          repo/app   2h   │ │
│ │ ✅ docs: update readme       repo/docs  5h   │ │
│ │ ✅ feat: billing flow        repo/app   8h   │ │
│ └──────────────────────────────────────────────┘ │
│                                                  │
│ Connected Repos (3)                              │
│ repo/app · repo/api · repo/site                  │
└─────────────────────────────────────────────────┘
```

## Data Sources

All data comes from existing deploy request records in the tenant's DB:

| Element | Source | Query |
|---|---|---|
| PRs Gated (total) | `deployGateRequest` count | `WHERE companyId = tenant` |
| Pending | `deployGateRequest` | `WHERE status = 'pending_approval'` |
| Approved Today | `deployGateRequest` | `WHERE status IN ('approved','redeemed') AND updatedAt > today` |
| Avg Response Time | Computed | `AVG(updatedAt - createdAt) WHERE status != 'pending_approval'` |
| Needs Attention | `deployGateRequest` | `WHERE status = 'pending_approval' ORDER BY createdAt` |
| Recent Activity | `deployGateRequest` | `ORDER BY updatedAt DESC LIMIT 10` |
| Connected Repos | `deployGateRequest` | `SELECT DISTINCT repo` |

**No new API endpoints needed.** The existing `/api/v1/deploy-requests` endpoint supports `status`, `limit`, and tenant scoping. We add:
- `GET /api/v1/deploy-requests/stats` — returns `{ total, pending, approvedToday, avgResponseMinutes, repos[] }`

## Components

### StatsBar
- 4 metric cards in a row
- Pending count uses orange/red color when > 0
- Avg time shows "—" if no resolved requests

### NeedsAttention
- Shows pending requests with inline approve button
- Approve triggers same flow as review page (POST `/approve`)
- On approve → card slides out, stats update
- Max 5 shown, "View all →" links to Deploy Requests page
- Each card shows: PR title, repo (short name), PR number, time ago, risk level badge

### RecentActivity
- Compact list, one line per request
- Status icon (✅ approved, ❌ denied, ⏳ pending, 🔄 carried forward)
- PR title, repo short name, relative time
- Click → navigates to detail page

### ConnectedRepos
- Derived from distinct `repo` values in deploy requests
- Simple tag/chip display
- Shows count of requests per repo on hover

### EmptyState
- Full-page takeover when zero deploy requests exist
- Copyable workflow YAML
- Shows user's API key (masked, with copy button)
- Links to docs

## Approve from Dashboard

The inline approve button:
1. POST to `/api/v1/deploy-requests/{id}/approve` with `{ productionConfirmed: true }`
2. On success: remove card from "Needs Attention", decrement pending count, increment approved count
3. On failure: show error toast (expired, already resolved, etc.)
4. **No confirmation modal** — approve is a single click (review page is for deep inspection)

## What Gets Removed

Everything from the current page:
- Kill Switches panel
- Policy panel
- Alerts panel  
- Digest panel
- "Founder control plane" language
- All associated types, fetch calls, sub-components (~600 lines)

These features may return in a future "Advanced" or "Governance" tab, but they are not part of the deploy-gate wedge.

## Styling

Uses existing `.approval-surface` tokens:
- `--background: #0a0a0a`
- `--card: #111111`
- `--border: #222222`
- `--foreground: #c8c8c8`
- `--muted: #888888`
- Approve button: `bg-[#10B981]`
- Risk badges: existing StatusBadge component

## API Endpoint: Stats

```
GET /api/v1/deploy-requests/stats

Response:
{
  total: number,
  pending: number,
  approvedToday: number,
  deniedToday: number,
  avgResponseMinutes: number | null,
  repos: string[],
  oldestPendingAge: number | null  // minutes
}
```

Scoped to authenticated tenant. Uses Prisma aggregations.

## Acceptance Criteria

- [ ] New user with 0 requests → sees onboarding with copyable YAML + API key
- [ ] User with pending requests → sees stats + "Needs Attention" with inline approve
- [ ] Approving from dashboard works (receipt created, status updated, card removed)
- [ ] Stats are accurate (total, pending, approved today, avg time)
- [ ] Recent activity shows last 10 requests with correct status icons
- [ ] Connected repos derived from request data
- [ ] Old dashboard code completely removed (kill switch, policy, digest, alerts)
- [ ] Page loads in < 2s
- [ ] Mobile responsive (stats stack to 2x2 grid)
- [ ] Matches approval page aesthetic (dark, minimal, sharp)

## Out of Scope

- Real-time WebSocket updates (polling every 30s is fine)
- Repo connection via GitHub App (future — repos are detected from incoming requests)
- Policy configuration
- Team/role management
- Notification preferences
