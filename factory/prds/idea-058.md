# PRD: idea-058 — Add prTitle to DeployGateRequest + populate from deploy-gate action

**Issue:** permission-protocol/app#92
**Priority:** P2
**Repo:** permission-protocol/app
**Size:** S

## Problem
Deploy requests don't store the PR title. The queue shows fallback text "Pull Request #N" instead of the actual PR title. Users can't scan the queue meaningfully without clicking into each request.

## User Journey
1. Marco opens the deploy queue on the PP dashboard
2. Sees a list of "Pull Request #42", "Pull Request #43", etc.
3. Has no idea what any of them are without clicking each one
4. **Expected:** Sees actual PR titles like "Add Stripe webhook handler", "Fix auth redirect loop"

## Requirements

### Must Have
1. **Prisma schema change:** Add `prTitle String?` to the `DeployGateRequest` model
2. **Migration:** Generate and apply Prisma migration
3. **Verify endpoint:** Accept `prTitle` in the request body at the verify/create endpoint (`src/app/api/v1/receipts/verify/route.ts` or equivalent)
4. **Deploy-gate action:** Send `prTitle` when creating the deploy request (check the action source for where it calls the verify endpoint — it already has access to PR title from the GitHub context)
5. **Queue display:** Use `request.prTitle` instead of the "Pull Request #N" fallback in the dashboard queue view

### Implementation Notes
- The deploy-gate GitHub Action already has `github.event.pull_request.title` in its context — just pass it through
- The verify endpoint needs to accept and store the new field
- Dashboard queue component needs to prefer `prTitle` over the fallback
- Existing requests without `prTitle` should still show the fallback gracefully

### Must NOT Do
- Don't change the deploy-gate action's required inputs (prTitle should be auto-detected, not user-configured)
- Don't break existing requests that don't have prTitle
- Don't modify the receipt page — only the queue/list view

## Acceptance Criteria
- [ ] Prisma migration runs cleanly
- [ ] New deploy requests store PR title
- [ ] Queue shows actual PR titles for new requests
- [ ] Old requests without prTitle still render with fallback
- [ ] deploy-gate action sends prTitle without user configuration
