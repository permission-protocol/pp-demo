# PRD: idea-062 — GitHub App: Installation token module (JWT + caching)

**Issue:** permission-protocol/app#42
**Priority:** P2
**Repo:** permission-protocol/app
**Size:** M

## Problem
PP needs to make authenticated API calls to GitHub on behalf of installed organizations (check branch status, merge PRs, list repos). This requires GitHub App installation tokens, which are short-lived and need JWT-based authentication to obtain.

## Requirements

### Must Have
1. **JWT generation module:** `src/lib/github-app/installation-token.ts`
   - RS256 signing with `GITHUB_APP_PRIVATE_KEY`
   - Issuer: `GITHUB_APP_ID`
   - Expiry: 10 minutes (GitHub max)
   - Uses `jose` or `jsonwebtoken` library

2. **`getInstallationToken(installationId: string)`:**
   - Calls `POST /app/installations/{id}/access_tokens` with JWT auth
   - Returns the token string
   - Caches in memory: `Map<installationId, {token, expiresAt}>`
   - 5-minute expiry buffer (refresh at 55 min, not 60)
   - Auto-refreshes expired tokens transparently

3. **`getInstallationForRepo(repoFullName: string)`:**
   - Looks up which installation has access to a given repo
   - Uses `GET /app/installations` → iterate installations → `GET /installation/repositories` to find match
   - Cache the repo→installationId mapping (repos don't move between installations often)
   - Returns installationId or throws if repo not found

4. **Environment variables:**
   - `GITHUB_APP_ID` — App numeric ID
   - `GITHUB_APP_PRIVATE_KEY` — PEM-encoded RSA private key (multiline, handle `\n` escaping)

### Implementation Notes
- This is a foundational module — other features (#41 callback flow, merge functionality, status checks) will import from it
- Keep it stateless where possible (the cache is in-memory, acceptable for single-instance)
- Handle rate limiting gracefully (GitHub returns 429 with retry-after header)
- Log token refresh events at debug level

### Must NOT Do
- Don't create API routes — this is an internal module only
- Don't persist tokens to database (in-memory cache is correct for short-lived tokens)
- Don't hardcode any credentials

## Acceptance Criteria
- [ ] JWT generation produces valid GitHub App JWT (verifiable via `GET /app`)
- [ ] `getInstallationToken()` returns valid installation token
- [ ] Tokens are cached and reused within expiry window
- [ ] Expired tokens auto-refresh with 5-min buffer
- [ ] `getInstallationForRepo()` resolves repo → installationId
- [ ] Missing env vars throw clear error at startup, not at first use
