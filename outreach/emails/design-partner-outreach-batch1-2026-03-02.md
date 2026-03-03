# Design Partner Outreach — Batch 1
**Drafted:** March 2, 2026 | **Status:** Pending Rod Review
**Issue:** #194 | **Queue:** Blocked for Rod review before sending

> These are drafts only. Do NOT send without Rod's review and explicit approval.
> Channel recommendations included per message.

---

## 1. Bilt Rewards

**Channel:** LinkedIn DM → Engineering leadership (VP/Director of Engineering or CTO)
**Find contact:** Via job posting page (General Catalyst board) or LinkedIn search for "Bilt Rewards VP Engineering"
**Hook:** They explicitly require Claude Code, Cursor, and Devin in all engineering job postings

---

**Subject / DM opening:**

> Hey [Name] — saw Bilt's job posting requiring Claude Code, Cursor, and Devin for all eng hires. That's a strong signal you're building with AI-generated code at scale.
>
> Quick question: when those agents open PRs to your payments infrastructure, what's the governance layer before merge? Not the CI checks — the authorization record. Who signed off, cryptographically, before that code touched prod?
>
> That's the gap we're building for. Permission Protocol is authorization infrastructure for AI-assisted deploys — a signed, timestamped receipt for every production change, bound to a specific commit and approver. One GitHub Action, under 2 minutes to install.
>
> The AWS Kiro incident last month (13-hour outage, agent deployed to prod without secondary approval) is exactly the scenario. For fintech, the blast radius is higher.
>
> Would you be open to a 15-min call, or happy to try it on one repo first? Demo: https://permissionprotocol.com

---

## 2. Raycast

**Channel:** Twitter/X DM to @thomaspaulmann (co-founder & CEO)
**Alt channel:** LinkedIn DM
**Hook:** Confirmed Greptile customer; 22 engineers shipping fast on a single codebase; they understand the AI review tooling space

---

**Subject / DM opening:**

> Hey Thomas — love what you're building at Raycast. Noticed you're running Greptile for AI code review on a team of ~22 shipping at serious velocity.
>
> AI review is step one. The gap we keep seeing: there's no cryptographic record of *who authorized a deploy* before it executed. Not a log after the fact — a receipt that exists before the action happens. If something goes sideways, you need that chain.
>
> The Cisco Talos report this month ("All gas, no brakes" on OpenClaw) named 341 malicious skills and 6 CVEs from agents operating without authorization infrastructure. That's the trajectory without enforcement.
>
> We built Permission Protocol — Deploy Gate — to close that loop. Required GitHub Actions status check, Ed25519-signed receipt per deploy, staging keys can't authorize production. One repo, 2 minutes.
>
> Worth a 15-minute chat, or want to see it on a Raycast repo first? https://permissionprotocol.com

---

## 3. WorkOS

**Channel:** Twitter/X DM to @grinich (Michael Grinich, CEO)
**Alt channel:** Email — michael@workos.com (inferred; verify before sending)
**Hook:** They build enterprise auth and SSO infrastructure — they *are* the governance layer for their customers. Their own deploy governance should match.

---

**Subject / DM opening:**

> Michael — WorkOS is the governance layer your customers depend on for SSO, SCIM, and auth. Curious whether your own AI-generated deploys have the same level of governance you give them.
>
> Your eng manager is on the Greptile site — you're already running AI code review. The missing piece: a cryptographically verifiable record of authorization *before* a deploy executes, not just after. When an AI-assisted PR ships a change to your SSO infrastructure, who signed off? Not in Slack — in an Ed25519-signed receipt bound to that exact commit.
>
> That's what Permission Protocol does. If an AI-generated change introduces a vulnerability in your auth infrastructure, your customers' customers feel it. The receipt is how you prove governance existed.
>
> Would love 15 minutes — or try Deploy Gate on one WorkOS repo and see the receipt. https://permissionprotocol.com

---

## 4. PostHog

**Channel:** GitHub DM or Twitter/X DM to @james406 (James Hawkins, CEO)
**Alt channel:** GitHub Issues/Discussion — PostHog has a very open eng culture
**Hook:** 65 commits/day to a public monorepo, confirmed Greptile customer, open-source culture = would be a vocal advocate

---

**Subject / DM opening:**

> James — PostHog's engineering culture is genuinely impressive. 65 commits/day, 22K tests, all in the open.
>
> You're already running Greptile. Here's what's still missing at that velocity: a pre-action authorization receipt for every production deploy. Not an audit log — a signed, timestamped proof that a human authorized *this specific commit* to go to prod, before it went. Append-only, tamper-evident, Ed25519-signed.
>
> At 65 commits/day to a monorepo, an AI-generated change that slips through affects your open-source users' data. The Astrix scan last month found 42K exposed OpenClaw instances — 93.4% with auth bypass — because agents operated without any external authorization gate. Same structural gap in deploy pipelines.
>
> Permission Protocol is one required GitHub Action. Try it on `posthog/posthog` — takes under 2 minutes to see a receipt. Would love to talk if it fits: https://permissionprotocol.com

---

## 5. Builder.io

**Channel:** Twitter/X DM or email to Steve Sewell (CEO)
**Find email:** Try steve@builder.io (common pattern; verify before sending)
**Hook:** He personally blogged about Cursor YOLO mode — he *knows* the governance gap from the top down

---

**Subject / DM opening:**

> Hey Steve — read your Cursor tips post. Solid breakdown. The YOLO mode section stuck with me: "runs terminal commands, installs packages, makes changes — without waiting for approval."
>
> That's a great dev experience. It's also exactly the scenario the AWS Kiro incident exploited last month — agent deployed to production without secondary approval, 13-hour outage. The difference between "fun in dev" and "disaster in prod" is whether there's an authorization gate before the action executes.
>
> Permission Protocol is that gate: a signed, timestamped receipt for every production deploy, bound to the specific commit and approver. One GitHub Action. If the receipt doesn't exist or doesn't match, the deploy doesn't run — even if YOLO mode pushed the commit.
>
> Given how deep you're into AI-assisted workflows, you'd have opinions worth hearing. 15-minute call or try it on one Builder.io repo? https://permissionprotocol.com

---

## Sending Notes for Rod

- **Priority order:** PostHog (public-friendly, could go GitHub DM or tweet) → Builder.io (Steve is active on Twitter/blog) → WorkOS (warm, they'd get it immediately) → Raycast (direct founder DM) → Bilt (coldest, needs LinkedIn network)
- **Demo URL:** Verify `https://permissionprotocol.com` has a live demo/landing before sending
- **AWS Kiro incident:** Double-check this is attributable/accurate before referencing (sourced from issue #194 hooks)
- **Edit welcome:** These are drafted for Rod's voice — adjust tone as needed, especially for any he has existing relationships with
- **Timing:** All 5 drafted for same batch; can stagger if preferred (e.g., send 2 Mon, 2 Wed, 1 Fri)
