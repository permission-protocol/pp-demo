# PP Status — Updated 2026-03-16

## Active
- **Marco User Requirements** — Final draft v2 complete (`pp-os/specs/marco-user-requirements.md`). 29 requirements, 5 sprints. Sarah requirements next.
- **App is now the single approval surface** — all review/approve/reject flows consolidated to app.permissionprotocol.com

## Recently Completed (2026-03-16)
- **Review surface consolidated to app** — Marketing site review/approve/replay pages deleted, 301 redirects added. 6,116 lines removed from site repo. Site now only hosts: landing pages, public receipt viewer (`/r/[id]`), contact/subscribe APIs.
- **App dashboard UX overhaul** — Ported marketing site UX to app:
  - StatsBar (pending, approved, avg wait, last approved)
  - Stack/swipe view with inline approve/deny
  - Bulk approve for low-risk non-production
  - Inline approve button on each queue row
  - Risk + environment badges on every list item
  - PR titles shown (not generic "Pull Request #N")
  - Repo filter pills (multi-select)
  - Status filter pills with counts
  - Recently Approved collapsible section
  - List/stack view toggle
- **App detail page UX overhaul**:
  - Approval note presets (LGTM, Routine deploy, Reviewed)
  - Sticky approve/reject bar on mobile (fixed bottom, backdrop-blur)
  - Timeline promoted to non-collapsible card
  - Risk score + blast radius side-by-side
  - Author track record (deploy history, "New author" warning)
  - Peer reviews from GitHub PR reviews API
  - Reject reason presets (Not ready, Needs tests, Wrong branch, Needs discussion)
- **Mobile-responsive dashboard** — 2x2 stats grid, separate mobile card layout, collapsible filters
- **CI URLs pointed to app** — Status checks and Slack notifications now link to app, not marketing site

## Architecture State
- **Marketing site** (permissionprotocol.com): Landing pages, public receipt viewer, redirects to app for everything else
- **App** (app.permissionprotocol.com): All authenticated flows — dashboard, deploy request review, approve/reject/merge, settings, audit trail
- **Deploy-gate**: GitHub Action that captures PRs → creates deploy requests in PP backend

## Pending
- **Sarah user requirements** — needs same deep treatment as Marco
- **Sprint 1 implementation specs** — break Marco M1-M6 into buildable tickets
- **Factory pipeline improvements**: error-aware retry, auto-archive, merge-order

## Blockers
- None
