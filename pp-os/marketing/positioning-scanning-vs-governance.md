# Scanning Isn't Control. Here's the Difference.

*Draft v2 — for Rod's review before publishing*

---

AI security tools are having their moment. Scanners, red-teamers, compliance checkers — all focused on the same question: **"Is your agent safe?"**

That's an important question. But it's not the only one.

A scan that says "your agent can send emails without approval" is useful when you read it. After that, the vulnerability still exists. Knowing about it and preventing it are different things.

## The Three Questions

Before you ship an AI agent, you need answers to three things:

**1. Who approved this agent's access?**
There should be a name, a timestamp, and a policy behind every action your agent can take. A specific human who said "yes, this agent can touch production."

**2. What happens when it goes wrong?**
When the agent makes a bad call at 3 AM, what stops it? Is there a kill switch? Does it escalate to a human? Or does it keep running?

**3. Can you prove it to your board?**
When a regulator or customer asks "how do you control your AI agents?", you need a live audit trail of every action, every approval, every denial — not a scan report from last quarter.

## Two Layers, Both Necessary

**Security assessment** tools (scanners, red-teamers) answer: *"Here's what could go wrong."*

They find vulnerabilities — unprotected tool calls, shared memory, missing input validation. This is valuable work. Every team should do it.

**Runtime governance** answers: *"This is what we won't allow to go wrong."*

It enforces permission boundaries on every agent action, in production, in real time. The agent cannot deploy, send, delete, or access without an authority receipt.

Assessment identifies problems. Governance prevents them.

## What This Looks Like In Practice

An agent with a security scan and no runtime governance:
- ✅ Identified 5 unprotected tool calls
- ❌ All 5 still execute in production
- ❌ No audit trail when something breaks
- ❌ No evidence of control for customers or regulators

An agent with runtime governance:
- ✅ Every tool call requires an authority receipt
- ✅ High-stakes actions require human approval before execution
- ✅ Kill switch can halt any agent instantly
- ✅ Immutable audit trail mapped to OWASP, NIST, ISO
- ✅ Compliance is a byproduct of how the system works

The strongest setup uses both. Scan to find gaps. Govern to enforce boundaries.

## Permission Protocol

We built the governance layer. One SDK call wraps any agent action in an authority receipt:

```python
@require_approval(resource="production", action="deploy")
def deploy_service():
    deploy("billing-api")
```

No receipt, no execution. Every approval logged. Every denial recorded. Every escalation tracked.

Assessment tells you where the risk is. Governance makes sure the risk doesn't materialize.

---

*[CTA: Try `npx @permission-protocol/cli scan .` to find unprotected actions → then install the SDK to enforce boundaries]*
