# Runbook: Add PP Deploy Gate to a New Repo

**Time:** ~5 minutes if everything's ready

## Prerequisites

- Repo is under `permission-protocol` org
- You have admin access to the repo (for secrets + branch protection)
- A PP API key with **both** scopes: `receipts.verify` + `deployRequests.create`
  - Create at: https://app.permissionprotocol.com/pp/api-keys

## Step 1: Add the workflow file

Create `.github/workflows/deploy-gate.yml`:

```yaml
name: Deploy Gate

on:
  pull_request:
    branches: [main]

jobs:
  gate:
    name: Permission Protocol
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: permission-protocol/deploy-gate@v1
        with:
          pp-api-key: ${{ secrets.PP_API_KEY }}
          pp-base-url: ${{ secrets.PP_BASE_URL }}
```

## Step 2: Set repo secrets

Go to: `https://github.com/permission-protocol/<REPO>/settings/secrets/actions`

| Secret | Value |
|--------|-------|
| `PP_API_KEY` | Your `pp_live_...` key (must have `deployRequests.create` scope!) |
| `PP_BASE_URL` | `https://app.permissionprotocol.com` |
| `PP_REQUEST_CREATE_TOKEN` | The request-create token (check `~/.openclaw/secrets/pp-request-create-token.txt`) |

## Step 3: Enable branch protection (optional but recommended)

Go to: `https://github.com/permission-protocol/<REPO>/settings/branches`

- Add rule for `main`
- Require status checks: **Permission Protocol**
- Enable "Require branches to be up to date"

## Step 4: Verify end-to-end

Open a test PR that touches a protected path (e.g., `deploy/` or `.github/workflows/`).

**Check each step passes:**

- [ ] Gate runs and detects protected files
- [ ] Request auto-creates (check https://app.permissionprotocol.com/pp/deploy-requests)
- [ ] Approve the request in PP UI
- [ ] Re-run the check → passes with ✅ APPROVED
- [ ] PR is mergeable

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "API key missing deployRequests.create scope" | Key only has `receipts.verify` | Create new key with both scopes at `/pp/api-keys` |
| Empty deploy queue after gate fails | Auto-create failed (scope or token issue) | Check CI logs for `creationSkippedReason` |
| Gate passes immediately (no block) | Changed files don't match protected paths regex | Check workflow's `PROTECTED_REGEX` pattern |
| "PP API unavailable" | Wrong `PP_BASE_URL` | Must be `https://app.permissionprotocol.com` (not `permissionprotocol.com`) |
| 404 on deploy-requests page | Wrong domain | Use `app.permissionprotocol.com`, not `permissionprotocol.com` |

## Key URLs

- API keys: https://app.permissionprotocol.com/pp/api-keys
- Deploy queue: https://app.permissionprotocol.com/pp/deploy-requests
- Action source: https://github.com/permission-protocol/deploy-gate

## Lessons (from pp-demo 2026-03-09)

- A key existing ≠ a key working. Always verify scopes.
- `PP_BASE_URL` must point to `app.permissionprotocol.com` — the marketing site won't work.
- Test the FULL loop (gate → request → approve → re-run → merge) before declaring done.
- Don't forget to add issues to the PP Product board (Project Node ID: `PVT_kwDOD2Ims84BRQBA`).
