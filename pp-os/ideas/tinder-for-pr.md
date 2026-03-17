# Tinder for PR

**Status:** Spec in progress
**Priority:** Post-sprint (after April 4)
**Origin:** Rod, 2026-03-17 Discord brainstorm
**Relationship:** Separate product, "Powered by Permission Protocol"

## Elevator Pitch
Mobile-first PR review app for vibe coders who don't know git. Swipe right to approve, left to reject. AI explains every diff in plain English. Permission Protocol handles the governance under the hood.

## Target User
Non-technical founders and vibe coders shipping code via AI tools (Cursor, Copilot, v0, etc.) who can't read diffs but still need to review and approve what's going into production.

## Core Features
- **Card UI** — one PR per screen, swipe gestures for approve/reject/request-changes
- **AI diff summaries** — plain-English explanation of what changed, risk score, impact assessment
- **PP integration** — every swipe creates an auditable permission receipt
- **GitHub connection** — pulls PRs from connected repos
- **Mobile-first** — designed for phone, works on desktop

## What PP Already Provides
- Deploy request creation from GitHub PRs
- Approve/reject flow with audit trail
- AI enrichment pipeline for context generation
- Permission receipts on every action

## What Needs Building
- Card/swipe UI (Next.js + mobile gestures)
- Plain-English diff summary mode (tuned for non-devs)
- Standalone auth + onboarding
- Brand, domain, landing page
- "Powered by Permission Protocol" integration badge

## Positioning
- Separate brand, own domain, own identity
- PP credited as infrastructure ("Powered by Permission Protocol")
- Same model as "Payments by Stripe" — PP gets credibility from real consumer product

## Open Questions
- [ ] Domain name (swipetoship.com? mergeme.app? prswipe.dev?)
- [ ] GitHub OAuth app (needs Rod's org admin)
- [ ] Monetization model (free? freemium? PP upsell?)
- [ ] Launch timing (post April 4 sprint)

## Decision Log
- 2026-03-17: Rod decides separate brand, PP-powered (not a mode inside PP app)
- 2026-03-17: Option 2 selected — full spec now, build post-sprint
