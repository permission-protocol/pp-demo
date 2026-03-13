# Permission Protocol – Master Plan

> **Change Policy:** Amendments require PR + PP deploy gate approval.
> Strategic amendments must include rationale in PR description.
> If a proposed goals.md objective contradicts a Non-Negotiable, master-plan amendment is required first.
>
> **Review Cadence:** Weekly review every Sunday by Charles. Confirm alignment or flag drift.
> Last reviewed: 2026-03-04
>
> **Strategic Pivot (2026-03-04):** See `pp-strategy-v2.md` (approved by Rod).
> Key shifts: Category = Authority Infrastructure. Primitive = Universal Action Receipt (UAR).
> Sequence = Marketing → Website → Product. Framing = Accountability, not security.
> 90-day focus: proof pages, website rebuild, open-source SDK.

---

## Core Thesis

Permission Protocol is the **canonical enforcement layer for autonomous AI actions**.

Every AI agent that touches the real world — deploys code, moves money, sends emails, changes infrastructure — needs explicit, auditable, cryptographically provable authorization. That authorization must live **outside the agent**, in a system the agent cannot override.

PP is that system. Not a framework. Not a best practice. **Infrastructure.**

The same way Stripe became the answer to "how do I accept payments," PP becomes the answer to "how do I prove this AI was allowed to do this."

---

## Wedge

**Deploy Gate** is the entry point.

Code deployment is the highest-stakes, most frequent autonomous action in software. Every company already has CI/CD. Deploy Gate inserts PP as a **required check** — no receipt, no merge. It's:

- Unavoidable (GitHub required status check)
- Zero-config (one GitHub Action)
- Immediately valuable (audit trail from day one)
- Trojan horse (once you have receipts for deploys, you want them for everything)

Deploy Gate is not the product. It's the wedge that makes PP the default.

---

## Non-Negotiables

1. **PP is the canonical Signer of Record.** The receipt is the proof. No receipt = no authorization.
2. **Authorization must exist outside the agent.** Agents cannot self-authorize. Period.
3. **Receipts are cryptographic evidence.** Signed, timestamped, immutable. Not logs. Not audit trails. Evidence.
4. **No receipt, no action.** The enforcement model is binary. There is no "soft mode."
5. **Single enforcement layer.** One system for all agent actions. Not per-tool, not per-provider.

---

## ICP (Ideal Customer Profile)

**Primary:** AI-native startups (10-100 engineers) shipping autonomous features.

- Already have AI agents in production or near-production
- Feel the pain of "who approved this?" when things break
- Engineering-led purchasing decisions
- Move fast, need governance that doesn't slow them down

**Secondary:** Enterprise AI teams building internal agent platforms.

- Regulated industries (finance, healthcare, legal)
- Need audit trails for compliance
- Longer sales cycle but higher contract value

**Entry point for both:** Deploy Gate on one repo → expand to all repos → expand beyond deploys.

---

## What PP Is NOT

- **Not an AI framework.** We don't help you build agents. We help you control them.
- **Not an observability tool.** We don't monitor. We authorize.
- **Not a policy engine.** We don't decide what's allowed. We enforce and record what was authorized.
- **Not a permissions system.** RBAC, ACLs, IAM — those define who can do what. PP proves who *did* authorize what, with cryptographic evidence.
- **Not optional.** PP is not a "nice to have" governance layer. It's a required check that blocks without a receipt.

---

## 3–5 Year Outcome

Permission Protocol is the **default authorization layer** for autonomous AI systems, the way Stripe is the default for payments.

**Measurable targets:**
- 10,000+ repos with Deploy Gate required checks enabled
- Present in 3+ CI/CD ecosystems (GitHub, GitLab, Bitbucket)
- Expanded beyond deploys: financial transactions, infrastructure changes, customer communications
- Revenue from enterprise contracts (authorization-as-infrastructure pricing)
- Industry standard: "Do you have PP receipts?" is a due diligence question

The endgame: **no serious AI system ships without a Signer of Record, and PP is that signer.**
