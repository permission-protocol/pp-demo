# Permission Protocol: GitHub Actions Enforcement Contract

## Definitions

**Production** = any environment that serves real users or writes to real customer data.

**External** = outside the agent runtime and not alterable by the agent.

---

## Overview

A GitHub Action that blocks production deploys unless a valid Permission Protocol receipt exists.

**Axiom:** No receipt, no deploy. Receipts are the only currency of authorization.

**Core behavior:**
```
No receipt → deploy fails
Invalid receipt → deploy fails  
Valid receipt → deploy proceeds
```

---

## Action Interface

### Usage

```yaml
- name: Verify Permission Protocol Receipt
  uses: permission-protocol/verify@v1
  with:
    # Required
    commit: ${{ github.sha }}
    environment: production
    
    # Scope binding (optional, defaults to current context)
    repo: ${{ github.repository }}
    workflow: ${{ github.workflow }}
    ref: ${{ github.ref }}
    run_id: ${{ github.run_id }}
    artifact_digest: sha256:...  # for image/artifact deploys
    
    # Redemption mode
    redeem_mode: run  # "run" (single-use per run_id) or "commit" (one per commit+env)
    
    # Behavior
    fail_on_missing: true  # default: true
    fail_on_expired: true  # default: true
    fail_on_unavailable: true  # default: true (fail closed)
  env:
    PP_TOKEN: ${{ secrets.PP_TOKEN }}  # NEVER pass as input, always via env
```

**Security note:** Never pass tokens as `with:` inputs — they can leak through logs or third-party actions. Always use `env:`.

### Outputs

```yaml
outputs:
  receipt_id:
    description: 'The receipt ID if valid'
  decision:
    description: 'ALLOW | DENY | ESCALATE'
  approver:
    description: 'Who approved (email or policy name)'
  approved_at:
    description: 'ISO timestamp of approval'
  valid:
    description: 'true | false'
  error:
    description: 'Error message if validation failed'
```

---

## Receipt Schema (v1)

```json
{
  "$schema": "https://permission.protocol/receipt.v1.schema.json",
  "receipt_id": "pp_rec_<ulid>",
  "receipt_version": "1",
  "canonicalization": "JCS",
  "decision": "ALLOW | DENY | ESCALATE",
  
  "scope": {
    "action": "deploy",
    "repo": "owner/repo",
    "commit": "<full_sha>",
    "environment": "production | staging | preview",
    "workflow": "deploy.yml",
    "ref": "refs/heads/main",
    "run_id": "123456789 (optional, for redemption checks)",
    "artifact_digest": "sha256:<digest> (optional, for image/artifact deploys)"
  },
  
  "approver": {
    "type": "human | policy | escalation",
    "identity": "alice@example.com | policy:auto-approve-staging",
    "method": "web | cli | api | slack"
  },
  
  "context": {
    "request_id": "pp_req_<ulid>",
    "requested_by": "agent:cursor | human:bob@example.com",
    "requested_at": "2026-02-09T14:55:00Z",
    "reason": "Deploy feature X to production"
  },
  
  "validity": {
    "issued_at": "2026-02-09T15:00:00Z",
    "expires_at": "2026-02-09T16:00:00Z",
    "single_use": true
  },
  
  "signature": {
    "algorithm": "ed25519",
    "key_id": "pp_key_<id>",
    "value": "<base64_signature>"
  }
}
```

### Required Fields (v1 Minimum)

Receipts bind to **immutable artifacts**: commit hash, workflow, and artifact/image digest when applicable.

```json
{
  "receipt_id": "pp_rec_abc123",
  "receipt_version": "1",
  "canonicalization": "JCS",
  "decision": "ALLOW",
  "scope": {
    "action": "deploy",
    "repo": "acme/webapp",
    "commit": "a1b2c3d4e5f6...",
    "environment": "production",
    "workflow": "deploy.yml",
    "ref": "refs/heads/main",
    "artifact_digest": "sha256:e3b0c442..."
  },
  "redemption": {
    "mode": "run",
    "redeemed_runs": []
  },
  "approver": {
    "type": "human",
    "identity": "alice@acme.com"
  },
  "validity": {
    "issued_at": "2026-02-09T15:00:00Z",
    "expires_at": "2026-02-09T16:00:00Z"
  },
  "signature": {
    "algorithm": "ed25519",
    "key_id": "pp_key_prod",
    "value": "..."
  }
}
```

---

## Verification Logic

```
VERIFY(receipt, commit, environment):
  
  1. PARSE receipt JSON
     → fail if malformed
  
  2. CHECK receipt.decision == "ALLOW"
     → fail if DENY or ESCALATE
  
  3. CHECK receipt.scope.commit == commit
     → fail if mismatch (exact match required)
  
  4. CHECK receipt.scope.environment == environment
     → fail if mismatch
  
  5. CHECK receipt.validity.expires_at > now()
     → fail if expired
  
  6. CHECK receipt.validity.issued_at < now()
     → fail if issued in future (clock skew tolerance: 60s)
  
  7. VERIFY_SIGNATURE(receipt, receipt.signature)
     → fail if signature invalid
     → signature covers: receipt_id + decision + scope + approver + validity
  
  8. IF receipt.validity.single_use:
     CHECK_NOT_REDEEMED(receipt.receipt_id)
     MARK_REDEEMED(receipt.receipt_id)
     → fail if already used
  
  RETURN valid: true, receipt_id, approver
```

---

## Failure Modes

| Failure | Exit Code | Message |
|---------|-----------|---------|
| No receipt found | 1 | `PP_NO_RECEIPT: No Permission Protocol receipt found for commit {sha}` |
| Receipt expired | 1 | `PP_EXPIRED: Receipt {id} expired at {time}` |
| Scope mismatch | 1 | `PP_SCOPE_MISMATCH: Receipt covers {receipt_scope}, not {actual_scope}` |
| Invalid signature | 1 | `PP_INVALID_SIGNATURE: Receipt signature verification failed` |
| Decision not ALLOW | 1 | `PP_DENIED: Receipt decision is {decision}, not ALLOW` |
| Already redeemed | 1 | `PP_REDEEMED: Receipt {id} has already been used for run {run_id}` |
| PP unavailable | 1 | `PP_UNAVAILABLE: Permission Protocol service unreachable` |

**All failures block the deploy.** No soft failures in v1.

**Fail-closed rule:** If `environment == production`, PP unavailability MUST fail the deploy. No exceptions. This prevents "oops, PP was down so we shipped anyway" incidents.

---

## Example Workflows

### Basic: Block Unapproved Deploys

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Verify Permission Protocol Receipt
        uses: permission-protocol/verify@v1
        with:
          commit: ${{ github.sha }}
          environment: production
        env:
          PP_TOKEN: ${{ secrets.PP_TOKEN }}
      
      # This only runs if receipt is valid
      - name: Deploy
        run: ./deploy.sh
```

### With Approval Request on Failure

**Important:** This pattern requests approval but STILL BLOCKS the deploy until a valid receipt exists. The deploy job only runs if `approved == 'true'`.

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  check-approval:
    runs-on: ubuntu-latest
    outputs:
      approved: ${{ steps.verify.outputs.valid }}
    
    steps:
      - name: Verify Permission Protocol Receipt
        id: verify
        uses: permission-protocol/verify@v1
        with:
          commit: ${{ github.sha }}
          environment: production
          fail_on_missing: false  # Check only, don't fail yet
        env:
          PP_TOKEN: ${{ secrets.PP_TOKEN }}
      
      - name: Request Approval if Missing
        if: steps.verify.outputs.valid != 'true'
        uses: permission-protocol/request@v1
        with:
          commit: ${{ github.sha }}
          environment: production
          reason: "Deploy triggered by push to main"
          notify: "slack:#deploy-approvals"
        env:
          PP_TOKEN: ${{ secrets.PP_TOKEN }}
      
      # This job ends here. Deploy job is gated below.
  
  deploy:
    needs: check-approval
    # CRITICAL: Deploy ONLY runs if receipt was valid
    if: needs.check-approval.outputs.approved == 'true'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      # Belt and suspenders: verify again before deploy
      - name: Re-verify Receipt
        uses: permission-protocol/verify@v1
        with:
          commit: ${{ github.sha }}
          environment: production
        env:
          PP_TOKEN: ${{ secrets.PP_TOKEN }}
      
      - name: Deploy
        run: ./deploy.sh
```

**Result if no receipt:** Check job completes, request sent to Slack, deploy job is SKIPPED. Human must approve, then re-run workflow.

### Agent-Initiated Deploy (Full Flow)

```yaml
name: Agent Deploy Request

on:
  workflow_dispatch:
    inputs:
      commit:
        description: 'Commit to deploy'
        required: true
      reason:
        description: 'Why this deploy?'
        required: true

jobs:
  request-and-wait:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Request Permission Protocol Approval
        id: request
        uses: permission-protocol/request@v1
        with:
          commit: ${{ inputs.commit }}
          environment: production
          reason: ${{ inputs.reason }}
          requested_by: "agent:${{ github.actor }}"
          wait: true  # Block until approved/denied
          timeout: 3600  # 1 hour
        env:
          PP_TOKEN: ${{ secrets.PP_TOKEN }}
      
      - name: Check Decision
        if: steps.request.outputs.decision != 'ALLOW'
        run: |
          echo "Deploy denied or timed out"
          exit 1
      
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.commit }}
      
      - name: Verify Receipt (belt and suspenders)
        uses: permission-protocol/verify@v1
        with:
          commit: ${{ inputs.commit }}
          environment: production
        env:
          PP_TOKEN: ${{ secrets.PP_TOKEN }}
      
      - name: Deploy
        run: ./deploy.sh
```

---

## Receipt Lookup (Push Model)

v1 uses a **push model** for receipts:

1. **Request** action creates a pending approval server-side
2. Human approves via web/Slack/CLI
3. **Approval creates receipt server-side**, keyed by `{repo, commit, environment}`
4. **Verify** action calls `POST /v1/receipts/verify` with `redeem=true`

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Request   │────▶│  PP Server   │◀────│   Verify    │
│   Action    │     │  (stores     │     │   Action    │
└─────────────┘     │   receipts)  │     └─────────────┘
                    └──────────────┘
                           ▲
                           │
                    ┌──────────────┐
                    │    Human     │
                    │   Approval   │
                    │ (web/slack/  │
                    │     cli)     │
                    └──────────────┘
```

**Why push model:**
- No receipt artifacts to manage in workflows
- Single source of truth
- Verify action is stateless (just queries)
- Audit trail lives server-side

---

## Atomic Verify + Redeem (Critical)

**Race condition risk:** Two concurrent jobs can verify the same receipt and both deploy if redemption is not atomic.

**Solution:** Verification endpoint MUST support atomic verify+redeem:

```
POST /v1/receipts/verify
{
  "repo": "acme/webapp",
  "commit": "a1b2c3d4...",
  "environment": "production",
  "workflow": "deploy.yml",
  "run_id": "123456789",
  "artifact_digest": "sha256:...",
  "redeem": true
}
```

**Server performs atomically:**
1. Lookup receipt by scope
2. Validate signature
3. Check not expired
4. Check not already redeemed for this `run_id` (if `redeem_mode: run`)
5. **Mark redeemed** (within same transaction)
6. Return receipt

If any step fails, the entire operation fails. No partial states.

**Without atomic redeem, "single_use" is theater.**

---

## Approval Surfaces (v1)

How humans approve requests:

| Surface | Flow |
|---------|------|
| **Web** | Link in notification → approve/deny button |
| **Slack** | Interactive message with approve/deny buttons |
| **CLI** | `pp approve <request_id>` |
| **API** | `POST /v1/requests/{id}/approve` |

All surfaces produce the same receipt. The approval method is recorded in `approver.method`.

---

## Key Constraints

1. **Receipts are commit-specific** — A receipt for commit `abc123` is not valid for `def456`
2. **Receipts are environment-specific** — A staging receipt is not valid for production
3. **Receipts bind to workflow** — Prevents "use receipt from another pipeline"
4. **Single-use per run** — One receipt can only be redeemed once per `run_id` (allows re-runs)
5. **Expiry required** — No indefinite approvals (1 hour default, configurable)
6. **Signature required** — All receipts must be signed by PP
7. **Artifact digest binding** — See below

---

## Artifact Identity Binding (Critical)

**Problem:** Commit SHA is not always the deployed artifact.
- Monorepos build multiple images per commit
- Builds can be re-run producing different artifacts
- Deploy may use image digest, not commit

**Rules:**

| Deploy Type | Required Binding |
|-------------|------------------|
| Container deploy | `artifact_digest` (image digest) — **required** |
| Non-container deploy | `artifact_digest` (zip/tar hash) or build provenance — **recommended** |
| Source deploy (rare) | Commit SHA sufficient |

**Enforcement:**

If `artifact_digest` is present in the receipt scope:
- Verification MUST require it to match the actual build output
- Mismatch = `PP_SCOPE_MISMATCH` failure

```yaml
- name: Verify PP Receipt
  uses: permission-protocol/verify@v1
  with:
    commit: ${{ github.sha }}
    environment: production
    artifact_digest: ${{ steps.build.outputs.digest }}  # From docker build
  env:
    PP_TOKEN: ${{ secrets.PP_TOKEN }}
```

**This prevents "approved commit, shipped different artifact."**

---

## Signature Specification

**What is signed:**

`signature.value` = Ed25519 signature over SHA-256 hash of the canonicalized receipt body, excluding the `signature` field.

**Canonicalization:** JCS (JSON Canonicalization Scheme, RFC 8785) — deterministic, no field order ambiguity.

```
canonical_body = JCS(receipt, excluding "signature")
hash = SHA-256(canonical_body)
signature = Ed25519_Sign(hash, pp_private_key)
```

**Verification:**
```
canonical_body = JCS(receipt, excluding "signature")
hash = SHA-256(canonical_body)
valid = Ed25519_Verify(hash, receipt.signature.value, pp_public_key[receipt.signature.key_id])
```

**Key discovery:** Public keys are discoverable via `GET /v1/keys/{key_id}`

**Version stability:** `receipt_version` + `canonicalization` fields ensure old receipts remain verifiable after upgrades. Never change canonicalization rules for a given version.

---

## Minimum API Endpoints (Ship List)

**Required for v1:**

| Endpoint | Purpose |
|----------|---------|
| `POST /v1/receipts/verify` | Atomic verify + redeem |
| `GET /v1/keys/{key_id}` | Public key discovery for signature verification |

**Optional for primitive issuance loop:**

| Endpoint | Purpose |
|----------|---------|
| `POST /v1/requests` | Create approval request |
| `POST /v1/requests/{id}/approve` | Human approves → creates receipt |
| `GET /v1/requests/{id}` | Poll request status |

**That's it.** No dashboards. No policies. No RBAC. Ship.

---

## Self-Hosted Option (Later)

For orgs that can't use hosted PP:

```yaml
- name: Verify Permission Protocol Receipt
  uses: permission-protocol/verify@v1
  with:
    commit: ${{ github.sha }}
    environment: production
    mode: self-hosted
    receipt_path: .pp/receipts/${{ github.sha }}.json
    public_key_path: .pp/keys/verify.pub
```

This is v1.1+ — hosted-first reduces friction.

---

## What This Doesn't Do (v1)

- ❌ Manage policies or RBAC
- ❌ Integrate with SSO/identity providers
- ❌ Provide audit dashboards
- ❌ Handle non-deploy actions

**v1 focuses on enforcement + verification; approval UX can be primitive (CLI/web).** The smallest possible system that actually works.

---

*Permission Protocol GitHub Actions Contract — February 2026*
