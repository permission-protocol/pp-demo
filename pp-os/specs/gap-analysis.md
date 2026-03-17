# Gap Analysis — App-Only Flow for Jake

*Audited March 17, 2026. Based on actual codebase.*

## The Big Finding

**The webhook handler only processes `pull_request.closed`.** It does NOT handle `opened`, `synchronize`, or `reopened`. This means:

- When an agent opens a PR, the App webhook receives it but **ignores it**
- Deploy request creation currently ONLY happens through the GitHub Action (deploy-gate)
- The Action calls `/api/v1/receipts/verify` which auto-creates a request if none exists
- The Action then polls for approval and sets commit status

**The entire PR → deploy request → block merge flow depends on the Action YAML being in the repo.** Without it, nothing happens.

## What Already Works (No Changes Needed)

| Component | Status | Notes |
|---|---|---|
| GitHub App install webhook | ✅ | Stores installation, repos, permissions |
| Installation token generation | ✅ | JWT + caching, can make API calls as the App |
| Set commit status (pending/success) | ✅ | `post-approval-actions.ts` + `getAppTokenForRepo()` |
| Post PR comment | ✅ | `postApprovalPrComment()` — currently only on approval |
| Enable auto-merge | ✅ | `enableAutoMerge()` via GraphQL |
| Enrichment pipeline | ✅ | Fires on deploy request creation, generates AI summary |
| Approve → receipt → merge flow | ✅ | Full flow works end-to-end |
| Repo ↔ installation lookup | ✅ | `getInstallationForRepo()`, `getAppTokenForRepo()` |

## What's Missing (Must Build)

### Gap 1: Webhook PR handler (THE BIG ONE)

**File:** `src/app/api/github-app/webhook/route.ts`

Currently the `pull_request` case only handles `closed`. Need to add handling for `opened`, `synchronize`, `reopened`:

```
pull_request.opened/synchronize/reopened →
  1. Look up installation → company from repo
  2. Create deploy request (Postgres) — needs new internal function, NOT the tenant-authed API
  3. Set commit status to "pending" on the PR head SHA
  4. Trigger enrichment worker (async)
  5. After enrichment completes → post rich PR comment with summary + approve/reject links
```

**Key challenge:** The current `POST /api/v1/deploy-requests` route requires `withTenant` (user auth). The webhook handler has no user context — it has an installation context. Need a new internal function that creates deploy requests from installation context (installation → company mapping already exists in `GitHubAppInstallation.companyId`).

### Gap 2: Rich PR comment on creation (not just approval)

**Currently:** PR comment only posted after approval (`postApprovalPrComment()`).
**Needed:** PR comment posted when enrichment completes, containing:
- AI summary
- Risk level
- Verification steps
- Direct approve link (`https://app.permissionprotocol.com/review/{requestId}?action=approve`)
- Direct reject link

Need a new function: `postReviewRequestPrComment()` — posts the "awaiting review" comment with enrichment data. The existing `postApprovalPrComment()` then updates it to "approved" status.

### Gap 3: Eliminate setup requirements

**File:** `src/lib/github-app/repo-status.ts`

Current "ready" status requires ALL THREE:
- `workflowInstalled` (Action YAML exists)
- `secretInjected` (PP_API_KEY in repo secrets)
- `rulesetCreated` (branch protection rule exists)

For App-only flow, NONE of these should be required. The App itself:
- Receives webhooks (replaces the Action)
- Uses installation tokens (replaces PP_API_KEY)
- Sets commit status (replaces ruleset — though branch protection requiring the status check is nice-to-have)

**Action:** Make these three flags optional/legacy. A repo is "ready" if it has a connected `GitHubAppRepo` record with an active installation. Period.

### Gap 4: Direct approve from link

The approve link in the PR comment needs to land on a page that:
1. Shows the AI summary (already rendered on detail page)
2. Has a prominent approve button (already exists)
3. Handles auth seamlessly (GitHub OAuth — already works)

**This might already work.** The existing `/review/{requestId}` page does all of this. Just need to verify the UX is clean enough for a cold link click (no dashboard context needed).

## Estimated Work

| Gap | Effort | Dependencies |
|---|---|---|
| 1. Webhook PR handler | 1-2 days | None |
| 2. Rich PR comment | 0.5 day | Gap 1 (needs enrichment data) |
| 3. Eliminate setup requirements | 0.5 day | None |
| 4. Direct approve from link | Verify only | Might already work |

**Total: ~3 days to make the App-only flow work for Jake.**

## Architecture After

```
BEFORE (current):
  Agent PR → GitHub Action (YAML in repo) → PP API (needs API key) → deplopy request
  → enrichment → user checks dashboard → approve → status + merge

AFTER (Jake flow):
  Agent PR → GitHub App webhook (auto) → deploy request (internal) 
  → enrichment → rich PR comment with summary → user clicks approve link
  → approve → status + auto-merge → receipt
```

Jake's install: click "Install" → select repos → done.
Jake's review: GitHub notification → read summary in PR → click approve → merged.
No YAML. No secrets. No dashboard.
