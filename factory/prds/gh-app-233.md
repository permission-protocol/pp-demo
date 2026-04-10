# PRD: [permission-protocol/app] MCP Guard Day 2 — approval hold path + receipt viewer

**Idea:** gh-app-233  
**Priority:** P0  
**Complexity:** M  
**Persona:** Marco, Sarah  

---

## Summary
Implements the core "governance-in-the-loop" pattern for MCP Guard. This enables the system to pause an agent's tool call when a policy requires approval, and provides a public receipt viewer for transparency and auditability. This is critical for the "Signer Decision" value proposition.

## Problem
Currently, MCP Guard (v0.1) can intercept and proxy, but it doesn't have a clean "hold and wait for human" state that integrates with the agent's tool-calling loop. Additionally, there is no easy way for a human to verify a decision's proof without digging into raw JSON logs.

## Solution
1. **Approval Hold Path**: Update the `require_approval` outcome to return a specific `{ "status": "held", "receipt_id": "..." }` response to the agent.
2. **Receipt Viewer**: Create a public route `/r/[id]` that renders a signed receipt's details (Action, Decision, Signer, Timestamp).
3. **SDK Integration**: Ensure `pp.gate()` or similar handles the held state.

## User Journey
1. **Agent** attempts a sensitive tool call (e.g., `delete_database`).
2. **MCP Guard** intercepts, evaluates policy, and hits `approval_required`.
3. **MCP Guard** returns a "held" status to the agent with a `receipt_id`.
4. **Human** receives a notification with a link to the receipt viewer.
5. **Human** approves the request via the viewer or dashboard.
6. **Agent** (or proxy) sees the approval and proceeds.

## Files to Change
- `src/lib/enrichment/outcome-router.ts`: Add `held` status to the router logic.
- `src/app/api/v1/receipts/verify/route.ts`: Ensure it supports looking up held receipts.
- `src/app/r/[id]/page.tsx`: Implement the public receipt viewer component (based on the demo receipt page).
- `src/lib/public-receipts.ts`: Add helper to fetch real receipt data for the viewer.

## Acceptance Criteria
- [ ] `outcome-router` returns `held` status for `approval_required` outcomes.
- [ ] `/r/[receiptId]` correctly renders data for a real receipt ID.
- [ ] Receipt viewer handles "Pending" vs "Approved" vs "Denied" states.
- [ ] `npx tsc --noEmit` passes.

## Edge Cases
1. **Receipt Not Found**: Show 404 with a helpful message.
2. **Expired Receipt**: Show "Expired" status in the viewer.
3. **Tampered Signature**: Display a prominent "INVALID SIGNATURE" warning.

## Out of Scope
- Integration with Slack/Discord notifications (handled by separate notification service).
- Agent-side retry logic (assumed to be handled by the agent framework or MCP host).

## Codex Prompt
You are implementing the MCP Guard Day 2 features: approval hold path and a public receipt viewer.

1. **Modify `src/lib/enrichment/outcome-router.ts`**:
   - Update the `routeOutcome` function to return `status: "held"` when the policy outcome is `approval_required`.
   - Ensure a `receipt_id` is included in the returned object.

2. **Implement `src/app/r/[id]/page.tsx`**:
   - Use the existing `src/app/demo/receipt/page.tsx` as a visual template.
   - Use `getPublicReceiptView` from `src/lib/public-receipts.ts` to fetch real receipt data.
   - Handle the `params.id` correctly (it might be a demo ID or a real receipt ID).
   - Display Action, Decision (Pending/Approved/Denied), Signer, and Timestamp.
   - For real receipts, show the `signature_value` and a "Verified ✓" badge if the signature is valid.

3. **Update `src/lib/public-receipts.ts`**:
   - Ensure `getPublicReceiptView` can fetch receipts by ID from the `permissionReceipt` table using `rawPrisma`.

Follow the pattern in `src/app/api/v1/public/receipts/[receiptId]/route.ts` for receipt lookup.

Before finishing, run `npx tsc --noEmit` and fix any type errors.
