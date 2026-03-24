# PP Status — Last Updated: 2026-03-24

## Active — Post-Launch (Wednesday Morning)
- **Status:** Tuesday HN launch complete. Recording/Demo sprint archived. Transitioning from "Launch Mode" to "Conversion/Retention Mode."
- **Goal:** Drive 100+ "Demo PR" approvals this week. Convert 5 early adopters to "Team" plan.
- **Next:** Analyze HN feedback, fix high-friction install bugs, and draft "Week 1" changelog.

## Active — MCP Guard (Enforcement Plane)
- **v0.1 Extraction:** Ed25519 verification and policy logic extracted into standalone `permission-protocol/mcp-guard` repo.
- **Next:** Draft v0.2 spec adding "Dynamic Policy Updates" based on signed receipts.

## Active — PullMatch (Growth)
- **Status:** PullMatch.com live. Live diff summarization active.
- **Next:** Launch "Share your risk profile" feature to drive viral loops from individual PRs.

## Technical Debt / Polish
- **Analytics:** Fix PostHog event naming in `pp-app` (currently generic "button_click").
- **Auth:** Investigate intermittent session logout on mobile Safari (likely SameSite cookie issue).

## Decisions (Mar 23)
- **Narrative:** "The Signer is the Product." Renamed CTA to "Approve & Sign."
- **Architecture:** Physical separation of Signer (SaaS) and Enforcer (Binary/MCP) is our primary architectural moat for technical trust.
- **UX:** "Evidentiary UX" — all security signals (Risk, Verification, Context) are now visible by default on the review dashboard to build immediate trust.
