# Competitive Cheat Sheet — INTERNAL ONLY

*Last updated: 2026-03-16*

---

## Universal Framing

When anyone asks "how are you different from X?":

> "They find vulnerabilities. We prevent unauthorized actions. Assessment tools are valuable — every team should use one. But finding a risk and stopping it from materializing are different things. We're the enforcement layer."

Then pivot to the Three Questions:
1. Who approved this agent's access?
2. What happens when it goes wrong?
3. Can you prove it to your board?

"Assessment tools help with question 1. Questions 2 and 3 require runtime governance. That's what we built."

---

## Guard0 (g0)

**What they do:** CLI security scanner + adversarial red-teaming for agent codebases. 1,200+ rules, 4,000+ attack payloads, compliance mapping to OWASP/NIST/ISO.

**Overlap:** Low. Pre-deployment assessment vs our runtime enforcement. Their "control layer" messaging is close to our positioning though.

**Their strengths:**
- Strong developer UX — npx one-liner, polished CLI output
- Wide framework coverage (10 frameworks, 5 languages)
- Compliance mapping on every finding
- OpenClaw-specific tooling (leveraging ClawHavoc news cycle)
- Free cloud dashboard as PLG funnel

**Their gaps:**
- No runtime enforcement — findings are reports, not prevention
- No approval gates or human-in-the-loop
- No audit trail of actual agent behavior in production
- Unknown team, no public funding, no visible company info

**In conversation:** "g0 is a solid scanning tool — we'd recommend using it alongside PP. They identify gaps in your code. We make sure those gaps can't be exploited at runtime. Assessment and enforcement are complementary layers."

**Watch for:** Runtime enforcement features. If they move past scanning into blocking, overlap increases significantly.

---

## Onyx Security ($40M, Conviction + Cyberstarts)

**What they do:** "Secure AI control plane" — discovers, monitors, and governs autonomous agents across cloud, endpoints, code, and SaaS. Israeli team, already working with large enterprises.

**Overlap:** Medium-high. Their language ("control plane", "govern") is close to ours.

**Their strengths:**
- $40M in funding — can move fast and hire aggressively
- Enterprise credibility from day one
- Broad surface coverage: cloud + endpoints + code + SaaS
- Discovery/inventory angle (what agents exist across your org?)

**Their gaps:**
- Enterprise-first approach = slower, more complex, larger deal sizes
- "Control plane" positioning is broad — unclear how much is monitoring vs actual enforcement
- No visible open-source CLI or developer-first PLG motion
- Top-down enterprise sale vs our bottom-up SDK adoption

**In conversation:** "Onyx helps enterprises discover and monitor what agents they have across their organization. PP gives each agent a permission layer at the code level — every action gated, every decision logged. They're organizational visibility. We're action-level enforcement."

**Watch for:** A lightweight SDK or developer tool. They have the funding to compete at our layer if they choose to.

---

## Promptfoo (acquired by OpenAI, March 2026)

**What they do:** AI model testing and red-teaming. Find security issues during development. Now part of OpenAI.

**Overlap:** Low. Model-level testing vs agent-level governance.

**Their strengths:**
- OpenAI acquisition = massive distribution to every OpenAI customer
- Strong open-source community pre-acquisition
- Solid adversarial testing framework

**Their gaps:**
- Model-focused, not agent-focused (no tool or action governance)
- Now part of OpenAI = vendor lock-in perception for non-OpenAI users
- Less likely to invest in non-OpenAI framework support post-acquisition

**In conversation:** "Promptfoo tests model behavior. PP governs agent actions. Models generate text — agents take actions in the real world. Those actions need explicit permission."

---

## Generic AuthZ (Permit.io, Oso, Cerbos, etc.)

**What they do:** Role-based access control and authorization for traditional applications.

**Overlap:** Conceptual — both involve permissions. Different layer entirely.

**In conversation:** "RBAC controls what users can do in your app. PP controls what AI agents can do in your infrastructure. Users have sessions and roles. Agents need authority receipts — explicit, auditable, revocable permission for every individual action. Authorization designed for autonomous systems is fundamentally different from human session auth."

---

## "We'll build it ourselves"

The most common competitor.

**In conversation:** "You can. Here's the scope: request/approval workflows, a policy engine, human escalation routing, timeout handling, receipt storage, signature verification, immutable audit trail, compliance mapping, kill switch, and a management dashboard. That's 3-6 months of dedicated engineering. Or you run `pip install permission-protocol` and have receipts flowing in an hour. Your engineers should be building your product, not your permission infrastructure."

---

## Quick Reference

| | Guard0 | Onyx | Promptfoo | PP |
|---|---|---|---|---|
| **Layer** | Pre-deploy scan | Org discovery + monitoring | Model testing | Runtime enforcement |
| **Approach** | Find vulnerabilities | Find and monitor agents | Test model safety | Prevent unauthorized actions |
| **When** | Before deploy | After deploy (observe) | During development | During execution (real-time) |
| **Output** | Scan report | Monitoring dashboard | Test results | Authority receipts |
| **Blocks actions?** | No | Unclear | No | **Yes** |
| **Audit trail?** | Scan results | Monitoring logs | Test logs | **Immutable receipt per action** |
| **Human-in-loop?** | No | Unclear | No | **Yes — approval gates** |
| **Kill switch?** | No | Unclear | No | **Yes** |
| **Developer UX** | ⭐⭐⭐⭐⭐ | ⭐⭐ (enterprise) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ (building) |

---

*Review and update monthly, or when a new competitor appears.*
