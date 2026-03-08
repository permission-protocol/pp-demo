# Phase 0 — Placeholder Fixes

Two leads need their messages re-injected with shorter versions (<300 chars each).

**Fix process:**
1. Go to Expandi → Campaign People tab
2. Find Donald Kossmann → click ⋯ → Remove from campaign
3. Find Charlie Holtz → click ⋯ → Remove from campaign
4. Run the curl commands below to re-inject them

---

## Donald Kossmann (Chargebacks911)

```bash
curl -s -X POST \
  "https://api.liaufa.com/api/v1/open-api/campaign-instance/772360/assign/?key=0a00d269-97cd-4961-8e7b-e0d0c8aae0a9&secret=8f9e3e1a-1a10-4933-8147-65be541c5365" \
  -H "Content-Type: application/json" \
  -d '{
    "profile_link": "https://www.linkedin.com/in/donaldkossmann",
    "first_name": "Donald",
    "company_name": "Chargebacks911",
    "connection_note": "Donald — read your piece on agent accountability in commerce. You nailed it: knowing what an agent was allowed to do vs what it did is the gap. We'\''re building exactly that layer. Would love to compare notes.",
    "connection_note_short": "Donald — your piece on agent accountability resonated. We'\''re building the authorization receipt layer you described. Would love to compare notes.",
    "message_1": "Thanks for connecting. Your point about stronger auditability resonated — exact problem we'\''ve been heads-down on. We built authorization receipts: before any agent action executes, it gets a signed receipt proving what was approved, by whom, when. Seeing this from Chargebacks911 clients?",
    "followup_1": "You mentioned the limits of OAuth for agentic commerce — we hit the same wall. OAuth handles access, not what an agent was authorized to do right now. Our receipts fill that gap. Worth a 15-min call to see how it maps to payment disputes?",
    "followup_2": "Last ping — totally understand if the timing'\''s off. If agent accountability is something Chargebacks911 is actively working on, I'\''d love to share what we'\''ve built. If not, no worries at all. Either way, enjoyed your article."
  }'
```

## Charlie Holtz (Conductor)

```bash
curl -s -X POST \
  "https://api.liaufa.com/api/v1/open-api/campaign-instance/772360/assign/?key=0a00d269-97cd-4961-8e7b-e0d0c8aae0a9&secret=8f9e3e1a-1a10-4933-8147-65be541c5365" \
  -H "Content-Type: application/json" \
  -d '{
    "profile_link": "https://www.linkedin.com/in/charlieholtz/",
    "first_name": "Charlie",
    "company_name": "Conductor",
    "connection_note": "Charlie — saw the HN thread about Conductor sandbox boundaries. Tricky problem: soft guardrails vs hard enforcement. We built a cryptographic authorization layer for exactly this — real enforcement agents cannot sweet-talk past. Thought you'\''d find it relevant.",
    "connection_note_short": "Charlie — saw the HN thread on sandbox boundaries. We built cryptographic enforcement that agents cannot bypass. Thought you'\''d find it relevant.",
    "message_1": "Every agent platform hits this wall: LLM guardrails are probabilistic but users expect deterministic enforcement. We built authorization receipts — every action requires a signed receipt before execution. Not a prompt, a cryptographic gate. Solving this at Conductor?",
    "followup_1": "We just submitted to NIST AI Agent Security RFI on exactly this: enforcing boundaries on autonomous coding agents. Happy to share our framework if you'\''re exploring solutions. YC-stage is the perfect time to bake this in.",
    "followup_2": "If enforcement is not a priority right now, totally understand. When it becomes one (and it will as enterprise customers ask), ping me. Happy to help Conductor be the first agent platform with real authorization receipts."
  }'
```

---

**Char counts (all under 300):**
- Donald message_1: ~295 ✓
- Donald followup_1: ~261 ✓
- Charlie message_1: ~272 ✓
- Charlie followup_1: ~218 ✓
