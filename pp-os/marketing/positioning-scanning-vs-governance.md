# Scanning Isn't Control. Here's the Difference.

*Draft — for Rod's review before publishing*

---

AI security tools are having their moment. Scanners, red-teamers, compliance checkers — they all answer some version of the same question: **"Is your agent safe?"**

Good question. Wrong stopping point.

Knowing your door is unlocked doesn't lock it. A scan report that says "your agent can send emails without approval" is useful exactly once — when you read it. After that, it's a PDF in someone's inbox.

## The Three Questions

Before you ship an AI agent, you need answers to three things:

**1. Who approved this agent's access?**
Not "does it have access" — that's an inventory. Who *authorized* it? Is there a name, a timestamp, a policy? Can you point to the human who said "yes, this agent can touch production"?

**2. What happens when it goes wrong?**
Not "could it go wrong" — that's an assessment. When the agent makes a bad call at 3 AM, what stops it? Is there a kill switch? Does it escalate? Or does it just... keep going?

**3. Can you prove it to your board?**
Not "do you have a compliance report" — that's a checkbox. When your board (or regulator, or customer) asks "how do you control your AI agents?", can you show them a live audit trail of every action, every approval, every denial?

## Two Layers, Both Necessary

**Security assessment** tools (scanners, red-teamers) answer: *"Here's what could go wrong."*

They find the vulnerabilities. Unprotected tool calls. Shared memory. Missing input validation. This is valuable work. Every team should do it.

**Runtime governance** answers: *"Here's what we won't let go wrong."*

It enforces permission boundaries on every agent action, in production, in real time. Not a report — a gate. The agent literally cannot deploy, send, delete, or access without an authority receipt.

One tells you the problem. The other prevents it.

## The Seatbelt Analogy

A safety inspection tells you your seatbelt is broken. Good to know.

A seatbelt saves you in the crash. Essential to have.

You need the inspection. But if you had to pick one, you'd pick the seatbelt. Because the crash doesn't wait for your remediation sprint.

## What This Means In Practice

An agent with a security scan and no runtime governance:
- ✅ Knows it has 5 unprotected tool calls
- ❌ Still executes all 5 in production
- ❌ No audit trail when things go wrong
- ❌ No way to prove control to customers/regulators

An agent with runtime governance:
- ✅ Every tool call requires an authority receipt
- ✅ Humans approve high-stakes actions before execution
- ✅ Kill switch halts any agent instantly
- ✅ Immutable audit trail maps to OWASP, NIST, ISO
- ✅ Compliance is a byproduct, not a project

Best case: use both. Scan to find gaps. Govern to enforce boundaries.

## Permission Protocol

We built the governance layer. One SDK call wraps any agent action in an authority receipt:

```python
@require_approval(resource="production", action="deploy")
def deploy_service():
    deploy("billing-api")
```

No receipt, no execution. Every approval logged. Every denial recorded. Every escalation tracked.

That's the difference between knowing what's wrong and making sure it can't happen.

---

*[CTA: Try `npx @permission-protocol/cli scan .` to see what's unprotected → then install the SDK to enforce it]*
