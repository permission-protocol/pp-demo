# Phase 0 — Test Messages

*Rod sends these manually from his personal LinkedIn. Goal: validate message quality before automating.*
*Generated: 2026-03-06*

---

## 1. Donald Kossmann — CTO, Chargebacks911

**LinkedIn:** https://www.linkedin.com/in/donaldkossmann
**Signal:** His own article (Mar 5) — "enterprises will need to demonstrate what the agent was allowed to do and what it actually did"
**Angle:** A4 (their_own_words) | **Opener:** O1 (pain_point)
**Score:** 4.05 | **Segment:** CTO

### Connection Note (262 chars)
> Donald — read your piece on agent accountability in commerce. You nailed it: knowing what an agent was *allowed* to do vs what it *did* is the gap. We're building exactly that layer. Would love to compare notes.

### Message 1 (after accept)
> Thanks for connecting. Your point about "stronger auditability of agent decisions and clearer evidence trails" really resonated — that's the exact problem we've been heads-down on.

> We built an authorization receipt system: before any agent action executes, it gets a cryptographic receipt proving what was approved, by whom, and when. Think audit trail that's tamper-proof and machine-readable.

> Curious — is Chargebacks911 running into this with your own AI agents internally, or is it more about what you're seeing from merchant clients?

### Follow-up 1 (3 days, no reply)
> Quick thought after re-reading your article — you mentioned the limits of OAuth delegation for agentic commerce. We hit the same wall. OAuth handles *who can access what*, but not *what was this agent actually authorized to do in this specific moment*.

> Our receipts fill that gap. Would a 15-min walkthrough be useful? Happy to show how it maps to the payment dispute use case.

### Follow-up 2 (5 days, no reply)
> Last ping — totally understand if the timing's off. If agent accountability is something Chargebacks911 is actively working on, I'd love to share what we've built. If not, no worries at all. Either way, enjoyed your article.

---

## 2. Louis Amira — CEO, Circuit & Chisel (ATXP)

**LinkedIn:** [NEEDS LOOKUP — search "Louis Amira Circuit Chisel" or "Louis Amira Stripe"]
**Signal:** Building ATXP protocol — autonomous agent payments with no human oversight
**Angle:** A3 (accountability_gap) | **Opener:** O4 (peer)
**Score:** 5.0 | **Segment:** Founder/CEO

### Connection Note (289 chars)
> Louis — fellow founder here. Been following ATXP since the seed announcement. Autonomous agent-to-agent payments is the future, but I keep thinking: when an agent executes a $50K purchase autonomously, what's the receipt that proves it was authorized? That's what we're building.

### Message 1 (after accept)
> Appreciate the connect. ATXP is one of the most ambitious things I've seen in agentic commerce — the full lifecycle without human oversight is exactly where things are headed.

> The piece I think is missing (and I'd love your pushback): enterprise buyers will want cryptographic proof of what each agent was authorized to do before the transaction executed. Not just "who approved access" but "what was the specific scope of this specific action."

> We built that receipt layer. Curious if you've been hearing that from enterprise prospects yet, or if it's still early?

### Follow-up 1 (3 days)
> One concrete example: imagine an ATXP agent negotiates a supplier contract at 2x the budget the user set. With our receipt system, the authorization scope ("max $25K, vendor category X") is cryptographically bound to the transaction. Dispute resolution becomes trivial.

> Would it be worth 15 min to explore whether this fits into ATXP's protocol layer? Could be a standards-level partnership, not just a vendor relationship.

### Follow-up 2 (5 days)
> Totally get it if you're heads-down on the build. Standing offer: whenever agent authorization comes up in your enterprise conversations (and it will), happy to jam on it. Good luck with ATXP — rooting for you.

---

## 3. Charlie Holtz — Co-Founder, Conductor

**LinkedIn:** https://www.linkedin.com/in/charlieholtz/
**Signal:** HN thread (Mar 5) exposed their sandbox guardrails are bypassable
**Angle:** A1 (incident_response) | **Opener:** O1 (pain_point)
**Score:** 3.35 (but exceptional timing + tech fit) | **Segment:** Founder

### Connection Note (278 chars)
> Charlie — saw the HN thread about Conductor's sandbox boundaries. Tricky problem: soft guardrails vs hard enforcement. We've been building a cryptographic authorization layer for exactly this — real enforcement that agents can't sweet-talk their way past. Thought you'd find it relevant.

### Message 1 (after accept)
> Thanks for connecting. To be clear — not trying to pile on about the sandbox thing. Every agent platform hits this wall eventually: LLM-based guardrails are probabilistic, but users expect deterministic enforcement.

> We built an authorization receipt system: every agent action requires a signed receipt *before* execution. The agent can't bypass it because it's not a prompt — it's a cryptographic gate in the execution path.

> Are you thinking about this as something to solve at the Conductor level, or leaving it to the individual agents (Claude Code, Codex)?

### Follow-up 1 (3 days)
> Quick addition — we just submitted to NIST's AI Agent Security RFI (Docket 2025-0035) on exactly this problem: how to enforce boundaries on autonomous coding agents. Happy to share our framework if you're exploring solutions. YC-stage is the perfect time to bake this in.

### Follow-up 2 (5 days)
> Last note — if enforcement isn't a priority right now, totally understand. When it becomes one (and it will as enterprise customers ask), ping me. Happy to help Conductor be the first agent platform with real authorization receipts. Good luck with the build.

---

## 4. Adnan Khan — Security Researcher (Clinejection discoverer)

**LinkedIn:** [NEEDS LOOKUP — search "Adnan Khan security researcher" or check GitHub: adnankhan]
**Signal:** Discovered and disclosed the Clinejection supply chain attack
**Angle:** A1 (incident_response) | **Opener:** O2 (social_proof)
**Score:** 4.5 | **Segment:** Security researcher (amplifier, not design partner)
**Goal:** Ally/amplifier — get him aware of PP as the architectural fix

### Connection Note (291 chars)
> Adnan — your Clinejection writeup was one of the best security analyses I've read this year. We just submitted to NIST's AI Agent Security RFI and cited the exact attack pattern you exposed. Building the authorization receipt layer that would've stopped it. Would love to connect.

### Message 1 (after accept)
> Really appreciate your work on Clinejection. The attack path you documented — prompt injection → CI/CD trigger → npm publish, all without a single authorization gate — is exactly what keeps me up at night.

> We're building Permission Protocol: cryptographic authorization receipts that sit between an AI agent and any real-world action. In Cline's case, our receipt gate would've required signed human approval before the pipeline trigger and npm publish. The agent literally couldn't have executed those steps.

> Curious: in your research, have you seen any projects tackling the authorization layer specifically (not just sandboxing)?

### Follow-up 1 (3 days)
> BTW — our NIST submission (Docket NIST-2025-0035) covers a 3-tier control framework for AI agent actions. Tier 3 = autonomous but receipted. Tier 1 = human-in-the-loop. Cline had no tiers at all. Happy to share the full submission if it's useful for your research.

### Follow-up 2 (5 days)
> No pressure at all. If you ever write about the authorization gap in AI agent security, I'd love to be a resource. Our approach is open-source SDK + cryptographic receipts. Standing offer to chat anytime.

---

## 5. Charlie Holtz → Alternate: Omer Kaplan — CEO, ZyG

**LinkedIn:** [NEEDS LOOKUP — search "Omer Kaplan ZyG"]
**Signal:** $58M seed just announced — agentic OS for DTC brands, agents manage marketing spend
**Angle:** A2 (deploy_safety) | **Opener:** O4 (peer)
**Score:** 3.9 | **Segment:** Founder/CEO
**Note:** This one tests the "funding announcement" signal type vs incident-based signals

### Connection Note (284 chars)
> Omer — congrats on the raise. Agentic OS for DTC is a massive opportunity. Quick question that might be premature: when your agents start autonomously managing ad spend and supplier contracts, how are you thinking about the authorization/audit layer? That's exactly what we're building.

### Message 1 (after accept)
> Thanks for connecting and congrats again on the $58M. The vision of agents managing the full DTC stack is compelling — and exactly where the market's heading.

> I keep thinking about one gap: when an agent autonomously spends $100K on Meta ads or signs an influencer contract, what proves it was authorized to do that? Not just "the user gave API access" but "this specific action was approved within these specific parameters."

> We built cryptographic authorization receipts for exactly this. Curious if your enterprise prospects are asking about this yet, or if it's more of a "we'll solve it when we get there" thing?

### Follow-up 1 (3 days)
> Concrete example: imagine ZyG's agent runs a campaign that overspends 3x the budget. With our receipt system, every spend action has a signed authorization with the exact scope — so you can show the client exactly what was approved vs what happened. Dispute resolution in 30 seconds, not 30 days.

> Worth 15 min to explore if this maps to your roadmap?

### Follow-up 2 (5 days)
> Totally understand if you're deep in post-raise execution. Standing offer: when "who authorized this agent action?" becomes a customer question (and with $58M of expectations, it will), happy to jam on it. Good luck with the build.

---

## Summary

| # | Target | Company | Angle | Opener | Signal Type |
|---|--------|---------|-------|--------|-------------|
| 1 | Donald Kossmann | Chargebacks911 | their_own_words | pain_point | public_article |
| 2 | Louis Amira | Circuit & Chisel | accountability_gap | peer | funding + architecture |
| 3 | Charlie Holtz | Conductor | incident_response | pain_point | HN incident |
| 4 | Adnan Khan | (researcher) | incident_response | social_proof | security research |
| 5 | Omer Kaplan | ZyG | deploy_safety | peer | funding announcement |

**What we're testing:**
- 3 different angles (incident_response, accountability_gap, deploy_safety, their_own_words)
- 3 different openers (pain_point, peer, social_proof)
- 3 different signal types (article, incident, funding)
- 4 segments (CTO, founder, researcher, founder)

**After Rod sends all 5, we track:**
- Which connection requests get accepted? (accept rate by angle/opener)
- Which messages get replies? (reply rate by angle/signal type)
- What do they actually say? (qualitative — tone, objections, interest level)

This data seeds the playbook before we turn on Expandi.

---

## LinkedIn URLs — All Found ✅

| Target | LinkedIn |
|--------|----------|
| Donald Kossmann | https://www.linkedin.com/in/donaldkossmann |
| Louis Amira | https://www.linkedin.com/in/louisamira/ |
| Charlie Holtz | https://www.linkedin.com/in/charlieholtz/ |
| Adnan Khan | https://www.linkedin.com/in/adnanekhan/ |
| Omer Kaplan | https://www.linkedin.com/in/omerkaplan1/ |

**All 5 ready to send.** Rod: start with connection requests, then send Message 1 after each accept.
