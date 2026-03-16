# URL Consolidation Spec — Final

**Date:** 2026-03-16
**Status:** Ready for implementation
**Goal:** Single codebase for all authenticated workflows. Marketing site sells. App does.

---

## Current State (What's Broken)

The marketing site (`permissionprotocol.com`) grew a full authenticated review system:
- Own NextAuth GitHub OAuth (separate session from app)
- Own API proxy layer (7 routes forwarding to app API)
- Own enrichment pipeline (Gemini AI summaries, GitHub diff fetching, risk signals, peer reviews, merge readiness)
- Own review dashboard + detail pages

Meanwhile the app (`app.permissionprotocol.com`) has its own:
- Review dashboard at `/pp/deploy-requests`
- Detail page at `/pp/deploy-requests/[id]` (2,181 lines)
- Enrichment pipeline (also Gemini, also GitHub diff — separate implementation)
- Features marketing site doesn't have: timeline, verification integrity, access control, deny reason categories

**GitHub CI status checks link to `https://www.permissionprotocol.com/review/{id}`** — the marketing site, not the app.

The app's detail page already links to marketing for receipts: `https://permissionprotocol.com/r/{receiptId}`.

---

## Final Architecture

```
permissionprotocol.com (marketing site)
├── /                        — Landing page
├── /how-it-works            — Product explainer
├── /pricing                 — Pricing
├── /developers              — Dev hub
├── /developers/quickstart   — Quickstart guide
├── /contact                 — Contact form
├── /blog/*                  — Blog
├── /r/[id]                  — Public receipt (KEEP — unauthenticated, shareable)
├── /review                  → 301 redirect to app.permissionprotocol.com/pp/deploy-requests
├── /review/[id]             → 301 redirect to app.permissionprotocol.com/review/[id]
├── /login                   → 301 redirect to app.permissionprotocol.com/auth/signin
├── /approve/[id]            — DELETE (demo-only, hardcoded data)
└── /replay/[id]             — DELETE (demo-only, hardcoded data)

app.permissionprotocol.com (the app)
├── /auth/signin             — GitHub OAuth
├── /review/[id]             — Bridge page (for GitHub CI links, expired request handling)
├── /pp/deploy-requests      — THE review dashboard (consolidated)
├── /pp/deploy-requests/[id] — THE review detail (consolidated)
├── /pp/setup                — Onboarding
├── /pp/repos                — Connected repos
├── /pp/deploy-providers     — Deploy providers
├── /pp/api-keys             — API keys
├── /pp/c/[slug]/*           — Company-scoped views
├── /account                 — Account settings
├── /activity                — Activity feed
├── /audit                   — Audit log
├── /companies               — Company management
├── /settings/*              — All settings
└── /wizards/*               — Setup wizards
```

---

## Work Items

### Phase 1: Port Marketing UX → App (app repo)

#### 1A. Dashboard Enhancements
**Target:** `/pp/deploy-requests/page.tsx`
**Port from:** Marketing's `ReviewDashboard.tsx` (813 lines)

Add to the app's existing dashboard:
- **Stats bar** at top: pending count, approved count, average wait time, last approved timestamp
- **Stack/swipe view** toggle (alternative to list view) — card-stack UI for quick triage
- **Bulk approve** button: approve all low-risk, non-production requests in one action
- **Manual request creation** form (inline expandable)

Keep the app's existing:
- Attention/All tab split
- Search, sort (newest/oldest/risk)
- Grouped lane display

#### 1B. Detail Page Enhancements  
**Target:** `/pp/deploy-requests/[requestId]/page.tsx`
**Port from:** Marketing's `ReviewPageClient.tsx` (1,385 lines)

Add to the app's existing detail page:
- **Peer review summary**: approved / changes_requested / commented counts from GitHub reviews API
- **Reject reason presets**: quick-select buttons ("Not ready", "Needs tests", "Wrong branch", "Needs discussion")

Keep the app's existing (already superior):
- Decision timeline
- Verification integrity checks with explicit risk acceptance
- Access denied handling
- Deny reason categories
- Merge readiness with check details
- Workflow rerun status
- Blast radius text
- AI summary with risk level parsing

#### 1C. Enrichment Consolidation
**Target:** App's `src/lib/enrichment/enrich.ts` (396 lines)

Port from marketing's `enrich.ts`:
- **Peer review fetching** (`fetchPeerReviews`) — the app's enrichment doesn't fetch GitHub peer reviews
- **Merge readiness** — the app already has this in the frontend helpers, but marketing fetches it server-side during enrichment. Evaluate if app should do the same for consistency.
- **Blast radius detection** — marketing has `detectBlastRadius()` with pattern matching. App may already derive this from risk signals; verify and port if missing.

The marketing site's enrichment adds:
- `peer_reviews: { total, approved, changes_requested, commented }`
- `blast_radius: string` (comma-separated affected areas)
- `summary_sha` + `summary_generated_at` (cache invalidation)

These should be added to the app's `ReviewEnrichment` type.

### Phase 2: Redirects + Cleanup (marketing site repo)

#### 2A. Add Redirects
In `next.config.js` (or middleware):

```js
redirects: [
  { source: '/review', destination: 'https://app.permissionprotocol.com/pp/deploy-requests', permanent: true },
  { source: '/review/:id', destination: 'https://app.permissionprotocol.com/review/:id', permanent: true },
  { source: '/login', destination: 'https://app.permissionprotocol.com/auth/signin', permanent: true },
]
```

#### 2B. Delete Dead Pages
Remove from marketing site:
- `app/review/` (entire directory — page.tsx, ReviewDashboard.tsx, [id]/*)
- `app/login/page.tsx`
- `app/approve/` (entire directory)
- `app/replay/` (entire directory)

#### 2C. Delete Marketing API Proxy Layer
Remove from marketing site:
- `app/api/review/` (entire directory — all 7+ routes)
- `app/api/reviews/route.ts`
- `app/api/auth/` (entire directory — NextAuth config)
- `src/lib/auth.ts`

Keep:
- `app/api/r/[id]/route.ts` — receipt data fetch (if receipt page stays on marketing)
- `app/api/contact/route.ts`
- `app/api/subscribe/route.ts`

#### 2D. Clean Up Dependencies
Remove from marketing site `package.json`:
- `next-auth` (if no other pages need it)
- Any auth-related dependencies

### Phase 3: Fix CI Status URL (app repo)

**Target:** `src/lib/post-approval-actions.ts`

Change:
```ts
target_url: `https://www.permissionprotocol.com/review/${request.id}`,
```
To:
```ts
target_url: `https://app.permissionprotocol.com/review/${request.id}`,
```

This is the URL GitHub shows in the PR checks tab. Currently points to marketing site. After Phase 2 redirects are live, this would redirect anyway — but it's cleaner to point directly to the app.

**Note:** The app's `/review/[id]` bridge page already handles this well — shows basic info, links to full detail at `/pp/c/{slug}/deploy-requests/{id}`, handles expired requests with re-request flow. No changes needed to the bridge page itself.

### Phase 4: Receipt Page Decision

The receipt page (`/r/[id]`) currently lives on the marketing site and is:
- Unauthenticated (public, shareable)
- 511 lines with full status derivation, signature verification display, share buttons (copy link, copy JSON, download)
- Referenced by the app: `https://permissionprotocol.com/r/{receiptId}`

**Decision: Keep on marketing site.**

Rationale:
- Receipts are public-facing artifacts — they belong on the public site
- The URL is already the canonical receipt URL referenced in the app
- No auth needed = no proxy complexity
- It's a read-only page fetching from the app's public API (`/api/v1/public/receipts/[id]`)
- Moving it would require changing every receipt link in the app + any already-shared URLs

The only remaining API route on marketing would be `/api/r/[id]` to fetch receipt data.

---

## Execution Order

1. **Phase 1** first (port features to app) — no user-facing disruption
2. **Phase 3** (fix CI URL) — can ship alongside Phase 1
3. **Phase 2** (redirects + cleanup) — only after Phase 1 is deployed and verified
4. **Phase 4** — no action needed, receipt stays

---

## What This Achieves

- **One place to fix bugs** — all authenticated workflow lives in the app repo
- **One auth session** — no more "logged in on marketing but not on app"
- **One enrichment pipeline** — no duplicate AI summary generation
- **No proxy layer** — marketing site is pure static marketing + public receipt
- **Best of both** — app gets marketing's UX wins (stats, stack view, bulk approve, peer reviews) while keeping its own strengths (timeline, verification, access control)
- **GitHub CI links work directly** — no redirect hop

## Risk

- **SEO** — `/review` was not in sitemap and is auth-gated, so no organic traffic to lose
- **Bookmarks** — 301 redirects handle anyone who bookmarked marketing `/review` pages
- **Receipt URLs** — unchanged, no breakage
- **GitHub CI links** — will redirect during transition (Phase 2 redirects), then point directly (Phase 3)
