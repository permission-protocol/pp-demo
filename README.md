# Permission Protocol Demo

**No receipt → no merge.** Every PR requires human approval before it can land.

[See a blocked PR →](https://github.com/permission-protocol/pp-demo/pull/1)

---

## Install on your repo (3 steps)

### 1. Add the workflow

Create `.github/workflows/deploy-gate.yml`:

```yaml
name: Deploy Gate

on:
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write
  statuses: write

jobs:
  gate:
    name: Permission Protocol
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: permission-protocol/deploy-gate@v1
        with:
          pp-api-key: ${{ secrets.PP_API_KEY }}
          pp-request-create-token: ${{ secrets.PP_REQUEST_CREATE_TOKEN }}
```

### 2. Get your keys

Sign up at [app.permissionprotocol.com](https://app.permissionprotocol.com), create an API key with both scopes (`receipts.verify` + `deployRequests.create`).

### 3. Add secrets

In your repo → Settings → Secrets → Actions, add:

| Secret | Value |
|--------|-------|
| `PP_API_KEY` | Your API key (starts with `pp_live_`) |
| `PP_REQUEST_CREATE_TOKEN` | Same key works here too |

**Done.** Open a PR and watch it get blocked until you approve it.

---

## What happens

```
PR opened → Deploy Gate runs → ❌ Blocked (no receipt)
                                    ↓
                        Approval link in PR comment
                                    ↓
                        Human approves on PP
                                    ↓
                        Re-run gate → ✅ Approved
                                    ↓
                              Merge allowed
```

Every approval creates a cryptographic receipt. Signed. Timestamped. Auditable.

---

## What you get

- **AI summary** of every PR on the approval page
- **Risk signals** — which files changed and why it matters
- **One-click merge** — approve and merge without touching GitHub
- **Audit trail** — every approval is a signed receipt
- **Fail-open** — if PP is down, your CI isn't blocked (configurable)

---

## FAQ

**Does this block all PRs or just some?**
All PRs by default. Your team policy (auto-approve vs manual) is configured in the PP dashboard, not in YAML.

**What if Permission Protocol goes down?**
Fail-open mode (default 30s timeout). If PP can't be reached, the gate passes with a warning. Your deploys are never blocked by us being down.

**Does this work with Codex / Claude Code / Cursor?**
That's exactly why we built it. AI agents push code fast. This makes sure a human still says "yes" before it goes live.

---

<p align="center">
  <a href="https://permissionprotocol.com">permissionprotocol.com</a>
</p>
