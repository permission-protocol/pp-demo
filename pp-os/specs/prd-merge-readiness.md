# PRD: Pre-Merge Readiness Check + Deployment Status Timeline

## Problem
PP shows "Merge & Deploy" without knowing if the PR is actually mergeable. GitHub may have:
- Branch out of date with base (needs rebase/update)
- Build/checks failing
- Merge conflicts

Users click merge, it fails, and PP gives no useful feedback. The review page becomes a dead end after approval — no visibility into what's happening between "Approved" and "Shipped."

## Solution
Fetch GitHub merge readiness before showing the merge button. Surface blockers inline. Add a deployment status timeline showing the full lifecycle from approval to ship.

---

## Feature 1: Pre-Merge Readiness (Marketing Site + App)

### Data Source
`GET /repos/{owner}/{repo}/pulls/{number}` returns:
- `mergeable`: boolean | null (null = computing, retry after 1s)
- `mergeable_state`: "clean" | "behind" | "blocked" | "dirty" | "unknown"
- `merge_commit_sha`: preview merge SHA

`GET /repos/{owner}/{repo}/commits/{sha}/check-runs` returns:
- Array of check runs with `name`, `conclusion` (success/failure/neutral/etc), `status` (queued/in_progress/completed)

### UI: Pre-Merge Checklist
Shown between approval status and merge button on the review/detail page:

**All green:**
```
✅ PP Approved
✅ All checks passing (4/4)
✅ Branch up to date with main
────────────────────────
[🚀 Merge & Deploy]
```

**Blockers present:**
```
✅ PP Approved
❌ 1 check failing — "Build and test"
⚠️ Branch is 3 commits behind main
────────────────────────
[Update Branch]     Merge blocked
```

**Merge conflict:**
```
✅ PP Approved
❌ Merge conflict — resolve manually
────────────────────────
Merge blocked — [View on GitHub]
```

### Check Status Display
Each check run shown as a line item (collapsed by default, expandable):
```
Checks (3/4 passing)
  ✅ Lint — 12s
  ✅ Type check — 8s  
  ❌ Build and test — failed after 45s
  ✅ Permission Protocol — approved
```

### Actions
| State | Button | Action |
|---|---|---|
| clean | "Merge & Deploy" | Merge via API |
| behind | "Update Branch" | `PUT /repos/{owner}/{repo}/pulls/{number}/update-branch` |
| dirty | "View on GitHub" | Link to PR (manual conflict resolution) |
| blocked (checks) | Disabled merge | Show which checks are failing |
| null (computing) | Spinner | Re-fetch after 1.5s, max 3 retries |

### "Update Branch" Button
Calls GitHub API to update the PR branch with the base branch. After success:
- Show "Branch updated — checks will re-run"
- Poll for new check results (every 10s, max 5 min)
- When checks pass + branch clean → show merge button

---

## Feature 2: Deployment Status Timeline (App Detail Page)

### Location
`/pp/deploy-requests/[requestId]` — new section after the approval details.

### Timeline View
```
📦 Deployment Status

● Created — Mar 11, 7:02 AM
│  PR #46: GitHub App data models
│
● Approved — Mar 11, 7:15 AM  
│  by rod · Receipt rcpt_dg_...
│
● Merge attempted — Mar 11, 7:15 AM
│  ❌ Failed: branch out of date
│
● Branch updated — Mar 11, 7:18 AM
│  Checks re-running...
│
● Checks passed — Mar 11, 7:20 AM
│  4/4 checks passing
│
● Merged — Mar 11, 7:20 AM
│  Commit abc1234 → main
│
● Shipped ✅
```

### Timeline Events
Sourced from existing DB fields + new merge tracking:
1. **Created** — `createdAt`
2. **Approved** — `decidedAt`, `decidedBy`, `receiptId`
3. **Merge attempted** — `postApprovalActionAt`, `postApprovalActionStatus`
4. **Merge failed** — `mergeStatus = 'merge_failed'`, show reason
5. **Merged** — `mergedAt`, `mergeCommitSha`
6. **Shipped** — terminal success state

### Retry Button
When merge failed:
```
● Merge attempted — 5 min ago
│  ❌ Branch out of date
│  [Retry Merge] [Update Branch] [View on GitHub]
```

---

## Feature 3: Marketing Site Review Page Enhancements

### Current State
After approval, shows "Merge & Deploy" button without context.

### New State
Same pre-merge checklist as app, fetched from the review API enrichment.

### API Changes
`GET /api/review/{id}` response adds:
```json
{
  "merge_readiness": {
    "mergeable": true,
    "mergeable_state": "clean",
    "checks": [
      { "name": "Build and test", "status": "completed", "conclusion": "success" },
      { "name": "Permission Protocol", "status": "completed", "conclusion": "success" }
    ],
    "checks_passing": 4,
    "checks_total": 4,
    "behind_by": 0
  }
}
```

---

## Implementation Plan

### Issue #50A: Merge readiness API
- New endpoint: `GET /api/v1/deploy-requests/{id}/merge-readiness`
- Fetches PR mergeable state + check runs from GitHub
- Caches for 30s (avoid hammering GitHub API)
- Returns: mergeable, mergeable_state, checks[], behind_by
- "Update Branch" endpoint: `POST /api/v1/deploy-requests/{id}/update-branch`

### Issue #50B: Pre-merge checklist UI (app detail page)
- Fetch merge readiness on page load
- Show checklist between approval and merge button
- Update Branch button
- Disable merge when blocked
- Poll after branch update

### Issue #50C: Deployment status timeline (app detail page)
- Build timeline from existing DB fields + merge tracking
- Show full lifecycle: created → approved → merge attempted → merged/failed → shipped
- Retry Merge button on failures

### Issue #50D: Marketing site merge readiness
- Add merge_readiness to review API enrichment
- Show pre-merge checklist on review page
- Update Branch + disabled merge when blocked

### Execution Order
50A → 50B + 50C (parallel) → 50D

---

## Dependencies
- PR #51 (merge tracking data model) — must be merged first
- GitHub token with `contents:write` + `pull_requests:write` (already have via pp-render-merge PAT)
- GitHub App (future) — replaces PAT, adds real-time webhook updates

## What This Does NOT Do
- Real-time push updates (future: GitHub App webhook for check_suite events)
- Auto-retry merge on check pass (future: webhook-driven)
- Branch protection analysis (just shows merge state, doesn't explain why)
