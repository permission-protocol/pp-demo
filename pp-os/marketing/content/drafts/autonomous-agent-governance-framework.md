# Autonomous Agent Governance Framework
### An open specification for runtime authority control in AI agent systems

**Version:** 0.1.0-draft
**Initiated by:** Permission Protocol — open to community contribution
**License:** CC BY 4.0
**Status:** Request for Comments

---

## Abstract

Autonomous AI agents are operating in production with access to databases, APIs, deployment pipelines, customer data, and financial systems. Most have no runtime governance — no structured permission model, no approval gates, no audit trail, and no kill switch.

This document defines a minimum governance framework for autonomous agent systems. It is framework-agnostic and implementation-independent. The goal is to establish a shared vocabulary and set of requirements that any team deploying autonomous agents can adopt.

---

## 1. Why This Exists

In the first quarter of 2026 alone:

- An autonomous coding agent at Amazon deleted production infrastructure during an unsupervised sprint window, according to reporting by Particula [1].
- An IBM customer-service agent began approving refunds outside policy guidelines, with no mechanism to detect or halt the behavior in real time, as reported by CNBC [2].
- A Northeastern University study deployed six autonomous agents in a live environment. Within two weeks, researchers documented social engineering vulnerabilities, unauthorized data sharing, and one agent resetting an entire email server to delete a single message [3].
- StellarCyber's threat tracking identified 520+ tool misuse and privilege escalation incidents across autonomous agent deployments in 2025-2026 [4].

These are not edge cases. They are the predictable result of deploying agents without governance primitives.

Security scanning identifies what *could* go wrong. Governance defines what *is not allowed* to go wrong, and enforces it at runtime.

A common response is "we already have RBAC and IAM for this." Traditional access control authorizes humans who make predictable, low-frequency requests. Agents make thousands of autonomous decisions per hour, and their behavior drifts over time in ways human users' behavior does not. Traditional audit logs record what happened — but not the agent's reasoning or the policy it evaluated. And traditional access control is static: it can't detect that an agent's *pattern* of authorized actions has changed in ways that indicate a problem. Agent governance requires runtime awareness that existing IAM was not designed for.

---

## 2. Core Concepts

### 2.1 Authority Receipt

Every action an autonomous agent takes in a governed system must produce an **authority receipt** — a structured, immutable record that answers:

- **Who** authorized this action? (human, policy engine, or escalation chain)
- **What** action was authorized? (resource, operation, scope)
- **When** was authorization granted? (timestamp, TTL)
- **Why** was it authorized? (policy reference, approval context)
- **What happened?** (outcome, success/failure, side effects)

If an action does not have a corresponding authority receipt, it does not execute. This is the foundational primitive.

### 2.2 Permission Boundary

A permission boundary defines the set of actions an agent *can* take without escalation. Everything outside the boundary requires explicit approval.

Boundaries should be:
- **Declarative** — defined in configuration, not scattered through code
- **Granular** — per-resource, per-operation, not just "read" or "write"
- **Auditable** — every boundary change produces its own receipt
- **Dynamic** — adjustable at runtime without redeployment

### 2.3 Approval Gate

An approval gate is a synchronous checkpoint where an agent action is held pending human or policy review. Gates are required for:

- **High-stakes operations** — production deployments, financial transactions, data deletion, external communications
- **Boundary crossings** — actions outside the agent's declared permission boundary
- **Anomaly triggers** — actions that match patterns flagged by monitoring (unusual frequency, scope, or timing)

Gate types:
| Type | Mechanism | Latency |
|---|---|---|
| Human-in-the-loop | Specific human must approve | Minutes to hours |
| Policy-based | Automated rule evaluation | Milliseconds |
| Escalation chain | Sequential approvers with timeout fallback | Configurable |
| Emergency override | Override authority for any action | Immediate |

#### Latency and Fallback

Approval gates introduce latency. For time-sensitive operations, the framework requires a defined fallback policy:

- **Timeout with default-deny:** If no approval is received within the TTL, the action is blocked. This is the safe default.
- **Timeout with default-allow:** If no approval is received within the TTL, the action proceeds. Use only for low-risk operations where blocking causes greater harm than executing.
- **Escalation chain with timeout:** If the primary approver does not respond, the request moves to the next approver in the chain. If the chain is exhausted, the timeout policy applies.

The fallback policy must be declared per gate, not globally. A deployment gate and a log-read gate should not share the same timeout behavior.

### 2.4 Kill Switch

Every governed agent system must have a kill switch that can:

- **Halt** a specific agent immediately
- **Halt** all agents in a scope (org, project, environment)
- **Preserve state** — the kill switch stops execution, it does not destroy context
- **Be triggered** by any authorized human, by policy violation, or by an anomaly detector

A kill switch that requires a code deploy is not a kill switch.

### 2.5 Audit Trail

The audit trail is the complete, append-only record of every authority receipt, every approval decision, every denial, every escalation, and every kill switch activation.

Requirements:
- **Immutable** — entries cannot be modified or deleted
- **Queryable** — "show me every action agent X took on resource Y in the last 24 hours"
- **Mappable** — entries map to compliance frameworks (OWASP, NIST AI RMF, ISO 42001)
- **Exportable** — available via API for external audit tools and regulators

---

## 3. Governance Levels

Not every agent needs the same governance. This framework defines four levels based on the blast radius of the agent's actions.

### Level 0: Logging Only
- All actions produce receipts
- No enforcement, no gates
- Minimum viable governance for any agent in production

### Level 1: Boundary Enforcement
- Permission boundaries enforced at runtime
- Actions outside boundaries are blocked (not just logged)

### Level 2: Approval Gates
- High-stakes actions require explicit approval
- Approval decisions are recorded in the audit trail
- Kill switch available

### Level 3: Full Governance
- All Level 2 requirements
- Emergency override capability (any authorized human can override any gate or boundary)
- Anomaly detection triggers automatic gates
- Real-time monitoring dashboard
- Compliance mapping (OWASP [5], NIST AI RMF [6], ISO 42001 [7])

#### Decision Matrix: Minimum Governance Level

| If your agent can... | Minimum Level |
|---|---|
| Read data, no external side effects | Level 0 |
| Write to internal systems (logs, caches, non-production DBs) | Level 1 |
| Send emails, messages, or notifications to humans | Level 2 |
| Access customer data or PII | Level 2 |
| Execute financial transactions (payments, refunds, transfers) | Level 2 |
| Deploy code to production | Level 2 |
| Delete data or modify infrastructure | Level 2 |
| Operate with broad, multi-system access and high autonomy | Level 3 |
| Operate in a regulated industry (healthcare, finance, government) | Level 3 |

---

## 4. Implementation Patterns

### 4.1 Wrapper Pattern (Recommended Starting Point)

Wrap every tool call in a governance check:

```python
# Before: ungoverned
def deploy_service(service_name):
    run_deploy(service_name)

# After: governed
@require_authority(resource="production", action="deploy", level=2)
def deploy_service(service_name):
    run_deploy(service_name)
```

The wrapper intercepts the call, checks the permission boundary, triggers an approval gate if required, generates the authority receipt, and logs the result.

### 4.2 Middleware Pattern

For frameworks with a plugin or middleware architecture (LangChain, CrewAI, AutoGPT), implement governance as middleware that intercepts tool invocations before execution.

```
Agent → Governance Middleware → Tool Execution → Receipt
```

### 4.3 Proxy Pattern

For agents that interact with external APIs, route calls through a governance proxy that enforces boundaries at the network level.

```
Agent → HTTP Request → Governance Proxy → External API
```

---

A formal API specification and reference schemas for authority receipts, permission boundaries, and audit trail entries are planned for v0.2 of this framework.

---

## 5. What This Framework Does Not Cover

- **Model safety** — prompt injection, jailbreaks, alignment. These are important but distinct from runtime governance.
- **Vulnerability scanning** — identifying potential weaknesses in agent code or configuration. Scanning is complementary to governance; this framework assumes you are also scanning.
- **Agent orchestration** — how agents are scheduled, coordinated, or scaled. Governance applies regardless of orchestration method.

---

## 6. Adopting This Framework

**Step 1:** Instrument your agents with receipt logging (Level 0). This alone gives you an audit trail.

**Step 2:** Define permission boundaries for each agent. Document what each agent is authorized to do.

**Step 3:** Add approval gates for high-stakes operations (Level 2). Start with deployments and data mutations.

**Step 4:** Implement a kill switch. Test it. Test it again.

**Step 5:** Map your audit trail to your compliance requirements.

---

## 7. Reference Implementation

[Permission Protocol](https://permissionprotocol.com) provides an open-source reference implementation of this framework, including:

- SDK for Python, TypeScript, and CLI
- GitHub Action for deploy-gate enforcement
- Dashboard for approval management and audit trail
- Policy engine for automated boundary enforcement

The reference implementation is one way to adopt this framework. The framework itself is implementation-independent.

---

## 8. References

[1] "When AI Agents Delete Production: Lessons from Amazon's Kiro Incident." Particula, March 2026. https://particula.tech/blog/ai-agent-production-safety-kiro-incident

[2] "'Silent failure at scale': The AI risk that can tip the business world into disorder." CNBC, March 1, 2026. https://www.cnbc.com/2026/03/01/ai-artificial-intelligence-economy-business-risks.html

[3] Shapira, N., Riedl, C., et al. "Agents of Chaos." Northeastern University / Bau Lab, 2026. https://arxiv.org/abs/2602.20021

[4] "Top Agentic AI Security Threats in Late 2026." StellarCyber, March 2026. https://stellarcyber.ai/learn/agentic-ai-securiry-threats/

[5] OWASP Top 10 for LLM Applications. https://owasp.org/www-project-top-10-for-large-language-model-applications/

[6] NIST AI Risk Management Framework (AI RMF 1.0). https://www.nist.gov/artificial-intelligence/risk-management-framework

[7] ISO/IEC 42001:2023 — Artificial Intelligence Management System. https://www.iso.org/standard/81230.html

---

## Contributing

This is a living specification. We welcome feedback, corrections, and contributions.

- **GitHub:** [permission-protocol/governance-framework](https://github.com/permission-protocol/governance-framework)
- **Discord:** [Permission Protocol Community](https://discord.gg/permissionprotocol)
