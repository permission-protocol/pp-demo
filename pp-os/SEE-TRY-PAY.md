# See Try Pay — Activation Framework

*The bottleneck is activation, not monetization.*

---

## The Loop

```
Install → First blocked action → Approval → "Oh shit" moment
```

If this loop isn't tight, nothing else matters.

---

## Phase 1: SEE (Force the first blocked action)

**Goal:** Install → blocked PR in <2 minutes with zero thinking

After GitHub App install:
1. Auto-create a PR in the user's connected repo
2. Trigger the block immediately
3. User sees:
   - ❌ "Awaiting approval"
   - "HIGH RISK: deploy to prod"

No manual setup. No docs to read. Just: install → blocked.

**Success metric:** Time from install to first "Awaiting approval" view

---

## Phase 2: TRY (Quick Start Wizard)

**Goal:** One button: "Test enforcement"

Dashboard shows a single CTA that:
1. Creates a test PR
2. Triggers the block
3. Shows the approval link

Zero friction. The wizard IS the onboarding.

**Success metric:** % of installs that complete first approval

---

## Phase 3: Fix the Approval Moment

**Goal:** Make approval feel like signing, not clicking

Current: Button click → done
Target: 
- Clear consequence ("This will deploy to production")
- Identity emphasis ("You are the signer")
- Feels weighty, not casual

**This is the "oh shit" moment.** If it feels like clicking "OK" on a dialog, we've failed.

---

## Metrics That Matter (Now)

- `installs → first_approval` conversion rate
- `approvals_per_org` (engagement depth)
- Time to first blocked action

## Metrics That Don't Matter (Yet)

- Revenue
- Pricing page views
- Stripe anything

---

## Phase 4: PAY (Only after SEE+TRY work)

Paywall triggers:
- "You've approved 10 actions"
- "Production enforcement requires upgrade"

Then Stripe. Not before.

---

## What to Stop

- Pricing page work
- Stripe integration
- Invoice/email flows

---

*Created: 2026-03-29. This is Sprint 2 focus after Week 4 decision.*
