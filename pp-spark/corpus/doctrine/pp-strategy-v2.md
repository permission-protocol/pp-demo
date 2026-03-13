# PP Strategic Pivot: Authority Infrastructure

**Status:** APPROVED by Rod — 2026-03-04
**Date:** 2026-03-04
**Authors:** Rod + Charles

---

## 1. What We Are

Permission Protocol is **Authority Infrastructure** — a new category. Not governance. Not security. Not a policy engine.

**PP issues cryptographic proof that an AI action was authorized before it happened.**

PP sits between AI decisions and real-world execution. Nothing consequential happens without a signed receipt.

**PP protects humans from AI decisions.** The conversation is about accountability, not security.

---

## 2. The Primitive: Universal Action Receipt (UAR)

The core artifact is the **Universal Action Receipt (UAR)** — a portable, verifiable proof of authority that can travel across systems.

- Every approval produces a UAR
- Every UAR gets a **shareable authority proof page** — beautiful, simple, one screen
- The proof page is the product's face to the world
- If receipts become required proof, infrastructure providers can enforce them (long-term gravity — don't build for it yet, keep in mind)

---

## 3. Core Principles

- **Developers adopt primitives, not platforms.** We focus on the primitive.
- **PP sits between decision and execution.** The most powerful position in the stack.
- **The proof page must be beautiful and simple.** Like Stripe payment pages. Not enterprise dashboards.
- **Goal: become the easiest way to require approval for AI agent actions.** A tiny primitive developers love.
- **Speed matters.** Give developers tools to create viral moments.

---

## 4. Key Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Category | **Authority Infrastructure** | Not governance, not security. New category. |
| Primitive | **Universal Action Receipt (UAR)** | Portable, verifiable, cross-system artifact of authority |
| Issuer vs Verifier | **Issuer** | The company that issues receipts becomes infrastructure |
| Framing | **Accountability, not security** | Security = optional overhead. Accountability = institutional requirement. |
| Sequence | **Marketing → Product** | Design site + messaging first. Build exactly what the site promises. |
| Open source | **SDK open, issuance is not** | "Add approvals to your AI agent in one line of code" |
| Scope | **90 days only** | Nail the primitive. Everything else later. |
| Current deploy gate | **Keep as first enforcement point** | Reframe as one integration of the receipt system |

---

## 5. Messaging & Positioning

### The One-Liners
- "AI agents shouldn't authorize their own actions."
- "Every AI action should have an authority receipt."
- "PP sits between AI decisions and real-world execution."
- "The Signer of Record for AI systems."

### Developer Pitch
- "PP gives you a cryptographic receipt proving an AI action was authorized."
- "Add approvals to your AI agent in one line of code."

### The Revealing Question (Sales / Conversations)
> "If an AI agent deployed broken code to production tonight, how would you prove who authorized it?"

Ask it. Stay quiet. Listen. If they can't answer cleanly — they need PP.

### The Frame Shift
**Don't say:** PP protects systems from AI mistakes (= security tool, optional)
**Do say:** PP proves who authorized an AI action (= accountability infrastructure, required)

### Category Language
- ✅ Authority, Signer of Record, authorization receipts, infrastructure layer, accountability
- ❌ AI governance, AI safety, policy engine, compliance tooling, security layer

---

## 6. Key Features

### Shareable Authority Proof Page
`permissionprotocol.com/r/abc123` — public, beautiful, one screen.

Shows: action, resource, who approved, when, policy applied, signature verified badge.

**This is the viral mechanic.** Developers paste it in PRs, Slack, docs. Everyone who clicks sees PP.

### Action Replay Page
`permissionprotocol.com/replay/abc123` — timeline of an AI action sequence.

Shows: what the agent proposed → PP blocked/approved → receipt issued → action executed.

**This is the "PP just saved my database" moment.** Developers share the replay when something scary gets caught. Beautiful, shareable, designed to go viral.

Example dev post: "My agent tried to drop a table in prod. PP caught it. Check it out → [replay URL]"

### Open Source SDK
`pip install permission-protocol` / `npm install @permissionprotocol/sdk`

```python
from permission_protocol import require_approval

@require_approval
def deploy_service():
    deploy()
```

Flow: approval link → receipt generation → receipt verification → simple API

---

## 7. What We're Building (Phased)

### Phase 1 — Positioning & Design (Weeks 1-2)
- Messaging framework (finalize from Section 5)
- Receipt proof page design (beautiful, simple, one screen)
- Action replay page design (timeline view)
- SDK developer experience design (code snippets for site)
- "How it works" diagram: PP between decision and execution
- Output: complete content spec for new website

### Phase 2 — Website Rebuild (Weeks 2-3)
- Full permissionprotocol.com rebuild around new positioning
- Receipt proof page + replay page mockups embedded
- SDK code examples (pre-launch)
- Core flow: approval link → receipt → verification → API
- Early access / waitlist capture
- Ship live → start driving traffic

### Phase 3 — Build to Match (Weeks 4-6)
- Live receipt proof pages (`permissionprotocol.com/r/xxx`)
- Live replay pages (`permissionprotocol.com/replay/xxx`)
- Python SDK: `@require_approval` (open source)
- Replace site mockups with real links

---

## 8. What We're NOT Building (Yet)

- Federation / authority networks
- Enterprise dashboards or governance features
- Multiple enforcement integrations beyond GitHub
- Formal spec / RFC
- Anything planned for 12+ months out

---

## 9. Success Metrics (90 days)

- SDK installs
- Receipts generated
- Receipt/replay URLs shared in real PRs / Slack / docs
- Waitlist signups from new site
- Viral moments (devs sharing "PP saved my ___" posts)
- Investor-ready metrics deck

---

## 10. Competitive Positioning

- **vs Crittora:** They issue permission policies (what's allowed). We issue authority receipts (what was actually authorized). Receipts > policies for accountability.
- **vs Cloud providers (AWS/GCP/Azure):** Single-platform authority. PP is cross-platform. Receipts travel across systems.
- **vs AI security tools:** They sell control. We provide proof. Different category entirely.

---

## 11. Reference Documents

These 17 strategic documents informed this pivot:
- 01: Universal Action Receipts (killer improvement)
- 02: PP Doctrine (external authorization)
- 03: Authority Infrastructure (new layer definition)
- 04: Issuer vs Verifier (THE architectural decision)
- 05: Authority Distribution Problem (federation — future)
- 06: Proof-of-Authority Links (viral mechanic)
- 07: VC Pitch (investor framing)
- 08: The One Diagram (visual explanation)
- 09: Agent Approval Guards (SDK Trojan horse)
- 10: Platform Trap (primitive first)
- 11: 24-Month Roadmap (phased category leadership)
- 12: Investor Stack Diagram (missing layer visual)
- 13: Most Dangerous Competitor (cloud providers)
- 14: Viral Developer Feature (replay pages)
- 15: Positioning Shift (security → accountability)
- 16: The Revealing Question (sales tool)
- 17: $50B Insight (mandatory choke point — long-term)

Also informed by: Crittora APP Whitepaper review (2026-03-04)
