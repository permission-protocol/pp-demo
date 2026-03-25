# PP Status — Last Updated: 2026-03-25 8:20 AM MDT

## Active Right Now
- **Mode:** Post-Launch Day 2 — Conversion & Retention phase
- **HN thread:** Live and being monitored (idea-078 ACTIVE)
- **Goal this week:** 100+ Demo PR approvals, 5 Team plan conversions
- **X API:** BLOCKED — write permissions failing, social amplification down (idea-082)

## Active — MCP Guard (Enforcement Plane)
- **v0.1:** Shipped — Ed25519 verification + policy logic extracted into `permission-protocol/mcp-guard`
- **v0.2 spec:** Backlog-ready (idea-084) — Dynamic Policy Updates via signed receipts

## Active — PullMatch (Growth)
- **Status:** PullMatch.com live. Diff summarization active.
- **Next:** "Share your risk profile" viral loop (idea-081, backlog-ready)

## Pending (Ready to Assign)
- idea-079: Week 1 changelog — catalog HN feedback, ship top 3 friction fixes
- idea-082: Fix X API write permissions (priority 1 — blocking amplification)
- idea-080: PostHog event names — can't measure conversion funnel without it
- idea-042: Actionable error UX (M) — every error gets a fix path
- idea-002: Blast radius indicator (M)
- idea-030: AI-generated code summary (M)
- idea-083: Mobile Safari SameSite cookie logout (S)
- idea-084: MCP Guard v0.2 spec (M)
- idea-081: PullMatch risk profile viral loop (M)

## Technical Debt
- **Analytics:** PostHog generic "button_click" events — blind to conversion funnel (idea-080)
- **Auth:** Mobile Safari intermittent session logout — SameSite cookie issue (idea-083)
- **Social:** X API write permissions broken — blocking outbound (idea-082)

## Decisions (Mar 25)
- **Architecture:** "Zero-Setup Demo" (PR #243) is live — primary conversion wedge
- **Narrative:** "The Signer is the Product." / "Locks over Cameras."
- **Analytics priority escalated:** Can't optimize conversion without PostHog event data
