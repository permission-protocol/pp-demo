# LinkedIn Day 14 Pivot — #2 Contacts
**Date:** April 20, 2026
**Batch:** LinkedIn Pivot (idea-099)
**Status:** DRAFTED — Awaiting Rod Approval

---

## Strategy
If the primary founder (sent Apr 7) hasn't responded after 14 days, we pivot to the engineering lead / CTO (#2 contact). 
**Angle:** "I messaged [Founder] about the agent authorization gap. Since [Company] is [specific context], I thought I'd loop you in too."

---

## 1. Cognition AI (Devin)
**Contact:** [Steven Hao](https://www.linkedin.com/in/stevenhao/) (CTO / Co-founder)
**Context:** Scott Wu messaged Apr 7. 
**Draft:**
```
Steven — I messaged Scott a couple of weeks ago about the agent authorization gap, but I wanted to loop you in as well.

With Devin becoming the first true autonomous software engineer, the question for your enterprise customers shifts from "can it code?" to "who authorized this deploy?"

We built Permission Protocol to be that enforcement gate. It issues cryptographic authorization receipts (Ed25519) before any agent action executes. For Devin, this means every production push or infra change is bound to a signed receipt.

Feels like the missing governance layer for Devin's enterprise access. Worth a 15-min sync?
```

---

## 2. Cursor (Anysphere)
**Contact:** [Aman Sanger](https://www.linkedin.com/in/amansanger/) (Founder)
**Context:** Michael Truell messaged Apr 7.
**Draft:**
```
Aman — reaching out because I messaged Michael earlier this month about the "Signer" boundary for AI code editors.

Cursor is dominating the agentic IDE space, but as you move into more autonomous fix/deploy loops, the governance gap is widening. Enterprise teams need to know exactly who (human or principal) authorized an agent's change before it hits the repo.

Permission Protocol issues cryptographic receipts for every action. Integrating a "Signer" mode into Cursor would give your enterprise users the immutable audit trail they need.

Open to a quick chat on how this fits the Cursor roadmap?
```

---

## 3. crewAI
**Contact:** [Heitor Carvalho](https://www.linkedin.com/in/heitorado/) (Software Engineer)
**Context:** João Moura messaged Apr 7.
**Draft:**
```
Heitor — I messaged João a couple of weeks ago, but since you're in the trenches of the framework, I wanted to share this with you too.

CrewAI is the go-to for multi-agent orchestration, but there's an authorization vacuum in the execution layer. When a crew agent calls a tool or moves money, there’s no external, signed proof of authority.

We built Permission Protocol specifically for this. It’s an authorization gate: no signed receipt = action blocked.

Would love to explore a reference implementation for CrewAI + Permission Protocol. 15 minutes?
```

---

## 4. LangChain
**Contact:** [Ankush Gola](https://www.linkedin.com/in/ankushgola/) (Co-founder)
**Context:** Harrison Chase messaged Apr 7.
**Draft:**
```
Ankush — I reached out to Harrison earlier this month about the authorization gap in the LangChain ecosystem.

Monitoring (LangSmith) is great for observability, but enterprise agents need hard enforcement. They need to prove an action was authorized *before* it executed, not just log it after.

Permission Protocol issues cryptographic authorization receipts for every tool call. It’s the "enforcement gate" that sits alongside LangChain's orchestration.

Interested in how this could complement the LangChain stack for enterprise security?
```

---

## 5. Railway
**Contact:** [Greg Terrono](https://www.linkedin.com/in/gregterrono/) (CTO)
**Context:** Jake Cooper messaged Apr 7.
**Draft:**
```
Greg — I messaged Jake a couple of weeks ago about the agent deploy boundary on Railway.

As more teams use AI agents to manage infra and deploy code to Railway, the governance surface area is exploding. Teams need an immutable audit trail proving every agent-driven infra change was authorized.

Permission Protocol issues Ed25519-signed receipts before execution. It’s the missing "Signer" decision for autonomous infra.

Would love to see if this makes sense for Railway’s enterprise customers. 15 minutes?
```

---

## 6. Trigger.dev
**Contact:** [Matt Aitken](https://www.linkedin.com/in/mattaaitken/) (Co-founder)
**Context:** James Perkins messaged Apr 7.
**Draft:**
```
Matt — I messaged James earlier this month about the authorization gap in autonomous background jobs.

Trigger.dev is the backbone for a lot of agentic workflows, but when those jobs hit high-consequence APIs (Stripe, AWS), there’s no cryptographic proof of authority.

Permission Protocol issues signed receipts before the job executes the action. No receipt = action blocked.

Worth 15 minutes to discuss how this could secure Trigger.dev workflows for your security-conscious users?
```

---

## 7. Ramp
**Contact:** [Karim Atiyeh](https://www.linkedin.com/in/katiyeh/) (CTO)
**Context:** Eric Glyman messaged Apr 7.
**Draft:**
```
Karim — I messaged Eric a couple of weeks ago about the authorization vacuum in agentic finance.

Ramp is the gold standard for spend management, but as "AI accountants" and agents start touching financial flows, the old approval models break. You need cryptographic proof that an agent action (payment, adjustment) was authorized by a human/principal before it runs.

We built Permission Protocol for exactly this. Ed25519-signed authorization receipts, pre-action enforcement, tamper-evident audit.

15 minutes to show you how we're solving the AI authorization problem for finance?
```

---

## Rod's Copy-Paste Command
If you approve of these pivot targets and drafts:
`APPROVE pivot-batch-099`
