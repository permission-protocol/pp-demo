# Response to Request for Information: Security Considerations for Artificial Intelligence Agents
## Docket NIST-2025-0035 | National Institute of Standards and Technology
**Submitted by:** Permission Protocol  
**Organization:** [TODO-ROD: Legal entity name]  
**Contact:** [TODO-ROD: Name, email, phone]  
**Submission Date:** [TODO-ROD: Date on or before March 9, 2026]  
**Submission Method:** regulations.gov, Docket NIST-2025-0035

---

> **Document Status:** Full draft — ready for Rod's review and strategic additions.  
> Skeleton file: `nist-rfi-skeleton.md` | Issue #242 | Drafted March 2, 2026  
> [TODO-ROD] sections marked throughout require your review before submission.

---

## Executive Summary

The core security gap in AI agent systems is not monitoring or detection — it is **authorization**. In most production deployments today, there is no cryptographically verifiable answer to the fundamental question: *was this action explicitly approved before it executed?*

Permission Protocol provides authorization infrastructure for autonomous AI systems. Our foundational contribution — the **cryptographic authorization receipt** — creates an immutable, signed, timestamped record of every authorized action *before* that action executes. The enforcement model is binary: no receipt, no action. This is not a monitoring layer or audit tool; it is **pre-action enforcement infrastructure** that operates independently of the AI model, is cryptographically tamper-evident, and cannot be circumvented by a compromised agent.

Our reference implementation, **Deploy Gate**, operationalizes this for software deployment pipelines. Integrated as a GitHub Actions required status check, Deploy Gate blocks every deployment until a valid cryptographic receipt exists — bound to the specific commit SHA, target environment, and authorized principal. Signed using Ed25519, timestamped per RFC 3161, anchored to an append-only ledger. Enforcement is fail-closed.

The empirical case is documented. The OpenClaw crisis of February 2026 — 42,665 publicly exposed agent instances, 93.4% with critical authentication bypass vulnerabilities, 6 CVEs in a single month — is the first large-scale exploitation of the authorization vacuum in deployed AI agent systems. Agents operated in production with full tool access and no mechanism for principals to verify or enforce what actions they were permitted to take. The consequences were public, material, and preventable.

Permission Protocol submits this response to offer a working technical architecture as a concrete reference for NIST's voluntary standards work. We welcome further engagement with the AI Agent Standards Initiative.

---

## 1. Security Threats, Risks, and Vulnerabilities Affecting AI Agent Systems

### 1(a) — Unique Security Threats Distinct from Traditional Software Systems *(Priority)*

**The primary novel threat class:** AI agent systems introduce **unauthorized autonomous action** — consequential real-world actions taken without any external party cryptographically verifying and approving them before execution. This threat class does not exist in traditional software, and traditional controls are architecturally insufficient to address it.

In traditional software, the instruction set is fixed; vulnerabilities exploit known, bounded code paths. AI agents operate differently: the model makes discretionary decisions about *what to do* based on context and objectives. The action space is not fully enumerable at development time, creating threat vectors that do not map onto existing vulnerability taxonomies.

**Threat 1: The Authorization Vacuum**

The most prevalent threat in current production AI agent deployments is the absence of any formal authorization model. The agent decides what to do; scaffolding code executes it. No external party approves the action before execution. Any manipulation of the agent's decision-making — prompt injection, adversarial inputs, goal misalignment — translates *directly* into real-world state changes with no checkpoint.

The OpenClaw crisis provides empirical evidence at scale. A ClawHunter scan in February 2026 identified 42,665 publicly exposed OpenClaw instances; 93.4% carried critical authentication bypass vulnerabilities. Agents had full tool access — file systems, APIs, external services — with no pre-action authorization infrastructure. Cisco described it as "from a capability perspective, groundbreaking; from a security perspective, an absolute nightmare." Six CVEs were disclosed in February 2026 alone. This is an operational failure mode already exploiting deployed systems.

A 2026 survey of 900+ executives and practitioners (Gravitee, "State of AI Agent Security 2026") confirms the authorization vacuum is industry-wide: while 80.9% of technical teams have deployed AI agents into active testing or production, only 14.4% have full security/IT approval for their entire agent fleet. More than half of all deployed agents operate without any security oversight or logging. 88% of organizations reported confirmed or suspected AI agent security incidents in the past year — rising to 92.7% in healthcare. These figures validate that the authorization vacuum is not a theoretical concern; it is an already-operational failure mode affecting the majority of enterprises deploying AI agents today.

**Threat 2: Self-Authorization**

Where the model has tool access without external enforcement, it effectively authorizes its own actions. System prompt instructions describe intended behavior but no external party enforces constraints at execution time. Under adversarial pressure — prompt injection, instruction hierarchy violations, or novel situations — the model may deviate, and no enforcement gate stops execution.

In multi-agent contexts, this compounds: a compromised agent can instruct sub-agents, propagating unauthorized authority through the agent graph.

**Threat 3: Receipt-Free Audit Trails**

Post-hoc logging records what actions occurred, not whether they were authorized before execution. A log entry showing "agent deployed commit abc123 to production at 14:32:07 UTC" is indistinguishable from a legitimately authorized deployment and an unauthorized one. Without a pre-action receipt, organizations cannot answer "was this action authorized?" with cryptographic certainty — only "did it occur?" These are fundamentally different questions.

**Threat 4: Scope Creep Without Enforcement**

Agents frequently operate with scope defined by system prompt instructions — probabilistic controls that do not prevent out-of-scope actions under adversarial conditions. There is no technical enforcement layer that blocks a code-deployment agent from also sending email if the underlying tool access exists.

Permission Protocol addresses these threats architecturally. The receipt model requires authorization to exist *outside* the agent. Receipts are cryptographic evidence, not logs. The enforcement model is binary: no receipt blocks execution. The scope field in every receipt precisely defines what action was authorized, preventing scope expansion.

---

### 1(b) — Variation by Deployment Method, Capability, and Use Case

Threat severity scales with deployment dimensions, with **financial services and federal government** presenting the most acute risk profiles:

**Model capability and blast radius:** More capable models with broader tool access create larger blast radii when misused. An agent that can deploy code, send email, browse the web, and modify databases represents a much larger attack surface than a narrowly scoped agent. Each tool access class is a distinct action category requiring its own authorization policy and receipt scope.

**Financial services deployments** represent the highest consequence density: agents executing trades, processing transactions, or modifying ledger entries without cryptographic pre-authorization create SOX and OCC compliance exposure that no post-hoc log can remediate. **Federal government deployments** carry the additional dimension that NIST has direct standards authority — a pilot demonstrating receipt-based authorization in federal AI agent systems would generate precedent with immediate regulatory weight.

**Healthcare deployments** present the same structural gap (agent actions affecting patient records or clinical decision support without pre-authorization) but operate under a more complex regulatory surface (HIPAA, FDA) with longer adoption timelines.

**Externally-deployed agents** operating on behalf of end users present compounded authorization complexity: the agent must be authorized by the deploying organization *and* act within bounds acceptable to each individual user — a layered structure requiring explicit modeling.

**Multi-agent orchestration:** As discussed in Section 1(e), multi-agent systems introduce authority propagation challenges absent in single-agent deployments.

---

### 1(c) — Security Risks as Adoption Barriers

The authorization gap is creating measurable friction in enterprise AI agent adoption:

The Gravitee "State of AI Agent Security 2026" report (900+ executives) found adoption is outpacing governance controls — fewer than half felt confident their agent deployments could pass a compliance review focused on agent behavior.

Strata's "AI Agent Identity Crisis" research identified authorization for non-human actors as a primary blocker in regulated industries where audit trail requirements are legally mandated.

The OpenClaw crisis directly suppressed deployment: following February 2026 disclosures, multiple large enterprises suspended agent-to-production deployments pending security reviews.

The absence of clear standards creates decision paralysis for organizations that want to implement responsible governance but have no authoritative framework. A NIST voluntary guideline establishing authorization infrastructure requirements would directly reduce adoption friction. PP's architecture is designed to be that reference.

---

### 1(d) — Threat Evolution Over Time *(Priority)*

**Current state (2026):** The authorization vacuum dominates. Most production AI agent systems operate without formal external authorization infrastructure. The OpenClaw crisis represents the first large-scale exploitation of this gap at scale, but it will not be the last. The threat is already materializing faster than the governance infrastructure needed to address it.

**Near-term (2026–2027):** Proliferating agentic frameworks (OpenAI Agents SDK, Anthropic MCP, open-source orchestrators) will dramatically increase agent-to-agent interactions. Each communication is an authorization surface. Without receipt infrastructure, a single compromised root agent propagates unauthorized authority through arbitrarily large sub-agent graphs.

**Medium-term (2027–2029):** Persistent, long-horizon agents introduce temporal authorization challenges. A decision at session initiation may govern actions executed days later. Time-bounded receipts with expiration and revocation are required; static prompt-based authorization is architecturally incompatible.

**Structural risk:** Without external authorization, the sole check on agent behavior is the model itself — opaque, version-dependent, unable to provide cryptographic guarantees. This is financial systems without ledgers: trust without verification. PP's receipt architecture scales with agent complexity because enforcement is model-independent.

---

### 1(e) — Multi-Agent System Threats

Multi-agent orchestration introduces the **authority propagation problem**: when a root agent delegates to sub-agents, what authorization do they carry? In current implementations: "whatever the scaffolding grants" — no formal model, authority expanding arbitrarily through delegation.

Key threat vectors: **Unauthorized delegation** (compromised root instructs sub-agent to exceed its scope), **authority laundering** (delegation chains obscure authorization provenance), and **orchestrator compromise** (hub-and-spoke architectures propagate unauthorized authority to all sub-agents simultaneously).

**PP's response:** Receipts are per-action, not per-session. Each action in a multi-agent chain requires its own receipt, referencing its parent receipt. Authority propagation is explicit, auditable, and bounded — no agent can grant more authority than its own receipt documents.

---

## 2. Security Practices for AI Agent Systems

### 2(a) — Technical Controls for Security *(Priority)*

**The foundational principle:** Controls inside the agent — system prompts, fine-tuning, instruction hierarchies, refusal training — are necessary but architecturally insufficient as primary controls for high-consequence deployments. A sufficiently capable model under adversarial conditions can be induced to violate internal constraints. External enforcement — operating independently of, and without the cooperation of, the model — is required.

NIST guidelines should distinguish two qualitatively different control categories:

**Tier 1 — External Authorization Infrastructure (deterministic controls)**

Require cryptographic authorization before any action with external state effects. Permission Protocol's implementation:

1. **Pre-action authorization request:** Before any externally-effecting action, the agent calls the PP authorization API with: action type, target scope, action parameters, principal identity, and session context.

2. **Policy evaluation:** PP evaluates against configured policy — action class permitted, scope within bounds, and whether consequence level requires human countersignature. High-consequence actions (production deployment, financial transactions) require human approval before a receipt is issued.

3. **Cryptographic receipt issuance:** On approval, PP issues an Ed25519-signed receipt over a canonicalized JSON payload including: `id`, `companyId`, `agentId`, `requestId`, `status`, `riskTier`, `policyVersion`, `scope`, `createdAt`, `expiresAt`. Scope binding ensures the receipt authorizes *exactly* the requested action — a receipt for `commitSha: a81f2c3e` cannot authorize any other commit; a staging receipt cannot authorize production deployment.

4. **Enforcement gate:** The action executor validates the receipt via the PP verification API. Absent, expired, revoked, or scope-mismatched receipts return `verified: false` and block execution. Fail-closed: the default state is denial.

5. **Ledger entry:** Every receipt creation, verification attempt, and redemption is recorded in an append-only ledger. Records cannot be modified. Single-use redemption is enforced.

**Deploy Gate as working reference implementation:**

```yaml
- name: Verify Deploy Authorization
  uses: permission-protocol/verify-action@v1
  with:
    api-key: ${{ secrets.PP_API_KEY }}
    scope: |
      {
        "scopeType": "GIT_REF_COMMIT",
        "repo": "${{ github.repository }}",
        "ref": "${{ github.ref }}",
        "commitSha": "${{ github.sha }}",
        "env": "production",
        "capability": "deploy:production"
      }

- name: Deploy to Production
  if: success()
  run: ./deploy.sh production
```

If the verification step fails — for any reason including network failure — the deploy step does not execute. GitHub's required status check enforces this at the repository level; no individual developer, regardless of write access, can bypass a failing required status check without modifying branch protection rules. The receipt is bound to the specific commit SHA and environment; a staging receipt cannot pass production verification.

**Tier 2 — System-Level Controls (defense-in-depth)**
- Least-privilege tool scoping, enforced at infrastructure layer (not model layer)
- Sandboxed execution with explicit egress controls
- Network-level access controls on tool endpoints
- Human approval gates before receipt issuance for high-consequence actions

**Tier 3 — Model-Level Controls (probabilistic, necessary but insufficient)**
- Prompt injection hardening and input sanitization
- Instruction hierarchy enforcement
- Anomaly detection on action request sequences
- Output filtering and refusal training

**Critical point for NIST standards:** Tiers 2 and 3 reduce probability of unauthorized action but cannot prevent it under sufficiently adversarial conditions. Only Tier 1 — external authorization with cryptographic enforcement — provides deterministic protection. NIST standards for high-consequence deployments should require Tier 1 controls, not treat all control types as equivalent.

---

### 2(b) — Effectiveness Variation by Deployment Context

External authorization controls (Tier 1) maintain their effectiveness across all model capability levels because they operate *independently* of the model. The enforcement gate requires a valid receipt regardless of what the model "decides." This is qualitatively different from Tier 3 controls, which become less effective as model capability increases — a more capable model is more effective at constructing plausible rationales for violating constraint instructions.

For NIST standards purposes, this implies a tier-dependent capability threshold. Organizations deploying high-capability models for high-consequence actions should be required to implement Tier 1 controls; the efficacy of Tier 3-only approaches degrades precisely where the stakes are highest.

---

### 2(c) — Future Evolution Requirements

As agent autonomy increases and action horizons extend:

- Authorization scope must become increasingly granular. "Can deploy code" is insufficient; scope must include which code, to which environment, at what time, with what rollback provisions.
- Time-bounded receipts with explicit expiration are required for long-horizon agent sessions. A receipt issued for a deployment operation that will be executed in 48 hours must have a validity window that expires before the next scheduled review cycle.
- Delegation chains must be explicitly tracked, with each sub-agent receipt referencing its parent authorization. The full authority chain must be verifiable at any point without trusting any single agent's self-report.

PP's receipt schema is designed to accommodate these requirements. The `expiresAt` field is mandatory and covered by the Ed25519 signature — it cannot be modified without invalidating the receipt. Scope types are extensible; `GIT_REF_COMMIT` and `PR_HEAD` are current implementations, with additional scope types under active development.

---

### 2(d) — Patching and Update Considerations

A critical gap in current agent security practice: authorization policy embedded within the model (via fine-tuning or system prompts) changes with every model update. An organization that deploys a new model version may be silently changing its authorization behavior without any review process. External authorization infrastructure must be independent of the model component to remain stable and auditable across model version changes. PP's enforcement layer operates at the infrastructure layer; it is model-agnostic by design. Updating the underlying model does not affect receipt issuance policy, enforcement behavior, or ledger integrity.

---

### 2(e) — Relevant Frameworks and Standards *(Priority)*

**Existing frameworks and their alignment with PP's architecture:**

**NIST AI RMF (AI 100-1):** PP's receipt model maps directly to the Govern, Map, and Manage functions. The receipt ledger operationalizes "GOVERN 6.2" (policies and procedures in place) and "MANAGE 3.2" (AI system response is monitored). The pre-action authorization gate operationalizes "secure and resilient" across all functional areas.

**NIST AI 600-1 (Generative AI Profile):** Human oversight before high-consequence actions is implemented as a mandatory approval step before receipt issuance; the receipt itself is the accountability artifact the profile specifies.

**NIST SP 800-207 (Zero Trust Architecture):** PP's "no receipt, no action" model is Zero Trust applied to the AI agent action layer. As Zero Trust requires verification of every network request, PP requires verified pre-authorization for every agent action with external state effects.

**NIST SP 800-53 Rev. 5 control mapping:**
| Control | PP Implementation |
|---|---|
| AC-3 (Access Enforcement) | Receipt required before action execution; absent receipt blocks action |
| AC-6 (Least Privilege) | Scope binding in receipt limits action to exact authorized parameters |
| AU-2 (Event Logging) | Append-only ledger captures all receipt events with full metadata |
| AU-9 (Protection of Audit Information) | Ed25519 signatures make ledger entries tamper-evident |
| AU-10 (Non-repudiation) | Signed, timestamped, ledger-anchored receipt provides legal non-repudiation |
| IA-2 (Identification and Authentication) | `principal.agent_id` and `principal.actor_id` in every receipt |
| SI-7 (Software, Firmware, and Information Integrity) | Receipt binds to commit SHA, preventing authorization of modified artifacts |

**NIST SP 800-218A:** Deploy Gate addresses software supply chain security directly — the receipt bound to a specific commit SHA ensures an authorization for one artifact cannot authorize deployment of a different artifact.

**Adoption barriers:**
- No standardized interface or schema for agent authorization requests; every deployment requires custom integration
- Absence of NIST guidance creates decision paralysis for risk-averse deployers

Deploy Gate requires one GitHub Action step and a PP API key — under two minutes per repository, with immediate compliance value from the first receipt.

---

## 3. Assessing the Security of AI Agent Systems

### 3(a) — Identifying Threats During Development and Testing *(Priority)*

Current assessments focus on code vulnerabilities, model robustness, and data access controls — but do not evaluate whether external authorization infrastructure exists at all. An agent with hardened prompts and strict access controls remains insecure if any model exploitation translates directly to unauthorized action.

**Proposed assessment framework:**

1. **Receipt coverage audit:** For each action class (via tool surface enumeration), does a pre-action receipt requirement exist? Unmapped actions are unprotected.
2. **Receipt chain integrity:** In multi-agent systems, does each action trace back to a human principal through verifiable receipts?
3. **Enforcement gap analysis:** Can any externally-effecting action execute without receipt verification? Including error handlers, fallbacks, and admin overrides.
4. **Scope constraint verification:** Do receipts bind to specific parameters (commit SHA, environment), not just action type?
5. **Expiration and revocation testing:** Are expired/revoked receipts rejected? PP returns distinct error codes: `RECEIPT_EXPIRED`, `RECEIPT_REVOKED`, `SIGNATURE_INVALID`, `SCOPE_MISMATCH`, `RECEIPT_NOT_FOUND`.

---

### 3(b) — Assessing a Specific Agent System *(Priority)*

Not all threats apply uniformly. Assessment depth and required controls should scale with:

**Action surface:** What external state effects can this agent cause, and what is the consequence classification of each? (Code deployment to production vs. staging; financial transactions above vs. below threshold; customer-facing communications vs. internal notifications)

**Authorization coverage:** For each action class, is there a receipt requirement? Coverage gaps are direct risk indicators.

**Agent identity and attribution:** Is each agent instance cryptographically identifiable? Can any action be attributed to a specific agent instance with confidence? PP's receipt schema includes `agentId`, `companyId`, and session context in every signed receipt, enabling precise attribution.

**Consequence classification and receipt requirements:** The `riskTier` field in PP receipts (e.g., `TIER_1` for production deployments) allows policy-driven escalation. High-risk-tier actions require additional approval steps before receipt issuance; low-risk-tier actions may be auto-approved subject to rate limits and scope constraints.

**NIST threshold recommendation:** The presence or absence of external authorization infrastructure should be treated as a binary threshold criterion in NIST assessment guidelines, not as one factor among many. An agent system with no receipt model fails the baseline regardless of the quality of its other controls. External authorization is a necessary condition for high-consequence deployment, not an optional enhancement.

---

### 3(c) — Upstream Developer Documentation

Model cards and system cards should include explicit documentation of:
- The complete action surface: every tool the model or agent can use, with a description of the external state effects each tool can produce
- Known prompt injection vulnerabilities and mitigations
- Recommended authorization controls for each action class, including whether PP receipt requirements are supported
- The authorization infrastructure the system is designed to work with

PP can contribute to this ecosystem by publishing standardized receipt schemas per action class — effectively a machine-readable "authorization profile" that agent developers can publish alongside model cards, indicating which action classes are covered by PP's receipt model and what scope types are supported.

---

### 3(d) — User-Facing Documentation

Current user-facing documentation for AI agent systems is sparse and inconsistent regarding authorization behavior. A PP receipt-based system inherently generates user-accessible deployment documentation: the receipt ledger is a timestamped record of every authorized action, readable by compliance teams and auditors. The receipt itself functions as a plain-language commitment: "Action X was authorized by Principal Y at Time Z, for Scope S, with policy Policy P." This is documentation that cannot be retroactively altered.

---

## 4. Limiting, Modifying, and Monitoring Deployment Environments

### 4(a) — Constraining Agent Deployment Environments *(Priority)*

The most robust constraint mechanism is the authorization layer itself. If PP issues receipts only for permitted action types within permitted scope boundaries, the agent cannot execute out-of-scope actions regardless of what the model decides.

**Scope constraint mechanisms:**

- **Action class allowlisting:** Only explicitly permitted action types receive receipts. Default state is denial (whitelist, not blacklist).
- **Scope binding:** Receipts bind to exact parameters — `GIT_REF_COMMIT` includes commit SHA, repository, environment, capability. A receipt for one parameter set cannot authorize a different set.
- **Environment separation:** Staging and production signers are independent; staging receipts cannot pass production verification. Boundaries are cryptographic, not policy-based.
- **Rate limits and action budgets:** Per-session budgets trigger human escalation when exceeded, preventing runaway behavior.
- **Context-aware authorization:** Dynamic policy can require human approval for first-time actions, high-value targets, or off-hours execution.

Deploy Gate enforces these via GitHub required status checks — non-bypassable at the repository level, even by administrators.

---

### 4(b) — Rollback and Negation Capabilities for Unwanted Actions *(Priority)*

PP receipts provide the foundational precondition for rollback: an immutable record of exactly what was authorized, with what parameters, by whom, and when. On incident detection, the `receiptId` identifies exact action parameters; the revocation signal (`RECEIPT_REVOKED`) propagates to dependent systems; rollback operations reference the original receipt to identify the state change to reverse.

**Limitation:** Reversal depends on the reversibility of the underlying state change. PP provides identification infrastructure; the reversal mechanism is application-specific.

**NIST recommendation:** Rollback capability should be tiered by consequence level. At minimum, every externally-effecting action should generate an immutable record sufficient to identify and (where feasible) reverse the action.

---

### 4(c) — Interactions with Counterparties

The PP receipt model most directly addresses authentication and source code integrity (counterparty interaction categories iv and v per NIST's framing). Deploy Gate targets the source code deployment interface specifically, binding authorization to a cryptographic artifact identifier (commit SHA) rather than a human-readable description of the artifact.

For multi-agent interactions: when Agent A calls Agent B, the authority chain model requires Agent B's receipt to reference Agent A's authorization. This makes the authority propagation explicit and auditable in the ledger.



---

### 4(d) — Monitoring Deployment Environments *(Priority)*

The receipt ledger generates monitoring signals as a side effect of authorization — qualitatively different from traditional logging:

- **Authorization-aware:** Records what was *authorized*, not just what *happened*. The delta between authorized and executed actions is the critical security signal.
- **Attempted action visibility:** Denied requests are security events; patterns of denials reveal reconnaissance.
- **Agent-agnostic:** Consistent coverage regardless of model, framework, or orchestration tool.
- **Tamper-evident:** Ed25519 signatures + append-only semantics prevent retroactive alteration.

**Anomaly detection signals:** Unusual action sequences, timing anomalies, scope boundary probing (incrementally expanding scope requests), and volume spikes. Receipt ledger infrastructure is operational in Deploy Gate; advanced anomaly detection is in active development.

---

### 4(e) — Open Internet Deployment

The authorization vacuum is most acute for agents deployed at internet scale, where the principal population is large, the action surface is broad, and human oversight per-action is infeasible. PP's receipt model scales to this context: authorization decisions are made by policy, not by individual human review of every action, with human escalation triggered by risk tier and anomaly detection. The ledger provides accountability infrastructure that enables post-hoc review at scale.

---

## 5. Additional Considerations

### 5(a) — Tools and Resources for Rapid Adoption

Authorization infrastructure must install like a dependency, not a compliance program. Deploy Gate requires: one GitHub Actions step, one secret (`PP_API_KEY`), one branch protection rule. Two-minute setup, immediate compliance value from the first receipt.

**NIST opportunities to accelerate adoption:**

1. **Reference implementation recognition:** Naming the authorization receipt pattern in voluntary guidelines legitimizes adoption for risk-averse enterprises and regulated industries.

2. **Standardized receipt schema:** A NIST-published JSON schema — analogous to RFC 7519 (JWT) — enables interoperability and prevents proprietary lock-in. PP's schema (Appendix A) could serve as the basis.

3. **SP 800-53 mapping:** Explicit mapping of receipt controls to AC, AU, IA, SI families enables FISMA and FedRAMP compliance use.

4. **Safe harbor framework:** Organizations implementing certified authorization infrastructure with demonstrated receipt coverage should receive safe harbor from AI-related liability. The financial system provides precedent: anti-fraud controls reduce liability exposure. Without positive incentives, the market won't self-correct — authorization failure costs are externalized to users while implementation costs fall on deployers.

---

### 5(b) — Priority Areas for Government Engagement

Based on our technical analysis and the current state of the market, we suggest NIST prioritize:

1. **External authorization as a threshold requirement for high-consequence deployments:** NIST voluntary guidelines should establish that AI agent systems taking high-consequence actions (production code deployment, financial transactions above defined thresholds, infrastructure modifications, externally-sent communications) require external authorization infrastructure with cryptographic receipt issuance. We recognize NIST's role is voluntary standards, not mandates — but the economic case for eventual regulatory adoption is clear: the cost of authorization failures is externalized to users and counterparties, while the cost of implementing authorization infrastructure is borne by deployers. The market will not self-correct under these incentive conditions. NIST establishing external authorization as a voluntary baseline creates the gravity that pulls adoption forward without requiring a crisis to force it.

2. **Receipt interoperability standard:** A standardized protocol and schema for AI agent authorization receipts would enable portability across authorization infrastructure providers, prevent proprietary lock-in, and create a level playing field. Analogies exist in mature ecosystems: JWT for identity tokens, certificate transparency logs for TLS certificates, software bill of materials for supply chain. AI agent authorization receipts should have the same standardized foundation.

3. **Federal pilot program:** A NIST-coordinated pilot implementing receipt-based authorization in federal agency AI agent deployments would generate real-world data on implementation friction, receipt schema requirements, and compliance utility — informing future guidelines with empirical rather than theoretical evidence. Federal deployments are the ideal proving ground: the regulatory surface is well-defined, NIST has direct standards authority, and success creates precedent that accelerates private-sector adoption.

---

### 5(c) — Research Priorities

Urgent research gaps identified through PP's development:

1. **Receipt schema standardization:** What fields are legally and technically sufficient across action classes and regulatory regimes (HIPAA, SOX, FISMA)? Minimum viable schema exists; regulatory-specific requirements have not been formally specified.

2. **Multi-agent authority propagation:** Formal models for authorization propagation through delegation chains without authority escalation. PP's per-action receipt model is an operational answer; formal adversarial analysis would strengthen the standard.

3. **Receipt-based rollback:** Standardized reversal mechanisms for common action classes using receipt records.

4. **Authorization performance at scale:** Latency budgets for high-frequency agent actions; caching and pre-authorization models consistent with security guarantees.

5. **Adversarial robustness of authorization infrastructure:** Failure modes when the authorization service itself is targeted — DoS resilience, key compromise recovery, ledger integrity.

---

### 5(d) — International Approaches

The EU AI Act (Regulation 2024/1689) establishes traceability and logging requirements for high-risk AI systems under Article 12, and human oversight requirements under Article 14. These are directionally aligned with PP's receipt model but differ in a critical architectural dimension: the EU framework specifies post-hoc logging and human review capability, while PP's model requires *pre-action* authorization. An agent can generate a comprehensive post-hoc log of every action it took without any of those actions having been pre-authorized.

NIST has an opportunity to set a technically more rigorous standard than the EU baseline by specifying pre-action authorization (not merely post-hoc logging) as the appropriate control for high-consequence autonomous action. This distinction is architecturally fundamental: logging records what happened; authorization receipts prove what was permitted before it happened.

The United Kingdom's AI Safety Institute has similarly focused on post-deployment evaluation rather than pre-action authorization infrastructure, representing the same architectural gap.

---

### 5(e) — Cross-Disciplinary Insights

Three mature systems independently arrived at the same architecture PP applies to AI agents: **Financial systems** (every transaction requires authorization, generates a receipt, settles against an append-only ledger), **blockchain** (transaction hashes as receipts, tamper-evident ledger, external validation), and **certificate transparency** (append-only logs making unauthorized issuance detectable). No payment system operates on trust-the-actor. AI agent authorization should have the same property.

NIST has an opportunity to codify these insights before a second-generation crisis — affecting higher-consequence action classes than OpenClaw — makes the gap undeniable at greater cost.

---

## Appendix A — Technical Architecture

### Deploy Gate: Reference Implementation

```
┌───────────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                               │
│                                                                   │
│  Developer Push → GitHub PR → [REQUIRED STATUS CHECK: GATE]      │
│                                         │                         │
│                              ┌──────────▼──────────┐             │
│                              │  Permission Protocol │             │
│                              │   Authorization API  │             │
│                              └──────────┬──────────┘             │
│                                         │                         │
│                          ┌──────────────▼──────────────┐         │
│                          │      Policy Evaluation       │         │
│                          │  • Action class permitted?   │         │
│                          │  • Scope within bounds?      │         │
│                          │  • Risk tier assessment?     │         │
│                          │  • Human approval required?  │         │
│                          └──────────────┬──────────────┘         │
│                                         │                         │
│                    ┌────────────────────▼────────────────────┐   │
│                    │        Cryptographic Receipt             │   │
│                    │  id: "rcpt_7f3d8a2e..."                  │   │
│                    │  scope.commitSha: "a81f2c3e..."          │   │
│                    │  scope.env: "production"                 │   │
│                    │  signature.algorithm: "Ed25519"          │   │
│                    │  signature.keyId: "key_prod_001"         │   │
│                    │  expiresAt: "2026-03-02T14:30:00Z"       │   │
│                    │  [append-only ledger entry]              │   │
│                    └────────────────────┬────────────────────┘   │
│                                         │                         │
│              verified: true  → GitHub status check PASSES        │
│              verified: false → Merge BLOCKED (fail-closed)        │
└───────────────────────────────────────────────────────────────────┘
```

### Receipt Payload Structure (Current Specification)

```json
{
  "id": "rcpt_7f3d8a2e...",
  "companyId": "comp_abc123",
  "version": "1.0",
  "status": "APPROVED",
  
  "scope": {
    "scopeType": "GIT_REF_COMMIT",
    "repo": "org/service",
    "ref": "refs/heads/main",
    "commitSha": "a81f2c3e9b4d5f6a7b8c9d0e1f2a3b4c5d6e7f8a",
    "env": "production",
    "capability": "deploy:production"
  },
  
  "agentId": "agent_deploy_bot",
  "requestId": "req_5c2a...",
  "policyVersion": "v2024.1",
  "riskTier": "TIER_1",
  
  "createdAt": "2026-03-02T10:30:00Z",
  "expiresAt": "2026-03-02T12:30:00Z",
  
  "signature": {
    "algorithm": "Ed25519",
    "keyId": "key_prod_001",
    "value": "base64_encoded_signature..."
  }
}
```

**Verification API response (success):**
```json
{ "verified": true, "receiptId": "rcpt_7f3d8a2e...", "expiresAt": "2026-03-02T12:30:00Z" }
```

**Verification API response (failure — example error codes):**
```
RECEIPT_NOT_FOUND | RECEIPT_EXPIRED | RECEIPT_REVOKED | SIGNATURE_INVALID | SCOPE_MISMATCH
```

### NIST Framework Mapping

| NIST Concept / Control | PP Implementation |
|---|---|
| **Identify** agents and their capabilities | `agentId`, `companyId`, `principal` fields in every receipt |
| **Manage** agent access and scope | Policy evaluation before issuance; `scope` field binding constrains action parameters |
| **Authorize** actions taken by agents | Cryptographic receipt is the authorization artifact; enforcement gate blocks execution without it |
| Zero Trust (verify every action) | "No receipt, no action" — binary, fail-closed enforcement |
| Non-repudiation (AU-10) | Ed25519-signed, RFC 3161-timestamped, ledger-anchored receipt |
| Least Privilege (AC-6) | Scope binding limits receipt applicability to exact authorized parameters |
| Access Enforcement (AC-3) | Enforcement gate rejects absent, expired, revoked, or mismatched receipts |
| Audit Logging (AU-2) | Append-only ledger: receipt creation, verification attempts, redemption events |
| Audit Protection (AU-9) | Ed25519 signatures on all ledger entries; append-only semantics prevent modification |
| Software Integrity (SI-7) | Scope binding to commit SHA ensures receipt cannot authorize different artifact |
| Human Oversight | Approval gate before receipt issuance for `TIER_1` and `TIER_2` risk actions |

---

## Appendix B — Evidence and Supporting Research

### The OpenClaw Security Crisis (February 2026)

The first large-scale documented exploitation of the AI agent authorization vacuum. Key statistics:

| Metric | Value | Source |
|---|---|---|
| Publicly exposed instances | 42,665 | ClawHunter scan |
| Instances with critical auth bypass | 93.4% | Astrix Security |
| Third-party skills with vulnerabilities | 26% | Security analysis |
| Agents at risk from unsecured database | 770,000 | Astrix Security |
| Emails leaked via Supabase misconfiguration | 35,000 | Astrix Security |
| Agent tokens leaked | 1.5 million | Astrix Security |
| CVEs disclosed in February 2026 | 6 | CVE database |
| Notable supply chain event | Malicious npm package silently installed OpenClaw via Cline | Dark Reading |

**Key industry assessments:**
> *"From a capability perspective, groundbreaking. From a security perspective, an absolute nightmare."* — Cisco Blogs
>
> *"Massive access and identity problem created by poorly secured automation at scale."* — The Register
>
> *"If an agent cannot be constrained, it should not be trusted with production authority."* — Netsync
>
> *"Less than half feel confident they could pass a compliance review focused on agent behavior."* — Gravitee / Strata research

**Documentation sources:**
- Astrix Security analysis: https://astrix.security/learn/blog/openclaw-moltbot-the-rise-chaos-and-security-nightmare-of-the-first-real-ai-agent/
- SecurityWeek: https://www.securityweek.com/openclaw-security-issues-continue-as-secureclaw-open-source-tool-debuts/
- Cisco: https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare
- The Register: https://www.theregister.com/2026/02/09/openclaw_instances_exposed_vibe_code/
- BitSight: https://www.bitsight.com/blog/openclaw-ai-security-risks-exposed-instances
- Aikido Security: https://www.aikido.dev/blog/why-trying-to-secure-openclaw-is-ridiculous
- Dark Reading (supply chain): https://www.darkreading.com/application-security/supply-chain-attack-openclaw-cline-users
- TechRadar (infostealer): https://www.techradar.com/pro/security/openclaw-ai-agents-targeted-by-infostealer-malware-for-the-first-time
- Conscia: https://conscia.com/blog/the-openclaw-security-crisis/

### Industry Research

- Gravitee "State of AI Agent Security 2026" (n=900+ executives): https://www.gravitee.io/blog/state-of-ai-agent-security-2026-report-when-adoption-outpaces-control
- Strata "AI Agent Identity Crisis: A 2026 Guide": https://www.strata.io/blog/agentic-identity/the-ai-agent-identity-crisis-new-research-reveals-a-governance-gap/
- Microsoft Security "Four Priorities for AI-Powered Identity and Network Access Security in 2026": https://www.microsoft.com/en-us/security/blog/2026/01/20/four-priorities-for-ai-powered-identity-and-network-access-security-in-2026/

### NIST Framework References

- NIST AI 100-1 (AI Risk Management Framework)
- NIST AI 600-1 (Generative AI Profile)
- NIST SP 800-207 (Zero Trust Architecture)
- NIST SP 800-53 Rev. 5 (Security and Privacy Controls)
- NIST SP 800-218A (Secure Software Development Framework for Generative AI and Dual-Use Foundation Models)

---

## [TODO-ROD] Checklist Before Submission

The following items require your review and input:

### Rod Must Fill (blocks submission)
- [ ] **Organization name and legal status** — What is the submitting entity? (LLC, C-Corp, sole proprietor?)
- [ ] **Contact information** — Name, email, phone for regulations.gov
- [ ] **Submission date** — On or before March 9, 2026

### Resolved by Charles (applied)
- [x] **Strata link** — Found and added
- [x] **Deployment context (1b)** — Lead with finance + federal, mention healthcare, skip IoT/OT
- [x] **Internet-scale (4e)** — Kept brief
- [x] **IoT/OT (4c)** — Removed (roadmap vaporware, NIST will smell it)
- [x] **Mandatory vs voluntary (5b)** — Voluntary framing with economic case for eventual mandatory; respects NIST's role
- [x] **Safe harbor (5a)** — Kept and strengthened (best policy instrument in the doc)
- [x] **EU AI Act (5d)** — Kept brief, one paragraph
- [x] **Competitive positioning** — Named, not attacked (Astrix, Acuvity/Proofpoint in market context)
- [x] **Patching section (2d)** — Cleaned up, kept brief
- [x] **User docs (3d)** — Cleaned up, kept brief

### Still Recommended
- [ ] **Trim to ~4,500 words** — Government reviewers skim; protect the receipts + Deploy Gate sections, cut everything else
- [ ] **Final format: PDF** — With PP logo. Plain text on regulations.gov looks amateur.

---

*Full draft completed: March 2, 2026 | Drafted by Charles (subagent) | Issue #242*  
*Source skeleton: `nist-rfi-skeleton.md` | Supporting docs: `master-plan.md`, `market-intel.md`, `receipt-model.html`, `deploy-gate.html`*
