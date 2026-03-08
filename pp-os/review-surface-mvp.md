# PP Review Surface — Real Product MVP

## Goal
Turn permissionprotocol.com/review from an internal tool into a multi-tenant product where any team can sign up, connect their repos, and start approving deploys.

## Current State (internal tool)
- Single tenant (our API keys hardcoded in Vercel env vars)
- No auth — anyone with URL sees our requests
- No signup, no onboarding
- Manual API key generation
- "Company OS" branding on Render backend
- GitHub integration via PATs (not scalable)

---

## MVP Scope (what gets us to "someone else can use it")

### Phase A: Auth + Multi-tenant (Week 1)
**Goal:** Users can log in, see only their org's requests.

1. **GitHub OAuth on permissionprotocol.com**
   - Login with GitHub button on `/review` (and `/login` page)
   - NextAuth.js with GitHub provider (proven, simple)
   - Session stored in cookie (no separate DB yet)
   - GitHub user info = identity

2. **Org/Tenant creation**
   - On first login → create tenant on PP API
   - Or: invite flow (existing tenant admin shares link)
   - Store tenant mapping: GitHub org → PP tenant ID

3. **Scoped API calls**
   - `/review` fetches requests scoped to the logged-in user's tenant
   - No more hardcoded API keys in env vars for list/detail routes
   - Approve/reject uses user's tenant credentials

4. **Protected routes**
   - `/review`, `/review/[id]` require auth
   - Landing pages (`/`, `/how-it-works`, etc.) stay public
   - Middleware redirects unauthenticated users to `/login`

### Phase B: GitHub App (Week 2)
**Goal:** One-click repo connection, no manual secret management.

5. **Create PP GitHub App**
   - Permissions: contents:read, statuses:write, pull_requests:write, checks:write
   - Events: pull_request, check_run
   - Installation creates a webhook → PP API

6. **App installation flow**
   - User clicks "Connect GitHub" → redirected to GitHub App install
   - Selects repos → PP receives installation webhook
   - Auto-creates API keys for that org/tenant
   - Stores installation ID for API calls

7. **deploy-gate.yml auto-setup**
   - After app install, offer to PR the workflow file into connected repos
   - Or: provide copy-paste YAML with pre-filled tenant values
   - First request appears automatically on next PR

8. **App-based auth for CI**
   - deploy-gate action authenticates via GitHub App (installation token)
   - No more manual PAT/secret management
   - Requests auto-tagged with correct tenant

### Phase C: Polish (Week 3)
**Goal:** Feels like a real product, not a prototype.

9. **Onboarding wizard**
   - Step 1: Sign up (GitHub OAuth)
   - Step 2: Install GitHub App (select repos)
   - Step 3: See first deploy request (or guided test)
   - Progress indicator, help text

10. **API key management UI**
    - Create/revoke keys from dashboard
    - Show usage stats per key

11. **Branding cleanup**
    - Remove "Company OS" from Render/API surfaces
    - Consistent PP branding everywhere
    - Proper error pages, loading states

12. **Team management (basic)**
    - Invite team members by GitHub username
    - Roles: admin (manage keys/repos) vs reviewer (approve/reject)

---

## What We DON'T Build Yet
- Billing/payments (free tier only)
- GitLab/Bitbucket support (GitHub only)
- Custom domains per tenant
- SSO/SAML
- Audit log export
- Webhook notifications (keep Discord-only)
- Mobile app

## Architecture Decisions Needed

| Decision | Options | Recommendation |
|----------|---------|----------------|
| Auth library | NextAuth.js vs Clerk vs Auth.js | NextAuth.js (free, proven, GitHub provider built-in) |
| User/tenant storage | PP API DB vs separate DB vs Vercel KV | PP API DB (Prisma already there, single source of truth) |
| GitHub App vs OAuth App | App (webhooks, installation tokens) vs OAuth (simpler) | GitHub App (future-proof, better permissions model) |
| Session storage | JWT vs DB sessions | JWT (stateless, no extra infra) |
| Tenant model | Org-based vs user-based | Org-based (matches GitHub orgs, multiple users per tenant) |

## Dependencies
- Breakout-Labs (PP API) changes for multi-tenant user management
- GitHub App registration (Rod needs to create under `permission-protocol` org)
- NextAuth.js setup on permissionprotocol-site

## Success Criteria
- [ ] New user can sign up via GitHub OAuth
- [ ] New user can install GitHub App on their org
- [ ] First PR on connected repo creates a deploy request visible in their dashboard
- [ ] They can approve → PR merges → without ever touching GitHub UI
- [ ] Zero manual intervention from us
