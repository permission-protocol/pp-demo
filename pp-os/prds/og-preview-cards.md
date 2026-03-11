# PRD: OpenGraph Preview Cards for Deploy Request Links

**Author:** Charles Goldberg  
**Date:** 2026-03-10  
**Status:** Draft  
**Repo:** permission-protocol/app

---

## Problem

When someone shares a PP deploy request link (approval page, receipt, review URL) in Slack, Discord, Twitter, or any platform that unfurls links — it shows a generic page title and no preview. This makes PP links look unfinished and loses an opportunity to convey status at a glance without clicking.

GitHub generates rich preview cards for every PR link showing the title, diff stats, author avatar, and status. PP should do the same for its core surfaces.

## Goal

Every PP deploy request URL should render a rich, branded preview card when shared — showing the request status, repo, risk level, and environment without requiring anyone to click through.

## Surfaces

Links that should have OG previews:

| Route | Context |
|---|---|
| `/review/{id}` | Approval page (shared with approvers) |
| `/pp/deploy-requests/{id}` | Dashboard detail view |
| `/pp/c/{slug}/deploy-requests/{id}` | Tenant-scoped detail view |
| `/receipt/{id}` (future) | Post-decision audit receipt |

## Approach

Two tiers, shipped sequentially.

### Tier 1: Meta Tags (ship first)

Server-side `<meta>` tags on each route. No image generation. Works everywhere immediately.

```html
<meta property="og:title" content="Deploy Request: permission-protocol/app PR #24" />
<meta property="og:description" content="⏳ Pending · production · medium risk · requested by rod" />
<meta property="og:site_name" content="Permission Protocol" />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://permissionprotocol.com/review/abc123" />
```

**Dynamic fields pulled from the request:**
- `og:title` → Repo + PR title (or "Deploy Request: {repo}")
- `og:description` → Status emoji + status + environment + risk level + author
- Twitter card tags (`twitter:card`, `twitter:title`, `twitter:description`)

**Status → emoji mapping:**
- pending → ⏳
- approved → ✅
- denied → ❌
- expired → ⏰
- superseded → 🔄

**Effort:** ~2 hours. Just a `generateMetadata` function on the page routes.

### Tier 2: Dynamic OG Image (ship second)

Custom-rendered image using `@vercel/og` (Satori + Edge Runtime). Returns a PNG that platforms embed as the link preview image.

**Route:** `GET /api/og/deploy-request/[id]`

**Image layout (1200×630):**

```
┌─────────────────────────────────────────────────┐
│  PP Logo                              Status ●  │
│                                                  │
│  permission-protocol/app                        │
│  feat: dashboard UX — pending badge, filters    │
│                                                  │
│  PR #24  ·  production  ·  ● medium risk        │
│                                                  │
│  Requested by rod  ·  Waiting 2h 15m            │
│                                                  │
│  permissionprotocol.com                         │
└─────────────────────────────────────────────────┘
```

**Design details:**
- Dark background matching PP's dashboard theme (`#0a0a0a` or `#111`)
- PP logo top-left
- Status indicator top-right: colored dot + text (green/amber/red)
- Risk level badge with colored dot (same as dashboard)
- Environment badge (production = red-tinted, staging = blue-tinted)
- Monospace font for repo name, SHA
- Bottom: domain watermark

**Meta tag integration:**
```html
<meta property="og:image" content="https://permissionprotocol.com/api/og/deploy-request/abc123" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
```

**Effort:** ~4 hours. JSX layout + edge route + font loading.

## Data Flow

```
Link shared → Platform fetches URL → Next.js SSR
  → Fetch deploy request by ID (same as page does)
  → If Tier 1: return <meta> tags in <head>
  → If Tier 2: /api/og route renders image via @vercel/og
  → Platform displays rich preview card
```

**Auth:** OG routes must be publicly accessible (crawlers can't authenticate). The data exposed is limited to what's in the meta tags — repo name, PR title, status, env, risk level, author ref. No secrets, no full diff, no internal IDs beyond the request slug.

**Security considerations:**
- Only expose fields already visible on the public review page
- No API keys or tenant secrets in OG content
- Rate-limit the OG image endpoint (Vercel edge handles this naturally)
- Consider caching OG images for 60s to avoid regeneration on every unfurl

## Cache Strategy

- **Tier 1 meta tags:** No special caching needed (rendered with the page)
- **Tier 2 OG images:**
  - `Cache-Control: public, max-age=60, s-maxage=300`
  - Short TTL because status changes (pending → approved)
  - Platforms cache aggressively anyway — acceptable tradeoff

## Success Criteria

1. Sharing a `/review/{id}` link in Discord/Slack shows repo, status, and environment without clicking
2. Sharing on Twitter/LinkedIn shows a branded image card (Tier 2)
3. No auth required for preview rendering
4. Status updates reflect within 5 minutes of change

## Out of Scope

- OG previews for non-deploy-request pages (dashboard, settings, etc.)
- Video previews or animated status
- Per-tenant branded OG images (use PP branding for all)
- OG images for the marketing site (separate concern)

## Sequencing

1. **Tier 1** — ship with the dashboard UX PR or immediately after. Low effort, immediate value.
2. **Tier 2** — next sprint. Polish item that makes PP links look premium.

## Dependencies

- `@vercel/og` package (Tier 2 only)
- Public access to deploy request metadata (already exists on review pages)
- PP logo as embeddable asset (SVG or PNG in `/public`)
