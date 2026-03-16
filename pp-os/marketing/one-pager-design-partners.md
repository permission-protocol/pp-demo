# Permission Protocol — Design Partner One-Pager

*Draft — for Rod's review*

---

## The Problem

AI agents are shipping to production without answers to three basic questions:

**Who approved this agent's access?** → Most teams can't point to a specific authorization for what their agents can do.

**What happens when it goes wrong?** → No kill switch. No escalation. The agent just keeps going at 3 AM.

**Can you prove it to your board?** → No audit trail. When a regulator or customer asks "how do you control your AI?", the answer is "we ran a scan once."

Scanning tools tell you what's broken. Nothing stops it from breaking.

---

## What Permission Protocol Does

**One enforcement layer for every agent action.**

```python
from permission_protocol import require_approval

@require_approval(resource="production", action="deploy")
def deploy_service():
    deploy("billing-api")
```

No authority receipt → no execution. Every action gated. Every decision logged.

**How it works:**

1. **Wrap** — Add `require_approval` to any agent action (deploy, send, delete, query — anything with consequences)
2. **Gate** — PP routes the request: auto-approve via policy, escalate to a human, or block. The agent waits.
3. **Receipt** — Every outcome (approved, denied, escalated, timed out) generates an immutable authority receipt with full audit trail

**What you get:**
- ✅ Human approval gates on high-stakes actions
- ✅ Policy engine for auto-approving routine actions
- ✅ Founder veto / kill switch — halt any agent instantly
- ✅ Immutable audit trail mapped to OWASP, NIST, ISO 42001, EU AI Act
- ✅ Works with any framework — LangChain, CrewAI, OpenAI Agents, MCP, custom

**SDKs:** Python + TypeScript. 5 minutes to integrate.

---

## Who This Is For

Teams shipping AI agents that touch real systems — deploy code, send emails, access databases, make payments, interact with customers.

If your agent can cause damage, it needs a permission layer.

---

## The Design Partner Ask

We're looking for **5 teams** to integrate Permission Protocol and shape the product:

**What you get:**
- Free access during the partner period (30 days minimum)
- Direct access to the founding team
- Your use cases shape the roadmap
- Priority support + custom integration help
- Compliance-ready audit trail from day one

**What we need:**
- A production (or near-production) AI agent with tool access
- 30 minutes/week for feedback
- Permission to reference you as an early adopter (optional, your call)

**Timeline:** Integration takes <1 day. First authority receipts flowing within hours.

---

## Why Now

- **OpenAI acquired Promptfoo** (AI security scanning) — $X00M+ signal that agent security is a category
- **Onyx Security raised $40M** (agent security control plane) — but focused on discovery/monitoring, not enforcement
- **OWASP Agentic Security Top 10** published — enterprises now have a framework to evaluate agent risk
- **EU AI Act enforcement begins 2026** — compliance isn't optional anymore

The assessment layer is getting crowded. The enforcement layer is empty. We're building it.

---

**Contact:** rod@permissionprotocol.com
**Site:** permissionprotocol.com
**GitHub:** github.com/permission-protocol
