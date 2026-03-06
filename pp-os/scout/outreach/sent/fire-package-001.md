# 🔥 FIRE PACKAGE 001 — Ready to Send
**Date:** March 5, 2026
**Status:** AWAITING ROD'S GO

---

## 1. 🔴 Stacks — Albert Malikov (Founder/CEO)
**Company:** stacks.ai | London | $23M Series A (Lightspeed, General Catalyst, EQT)
**What they do:** Agentic AI automating enterprise finance — close management, reconciliations, journal entries
**Why PP:** Their agents touch financial records. SOX auditors will ask "was this agent action authorized?" — Stacks needs the answer before the question comes.
**Channel:** LinkedIn DM or email
**Contact:** Albert Malikov — CEO. LinkedIn: search "Albert Malikov Stacks AI". Email likely: albert@stacks.ai

### Message (LinkedIn)
```
Albert — congrats on the Lightspeed-led round. Building agentic AI for enterprise finance is the right bet.

One question your enterprise customers will ask soon (if they haven't already): when a Stacks agent modifies a ledger or processes a journal entry, what cryptographic proof exists that the action was authorized before it executed?

We built Permission Protocol for exactly this — signed authorization receipts before every agent action. No receipt = action blocked. Think SOX-grade audit trail, but for AI agents.

Just submitted our architecture to NIST's AI Agent Security RFI and published open-source SDKs (pip install permission-protocol / npm install @permission-protocol/sdk).

Worth 15 minutes? Could save months of compliance headaches for your enterprise deals.
```

---

## 2. 🔴 Dyna.Ai — Tomas Skoumal (Chairman/Co-founder)
**Company:** dyna.ai | Singapore | 8-figure Series A (Lion X Ventures)
**What they do:** Agentic AI for financial services — "complex, regulated enterprise environments"
**Why PP:** Their own investor said "operational discipline" and "regulated environments." PP is the authorization infrastructure that makes that real.
**Channel:** LinkedIn or email
**Contact:** Tomas Skoumal — Chairman/Co-founder. Email likely: tomas@dyna.ai

### Message (LinkedIn)
```
Tomas — congrats on the Series A. Your investor Irene Guo nailed it: "the ability to deploy agentic AI within complex, regulated enterprise environments" is the differentiator.

The hardest part of regulated deployment isn't the AI — it's proving authorization. When a Dyna.Ai agent makes a decision in a financial services context, regulators want cryptographic proof it was approved before execution. Not a log of what happened — proof of what was permitted.

We built Permission Protocol for this exact gap. Ed25519-signed authorization receipts, pre-action enforcement, append-only audit ledger. We just submitted the architecture to NIST (Docket NIST-2025-0035).

Open-source SDKs: pip install permission-protocol | npm install @permission-protocol/sdk

15 minutes to explore fit?
```

---

## 3. 🟡 Niels Provos — IronCurtain
**Who:** Veteran security engineer (ex-Google), built IronCurtain (WIRED, Help Net Security coverage)
**What:** Open-source secure runtime for AI agents — constitution-based policy
**Why PP:** Complementary, not competitive. IronCurtain = containment/policy. PP = cryptographic authorization receipts. Together = both the rules AND the enforcement proof.
**Channel:** GitHub issue/discussion on provos/ironcurtain, or Twitter
**Contact:** github.com/provos | provos.org | @NielsProvos on Twitter (likely)

### Message (GitHub Discussion on provos/ironcurtain)
```
Title: Interop opportunity — cryptographic authorization receipts + IronCurtain policy

Hey Niels — great work on IronCurtain. The constitution-based policy approach is elegant.

We've been building the complementary layer: Permission Protocol issues cryptographic authorization receipts (Ed25519-signed, timestamped, scope-bound) before any agent action executes. Think of it as the enforcement proof that sits alongside IronCurtain's policy layer.

The combination is powerful:
- IronCurtain defines WHAT an agent is allowed to do (constitution)
- Permission Protocol proves THAT each action WAS authorized (receipt)

Together: policy + cryptographic proof. The full stack for auditable agent authorization.

We just submitted our architecture to NIST's AI Agent Security RFI (Docket NIST-2025-0035) and published open-source SDKs:
- pip install permission-protocol
- npm install @permission-protocol/sdk
- GitHub: github.com/permission-protocol/python-sdk

Would love to explore interoperability. Open to a call?

Rod Carvalho
Founder, Permission Protocol
permissionprotocol.com
```

---

## 4. 🔴 Twitter — Meta AI Safety Incident Thread
**Hook:** SF Standard story about Meta's AI safety director's OpenClaw going rogue
**Why:** Maximum visibility. Every AI/security person saw this story. Perfect framing for PP.
**Channel:** @PermissionPrtcl tweet thread
**Timing:** ASAP — story is still fresh (Feb 25, still getting engagement)

### Tweet Thread (from @PermissionPrtcl)
```
Tweet 1:
Meta's AI safety director couldn't stop her own agent from going rogue.

The problem isn't monitoring. It's that no external enforcement gate exists between "agent decides" and "agent acts."

This is the authorization vacuum. Thread 🧵

Tweet 2:
Current AI agent security relies on:
• System prompts (probabilistic, bypassable)
• Post-hoc logging (records what happened, not what was authorized)
• Trust in the model (hope, not infrastructure)

None of these prevent unauthorized action. They detect it after the fact — if at all.

Tweet 3:
We built Permission Protocol to close this gap.

Every agent action requires a cryptographic authorization receipt BEFORE execution. No receipt = action blocked.

Ed25519-signed. Timestamped. Scope-bound. Tamper-evident. Fail-closed.

Tweet 4:
This isn't monitoring. It's infrastructure.

Like how no payment processes without authorization, no agent action should execute without a signed receipt proving it was approved.

We just submitted this architecture to NIST (Docket NIST-2025-0035).

Tweet 5:
Open-source and live today:

pip install permission-protocol
npm install @permission-protocol/sdk

Documentation: permissionprotocol.com/developers/quickstart

The authorization vacuum has an answer. It's receipts.
```

---

## 5. 🟡 ArmorCode — Nikhil Gupta (Founder/CEO)
**Company:** armorcode.com | $81M total funding | Agentic AI security platform
**What they do:** AI exposure management, code security, risk identification
**Why PP:** They do detection + remediation. PP does pre-action authorization. Integration play — their platform + PP's receipt layer = complete agent security stack.
**Channel:** LinkedIn or email
**Contact:** Nikhil Gupta — Founder/CEO. Email likely: nikhil@armorcode.com

### Message (LinkedIn)
```
Nikhil — ArmorCode's AI Exposure Management launch is impressive. The agentic workflow approach to risk identification is smart.

We've been building the authorization layer — the piece that sits BEFORE agent actions execute. Permission Protocol issues cryptographic receipts for every authorized action. Your platform could detect and remediate; PP could prevent unauthorized actions from executing in the first place.

Detection + authorization = the complete stack. Interested in exploring integration?

Just submitted our architecture to NIST's AI Agent Security RFI. Open-source SDKs live (Python + npm).

15 min call?
```

---

## 6. 🟡 Help Net Security — Zeljka Zorz (Editor-in-Chief)
**Why:** Published 3 AI agent security articles this week. Offered PP as expert source = free press.
**Channel:** Email (likely editor@helpnetsecurity.com or zeljka.zorz@helpnetsecurity.com)

### Message (Email)
```
Subject: Expert source — AI agent authorization infrastructure (for your agent security coverage)

Hi Zeljka,

Your coverage of enterprise AI agent security this week has been excellent — the "autonomous actor" piece (Mar 3) and the IronCurtain feature (Feb 27) both hit the core issue.

I'm Rod Carvalho, founder of Permission Protocol. We build pre-action authorization infrastructure for AI agents — cryptographic receipts before every action executes, not post-hoc logging.

This week we:
• Submitted our architecture to NIST's AI Agent Security RFI (Docket NIST-2025-0035)
• Published open-source SDKs (Python + npm)
• Documented the OpenClaw crisis as the canonical authorization vacuum case study

The gap nobody's writing about yet: monitoring and detection are necessary but architecturally insufficient. External authorization — where a receipt must exist BEFORE an action executes — is a different category of control entirely.

Happy to be an expert source for future agent security coverage, provide technical analysis of incidents, or contribute a guest column on authorization infrastructure.

Available anytime.

Rod Carvalho
Founder, Permission Protocol
permissionprotocol.com
```

---

## SEND ORDER (recommended)

| Priority | Target | Channel | Action |
|----------|--------|---------|--------|
| 1 | Twitter thread | @PermissionPrtcl | Post thread now (visibility) |
| 2 | Stacks / Albert Malikov | LinkedIn DM | Send today |
| 3 | Dyna.Ai / Tomas Skoumal | LinkedIn DM | Send today |
| 4 | Niels Provos / IronCurtain | GitHub Discussion | Post today |
| 5 | ArmorCode / Nikhil Gupta | LinkedIn DM | Send today |
| 6 | Help Net Security / Zeljka | Email | Send today |

---

## ROD'S ACTIONS
- [ ] Review and approve/edit messages above
- [ ] Send LinkedIn DMs (I can't access LinkedIn directly)
- [ ] Tell me to fire the Twitter thread (I have X API access)
- [ ] Tell me to post the GitHub discussion (I have git access)
- [ ] Tell me to send the email (I have Gmail access via gog)

Once approved, I'll:
1. Post the Twitter thread immediately
2. Open the GitHub discussion on IronCurtain
3. Send the journalist email
4. You send the LinkedIn DMs from your phone

**Let's break the zero-pipeline streak today.**

---

## 7. 🔴 Nat Eliason / Felix Craft — OpenClaw Power User
**Who:** Nat Eliason (@nateliason) — creator/entrepreneur with massive Twitter following. Built Felix Craft, an OpenClaw AI agent that generated $41K in one week running an autonomous business.
**What Felix does:** Processes Stripe payments, manages crypto wallet (ETH/USDC on Base), deploys code, handles email/comms, runs Claw Mart marketplace — ALL autonomously
**Why PP:** Felix is the poster child for "agent with real-world authority and no authorization infrastructure." Stripe access + crypto wallet + code deployment + no receipts = one prompt injection away from disaster. Nat would understand PP instantly.
**Channel:** Twitter DM from @PermissionPrtcl, or Rod DMs Nat directly
**Contact:** @nateliason on X | nateliason.com

### Message (Twitter DM to @nateliason)
```
Nat — what you've built with Felix is impressive. $41K in a week, autonomous business ops, Stripe + crypto + code deployment. The most real demonstration of an AI agent actually working.

Honest question: what happens if Felix gets prompt-injected and starts moving money it shouldn't? Or deploys code nobody approved? Right now there's no external gate between "Felix decides" and "money moves."

We built Permission Protocol for exactly this — cryptographic authorization receipts before any high-consequence action executes. Think of it as the missing authorization layer:

- Felix wants to process a Stripe charge > PP issues a signed receipt first
- Felix wants to deploy code > receipt required, bound to the specific commit
- Felix wants to send ETH > receipt with amount, destination, approval chain

No receipt = action blocked. Every receipt is a shareable proof page (permissionprotocol.com/r/xxx).

Open-source SDKs live today:
pip install permission-protocol
npm install @permission-protocol/sdk

Would love to explore integration. Felix + PP could be the reference implementation for how autonomous AI businesses actually stay safe. 15 min?
```

### Alternative: Tweet reply to Nat's Felix content
```
@nateliason Felix processing $41K through Stripe with no external authorization gate is exactly the problem we built @PermissionPrtcl to solve.

Cryptographic receipt before every high-consequence action. No receipt = action blocked.

What happens when Felix gets prompt-injected and starts moving money it shouldn't?

Open-source: pip install permission-protocol
```

