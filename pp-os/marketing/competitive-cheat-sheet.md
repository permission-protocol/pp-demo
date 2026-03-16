# Competitive Cheat Sheet — INTERNAL ONLY

*Last updated: 2026-03-16*

---

## Universal Framing

When anyone asks "how are you different from X?":

> "They tell you what's wrong. We make sure it can't go wrong. Scanners are the safety inspection. Permission Protocol is the seatbelt. You want both — but only one saves you in the crash."

Then pivot to the Three Questions:
1. Who approved this agent's access?
2. What happens when it goes wrong?
3. Can you prove it to your board?

"Scanners answer a version of question 1. Nobody answers 2 and 3. We answer all three."

---

## Guard0 (g0)

**What they do:** CLI security scanner + adversarial red-teaming for agent codebases. 1,200+ rules, 4,000+ attack payloads, compliance mapping to OWASP/NIST/ISO.

**Overlap:** Low. They're pre-deployment assessment. We're runtime enforcement. Messaging overlap on "control layer" though.

**Their strengths:**
- Beautiful developer UX (npx one-liner, pretty CLI output)
- Massive rule coverage (10 frameworks, 5 languages)
- Compliance mapping on every finding
- OpenClaw-specific tooling (riding ClawHavoc news cycle)
- Free cloud dashboard (PLG funnel)

**Their gaps:**
- No runtime enforcement — scan tells you problems, doesn't prevent them
- No approval gates or human-in-the-loop
- No audit trail of actual agent behavior in production
- Unknown team / no public funding / ghost company vibes

**Counter:** "g0 is a great scan tool — we'd recommend it alongside PP. They find the gaps in your code. We make sure those gaps can't be exploited at runtime. Use g0 to audit, use PP to enforce."

**Complementary, not competitive (for now).** Watch for them adding runtime features.

---

## Onyx Security

**What they do:** "Secure AI control plane" — discovers, monitors, and governs autonomous agents across cloud, endpoints, code, and SaaS. $40M funding from Conviction + Cyberstarts. Israeli team.

**Overlap:** Medium-high. Their language ("control plane", "govern") is very close to ours.

**Their strengths:**
- $40M in funding — can move fast, hire aggressively
- Enterprise credibility (already working with "major corporations")
- Broad surface: cloud + endpoints + code + SaaS
- Discovery/inventory angle (what agents exist in your org?)

**Their gaps:**
- Enterprise-first = slow, complex, big deal sizes
- "Control plane" is vague — monitor and govern, but do they actually block?
- No open-source CLI, no PLG motion visible
- Top-down sale vs our bottom-up SDK adoption

**Counter:** "Onyx helps enterprises discover what agents they have. Permission Protocol gives every agent a permission layer before it can act. They're org-level visibility. We're action-level enforcement. Different layers."

**The real risk:** If they build a lightweight SDK or developer tool, they have the money to compete directly. Watch their product launches closely.

---

## Promptfoo (acquired by OpenAI, March 2026)

**What they do:** AI model testing/red-teaming. Find security issues during development. Now part of OpenAI.

**Overlap:** Low. They're model-level testing. We're agent-level governance.

**Their strengths:**
- OpenAI acquisition = distribution (every OpenAI customer gets access)
- Strong open-source community pre-acquisition
- Good adversarial testing framework

**Their gaps:**
- Model-focused, not agent-focused (no tool/action governance)
- Now part of OpenAI = vendor lock-in perception
- Unlikely to support non-OpenAI frameworks aggressively post-acquisition

**Counter:** "Promptfoo tests your model. PP governs your agent. Models generate text — agents take actions. Actions need permission."

---

## Generic RBAC / AuthZ (Permit.io, Oso, Cerbos, etc.)

**What they do:** Role-based access control and authorization for traditional applications.

**Overlap:** Conceptual — both are "permission" systems. But different layer entirely.

**Counter:** "RBAC controls what users can do in your app. PP controls what AI agents can do in your infrastructure. Users authenticate and get roles. Agents need authority receipts — explicit, auditable, revocable permission for every action. It's authorization designed for autonomous systems, not human sessions."

---

## "We'll build it ourselves"

The most common competitor.

**Counter:** "You absolutely can. Here's what you're building: request/approval workflow, policy engine, human escalation routing, timeout handling, receipt storage, signature verification, audit trail, compliance mapping, kill switch, and a dashboard. That's 3-6 months of engineering. Or you `pip install permission-protocol` and have receipts flowing in an hour. Your engineers should build your product, not your permission layer."

---

## Quick Reference Table

| | Guard0 | Onyx | Promptfoo | PP |
|---|---|---|---|---|
| **Layer** | Pre-deploy scan | Org discovery/monitoring | Model testing | Runtime enforcement |
| **Approach** | Find vulnerabilities | Find & monitor agents | Test model safety | Prevent unauthorized actions |
| **When** | Before deploy | After deploy (observe) | During development | During execution (real-time) |
| **Output** | Report | Dashboard | Test results | Authority receipts |
| **Blocks actions?** | No | Unclear | No | **Yes** |
| **Audit trail?** | Scan results | Monitoring logs | Test logs | **Immutable receipts per action** |
| **Human-in-loop?** | No | Unclear | No | **Yes — approval gates** |
| **Kill switch?** | No | Unclear | No | **Yes** |
| **Developer UX** | ⭐⭐⭐⭐⭐ | ⭐⭐ (enterprise) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ (building) |
| **Pricing** | Free + Cloud | Enterprise | Free (OpenAI) | Free tier + paid |

---

*Update this when new competitors appear. Check monthly.*
