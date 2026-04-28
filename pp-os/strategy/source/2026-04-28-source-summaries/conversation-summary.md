# Permission Protocol — Conversation Summary

**Date:** April 28, 2026
**Goal:** Demonstrate strong product-market fit by June 1, 2026
**Status at end of conversation:** Strategy phase closed. Execution phase begins.

---

## 1. What We Learned

### 1.1 The product, decisively

Permission Protocol is a **verifiable receipt layer for AI-agent actions**. Not a protocol pitch, not a governance framework, not approval workflow.

The primitive is a four-step contract:
1. Agent (or CI, or human) requests authorization for a specific action
2. Policy engine returns *allow / deny / approval-required*
3. If approval required, a human signs through a hosted UI; an Ed25519-signed receipt is issued
4. The execution point refuses to proceed without a valid, verifiable receipt

The artifact Permission Protocol owns is **the receipt**, not the approval UI.

Two packaged products share the same primitive:

- **Action Gate** — API + hosted approval flow + signed receipt verifier for agent companies. Sold as $7,500 30-day pilot to gate one real action end-to-end.
- **Merge Gate** (was Deploy Gate) — GitHub App that adds a required check on AI-authored PRs touching configured production paths. Free / $99 / $299 / $1,500 tiers.

### 1.2 The market premise was confirmed

After eight rounds of analysis, the central premise is supported by named, public, recent evidence:

- **Phil Venables** (former Google Cloud CISO): *"We need a SOC 2 for AI agents."*
- **AIUC-1 standard** published Feb 25, 2026 by JP Morgan, Salesforce, MongoDB, Oracle, Brex, Databricks, Confluent, Elastic, UiPath, Deutsche Börse, Department of War. Schellman as accredited auditor. Q2 2026 update specifically strengthened agent identity controls (A003.3, A003.4) — written almost as if for this product category.
- **Ric Smith** (Okta CTO): *"Where are my agents, what can they connect to, and what can they do?"*
- **Cloud Security Alliance** (Apr 2026): 53% of organizations report agents exceeding intended permissions; 82% of enterprises have unknown AI agents in environments; 65% reported AI-agent-related incidents in past year.
- **Vendr measured data:** AI products take 21% longer to buy than non-AI on the same platform (Q2 2024). Net-new SaaS buying cycles up 37% over three years.
- **Conveyor:** 3.1-week average security review per deal; 52% of sales teams say reviews delay deals.
- **Whistic 2025 TPRM Impact Report:** TPRM teams now spending 37.4 hours/week on assessments, up 14 hours YoY.
- **Gravitee:** only 14.4% of deployed agents went live with full security/IT approval.
- **Vanta State of Trust 2025:** "Only 48% have a framework for granting or limiting autonomy"; "agentic AI use is outpacing understanding."

### 1.3 The two-layer security review model

Buyer mental model that emerged from the simulations:

- **Layer 1 — classical SaaS controls** (SOC 2, ISO 27001, DPA, encryption, SSO). Vanta / Conveyor / HyperComply already collapse this with claimed 70–81% time reductions.
- **Layer 2 — agent-specific authorization** (what the agent can connect to, what it can do, runtime authorization, action-level audit trails). **No one has collapsed this yet.**

Permission Protocol's wedge is Layer 2. Vanta and Conveyor are not competitors — they're the case-study analogs that prove the buyer pays for evidence-collapse vendors.

### 1.4 Permission Protocol implements AIUC-1 (does not conform, mildly extends)

Both independent analyses converged: Permission Protocol implements roughly 8–10 of AIUC-1's ~50 controls, clustered in:

| AIUC-1 Control | What it requires | PP fit |
|---|---|---|
| **B006** — Prevent unauthorized AI agent actions | Contextual access controls | Direct hit, the whole product |
| **A003.3** — Agent identity governance (new Q2 2026) | Cryptographically verifiable agent identities | Each policy binds an agent identity via signature |
| **A003.4** — Permission-ready architecture (new Q2 2026) | Just-in-time permissions, scope/duration limits | Time-bounded, action-scoped sealed permissions |
| **B008** — Caller authentication / message signing | Cryptographic verification across model APIs, MCP, A2A | Cryptographic verification of policy before tool exposure |
| **D003** — Tool call governance | Tool authorization, I/O validation, logging of tool name and parameters | "No tool executes without verified authorization" + audit trail |
| **E015** — Log AI system activity | Tamper-evident logs of agent actions | Signed receipts are stronger evidence than the standard requires |

Public framing: *"Permission Protocol is to AIUC-1 controls B006/A003.3/A003.4/B008/D003/E015 what an MFA provider is to SOC 2's CC6 access controls — a building block, not the certification."*

The one place PP **exceeds** AIUC-1 is cryptographic non-repudiation — third-party offline verifiability that the standard's logging controls don't yet require.

### 1.5 The competitive landscape is more advanced than initially assumed

Every prospective Tier 1 customer is **already shipping approval features**:

- Intercom Fin: "Ask teammate" approvals for refunds, account closures, data deletion
- Sierra: supervisor "observe to intercept" + PCI-compliant agent step-out for payments
- Decagon: "Agent Operating Procedures" with confidence thresholds and human fallback
- Salesforce: trains buyers to define agent boundaries
- Okta: runtime fine-grained access policy product for AI agents shipping today

Implication: the pitch **cannot** be "we add approval workflow." It must be: *"We add the neutral, externally verifiable, auditor-recognized evidence layer on top of whatever approval workflow you've built."*

### 1.6 The compelling event is security review compression, not anticipatory CISO concern

The pain a CFO/CRO writes a check for is **deal velocity slipping in security review**, not a hypothetical future audit. The pitch must lead with measurable cycle-time compression backed by Vendr's 21%, Conveyor's 3.1 weeks, etc.

### 1.7 Strategic bets that were debated and resolved

- **Platform vs. Merge Gate** — Resolved: platform thesis is the company-level bet; Merge Gate is the parallel proof loop. Direct rebrand to "Independ Merge Gate" rejected as a 60-day pivot, not a 30-day one.
- **MCP / action platforms (Composio, Pipedream, Zapier, n8n, Make, LangChain) as ICP** — Rejected. They're peers and infrastructure, not buyers. They will build it themselves.
- **Famous mega-customers (Sierra, Decagon, Salesforce direct) as primary outreach** — Deprioritized. Smaller 10–50 person agent companies in active enterprise sales are easier to reach AND more likely to feel acute pain without brand momentum to coast on.
- **Coding agent companies** — Tier 2, real but slower than customer-facing CX agents.
- **Open receipt spec as defensive moat** — Adopted. Publishing the receipt format as an open Ed25519-signed JSON spec early changes the strategic conversation from "buy our product" to "adopt the standard the ecosystem is converging on."

### 1.8 Critical fragility identified and corrected

- **Overclaiming.** The marketing language ("cryptographic," "signed," "immutable") had outpaced the implementation (JSON-to-stderr). For a security-adjacent product this is a fatal mistake. **Resolution:** ship Ed25519 signing + public verifier by May 5, OR soften every claim to "tamper-evident audit record" until signing ships. Non-negotiable.
- **Warm intro assumption.** The plan repeatedly assumed warm intros that don't exist. Cold-outbound channels (LinkedIn, X, investor backchannel, ex-employee operator network, public AIUC-1 analysis post) are the actual path.
- **Bandwidth realism.** Earlier plans assumed 12–14 hour days. Either OpenClaw and other obligations get quarantined for 30 days, or daily volume scales to 60% with proportionally lower PMF bar.

---

## 2. What We Decided

### 2.1 The pitch (final)

**For customer-facing AI agent companies:**
> "Your agents are starting to take real actions: refunds, account changes, customer emails, subscription updates, data exports. Enterprise buyers are asking how those actions are controlled before they fire — not just logged after. Permission Protocol gives you an Action Gate: policy check, human approval when needed, signed receipt, and receipt verification before execution. We gate one real action in your product so you can prove who authorized what, under which policy, before the action fired. 30-day pilot, $7,500."

**For direct engineering teams:**
> "Your coding agents can create PRs. Most are fine. The dangerous ones touch infra, migrations, auth, billing, deploy workflows, or production config. Merge Gate adds a required GitHub check for those PRs. A human signs the exact change, the receipt is tied to the PR and commit, and the check only passes for that approved version. No receipt, no merge."

**Single sentence:** *We help agent companies prove that high-risk actions were approved before execution — the verifiable evidence layer that compresses enterprise security review at the agent-action layer.*

### 2.2 Who has the pain and will pay

**Tier 1 — Customer-facing AI agent companies**
Required: sells AI agents (not features), agents take write actions, mid-market or enterprise sales motion, prospects asking about approval/audit/authorization, founder-accessible, $7,500 not a procurement event. Verticals: AI customer support, CX/customer ops, ecommerce ops, RevOps/CRM, fintech ops, healthcare admin.

**Tier 2 — AI coding-agent companies with enterprise customers**
Sell external signed receipts for agent-authored code changes and production actions. Slower cycle.

**Tier 3 — Direct AI-native engineering teams (Merge Gate)**
Fallback and parallel proof loop. 10–100 engineer startups using Cursor, Claude Code, Copilot agent, Devin.

**Explicitly NOT targeting in 30 days:** Composio, Pipedream, n8n, Make, Zapier, Workato, LangChain, CrewAI, Salesforce direct, GitHub direct, Atlassian, large enterprise procurement.

### 2.3 The 30-day plan

**Days 1–3 (Apr 28–30) — Validation sprint**
Five listening calls with customer-facing AI agent founders/leads. Script: *"Without me pitching anything, what's the hardest question you're getting from enterprise prospects about what your agent is allowed to do?"* Score each 0–3.

**Decision rule (Apr 30 evening):**
- 3+ calls score 2 or 3 → **Action Gate sprint** — 70% Action Gate / 20% Merge Gate / 10% spec & content
- 0–1 calls score 2 or 3 → **Merge Gate sprint** — pivot to direct, accept smaller-but-real PMF
- Exactly 2 → run both 10 days, force decision May 10

**Plan B trigger (May 14):** if no money or integration commitment, shift to 50/50.
**Plan C trigger (May 20):** if no paid pilot or LOI, June 1 PMF story pivots fully to Merge Gate evidence.

### 2.4 Build list (Week 1, regardless of validation outcome)

1. **Receipt Format v0.1** — public JSON schema, Ed25519 signature, payload_hash, policy_id, policy_version, actor, action, resource, decision, signer, created_at, expires_at, signature, key_id. Include explicit field mappings to SOC 2 CC6.1, ISO 27001 A.9.4, GDPR Article 6, AIUC-1 B006/A003.3/A003.4/D003/E015.
2. **Public verifier page** at `/r/<receipt_id>` — valid/invalid, signed by whom, action approved, payload hash, policy, timestamp, expiry status.
3. **Refund/email demo** — draft email allowed → send email approval required → refund $50 allowed → refund $500 approval required → refund $5,000 denied. Approval creates signed receipt; execution requires verification.
4. **Honest claim audit** — every "cryptographic"/"signed"/"immutable" claim either backed by shipped signing or softened to "tamper-evident audit record." Done by May 5.
5. **AIUC-1 implementation paragraph** on homepage and `/platforms` pages.
6. **Open-spec GitHub repo** for Receipt Format v0.1 — defensive moat against Composio/Descope/etc. self-build.

### 2.5 Don't-Build list (sacred, no exceptions)

SAML, SCIM, self-hosting, advanced policy language, Slack approval flow, MCP adapter polish, dashboard, audit exports, enterprise admin UI, marketplace polish, rebrand, more strategy docs.

### 2.6 June 1 PMF bar

**Strong PMF (defensible to investors):**
- 1 paid Action Gate pilot ($7,500 invoiced)
- 1 coding-agent or customer-agent LOI
- 3–5 Merge Gate paying/evaluation repos
- Signed receipts live in two real customer environments
- 5 prospects repeating the same pain in their own words

**Plan-B PMF (Merge Gate path):**
- 10–15 paying/evaluation Merge Gate repos
- 50+ gated PR decisions
- 25+ signed receipts issued
- 5 teams articulating the same pain

### 2.7 The outreach motion (since warm intros don't exist)

**80 cold contacts total, sent in next 4 hours:**
- 50 LinkedIn DMs to founders/CTOs/product leads at customer-facing AI agent companies (10–50 person, weighted CX/support, smaller-than-famous), under 300-character invite limit, each with one specific personalization hook
- 10 outreach to VC partners with portfolio-specific hooks asking for portfolio intros (Sonya Huang, Sarah Tavel, Sarah Wang, Anjney Midha, Andrew Reed, Saam Motamedi, Aaref Hilaly, Caryn Marooney, Lucas Swisher, Aaron Jacobson [substitute for Vanessa Larco who left NEA])
- 20 LinkedIn DMs to ex-employees of Decagon/Sierra/Crescendo/Forethought/Ada/Gorgias/Maven AGI/Lorikeet/Cresta/Replicant/PolyAI/AptEdge/Intercom Fin/Salesforce Agentforce/Zendesk AI — Trust/Security/Enterprise AE/Founding Eng roles, departed 2024–2025

**Realistic conversion math:** 80 cold sends → 6–12 booked calls. Beats the ≥5 validation goal. Apollo/Clay enrichment to verified emails (~$50, 1 hour) roughly doubles that.

**AIUC-1 LinkedIn/X post published tonight:** raises every channel's conversion rate and seeds inbound for the next 30 days.

### 2.8 What I (Claude) refuse to do this week

- No more strategy docs
- No more competitor analyses
- No more pitch variants
- No more simulated interviews
- No more framework comparisons

If Rod returns Thursday evening with call notes and scores, help commit to the path the data picks and execute the May 1 sprint with conviction.

---

## 3. The Single Sentence

**Permission Protocol is the verifiable receipt layer for AI-agent actions — the runtime implementation of AIUC-1 controls B006/A003.3/A003.4/D003/E015 — sold as a $7,500 30-day Action Gate pilot to customer-facing AI agent companies whose enterprise prospects are slowing deals at the agent-action layer of security review; the 30-day path is validate the buyer pain in 5 cold-sourced listening calls by April 30, ship Ed25519 signing + public verifier + open receipt spec by May 5, and convert 1+ paid pilot + 1+ LOI + 3–5 Merge Gate paying repos by June 1.**

---

## 4. Open Questions That Will Be Answered by Action

These cannot be resolved by more analysis; only by execution.

1. Does a real customer-facing AI agent founder, on a real call, name pre-execution authorization as an active procurement blocker? *(Answered by: 5 calls Apr 29–30.)*
2. Does the audit-evidence framing ("SOC 2 for AI agents," AIUC-1 mappings) land harder than the approval-workflow framing? *(Answered by: which framing draws follow-up engagement on the calls.)*
3. Will an AIUC-1 consortium member partner on positioning, or treat Permission Protocol as a peripheral implementation? *(Answered by: outreach to AIUC-1 organizers in Week 1.)*
4. Can the Action Gate sales cycle compress to 30 days with cold-sourced pipeline? *(Answered by: May 14 milestone — 1 paid pilot or strong co-build commitment.)*
5. If validation fails, does Merge Gate direct generate 10–15 paying repos by June 1? *(Answered by: HN/PH/Marketplace launch in Week 1 if Plan B activates.)*

---

*End of summary.*
