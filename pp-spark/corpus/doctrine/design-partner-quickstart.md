# Deploy Gate Quick Start — 5 Minutes to Your First Protected Deploy

*Welcome, design partner. You're among the first to put Deploy Gate to work, and we want to make sure it clicks fast. This guide gets you from zero to a fully gated production deploy — with a cryptographic receipt to prove it.*

---

## What You'll Get

- **Every deploy to `main` requires an explicit authorization receipt** — no receipt, no merge, no exceptions.
- **An immutable audit trail from day one** — signed, timestamped proof of who approved every production change.
- **Fail-closed enforcement by default** — the pipeline blocks until authorization is confirmed; it never quietly passes.

---

## Step 1 — Prerequisites

Before you start, have these ready:

- [ ] A GitHub repo with Actions enabled and a CI workflow targeting `main`
- [ ] A Permission Protocol account — you should have received credentials in your design partner welcome email. No account yet? Reply to that email and we'll sort it out same day.
- [ ] Your **PP API Key** and **Tenant ID** from the [PP dashboard](https://app.permissionprotocol.com)

*That's it. No SDK to install, no infra to provision.*

---

## Step 2 — Add Your Secrets to GitHub

In your repo, go to **Settings → Secrets and variables → Actions** and add two repository secrets:

| Name | Value |
|---|---|
| `PP_API_KEY` | Your API key from the PP dashboard |
| `PP_TENANT_ID` | Your Tenant ID from the PP dashboard |

These stay encrypted in GitHub and are never exposed in logs.

---

## Step 3 — Add the GitHub Action

Create `.github/workflows/deploy-gate.yml` in your repo:

```yaml
name: Deploy Gate

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  deploy-gate:
    runs-on: ubuntu-latest
    steps:
      - name: Verify Deploy Authorization
        uses: permission-protocol/deploy-gate@v1
        with:
          api-key: ${{ secrets.PP_API_KEY }}
          tenant-id: ${{ secrets.PP_TENANT_ID }}
          scope: |
            {
              "scopeType": "GIT_REF_COMMIT",
              "repo": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "commitSha": "${{ github.sha }}",
              "env": "production",
              "capability": "deploy:production"
            }
```

Commit and push. The check will show up on your next PR as `deploy-gate / Verify Deploy Authorization`.

---

## Step 4 — Configure the Required Check

Lock the gate so it can't be bypassed. In your repo:

1. Go to **Settings → Branches → Branch protection rules**
2. Add a rule for `main` (or your default branch)
3. Enable these settings:
   - ✅ **Require status checks to pass before merging**
     → Search and add: `deploy-gate`
   - ✅ **Require branches to be up to date before merging**
   - ✅ **Do not allow bypassing the above settings**
4. Save the rule

From this point on, no PR merges to `main` without a valid receipt. Not even repo admins.

---

## Step 5 — Approve Your First Deploy

Open a test PR against `main`. You'll see the Deploy Gate check appear as **pending** — it's waiting for an authorization receipt.

To issue one:

1. Go to your [PP dashboard](https://app.permissionprotocol.com)
2. Find the pending deploy request (it should appear automatically within ~30 seconds)
3. Review the scope: repo, commit SHA, environment
4. Click **Approve**

The receipt is signed, timestamped, and sent back to the Action. The check turns green. Your PR is now mergeable.

---

## Step 6 — Verify the Receipt

After the check passes, click into the **Verify Deploy Authorization** step in the GitHub Actions log. You'll see output like:

```
Receipt:     VERIFIED
Signer:      production-authority
Scope:       GIT_REF_COMMIT
Repo:        your-org/your-repo
Commit:      a81f2c3e...
Environment: production
Expires:     2026-04-01T00:00:00Z
```

This receipt is immutable. It lives in PP's ledger and can be retrieved any time for audit purposes.

---

## Troubleshooting

**The check is stuck on "pending" and nothing shows up in the dashboard**
> Make sure your `PP_TENANT_ID` is correct — a wrong tenant ID silently drops the request. Double-check in Settings → API on your dashboard.

**`Error: api-key is required`**
> The secret name is case-sensitive. It must be `PP_API_KEY` exactly — no quotes, no spaces.

**Check passes but branch protection doesn't block the PR**
> You need to add `deploy-gate` to the required status checks list *after* it has run at least once (GitHub only shows checks that have previously executed). Open a test PR first, then add it to the protection rule.

**Receipt shows `SCOPE_MISMATCH`**
> The receipt scope must match exactly. If you approved for `main` but the PR is on a feature branch, it won't verify. Receipts are scoped to a specific commit SHA — they don't transfer.

**Staging approvals aren't unlocking production**
> Correct — that's by design. `env: staging` and `env: production` are separate authorization chains. You'll need a production receipt for a production deploy.

**The check fails immediately with `receipt_not_found`**
> No receipt has been issued yet for this commit. Go to the PP dashboard, find the request, and approve it. If the request isn't there, check that your `PP_TENANT_ID` is correct.

---

## What's Next

You're gated. Here's where to go from here:

- **[Full Deploy Gate docs](https://permissionprotocol.com/deploy-gate)** — advanced scoping, environment configuration, receipt expiry, and revocation
- **[Dashboard guide](https://app.permissionprotocol.com)** — managing approvers, setting up approval chains, viewing receipt history
- **Design partner support** — reply to your welcome email or ping us directly. You have a dedicated contact and we respond fast. No ticket queue.

We're actively shaping the product based on what design partners run into. If something feels off, confusing, or missing — tell us. That feedback is exactly why you're here.

*Thanks for being early. Let's build something worth trusting.*
