# URL Surface Audit — 2026-03-16

## The Problem
Two codebases serve overlapping authenticated workflows. Bugs get reported against one and fixed on the other. Features drift.

---

## Full Inventory

### permissionprotocol.com (Marketing Site)
**Repo:** `permissionprotocol-site`

| Route | Type | Lines | Purpose |
|---|---|---|---|
| `/` | Marketing | — | Landing page |
| `/how-it-works` | Marketing | 71 | Product explainer |
| `/pricing` | Marketing | 16 | Pricing page |
| `/developers` | Marketing | 5 | Dev hub |
| `/developers/quickstart` | Marketing | 16 | Quickstart guide |
| `/contact` | Marketing | 16 | Contact form |
| `/blog` | Marketing | — | Blog index |
| `/login` | **Auth** | — | GitHub OAuth → redirects to `/review` |
| `/review` | **⚠️ OVERLAP** | 813 | Review dashboard (list all requests) |
| `/review/[id]` | **⚠️ OVERLAP** | 1,385 | Full review detail + approve/reject/merge |
| `/approve/[id]` | **DEMO ONLY** | 95 | Static demo (uses `demoReceipt`, not real data) |
| `/r/[id]` | **⚠️ OVERLAP** | 511 | Receipt page (fetches real data from PP API) |
| `/replay/[id]` | **DEMO ONLY** | 108 | Static demo replay (hardcoded events) |

**Marketing site API layer** (7 routes):
- `/api/reviews` — proxies to `app.permissionprotocol.com/api/v1/deploy-requests`
- `/api/review/[id]` — fetches + enriches with GitHub diff, AI summary, risk signals
- `/api/review/[id]/approve` — proxies approve + triggers GitHub Action rerun
- `/api/review/[id]/reject` — proxies deny
- `/api/review/[id]/merge` — proxies merge
- `/api/review/[id]/summary` — regenerates AI summary
- `/api/review/[id]/update-branch` — updates PR branch
- `/api/review/author/[username]` — reviews by author

### app.permissionprotocol.com (The App)
**Repo:** `permission-protocol-app`

| Route | Type | Lines | Purpose |
|---|---|---|---|
| `/` | Dashboard | — | Home/redirect |
| `/auth/signin` | Auth | — | GitHub OAuth |
| `/pp/deploy-requests` | **⚠️ OVERLAP** | 928 | Deploy request list (attention/all tabs, filters, sort) |
| `/pp/deploy-requests/[id]` | **⚠️ OVERLAP** | 2,181 | Full detail: AI summary, risk signals, diff, timeline, approve/deny/merge |
| `/pp/setup` | App-only | 1,692 | Onboarding wizard |
| `/pp/repos` | App-only | 383 | Connected repos |
| `/pp/deploy-providers` | App-only | 602 | Deploy provider config |
| `/pp/api-keys` | App-only | 570 | API key management |
| `/pp/c/[slug]/deploy-requests` | App-only | — | Company-scoped request list |
| `/pp/c/[slug]/deploy-requests/[id]` | App-only | — | Company-scoped detail |
| `/review/[id]` | **⚠️ OVERLAP** | 281 | Lightweight review: shows status, "Open in PP" link, re-request for expired |
| `/account` | App-only | 576 | Account settings |
| `/activity` | App-only | 116 | Activity feed |
| `/audit` | App-only | 414 | Audit log |
| `/companies` | App-only | 1,027 | Company management |
| `/settings` | App-only | 1,233 | General settings |
| `/settings/llm` | App-only | 755 | LLM config |
| `/settings/llm/defaults` | App-only | — | LLM defaults |
| `/settings/slack` | App-only | 897 | Slack integration |
| `/settings/delegated-accounts` | App-only | 930 | Delegated accounts |
| `/wizards/github-connection` | App-only | 527 | GitHub connection wizard |
| `/c/*` routes | Legacy | 1 each | Re-exports from `/pp/*` (aliases) |

---

## Overlap Analysis

### 1. Review Dashboard (Request List)
| | Marketing `/review` | App `/pp/deploy-requests` |
|---|---|---|
| Lines | 813 | 928 |
| Data source | Proxies to PP API via own backend | Direct API calls |
| Filters | Repo, status | Attention/all tabs, search, sort by newest/oldest/risk |
| Views | List + stack (swipe) mode | List with grouped lanes |
| Bulk actions | "Approve all low-risk non-prod" | — |
| Manual create | ✅ Create request form | — |
| Stats | Pending/approved counts, avg wait, last approved | — |
| **Winner** | **Marketing** (richer UX, stats, bulk approve, stack view) | App has better filtering/sorting |

### 2. Review Detail (Single Request)
| | Marketing `/review/[id]` | App `/pp/deploy-requests/[id]` |
|---|---|---|
| Lines | 1,385 | 2,181 |
| AI summary | ✅ Generated on marketing backend (Gemini Flash Lite) | ✅ Fetched from PP API |
| Risk signals | ✅ Deterministic + enrichment | ✅ Enrichment + context signals |
| Diff viewer | ✅ File list + patches | ✅ File list + patches + collapsible |
| Merge readiness | ✅ Checks, behind_by | ✅ Checks, mergeable state |
| Peer reviews | ✅ Approved/changes_requested/commented | ❌ |
| Approve/reject | ✅ With reject reason presets | ✅ With deny reason categories |
| Post-approve flow | ✅ Rerun GitHub Actions + receipt link | ✅ Rerun + receipt + merge readiness |
| Timeline | ❌ | ✅ Full decision timeline |
| Verification status | ❌ | ✅ Integrity verification |
| Blast radius | ✅ | ✅ |
| Access denied handling | ❌ | ✅ Graceful access denied states |
| **Winner** | **Marketing** (better UX/design, peer reviews) | **App** (timeline, verification, access control, more complete) |

### 3. Receipt Page
| | Marketing `/r/[id]` | App |
|---|---|---|
| Lines | 511 | No dedicated page (API only) |
| Features | Full receipt card, signature verification, share buttons, status derivation | `/api/v1/public/receipts/[id]` (JSON only) |
| **Winner** | **Marketing** (only real implementation) |

### 4. The `/review/[id]` on the App
This is a **lightweight landing page** (281 lines) that:
- Shows basic request info (repo, env, PR, commit, status)
- Links to "Open in Permission Protocol" → `/pp/c/{slug}/deploy-requests/{id}`
- Handles expired requests with "Request New Approval" button
- Auto-redirects to newer active requests

It's essentially a **bridge page** for links from GitHub CI status checks and emails.

### 5. Demo-Only Pages (Marketing)
- `/approve/[id]` — Uses `demoReceipt` hardcoded data. **Not functional.**
- `/replay/[id]` — Uses `replayAuthorizedEvents`/`replayBlockedEvents` hardcoded data. **Not functional.**

---

## Architecture Issue: Marketing Site as Proxy

The marketing site runs its own **full backend** that:
1. Proxies all requests to `app.permissionprotocol.com/api/v1/`
2. Adds its own enrichment layer (GitHub diff, AI summary via Gemini, risk detection, peer reviews, merge readiness)
3. Has its own auth (NextAuth GitHub OAuth — separate session from the app)
4. Caches enrichment results in-memory (10min TTL)

This means:
- **Two auth sessions** — logging into marketing site ≠ logged into app
- **Two enrichment pipelines** — marketing site generates AI summaries independently
- **Two places to fix bugs** — approve/reject/merge logic exists in both
- **Drift is inevitable** — the app gets features (timeline, verification), marketing site gets UX improvements (stack view, bulk approve)

---

## Recommendation: Consolidation Plan

### Keep on Marketing Site (permissionprotocol.com)
- `/` — Landing
- `/how-it-works` — Product explainer
- `/pricing` — Pricing
- `/developers/*` — Dev docs
- `/contact` — Contact
- `/blog/*` — Blog
- `/r/[id]` — Public receipt (unauthenticated, shareable)

### Move to App (app.permissionprotocol.com) — Best of Both
- `/pp/deploy-requests` — Merge marketing dashboard UX (stats, stack view, bulk approve) into app's list page
- `/pp/deploy-requests/[id]` — Merge marketing's peer reviews + UX into app's detail page (which has timeline, verification, access control)
- `/review/[id]` — Keep as bridge page (for GitHub CI links)

### Kill / Redirect
- Marketing `/review` → redirect to `app.permissionprotocol.com/pp/deploy-requests`
- Marketing `/review/[id]` → redirect to `app.permissionprotocol.com/review/[id]` (bridge page)
- Marketing `/login` → redirect to `app.permissionprotocol.com/auth/signin`
- Marketing `/approve/[id]` → delete (demo-only, not functional)
- Marketing `/replay/[id]` → delete or rebuild as real feature on app

### Kill Marketing API Layer
- Remove all `/api/review/*` routes from marketing site
- Move enrichment logic (enrich.ts) into the app's API
- Single auth, single backend, single place to fix bugs

### Features to Port (Marketing → App)
1. **Stack/swipe view** for request queue
2. **Bulk approve** (low-risk, non-prod)
3. **Stats bar** (pending count, avg wait, last approved)
4. **Manual request creation** form
5. **Peer review summary** on detail page
6. **Receipt page** (`/r/[id]`) — could stay on marketing or move to app with public route
