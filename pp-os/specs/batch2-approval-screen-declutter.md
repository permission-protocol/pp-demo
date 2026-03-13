# Spec: Approval Screen Declutter — Remove What Marco Doesn't Need

## Problem
The approval screen is designed for a power user, not for Marco (engineering manager) or Sarah (security lead) who just got a link and need to make a quick decision. Half the screen is internal plumbing they don't care about.

## Audit: What's on screen vs what Marco needs

### ❌ REMOVE — Marco doesn't need these:

1. **"← Back to Queue"** — Marco came from a link. He has no queue. He's not a Control Plane user. This is admin navigation, not approver UI.

2. **"Opened 6m ago"** — Irrelevant to the decision. Minor clutter.

3. **Quick-tag buttons ("Reviewed", "LGTM", "Routine deploy")** — These are workflow tags for power users managing a queue of requests. Marco is approving ONE deploy. He doesn't need to categorize it.

4. **"Reason for approval (optional)" text box** — Nice to have for audit, but it's taking up prime real estate above the fold. Should be collapsed or tucked into the approve flow (show after clicking Approve, not before).

5. **"Confirm production deploy for f7485a1"** — The commit SHA means nothing to Marco. Should say "Confirm production deploy for **pp-demo**" or just be part of the Approve button ("Approve for Production").

6. **"Automatic verification did not pass. Approval requires explicit risk acceptance."** + **"I accept the verification risk"** — This is internal verification state (RECEIPT_NOT_FOUND because signing key isn't set). Real users shouldn't see this. When verification is genuinely relevant, it should be a simple warning, not a checkbox gate. Currently it's showing because of OUR missing config, not because of actual risk.

7. **"Advanced" expander** — What's in it? If it's admin-only settings, hide from the approve flow entirely.

8. **Reject reason pills ("Needs more review", "Wrong scope", "Suspicious change", "Other")** + **"Require a new request" checkbox** — These belong in the Deny flow, not visible by default. Show only after clicking Deny.

9. **"pending" badge** — He knows it's pending. He's here to change that.

10. **"Risk acceptance required" badge** — Internal verification state, not a user-facing concept.

11. **"Automatic verification did not pass" warning (shown TWICE)** — Once in the checkbox area, once as a yellow banner below the title. Redundant AND confusing.

12. **"Technical details (RECEIPT_NOT_FOUND)"** — Absolutely not for Marco. This is a debug message.

### ✅ KEEP — What Marco actually needs:

1. **PR title** — "feat: add config validator utility"
2. **Repo + PR number** — permission-protocol/pp-demo · PR #16
3. **Author + time** — Charles Goldberg · 6m ago
4. **AI Summary** — (redesigned per batch 2 spec #1)
5. **Risk Signals** — quick visual risk level
6. **Changed Files** — what's in this deploy
7. **Approve / Deny buttons** — the action
8. **Production confirmation** — but worded for humans, not SHAs

## Proposed Approval Screen Layout

```
feat: add config validator utility
permission-protocol/pp-demo · PR #16 · by Charles Goldberg · 6m ago

┌─ AI Summary ─────────────────────────────┐
│ What: Config validation utility           │
│ Risk: 🟢 Low — new file, no existing     │
│       code modified                       │
│ Action: ✅ Safe to merge                  │
└───────────────────────────────────────────┘

▸ Risk Signals (1 high)
▸ Changed Files (1) +8 -0

┌───────────────────────────────────────────┐
│  This deploys to production.              │
│  [ ✅ Approve ]         [ ✖ Deny ]       │
└───────────────────────────────────────────┘
```

- Approve button includes production confirmation inline (no separate checkbox)
- Deny click expands reject reason options (not shown by default)
- Approval reason is optional, shown as small "Add a note..." link
- No queue nav, no tags, no debug info, no verification plumbing

## Implementation Notes
- The approval screen (public review page) and the Control Plane detail page may be different components — or the same with role-based rendering
- If same component: detect if user came from a review link vs from the queue, show different chrome
- If separate: the review page should be the clean version above; Control Plane keeps admin features
- When verification fails due to missing config (RECEIPT_NOT_FOUND), don't show it as a user-facing risk — log it server-side

## Files Likely Changed
- Approval/review page component
- Possibly the public review page at permissionprotocol.com/review/[id]
- Verification warning component (hide debug details from non-admin users)

## Priority
Critical — this IS the product. This is what every potential customer sees first.
