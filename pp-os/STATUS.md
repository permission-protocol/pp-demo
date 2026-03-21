# PP Status — Last Updated: 2026-03-20

## Active — MCP Guard (72h Sprint)
- **v0.1 Shipped:** Stdio proxy for MCP policy enforcement live.
- **Day 2 (Mar 21):** Approval hold path, basic receipt viewer.
- **Day 3 (Mar 22):** HN post — "We built an MCP guardrail that blocks dangerous agent actions using a simple config file"
- **Product sentence:** "Permission Protocol decides whether AI actions are allowed to happen."

## Active — PullMatch (Product Demo)
- **Launched:** PullMatch.com is live. Rebrand from "Tinder for PR" complete.
- **Features:** GitHub OAuth, repo picker, SEO, blog, waitlist share flow, interactive demo.
- **Next:** Real PR card feed + real diff summarization.

## Active — Governance Framework
- **Repo live:** https://github.com/permission-protocol/governance-framework
- **Publish cadence:** Stagger blog posts 1/week after MCP Guard ships.

## Parked
- Singapore localization, Sarah/Marco requirements, Factory triage.

## Recent Decisions (Mar 20)
- **Multi-Workspace Fix:** Fixed GitHub App installation flow for users with multiple workspaces (PP + PullMatch).
- **Free Plan Constraints:** GitHub free plans block rulesets and branch protection. App must gracefully skip enforcement checks on these tiers.
- **Archived Company Leak:** Fixed ghost PRs from archived companies by adding `archivedAt: null` cascading checks.
