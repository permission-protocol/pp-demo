# PRD: Permission Protocol GitHub App

## Problem
Users must manually: (1) create API keys, (2) add repo secrets, (3) copy a workflow file, (4) configure branch protection. Each step is a drop-off point. Key management is the #1 pain point from QA. The deploy-gate can't set commit statuses as a trusted GitHub integration, forcing workarounds. Self-approval is possible because the same key creates and approves.

## Solution
A GitHub App that handles repo connection, secret injection, commit status management, and PR lifecycle events. One-click "Connect Repo" from the PP dashboard.

## Design Principles
- **Additive, not replacing**: API key auth stays. App auth is a better path, not the only path.
- **Guide, don't force**: Show users what to do, offer to do it for them, but don't surprise-commit to their repos.
- **Fail gracefully**: If the App is uninstalled, fall back to API key auth. Never brick a user's deploy pipeline.

---

## User Flow

### 1. Connect Repo (Dashboard → GitHub → Dashboard)
```
User is logged into PP dashboard (authenticated session)
  → Clicks "Connect Repository"
  → Redirects to github.com/apps/permission-protocol/installations/new
  → User selects org + repos to grant access
  → GitHub redirects to app.permissionprotocol.com/api/github-app/callback
      with ?installation_id=<id>&setup_action=install
  → PP stores installation linked to user's current company (from session)
  → Fetches accessible repos from installation
  → Redirects to /pp/setup?connected=true
```

### 2. Setup Wizard (Post-Connection)
For each connected repo, the setup page shows three steps with status:

**Step 1: Workflow File** (required)
- Shows copy-paste `.github/workflows/pp-gate.yml` content
- "Auto-install" button: PP creates the file via Contents API (opt-in, creates a commit)
- Status: ✅ Detected / ⏳ Not found

**Step 2: API Key** (required for verify — auto-handled)
- PP auto-creates a scoped API key (`deployRequests.create` + `receipts.verify` only)
- Injects as repo secret `PP_API_KEY` via GitHub API
- Also injects `PP_BASE_URL` as repo variable
- Status: ✅ Injected / ❌ Failed (show manual instructions)

**Step 3: Branch Protection** (recommended, not required)
- Shows instructions for adding "Permission Protocol" required status check
- "Auto-configure" button: PP creates a ruleset via Rulesets API (opt-in)
- Uses App's integration_id so App-set statuses are trusted
- Status: ✅ Configured / ⚠️ Manual setup needed

### 3. Ongoing Operation
- **Gate runs** → deploy-gate action uses auto-injected `PP_API_KEY` secret (existing flow, unchanged)
- **Approval** → PP sets commit status using App's installation token (trusted integration source ✅)
- **Merge** → PP merges using App's installation token (replaces PAT)
- **PR closed/merged** → Webhook fires → PP auto-expires pending requests
- **PR reopened** → Webhook fires → PP can re-activate (future)

---

## GitHub App Configuration

### Identity
- **Name:** Permission Protocol
- **Slug:** permission-protocol (github.com/apps/permission-protocol)
- **Homepage:** https://permissionprotocol.com
- **Callback URL:** https://app.permissionprotocol.com/api/github-app/callback
- **Setup URL:** https://app.permissionprotocol.com/pp/setup (post-install redirect)
- **Webhook URL:** https://app.permissionprotocol.com/api/github-app/webhook
- **Webhook secret:** Stored in env var `GITHUB_APP_WEBHOOK_SECRET`

### Permissions (Repository)
| Permission | Access | Why |
|---|---|---|
| Contents | Read & Write | Auto-install workflow file, read PR diffs for enrichment |
| Pull requests | Read & Write | Read PR metadata, merge PRs, read PR state for reconciliation |
| Commit statuses | Read & Write | Set "Permission Protocol" status after approval |
| Metadata | Read | Required baseline for all GitHub Apps |
| Actions | Read | Check workflow run status for rerun |
| Administration | Read & Write | Create branch protection rulesets (opt-in auto-configure) |
| Secrets | Write | Inject PP_API_KEY as repo secret during setup |
| Variables | Write | Inject PP_BASE_URL as repo variable during setup |

### Webhook Events
| Event | Handler |
|---|---|
| `installation.created` | Store installation, fetch repo list, link to company |
| `installation.deleted` | Mark installation as removed, don't delete data |
| `installation.suspend` | Mark suspended, stop using installation token |
| `installation_repositories.added` | Add repos to installation |
| `installation_repositories.removed` | Mark repos as disconnected |
| `pull_request.closed` | Auto-expire pending deploy requests for this PR |
| `pull_request.reopened` | Log event (future: re-activate) |

---

## Data Model

### New Table: `GitHubAppInstallation`
```prisma
model GitHubAppInstallation {
  id                String   @id @default(cuid())
  companyId         String
  installationId    Int      @unique    // GitHub's installation ID
  accountLogin      String              // GitHub org/user login
  accountType       String              // "Organization" | "User"
  appId             Int
  status            String   @default("active") // active | suspended | removed
  permissions       Json?               // Granted permissions snapshot
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  company           Company  @relation(fields: [companyId], references: [id])
  repos             GitHubAppRepo[]
}
```

### New Table: `GitHubAppRepo`
```prisma
model GitHubAppRepo {
  id                String   @id @default(cuid())
  installationId    String
  repoFullName      String              // "owner/repo"
  repoId            Int                 // GitHub repo numeric ID
  status            String   @default("connected") // connected | disconnected
  workflowInstalled Boolean  @default(false)
  secretInjected    Boolean  @default(false)
  rulesetCreated    Boolean  @default(false)
  rulesetId         Int?                // GitHub ruleset ID for cleanup
  apiKeyId          String?             // PP API key created for this repo
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  installation      GitHubAppInstallation @relation(fields: [installationId], references: [id])

  @@unique([installationId, repoFullName])
}
```

### Migration
```sql
-- Single migration file
CREATE TABLE "GitHubAppInstallation" (...);
CREATE TABLE "GitHubAppRepo" (...);
CREATE UNIQUE INDEX ... ON "GitHubAppInstallation"("installationId");
CREATE UNIQUE INDEX ... ON "GitHubAppRepo"("installationId", "repoFullName");
```

---

## API Endpoints

### `GET /api/github-app/install`
Redirects to GitHub App installation page.
- Requires authenticated session
- Appends `state=<encrypted_company_id>` for CSRF + tenant mapping on callback

### `GET /api/github-app/callback`
Post-install redirect handler.
- Validates `state` param to resolve company
- Stores installation in DB linked to company
- Fetches repo list from `GET /installation/repositories`
- Redirects to `/pp/setup?connected=true&installation_id=<id>`

### `POST /api/github-app/webhook`
Webhook event handler (no auth session — uses HMAC signature verification).
- Verifies `X-Hub-Signature-256` header against `GITHUB_APP_WEBHOOK_SECRET`
- Routes to handler by `X-GitHub-Event` header + `action` field
- Returns 200 quickly, processes async if needed

### `GET /api/v1/github-app/repos`
Lists connected repos with setup status. Requires session auth.
```json
{
  "repos": [
    {
      "repoFullName": "permission-protocol/app",
      "status": "connected",
      "workflowInstalled": true,
      "secretInjected": true,
      "rulesetCreated": true,
      "setupComplete": true
    }
  ]
}
```

### `POST /api/v1/github-app/setup-repo`
Runs one or more setup steps for a connected repo. Requires session auth.
```json
{
  "repoFullName": "permission-protocol/app",
  "steps": ["workflow", "secret", "ruleset"]  // any combination
}
```
Each step is idempotent. Returns per-step results.

---

## Installation Token Management

### Token Lifecycle
- Installation tokens are requested via `POST /app/installations/{id}/access_tokens`
- Signed with App private key (JWT, RS256)
- Valid for 1 hour
- Scoped to installation's granted permissions + repos

### Caching Strategy
```typescript
// src/lib/github-app/installation-token.ts
const tokenCache = new Map<number, { token: string; expiresAt: number }>();

export async function getInstallationToken(installationId: number): Promise<string> {
  const cached = tokenCache.get(installationId);
  if (cached && cached.expiresAt > Date.now() + 5 * 60 * 1000) {  // 5 min buffer
    return cached.token;
  }
  const jwt = generateAppJwt();  // Sign with private key
  const response = await fetch(`https://api.github.com/app/installations/${installationId}/access_tokens`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${jwt}`, Accept: 'application/vnd.github+json' },
  });
  const { token, expires_at } = await response.json();
  tokenCache.set(installationId, { token, expiresAt: new Date(expires_at).getTime() });
  return token;
}
```

### JWT Generation
- Uses `GITHUB_APP_ID` + `GITHUB_APP_PRIVATE_KEY` env vars
- Signs with RS256 (jsonwebtoken or jose library)
- Issued at: now, Expires: now + 10 min (GitHub max)
- Issuer: App ID

---

## Post-Approval: Commit Status via App

### Current Flow (broken)
```
Approve → PAT sets commit status → ruleset rejects (wrong integration_id)
```

### New Flow
```
Approve → look up GitHubAppRepo by (repo) → get installationId
  → getInstallationToken(installationId)
  → POST /repos/{owner}/{repo}/statuses/{sha} with installation token
  → Ruleset accepts ✅ (trusted integration)
```

### Fallback
If no App installation found for the repo → fall back to existing PAT behavior (GITHUB_TOKEN env var). Never block approval because the App isn't installed.

**File changes:**
- `src/lib/services/deploy-gate-post-approval.ts` — add App token path before PAT fallback
- `src/lib/post-approval-actions.ts` — same

---

## Webhook: Auto-Expire on PR Close

When `pull_request.closed` fires:
1. Extract `repo` (full_name) and `number` from payload
2. Look up `GitHubAppInstallation` by repo → get `companyId`
3. Call existing `reconcileStaleRequests()` or direct DB update:
   ```sql
   UPDATE "DeployGateRequest"
   SET status = 'expired', "decidedAt" = NOW(),
       reason = 'PR closed/merged on GitHub'
   WHERE repo = $1 AND "prNumber" = $2
     AND status = 'pending' AND "companyId" = $3
   ```
4. Return 200

This replaces the polling-based reconciliation for App-connected repos (polling remains as fallback for non-App repos).

---

## Dashboard UI

### Connected Repos Section (Dashboard page)
```
┌──────────────────────────────────────────────────────┐
│  📦 Connected Repositories                           │
│                                                       │
│  permission-protocol/app         ✅ Ready             │
│  permission-protocol/site        ⚠️ Needs ruleset     │
│                                                       │
│  [+ Connect Repository]                              │
└──────────────────────────────────────────────────────┘
```

### Setup Page (/pp/setup)
Per-repo setup checklist:
```
permission-protocol/app
  ✅ Workflow file installed
  ✅ API key injected
  ⚠️ Branch protection — [Auto-configure] or [Show instructions]
```

---

## Environment Variables (New)

| Var | Where | What |
|---|---|---|
| `GITHUB_APP_ID` | Render | App numeric ID |
| `GITHUB_APP_PRIVATE_KEY` | Render | PEM-encoded private key (base64 or raw) |
| `GITHUB_APP_WEBHOOK_SECRET` | Render | Webhook HMAC secret |
| `GITHUB_APP_CLIENT_ID` | Render | OAuth client ID (for user auth flow if needed) |
| `GITHUB_APP_CLIENT_SECRET` | Render | OAuth client secret |

---

## Implementation Order

### Phase 1: Core (ship this)
1. **Rod creates GitHub App** on github.com (manual — ~10 min)
   - Set permissions, webhook URL, generate private key
   - Store credentials in 1Password + Render env vars
2. **Webhook handler** — `POST /api/github-app/webhook`
   - HMAC verification
   - installation.created/deleted/suspend handlers
   - installation_repositories.added/removed handlers
   - pull_request.closed handler (auto-expire)
3. **Installation storage** — Prisma migration + models
4. **Callback flow** — `GET /api/github-app/callback`
   - State validation, installation storage, repo fetch
5. **Installation token module** — JWT generation + token caching
6. **Commit status via App** — Update post-approval to use App token
7. **Setup page** — repo list, setup checklist, auto-install buttons

### Phase 2: Polish (after Phase 1 is live)
8. **Auto-inject secrets** — PP_API_KEY as repo secret
9. **Auto-install workflow** — Create commit with pp-gate.yml
10. **Auto-configure ruleset** — Create via Rulesets API
11. **Verify endpoint App auth** — Accept installation token as alternative to API key
12. **Uninstall handling** — Graceful degradation, notify user

### Phase 3: Future
- GitLab / Bitbucket support
- GitHub Marketplace listing
- Check Runs API (richer than commit statuses)
- Per-repo policy configuration in dashboard

---

## Security

- **Webhook HMAC**: All webhook payloads verified via `X-Hub-Signature-256` before processing
- **Installation tokens**: Short-lived (1 hour), auto-refreshed, never stored in DB
- **App private key**: In env var only, never in code or DB. Rotatable via GitHub App settings.
- **State param**: Encrypted company ID prevents CSRF on callback and ensures correct tenant mapping
- **Repo scoping**: Each installation token is scoped to only the repos the user granted access to
- **API key isolation**: Auto-created keys get `deployRequests.create` + `receipts.verify` only — NOT `deployRequests.approve`
- **Graceful degradation**: If App is uninstalled, existing API key auth continues working. No lockout.

---

## What This Fixes
| QA Issue | How |
|---|---|
| #7 Key management painful | Auto-inject keys as repo secrets |
| #9 Self-approval | Auto-created keys have create-only scope, not approve |
| #13 Stale requests | Webhook auto-expires on PR close |
| Commit status rejection | App token is trusted integration |
| Manual workflow setup | Auto-install option |
| Manual branch protection | Auto-configure option |

## What This Does NOT Change
- Verify endpoint logic (stays the same, API key auth still primary)
- Deploy-gate action (stays the same, uses PP_API_KEY secret)
- Approval flow (stays the same, just commit status source changes)
- Receipt signing/verification (completely unchanged)
