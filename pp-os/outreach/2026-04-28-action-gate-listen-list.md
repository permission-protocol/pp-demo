# Action Gate Listen-First Outreach List

**Created:** 2026-04-28
**Purpose:** 5 listening calls with customer-facing AI agent founders by May 3 evening.
**Send rate:** 30 DMs over 3 days (10/day). Quality > volume.
**Channel:** LinkedIn primary, X secondary. NO guessed emails.
**Day 14 pivot rule:** if primary contact ghosts after Day 14, hit secondary at same company.

## ICP filter (every company must pass all 5)

1. ✅ Sells AI agents (not "AI-powered features" inside another product)
2. ✅ Agent takes or imminently will take consequential write actions (refunds, account changes, customer emails, subscription updates, data export/deletion, CRM writes, billing actions)
3. ✅ 20-200 employees (small enough to talk to founder, big enough to feel enterprise pain)
4. ✅ Active enterprise sales motion (mid-market to enterprise — must have at least one named enterprise logo or actively chasing one)
5. ✅ Founder/CTO/Head of Product accessible via public LinkedIn

## What WE explicitly skip

- Composio, Pipedream, Zapier, n8n, Make, Workato, Gumloop, LangChain, CrewAI, Mastra → peers/infra, not buyers
- Sierra/Decagon/Salesforce direct → too big, too slow, will build internally
- General MCP enthusiasts and consulting shops
- Companies whose primary product is a chatbot UI without write actions

## Verticals (priority order)

| Tier | Vertical | Why |
|---|---|---|
| 1 | AI customer support / CX agents (refunds, escalations, account changes) | Highest write-action surface area, fastest enterprise procurement pain |
| 1 | Ecommerce ops agents (order changes, refunds, customer emails) | Same as above with smaller deal sizes = faster pilots |
| 2 | RevOps/CRM agents (lead routing, deal updates, email sends) | Salesforce-adjacent, security review applies |
| 2 | Fintech ops agents (transaction review, customer comms) | Highest stakes per action, slowest sales cycle |
| 3 | Healthcare admin agents (scheduling, claims, patient comms) | HIPAA-driven pain, but slow enterprise cycle |
| 3 | AI coding-agent companies (PR creation, infra changes) | Tier 2 ICP per source docs — slower than CX |

## Seed list — companies to research (target: 50)

**Status legend:** TARGET (researching) / SOURCED (LinkedIn URL confirmed) / SENT (DM sent) / REPLIED / CALL_BOOKED / CALL_DONE / DEAD

### Tier 1: AI customer support / CX agents (smaller-than-famous priority)

| # | Company | Vertical | Founder/CTO LinkedIn | Status | Notes |
|---|---|---|---|---|---|
| 1 | Crescendo | CX agents | TARGET | TARGET | named in source doc |
| 2 | Forethought | CX agents | TARGET | TARGET | named in source doc |
| 3 | Ada | CX agents | TARGET | TARGET | named in source doc — bigger, deprioritize |
| 4 | Gorgias AI | Ecommerce CX | TARGET | TARGET | named in source doc |
| 5 | Maven AGI | CX agents | TARGET | TARGET | named in source doc, ex-employees too |
| 6 | Lorikeet | CX agents | TARGET | TARGET | smaller, founder-accessible |
| 7 | Cresta | Contact center | TARGET | TARGET | bigger, deprioritize |
| 8 | Replicant | Voice CX | TARGET | TARGET |  |
| 9 | PolyAI | Voice CX | TARGET | TARGET |  |
| 10 | AptEdge | CX agents | TARGET | TARGET |  |

### Tier 1: Ecommerce ops agents

| # | Company | Vertical | Founder/CTO LinkedIn | Status | Notes |
|---|---|---|---|---|---|
| 11 | Reach out to research → fill in | Ecom ops |  | TARGET | Need to find 5-7 here |

### Tier 2: RevOps / CRM agents

| # | Company | Vertical | Founder/CTO LinkedIn | Status | Notes |
|---|---|---|---|---|---|
| 12 | Need to research | RevOps |  | TARGET |  |

### Tier 2: Coding-agent companies (Priority 2 per source)

| # | Company | Vertical | Founder/CTO LinkedIn | Status | Notes |
|---|---|---|---|---|---|
| 13 | Factory | Coding | TARGET | TARGET | named in source doc |
| 14 | Codegen | Coding | TARGET | TARGET | named in source doc |

### AIUC-1 partnership outreach (separate channel)

| # | Target | Approach | Status |
|---|---|---|---|
| AIUC-1 | Schellman (accredited auditor) | Direct email to Avani Desai + AI practice lead | TARGET |
| AIUC-1 | Consortium contact (JP Morgan / Salesforce / Brex AI risk leads) | LinkedIn DM citing AIUC-1 implementation analysis | TARGET |

## DM template (research-framed, NOT pitch)

Subject/connect message, <300 chars, one personalization hook per send:

> Hi {{first_name}} — I'm researching how enterprise security review is changing for AI agents that take real actions. Curious whether {{company}} is getting buyer questions about who authorized risky actions before execution. No pitch — could I ask 4 questions?

Personalization hooks (one per company, must be specific):
- recent product launch with write actions
- recent enterprise customer announcement
- public talk/podcast where they discussed agent autonomy
- specific action their agent takes (named in their docs)

## Validation call structure (8 questions)

Per source operating-plan section 10:

Opening: *"Without me pitching anything, what's the hardest question you're getting from enterprise prospects about what your agent is allowed to do?"*

Follow-ups:
1. What actions can your agent take today besides answering questions?
2. Which actions make enterprise buyers nervous?
3. Has security review gotten longer/more detailed because of agent autonomy?
4. What exactly are they asking for — logs, approvals, controls, SOC 2 mapping, data boundaries, human review?
5. Do you have pre-execution authorization today, or mostly post-action logs?
6. Would a verifiable approval-and-receipt artifact help, or would they still want something else?
7. If this helped, what action would you gate first?
8. If we could gate that action in 30 days, would you pay $7,500 for a pilot?

## Scoring rubric

- **0:** no write actions or no enterprise pressure
- **1:** write actions exist, but controls are not urgent
- **2:** named enterprise concern around approval/audit/control
- **3:** deal friction + named action + willingness to pilot/pay

## May 4 decision rule

- 3+ calls scoring 2 or 3 → green-light Action Gate build sprint
- 0–1 calls scoring 2 or 3 → Merge Gate-primary, ship 10-15 paying repos by June 1
- 2 calls in band → parallel 10-day plan, force decision May 14

---

*Tracker maintained by Charles Goldberg. Updated daily during sprint.*
