# NIST RFI Response Skeleton — Permission Protocol
## Security Considerations for Artificial Intelligence Agents
**Docket:** NIST-2025-0035 | **Deadline:** March 9, 2026 | **Submitted by:** Permission Protocol / [TODO-ROD: org name]

---

> **Status:** ✅ SKELETON SUPERSEDED — Full polished draft exists at `pp-os/nist-rfi-response.md`
> Full draft completed: March 2, 2026 (Issue #242). Rod: review that file, not this one.
> This skeleton is preserved for reference only.
>
> Original skeleton notes:
> Rod: please review [TODO-ROD] sections and add strategic/policy judgments.
> Priority questions per NIST guidance: 1(a), 1(d), 2(a), 2(e), 3(a), 3(b), 4(a), 4(b), 4(d)

---

## Executive Summary

AI agent systems are taking autonomous actions — deploying code, moving money, sending communications, modifying infrastructure — faster than the governance infrastructure needed to control them. The fundamental security gap is not detection or monitoring: it is **authorization**. The question "was this action approved?" has no cryptographically verifiable answer in today's agent architectures.

Permission Protocol is authorization infrastructure for autonomous AI systems. Our core model — the **cryptographic receipt** — creates an immutable, signed, timestamped record of every authorized action before that action is executed. No receipt, no action. This is not a policy engine, a monitoring tool, or a logging system. It is **enforcement infrastructure**: the agent cannot act without external authorization, and the authorization cannot be forged or retroactively altered.

Our reference implementation, **Deploy Gate**, demonstrates this model at scale. As a GitHub Actions required status check, it blocks every code deployment until a cryptographic authorization receipt exists. This architecture is directly applicable to the NIST framework's three pillars: **identify** (who authorized this agent, for what), **manage** (control scope and escalation thresholds), and **authorize** (cryptographic proof of approval before action).

The OpenClaw security crisis — 42,665 exposed instances, 93.4% with critical auth bypass, 6 CVEs documented in February 2026 alone — is the empirical proof case. Agents shipped to production without authorization infrastructure. The results were predictable and publicly documented. Permission Protocol's receipt model exists precisely to prevent this class of vulnerability.

We submit this response to offer a working technical architecture as a reference implementation for NIST's voluntary guidelines and standards work. We welcome further engagement with the AI Agent Standards Initiative.

---

## 1. Security Threats, Risks, and Vulnerabilities Affecting AI Agent Systems

### 1(a) — **[PRIORITY]** Unique security threats distinct from traditional software

**Core finding:** The primary novel threat affecting AI agent systems is **unauthorized autonomous action** — agents executing real-world effects without cryptographically verifiable, pre-action authorization from a principal that exists outside the agent itself.

Traditional software has a fixed instruction set; a vulnerability exploits a known code path. AI agents have *discretionary execution*: the model determines what action to take given context. This creates a new threat class:

**Threat 1: Authorization vacuum.** Most AI agent systems today have no formal authorization model. The agent decides what to do; scaffolding code executes it. There is no external party that must sign off before action. This means any compromise of the model (prompt injection, adversarial inputs, misaligned objectives) directly translates to real-world effects with no checkpoint.

- *Evidence:* The OpenClaw security crisis (Feb 2026) documented 42,665 publicly exposed instances, 93.4% with critical auth bypass vulnerabilities. Agents could be directed to execute arbitrary actions without any authorization mechanism. Source: ClawHunter scan, Astrix Security analysis.

**Threat 2: Self-authorization.** Agents that are given tool access without an external enforcement layer can effectively authorize their own actions. In a multi-agent context, a compromised agent can delegate to sub-agents, propagating unauthorized authority.

**Threat 3: Receipt-free audit trails.** Logs and observability tools record what happened, but not whether it was authorized. Post-hoc logging is insufficient: a malicious or compromised agent can act and the log entry is indistinguishable from a legitimate action. The absence of a pre-action authorization record makes forensic attribution impossible.

**Threat 4: Scope creep without enforcement.** Agents operating in production environments routinely exceed their intended scope because there is no technical enforcement layer — only policy documents and prompt instructions that the model may not follow under adversarial pressure.

**Permission Protocol's response:** The receipt model addresses these threats at the architectural level. Authorization must exist outside the agent (Non-Negotiable #2), receipts are cryptographic evidence not logs (#3), and the enforcement model is binary — no receipt blocks execution (#4, #5).

---

### 1(b) — Variation by deployment method, capability, use case

[TODO-ROD: Strategic judgment on which deployment contexts PP prioritizes. Technical draft below.]

Threat severity scales with:
- **Model capability:** More capable models have greater blast radius when compromised. A coding agent that can also browse the web, send emails, and modify infrastructure represents a much larger attack surface than a single-purpose agent.
- **Tool surface:** Each additional tool (file system, API, external services) is a new action class that requires authorization scoping. PP's receipt model covers any action class; Deploy Gate is the first vertical.
- **Internal vs. external deployment:** Externally deployed agents acting on behalf of users have compounded authorization complexity — the agent must be authorized by the deployer AND act within bounds acceptable to the end user.
- **Multi-agent orchestration:** Authority delegation across agents creates cascading authorization gaps (see 1(e)).

---

### 1(c) — Security risks as adoption barriers

The authorization gap is creating measurable adoption friction in regulated industries. Key data:

- Gravitee "State of AI Agent Security 2026" (900+ executives): adoption is outpacing governance controls; less than half feel confident they could pass a compliance review focused on agent behavior.
- Strata "AI Agent Identity Crisis" research: identity and authorization for non-human actors are cited as primary adoption blockers in enterprise environments.
- The OpenClaw crisis directly suppressed adoption: following the disclosure of 42K exposed instances and 6 CVEs, organizational deployment policies tightened industry-wide.

A standards-based authorization model — with NIST imprimatur — would directly reduce this friction by providing deployers a compliance framework they can reference.

---

### 1(d) — **[PRIORITY]** Threat evolution over time

**Current state (2026):** Authorization vacuum. Most production AI agents operate without formal authorization infrastructure. The threat is already materializing: the OpenClaw crisis is the first documented large-scale exploitation of this gap.

**Near-term evolution (2026–2027):** As agentic frameworks mature (OpenAI Agents SDK, Anthropic MCP, open-source orchestrators), the number of agent-to-agent interactions will grow exponentially. Each delegation hop is a new authorization surface. Without infrastructure to track authority chains, the blast radius of a single compromised agent grows with the size of the agent graph.

**Medium-term (2028–2030):** Agents will operate in persistent environments with long-horizon goals. A single authorization decision made at session initiation may govern actions taken hours later. Receipts issued at time T must still be verifiable and scoped at time T+N.

**Long-term structural risk:** Without external authorization infrastructure, the only check on agent behavior is the model itself — a closed system that cannot be externally audited or overridden. This is structurally analogous to financial systems without ledgers: trust without verification.

**PP's architectural response:** Cryptographic receipts are timestamped, immutable, and externally held. They provide verifiability at any point in time, for any action taken at any past time. This architecture scales with agent complexity rather than against it.

---

### 1(e) — Multi-agent system threats

Multi-agent systems introduce the **authority propagation problem**: when Agent A delegates a task to Agent B, what authorization does Agent B carry? In current implementations, the answer is typically "whatever authority the scaffolding grants" — i.e., no formal model.

Key threat vectors:
- **Unauthorized delegation:** Agent A, compromised via prompt injection, instructs Agent B to execute a high-privilege action it was not originally authorized for.
- **Authority laundering:** A chain of agent-to-agent calls obscures the original authorization (or lack thereof). Post-hoc tracing is difficult; pre-action verification is impossible without receipts.
- **Orchestrator compromise:** In hub-and-spoke architectures, compromise of the orchestrator propagates to all sub-agents.

**PP's multi-agent model:** Receipts are per-action, not per-session. Each action in a multi-agent chain requires its own authorization receipt. This makes authority propagation explicit, auditable, and bounded — an agent cannot grant more authority than it has.

---

## 2. Security Practices for AI Agent Systems

### 2(a) — **[PRIORITY]** Technical controls for security

**The key insight:** Controls that live inside the agent (prompt engineering, instruction hierarchy, model-level constraints) are necessary but insufficient. A sufficiently capable model, under adversarial pressure, can be made to violate internal constraints. External enforcement is required.

**Tier 1 — External authorization infrastructure (PP's contribution):**

The most robust control is architectural: require external authorization before any action with external state effects. The technical implementation:

1. **Pre-action authorization request:** Before execution, the agent system calls the authorization service with: action type, scope, parameters, principal identity, and session context.
2. **Authorization decision:** The external service (PP) evaluates the request against policy, scope constraints, and approval requirements. For high-consequence actions, human approval is required before the receipt is issued.
3. **Cryptographic receipt issuance:** On approval, PP issues a signed, timestamped receipt bound to the specific action parameters.
4. **Enforcement gate:** The action executor validates the receipt before proceeding. Invalid or absent receipt → blocked execution.
5. **Immutable ledger:** Receipts are recorded in an append-only log. No receipt can be retroactively altered or deleted.

**Deploy Gate as reference implementation:**
- GitHub Actions required status check
- Intercepts every code deployment
- Requires valid PP authorization receipt before merge is permitted
- Receipt is cryptographically signed, timestamped, bound to commit hash and actor identity
- Zero-config installation (one GitHub Action)
- Adoption path: one repo → all repos → extend beyond deploys

**Maturity:** Deploy Gate is in active development as a working reference implementation. The underlying receipt model is production-ready. Full multi-environment deployment at enterprise scale is the current development focus.

**Tier 2 — System-level controls (complementary):**
- Least-privilege tool scoping: agent tool access is limited to the minimum required for the authorized action
- Sandboxed execution environments: agent actions execute in isolated environments with explicit egress controls
- Human approval gates: for high-consequence or novel action classes, receipts require human countersignature before issuance

**Tier 3 — Model-level controls (necessary but insufficient alone):**
- Prompt injection hardening
- Instruction hierarchy (system instructions > user instructions > tool outputs)
- Anomaly detection on action sequences

**The critical point for NIST standards work:** Controls in Tiers 2 and 3 are probabilistic — they reduce the likelihood of unauthorized action but cannot prevent it under sufficiently adversarial conditions. Only Tier 1 (external authorization with enforcement) is deterministic.

---

### 2(b) — Effectiveness variation by deployment context

External authorization controls (Tier 1) maintain effectiveness across capability levels because they are independent of the model. The receipt is required regardless of what the model "decides." Model-level controls (Tier 3) become less effective as model capability increases — a more capable model is better at circumventing internal constraints.

**Implication for standards:** NIST guidelines should distinguish between probabilistic controls (model-level) and deterministic controls (external enforcement). Standards for high-consequence deployments should require external authorization infrastructure, not rely solely on model-level constraints.

---

### 2(c) — Future evolution requirements

As agents become more capable and autonomous:
- Authorization scope must become more granular (not just "can deploy code" but "can deploy to production" vs. "can deploy to staging")
- Time-bounded receipts will be required for long-horizon agent sessions
- Delegation chains must be explicitly tracked with each sub-agent receipt referencing its parent authorization

---

### 2(d) — Patching and updating considerations

[TODO-ROD: Less directly relevant to PP's core thesis. Can be brief.]

Key consideration: updates to the model component of an agent system change its behavior unpredictably. If authorization policy is baked into the model (via fine-tuning or system prompts), model updates can silently change authorization behavior. **Authorization infrastructure must be external to and independent of the model** to remain stable across model versions.

---

### 2(e) — **[PRIORITY]** Relevant frameworks and adoption

**Most relevant existing frameworks:**

- **NIST AI RMF (AI 100-1):** PP's receipt model maps directly to the "Govern," "Map," and "Manage" functions. Receipts operationalize the RMF's "secure and resilient" subcategories.
- **NIST AI 600-1 (GenAI Profile):** The "information security" and "human oversight" considerations in the GenAI profile are architecturally addressed by PP's approval gates and receipt model.
- **Zero Trust Architecture (NIST SP 800-207):** PP's "no receipt, no action" enforcement model is a direct application of Zero Trust principles to AI agent systems. Every agent action is treated as potentially untrusted until cryptographically authorized.
- **NIST SP 800-53 (AC-2, AC-3, AU-2, AU-9, AU-10):** PP receipts directly implement access enforcement (AC-3), audit event logging (AU-2), protection of audit information (AU-9), and non-repudiation (AU-10).

**Adoption barriers:**
- No standardized interface for agent authorization requests — every deployment requires custom integration
- Lack of NIST guidance creates decision paralysis for deployers who want to do the right thing but have no reference model
- "Move fast" culture in AI-native startups deprioritizes governance infrastructure until a crisis occurs

**PP's response:** Deploy Gate is designed to eliminate adoption friction — one GitHub Action, zero configuration, immediate value from day one. The Trojan-horse model: once you have receipts for deploys, the infrastructure is in place to extend to all agent actions.

---

## 3. Assessing the Security of AI Agent Systems

### 3(a) — **[PRIORITY]** Anticipating and identifying threats during development

**The authorization gap as an assessment target:**

Current security assessments focus on code vulnerabilities, model robustness, and access controls on data. A critical gap: assessments do not evaluate whether authorization infrastructure exists at all. A system with perfect code security but no external authorization enforcement remains fundamentally insecure.

**PP-based assessment methodology:**
1. **Receipt coverage audit:** For each action class the agent can perform, does a pre-action authorization receipt exist? Gaps in receipt coverage are gaps in authorization.
2. **Receipt chain integrity:** In multi-agent systems, is each action in the chain covered by a receipt that traces back to a human principal?
3. **Enforcement gap analysis:** Can any action be executed without a valid receipt? If yes, the enforcement model has gaps.
4. **Scope constraint verification:** Do receipts include action parameters (not just action type)? A receipt for "deploy code" that doesn't specify which code to deploy is insufficient.

**Post-deployment incident detection:**
- Receipt ledger anomaly detection: flag actions where receipt issuance and action execution timestamps diverge
- Missing receipt alerts: any action with external state effects that lacks a receipt is an incident
- Receipt revocation infrastructure: ability to invalidate receipts in real-time if a session is compromised

**Alignment with traditional security:**
- PP receipts function as non-repudiation evidence (aligned with AU-10 in NIST SP 800-53)
- The receipt ledger is analogous to a certificate transparency log — append-only, publicly verifiable
- Enforcement gates align with code signing requirements in software supply chain security

---

### 3(b) — **[PRIORITY]** Assessing a particular agent system

Not all threats apply to every deployment. Assessment should be scoped to:
- **Action surface:** What external state effects can this agent cause? (Code deployment, financial transactions, email, infrastructure changes)
- **Authorization coverage:** For each action class, is there a receipt requirement?
- **Consequence classification:** High-consequence actions (production deploys, fund transfers) require stricter receipt requirements (human countersignature, time-bounded scope)
- **Agent identity:** Is the agent cryptographically identifiable? Can actions be attributed to a specific agent instance?

**PP receipt model as assessment scaffold:**
The presence or absence of a receipt model is itself a binary security indicator. An agent system with no external authorization infrastructure fails the baseline regardless of other controls. NIST guidelines should codify this: external authorization is a threshold requirement, not an optional enhancement.

---

### 3(c) — Upstream developer documentation

Model cards and system cards should include:
- Action surface documentation: what tools can the model/agent use?
- Known prompt injection vulnerabilities
- Recommended authorization controls for each action class

PP's contribution: standardized receipt schemas that model/agent developers can publish as part of their documentation — "this agent supports PP receipts for the following action classes."

---

### 3(d) — User-facing documentation

[TODO-ROD: Brief. Not core PP positioning.]

Current state: sparse and inconsistent. A PP receipt-based system inherently generates deployment documentation — the receipt ledger is a timestamped record of every authorized action, readable by auditors and compliance teams.

---

## 4. Limiting, Modifying, and Monitoring Deployment Environments

### 4(a) — **[PRIORITY]** Constraining agent deployment environments

**The authorization layer as the constraint mechanism:**

The most robust constraint on agent action scope is the authorization layer. If the authorization service only issues receipts for permitted action classes, the agent cannot execute any action outside that scope — regardless of what the model "decides" to do.

**Technical implementation:**
- **Action class allowlisting:** Authorization service only issues receipts for pre-approved action types. Actions outside the list cannot receive a receipt → cannot execute.
- **Scope binding:** Receipts are bound to specific parameters. A receipt for "deploy commit abc123 to staging" cannot be used to deploy a different commit or to production.
- **Rate limits and budget constraints:** Authorization service enforces per-session action budgets. An agent that attempts to deploy 50 times in an hour triggers human review before receipts are issued.
- **Context-aware authorization:** Authorization policy can be dynamic — more restrictive during off-hours, require human approval for first-time action types, escalate for high-value targets.

**Deploy Gate as proof of concept:**
Deploy Gate demonstrates this model for code deployment. The GitHub required status check is the enforcement gate: no receipt, no merge. The receipt is issued by PP after policy evaluation. The constraint is deterministic — no bypass path exists.

---

### 4(b) — **[PRIORITY]** Rollback and negation for unwanted actions

**Receipts as rollback infrastructure:**

The PP receipt model provides the foundation for rollback:
1. Every action is associated with a receipt (timestamped, action parameters recorded)
2. Rollback operations can reference the original receipt to identify exactly what was executed
3. Receipt revocation signals downstream systems that the original action should be reversed

**Current state of applied use:**
Limited. Most agent systems have no rollback infrastructure because they have no action records. PP receipts create the precondition for rollback: you cannot undo what you cannot precisely identify.

**Recommendation for NIST standards:** Rollback capability should be a requirement for high-consequence deployments. The minimum requirement is that every action with external state effects generates an immutable record sufficient to identify and reverse the action.

---

### 4(c) — Interactions with counterparties

PP receipt model addresses interactions at 4(c)(iv) (authentication mechanisms, source code, network-level access) most directly, as Deploy Gate targets source code access.

Multi-agent interactions (4(c)(v)): the authority chain model ensures that agent-to-agent interactions carry explicit authorization through receipt propagation.

[TODO-ROD: Expand on IoT/OT relevance if desired — longer-term PP roadmap.]

---

### 4(d) — **[PRIORITY]** Monitoring deployment environments

**Receipt ledger as monitoring infrastructure:**

The PP receipt model generates a monitoring signal as a side effect of authorization:
- Every authorized action is in the ledger
- Every attempted action that fails receipt validation is a security event
- Anomaly detection can run against the ledger: unusual action sequences, timing anomalies, scope boundary probes

**Advantages over traditional monitoring:**
- Traditional monitoring detects what happened. PP receipts record what was authorized and what was attempted — capturing the delta between the two, which is the signal that matters most.
- Receipt-based monitoring is agent-agnostic. It works identically regardless of which model, framework, or scaffolding is used.
- The ledger is append-only and cryptographically sealed, making it tamper-evident monitoring infrastructure.

**Maturity:** Receipt ledger and anomaly detection on receipt activity are active development priorities. Early implementations are operational in Deploy Gate.

---

### 4(e) — Open internet deployment

[TODO-ROD: Brief reference to PP's relevance for internet-scale deployment monitoring.]

---

## 5. Additional Considerations

### 5(a) — Tools and resources for rapid adoption

**PP's answer: make the on-ramp zero-friction.**

Deploy Gate is designed for 2-minute installation on any GitHub repository. The vision: authorization infrastructure that installs like a dependency, not like a compliance program. For NIST to accelerate adoption:

- **Reference implementation endorsement:** NIST naming PP's receipt model (or the receipt architecture pattern) as a reference implementation in voluntary guidelines would immediately legitimize adoption for risk-averse deployers.
- **Standardized receipt schema:** A NIST-published JSON schema for authorization receipts would enable interoperability across authorization providers — the same way JWT standardized identity tokens.
- **Compliance framework mapping:** Explicit mapping of authorization receipt requirements to NIST SP 800-53 control families (AC, AU, IA) would help regulated-industry deployers justify investment.

---

### 5(b) — Priority areas for government collaboration

**[TODO-ROD: Policy recommendations — your strategic judgment call.]**

Suggested priorities:
1. **Authorization as baseline requirement:** NIST guidelines should establish external authorization infrastructure as a threshold requirement for high-consequence agent deployments (production code, financial transactions, infrastructure changes). Not a recommendation — a requirement.
2. **Receipt interoperability standard:** A standardized protocol for authorization receipts would prevent vendor lock-in and create a level playing field for authorization infrastructure providers.
3. **Safe harbor for compliant deployers:** Organizations that implement certified authorization infrastructure (with receipt coverage) should receive safe harbor protection. This creates a positive incentive structure.

---

### 5(c) — Research priorities

**Most urgent research gaps:**
1. **Receipt schema standardization:** What information must an authorization receipt contain to be legally and technically sufficient? (Action parameters, principal identity, timestamp, scope, expiry, signature)
2. **Multi-agent authority propagation:** Formal models for how authorization should propagate through agent chains without authority escalation
3. **Receipt-based rollback mechanisms:** Technical infrastructure for reversing agent actions using receipt records
4. **Authorization performance at scale:** Can pre-action receipt validation be achieved with latency low enough for high-frequency agent actions?

---

### 5(d) — International approaches

[TODO-ROD: Brief comparative note. EU AI Act's traceability requirements are directionally aligned. Include if desired.]

EU AI Act Article 12 requires logging and traceability for high-risk AI systems — directionally aligned with PP's receipt model, but not specific to pre-action authorization. The EU approach is post-hoc; PP's model is pre-action. NIST should set the more rigorous standard.

---

### 5(e) — Cross-disciplinary insights

The financial system analogy is instructive: every transaction requires authorization (the transaction receipt), the ledger is append-only and immutable, and no payment can be reversed without identifying the original transaction record. The crypto/blockchain world independently arrived at the same architecture — the transaction hash is a receipt, the blockchain is a tamper-evident ledger.

AI agent authorization should be designed with the same architectural primitives. The Permission Protocol receipt model applies this pattern to AI actions.

---

## Appendix A — Technical Architecture Summary

### Deploy Gate (Reference Implementation)

```
┌─────────────────────────────────────────────────────────────────┐
│                     CI/CD Pipeline                               │
│                                                                  │
│  Developer Push → GitHub Actions → [DEPLOY GATE CHECK]          │
│                                         │                        │
│                              ┌──────────▼──────────┐            │
│                              │  Permission Protocol │            │
│                              │   Authorization API  │            │
│                              └──────────┬──────────┘            │
│                                         │                        │
│                          ┌──────────────▼──────────────┐        │
│                          │      Policy Evaluation       │        │
│                          │  • Action class permitted?   │        │
│                          │  • Scope within bounds?      │        │
│                          │  • Human approval required?  │        │
│                          └──────────────┬──────────────┘        │
│                                         │                        │
│                          ┌──────────────▼──────────────┐        │
│                          │    Cryptographic Receipt     │        │
│                          │  • Signed (ECDSA/Ed25519)    │        │
│                          │  • Timestamped (RFC 3161)    │        │
│                          │  • Bound to commit hash      │        │
│                          │  • Bound to principal ID     │        │
│                          │  • Immutable ledger entry    │        │
│                          └──────────────┬──────────────┘        │
│                                         │                        │
│              Valid Receipt → GitHub status check PASSES          │
│              No/Invalid Receipt → Merge BLOCKED                  │
└─────────────────────────────────────────────────────────────────┘
```

### Receipt Schema (Proposed Standard)

```json
{
  "receipt_id": "uuid-v4",
  "version": "1.0",
  "action": {
    "type": "code_deployment",
    "target": "production",
    "artifact": "commit:abc123def456",
    "repository": "org/repo"
  },
  "principal": {
    "agent_id": "deploy-bot-v2",
    "actor_id": "user:rod@example.com",
    "session_id": "session-xyz"
  },
  "authorization": {
    "policy_id": "deploy-policy-v3",
    "approver": "user:rod@example.com",
    "approved_at": "2026-02-26T14:30:00Z",
    "scope": ["staging", "production"],
    "expires_at": "2026-02-26T16:30:00Z"
  },
  "cryptography": {
    "algorithm": "Ed25519",
    "signature": "base64-encoded-signature",
    "signer_id": "pp-signer-us-west-1",
    "timestamp_token": "rfc3161-token"
  },
  "ledger_ref": "ledger://pp/receipts/2026/02/26/uuid"
}
```

### NIST Framework Mapping

| NIST Concept | PP Implementation |
|---|---|
| **Identify** agents and their capabilities | Agent identity bound to receipt (`principal.agent_id`) |
| **Manage** agent access and scope | Policy evaluation before receipt issuance; scope field in receipt |
| **Authorize** actions taken by agents | Cryptographic receipt is the authorization artifact |
| Zero Trust (verify every action) | "No receipt, no action" — binary enforcement |
| Non-repudiation (AU-10) | Signed, timestamped, ledger-anchored receipt |
| Least privilege (AC-6) | Scope binding in receipt limits action parameters |
| Audit trail (AU-2) | Append-only receipt ledger |
| Human oversight | Approval gate before receipt issuance for high-consequence actions |

---

## Appendix B — Evidence and References

### The OpenClaw Security Crisis (Feb 2026)

The largest documented real-world example of AI agent security failure at scale. Key facts:
- **42,665** publicly exposed instances (ClawHunter scan)
- **93.4%** had critical auth bypass vulnerabilities
- **26%** of third-party skills contained security vulnerabilities
- **770,000** agents at risk from unsecured database
- **35,000** emails + 1.5M agent tokens leaked via Supabase
- **6 CVEs** documented in February 2026 alone
- Supply chain attack: malicious npm package silently installed OpenClaw on Cline users

Sources:
- Astrix Security: https://astrix.security/learn/blog/openclaw-moltbot-the-rise-chaos-and-security-nightmare-of-the-first-real-ai-agent/
- SecurityWeek: https://www.securityweek.com/openclaw-security-issues-continue-as-secureclaw-open-source-tool-debuts/
- Cisco: https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare
- The Register: https://www.theregister.com/2026/02/09/openclaw_instances_exposed_vibe_code/
- DarkReading (supply chain): https://www.darkreading.com/application-security/supply-chain-attack-openclaw-cline-users

### Industry Research

- Gravitee "State of AI Agent Security 2026" (900+ executives surveyed): https://www.gravitee.io/blog/state-of-ai-agent-security-2026-report-when-adoption-outpaces-control
- Strata "AI Agent Identity Crisis": [TODO-ROD: Add link]
- Microsoft Security "Four priorities for AI-powered identity and network access security in 2026": https://www.microsoft.com/en-us/security/blog/2026/01/20/four-priorities-for-ai-powered-identity-and-network-access-security-in-2026/

### Key Quotes

> "From a capability perspective, groundbreaking. From a security perspective, an absolute nightmare." — Cisco

> "Massive access and identity problem created by poorly secured automation at scale." — The Register

> "If an agent cannot be constrained, it should not be trusted with production authority." — Netsync

> "Less than half feel confident they could pass a compliance review focused on agent behavior." — Strata/Gravitee research

### NIST Framework References

- NIST AI 100-1 (AI RMF)
- NIST AI 600-1 (GenAI Profile)
- NIST SP 800-207 (Zero Trust)
- NIST SP 800-53 Rev. 5 (AC-3, AC-6, AU-2, AU-9, AU-10, IA-2)
- NIST SP 800-218A (Secure Software Development for GenAI)

---

## [TODO-ROD] Sections Requiring Your Input

1. **Organization background / credentials** — Who is submitting this? Company formation status, team background, relevant expertise
2. **Competitive positioning** — How explicitly do we call out gaps in existing solutions (Astrix, etc.)?
3. **Policy recommendations** — How aggressive on "mandatory" vs. "voluntary" language?
4. **EU AI Act comparison (Section 5d)** — Keep brief or expand into a full comparative analysis?
5. **Contact information** — Submitter name, email, organization for the regulations.gov form
6. **Safe harbor language (Section 5b)** — Do you want to advocate for safe harbor explicitly?
7. **Word count / length** — This skeleton is ~4,500 words. NIST has no stated limit. Do you want to expand any sections or trim?
8. **Submit format** — Regulations.gov accepts plain text or PDF. Want me to format as a final PDF-ready doc after your review?

---

*Skeleton drafted by Charles | Issue #229 | 2026-02-26*
*Related: Issue #198 (full NIST RFI submission — blocked on Rod's review)*
