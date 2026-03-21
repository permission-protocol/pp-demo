# PP-OS LinkedIn Outreach Pivot: "The Design Partner Wedge"

**Date:** 2026-03-21
**Status:** Pending Approval
**Goal:** Transition from selling infrastructure to recruiting enterprise Design Partners / Customer Advisory Board (CAB) members.

## 1. The Strategy Shift
*   **Old Strategy:** "We built cryptographic receipts, do you want them?" (0/9 accepts). Resulted in pitch-slapping and high friction.
*   **New Strategy:** "Tear our architecture apart." (Ego + Expertise). We position Rod as an architect seeking harsh feedback from top-tier security/engineering leaders before an enterprise push.
*   **The Leverage:** This qualifies the market. If they say why it won't work, we get exact enterprise objections. If they like it, we get a pilot partner.

## 2. The Targets
*   **Roles:** CISOs, VP Engineering, CTOs, and Head of AI Security.
*   **Companies:** Mid-market to Enterprise SaaS companies that have recently announced or deployed AI/Agentic features.
*   **Why:** They own the liability. They don't want to buy another tool, but they love giving their expert opinion on bleeding-edge architecture.

## 3. The Messaging Sequence

**Angle:** `design_partner_critique`

**Connection Note (Ego + Credibility - Max 300 chars):**
> "Hey {first_name} — we just submitted a framework to NIST on deterministic AI agent security. Since {company} is scaling AI, I'd love to connect. I'm looking for a few sharp engineering/security leaders to poke holes in our architecture."

**Message 1 (The Ask - Sent after accept):**
> "Thanks for connecting. The short version: prompt engineering fails at preventing rogue agent actions. We built a physical stdio proxy (MCP Guard) that blocks tool calls + a cryptographic receipt layer for auditability.
>
> Before we push this to enterprise, I need someone with your vantage point to tell me why this *won't* work in a real corporate environment. Open to taking a look at a 60s demo and giving me raw, harsh feedback?"

**Follow-up 1 (The Low-Friction Out - Sent 4 days later):**
> "No worries if you're swamped. The open-source repo is here if you're curious how the YAML blocking works: [GitHub Link]. If you ever want to jam on agent liability and security, my door is always open."

*Note: The sequence is deliberately short. Two messages post-connect. No desperate 3rd follow-up.*

## 4. Technical Execution Plan

If approved, Charles will execute the following:

1.  **Playbook Update:** Overwrite `pp-os/outreach/playbook.json` to replace the 4 abstract angles with the single `design_partner_critique` angle and the templates above.
2.  **Expandi Teardown:** 
    *   Mark the current "New Campaign - 06 Mar, 2026" as paused/archived. 
    *   Create a fresh campaign in Expandi dedicated to the Design Partner wedge.
3.  **Scanner Tuning:** Update `scan-signals.sh` to deprioritize "new agent startups" and heavily weight signals indicating "enterprise AI deployment", "CISO", "security breaches", and "MCP".
4.  **Batch 3 Injection:** Source 5 highly targeted VP Eng / CISOs, generate the new sequence, validate character counts, and inject into the new campaign.

## 5. Success Metrics
*   **Primary:** Connection Acceptance Rate (Target: >20%). If they accept, the ego play worked.
*   **Secondary:** Reply Rate (Target: >10%). We want them asking for the 60s NemoClaw demo video.
