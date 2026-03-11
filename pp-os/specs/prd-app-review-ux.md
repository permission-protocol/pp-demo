# PRD: App Review UX — Port Marketing Site Experience to App

**Status:** Draft
**Date:** 2026-03-09
**Author:** Charles
**Owner:** Rod

---

## Problem

We have two surfaces showing deploy request data with disconnected UX:

- **Marketing site** (`permissionprotocol.com/review/`) — clean approval UX with AI summary, diff view, one-click merge. No auth, no dashboard. Works for individual links.
- **App** (`app.permissionprotocol.com`) — has auth, tenant scoping, dashboard queue, settings, audit trail. But the deploy request detail page is basic — no AI summary, no diff, no one-click merge.

External users who install deploy-gate get a link to the marketing site, approve there, but have no way to see "what else needs my attention?" without logging into the app — where the experience is worse.

**The app is the product. It needs the marketing site's approval UX.**

---

## Goal

A logged-in user on `app.permissionprotocol.com` can:

1. See all pending requests in a dashboard with counts
2. Open any request and see: AI summary, diff, risk signals, PR metadata
3. Approve or reject with one click
4. Merge from PP without touching GitHub
5. See audit trail (receipt, timestamps, who approved)

The marketing site's review pages remain as the public/shareable layer for users without accounts.

---

## Architecture Decision

**Build natively in the app. No bandaids.**

The marketing site was the prototype that proved the UX. Now build it for real where it belongs — the app. The app has direct DB access, user sessions, tenant scoping, and role context. It's the product.

- **Not an iframe.** Fragile, auth complications, can't customize.
- **Not a shared package.** Monorepo/publishing overhead for two consumers is premature.
- **Not a copy-paste.** Reimplemented using the app's existing patterns, component library, and data layer.

The enrichment pipeline (diff fetch, AI summary, risk signals) is reimplemented in the app backend with direct DB caching. The frontend is new React components built to the same visual spec as the marketing site but native to the app.

Marketing site review pages stay alive as the public/shareable layer for anonymous users and deploy-gate links. Long-term, they may redirect to the app once onboarding exists.

---

## Scope

### Phase 1: Enriched Detail Page (this sprint)

**Backend:**
- [ ] Add enrichment endpoint: `GET /api/v1/deploy-requests/[id]/enrichment`
  - Fetches PR diff from GitHub (truncated, same limits as marketing site)
  - Runs risk signal detection (CI/CD, Auth, DB, Secrets, Infra, Deploy, API patterns)
  - Generates AI summary via Gemini 3.1 Flash Lite
  - Caches result (enrich once, serve many)
  - Requires `GITHUB_TOKEN` + `GEMINI_API_KEY` on Render

**Frontend (app deploy request detail page):**
- [ ] AI summary section — 2-4 sentence plain-English description of the change
- [ ] Diff viewer — file list with expandable patches, syntax highlighting
- [ ] Risk signals — badges for detected categories (CI/CD, Auth, etc.)
- [ ] PR metadata — title, author, branch, file count, lines changed
- [ ] Approve button — creates receipt + sets GitHub commit status
- [ ] Reject button — updates status + posts PR comment
- [ ] Merge button — appears after approval, triggers GitHub merge
- [ ] Status badge — pending/approved/rejected/merged with colors aligned to marketing site

**Styling:**
- Match marketing site colors on approval-specific elements (`.approval-surface` scoped CSS)
- Don't change app dashboard/nav/settings styling
- Colors: approve `#10B981`, reject `#EF4444`, pending `#F59E0B`, bg `#0a0a0a`, card `#111111`

### Phase 2: Dashboard Upgrade (next sprint)

- [ ] Pending count badge in sidebar nav
- [ ] Filter: "Needs attention" (pending manual) vs "All" (includes auto-approved)
- [ ] Sort by: newest, oldest, risk level
- [ ] Bulk actions (approve all low-risk, etc.)
- [ ] Email/webhook notifications for new pending requests

### Phase 3: Smart Routing (later)

- [ ] Deploy-gate links route to app (logged-in) or marketing site (anonymous)
- [ ] Marketing site "Sign in to manage all requests" CTA
- [ ] Unified notification system (email, Slack, Discord)

---

## Non-Goals (this sprint)

- Don't change marketing site review pages (they work, keep them)
- Don't build shared component package yet (Phase 2/3)
- Don't add GitLab/Bitbucket support
- Don't add billing
- Don't add team/role management beyond existing tenant model

---

## Success Criteria

1. A user logs into `app.permissionprotocol.com`, sees pending requests, opens one, sees AI summary + diff, approves, merges — never leaves the app
2. The experience is at least as good as the marketing site's review page
3. External users in the 28-day sprint can use the app as their daily driver

---

## Technical Notes

**Enrichment source code to port:**
- `permissionprotocol-site/app/api/review/lib/enrich.ts` — `fetchPrDiff()`, `detectRiskSignals()`, `generateAiSummary()`, `enrichReviewRequest()`
- Truncation limits: 2000 chars/file, 8000 chars total for AI prompt, max 10 files
- Risk patterns: CI/CD, Auth, Database, Secrets, Infra, Dependencies, Scripts, Deploy, API

**Env vars needed on Render (already set):**
- `GITHUB_TOKEN` — for diff fetching + merge + commit status
- `GEMINI_API_KEY` — for AI summary generation

**Merge flow (already exists on backend):**
- `POST /api/v1/deploy-requests/[id]/merge` — calls `executePostApprovalActions()`
- Sets `postApprovalActionType`, `postApprovalActionStatus`, `postApprovalActionResult` on the request

**Existing issue:** #14 on `permission-protocol/app` — re-approval flow for expired receipts (related, should be addressed in Phase 1)

---

## Open Questions

1. **Cache strategy for enrichment?** Enrich on first view and cache, or enrich at request creation time?
   - Recommendation: enrich on first view, cache in DB. Request creation is time-sensitive (gate is waiting); enrichment can be lazy.

2. **Who can approve?** Currently anyone with tenant access (owner/admin). Should we add approver roles?
   - Recommendation: keep it simple for now. Owner/admin can approve. Role-based approval is Phase 3.

3. **Notification when request arrives?** Email? Slack webhook? Discord?
   - Recommendation: PR comment (already shipped in deploy-gate v2) is the notification for now. Dashboard badge when you log in. Real notifications in Phase 2.
