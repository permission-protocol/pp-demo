# NIST CAISI RFI Response: Security Considerations for AI Agents
## Docket No. NIST-2025-0035 | Due: March 9, 2026

**Submitted by:** Permission Protocol (Roca Ventures, Inc.)
**Contact:** Rod [last name needed] | rod@permissionprotocol.com
**Date:** [To be submitted]

---

## About Permission Protocol

Permission Protocol is an open-source authorization framework for AI agent systems operating in production CI/CD environments. Our Deploy Gate product enforces cryptographically signed authorization receipts before AI-initiated code deployments can reach production. We operate at the intersection of AI agent capabilities and deployment security, providing fail-closed enforcement for autonomous production changes.

- **Open source:** [github.com/permission-protocol/deploy-gate](https://github.com/permission-protocol/deploy-gate)
- **Website:** [permissionprotocol.com](https://permissionprotocol.com)

---

## Topic 1: Unique Security Threats Affecting AI Agent Systems

### The Authorization Gap in Autonomous Deployment

The most underappreciated security threat in AI agent systems is the **authorization gap**: AI agents that can autonomously modify production systems without a discrete, verifiable authorization step between "agent decides" and "production changes."

**Case Study: OpenClaw (January–February 2026)**

In February 2026, Astrix Security documented that 42,665 OpenClaw AI agent instances were publicly exposed, with 93.4% having authentication bypass vulnerabilities. An estimated 770,000 agents were at risk. The root cause was not a software bug — it was an architectural pattern where authorization lived *inside* the agent. When the agent was compromised, all credentials and permissions it held were compromised.

**Case Study: AWS Kiro (December 2025)**

Amazon's AI coding agent Kiro caused a 13-hour AWS production outage after deciding to delete and recreate a production environment. The agent normally required two-human sign-off, but a permissions misconfiguration gave it single-operator access. Amazon's remediation was "staff training" — which does not address the architectural flaw.

### How These Threats Will Change Over Time

As AI agents become more capable and autonomous:
- **Scope expansion:** Agents will be granted broader production access across more systems
- **Speed amplification:** Autonomous actions will occur faster than human review cycles
- **Trust inflation:** Successful agent actions build organizational trust, leading to reduced oversight over time
- **Cascading failures:** Multi-agent systems may trigger chain reactions where one agent's output becomes another's input, with no authorization checkpoint between them

---

## Topic 2: Methods for Improving Security in Development and Deployment

### The Deploy Gate Pattern: Authorization External to the Agent

We propose that AI agent authorization should follow a **fail-closed, receipt-based** model:

1. **Separation of capability and authorization.** The agent should be able to *request* actions but never *grant itself* authorization. Authorization must be an external system the agent cannot bypass, forge, or inherit.

2. **Cryptographic receipts.** Every authorized action should produce an immutable, cryptographically signed receipt specifying:
   - What was authorized (specific commit SHA, repo, environment)
   - Who authorized it (human or policy identity)
   - When authorization was granted (timestamp + expiration)
   - A verifiable signature

3. **Fail-closed enforcement.** The default state must be *denied*. Absence of an authorization receipt must block the action — not log a warning, not send an alert. A hard stop.

4. **Scoped, time-limited authorization.** Each receipt authorizes one specific action. No blanket approvals. No persistent access tokens that an agent can reuse.

### Implementation Reference

Permission Protocol's Deploy Gate implements this pattern as a GitHub Action:

```yaml
- name: Deploy Gate
  uses: permission-protocol/deploy-gate@v1
```

When an AI agent opens a PR, the deploy pipeline checks for a signed receipt. If absent, the deploy is blocked and an approval URL is surfaced. A human reviews and approves. The receipt is generated, scoped to that specific commit, and verified by the pipeline independently of the agent.

The agent never holds production authorization. It cannot forge a receipt. It cannot bypass the gate.

---

## Topic 3: Gaps in Existing Cybersecurity Approaches

### Permissions ≠ Authorization

Existing IAM and RBAC systems answer: *"What is this identity allowed to do?"* They do not answer: *"Is this specific action, right now, approved?"*

The AWS Kiro incident illustrates this gap. AWS has the most sophisticated permissions system on the planet (IAM). Kiro had the *permissions* to delete the environment. It did not have *authorization* for that specific destructive action. No system enforced the difference.

### Gaps We Observe:

1. **No standard for agent action receipts.** There is no interoperable format for "proof that this action was authorized." Every organization invents its own audit trail (or doesn't).

2. **Agent identity is conflated with operator identity.** AI agents typically inherit their operator's credentials. When the operator has broad access, the agent does too — regardless of whether the specific action was reviewed.

3. **Monitoring is reactive, not preventive.** Current approaches detect unauthorized actions after they occur. For irreversible actions (production deployments, data deletions, infrastructure changes), detection is insufficient. Prevention is required.

4. **No fail-closed default.** Most CI/CD systems default to *allow*. If a security check fails to run (misconfiguration, timeout, outage), the action proceeds. For AI agent actions, the default should be *deny*.

---

## Topic 4: Methods for Measuring Security of AI Agent Systems

### Proposed Metrics

1. **Authorization coverage:** What percentage of an AI agent's production-impacting actions require a discrete authorization step?

2. **Receipt verifiability:** Can a third party independently verify that a specific action was authorized, by whom, and with what scope?

3. **Fail-closed ratio:** When the authorization system is unavailable, what percentage of agent actions are blocked (vs. allowed by default)?

4. **Scope precision:** How narrowly is each authorization scoped? (e.g., "deploy anything to production" vs. "deploy commit abc123 to production in repo X")

5. **Time-to-audit:** How quickly can an organization produce a complete chain of authorization for any given production change?

### Evaluation Methodology

We recommend a **red-team framework** for AI agent authorization:
- Can the agent deploy to production without human authorization?
- Can the agent escalate its own permissions?
- If the authorization system is offline, does the agent's action proceed or block?
- Can the agent forge or reuse an authorization receipt?
- Can a compromised agent access authorization receipts for other actions?

---

## Topic 5: Deployment Environment Interventions

### Constraining Agent Access

1. **External authorization gates in CI/CD pipelines.** Every production deployment pipeline should include a mandatory gate that verifies an authorization receipt before proceeding. This gate must be external to the agent and independently verifiable.

2. **Least-privilege by default with explicit escalation.** AI agents should start with no production access. Each production-impacting action requires a scoped, time-limited receipt. This is more granular than traditional role-based access.

3. **Separation of agent runtime and authorization service.** The system that grants authorization must be architecturally separated from the agent. Compromising the agent should not compromise the authorization layer.

### Monitoring Agent Access

4. **Immutable audit trails.** Every authorization decision (grant and denial) should be logged immutably. These logs should be queryable by action, agent, authorizer, and time range.

5. **Anomaly detection on authorization patterns.** Monitor for unusual patterns: agents requesting authorization outside normal hours, for unusual scopes, or at unusual frequency.

---

## Recommendations for NIST Guidelines

1. **Establish a standard format for AI agent authorization receipts.** An interoperable receipt format would enable cross-platform verification, third-party auditing, and regulatory compliance.

2. **Require fail-closed defaults for AI agent production access.** Guidelines should recommend that AI agents be denied production access by default, with explicit authorization required for each action.

3. **Distinguish "permissions" from "authorization" in agent security frameworks.** Current frameworks conflate these concepts. Permissions define capability ceilings. Authorization gates specific actions.

4. **Mandate separation of agent identity and operator identity.** AI agents should have distinct, auditable identities — not inherit operator credentials.

5. **Encourage open-source reference implementations.** Standards are most effective when accompanied by working implementations that organizations can adopt and audit.

Permission Protocol offers Deploy Gate as a candidate reference implementation for CI/CD authorization gating. It is open source, actively maintained, and deployed in production environments.

---

## Conclusion

The security challenge of AI agent systems is not primarily about securing the agent itself — it is about securing the *authorization layer* between agent intention and real-world impact. The OpenClaw and AWS Kiro incidents demonstrate that even sophisticated organizations fail when authorization lives inside the agent or depends on correct permissions configuration.

We urge NIST to prioritize standards for **external, cryptographic, fail-closed authorization** as a foundational security primitive for AI agent systems. The technology exists today. What is needed is standardization and adoption.

We welcome the opportunity to collaborate with CAISI and ITL on developing these standards.

---

**# STATUS: DRAFT — NEEDS ROD'S REVIEW BEFORE SUBMISSION**
**Submit at:** regulations.gov, docket NIST-2025-0035
**Deadline:** March 9, 2026, 11:59 PM ET
