# Outreach Templates — Consequence Engine Angle

*Updated: 2026-04-08. Use these for all outreach going forward.*

---

## Template 1: Cold LinkedIn DM (Founders/CTOs of AI-heavy teams)

**Subject:** How do you know which AI PRs are safe?

Your agents are writing code. GitHub treats every PR the same — a one-line test fix and a rewrite of your auth layer get the same merge button.

Permission Protocol analyzes every PR for production consequences. Low-risk changes clear automatically. High-risk changes require a human signer. Every decision gets a tamper-evident receipt.

Install in 30 seconds, zero config: [link]

---

## Template 2: Cold LinkedIn DM (AI infra founders — Cognition, Cursor, crewAI, etc.)

Your users are shipping AI-generated code to production. The question they'll ask next: "how do I know what this could do before it merges?"

We built Permission Protocol — consequence analysis for every PR. It explains what a change could do, decides deterministically if it needs a human, and produces a signed receipt.

Would love to show you a 60-second demo. Open to a quick call this week?

---

## Template 3: Cold LinkedIn DM (DevOps/Platform leads)

Your team is merging 10+ AI-generated PRs a day. How do you decide which ones need a human?

Permission Protocol installs as a GitHub App and analyzes every PR automatically:
- Test file updates → cleared instantly with a receipt
- Auth code changes → flagged for human sign-off
- Hardcoded secrets → blocked from merge

Zero configuration. 30-second install. [link]

---

## Template 4: Warm follow-up (people who've seen the old messaging)

We've been refining what PP does. The short version:

PP turns a PR into a consequence brief — what this change could do to production — and decides whether it needs a human. Not a code review bot. An authority system.

Here's what it looks like on a real PR: [screenshot/Loom link]

Worth 5 minutes of your time?

---

## Template 5: Community post (dev.to / Reddit / Discord)

**Title:** We stopped building a PR review tool and built an authority system instead

We spent weeks building "a better approval surface for AI-generated PRs." The feedback was consistent: "this is just another layer on top of GitHub."

They were right. So we rebuilt.

Permission Protocol now:
1. Analyzes every PR for production consequences (not code quality — consequences)
2. Decides deterministically whether it needs a human (not the LLM — hard rules)
3. Produces a tamper-evident receipt for every decision

The LLM writes the consequence brief. Deterministic rules decide the gate. The LLM never blocks a merge.

Here's what a real PR comment looks like:

[screenshot of cleared / approval_required / denied examples]

Install in 30 seconds on any GitHub repo: [link]

---

## Anti-patterns (never use these in outreach)
- "Better PR reviews"
- "AI-powered code review"
- "Risk assessment"
- "Governance layer"
- "Smart reviewer"
- "Auto-approved with receipt"
