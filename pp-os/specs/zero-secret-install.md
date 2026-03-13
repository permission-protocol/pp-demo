# Spec: Zero-Secret Install

**Status:** Ready to build (tomorrow)
**Date:** 2026-03-12
**Priority:** #2 — biggest adoption blocker

---

## Problem

Today, installing deploy-gate requires:
1. Create PP account
2. Get API key + tenant ID
3. Add `PP_API_KEY` and `PP_BASE_URL` as GitHub secrets
4. Add the workflow file
5. Enable branch protection

Most developers stop at step 2. Secrets kill adoption.

## Goal

Install deploy-gate with zero configuration:

```yaml
- uses: permission-protocol/deploy-gate@v1
```

No secrets. No account. No setup. First PR just works.

## How It Works

### First-time flow (new org, no PP account):

```
1. Developer adds workflow file with just `uses: permission-protocol/deploy-gate@v1`
2. AI agent opens PR
3. Deploy-gate action runs:
   a. No PP_API_KEY found in env → enters "auto-provision" mode
   b. Extracts GitHub org from GITHUB_REPOSITORY env var
   c. Calls PP API: POST /api/v1/auto-provision
      Body: { org: "my-company", repo: "my-company/api", sender: "codex-bot" }
      Auth: GitHub Actions OIDC token (ACTIONS_ID_TOKEN_REQUEST_TOKEN)
   d. PP backend:
      - Verifies the OIDC token is legitimate (from GitHub Actions)
      - Finds or creates a workspace for this org
      - Returns: { tenant_id, approval_url, request_id }
   e. Action creates deploy request using the returned tenant context
   f. Sets commit status to pending
   g. Posts PR comment with approval link
4. Merge blocked
5. Anyone clicks approval link → GitHub OAuth login → approve → receipt
6. Merge unblocked
```

### Returning flow (org already has workspace):

Same as above, but step (d) finds the existing workspace instead of creating one.

### Upgrade flow (developer wants dashboard):

```
1. Developer visits permissionprotocol.com
2. Logs in with GitHub
3. PP detects their org already has a workspace (auto-provisioned)
4. "Claim your workspace" → link GitHub account to workspace
5. Now they have dashboard, policies, team features
```

## Technical Changes

### 1. Deploy-gate action (`permission-protocol/deploy-gate`)

**Current:** Requires `PP_API_KEY` input, fails without it.

**New behavior:**
```
if PP_API_KEY is set:
  use existing authenticated flow (backward compatible)
else:
  request OIDC token from GitHub Actions
  call POST /api/v1/auto-provision with OIDC token
  use returned context for the rest of the flow
```

**OIDC token:** GitHub Actions provides `ACTIONS_ID_TOKEN_REQUEST_TOKEN` and `ACTIONS_ID_TOKEN_REQUEST_URL` automatically. The action requests a token scoped to the PP API audience. This proves the request genuinely comes from GitHub Actions for that repo — no spoofing possible.

**Action.yml changes:**
- Make `api-key` input optional (currently required)
- Add `permissions: id-token: write` note in README
- Workflow needs `id-token: write` permission for OIDC

### 2. PP API — new auto-provision endpoint

**Route:** `POST /api/v1/auto-provision`

**Auth:** GitHub Actions OIDC token in Authorization header

**Request:**
```json
{
  "org": "my-company",
  "repo": "my-company/api",
  "sender": "codex-bot",
  "pr_number": 42,
  "commit_sha": "abc123"
}
```

**Backend logic:**
1. Verify OIDC token with GitHub's OIDC provider
2. Extract org + repo from token claims (don't trust request body alone)
3. Find workspace by org name
4. If no workspace: create one (auto-provisioned, free tier, 1 repo, 100 receipts)
5. Create deploy request in that workspace
6. Return: `{ request_id, approval_url, tenant_id }`

**Response:**
```json
{
  "request_id": "abc-123",
  "approval_url": "https://permissionprotocol.com/review/abc-123",
  "workspace": {
    "id": "ws_xxx",
    "org": "my-company",
    "tier": "free",
    "auto_provisioned": true
  }
}
```

### 3. Workspace claiming

**When user logs in with GitHub OAuth:**
- Check if their GitHub org has an auto-provisioned workspace
- If yes: show "Claim workspace" prompt
- Claiming links the workspace to their account
- Unlocks dashboard, settings, team features

### 4. Free tier limits (enforced on auto-provisioned workspaces)

- 1 repo (the first one that triggers auto-provision)
- 100 receipts/month
- Public receipts only
- No policies, no roles, no integrations
- Upgrade prompt when limits hit

## What Does NOT Change

- Existing users with API keys: zero impact, backward compatible
- The approval/receipt flow: identical
- The review page: identical
- Branch protection: still needed (user's responsibility)

## Security Considerations

- OIDC token verification prevents spoofing (only real GitHub Actions can auto-provision)
- Auto-provisioned workspaces are sandboxed (free tier limits)
- No API key is ever generated in the auto-provision flow — the action uses per-request OIDC auth
- Rate limit auto-provision: max 10 new workspaces per org per day

## Migration Path

1. Deploy API endpoint first (backward compatible)
2. Update deploy-gate action to try OIDC when no API key
3. Update docs/quickstart to show the simpler install
4. Existing users: nothing changes

## Open Questions

- Should auto-provisioned workspaces expire after 90 days of inactivity?
- Should we allow multiple repos on free tier? (1 is restrictive but creates clear upgrade path)
- Do we need email collection during auto-provision for follow-up? (probably not — GitHub org is enough to find them later)
