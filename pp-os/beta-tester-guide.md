# 🔨 Break Permission Protocol — Beta Tester Guide

Thanks for agreeing to stress test this before launch. Here's what to look at and how to break it.

## What is Permission Protocol?
A governance layer for AI agents. When an AI agent tries to do something consequential (deploy code, access data, make a payment), Permission Protocol blocks the action until a human explicitly approves and signs it. The approval produces a cryptographic authority receipt — proof of who authorized what, when.

**Think of it as:** An approval gate + audit trail for AI-initiated actions.

## 🎯 The 15-Minute Test

### Step 1: See a Gated PR (2 min)
Go to this pull request — it was opened by an AI agent and is **blocked by Permission Protocol**:
→ **https://github.com/permission-protocol/pp-demo/pull/32**

Notice:
- The bot comment with the AI review summary
- The "Authorize Deploy" and "Reject" links
- The pending status check blocking merge

### Step 2: Review the Deploy Request (5 min)
Click **"Authorize Deploy"** in the bot comment. This takes you to the review dashboard.

You'll see:
- **Risk level** (HIGH RISK / Production)
- **AI review summary** — what changed, what to watch for
- **Verification steps** — what to check before approving
- **Risk signals** — automated security analysis
- **The signer warning** — "You will be recorded as the signer"
- **Approve & Sign** / **Reject** buttons

👉 **Try to approve it.** You'll need to be logged in (GitHub OAuth). See what the signed receipt looks like.

### Step 3: Try to Break It (8 min)
Here's what I want you to stress test:

**Security:**
- [ ] Can you approve without logging in?
- [ ] Can you forge or modify a receipt after it's signed?
- [ ] Can you bypass the gate and merge the PR without approval?
- [ ] What happens if you approve from an account that's not authorized?

**UX:**
- [ ] Is it obvious what you're approving?
- [ ] Would you trust this in a real production deploy?
- [ ] Is the risk information useful or just noise?
- [ ] What's confusing or missing?

**Architecture:**
- [ ] What's the single point of failure?
- [ ] If this service goes down, do all deploys stop?
- [ ] How would this work at scale (100 PRs/day)?
- [ ] What's the attack surface?

## 🔗 Key Links
- **Demo PR:** https://github.com/permission-protocol/pp-demo/pull/32
- **Product site:** https://permissionprotocol.com
- **App dashboard:** https://app.permissionprotocol.com
- **GitHub repo:** https://github.com/permission-protocol
- **SDK (PyPI):** `pip install permission-protocol`

## 💬 How to Give Feedback
Reply to my text with whatever you find. Raw notes, stream of consciousness, screenshots — all good. Don't polish it. The rougher the feedback, the more useful.

**Specifically helpful:**
- "I expected X but got Y"
- "This confused me because..."
- "In production I'd want..."
- "The obvious attack is..."

## 🏆 Bonus Challenge
There's an open bounty for bypassing the Ed25519 signature verification:
→ https://github.com/permission-protocol/deploy-gate/issues/36
**$200 if you can forge a valid authority receipt.**

---

*Built by Rod (your former BlackLocus CEO/co-founder). Launching publicly next Tuesday. Your honest feedback before then is worth more than 1000 HN upvotes.*
