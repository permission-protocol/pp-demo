# Permission Protocol - Comprehensive Product Status

**Date:** February 12, 2026  
**Deployment:** https://company-os-web.onrender.com  
**Repository:** github.com/Roca-Ventures/Breakout-Labs

---

## Executive Summary

Permission Protocol (PP) is a **trust-gated autonomy system** where AI agents operate with broad visibility but narrow, gated authority. Every consequential action requires a cryptographically signed receipt proving authorization.

**Core thesis:** No receipt = unauthorized autonomy.

---

## 1. Core Architecture

### 1.1 Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Next.js 14 (App Router) |
| Database | PostgreSQL (Render) |
| ORM | Prisma |
| Auth | NextAuth.js (GitHub OAuth) |
| Signing | Ed25519 (native crypto) |
| Deployment | Render |

### 1.2 Multi-Tenancy Model

```
Company (tenant root)
├── Members (owner/admin/member roles)
├── API Keys (pp_live_xxx / pp_test_xxx)
├── Signing Keys (Ed25519 keypairs)
├── Receipts (signed authorization proofs)
├── Approvals (human-in-the-loop gates)
├── Deploy Gate Requests (CI/CD lifecycle)
├── Kill Switch State (emergency controls)
├── Policies (rule packs)
└── Alerts (anomaly notifications)
```

### 1.3 Data Models (48 Prisma models)

**Core Models:**
- `User`, `Account`, `Session` - NextAuth identity
- `Company`, `CompanyMember` - Multi-tenant isolation
- `ApiKey` - Scoped API authentication
- `PermissionReceipt` - Signed authorization proofs
- `PermissionSigningKey` - Ed25519 key management
- `PermissionApproval` - Human approval workflow
- `DeployGateRequest` - CI/CD deploy lifecycle
- `PolicySnapshotV1` - Policy versioning
- `PermissionAlert` - Anomaly detection

**Kill Switch Models:**
- `PermissionKillSwitchState` - Global freeze state
- `PermissionPausedAgent` - Per-agent pause
- `PermissionPausedCapability` - Per-capability pause
- `PermissionKillSwitchReceipt` - Kill switch audit

**Connector Models:**
- `PermissionConnectorAccount` - External service accounts
- `PermissionConnectorSecret` - Encrypted credentials
- `PermissionCapabilityGrant` - Scoped capability grants

---

## 2. API Surface

### 2.1 Public APIs (`/api/v1/`)

| Endpoint | Methods | Auth | Status | Purpose |
|----------|---------|------|--------|---------|
| `/receipts/verify` | POST | X-PP-API-Key | ✅ Live | CI/CD receipt verification |
| `/deploy-requests` | GET, POST | Session/CLI/API-Key | ✅ Live | Deploy gate lifecycle |
| `/deploy-requests/[id]` | GET | Session/CLI/API-Key | ✅ Live | Get request details |
| `/deploy-requests/[id]/approve` | POST | Session/CLI/API-Key | ✅ Live | Approve deploy |
| `/deploy-requests/[id]/deny` | POST | Session/CLI/API-Key | ✅ Live | Deny deploy |
| `/approvals` | GET | Session/CLI/API-Key | ✅ Live | List pending approvals |
| `/approvals/[id]` | GET | Session/CLI/API-Key | ✅ Live | Get approval details |
| `/approvals/[id]/approve` | POST | Session/CLI/API-Key | ✅ Live | Approve request |
| `/approvals/[id]/deny` | POST | Session/CLI/API-Key | ✅ Live | Deny request |
| `/execute` | POST | Bearer + X-Tenant-Id | ✅ Live | Agent tool execution gate |
| `/keys/current` | GET | Public | ✅ Live | Get current signing key |
| `/keys/[keyId]` | GET | Public | ✅ Live | Get specific key |
| `/kill/global/freeze` | POST | Session (Owner) | ✅ Live | Global emergency freeze |
| `/kill/global/unfreeze` | POST | Session (Owner) | ✅ Live | Unfreeze system |
| `/kill/agent/[id]/pause` | POST | Session (Owner/Admin) | ✅ Live | Pause specific agent |
| `/kill/agent/[id]/resume` | POST | Session (Owner/Admin) | ✅ Live | Resume agent |
| `/kill/capability/[cap]/pause` | POST | Session (Owner/Admin) | ✅ Live | Pause capability |
| `/kill/capability/[cap]/resume` | POST | Session (Owner/Admin) | ✅ Live | Resume capability |
| `/kill/status` | GET | Session | ✅ Live | Get kill switch status |
| `/policy/packs` | GET, POST | Session | ✅ Live | Policy pack management |
| `/policy/history` | GET | Session | ✅ Live | Policy version history |
| `/policy/rollback` | POST | Session (Owner) | ✅ Live | Rollback to previous policy |
| `/policy/activate-pack` | POST | Session | ✅ Live | Activate policy pack |
| `/alerts` | GET, POST | Session | ✅ Live | Alert management |
| `/alerts/[id]` | GET, PATCH | Session | ✅ Live | Alert details/acknowledge |
| `/exports/receipts` | GET | Session | ✅ Live | Export receipts (CSV/JSON) |
| `/exports/policies` | GET | Session | ✅ Live | Export policies |
| `/exports/alerts` | GET | Session | ✅ Live | Export alerts |
| `/exports/approvals` | GET | Session | ✅ Live | Export approvals |
| `/connectors/accounts` | GET, POST | Session | ✅ Live | Connector account management |
| `/connectors/accounts/[id]/secrets` | GET, POST | Session | ✅ Live | Secret management |
| `/connectors/grants` | GET, POST | Session | ✅ Live | Capability grants |
| `/setup/status` | GET | Session | ✅ Live | Onboarding status |
| `/setup/verify` | POST | Session | ✅ Live | Verify setup step |
| `/digest` | GET | Session | ✅ Live | Daily digest data |

### 2.2 Authentication Methods

| Method | Header | Format | Scopes |
|--------|--------|--------|--------|
| **Session** | Cookie | NextAuth session | Full access per role |
| **CLI Auth** | Authorization | `Basic base64(tenantId:CLI_API_KEY)` + X-Tenant-Id | Whitelisted routes |
| **API Key** | X-PP-API-Key | `pp_live_xxx` or `pp_test_xxx` | Per-key scopes |
| **Execute Key** | Authorization | `Bearer EXECUTE_API_KEY` + X-Tenant-Id | /execute only |

### 2.3 API Key Scopes

| Scope | Grants |
|-------|--------|
| `receipts:verify` | Verify receipts via /api/v1/receipts/verify |
| `deploy-gate:read` | Read deploy-requests |
| `deploy-gate:write` | Approve/deny deploy-requests |
| `approvals:read` | Read approvals |
| `approvals:write` | Approve/deny approvals |
| `*` | Full access (all scopes) |

---

## 3. UI Pages

### 3.1 Permission Protocol UI (`/pp/*`)

| Page | Path | Status | Purpose |
|------|------|--------|---------|
| Dashboard | `/pp` | ✅ Live | Main PP control plane |
| Deploy Requests | `/pp/deploy-requests` | ✅ Live | Deploy gate request list |
| Request Detail | `/pp/deploy-requests/[id]` | ✅ Live | Approve/deny UI |
| Setup Wizard | `/pp/setup` | ✅ Live | Onboarding flow |

### 3.2 Company OS UI

| Page | Path | Status | Purpose |
|------|------|--------|---------|
| Tasks | `/tasks` | ✅ Live | Task board |
| Approvals | `/approvals` | ✅ Live | Approval inbox |
| Constitution | `/constitution` | ✅ Live | Rules editor |
| CEO | `/ceo` | ✅ Live | AI CEO planning |
| Activity | `/activity` | ✅ Live | Activity feed |
| PR Outbox | `/pr-outbox` | ✅ Live | Pending PRs |
| Artifacts | `/artifacts` | ✅ Live | Generated artifacts |
| GitHub | `/github` | ✅ Live | GitHub integration |
| Governance | `/governance` | 🔨 Partial | Governance dashboard |
| Audit | `/audit` | 🔨 Partial | Audit log viewer |
| Knowledge | `/knowledge` | ✅ Live | Knowledge base |
| Dev AI | `/dev-ai` | ✅ Live | AI dev patches |
| Settings | `/settings/*` | ✅ Live | LLM, Slack, accounts |
| Auth | `/auth/*` | ✅ Live | Sign in/error |
| Companies | `/companies` | ✅ Live | Company selector |
| Onboarding | `/onboarding` | ✅ Live | New user onboarding |
| Account | `/account` | ✅ Live | User account |

### 3.3 Missing UI Pages

| Page | Purpose | Priority |
|------|---------|----------|
| API Keys Management | Create/revoke API keys | High |
| Receipts Browser | View/search receipts | Medium |
| Kill Switch Dashboard | Visual kill switch controls | Medium |
| Policy Editor | Visual policy rule builder | Low |

---

## 4. Receipt System

### 4.1 Receipt Lifecycle

```
1. Agent requests permission → /api/v1/execute
2. Policy evaluated → ALLOW/DENY/ESCALATE
3. If ALLOW: Receipt signed with Ed25519
4. Receipt returned with signature
5. Agent presents receipt to external system
6. External system verifies via /api/v1/receipts/verify
7. Receipt optionally redeemed (one-time use)
```

### 4.2 Receipt Structure

```json
{
  "id": "rcpt_xxx",
  "companyId": "company_xxx",
  "idemKey": "unique-idempotency-key",
  "agentId": "agent-identifier",
  "status": "APPROVED",
  "inputHash": "sha256-of-request",
  "requestJson": "{...original request...}",
  "policyVersion": "policy_v1_xxx",
  "reasonCodes": ["RULE_MATCHED", "AUTO_APPROVED"],
  "summary": "Human-readable decision summary",
  "signature": {
    "receiptVersion": "1.0",
    "canonicalization": "JCS",
    "signatureAlg": "Ed25519",
    "signatureKeyId": "key_xxx",
    "signatureValue": "base64-signature"
  },
  "expiresAt": "2026-02-12T12:00:00Z",
  "redeemedAt": null,
  "redeemedBy": null,
  "createdAt": "2026-02-12T10:00:00Z"
}
```

### 4.3 Verification Flow

```
POST /api/v1/receipts/verify
{
  "scope": {
    "repo": "owner/repo",
    "ref": "refs/heads/main",
    "commit": "abc123",
    "workflow": "deploy.yml",
    "env": "production",
    "capability": "deploy:production"
  },
  "redeem": true,
  "redeemRunId": "github-run-123",
  "redeemBy": "github-actions"
}

Response:
{
  "success": true,
  "valid": true,
  "result": {
    "receiptId": "rcpt_xxx",
    "decision": "APPROVED",
    "signatureValid": true,
    "redeemed": true
  }
}
```

---

## 5. Deploy Gate (CI/CD Integration)

### 5.1 Flow

```
1. CI workflow calls /api/v1/receipts/verify
2. If no receipt exists, PP creates DeployGateRequest
3. DeployGateRequest shown in /pp/deploy-requests UI
4. Human approves/denies via UI or Telegram
5. On approve: Receipt created and signed
6. CI re-verifies, receipt found, deploy proceeds
```

### 5.2 GitHub Actions Integration

```yaml
- name: Verify Permission
  uses: ./.github/actions/verify
  with:
    pp_base_url: ${{ secrets.PP_BASE_URL }}
    pp_api_key: ${{ secrets.PP_API_KEY }}
    environment: production
    capability: deploy:production
    fail_on_missing: 'true'
    redeem: 'true'
    commit_sha: ${{ github.event.pull_request.head.sha }}
```

### 5.3 Request States

| State | Description |
|-------|-------------|
| `pending` | Awaiting human decision |
| `approved` | Approved, receipt created |
| `denied` | Rejected by human |
| `expired` | TTL exceeded without decision |

---

## 6. Kill Switch System

### 6.1 Capabilities

| Kill Switch | Scope | Effect |
|-------------|-------|--------|
| **Global Freeze** | All agents | All executions blocked |
| **Agent Pause** | Single agent | Specific agent blocked |
| **Capability Pause** | Single capability | Specific action blocked |

### 6.2 API

```bash
# Global freeze
POST /api/v1/kill/global/freeze
{"reason": "Security incident"}

# Pause agent
POST /api/v1/kill/agent/agent-123/pause
{"reason": "Misbehaving"}

# Pause capability
POST /api/v1/kill/capability/deploy:production/pause
{"reason": "Deployment window closed"}
```

---

## 7. Policy System

### 7.1 Policy Packs

Pre-built policy templates that can be activated:

- **Minimal** - Most permissive, minimal checks
- **Standard** - Balanced security/autonomy
- **Strict** - High security, more escalations
- **Custom** - User-defined rules

### 7.2 Policy Rules

```json
{
  "name": "require-approval-for-prod-deploy",
  "actionClass": "deploy:production",
  "condition": "always",
  "decision": "ESCALATE",
  "approverRole": "owner",
  "enabled": true
}
```

---

## 8. Security Posture

### 8.1 Implemented Security Controls

| Control | Status | Notes |
|---------|--------|-------|
| Multi-tenant isolation | ✅ | Belt+suspenders: always WHERE companyId |
| Ed25519 receipt signing | ✅ | Cryptographic proof of authorization |
| API key scoping | ✅ | Least-privilege per key |
| Rate limiting | ✅ | Per-IP and per-key limits |
| Unsigned receipt rejection | ✅ | ALLOW without signature = DENY |
| Session auth | ✅ | NextAuth with secure cookies |
| CLI auth whitelist | ✅ | Only specific routes allowed |
| CSRF protection | ✅ | Via NextAuth |
| Input validation | ✅ | Zod schemas throughout |
| Audit logging | ✅ | AuditEvent model |

### 8.2 Security Documentation

- `docs/security/tenant-invariants.md` - Multi-tenant rules
- `docs/security/route-scope-checklist.md` - API security checklist
- `docs/security/route-blocking.md` - Blocked routes
- `SECURITY.md` - Security policy
- `THREAT_MODEL.md` - Threat analysis

### 8.3 Test Coverage

| Test File | Coverage |
|-----------|----------|
| `verify-auth.test.ts` | Receipt verification auth |
| `deploy-gate-verify-request.test.ts` | Deploy gate lifecycle |
| `cross-company-access.test.ts` | Tenant isolation |
| `golden-vectors.test.ts` | Cryptographic vectors |
| `internal-routes.test.ts` | Internal API security |

---

## 9. External Integrations

### 9.1 Current Integrations

| Integration | Status | Purpose |
|-------------|--------|---------|
| GitHub OAuth | ✅ Live | Authentication |
| GitHub API | ✅ Live | Repo indexing, PR creation |
| GitHub Actions | ✅ Live | Deploy gate CI/CD |
| Slack | ✅ Live | Notifications |
| OpenClaw (Telegram) | 🔨 In Progress | Founder approval via Telegram |

### 9.2 Pending Integrations

| Integration | Priority | Notes |
|-------------|----------|-------|
| OpenAI/Anthropic LLM | ✅ Via LLMCredential | AI CEO planning |
| Stripe | Planned | Billing |
| Linear | Planned | Issue sync |

---

## 10. Current Work Items

### 10.1 In Progress (PR #30)

- X-PP-API-Key auth for deploy-requests endpoints
- PR head SHA fix for verify action (scope mismatch fix)

### 10.2 Blocking Issues

| Issue | Status | Blocker |
|-------|--------|---------|
| OpenClaw Telegram plugin | Blocked | Waiting for PR #30 merge + API key |
| CI verify workflow | Blocked | Needs receipts:verify scoped key |

### 10.3 Backlog (High Priority)

1. **API Keys UI** - Create/revoke keys from dashboard
2. **Receipts Browser** - Search and view receipts
3. **Webhook notifications** - Push events to external systems

---

## 11. Operational Notes

### 11.1 Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `DATABASE_URL` | Yes | PostgreSQL connection |
| `NEXTAUTH_SECRET` | Yes | Session encryption |
| `NEXTAUTH_URL` | Yes | Callback URL |
| `GITHUB_CLIENT_ID` | Yes | GitHub OAuth |
| `GITHUB_CLIENT_SECRET` | Yes | GitHub OAuth |
| `PP_SIGNING_PRIVATE_KEY` | Yes | Ed25519 signing key |
| `PP_GLOBAL_COMPANY_ID` | No | Default tenant (default: "global") |
| `CLI_API_KEY` | No | CLI auth key |
| `EXECUTE_API_KEY` | No | Execute endpoint key |

### 11.2 Render Deployment

- Auto-deploy from `main` branch
- PostgreSQL managed database
- Web service with health check at `/api/health`

---

## 12. Documentation Index

| Document | Path | Purpose |
|----------|------|---------|
| Quickstart | `docs/QUICKSTART.md` | 10-minute setup guide |
| Platform Overview | `docs/PLATFORM_OVERVIEW.md` | Architecture deep-dive |
| Receipt Standard | `docs/receipt-standard.md` | Receipt format spec |
| Receipt Signing | `docs/receipt-signing.md` | Cryptographic details |
| Deploy Gate Guide | `docs/deploy-gate-github-actions.md` | CI/CD integration |
| Playbooks | `docs/playbooks/` | Integration examples |
| Security | `docs/security/` | Security documentation |

---

*Generated: 2026-02-12 13:17 MST*
