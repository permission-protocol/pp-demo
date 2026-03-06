# Outreach Batch 001 — March 5, 2026
**Status:** PENDING REVIEW
**Prepared by:** Charles (Scout)
**Approved by:** [ ]

---

## Lead 1: Dyna.Ai — Finance Agentic AI
**Why:** Just raised 8-figure Series A for financial services agents. Agents making financial decisions = highest consequence class. They NEED authorization infrastructure before their first enterprise deal asks "how do you prove this was approved?"
**Channel:** Email to founders/CTO (research contact)
**Priority:** 🔴 HIGH

### Draft — Cold Email
```
Subject: Authorization receipts for Dyna.Ai agent actions

Hi [Name],

Congrats on the Series A — scaling agentic AI in financial services is the right bet.

Quick question: when a Dyna.Ai agent executes a financial decision, what cryptographic proof exists that the action was authorized before it ran?

We built Permission Protocol specifically for this gap. It's an authorization layer that issues signed receipts before any agent action executes — think "no receipt, no action." For financial services, this means:

- SOX-grade audit trail (signed, timestamped, tamper-evident)
- Every agent action traceable to an authorized principal
- Fail-closed enforcement — agents can't act without approval

We just submitted our architecture to NIST's AI Agent Security RFI (Docket NIST-2025-0035) and published open-source SDKs:
- pip install permission-protocol
- npm install @permission-protocol/sdk

Would 15 minutes make sense to explore whether this fits your governance roadmap?

Rodrigo Carvalho
Founder, Permission Protocol
permissionprotocol.com
```

---

## Lead 2: Stacks — $23M Finance Automation
**Why:** Lightspeed + General Catalyst backed. Agents automating enterprise finance = transactions, approvals, compliance. Their customers will ask about authorization.
**Channel:** Email / LinkedIn
**Priority:** 🔴 HIGH

### Draft — Cold Email
```
Subject: How Stacks proves agent actions were authorized

Hi [Name],

Saw the Lightspeed-led round — enterprise finance automation is exactly where agents need the tightest controls.

When a Stacks agent processes a transaction or modifies a ledger, what proves it was authorized before execution? Post-hoc logs can't answer that question for SOX auditors.

We built Permission Protocol — cryptographic authorization receipts for AI agent actions. Before any action executes, a signed receipt is issued (Ed25519, timestamped, scope-bound). No receipt = action blocked.

Think of it as the audit trail your enterprise customers' compliance teams will demand.

Open-source SDKs live: pip install permission-protocol | npm install @permission-protocol/sdk

Happy to show you a 5-minute demo. When works?

Rod Carvalho
Founder, Permission Protocol
```

---

## Lead 3: Niels Provos / IronCurtain
**Why:** Building open-source agent safeguards. Different approach (containment vs authorization). Natural ally — complementary, not competitive. Veteran security engineer = high credibility, high network.
**Channel:** Twitter DM or email
**Priority:** 🟡 MEDIUM-HIGH (ally, not customer)

### Draft — Twitter DM from @PermissionPrtcl
```
Hey Niels — saw IronCurtain on Help Net Security. Love the approach.

We've been building in the same space from a different angle: cryptographic authorization receipts (pre-action enforcement, not containment). Think "no receipt, no action" — every agent action gets a signed proof before it executes.

Just published open-source SDKs and submitted our architecture to NIST's AI Agent Security RFI.

Would be great to compare notes — our approaches are complementary. The space needs both containment AND authorization infrastructure.

Open to a quick call?
```

---

## Lead 4: Twitter/X — Riding the Meta AI Safety Story
**Why:** The SF Standard story about Meta's AI safety director losing control of her OpenClaw is PERFECT framing. Reply to discussions, not cold DM.
**Channel:** @PermissionPrtcl Twitter replies
**Priority:** 🔴 HIGH (visibility, not direct lead)

### Draft — Quote tweet or reply thread
```
Meta's AI safety director couldn't stop her own AI agent from going rogue.

The problem isn't monitoring — it's that there's no external enforcement gate. The agent decides what to do, then does it. No checkpoint.

We built @PermissionPrtcl to fix this: cryptographic authorization receipts before every action. No receipt = action blocked.

Just submitted our architecture to NIST (Docket NIST-2025-0035).

Open-source: pip install permission-protocol
```

---

## Lead 5: ArmorCode — Agentic AI Security Platform
**Why:** $81M total funding, building agentic AI security. Could be: integration partner (they do detection, we do authorization), customer (use PP in their own agent infrastructure), or acquisition lead.
**Channel:** Email / LinkedIn
**Priority:** 🟡 MEDIUM

### Draft — Partnership angle email
```
Subject: Complementary layers — ArmorCode detection + PP authorization

Hi [Name],

Congrats on the strategic round. ArmorCode's agentic AI security platform is impressive — particularly the detection and response side.

We've been building the complementary layer: pre-action authorization. Permission Protocol issues cryptographic receipts before any agent action executes. Detection tells you what happened; authorization prevents it from happening without approval.

Our NIST SP 800-53 mapping (AC-3, AU-10, SI-7) might be interesting for your enterprise customers' compliance requirements.

Would love to explore whether a PP integration makes sense in ArmorCode's platform. 15 minutes?

Rod Carvalho
Founder, Permission Protocol
```

---

## Lead 6: Journalists — Offer Expert Source
**Why:** ZDNET, Help Net Security, Hacker News, Dark Reading all published agent security articles THIS WEEK. Offering PP as expert source = free press + credibility.
**Channel:** Email to journalists
**Priority:** 🟡 MEDIUM

### Draft — Pitch to Zeljka Zorz (Help Net Security editor)
```
Subject: Expert source — AI agent authorization infrastructure

Hi Zeljka,

Great piece on enterprise AI agent security (Mar 3). The stat about 80% of orgs reporting risky agent behaviors resonates — we see this daily.

I'm Rod Carvalho, founder of Permission Protocol. We build authorization infrastructure for AI agents — cryptographic receipts before every action, not post-hoc logging. Think Zero Trust applied to the agent action layer.

We just:
- Submitted our architecture to NIST's AI Agent Security RFI
- Published open-source SDKs (Python + npm)
- Documented the OpenClaw crisis as the canonical example

Happy to be an expert source for future agent security coverage. The authorization gap is the story nobody's telling yet — monitoring is necessary but architecturally insufficient.

Available anytime for a call or quote.
```

---

## NEXT ACTIONS
1. Rod reviews these drafts
2. Research actual contact emails for Dyna.Ai, Stacks, ArmorCode
3. Send approved messages
4. Set up signal detection cron (every 4h)
5. Track responses in `outreach/responses/`
