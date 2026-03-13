# PRD: Marketing Site Merge Readiness (50D)

## Problem
The marketing site review page (`permissionprotocol.com/review/{id}`) shows "Merge & Deploy" after approval without knowing if the PR is actually mergeable. Same gap as the app — no visibility into branch status, failing checks, or merge conflicts.

## Solution
Add merge readiness data to the existing review API enrichment. Show the same pre-merge checklist on the marketing site review page.

---

## API Changes

### `GET /api/review/{id}` (marketing site)
Add `merge_readiness` field to the response, fetched alongside existing enrichment.

**Source:** Same GitHub API calls as the app endpoint:
- `GET /repos/{owner}/{repo}/pulls/{number}` → mergeable, mergeable_state
- `GET /repos/{owner}/{repo}/commits/{sha}/check-runs` → check status
- `GET /repos/{owner}/{repo}/compare/{base}...{head}` → behind_by

**New response field:**
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

**When to fetch:** Only when status is `approved` and `pr_merged` is false. No point checking readiness for pending/denied/already-merged requests.

**Caching:** Same 30s cache as enrichment (already cached via enrichment cache).

### `POST /api/review/{id}/update-branch` (new endpoint)
Proxies the "Update Branch" call to the PP app API (or directly to GitHub).
- Requires: GITHUB_TOKEN env var on Vercel
- Calls: `PUT /repos/{owner}/{repo}/pulls/{number}/update-branch`
- Returns: `{ success: boolean, message: string }`

---

## UI Changes

### Review Page (`ReviewPageClient.tsx`)

**Current (after approval):**
```
✅ Approved
[Merge & Deploy]
```

**New (after approval, before merge):**
```
✅ Approved by rod

Pre-merge checks:
  ✅ All checks passing (4/4)
  ✅ Branch up to date with main
[🚀 Merge & Deploy]
```

**With blockers:**
```
✅ Approved by rod

Pre-merge checks:
  ❌ 1 check failing — "Build and test"
  ⚠️ Branch is 3 commits behind main
[Update Branch]     Merge blocked
```

**With conflict:**
```
✅ Approved by rod

Pre-merge checks:
  ❌ Merge conflict
[View on GitHub]    Merge blocked
```

### Checklist Component
Simple inline list between approval status and merge button:
- Each check: icon (✅/❌/⚠️) + label + detail
- Expandable check runs list (collapsed by default)
- Matches existing dark theme (bg-[#0a0a0a], border-[#222222], text-[#c8c8c8])

### Merge Button States
| State | Button | Behavior |
|---|---|---|
| clean, all checks pass | "Merge & Deploy" (blue) | Existing merge flow |
| behind | "Update Branch" (yellow outline) | POST /api/review/{id}/update-branch, then re-fetch readiness |
| dirty | "View on GitHub" (gray outline) | Links to PR, merge disabled |
| checks failing | "Merge & Deploy" disabled | Show tooltip: "Checks must pass before merging" |
| loading/computing | Spinner | Retry automatically |

### After "Update Branch"
- Show "Branch updated — waiting for checks..."
- Poll `/api/review/{id}` every 10s (existing poll already runs while pending — reuse for approved+unmerged)
- When `merge_readiness.mergeable_state` becomes "clean" → show merge button

---

## Implementation

### Files to modify:
1. `app/api/review/lib/enrich.ts` — add `fetchMergeReadiness()` function
2. `app/api/review/[id]/route.ts` — include merge_readiness in response
3. `app/api/review/[id]/update-branch/route.ts` — new endpoint
4. `app/review/[id]/ReviewPageClient.tsx` — pre-merge checklist UI

### `fetchMergeReadiness()` in enrich.ts
```typescript
export async function fetchMergeReadiness(
  owner: string,
  repo: string,
  prNumber: number
): Promise<MergeReadiness | null> {
  const token = process.env.GITHUB_TOKEN;
  if (!token) return null;

  // Fetch PR mergeable state
  // Fetch check runs
  // Fetch behind_by via compare
  // Return structured result
}
```

### Caching
Merge readiness is NOT cached with the enrichment (enrichment has 10-min TTL, merge readiness should be fresher). Use a separate 30s cache keyed on `{repo}#{prNumber}:readiness`.

---

## Dependencies
- `GITHUB_TOKEN` on Vercel (already set — pp-render-merge PAT)
- Existing enrichment cache infrastructure in `enrich.ts`

## What This Does NOT Do
- Auto-refresh when checks complete (future: GitHub App webhooks)
- Show branch protection rule details
- Handle non-GitHub repos
