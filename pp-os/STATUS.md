# PP Status — Last Updated: 2026-03-23

## Active — HN Launch (Tuesday Morning)
- **Status:** Action plan consolidated. All technical blockers merged and deployed.
- **Goal:** "Show HN: We built a system where AI agents can't deploy without a human signer."
- **Next:** Rod recording final demo GIF today. Launch Tuesday 8:30 AM MST.

## Active — MCP Guard (Enforcement Plane)
- **v0.1 Extraction:** Ed25519 verification and policy logic extracted into standalone `permission-protocol/mcp-guard` repo to physicalize the "Signer vs Enforcer" split.
- **Next:** Wire `mcp-guard` proxy to use new enforcement primitives.

## Active — PullMatch (Product Demo)
- **Launched:** PullMatch.com is live.
- **Recent:** Mobile landing optimized. Live diff summarization active.

## Technical Fixes (Launch Polish)
- **GitHub Comments:** Fixed emoji encoding bug that broke update-in-place logic (PR #244).
- **Anonymous Demo:** Added login-free `/demo/` approval flow for frictionless HN trial (PR #243).
- **Site Scrolling:** Removed hero chevron and disabled smooth-scroll to fix double-scroll bug (PR #230).

## Recent Decisions (Mar 23)
- **Architecture over Code:** Moving enforcement logic to a separate repo (`mcp-guard`) is critical for the "mathematically defensible" marketing claim.
- **Conversion Wedge:** Reducing the "Aha!" moment from a 5-minute install to a 30-second anonymous demo PR is the priority for the launch funnel.
