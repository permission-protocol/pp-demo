# PRD: idea-043 — Fix /r/demo receipt (seed demo receipt)

**Issue:** permission-protocol/app#120
**Priority:** P0
**Repo:** permission-protocol/app

## Problem
The homepage hero CTA "See the receipt →" links to `/r/demo` which returns "Receipt not found". This is the #1 conversion mechanism — visitors who click it see a dead end.

## User Journey
1. Visitor lands on permissionprotocol.com
2. Reads "Who authorized that AI action?"
3. Clicks "See the receipt →" (primary CTA)
4. **Current:** "Receipt not found" error page
5. **Expected:** Beautiful, interactive demo receipt

## Requirements

### Must Have
- `/r/demo` renders a fully populated demo receipt (not an error)
- Receipt shows all fields: action, agent, approver, policy, timestamp, signature status
- Works without any DB seeding (hardcoded fallback if no DB record exists)
- Matches the receipt mockup shown on the homepage

### Implementation
In the receipt page component (`/r/[id]` or equivalent):
1. Check if the ID is `demo`
2. If yes, render a hardcoded demo receipt with these values:
   - Action: `deploy → billing-service`
   - Agent: `deploy-bot`
   - Approved by: `Sarah Kim`
   - Policy: `production-deploy`
   - Timestamp: Current date minus 2 hours (feels fresh)
   - Environment: `production`
   - Signature: `Verified ✓`
   - Receipt URL: `permissionprotocol.com/r/demo`
3. If no, proceed with normal DB lookup

### Must NOT Do
- Don't change the receipt page layout or styling
- Don't modify the DB schema
- Don't affect real receipt rendering

## Customer Test
A new visitor clicks "See the receipt" from the homepage. They see a complete, professional receipt that demonstrates the product's value in 5 seconds. They think: "I want this for my deploys."

## Files Likely Touched
- `src/app/r/[id]/page.tsx` (or wherever the receipt route lives)
- Possibly a `demo-receipt.ts` constants file
