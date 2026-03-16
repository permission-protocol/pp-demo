# PRD: idea-048 — How It Works Page Expansion

**Issue:** permission-protocol/site#198
**Priority:** P1
**Repo:** permission-protocol/site

## Problem
`/how-it-works` page shows 3 cards with one sentence each, then ~70% empty space. The homepage actually has better "how it works" content than the dedicated page.

## Requirements

### Must Have

**Section 1: Existing 3-step cards (keep, enhance)**
- Keep Step 1/2/3 cards but add a visual connector between them (arrow or line)
- Add a small code snippet under each step showing the developer's perspective

**Section 2: Flow Diagram (NEW)**
- Reuse/adapt the flow diagram from the homepage: `PR Created → Permission Protocol → Decision (Blocked/Approved)`
- Show the full lifecycle: Agent acts → SDK intercepts → Request created → Human reviews → Receipt issued → Action proceeds
- Can be a styled diagram using divs/CSS (no image dependency)

**Section 3: The Receipt (NEW)**
- Show the receipt anatomy with labeled parts
- Fields: Action, Agent, Approver, Policy, Timestamp, Signature, Verification status
- Reuse the receipt mockup component from the homepage if available
- Link: "See a live receipt →" to `/r/demo`

**Section 4: Infrastructure Stack (NEW)**
- Reuse the table from the homepage: Identity/Encryption/Payments/Observability/Authority
- Position PP as the missing "Authority" layer

**Section 5: CTA**
- "Ready to add authority?" → Get Started (quickstart) + Talk to Us (contact)

### Style
- Match existing dark theme and card styling
- Use the same section spacing as homepage
- Keep it scannable — Sarah should get the full picture in 60 seconds

### Must NOT Do
- Don't change the nav or footer
- Don't add new pages — this is all on `/how-it-works`
- Don't add external dependencies (no diagram libraries)
