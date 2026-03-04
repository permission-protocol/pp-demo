# Permission Protocol — Website Spec V3 (Launch)

**Status:** DRAFT — Awaiting Rod's approval
**Date:** 2026-03-04
**Base:** Version B + Version A cherry-picks, trimmed to 7 launch pages
**North star:** Full V-A/V-B specs preserved as future sitemap

---

## 1. LAUNCH SCOPE — 7 PAGES ONLY

```
permissionprotocol.com/
├── /                       Homepage (conversion funnel)
├── /r/:receiptId           Receipt proof page (viral artifact)
├── /approve/:requestId     Approval page (workflow)
├── /replay/:replayId       Action replay page (viral artifact)
├── /developers/quickstart  Quickstart guide
├── /pricing                Pricing tiers
└── /contact                Contact / waitlist / early access
```

Everything else (docs, blog, /why, /how-it-works, /enterprise, /authority-network, /security, /about, changelog) is **deferred** to post-SDK-launch. The homepage covers the essential narrative; standalone pages expand it later.

### Deferred Pages (North Star — build when ready)
- `/why` — standalone doctrine page (homepage already covers this)
- `/how-it-works` — deep architecture walkthrough
- `/receipts` — receipt model deep dive
- `/developers` — developer hub landing
- `/developers/sdk` — SDK reference
- `/developers/examples` — integration examples
- `/enterprise` — enterprise features (when customers exist)
- `/authority-network` — federation model (Phase 2+)
- `/blog` — category-defining content
- `/docs/*` — full documentation (when SDK ships)
- `/about` — mission / team
- `/security` — trust & verification details

---

## 2. HOMEPAGE SPEC

The homepage is a single-scroll conversion funnel. Each section moves the visitor one step closer to adoption.

### Section 1: HERO

**Headline:**
> AI agents shouldn't authorize their own actions.

**Subheadline:**
> Permission Protocol is the Signer of Record for AI systems — issuing cryptographic receipts that prove an action was authorized before it happens.

**Key message:** There is a missing layer between AI decisions and real-world execution. Permission Protocol is that layer.

**Visual concept:** A clean, animated vertical flow diagram:
```
AI Agent
    ↓
Permission Protocol (glowing, emphasized)
    ↓
Authorized Action
```
The center node pulses subtly. Flow animates on page load — agent appears, receipt issues, action executes.

**Primary CTA:** `Get Started — Free` → /developers/quickstart
**Secondary CTA:** `See How It Works` → smooth scroll to Section 4

---

### Section 2: THE PROBLEM

**Headline:**
> Today, AI agents authorize themselves.

**Subheadline:**
> When AI systems deploy code, access data, or move money — nothing proves who approved it.

**Key message:** Capability has become permission (ambient authority). That's a structural conflict of interest.

**Visual concept:** Split screen comparison.

Left side (labeled "Today — No Authority Layer"):
```
Agent → Tool → Execution
    ⚠️ No approval
    ⚠️ No proof
    ⚠️ No accountability
```

Right side (labeled "With Permission Protocol"):
```
Agent → Permission Protocol → Signed Receipt → Execution
    ✓ Approved
    ✓ Verified
    ✓ Auditable
```

**CTA:** None — creates tension that the next section resolves.

---

### Section 3: THE SIGNER OF RECORD

**Headline:**
> The authority layer for AI systems.

**Subheadline:**
> Permission Protocol sits between AI decisions and real-world execution — issuing cryptographic proof that authority existed before the action occurred.

**Key message:** PP is infrastructure, not tooling. It occupies the most powerful position in the stack: between decision and execution.

**Visual concept:** The AI Economy Stack diagram:
```
┌──────────────────────────────┐
│     AI Applications          │
│  Agents, Copilots, Workflows │
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│     Decision Systems         │
│   LLMs, Planning Agents      │
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│   ★ AUTHORITY LAYER ★        │
│    Permission Protocol        │
│  Signed Authorization Receipts│
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│  Execution Infrastructure    │
│  Cloud · APIs · Databases     │
└──────────────────────────────┘
```

Authority Layer block: visually prominent — accent color, subtle glow.

**CTA:** None — builds inevitability.

---

### Section 4: HOW IT WORKS

**Headline:**
> Three steps. One receipt. Full accountability.

**Subheadline:**
> Every consequential AI action flows through Permission Protocol before execution.

**Visual concept:** Horizontal 3-step flow with animated transitions:

**Step 1 — Agent Proposes Action**
Icon: robot/agent
Text: "An AI agent requests permission to execute a consequential action — deploy, delete, transfer, access."

**Step 2 — Permission Protocol Authorizes**
Icon: shield/stamp
Text: "Permission Protocol evaluates the request against policies, collects approvals if needed, and issues a cryptographic authority receipt."

**Step 3 — Infrastructure Verifies**
Icon: server/check
Text: "The execution system — CI/CD pipeline, API gateway, database — verifies the receipt before allowing the action."

Below the steps, a code block:
```python
receipt = pp.authorize(
    action="deploy",
    resource="billing-service"
)

deploy(receipt)  # Pipeline verifies the receipt
```

**CTA:** `Try the SDK →` → /developers/quickstart

---

### Section 5: THE AUTHORITY RECEIPT

**Headline:**
> The primitive that proves authority existed.

**Subheadline:**
> Every authorized action produces a signed, portable, verifiable receipt.

**Key message:** The AuthorityReceipt is the core product object. It travels across systems. It is the proof.

**Visual concept:** Interactive receipt card with two states:

**Front (human-readable):**
```
┌─────────────────────────────────────┐
│         ✓ ACTION AUTHORIZED         │
│                                     │
│  Action:      deploy                │
│  Resource:    billing-service       │
│  Agent:       deploy-bot            │
│  Approved by: Sarah Kim             │
│  Policy:      production-deploy     │
│  Timestamp:   2026-03-03 10:14 UTC  │
│  Signature:   Verified ✓            │
│  Issuer:      Permission Protocol   │
│                                     │
│  permissionprotocol.com/r/8f91c2    │
└─────────────────────────────────────┘
```

**Back (JSON, on hover/click flip):**
```json
{
    "receipt_id": "8f91c2",
    "actor": "deploy-bot",
    "action": "deploy",
    "resource": "billing-service",
    "approved_by": "sarah.kim",
    "policy": "production-deploy",
    "timestamp": "2026-03-03T10:14:22Z",
    "authority_issuer": "permissionprotocol.com",
    "signature": "pp_sig_..."
}
```

**CTA:** `See a live receipt →` → link to demo receipt at /r/demo

---

### Section 6: INFRASTRUCTURE COMPARISON

**Headline:**
> Every critical system has an authority layer. AI doesn't — until now.

**Subheadline:**
> Permission Protocol completes the infrastructure stack.

**Visual concept:** Animated comparison table that builds row by row:

| Layer | System | What It Proves |
|---|---|---|
| Identity | OAuth / Okta | Who is making the request |
| Encryption | TLS | Communication can be trusted |
| Payments | Stripe | Money can move securely |
| Observability | Datadog | What happened in the system |
| **Authority** | **Permission Protocol** | **Who authorized the action** |

Final row appears last with highlight animation.

**CTA:** None — category credibility builder.

---

### Section 7: DEVELOPER EXPERIENCE

**Headline:**
> One line of code. Full authority.

**Subheadline:**
> Add approval guards to any AI agent in seconds.

**Visual concept:** Tabbed code blocks:

**Tab 1: Python**
```python
from permission_protocol import require_approval

@require_approval
def deploy_service():
    deploy("billing-api")

# Agent calls deploy_service()
# → Paused until authorized
# → Receipt issued
# → Execution continues
```

**Tab 2: Node.js**
```javascript
import { authorize } from '@permissionprotocol/sdk';

const receipt = await authorize({
    action: "deploy",
    resource: "billing-service"
});

await deploy(receipt);
```

**Tab 3: Terminal output**
```
$ pp authorize --action deploy --resource billing-service

✓ Authorization required
    Approval link: https://permissionprotocol.com/approve/4ac91
    Waiting for approval...

✓ Approved by sarah.kim
✓ Receipt issued: pp_r_8f91c2
✓ View: https://permissionprotocol.com/r/8f91c2
```

**CTA:** `pip install permission-protocol` (copyable) + `Read the Quickstart →`

---

### Section 8: USE CASES

**Headline:**
> Authority for every consequential AI action.

**Visual concept:** Grid of 6 cards:

| Card | Description |
|---|---|
| **CI/CD Deploys** | Require an authority receipt before any AI-initiated deployment reaches production. |
| **Database Operations** | Block destructive database mutations unless a signed receipt is present. |
| **Financial Transactions** | Ensure every AI-initiated payment or transfer has explicit authorization. |
| **Data Access** | Prove who authorized access to sensitive customer or internal data. |
| **API Calls** | Require receipt verification at API gateways for high-impact endpoints. |
| **Multi-Agent Orchestration** | Ensure downstream agents carry valid authority receipts from upstream approvals. |

**CTA:** `Get Started →` → /developers/quickstart

---

### Section 9: SOCIAL PROOF / TRUST SIGNALS

**Headline:**
> Trusted by teams building the future of autonomous systems.

**Visual concept:** Logo bar (placeholder until real). Below: metric cards:
- "X authority receipts issued"
- "Y developers using the SDK"

**CTA:** None — trust-building.

---

### Section 10: FINAL CTA

**Headline:**
> Authority before execution. Start now.

**Subheadline:**
> Free for individual developers. Enterprise plans for teams that need enforcement at scale.

**Visual concept:** Two CTA cards side by side:

| For Developers | For Enterprise |
|---|---|
| Install the SDK, get receipts in 5 minutes | Human-in-the-loop, self-hosted authority, compliance |
| `Get Started Free →` | `Talk to Us →` |

---

## 3. ARTIFACT PAGES

### Page: /r/:receiptId — Receipt Proof Page

**Purpose:** The viral artifact. When someone shares a receipt link, this is what people see. Must be beautiful, simple, and instantly credible.

**Layout:** Single centered card on a minimal page.

**Section 1 — Status header**
- `✓ ACTION AUTHORIZED` (green) or `✕ INVALID / EXPIRED` (red) with reason
- Verified badge + signature icon

**Section 2 — Receipt details**
```
Deploy → billing-service

Approved by:    Sarah Kim
Policy:         production-deploy
Timestamp:      2026-03-03 10:14:22 UTC

Signature:      Verified ✓
Issuer:         Permission Protocol
```

**Section 3 — Verification details (expandable/collapsible)**
- Signature algorithm
- Key ID
- Authority chain
- Raw receipt JSON

**Section 4 — Share controls**
- Copy link
- Copy receipt JSON
- Download receipt

**Footer CTA:** `Powered by Permission Protocol — Get Started Free →`

**Design principles:** Stripe-payment-confirmation clean. One screen. No clutter. Subtle brand presence. Must feel like a real institutional document.

**Security:** Publicly viewable only if issuer marks it shareable (or it's a demo receipt). Always show "Issuer" clearly.

---

### Page: /approve/:requestId — Approval Page

**Purpose:** Human-in-the-loop workflow. Approve or reject a pending action.

**Section 1 — Action summary**
- Agent, action, resource, risk indicators
- "Risk badge" for high-impact actions

**Section 2 — Approve / Reject**
- Two clear buttons + optional comment field
- Clean, decisive UI — no ambiguity

**Section 3 — Result**
- On approve → receipt issued + link to `/r/:receiptId`
- On reject → blocked + record link

**Security:** Must require identity verification (magic link, SSO, or signed token) — even in MVP. No anonymous approvals.

---

### Page: /replay/:replayId — Action Replay Page

**Purpose:** Viral shareable timeline of an AI action sequence. The "PP saved my database" moment.

**Layout:** Vertical timeline on a minimal page.

**Authorized action version:**
```
AI Action Replay

10:14:12  ● Agent proposes action
             deploy billing-service

10:14:13  ● Permission Protocol evaluates
             Policy: production-deploy

10:14:14  ● Human approval required
             Approval link sent to sarah.kim

10:14:16  ● Approved by Sarah Kim

10:14:17  ● Authority receipt issued
             Receipt: pp_r_8f91c2

10:14:18  ● Deployment executed ✓

──────────────────────────────────
Protected by Permission Protocol
```

**Blocked action version:**
```
10:14:12  ● Agent proposes action
             delete_database()

10:14:13  ● Permission Protocol blocks action
             No authority receipt

10:14:13  ✕ ACTION BLOCKED
```

Timeline ends abruptly at red X. The block should feel decisive and protective.

**Section: Artifacts**
- Link to receipt (if issued)
- Link to approval request
- Raw events export

**Footer CTA:** `Powered by Permission Protocol — Get Started Free →`

---

## 4. QUICKSTART PAGE — /developers/quickstart

**Purpose:** 5-minute path from zero to first receipt. The "magic moment."

**Section 1 — Install**
```bash
pip install permission-protocol
```

**Section 2 — Configure**
```python
import permission_protocol as pp
pp.configure(api_key="pp_key_...")
```

**Section 3 — Add an approval guard**
```python
from permission_protocol import require_approval

@require_approval
def deploy_service():
    deploy("billing-api")
```

**Section 4 — Run your agent**
```
$ python agent.py
> deploy_service() requested
> Approval required: https://permissionprotocol.com/approve/4ac91
> Waiting for approval...
> ✓ Approved by sarah.kim
> ✓ Receipt: pp_r_8f91c2
> ✓ Deployment executed
```

**Section 5 — Approve in the browser**
- Approval link opens action details
- Approve/reject buttons
- Screenshot/mockup of approval page

**Section 6 — Share the receipt**
```
https://permissionprotocol.com/r/8f91c2
```
- Screenshot/mockup of receipt proof page

**Section 7 — Next steps**
- Verify receipts in CI/CD (teaser for future enforcement docs)
- Explore the SDK API
- Join the community

---

## 5. PRICING PAGE — /pricing

**Section 1 — Tier grid**

| Tier | Target | Features |
|---|---|---|
| **Free** | Individual developers | SDK, 1,000 receipts/month, basic approval links, receipt proof pages |
| **Team** | Small teams | Unlimited receipts, team approval workflows, shared policies, audit log |
| **Enterprise** | Large orgs | Self-hosted authority nodes, federation, SSO, compliance exports, SLA |

**Section 2 — "Start with the primitive"**
- Start with approvals + receipts; enforce later
- Staged ladder graphic

**Section 3 — CTA split**
- `Install SDK` (developer)
- `Talk to sales` (enterprise)

---

## 6. CONTACT PAGE — /contact

**Section 1 — Form**
Fields: name, email, company, use case (deploy / data / payments / API / other), environment (clouds), timeline

**Section 2 — What happens next**
"We'll review your enforcement points, map receipt verification, and propose a pilot."
3-step timeline visual.

---

## 7. VISUAL SYSTEM

### Color Palette (Hybrid — current site identity + V3 additions)

| Role | Hex | Name | Source |
|---|---|---|---|
| Background | `#0a0a0a` | Void | Current site |
| Surface / panels | `#1a1a1a` | Ash | Current site |
| Borders | `#222222` | — | Current site |
| Text primary | `#c8c8c8` | Signal | Current site |
| Text secondary | `#888888` | — | Current site |
| Text muted | `#666666` | — | Current site |
| Primary accent (permit/verified/CTA) | `#44aa99` | Permit Teal | Current site |
| Danger (blocked/denied/fail-closed) | `#EF4444` | Alert Red | V3 new — brighter than old #aa4455 for impact |
| Warning (approval required/high-impact) | `#F59E0B` | Approval Amber | V3 new |
| Card backgrounds (light context, e.g. receipt cards) | `#111111` | — | Current site |

**Usage rules:**
- Teal (`#44aa99`) for "Get started / Install / Verified / Authorized" — PP's signature color
- Red (`#EF4444`) ONLY for "Blocked / Invalid / Missing receipt / Denied"
- Amber (`#F59E0B`) ONLY for "Approval required / Pending / High-impact"
- The site stays dark. Light cards/surfaces use `#111111` or `#1a1a1a`, not white.

### Typography

| Element | Font | Weight | Size |
|---|---|---|---|
| Headlines (H1) | Space Grotesk | Bold (700) | 48–56px |
| Section titles (H2) | Space Grotesk | Semibold (600) | 32–36px |
| Body | Space Grotesk (or Inter fallback) | Regular (400) | 16–18px, 1.6 line-height |
| Code | JetBrains Mono | Regular (400) | 14–15px |
| CTA buttons | Space Grotesk | Semibold (600) | 16px |

### Icon Style
- Line icons, 1.5px stroke, rounded corners, 24×24 grid
- Library: Lucide or Phosphor
- Custom icons needed: Authority Receipt, Signed Stamp, Agent, Enforcement Point

### Diagram Style
- Dark backgrounds with light text and accent-colored flow lines
- SVG-first (sharp at all sizes)
- Rounded rectangle nodes, subtle borders
- Animated flow arrows (CSS/SVG)
- Consistent theme across all diagrams (stroke width, arrowheads, node radius)
- "Receipt" = small document with signature seal
- "Gate" = narrow chokepoint with pass/fail branches

### Motion / Animation
- Scroll-triggered section reveals (fade up, 200ms ease)
- Flow diagram arrows animate on scroll-into-view
- Receipt card hover: slight lift + shadow increase
- Comparison table rows build sequentially
- All animations subtle and purposeful — never decorative

---

## 8. CORE DIAGRAMS (Launch Set)

Only what's needed for the 7 launch pages:

1. **The One Diagram** (Homepage hero) — Agent → PP → Receipt → Execution
2. **Before/After Comparison** (Homepage §2) — Today vs With PP
3. **AI Economy Stack** (Homepage §3) — Four layers with Authority highlighted
4. **3-Step Flow** (Homepage §4) — Propose → Authorize → Verify
5. **Receipt Card** (Homepage §5 + /r/ page) — Interactive front/back
6. **Infrastructure Comparison Table** (Homepage §6) — OAuth/TLS/Stripe/Datadog/PP
7. **Use Case Grid Icons** (Homepage §8) — 6 cards
8. **Replay Timeline** (/replay/ page) — Vertical event timeline
9. **Terminal Mockup** (Homepage §7 + Quickstart) — SDK install → receipt output

---

## 9. IMAGE GENERATION PROMPTS (Nano Banana 2)

Trimmed to launch-critical images only. Full set in Version B spec.

### PROMPT 01 — Homepage Hero Illustration
```
Create a sleek, futuristic illustration on a near-black background (#0a0a0a to #111111 gradient). Three geometric nodes arranged vertically and connected by glowing permit teal (#44aa99) flow lines with subtle particle effects along the lines.

Top node: a rounded hexagon with a minimalist robot/circuit icon inside, representing an AI agent, colored light grey.

Center node: the largest, a rounded rectangle with a soft radial blue glow emanating outward, containing the bold sans-serif text "PP" in white. This is the focal point.

Bottom node: a rounded rectangle with a minimalist server/cloud icon inside, representing infrastructure, colored light grey.

Between the top and center nodes: a small glowing document icon with a checkmark, representing an authority receipt, floating along the flow line.

Style: premium tech product illustration, clean vector aesthetic, subtle depth with layered shadows, no gradients on the nodes themselves, matte surfaces. Similar to Vercel or Stripe hero illustrations. 16:9 aspect ratio, 4K resolution.
```

### PROMPT 02 — Before/After Comparison
```
Create a side-by-side comparison illustration on a near-black (#0a0a0a) background, split down the middle with a thin vertical divider line.

Left side — labeled "TODAY" in small red (#EF4444) bold sans-serif text at the top:
Three nodes connected by a straight red dashed line flowing downward: "AI Agent" (top, grey hexagon) → "Tool" (middle, grey square) → "Execution" (bottom, grey square). Next to the flow, three small red warning triangle icons with the labels "No approval", "No proof", "No accountability" in small light grey text.

Right side — labeled "WITH PERMISSION PROTOCOL" in small green (#10B981) bold sans-serif text at the top:
Four nodes connected by a solid permit teal (#44aa99) glowing line flowing downward: "AI Agent" (top) → "Permission Protocol" (middle, larger, blue glow) → "Receipt" (small document icon with checkmark) → "Execution" (bottom). Next to the flow, three small green checkmark icons with labels "Approved", "Verified", "Auditable" in small light grey text.

Style: clean tech diagram, geometric shapes, minimal, dark background, no 3D effects, flat design with subtle glow on the blue elements. 16:9 aspect ratio, 4K.
```

### PROMPT 03 — AI Economy Stack
```
Create a vertical stack diagram on a near-black (#0a0a0a) background showing four horizontal layers stacked vertically, each as a wide rounded rectangle with subtle borders.

Top layer: light grey background, text "AI Applications" in dark text, subtitle "Agents · Copilots · Workflows" in smaller grey text.

Second layer: light grey background, text "Decision Systems" in dark text, subtitle "LLMs · Planning Agents" in smaller grey text.

Third layer (the focal point): permit teal (#44aa99) background with a soft outer glow, text "AUTHORITY LAYER" in bold white, subtitle "Permission Protocol" below it, and "Signed Authorization Receipts" in smaller white text below that.

Bottom layer: light grey background, text "Execution Infrastructure" in dark text, subtitle "Cloud · APIs · Databases · CI/CD" in smaller grey text.

Between each layer, a thin white downward arrow.

Style: premium infographic, clean sans-serif typography, no 3D effects, subtle shadows between layers for depth. 9:16 aspect ratio (vertical), 4K.
```

### PROMPT 04 — Authority Receipt Card (Front)
```
Create a photorealistic mockup of a digital receipt card floating at a slight 3D angle on a near-black (#0a0a0a) background with a subtle spotlight from above.

The card is white with rounded corners (12px radius), a thin light grey border, and a soft drop shadow. It contains:

Top: a green (#10B981) checkmark circle icon next to bold text "ACTION AUTHORIZED" in dark navy.

Below, a clean data layout with labels in light grey and values in dark navy bold:
"Action:" → "deploy"
"Resource:" → "billing-service"
"Agent:" → "deploy-bot"
"Approved by:" → "Sarah Kim"
"Policy:" → "production-deploy"
"Timestamp:" → "2026-03-03 10:14 UTC"
"Signature:" → "Verified ✓" (in green)

Bottom: small text "permissionprotocol.com/r/8f91c2" in permit teal (#44aa99).

At the very bottom of the card, a thin permit teal accent line.

Style: product screenshot aesthetic, like a Stripe receipt or Apple Pay confirmation. Clean, institutional, trustworthy. 4:5 aspect ratio, 4K.
```

### PROMPT 05 — Receipt Card (JSON Back)
```
Create a dark-themed code card floating at a slight 3D angle on a near-black (#0a0a0a) background. The card has a dark charcoal (#1E1E2E) background with rounded corners and a subtle permit teal (#44aa99) border glow on the left edge.

The card displays syntax-highlighted JSON code:

{
    "receipt_id": "8f91c2",
    "actor": "deploy-bot",
    "action": "deploy",
    "resource": "billing-service",
    "approved_by": "sarah.kim",
    "policy": "production-deploy",
    "timestamp": "2026-03-03T10:14:22Z",
    "authority_issuer": "permissionprotocol.com",
    "signature": "pp_sig_a8f2..."
}

JSON keys in permit teal, string values in green (#10B981), punctuation in grey. Monospace font similar to JetBrains Mono.

Style: VS Code / developer terminal aesthetic, premium and sharp. 4:5 aspect ratio, 4K.
```

### PROMPT 06 — Infrastructure Comparison Table
```
Create a clean infographic table on a near-black (#0a0a0a) background showing five rows of infrastructure layers.

Each row has three columns: an icon on the left, the layer name in the center, and the company name on the right.

Row 1: lock icon, "Identity", "OAuth / Okta" — all in muted grey
Row 2: shield icon, "Encryption", "TLS" — all in muted grey
Row 3: credit card icon, "Payments", "Stripe" — all in muted grey
Row 4: chart icon, "Observability", "Datadog" — all in muted grey
Row 5 (highlighted): stamp/seal icon in permit teal, "Authority" in bold white, "Permission Protocol" in bold permit teal (#44aa99). This row has a subtle blue background glow.

Style: minimal data table, premium infographic, clean sans-serif font. 16:9 aspect ratio, 4K.
```

### PROMPT 07 — Developer Terminal Mockup
```
Create a realistic macOS terminal window mockup on a near-black (#0a0a0a) background. The terminal has a dark charcoal background with the standard three colored dots (red, yellow, green) in the top-left corner.

The terminal shows this exact text sequence with syntax coloring:

Line 1 (grey): "$ pip install permission-protocol"
Line 2 (green): "✓ Installed successfully"
Line 3 (empty)
Line 4 (grey): "$ python agent.py"
Line 5 (white): "> deploy_service() requested"
Line 6 (permit teal): "> Authorization required"
Line 7 (grey): "> Approval link: https://permissionprotocol.com/approve/4ac91"
Line 8 (yellow): "> Waiting for approval..."
Line 9 (empty)
Line 10 (green): "> ✓ Approved by sarah.kim"
Line 11 (green): "> ✓ Receipt issued: pp_r_8f91c2"
Line 12 (green): "> ✓ Deployment executed"

Style: realistic terminal screenshot, developer aesthetic, JetBrains Mono font. 16:9 aspect ratio, 4K.
```

### PROMPT 08 — OG Image / Social Card
```
Create a social media card (1200x630 pixels) on a near-black (#0a0a0a) background.

Left side: the vertical flow diagram — three small geometric nodes connected by glowing permit teal lines: "AI Agent" (top) → "PP" in a glowing blue circle (center) → "Infrastructure" (bottom).

Right side:
Large bold white sans-serif text: "Permission Protocol"
Below in permit teal (#44aa99): "The Signer of Record for AI Systems"
Below in smaller grey text: "Cryptographic proof that an AI action was authorized before it happened."

Bottom-right corner: small text "permissionprotocol.com" in grey.

Style: social media card, tech infrastructure brand, Stripe/Vercel aesthetic. Exactly 1200x630 pixels.
```

### PROMPT 09 — Receipt Page Browser Mockup
```
Create a realistic browser window mockup on a near-black (#0a0a0a) background. The browser has a minimal chrome with a URL bar showing "permissionprotocol.com/r/8f91c2".

Inside the browser, a clean white page with a single centered card. The card shows:

A large green (#10B981) checkmark circle at the top.
Bold heading: "Action Authorized"

Below:
"Deploy → billing-service"
"Approved by: Sarah Kim"
"Timestamp: 2026-03-03 10:14:22 UTC"
"Signature: Verified ✓" in green

At the bottom of the card, small text "Issued by Permission Protocol" in permit teal.

Below the card, small grey text "Powered by Permission Protocol" and a blue button "Get Started Free →".

Style: Stripe payment confirmation aesthetic, clean and institutional. 16:9 aspect ratio, 4K.
```

### PROMPT 10 — Replay Page Browser Mockup (Blocked)
```
Create a realistic browser window mockup on a near-black (#0a0a0a) background. The browser URL bar shows "permissionprotocol.com/replay/abc123".

Inside the browser, a clean white page with a vertical timeline. The heading says "AI Action Replay" in dark navy bold text.

The timeline has 3 entries:

"10:14:12" — blue dot — "Agent proposes action: delete_database()"
"10:14:13" — red dot — "Permission Protocol blocks action — No authority receipt"
"10:14:13" — large red X icon — "ACTION BLOCKED" in bold red (#EF4444) text

The timeline line ends abruptly at the red X. The red X has a subtle red glow.

Below: "Protected by Permission Protocol" in permit teal, and a blue button "Get Started Free →".

Style: product screenshot, clean and decisive — the block should feel protective. 16:9 aspect ratio, 4K.
```

---

## 10. MESSAGE HIERARCHY

The narrative the site communicates, in order:

1. AI agents now execute real-world actions (deploy, data, money).
2. The structural flaw: agents often authorize themselves (ambient authority).
3. The missing layer: no separation between decision and execution.
4. The principle: authority must be external — separation of powers for AI.
5. PP's role: Signer of Record that issues signed authority receipts.
6. The primitive: AuthorityReceipt (portable proof) — not "a platform."
7. The enforcement contract: infra verifies receipts, fails closed without them.
8. The outcome: organizations can prove who authorized what.

### Words to Always Use
- Authority
- Signer of Record
- Authority receipt
- Infrastructure layer
- Cryptographic proof
- Before execution

### Words to Never Use
- AI governance platform
- AI safety tooling
- Policy engine
- Agent security layer
- Compliance tooling
- Dashboard

---

## 11. CONVERSION STRATEGY

### Conversion Funnel
```
Visitor → Understanding → Developer activation → Team adoption → Enterprise
```

### CTAs by Stage

| Visitor Type | CTA | Destination |
|---|---|---|
| First-time visitor | "Get Started — Free" | /developers/quickstart |
| Developer exploring | "pip install permission-protocol" | Quickstart / GitHub |
| Enterprise buyer | "Talk to Us" | /contact |
| Receipt link clicker | "Get Started Free" (footer of /r/) | /developers/quickstart |
| Replay link clicker | "Get Started Free" (footer of /replay/) | /developers/quickstart |

### Viral Loop
```
Developer installs SDK
    → Adds @require_approval
    → Receipt generated
    → Developer shares receipt link in Slack/GitHub
    → Colleagues click → see Permission Protocol
    → Colleagues install SDK
    → Team adopts → Enterprise conversation
```

---

## 12. IMPLEMENTATION NOTES

### Tech Stack

| Component | Choice |
|---|---|
| Framework | Next.js 14+ (App Router) + TypeScript |
| Styling | Tailwind CSS + custom design tokens |
| Animation | Framer Motion |
| Diagrams | Custom SVG React components |
| Code blocks | Shiki or Prism + copy button |
| Hosting | Vercel |
| Analytics | PostHog |
| Forms | Custom + API route |

### Route Structure
```
app/
├── layout.tsx                    Global nav + footer
├── page.tsx                      Homepage
├── /developers/quickstart/page.tsx
├── /pricing/page.tsx
├── /contact/page.tsx
├── /r/[id]/page.tsx              Receipt proof page
├── /approve/[id]/page.tsx        Approval page
└── /replay/[id]/page.tsx         Replay page
```

### Component System (build once, reuse)

| Component | Description |
|---|---|
| `<Hero>` | Full-width hero with headline, subhead, CTA, visual |
| `<SectionBlock>` | Standard content section with headline, body, visual slot |
| `<CodeBlock>` | Syntax-highlighted, copyable, tabbed by language |
| `<DiagramFlow>` | Animated flow diagram |
| `<ReceiptCard>` | Interactive receipt (front/back flip) |
| `<ComparisonTable>` | Animated row-by-row infrastructure comparison |
| `<UseCaseGrid>` | 6-card grid |
| `<CTABanner>` | Full-width CTA with dev/enterprise split |
| `<ReplayTimeline>` | Vertical timeline for replay pages |
| `<StackDiagram>` | AI Economy Stack visualization |

### Performance
- Lighthouse 95+ all categories
- FCP < 1.2s, TTI < 2.5s, CLS < 0.1
- Static pre-render for all pages
- Artifact pages SSR with caching

### SEO
- Meta title + description per page
- OG images per page type
- Schema markup: Organization + SoftwareApplication

---

**END SPEC V3**
