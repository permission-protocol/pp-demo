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

Autonomous AI agent systems are taking consequential real-world actions — deploying production software, initiating financial transactions, sending communications on behalf of users, and modifying infrastructure — at a pace that has decisively outrun the governance mechanisms designed to control them. The core security gap is not a monitoring problem or a detection problem: it is an **authorization problem**. In the vast majority of production AI agent deployments today, there is no cryptographically verifiable answer to the fundamental governance question: *was this action explicitly approved before it was executed?*

Permission Protocol is authorization infrastructure for autonomous AI systems. Our foundational technical contribution — the **cryptographic authorization receipt** — creates an immutable, signed, timestamped record of every authorized action *before* that action executes. The enforcement model is binary: no receipt, no action. This is not a monitoring layer, a policy engine, or an audit logging tool. It is **pre-action enforcement infrastructure** that operates independently of the AI model, is cryptographically tamper-evident, and cannot be circumvented by a compromised or misaligned agent.

Our reference implementation, **Deploy Gate**, operationalizes this model for software deployment pipelines. Deployed as a GitHub Actions required status check, Deploy Gate blocks every code deployment until a valid cryptographic authorization receipt exists — binding the receipt to the specific commit SHA, target environment, and authorized principal. The receipt is signed using Ed25519, timestamped per RFC 3161, and anchored to an append-only ledger. No bypass path exists; the enforcement gate is fail-closed by design.

The empirical case for this architecture is already documented. The OpenClaw security crisis of February 2026 — 42,665 publicly exposed agent instances, 93.4% carrying critical authentication bypass vulnerabilities, 6 CVEs disclosed within a single month — represents the first large-scale documented exploitation of the authorization vacuum in deployed AI agent systems. Agents operated in production environments with full tool access, no external authorization infrastructure, and no mechanism by which principals could verify or enforce what actions agents were permitted to take. The consequences were public, material, and preventable.

Permission Protocol submits this response to offer a working technical architecture as a concrete reference implementation for NIST's voluntary standards work. We welcome further engagement with the AI Agent Standards Initiative.

---

## 1. Security Threats, Risks, and Vulnerabilities Affecting AI Agent Systems

### 1(a) — Unique Security Threats Distinct from Traditional Software Systems *(Priority)*

**The primary novel threat class:** AI agent systems introduce **unauthorized autonomous action** — the ability for a software system to take consequential real-world actions without any external party having cryptographically verified and approved those specific actions before execution. This threat class does not exist in traditional software systems, and traditional security controls are architecturally insufficient to address it.

In traditional software, the instruction set is fixed. Vulnerabilities exploit known, bounded code paths. An attacker must find and exploit a specific flaw. AI agents operate on a fundamentally different model: the AI component makes discretionary decisions about *what to do* based on context, instructions, and objectives. The set of actions the agent might choose to take is not fully enumerable at development time. This creates new threat vectors that do not map cleanly onto existing vulnerability taxonomies:

**Threat 1: The Authorization Vacuum**

The most prevalent and consequential threat in current production AI agent deployments is the absence of any formal authorization model. The agent decides what action to take; scaffolding code executes it. No external party is required to approve the action before execution. This means any manipulation of the agent's decision-making process — whether through prompt injection, adversarial inputs, goal misalignment, or compromised context — translates *directly* into real-world state changes with no authorization checkpoint.

The OpenClaw security crisis provides empirical evidence at scale. A ClawHunter scan in February 2026 identified 42,665 publicly exposed OpenClaw instances, of which 93.4% carried critical authentication bypass vulnerabilities. Agents operating within those instances had tool access — file systems, APIs, external services — without any authorization infrastructure requiring pre-action approval. Astrix Security documented the resulting exposure; Cisco described the situation as "from a capability perspective, groundbreaking; from a security perspective, an absolute nightmare." Six CVEs were disclosed in February 2026 alone. This is not a hypothetical risk class; it is an operational failure mode already exploiting deployed systems.

**Threat 2: Self-Authorization**

In agent architectures where the model has access to tools without external enforcement, the model effectively authorizes its own actions. The system prompt or fine-tuned instruction set describes what the agent is "supposed" to do, but no external party enforces those constraints at execution time. Under adversarial pressure — prompt injection attacks, instruction hierarchy violations, or simply novel situations the prompt author did not anticipate — the model may deviate from intended behavior, and there is no enforcement gate to stop execution.

In multi-agent contexts, this problem compounds: a compromised agent can instruct sub-agents, propagating unauthorized authority through the agent graph. The original authorization boundary (whatever it was) applies to the root agent; sub-agents may receive delegated authority that their own instructions never explicitly granted.

**Threat 3: Receipt-Free Audit Trails**

Post-hoc logging records what actions occurred, but not whether those actions were authorized before execution. This is an architecturally critical distinction. A log entry showing "agent deployed commit abc123 to production at 14:32:07 UTC" is indistinguishable, after the fact, from a legitimately authorized deployment and an unauthorized one executed by a compromised agent. Without a pre-action authorization record — a receipt that existed *before* the deploy executed — forensic attribution is impossible, and audit trails cannot serve as meaningful compliance evidence.

The absence of pre-action receipts means that organizations relying solely on post-hoc logging cannot answer the regulatory question "was this action authorized?" with any cryptographic certainty. They can only answer "did this action occur?" These are fundamentally different questions.

**Threat 4: Scope Creep Without Enforcement**

AI agents frequently operate in production with a scope defined by policy documents and system prompt instructions. These are probabilistic controls: they influence the model's behavior under normal conditions but do not prevent out-of-scope actions under adversarial conditions or at the edge of the model's training distribution. There is no technical enforcement layer that blocks a code-deployment agent from also sending email, or a data-retrieval agent from also modifying records, if the underlying tool access exists.

Permission Protocol addresses these threats architecturally. The receipt model requires that authorization exist *outside* the agent (Non-Negotiable #2 in PP's architecture). Receipts are cryptographic evidence, not logs (#3). The enforcement model is binary: no receipt blocks execution (#4). The scope field in every receipt precisely defines what action was authorized, preventing scope expansion (#5).

---

### 1(b) — Variation by Deployment Method, Capability, and Use Case

[TODO-ROD: Strategic judgment — which deployment contexts should PP prioritize in this response? Technical framing below; please add your positioning.]

Threat severity scales with several deployment dimensions:

**Model capability and blast radius:** More capable models capable of using a broader range of tools create larger potential blast radii when those capabilities are misused. An agent that can deploy code, send email, browse the web, and modify database records through a unified interface represents a much larger attack surface than a narrowly scoped, single-purpose agent. The authorization requirement scales proportionally: each tool access class is a distinct action category requiring its own authorization policy and receipt scope.

**Tool surface area:** Each tool available to an agent (file system access, external API calls, code execution, financial transactions) is a distinct attack surface. PP's receipt model covers any action class through configurable scope types; Deploy Gate represents the first vertical implementation, targeting production code deployment as the highest-stakes, highest-frequency autonomous action in software organizations.

**Internal versus externally-deployed agents:** Externally deployed agents operating on behalf of end users present compounded authorization complexity — the agent must be authorized by the deploying organization *and* must act within bounds acceptable to each individual user. This layered authorization structure requires explicit modeling.

**Multi-agent orchestration:** As discussed in Section 1(e) below, multi-agent systems introduce authority propagation challenges that are absent in single-agent deployments.

---

### 1(c) — Security Risks as Adoption Barriers

The authorization gap is creating measurable friction in enterprise AI agent adoption. Research from multiple sources in early 2026 confirms the pattern:

The Gravitee "State of AI Agent Security 2026" report, drawing on surveys of more than 900 executives, found that AI agent adoption is outpacing organizational governance controls — and that fewer than half of respondents felt confident their agent deployments could pass a compliance review focused on agent behavior.

Strata's "AI Agent Identity Crisis" research identified identity and authorization for non-human actors as a primary blocker for enterprise AI agent adoption, particularly in regulated industries where audit trail requirements are legally mandated.

The OpenClaw crisis directly suppressed deployment: following the February 2026 disclosures, organizational deployment policies tightened industry-wide, and multiple large enterprises suspended agent-to-production deployments pending security reviews.

The absence of clear standards creates decision paralysis for organizations that want to implement responsible governance controls but have no authoritative framework against which to measure compliance. A NIST voluntary guideline establishing authorization infrastructure requirements would directly reduce adoption friction by providing deployers a compliance reference. PP's architecture is designed to be that reference.

---

### 1(d) — Threat Evolution Over Time *(Priority)*

**Current state (2026):** The authorization vacuum dominates. Most production AI agent systems operate without formal external authorization infrastructure. The OpenClaw crisis represents the first large-scale exploitation of this gap at scale, but it will not be the last. The threat is already materializing faster than the governance infrastructure needed to address it.

**Near-term evolution (2026–2027):** The proliferation of agentic frameworks — OpenAI's Agents SDK, Anthropic's Model Context Protocol (MCP), and numerous open-source orchestrators — will dramatically increase the density of agent-to-agent interactions in production environments. Each agent-to-agent communication represents an authorization surface: when Agent A instructs Agent B to execute an action, what authorization does Agent B carry, and how is that authority verifiable? Without receipt infrastructure to track authority chains, a single compromised root agent can propagate unauthorized authority to an arbitrarily large sub-agent graph.

**Medium-term (2027–2029):** Agents operating in persistent, long-horizon environments will introduce temporal authorization challenges. A single authorization decision made at session initiation may govern actions executed hours or days later. Receipts issued at time T must remain verifiable at time T+N, with clear expiration and revocation mechanisms. Static prompt-based authorization models are architecturally incompatible with this use pattern.

**Structural long-term risk:** Without external authorization infrastructure, the sole check on agent behavior is the model itself — an opaque system that cannot be externally audited, that changes with every model version update, and that cannot provide cryptographic guarantees about its own behavior. This is structurally analogous to financial systems without ledgers: trust without verification. The consequences of allowing this architecture to persist as AI agents take on higher-consequence actions — infrastructure management, financial operations, legal commitments — will be severe.

Permission Protocol's cryptographic receipt architecture scales with, rather than against, agent complexity. Receipts are timestamped, externally held, and immutable. The enforcement model does not change as the underlying model changes; authorization infrastructure remains stable across model version updates.

---

### 1(e) — Multi-Agent System Threats

Multi-agent orchestration introduces the **authority propagation problem**: when a root agent delegates a task to one or more sub-agents, what authorization do those sub-agents carry? The answer in current implementations is typically "whatever the scaffolding grants" — meaning no formal authorization model, and authority that can expand arbitrarily through delegation chains.

The primary threat vectors in multi-agent systems are:

**Unauthorized delegation:** A root agent, compromised via prompt injection or adversarial input, instructs a sub-agent to execute a high-privilege action that the root agent was never authorized to perform — or to perform an action on a scope (e.g., production environment) that was outside its authorized scope. Without per-action receipt requirements on sub-agents, this delegation is unchecked.

**Authority laundering:** A chain of agent-to-agent calls obscures the authorization provenance of a given action. Post-hoc tracing becomes impractical as the delegation graph grows. Pre-action verification of sub-agent receipts is the only reliable control.

**Orchestrator compromise:** In hub-and-spoke multi-agent architectures, a compromised orchestrator propagates unauthorized authority to all sub-agents simultaneously. The blast radius scales with the number of sub-agents and their respective tool surfaces.

**PP's architectural response:** In the Permission Protocol model, receipts are per-action, not per-session. Each action in a multi-agent chain requires its own authorization receipt, which in turn can reference its parent receipt in the authorization chain. This makes authority propagation explicit, auditable, and bounded — a sub-agent cannot receive or exercise authority not explicitly reflected in its receipt. An agent cannot grant more authority than is documented in its own authorization chain.

---

## 2. Security Practices for AI Agent Systems

### 2(a) — Technical Controls for Security *(Priority)*

**The foundational principle:** Controls that live *inside* the agent — system prompt instructions, model-level fine-tuning, instruction hierarchies, refusal training — are necessary components of a defense-in-depth strategy but are architecturally insufficient as primary security controls for high-consequence deployments. A sufficiently capable model, under sufficiently adversarial conditions, can be induced to violate internal constraints. External enforcement — controls that operate independently of, and without the cooperation of, the model — is required.

NIST guidelines should distinguish between two qualitatively different categories of controls:

**Tier 1 — External Authorization Infrastructure (deterministic controls)**

The most robust technical control is architectural: require cryptographic authorization before any action with external state effects. Permission Protocol's implementation of this model follows this sequence:

1. **Pre-action authorization request:** Before executing any action with external state effects, the agent system calls the PP authorization API. The request includes: action type, target scope, action parameters, principal identity, and session context.

2. **Policy evaluation:** PP evaluates the request against configured policy — action class permitted, scope within authorized bounds, and whether the consequence level requires human countersignature before receipt issuance. For high-consequence actions (e.g., production deployment, financial transactions), human approval is required before a receipt is issued.

3. **Cryptographic receipt issuance:** On approval, PP issues a signed authorization receipt. The receipt is signed using Ed25519 over a canonicalized JSON payload including: `id`, `companyId`, `agentId`, `requestId`, `status`, `riskTier`, `policyVersion`, `scope` (bound to specific action parameters), `createdAt`, `expiresAt`, and all signed fields. The scope binding ensures the receipt authorizes *exactly* the requested action — a receipt for `commitSha: a81f2c3e` cannot authorize deployment of any other commit. A receipt for `env: staging` cannot authorize production deployment.

4. **Enforcement gate:** The action executor validates the receipt against the PP verification API before proceeding. A receipt that is absent, expired, revoked, or scope-mismatched results in a `verified: false` response and execution is blocked. This is fail-closed enforcement — the default state is denial.

5. **Ledger entry:** Every receipt creation, verification attempt, and redemption event is recorded in an append-only ledger. Records cannot be modified or deleted. Single-use redemption is enforced: a redeemed receipt cannot be presented again for a subsequent action.

**Deploy Gate as working reference implementation:**

Deploy Gate operationalizes this model for the code deployment action class. Integrated as a GitHub Actions required status check:

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

If the verification step fails — for any reason, including network failure (fail-closed behavior) — the `Deploy to Production` step does not execute. GitHub's required status check mechanism enforces this at the repository level; administrators cannot be bypassed by individual developers even if they have repository write access. The receipt is bound to the specific commit SHA and target environment; a staging receipt cannot pass production verification.

**Tier 2 — System-Level Controls (defense-in-depth)**

Complementary to external authorization infrastructure:
- Least-privilege tool scoping: agent tool access is limited to the minimum required for the authorized action class, enforced at the infrastructure layer, not the model layer
- Sandboxed execution environments with explicit egress controls
- Network-level access controls on tool endpoints
- Human approval gates required for high-consequence actions before receipt issuance

**Tier 3 — Model-Level Controls (probabilistic, necessary but insufficient)**

- Prompt injection hardening and input sanitization
- Instruction hierarchy enforcement (system instructions take precedence over user inputs and tool outputs)
- Anomaly detection on action request sequences
- Output filtering and refusal training

**Critical point for NIST standards:** Controls in Tiers 2 and 3 reduce the probability of unauthorized action but cannot prevent it under sufficiently adversarial conditions. Only Tier 1 — external authorization with cryptographic enforcement — provides deterministic protection. NIST standards for high-consequence agent deployments should require Tier 1 controls, not treat all control types as equivalent or interchangeable.

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

[TODO-ROD: Relatively brief. Your call on whether to expand.]

A critical gap in current agent security practice: authorization policy embedded within the model (via fine-tuning or system prompts) changes with every model update. An organization that deploys a new model version may be silently changing its authorization behavior without any review process. External authorization infrastructure must be independent of the model component to remain stable and auditable across model version changes. PP's enforcement layer operates at the infrastructure layer; it is model-agnostic by design. Updating the underlying model does not affect receipt issuance policy, enforcement behavior, or ledger integrity.

---

### 2(e) — Relevant Frameworks and Standards *(Priority)*

**Existing frameworks and their alignment with PP's architecture:**

**NIST AI Risk Management Framework (AI 100-1):** PP's receipt model maps directly to the AI RMF's Govern, Map, and Manage functions. The receipt ledger operationalizes the "GOVERN 6.2" subcategory (policies and procedures are in place) and "MANAGE 3.2" (AI system response is monitored). The pre-action authorization gate operationalizes the "secure and resilient" subcategory across all functional areas.

**NIST AI 600-1 (Generative AI Profile):** The profile's "Information Security" and "Human Oversight" considerations are architecturally addressed by PP's approval gates and receipt model. Specifically: the requirement for human oversight before high-consequence actions is implemented as a mandatory approval step before receipt issuance; the receipt itself serves as the accountability artifact specified in the profile's "Accountability" consideration.

**NIST SP 800-207 (Zero Trust Architecture):** PP's "no receipt, no action" enforcement model is a direct application of Zero Trust principles to the AI agent action layer. In traditional Zero Trust, no network access is implicitly trusted — every request is verified. In PP's model, no agent action is implicitly authorized — every action with external state effects requires verified pre-authorization. The Zero Trust principle "verify explicitly" maps precisely to receipt-based authorization.

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

**NIST SP 800-218A (Secure Software Development for Generative AI):** Deploy Gate directly addresses the software supply chain security use case — the receipt is bound to a specific commit SHA, ensuring that an authorization issued for one artifact cannot be presented to authorize deployment of a different artifact.

**Adoption barriers identified:**
- No standardized interface or schema for agent authorization requests; every deployment requires custom integration
- Absence of NIST guidance creates decision paralysis for risk-averse deployers who want to implement correct governance but have no authoritative reference
- "Move fast" culture in AI-native development organizations deprioritizes governance infrastructure until a security crisis demonstrates the cost

PP addresses the adoption barrier directly: Deploy Gate requires a single GitHub Action addition and a PP API key. The on-ramp is designed to take less than two minutes for a single repository, with immediate compliance value from the first receipt.

---

## 3. Assessing the Security of AI Agent Systems

### 3(a) — Identifying Threats During Development and Testing *(Priority)*

**The authorization gap as the primary assessment target:**

Current security assessments of AI agent systems focus predominantly on code vulnerabilities, model robustness under adversarial inputs, and access controls on data resources. A critical assessment gap: evaluations do not systematically evaluate whether external authorization infrastructure exists at all. An agent system with no code vulnerabilities, hardened prompts, and strict data access controls remains fundamentally insecure if it has no external authorization enforcement — because any exploitation of the model itself translates directly to unauthorized action.

**PP-based assessment methodology:**

We propose the following assessment framework, aligned with NIST's assessment guidance:

1. **Receipt coverage audit:** For each action class the agent is capable of executing (identified through tool surface enumeration), does a pre-action authorization receipt requirement exist? Unmapped action classes are unprotected action classes.

2. **Receipt chain integrity verification:** In multi-agent systems, is each action in the agent graph covered by a receipt that traces back through a verifiable chain to a human principal with explicit authority? Gaps in the chain represent unauthorized delegation.

3. **Enforcement gap analysis:** Is there any code path through which an action with external state effects can execute without a valid receipt being verified? This is analogous to a code signing gap analysis in software supply chain security. Any bypass path — including error handling paths, fallback modes, and administrative overrides — must be evaluated.

4. **Scope constraint verification:** Do receipts include specific action parameters (not merely action type)? A receipt that authorizes "deploy code" without binding to a specific artifact, repository, and environment is insufficient. PP's scope types (e.g., `GIT_REF_COMMIT` binding to specific commit SHA and target environment) are the reference model.

5. **Expiration and revocation testing:** Are expired receipts correctly rejected? Can receipts be revoked in real time if a session is determined to be compromised? PP's verification API returns distinct error codes for each failure mode: `RECEIPT_EXPIRED`, `RECEIPT_REVOKED`, `SIGNATURE_INVALID`, `SCOPE_MISMATCH`, and `RECEIPT_NOT_FOUND`.

**Post-deployment incident detection:**
- Receipt ledger anomaly detection: flag sessions where the volume, frequency, or scope of receipt requests diverges from established baseline
- Missing receipt alerts: any action with external state effects that lacks a corresponding ledger entry is a security event requiring immediate investigation
- Receipt boundary probing detection: attempts to obtain receipts for out-of-scope actions constitute reconnaissance and should trigger escalation

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

[TODO-ROD: Brief. Lower priority.]

Current user-facing documentation for AI agent systems is sparse and inconsistent regarding authorization behavior. A PP receipt-based system inherently generates user-accessible deployment documentation: the receipt ledger is a timestamped record of every authorized action, readable by compliance teams and auditors. The receipt itself functions as a plain-language commitment: "Action X was authorized by Principal Y at Time Z, for Scope S, with policy Policy P." This is documentation that cannot be retroactively altered.

---

## 4. Limiting, Modifying, and Monitoring Deployment Environments

### 4(a) — Constraining Agent Deployment Environments *(Priority)*

**The authorization layer as the primary constraint mechanism:**

The most robust mechanism for constraining agent action scope is the authorization layer itself. If the PP authorization service is configured to issue receipts only for permitted action types and within permitted scope boundaries, the agent *cannot* execute any out-of-scope action regardless of what the model decides. The constraint is enforced externally and cannot be overridden by the agent.

**Technical mechanisms for scope constraint:**

**Action class allowlisting:** The PP authorization service is configured with an explicit list of action types for which receipts will be issued. Actions not on the allowlist return `RECEIPT_NOT_FOUND` at verification, blocking execution. This is a whitelist model rather than a blacklist — the default state is denial.

**Scope binding and parameter constraints:** Receipts are bound to specific action parameters. The `GIT_REF_COMMIT` scope type binds to an exact commit SHA, repository, git ref, target environment, and capability string. A receipt issued for one set of parameters cannot authorize a different set. This prevents the common pattern where a broad authorization is obtained and then applied to a larger-than-intended set of actions.

**Environment-scoped authority:** Deploy Gate enforces strict environment separation. The staging authority signer and production authority signer are independent; a staging receipt cannot pass production verification. Environment boundaries are cryptographic, not policy-based — there is no configuration switch that allows a staging receipt to be elevated to production authority.

**Rate limits and action budgets:** The PP authorization service can enforce per-session action budgets. An agent attempting to obtain receipts for an unusually large number of actions in a short time window triggers an escalation to human review before additional receipts are issued. This prevents runaway agent behavior within a session even if individual action requests are within scope.

**Context-aware authorization:** Authorization policy can be dynamic — requiring human approval for first-time action types, escalating for actions targeting high-value resources, applying stricter constraints during off-hours or in the absence of an active human session.

**Deploy Gate as proof of concept:** The GitHub required status check mechanism provides the enforcement point that makes Deploy Gate's scope constraints non-bypassable at the repository level. Even repository administrators with direct merge authority cannot bypass a failing required status check without modifying the repository's branch protection rules — an action that generates a separate audit event and can itself be subject to PP authorization.

---

### 4(b) — Rollback and Negation Capabilities for Unwanted Actions *(Priority)*

**Receipts as rollback infrastructure:**

The PP receipt model provides the foundational precondition for rollback capability: an immutable, cryptographically signed record of exactly what action was authorized, with what parameters, at what time, by which principal.

The rollback workflow enabled by the receipt model:
1. An action is identified as unauthorized or erroneous (either through anomaly detection, human review, or receipt revocation trigger)
2. The receipt ledger entry for that action is identified by `receiptId` — providing the exact action parameters (artifact, repository, target environment, execution timestamp)
3. The revocation signal propagates to dependent systems: `RECEIPT_REVOKED` error code is returned on any subsequent verification attempt
4. Rollback operations reference the original receipt parameters to precisely identify the state change to be reversed

**Current limitation:** Receipt-based rollback is a foundational precondition, not a complete solution. The ability to reverse an action depends on the reversibility of the underlying state change (code deployment rollback is straightforward; deleted data may not be recoverable). PP's receipt model provides the identification infrastructure; the rollback execution mechanism is application-specific.

**Recommendation for NIST standards:** Rollback capability should be a tiered requirement for agent deployments, scaling with action consequence level. At minimum, every action with external state effects should generate an immutable record sufficient to identify and (where technically feasible) reverse the action. PP's receipt ledger satisfies the identification requirement; NIST guidelines should specify that identification is a threshold requirement, with application-specific reversal as a higher-tier requirement.

---

### 4(c) — Interactions with Counterparties

The PP receipt model most directly addresses authentication and source code integrity (counterparty interaction categories iv and v per NIST's framing). Deploy Gate targets the source code deployment interface specifically, binding authorization to a cryptographic artifact identifier (commit SHA) rather than a human-readable description of the artifact.

For multi-agent interactions: when Agent A calls Agent B, the authority chain model requires Agent B's receipt to reference Agent A's authorization. This makes the authority propagation explicit and auditable in the ledger.

[TODO-ROD: Expand on IoT/OT or critical infrastructure relevance if desired — this is in PP's longer-term roadmap but may be worth flagging for NIST's benefit.]

---

### 4(d) — Monitoring Deployment Environments *(Priority)*

**The receipt ledger as monitoring infrastructure:**

The PP receipt model generates a high-quality monitoring signal as an inherent side effect of authorization. This is qualitatively different from traditional agent monitoring:

- **Authorization-aware monitoring:** The ledger records not only what actions occurred (as post-hoc logs do) but what was authorized before execution. The delta between "actions authorized" and "actions executed" — authorization gaps, unauthorized execution attempts, scope boundary probes — is the security signal that matters most in adversarial environments.

- **Attempted action visibility:** Every authorization request, whether approved or denied, generates a ledger entry. Denied requests (actions the agent attempted but could not obtain a receipt for) are security events; patterns of denied requests reveal reconnaissance behavior.

- **Agent-agnostic monitoring:** PP's receipt ledger provides consistent monitoring coverage regardless of which AI model, which agent framework, or which orchestration tool is used. All agent activity that touches the authorization layer generates the same structured ledger events.

- **Tamper-evident audit trail:** Ed25519 signatures on receipt payloads and append-only ledger semantics make the monitoring record cryptographically tamper-evident. An attacker who compromises the agent system cannot retroactively alter the ledger to conceal unauthorized actions.

**Anomaly detection on receipt activity:**
- Unusual action sequences: requests for receipts in an order inconsistent with the established workflow for that agent type
- Timing anomalies: receipt requests at unusual hours or with unusual urgency parameters
- Scope boundary probing: repeated requests for receipts with incrementally expanding scope, suggestive of an agent testing authorization boundaries
- Volume anomalies: receipt request rates exceeding established baselines for the agent type and session context

**Maturity note:** Receipt ledger infrastructure and basic anomaly detection are operational in Deploy Gate's current implementation. Advanced anomaly detection on receipt activity patterns is an active development priority.

---

### 4(e) — Open Internet Deployment

[TODO-ROD: Brief reference to PP's relevance for internet-scale deployment, and whether you want to comment on public-facing agent deployments.]

The authorization vacuum is most acute for agents deployed at internet scale, where the principal population is large, the action surface is broad, and human oversight per-action is infeasible. PP's receipt model scales to this context: authorization decisions are made by policy, not by individual human review of every action, with human escalation triggered by risk tier and anomaly detection. The ledger provides accountability infrastructure that enables post-hoc review at scale.

---

## 5. Additional Considerations

### 5(a) — Tools and Resources for Rapid Adoption

**PP's design philosophy on adoption:** Authorization infrastructure must install like a dependency, not like a compliance program. Every additional step in the adoption path is a barrier that prevents organizations from implementing the controls NIST wants to see.

Deploy Gate is designed around this philosophy. Installation on a GitHub repository requires:
1. Add one GitHub Actions workflow step (`permission-protocol/verify-action@v1`)
2. Configure one repository secret (`PP_API_KEY`)
3. Set Deploy Gate as a required status check in branch protection rules

This is a two-minute setup on a single repository, with immediate compliance value from the first receipt. The incremental path from there — one repo to all repos; deploys to all agent actions — is designed to be friction-free.

**NIST opportunities to accelerate adoption:**

1. **Reference implementation recognition:** NIST naming PP's receipt model or the authorization receipt architecture pattern as a reference implementation in voluntary guidelines would immediately legitimize adoption for risk-averse enterprises and regulated-industry deployers who need an authoritative standard to reference.

2. **Standardized receipt schema:** A NIST-published JSON schema for authorization receipts — analogous to the way RFC 7519 standardized JWT — would enable interoperability across authorization infrastructure providers and prevent proprietary lock-in. PP's current receipt schema (detailed in Appendix A) could serve as the basis for such standardization.

3. **SP 800-53 mapping documentation:** Explicit published mapping of receipt-based authorization controls to SP 800-53 control families (AC, AU, IA, SI) would enable regulated-industry deployers to use PP receipts as evidence in FISMA and FedRAMP compliance assessments.

4. **Safe harbor framework:** [TODO-ROD: Your call on whether to advocate for this explicitly. Draft below.] Organizations that implement certified authorization infrastructure with demonstrated receipt coverage for high-consequence action classes should receive safe harbor from certain AI-related liability categories. This creates a positive incentive structure and rewards proactive compliance rather than waiting for incidents.

---

### 5(b) — Priority Areas for Government Engagement

[TODO-ROD: This is a policy/strategic judgment section. Please review and revise to reflect your priorities and political calculus on voluntary vs. mandatory framing.]

Based on our technical analysis and the current state of the market, we suggest NIST prioritize:

1. **External authorization as a threshold requirement for high-consequence deployments:** NIST voluntary guidelines should establish that AI agent systems taking high-consequence actions (production code deployment, financial transactions above defined thresholds, infrastructure modifications, externally-sent communications) must implement external authorization infrastructure with cryptographic receipt issuance. This should be framed as a baseline requirement, not an optional enhancement.

2. **Receipt interoperability standard:** A standardized protocol and schema for AI agent authorization receipts would enable portability across authorization infrastructure providers, prevent proprietary lock-in, and create a level playing field. Analogies exist in mature ecosystems: JWT for identity tokens, certificate transparency logs for TLS certificates, software bill of materials for supply chain. AI agent authorization receipts should have the same standardized foundation.

3. **Federal pilot program:** A NIST-coordinated pilot implementing receipt-based authorization in federal agency AI agent deployments would generate real-world data on implementation friction, receipt schema requirements, and compliance utility — informing future rulemaking and voluntary guidelines with empirical rather than theoretical evidence.

---

### 5(c) — Research Priorities

The most urgent research gaps for the field, as identified through PP's development and market engagement:

1. **Receipt schema standardization:** What information must an authorization receipt contain to be legally and technically sufficient across different action classes, regulatory regimes, and organizational contexts? The minimum viable schema includes: action type, action parameters (scope-bound), principal identity (agent and human), authorization timestamp, expiration, policy version, and cryptographic signature. But the specific fields required for legal non-repudiation in different regulatory contexts (HIPAA, SOX, FISMA) have not been formally specified.

2. **Multi-agent authority propagation models:** Formal models are needed for how authorization should propagate through agent delegation chains without authority escalation. The key problem: Agent A, authorized for scope S, delegates a subtask to Agent B — what is Agent B authorized to do, and how is this verifiable? PP's per-action receipt model provides an operational answer, but formal theoretical grounding and adversarial analysis of the delegation model would strengthen the standard.

3. **Receipt-based rollback mechanisms:** Technical infrastructure for reversing agent actions using receipt records is an underexplored area. The receipt provides the identification foundation; the reversal execution mechanisms for common action classes (infrastructure changes, financial transactions, content publications) need standardized specifications.

4. **Authorization performance at scale:** Pre-action receipt verification introduces latency into agent action execution. For high-frequency agent actions (potentially thousands per session), what is the acceptable latency budget, and what caching and pre-authorization models are consistent with maintaining security guarantees?

5. **Adversarial robustness of external authorization infrastructure:** If the authorization service is itself a target, what are its failure modes? Research on the security properties of the authorization infrastructure itself — including denial-of-service resilience, key compromise recovery, and ledger integrity under adversarial conditions — is needed.

---

### 5(d) — International Approaches

[TODO-ROD: Your call on whether to expand this into a full comparative analysis or keep brief.]

The EU AI Act (Regulation 2024/1689) establishes traceability and logging requirements for high-risk AI systems under Article 12, and human oversight requirements under Article 14. These are directionally aligned with PP's receipt model but differ in a critical architectural dimension: the EU framework specifies post-hoc logging and human review capability, while PP's model requires *pre-action* authorization. An agent can generate a comprehensive post-hoc log of every action it took without any of those actions having been pre-authorized.

NIST has an opportunity to set a technically more rigorous standard than the EU baseline by specifying pre-action authorization (not merely post-hoc logging) as the appropriate control for high-consequence autonomous action. This distinction is architecturally fundamental: logging records what happened; authorization receipts prove what was permitted before it happened.

The United Kingdom's AI Safety Institute has similarly focused on post-deployment evaluation rather than pre-action authorization infrastructure, representing the same architectural gap.

---

### 5(e) — Cross-Disciplinary Insights

The financial system analogy is instructive and should inform NIST's standards work. Every financial transaction requires authorization (the payment instruction), generates a non-repudiable record (the transaction receipt), and is settled against an append-only ledger. No payment system operates on a trust-the-actor model. The question "was this transaction authorized?" has a definitive, cryptographically verifiable answer. The question "was this AI agent action authorized?" should have the same property.

The blockchain ecosystem independently arrived at the same architectural insight: the transaction hash is a receipt, the blockchain is a tamper-evident ledger, and validity requires verification rather than trust. Proof-of-work and proof-of-stake are external validation mechanisms — the ledger's validity does not depend on trusting any individual node.

Certificate transparency logs — a security infrastructure standard for TLS certificates — provide another direct analogy. The append-only log of issued certificates provides public verifiability and makes unauthorized certificate issuance detectable. PP's receipt ledger applies the same architecture to AI agent authorization.

NIST has an opportunity to codify these cross-disciplinary insights into AI agent security standards before a second-generation security crisis — one affecting higher-consequence action classes than OpenClaw — makes the architectural gap undeniable at greater cost.

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
- Strata "AI Agent Identity Crisis": [TODO-ROD: Add link if available]
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

- [ ] **Organization name and legal status** — What is the submitting entity? Current status (LLC, C-Corp, sole proprietor)?
- [ ] **Contact information** — Name, email, phone for submission form on regulations.gov
- [ ] **Submission date** — Must be on or before March 9, 2026
- [ ] **Strata link (Section 5a / Appendix B)** — Do you have the URL for the "AI Agent Identity Crisis" research?
- [ ] **Section 1(b) — Deployment context prioritization** — Which verticals/contexts do you want to call out? (Healthcare, finance, federal?)
- [ ] **Section 4(e) — Internet-scale deployment** — Expand or keep brief?
- [ ] **Section 4(c) — IoT/OT relevance** — Mention as future roadmap item or leave out?
- [ ] **Section 5(b) — Mandatory vs. voluntary language** — How aggressive should PP's policy recommendations be? "Threshold requirement" is the current framing; do you want stronger ("mandatory") or softer language?
- [ ] **Section 5(a) — Safe harbor advocacy** — Keep the draft or remove? This is a political judgment call.
- [ ] **Section 5(d) — EU AI Act comparison** — Keep brief (current) or expand into full comparative analysis?
- [ ] **Competitive positioning** — How explicitly should we acknowledge other players (Astrix, Acuvity/Proofpoint)? Current draft names them in market context but does not attack.
- [ ] **Word count / length** — Current draft is approximately 5,800 words (excluding appendices). NIST has no stated limit. Cut or leave?
- [ ] **Final format** — Regulations.gov accepts plain text or PDF. Want a PDF-formatted version after your review?

---

*Full draft completed: March 2, 2026 | Drafted by Charles (subagent) | Issue #242*  
*Source skeleton: `nist-rfi-skeleton.md` | Supporting docs: `master-plan.md`, `market-intel.md`, `receipt-model.html`, `deploy-gate.html`*
