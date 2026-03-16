# PRD: idea-046 — Audit Log: Resolve Raw IDs to Usernames

**Issue:** permission-protocol/app#122
**Priority:** P1
**Repo:** permission-protocol/app

## Problem
Audit log "Requested by" column shows raw IDs like `cmkrc6fib000090cjwvvrstlq`. "Decision" column truncates to "Decisi..." on default viewport.

## Requirements

### Must Have
1. **Requested by column:** Resolve internal IDs to display names
   - If a GitHub username is available (from the deploy request or user record), show it
   - If only internal ID exists, show a truncated version with copy-on-click: `cmkrc6...rstlq`
   - If the requestor is "system", show "System" with a system icon
   
2. **Decision column:** Must not truncate
   - Use full word "approved" / "denied" / "expired"
   - OR use icons: ✅ Approved, ❌ Denied, ⏰ Expired
   - Column should have `min-width` to prevent truncation

3. **Responsive table:** On smaller viewports, consider:
   - Horizontal scroll rather than column truncation
   - Or: collapse less-critical columns (connector, requested by) into an expandable row

### Implementation Notes
- Audit log page likely fetches from `/api/audit` or similar
- The API response probably includes raw user IDs — check if there's a join to users table that provides display names
- If not, add a lightweight lookup (batch resolve user IDs to names)

### Must NOT Do
- Don't change the audit log API response structure
- Don't add new API endpoints unless necessary
- Don't change filter/search functionality
