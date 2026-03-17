# Jake System Spec — The Primitive

*How PP works for Jake, the vibe coder. Written March 16, 2026.*

## Install (One Action)
1. Jake clicks "Install GitHub App" (from landing page or GitHub Marketplace)
2. Selects repos
3. Done. No YAML, no secrets, no config.

## Behind the Scenes on Install
- GitHub sends `installation.created` webhook to PP
- PP stores installation (org, repos, access token)
- PP now has permission to: read PRs, set commit statuses, post comments, enable auto-merge

## When Agent Opens a PR
1. GitHub sends `pull_request.opened` webhook to PP
2. PP creates deploy request record (Postgres)
3. PP sets commit status to `pending` ("Permission Protocol — Awaiting review")
4. Enrichment worker fires: fetches diff → AI summary → risk signals
5. PP posts rich PR comment:
   ```
   🔒 Permission Protocol — Review Required

   **Summary:** Adds Stripe checkout to pricing page. New API route
   `/api/checkout` created. Stripe secret key read from env var.

   **Risk:** MEDIUM — new payment integration, but uses env vars correctly.

   **Verify:** Test checkout flow with Stripe test keys.

   ✅ [Approve & Merge](https://app.permissionprotocol.com/review/abc123?action=approve)
   ❌ [Reject](https://app.permissionprotocol.com/review/abc123?action=reject)
   ```
6. GitHub notifies Jake (he already gets PR comment notifications)

## Notification Chain
- **GitHub notification** (always): PR comment appears in notifications/email/mobile
- **Slack** (if configured): optional webhook
- **The PR itself**: commit status blocks merge

## Jake's Approve Flow
1. Sees GitHub notification
2. Opens PR comment
3. Reads 3-line summary
4. Clicks "Approve & Merge"
5. Lands on minimal approve page (auth via GitHub OAuth)
6. Confirms
7. PP: commit status → success, auto-merge enabled, receipt generated
8. PR merges. 30 seconds total.

## Data Flow

```
Agent opens PR
  → GitHub webhook → PP backend
    → Create deploy request (Postgres)
    → Set commit status: pending (GitHub API)
    → Start enrichment (async worker)
      → Fetch diff (GitHub API)
      → AI summary (OpenAI/Anthropic)
      → Store enrichment (Postgres)
      → Post PR comment with summary + links (GitHub API)
      → Slack webhook (if configured)

Jake clicks Approve
  → App auth check (GitHub OAuth)
  → Update deploy request: approved (Postgres)
  → Set commit status: success (GitHub API)
  → Enable auto-merge (GitHub GraphQL)
  → Generate receipt (Postgres + crypto signature)
  → Update PR comment: "✅ Approved by @jake" (GitHub API)
```

## Storage

| Data | Where | Why |
|---|---|---|
| Installation record | PP Postgres | Links GitHub org/repos to PP |
| Deploy request | PP Postgres | Pending review (PR metadata, status, timestamps) |
| Enrichment | PP Postgres (JSON field) | AI summary, risk, verification steps |
| Receipt | PP Postgres + public URL | Cryptographic proof of approval |
| Commit status | GitHub (via API) | Blocks/unblocks PR merge |
| PR comment | GitHub (via API) | Summary + action links |

## Gaps to Build

### Must (days 9-14)
1. **App-only PR flow** — webhook handler creates deploy requests + manages status check lifecycle without Action YAML
2. **Rich PR comment** — summary + risk + one-click approve/reject links
3. **Direct approve from link** — minimal page: summary, approve button, done

### Should (days 15-17)
4. **Marketplace listing**
5. **Landing page with install button** — one CTA

### Don't (yet)
- Email notifications
- Push notifications
- Slack improvements
- Dashboard work
