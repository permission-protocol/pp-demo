# Spec: Consolidate Redundant Approval Badges

## Problem
After approval, the deploy request page shows three separate green indicators:
1. **"Approved"** — top status banner
2. **"approved"** — inline status near the author/timestamp line
3. **"Verification verified"** — in the sidebar "At a Glance" panel

They all look the same (green badges) and convey the same feeling: "this was approved." A user sees three green things and thinks "why is it telling me three times?"

## What They Actually Mean
- **Status: approved** — the deploy request was approved by a human
- **Approval: APPROVED** — quorum was met (1/1 approvals)
- **Verification: VERIFIED** — the receipt was cryptographically verified (signing check passed)

These are technically distinct, but only the last one matters to show separately — and even then, only if someone cares about cryptographic proof.

## Proposed Design

### Primary State (one clear indicator)
Show ONE prominent status at the top:
```
✅ Approved by rodchalski · 2m ago
```
This replaces the top banner + inline status. One line. Done.

### Sidebar "At a Glance" — Simplify
Instead of:
```
Status    approved
Approval  APPROVED
Verification VERIFIED
Quorum    1/1
```

Show:
```
Status       ✅ Approved
Approved by  rodchalski
Quorum       1/1 ✓
Receipt      🔗 Verified
```

- Merge "Status" and "Approval" into one field (they're always the same)
- "Verification" becomes a subtle indicator on the receipt link — if verified, show a checkmark; if not, show a warning
- The user doesn't need to know what "Verification VERIFIED" means in the abstract

### Remove Inline Status Badge
The "approved" badge next to the author name ("Charles Goldberg 3m ago **approved**") should just be the timestamp/author line. The status is already shown at the top. Don't repeat it inline.

## Rules
- **One primary status indicator** — the top banner
- **No duplicate status badges** — if status is shown at the top, don't show it inline too
- **Verification is a receipt property**, not a page-level status — show it as an icon/badge on the receipt link, not as a standalone row

## Files Likely Changed
- Deploy request detail page component (top banner, inline status, sidebar)
- Sidebar "At a Glance" component

## Priority
Medium-high — visual clutter erodes trust. Clean UI = professional product.
