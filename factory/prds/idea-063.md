# PRD: idea-063 — GitHub App: Callback flow (post-install redirect + repo listing)

**Issue:** permission-protocol/app#41
**Priority:** P2
**Repo:** permission-protocol/app
**Size:** M

## Problem
After a user installs the PP GitHub App on their org, there's no callback handler to complete the flow. The user gets redirected to a dead-end or GitHub's default page instead of back to PP.

## User Journey
1. User clicks "Install GitHub App" (from onboarding or settings)
2. Redirected to GitHub App installation page
3. User selects org + repos, clicks Install
4. **Current:** Redirected to... nowhere useful
5. **Expected:** Redirected back to PP setup page showing connected repos

## Requirements

### Must Have
1. **Install endpoint:** `GET /api/github-app/install`
   - Generates encrypted `state` param containing the company/user ID (CSRF protection)
   - Redirects to `https://github.com/apps/permission-protocol/installations/new?state={encrypted_state}`
   - Requires authenticated session (redirect to login if not)

2. **Callback endpoint:** `GET /api/github-app/callback`
   - Receives `installation_id` and `state` from GitHub redirect
   - Validates `state` param to resolve company (CSRF check)
   - Stores the installation record linked to the company
   - Fetches accessible repos via `GET /installation/repositories` (using installation token from #42/idea-062)
   - Stores repos in `GitHubAppRepo` table (or equivalent)
   - Redirects to `/pp/setup?connected=true&installation_id={id}`

3. **Setup success page:** `/pp/setup` handles `connected=true` query param
   - Shows "Successfully connected!" message
   - Lists the repos that were just connected
   - Links to next steps (add workflow, view dashboard)

4. **Error handling:**
   - Invalid/missing state → error page with "try again" link
   - GitHub API failure → error page with retry
   - Unauthenticated users → redirect to login, then back to install flow

### Dependencies
- **idea-062 (#42):** Needs `getInstallationToken()` to fetch repos after callback
- If idea-062 isn't built yet, the callback can store the installation ID and defer repo fetching

### Implementation Notes
- State encryption: use a symmetric key (AES-256-GCM) with a server secret
- State should include: userId, companyId, timestamp (expire after 10 min)
- GitHubAppRepo model may need: `repoFullName`, `installationId`, `companyId`, `enabled` (boolean)
- Check if Prisma schema already has these models from earlier work

### Must NOT Do
- Don't auto-enable deploy gates on all repos — user should choose
- Don't store GitHub tokens in the database — use the installation token module
- Don't skip CSRF validation on the callback

## Acceptance Criteria
- [ ] Install endpoint redirects to GitHub with state param
- [ ] Callback validates state and stores installation
- [ ] Repos are fetched and stored after successful callback
- [ ] Invalid/missing state returns clear error
- [ ] Unauthenticated users redirected to login
- [ ] Setup page shows connected repos on success
