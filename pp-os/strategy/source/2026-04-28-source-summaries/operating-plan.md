# Permission Protocol — Chat Findings, Decisions, and Operating Plan

**Date:** April 28, 2026  
**Purpose:** Consolidate the strategy work, stress tests, feedback rounds, simulated interviews, AIUC-1 analysis, outreach planning, and final decisions from this chat into one executable reference.

---

## 1. Executive Summary

The strategy converged on one core idea:

> **Permission Protocol should be the runtime authorization and verifiable evidence layer for high-risk AI-agent actions.**

The product is not primarily a GitHub approval tool, a generic protocol, an AI governance dashboard, or an approval workflow app. The core product is the **receipt-backed enforcement primitive**:

> **No receipt, no execution.**

The strongest product package is:

> **Permission Protocol Action Gate** — policy check, human approval when required, signed/verifiable receipt, and receipt verification before a high-risk AI-agent action executes.

The strongest initial buyer is:

> **Customer-facing AI-agent companies selling into enterprise, whose agents can take customer-facing or business-critical write actions and whose prospects ask about controls, authorization, security review, compliance, auditability, or runtime evidence.**

The secondary buyer is:

> **AI coding-agent companies and AI-native engineering teams, where agents create PRs or production-impacting changes and teams need merge/deploy gates with evidence.**

The key strategic correction from the later feedback was that the compelling event should not be framed as generic “enterprise buyers will ask about controls.” The sharper wedge is:

> **Enterprise security review is becoming longer and more AI-agent-specific. Agent vendors need reusable, verifiable runtime evidence for high-risk actions to reduce deal friction.**

The next step is not more strategy. It is real prospect validation and outreach.

---

## 2. Final Strategic Decision

### Final company-level thesis

Permission Protocol is the **runtime authority and audit-evidence layer** for AI-agent actions.

It proves:

- which agent requested an action,
- what action was requested,
- what resource/customer/context was affected,
- what policy applied,
- who approved it,
- what payload/parameters were approved,
- whether execution matched the approved payload,
- and whether a valid receipt existed before execution.

### Final product-level thesis

The product is:

> **Action Gate** — a pre-execution authorization API + hosted approval flow + signed receipt + verifier.

Deploy Gate / Merge Gate is not the company. It is an adapter and proof loop.

### Final go-to-market thesis

Primary GTM:

> Sell Action Gate to AI-agent companies as runtime authorization evidence they can show enterprise security/procurement teams.

Secondary GTM:

> Keep Merge Gate / Deploy Gate alive for AI-written code and production-risk PRs, but do not let it define the whole company unless Action Gate validation fails.

---

## 3. What We Are Selling

### The primitive

Permission Protocol sells one primitive:

> **A verifiable receipt that proves a specific consequential AI-agent action was authorized before execution.**

The contract:

1. Agent requests authorization for a specific action.
2. Policy returns `allow`, `deny`, or `approval_required`.
3. If approval is required, a human signs through a hosted approval UI.
4. Permission Protocol issues a signed receipt.
5. The execution point verifies the receipt.
6. If the receipt is invalid, missing, expired, or bound to different payload parameters, execution fails.

### Product 1: Action Gate

**Use case:** customer-facing or business-critical AI-agent actions.

Examples:

- refund issuance,
- customer email send,
- subscription change,
- account closure,
- customer data export,
- customer data deletion,
- CRM update,
- billing/payment action,
- production deploy,
- database migration,
- destructive tool/API call.

**Positioning:**

> Runtime authorization evidence for high-risk AI-agent actions.

**Tagline:**

> No receipt, no execution.

### Product 2: Merge Gate / Deploy Gate

**Use case:** AI-authored or high-risk PRs touching production-risk areas.

Examples:

- infra,
- migrations,
- auth,
- billing,
- secrets,
- deploy workflows,
- CI/CD,
- production config.

**Positioning:**

> Let agents write code. Don’t let them merge blindly.

**Tagline:**

> No receipt, no merge.

---

## 4. What We Are Not Selling

Do **not** lead with any of these:

- “a protocol,”
- “AI safety,”
- “AI governance platform,”
- “another GitHub approval gate,”
- “AI code review,”
- “generic approval workflow,”
- “generic audit logs,”
- “OAuth replacement,”
- “MCP platform,”
- “compliance dashboard.”

The approval UI is not the product. The receipt is the product.

The product becomes valuable only if the execution point refuses to proceed without a valid receipt.

---

## 5. Clear Problem Statement

### Main problem

AI agents are moving from answering questions to taking real actions. Those actions create risk.

Enterprise buyers increasingly need to know:

> What was the agent allowed to do, who approved the action, what exact action was approved, and can we verify that the executed action matched the approved action?

### Customer-facing agent version

Customer-facing agents can affect money, accounts, customer data, promises, service outcomes, and liability.

The buyer fear is:

> “If the agent issues the wrong refund, closes the wrong account, sends the wrong email, deletes data, changes a subscription, or makes a policy exception, who authorized that and where is the proof?”

### Coding-agent version

Coding agents can create PRs, modify code, trigger workflows, and increasingly affect production systems.

The buyer fear is:

> “I want agents writing code, but I do not want one touching auth, billing, migrations, infra, deploy workflows, or production config without explicit human authority.”

### Security-review version

Security review is increasingly split into two layers:

1. Standard SaaS review: SOC 2, ISO 27001, DPA, subprocessors, pen test, SSO, SCIM, encryption, incident response.
2. AI-agent review: model providers, data training, prompt/data retention, agent permissions, tool access, action boundaries, runtime authorization, human approval, audit trail, and evidence that actions stayed inside policy.

Permission Protocol targets the second layer.

---

## 6. Value Proposition

### Primary value proposition

> Permission Protocol helps AI-agent companies prove that high-risk actions were authorized before execution.

### Stronger security-review version

> Permission Protocol gives agent companies verifiable runtime evidence for high-risk AI-agent actions, mapped to controls enterprise security reviewers already recognize.

### CRO/founder version

> If security review is slowing enterprise deals because your agent can take write actions, Permission Protocol gives you the runtime evidence artifact you are missing.

### Technical version

> Wrap high-risk agent actions with `requestPermission()`. Get allow/deny/approval-required decisions, route human approval when needed, issue signed receipts, and verify before execution.

### Investor version

> As AI agents move from chat to action, Permission Protocol becomes the authority and evidence layer enterprises need before trusting agents with real tools.

---

## 7. ICP and Priority Segments

## Priority 1 — Customer-facing AI-agent companies selling into enterprise

This is the primary ICP.

### Required traits

- 20–200 person AI-agent company.
- Product is an AI agent, not just an AI feature.
- Agent takes or will soon take consequential write actions.
- Sells into mid-market, enterprise, regulated, or compliance-sensitive accounts.
- Prospects ask about security, auditability, human approval, compliance, controls, or what the agent is allowed to do.
- Founder, CTO, Head of Product, Head of Enterprise, or Trust/Security lead can make a fast pilot decision.

### Best verticals

- AI customer support / CX agents.
- Ecommerce support and ops agents.
- RevOps / CRM agents.
- Fintech operations agents.
- Healthcare admin agents.
- AI coding-agent companies with enterprise customers.

### Initial target examples

- Decagon.
- Sierra.
- Crescendo.
- Forethought.
- Ada.
- Gorgias AI.
- Intercom Fin enterprise/product.
- Zendesk AI/product.
- Factory.
- Codegen.
- Cursor Enterprise.
- Cognition / Devin Enterprise.
- Replit Agent Enterprise.

## Priority 2 — AI coding-agent companies

These companies sell agents that write code, create PRs, and sometimes touch production workflows.

Sell them:

> External signed receipts for agent-authored code changes and production actions.

Do **not** pitch:

> “Use our GitHub gate internally.”

Pitch instead:

> “Your enterprise customers will ask who authorized the agent-authored production action and where the proof lives.”

## Priority 3 — Direct AI-native engineering teams

This is a useful proof loop, not the main company thesis.

Best buyers:

- 10–100 engineer startups.
- Already using Cursor, Claude Code, Codex, Devin-like agents, Copilot coding agent, or internal code agents.
- Agents create PRs at least weekly, ideally daily.
- Risky paths exist: infra, migrations, auth, billing, secrets, CI/CD, production config.
- Technical founder or CTO can buy immediately.

## Deprioritized for the 30-day sprint

Do not make these the main pipeline before June 1:

- Composio.
- Pipedream.
- Zapier.
- n8n.
- Make.
- Gumloop.
- LangChain.
- CrewAI.
- Mastra.
- systems integrators.
- big enterprise buyers directly.
- generic MCP enthusiasts.

These are strategically relevant, but many will build rather than buy, move too slowly, or want partnerships instead of paid pilots.

---

## 8. Offers and Pricing

## Offer A — Action Gate Evidence Pilot

**Price:** $7,500 for 30 days.

**Deliverable:** Gate one real high-risk agent action end-to-end and produce verifiable runtime evidence.

### Included

- one action integration,
- one policy,
- one approval flow,
- signed receipt,
- verification endpoint,
- public/private receipt page,
- control-mapping artifact,
- founder-led integration support.

### Example pilot

> Refunds above $100 require approval. The agent cannot execute the refund unless a signed receipt verifies. The receipt includes actor, action, customer/resource, payload hash, policy, approver, timestamp, execution result, and control mapping.

### How to sell it

Do not say:

> “Platform integration pilot.”

Say:

> “We will gate one action your agent already takes.”

## Offer B — Merge Gate / Deploy Gate

**Price options discussed:**

- one repo free for evaluation,
- $99–$299/month for team/self-serve,
- $1,500/month concierge production pilot.

### How to sell it

> Protect one repo. AI-authored or high-risk production changes cannot merge until a human signs an approval receipt.

---

## 9. Pitch Library

## Primary email pitch to agent companies

Subject: Agent action evidence for enterprise security review

Hi {{first_name}},

I’m researching how enterprise security teams are reviewing AI agents that can take real actions — refunds, customer emails, subscription changes, account updates, data export/deletion, etc.

The pattern I’m testing is this: SOC 2 and logs answer part of the review, but they don’t prove that a specific high-risk agent action was authorized before execution.

Permission Protocol gives agent companies an Action Gate: policy check → human approval when needed → signed receipt → execution only if the receipt verifies.

Would you be open to a 15-minute conversation about whether this is showing up in {{company}}’s enterprise reviews?

Rod

## Short LinkedIn connection message

Hi {{first_name}} — I’m researching enterprise security review for AI agents that take actions. Curious whether buyers are asking {{company}} for proof of who authorized risky actions before execution. No pitch — could I ask 4 questions?

## Founder/direct version

Your agent can take actions. That is the value — and the procurement problem.

We help you prove high-risk actions were authorized before execution. One action, one policy, signed receipts, 30-day pilot.

## Merge Gate pitch

You’re letting AI coding agents create PRs. Most are fine. The risky ones touch infra, migrations, auth, billing, deploy workflows, or production config.

Merge Gate blocks those PRs until a human signs the exact change. The check only passes for the approved commit.

No receipt, no merge.

---

## 10. Validation Questions

The validation call should not start with a product pitch.

Opening:

> I’m trying to understand how agent companies are handling enterprise procurement around agent autonomy. Without me pitching anything, what is the hardest question you’re getting from enterprise prospects about what your agent is allowed to do?

Follow-ups:

1. What actions can your agent take today besides answering questions?
2. Which actions make enterprise buyers nervous?
3. Has security review gotten longer or more detailed because of agent autonomy?
4. What exactly are they asking for — logs, approvals, controls, SOC 2 mapping, data boundaries, human review?
5. Do you have pre-execution authorization today, or mostly post-action logs?
6. Would a verifiable approval-and-receipt artifact help, or would they still want something else?
7. If this helped, what action would you gate first?
8. If we could gate that action in 30 days, would you pay $7,500 for a pilot?

## Scoring rubric

- **0:** no write actions or no enterprise pressure.
- **1:** write actions exist, but controls are not urgent.
- **2:** named enterprise concern around approval/audit/control.
- **3:** deal friction + named action + willingness to pilot/pay.

---

## 11. Decision Gates

## April 28–30 validation pass

Run 5–8 listening calls.

Decision rule:

- **3+ calls score 2 or 3:** run Action Gate sprint.
- **0–1 calls score 2 or 3:** shift June 1 sprint to Merge Gate.
- **Exactly 2 calls score 2 or 3:** run both for 10 days; force decision May 10.

## May 7 gate

Need:

- 8+ qualified calls completed,
- 3+ prospects naming the same pain,
- 1+ asking for integration details.

If not, you are behind.

## May 14 gate

Need:

- 2 SOWs out,
- 1 prospect committed to pay or co-build.

If not, shift to 50/50 Action Gate and Merge Gate.

## May 20 gate

Need:

- 1 paid pilot or LOI in hand.

If not, June 1 PMF story pivots to Merge Gate evidence.

## June 1 evidence bar

Minimum credible story:

- 1 paid Action Gate pilot at $7,500,
- 1 coding-agent/customer-agent LOI or serious negotiation,
- 3–5 Merge Gate evaluation/paying repos,
- signed receipts live in 2 environments,
- 50+ authorization/receipt events,
- 5 prospects naming the same pain in their words,
- one quote about security review, runtime evidence, or action approval.

Strong story:

- 2 paid Action Gate pilots,
- 1 named design partner,
- 1 public/private case study,
- 100+ receipt/decision events,
- one inbound from the right ICP,
- evidence that the receipt artifact helps answer security/procurement.

---

## 12. Build Scope

## Must build first

1. Action Gate API / SDK.
2. Policy decision states: `allow`, `deny`, `approval_required`.
3. Hosted approval page.
4. Real signed receipt.
5. Public/private receipt verifier.
6. Receipt Format v0.1.
7. Refund/email/account-change demo.
8. Merge Gate adapter kept usable.

## Receipt Format v0.1 should include

- receipt ID,
- request ID,
- issuer,
- key ID,
- actor,
- action,
- resource,
- tenant,
- payload hash,
- payload summary,
- policy ID/version,
- decision,
- signer ID,
- signer role,
- approved timestamp,
- execution status,
- execution hash,
- expiration,
- signature algorithm,
- signature,
- selected control mappings.

## Demo flow

A support agent receives a customer request:

> “Refund this customer and send confirmation.”

Actions:

1. `read_order_status` → allowed.
2. `draft_customer_email` → allowed.
3. `send_customer_email` → approval required.
4. `issue_refund $50` → allowed.
5. `issue_refund $500` → approval required.
6. `issue_refund $5,000` → denied.
7. `delete_customer_account` → denied.

The demo must show:

- policy decision,
- approval request,
- human signature,
- receipt issued,
- receipt verification,
- execution blocked without receipt,
- execution allowed with valid receipt.

## Do not build yet

- SAML.
- SCIM.
- self-hosting.
- full dashboard.
- Slack approval before hosted web approval works.
- advanced policy language.
- audit exports.
- enterprise admin UI.
- full MCP adapter polish.
- marketplace polish.
- rebrand.
- more strategy docs.

---

## 13. AIUC-1 Decision

The correct classification is:

> **Permission Protocol implements a narrow runtime authority and audit-evidence slice of AIUC-1. It does not broadly conform to AIUC-1, and it is not an official extension unless AIUC-1 formally adopts or references it.**

Precise market-facing claim:

> Permission Protocol helps implement selected AIUC-1 controls for agent permissions, unsafe tool/action execution, human approval, and authorization auditability. It is not a substitute for AIUC-1 certification.

AIUC-1 is broader than Permission Protocol. It covers safety, reliability, accountability, data/privacy, testing, harmful output, model behavior, and operational governance. Permission Protocol mainly maps to the runtime authorization/audit cluster.

The right positioning is:

> AIUC-1 = assurance standard and certification framework.  
> Permission Protocol = runtime authority/audit implementation that helps satisfy selected AIUC-1 controls.

Do not claim AIUC-1 conformance.

---

## 14. Competitive Landscape and Risks

## Risk 1 — “Approvals” are already features

Intercom, Decagon, Sierra, Salesforce, Okta, Zapier, Descope, and others already talk about guardrails, approvals, audit logs, human handoff, runtime controls, or agent identity.

Therefore, do not pitch:

> “We add approvals.”

Pitch:

> “We produce independently verifiable runtime evidence that the approved action matched the executed action.”

## Risk 2 — Platforms may build this themselves

Composio, Pipedream, Zapier, Workato, Descope, and others are adjacent enough to build approval/audit functionality.

Defense:

- own the receipt format,
- publish open Receipt Format v0.1,
- ship public verification,
- become the neutral external proof layer,
- map receipts to standards/security-review evidence.

## Risk 3 — Receipts are weak unless tied to enforcement

If receipts are just logs, they are compliance theater.

Every pitch must tie the receipt to execution:

- no receipt, no execution,
- no receipt, no merge,
- no receipt, no tool call,
- no receipt, no refund/customer email/account change.

## Risk 4 — Overclaiming crypto is fatal

If receipts are not actually signed and verifiable, do not use:

- “cryptographic,”
- “signed,”
- “immutable,”
- “non-repudiable.”

Use “tamper-evident audit record” until signing is real.

## Risk 5 — GitHub-only positioning collapses into branch protection

If buyers hear:

> “We block PRs until approval,”

many will think:

> “GitHub already does that.”

The correct differentiation is:

> GitHub branch protection blocks merges. Permission Protocol proves which human authorized the agent action that unlocked the merge.

---

## 15. Website and Messaging Decisions

## Website direction

Keep the Deploy Gate page, but do not make it the entire company story.

Add/refine a page for Action Gate / platforms:

### Headline option

> Runtime evidence for AI-agent security reviews.

### Subhead option

> Gate high-risk agent actions with policy checks, human approval, and verifiable receipts before execution — mapped to selected AIUC-1, SOC 2, and ISO 27001 control evidence.

### Caveat

> Permission Protocol helps implement selected runtime authorization and auditability controls. It is not a substitute for AIUC-1 certification, SOC 2, or ISO 27001.

### Section: What the receipt proves

- Which agent requested the action.
- What exact action was requested.
- What resource/customer/context was affected.
- What payload or parameters were approved.
- Which policy applied.
- Who approved.
- When approval happened.
- Whether the executed action matched the approved payload.
- Whether the receipt verified.

### Section: Built for security review

- action-level evidence,
- verifier URL,
- exportable receipt,
- control mapping,
- customer-specific policy.

---

## 16. Outreach Findings and Corrections

## Original access plan

Because warm intros were not available, the recommended route became a **credibility-first cold validation campaign**.

The outreach framing should not be:

> “Book a demo.”

It should be:

> “I’m researching how enterprise security review is changing for AI agents that take actions. I’m speaking with founders/operators and will share anonymized findings.”

## Outreach math

To get roughly 8 calls:

- 100 companies,
- 2 people per company,
- 200 first-touch messages,
- 2 follow-ups each,
- roughly 600 total touches over 10 days.

## Contact-list decision

The attempted 200-contact list generated in this chat was not good enough. It contained many generic company emails and some guessed/low-confidence LinkedIn URLs.

Final decision:

- Do **not** guess personal emails.
- Do **not** rely on generic support emails for founder validation.
- Use LinkedIn/X/email only when the contact is public and clearly tied to the target role.
- Where no direct email exists, use LinkedIn connection notes or public company contact forms.
- For personal emails, use a legitimate enrichment tool or manual verification process, not guessing.

A trustworthy contact list should include a confidence score per field:

- verified personal email,
- likely professional email,
- generic company email,
- LinkedIn only,
- company-page only.

Do not send high-volume email to guessed addresses.

---

## 17. Current Best Outreach Process

1. Build a tighter list of 50 companies, not a noisy 200.
2. For each company, identify:
   - founder/CEO,
   - CTO,
   - Head of Product,
   - Head of Enterprise,
   - Trust/Security lead,
   - Field CTO / Solutions lead.
3. Use LinkedIn/X first for founders if no verified email exists.
4. Use company emails only for routing, not primary validation.
5. Track every prospect in a live sheet with:
   - segment,
   - contact,
   - channel,
   - message sent,
   - reply,
   - call score,
   - named pain,
   - next step,
   - willingness to pay.

---

## 18. Final Operating Plan

## Today

1. Freeze strategy: Action Gate primary, Merge Gate secondary.
2. Stop writing strategy docs.
3. Ship/verify real receipt signing.
4. Draft Receipt Format v0.1.
5. Build/refine refund/email/account-change demo.
6. Create a tight prospect tracker.
7. Start outreach with research-first framing.

## Next 72 hours

1. Send 50–100 targeted messages.
2. Get 5–8 listening calls booked.
3. Complete at least 3 calls.
4. Score each call 0–3.
5. Decide whether Action Gate pain is present-tense or still premature.

## Next 7 days

1. Finish Action Gate API skeleton.
2. Finish hosted approval page.
3. Finish signed receipts and verifier.
4. Publish Receipt Format v0.1.
5. Update website hero/platform page.
6. Send first 100–150 outbound touches.
7. Get 8+ qualified conversations.
8. Send 2 pilot proposals.

## By May 14

1. Have one committed or near-committed paid pilot.
2. Have at least 2 SOWs out.
3. Have 25+ receipt events across demos/prospect workflows.
4. Have 3+ exact buyer quotes about runtime evidence, action approval, or security review.

## By June 1

Target:

- 1 paid Action Gate pilot,
- 1 LOI or serious second pilot,
- 3–5 Merge Gate repos/evaluations,
- signed receipts live in 2 environments,
- 50+ authorization/receipt events,
- 5 prospects naming the same pain,
- one case-study-quality quote.

---

## 19. One-Sentence Final Strategy

> **Sell Action Gate as runtime authorization evidence for customer-facing AI-agent companies going through enterprise security review: one high-risk action, one policy, human approval when needed, signed receipt, execution blocked without verification. Keep Merge Gate as the GitHub proof adapter and fallback, not the company thesis.**

---

## 20. Source Basis from Uploaded Drafts and Feedback

This summary consolidates decisions from these uploaded materials and discussion threads:

- PP - Small Primitive.
- PP Stress Test.
- PP - Sell as Partnerships.
- PP - Who to Sell.
- PP - Independent Merge Gate.
- C - GTM Plan.
- C - Feedback 1–4.
- OA - Interview Simulation 1–2.
- C - Interview Simulation 1–2.
- OA/C - AIUC-1 Analysis.
- Live-site review of permissionprotocol.com performed earlier in the chat.
- Outreach/contact-list iterations from the chat.

