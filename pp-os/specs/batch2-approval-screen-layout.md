# Spec: Approval Screen — Information Architecture for Decision-Making

## The Insight
Marco and Sarah aren't reading a document. They're answering ONE question: **"Should this go live?"**

Every element on the screen should push them toward a confident yes or no in under 60 seconds. The layout should mirror how humans actually make decisions: context → risk assessment → action.

## Current Problem
Information is presented in creation order (title, summary, signals, files, details) — like a form, not a decision flow. The approve/deny buttons are mid-page, mixed with checkboxes and tags. There's no visual hierarchy guiding the eye.

## Proposed Layout: The Decision Flow

### Zone 1: Context (2 seconds) — "What am I looking at?"
```
┌─────────────────────────────────────────────────────┐
│  feat: add config validator utility                 │
│  pp-demo · PR #16 · by Charles Goldberg · 6m ago    │
│  🤖 Opened by AI agent                              │
│  Deploys to: production                             │
└─────────────────────────────────────────────────────┘
```
- PR title large, everything else small
- Environment badge (production = red/orange, staging = blue)
- Actor type (human / AI agent / CI)
- **No thinking required.** Pure context.

### Zone 2: Assessment (15 seconds) — "Should I be worried?"
```
┌─────────────────────────────────────────────────────┐
│  Risk: 🟢 Low                                       │
│  What: Adds config validation. No existing code      │
│        modified.                                     │
│  Blast radius: None — new utility file only          │
│  Code review: ✅ 1 approved on GitHub                │
│  After approval: checks re-run → auto-merge → done  │
└─────────────────────────────────────────────────────┘
```
- Risk level is the FIRST thing in this zone — color-coded, instant read
- One-line "what" — not a paragraph
- Blast radius — who/what is affected
- Social proof — did peers review this on GitHub?
- What happens next — remove uncertainty
- **Marco stops here if risk is green.** Sarah reads on.

### Zone 3: Action (1 second) — "Do the thing"
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│      [ ✅ Approve for Production ]   [ ✖ Deny ]    │
│                                                     │
│      Add a note... (optional, collapsed)            │
└─────────────────────────────────────────────────────┘
```
- Buttons are BIG, unmissable
- "Approve for Production" includes the environment in the button text — no separate checkbox
- Deny is secondary (outlined, not filled)
- Note/reason is a small link, not a textarea taking up space
- **Deny expands** to show reason pills + "require new request" ONLY when clicked

### Zone 4: Evidence (Sarah's zone) — "Show me the details"
```
▸ Risk Signals (1 high, 2 low)
▸ Changed Files (1) +8 -0
▸ Request Details (commit, timestamps, scope)
▸ AI Analysis (full text)
```
- All collapsed by default
- Accordion/details elements
- Sarah expands what she needs; Marco never scrolls here
- This is the "audit trail" zone — reference material, not decision material

## Key Design Principles

### 1. Progressive Disclosure
- Zone 1+2+3 fit above the fold on any screen
- Zone 4 is below the fold, expandable
- 80% of approvals happen without scrolling

### 2. Risk-First Visual Hierarchy
- Risk badge is the largest, most colorful element after the title
- Green = fast path (approve without thinking twice)
- Yellow = pause and read the details
- Red = expand everything, read carefully

### 3. Environment Awareness
- Production deploys should FEEL different from staging
- Subtle background tint or border color shift
- Production: warm (amber/red accent)
- Staging: cool (blue/neutral)
- This subconsciously primes the approver to take production seriously

### 4. Social Proof Reduces Friction
- "2 developers approved this on GitHub" makes Marco click faster
- "No code review" makes Sarah pause — which is correct behavior
- Show the GitHub review status prominently in Zone 2

### 5. The Button Tells You What Happens
- Not just "Approve" — "Approve for Production"
- Not just "Deny" — could be "Block Deploy" for gravity
- The button text should include the consequence

## Mobile Consideration
Marco gets this link on his phone at 11pm. The layout should work on mobile:
- Zone 1: full width, small text
- Zone 2: stacked vertically
- Zone 3: full-width buttons, thumb-friendly
- Zone 4: accordions work great on mobile

## Files Likely Changed
- Approval page component — complete layout restructure
- Possibly separate `ApprovalDecisionView` component
- Risk badge component (color-coded by level)
- Environment badge component

## Priority
Critical — this layout IS the product experience. Everything else is plumbing.
