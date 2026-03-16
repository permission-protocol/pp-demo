# PRD: idea-070 — Deploy Gate API Documentation Page

**Issue:** permission-protocol/site#15
**Priority:** P2
**Repo:** permission-protocol/site
**Size:** M

## Problem
No public API documentation. Developers who want to integrate programmatically have to read source code or guess endpoints.

## Current API Surface (from codebase)
- `POST /api/review/[id]/approve` — approve a deploy request
- `POST /api/review/[id]/reject` — deny a deploy request
- `POST /api/review/[id]/merge` — merge after approval
- `POST /api/review/[id]/rerun` — re-run CI checks
- `POST /api/review/[id]/update-branch` — update PR branch
- `GET /api/review/[id]` — get request details
- `GET /api/review/[id]/summary` — get AI summary
- `GET /api/reviews` — list all deploy requests
- `GET /api/review/author/[username]` — get author track record
- `POST /api/contact` — contact form
- `GET /api/r/[id]` — get receipt

## Requirements

### New Page: `/developers/api`
- Linked from main nav (Developers dropdown) and from quickstart page
- Clean, technical documentation layout

### Content Structure
1. **Authentication** — how to authenticate (API key, session, GitHub App token)
2. **Endpoints** — each endpoint with:
   - Method + path
   - Description
   - Request body (JSON schema or example)
   - Response body (example)
   - Status codes
3. **Rate Limits** — if any
4. **Examples** — curl examples for common flows:
   - List pending requests
   - Approve a request
   - Get a receipt

### Design
- Two-column layout: nav sidebar (left) + content (right)
- Code blocks with copy button (reuse existing `CodeBlock` component from `src/components/CodeBlock.tsx`)
- Consistent with existing `/developers/quickstart` page styling
- Anchor links for each endpoint section
- Responsive: single column on mobile

## User Journey
1. Marco's dev opens `/developers/api` from nav
2. Finds the endpoint they need in the sidebar
3. Reads schema + example
4. Copies curl command → tests it → integrates

## Files to Create/Change
- New: `app/developers/api/page.tsx`
- New: `app/developers/api/ApiDocsClient.tsx` (client component for sidebar nav highlighting)
- `src/components/SiteHeader.tsx` — add "API Reference" to Developers dropdown (if dropdown exists) or nav

## What NOT to Change
- Actual API routes or behavior
- Other developer pages
