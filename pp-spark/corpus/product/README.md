<p align="center">
  <img src="https://permissionprotocol.com/assets/logo-dark.png" alt="Permission Protocol" width="200">
</p>

<h1 align="center">Permission Protocol</h1>

<p align="center">
  <strong>No receipt = no deploy. Fail-closed enforcement for AI-driven production changes.</strong>
</p>

<p align="center">
  <a href="https://permissionprotocol.com">Website</a> · <a href="https://permissionprotocol.com/install">Install Guide</a> · <a href="https://app.permissionprotocol.com">Dashboard</a> · <a href="docs/QUICKSTART.md">Quickstart</a>
</p>

---

## 🏆 The Challenge: Can You Deploy Without Permission?

[![Challenge](https://img.shields.io/badge/Challenge-Undefeated-red?style=for-the-badge&logo=github)](./CHALLENGE.md)

**Think you can bypass our deploy gates?** Try to merge code to this repository without generating a cryptographically signed receipt. 

**Success rate so far:** `0%` _(0 out of 0 attempts)_

[**→ Accept the Challenge**](https://github.com/Roca-Ventures/Breakout-Labs/fork) | [**→ Read the Rules**](./docs/receipt-challenge.md)

---

## The Problem

AI agents are shipping code to production. But who approved it? Internal logs aren't proof — they're self-reported. If your AI can deploy without an explicit human signer, you have **unauthorized autonomy** running in production.

## The Solution

Permission Protocol adds a **signer of record** to every production change. A cryptographically signed receipt proves a human authorized the action — before it happens, not after.

```
PR merged → CI runs → ⛔ Deploy Gate checks for receipt → ✅ Receipt valid → Deploy proceeds
                                                        → ❌ No receipt → Deploy blocked
```

**This is fail-closed.** The default state is denial.

---

## Install in 3 Steps

### 1. Add secrets to your repo

Go to **Settings → Secrets → Actions** and add:

| Secret | Value |
|--------|-------|
| `PP_API_KEY` | Your API key from the [PP dashboard](https://app.permissionprotocol.com) |
| `PP_TENANT_ID` | Your tenant ID from the dashboard |

### 2. Add the workflow file

Create `.github/workflows/deploy-gate.yml`:

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
        uses: permission-protocol/verify-action@v1
        with:
          api-key: ${{ secrets.PP_API_KEY }}
          tenant-id: ${{ secrets.PP_TENANT_ID }}
          scope: |
            {
              "scopeType": "GIT_REF_COMMIT",
              "ref": "${{ github.sha }}",
              "repo": "${{ github.repository }}",
              "environment": "production"
            }
```

### 3. Require the check

In **Settings → Branches → Branch protection rules** for `main`:

- ☑ Require status checks to pass → add **deploy-gate**
- ☑ Do not allow bypassing the above settings

**Done.** Every PR now requires a valid authorization receipt before merging.

---

## How It Works

1. **Developer opens PR** — Deploy Gate check appears as pending
2. **Authorized signer creates deploy request** in the PP dashboard
3. **Receipt is issued** — cryptographically signed, scoped to this exact commit + repo + environment
4. **Deploy Gate verifies the receipt** — check turns green, PR can merge
5. **Full audit trail** — who signed, when, for what, with what scope

No receipt exists → check stays red → PR stays blocked → nothing reaches production.

## What a Receipt Proves

| Field | Guarantees |
|-------|-----------|
| **Signer** | A specific human authorized this action |
| **Scope** | Authorization covers this exact commit, repo, and environment |
| **Signature** | Receipt is cryptographically signed and tamper-evident |
| **Timestamp** | Authorization was granted within the validity window |
| **Audit** | Immutable record exists for compliance and forensics |

---

## Documentation

| Doc | Description |
|-----|-------------|
| [Quickstart Guide](docs/QUICKSTART.md) | Zero to running in 10 minutes |
| [Receipt Standard](docs/receipt-standard.md) | How receipts work |
| [Deploy Gate Details](https://permissionprotocol.com/deploy-gate) | Full Deploy Gate docs |
| [Architecture](https://permissionprotocol.com/architecture) | System architecture |
| [Threat Model](docs/THREAT_MODEL.md) | Security boundaries |
| [Integration Playbooks](docs/playbooks/) | Tool-calling, LangGraph, CI/CD |

## Self-Hosted / Development

<details>
<summary>Click to expand development setup</summary>

```bash
# Clone and install
git clone https://github.com/Roca-Ventures/Breakout-Labs
cd Breakout-Labs
npm install

# Set up database
cp .env.example .env
npm run db:generate
npm run db:migrate
npm run db:seed

# Start dev server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

See [Environment Setup](docs/ENVIRONMENT_SETUP.md) for full configuration options including LLM providers, GitHub connectors, and Slack notifications.

</details>

## Security

Permission Protocol is security-critical infrastructure.

- **[Security Policy](SECURITY.md)** — Vulnerability reporting and security practices
- **[Threat Model](docs/THREAT_MODEL.md)** — Trust boundaries and attack surface

Report vulnerabilities: security@permissionprotocol.com

## License

MIT

---

<p align="center">
  <em>No AI action without an explicit signer.</em>
</p>
