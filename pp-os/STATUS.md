# PP Status — Last Updated: 2026-03-21

## Active — MCP Guard (72h Sprint)
- **v0.1 Shipped:** Stdio proxy for MCP policy enforcement live.
- **Day 2 (Mar 21):** Approval hold path, basic receipt viewer.
- **Day 3 (Mar 22):** HN post — "We built an MCP guardrail that blocks dangerous agent actions using a simple config file"
- **Product sentence:** "Permission Protocol decides whether AI actions are allowed to happen."

## Active — PullMatch (Product Demo)
- **Launched:** PullMatch.com is live. Rebrand from "Tinder for PR" complete.
- **Features:** GitHub OAuth, repo picker, SEO, blog, waitlist share flow, interactive demo.
- **Mar 21 Update:** Optimized mobile landing page (SwipeDemo above fold). Wired live `/api/summarize` for real GitHub diff risk analysis.
- **Next:** Real PR card feed + real diff summarization.

## Active — Governance Framework
- **Repo live:** https://github.com/permission-protocol/governance-framework
- **Publish cadence:** Stagger blog posts 1/week after MCP Guard ships.

## Parked
- Singapore localization, Sarah/Marco requirements, Factory triage.

## Recent Decisions (Mar 21)
- **Mobile-First Demo:** Switched PullMatch hierarchy to prioritize the interactive demo for mobile conversion.
- **Live Summarization:** Decided to use real-time LLM risk analysis of GitHub diffs as the primary "Aha!" moment on PullMatch.
- **Headless Browser Rule:** Manual `navigate` + specific `targetId` is required for reliable screenshots to avoid racing or stale tabs.
- **Framer-Motion Workaround:** Use `opacity: 1 !important` CSS override during screenshots to capture scroll-triggered animations correctly.
