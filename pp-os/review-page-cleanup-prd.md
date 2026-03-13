# PRD: Deploy Review Page Cleanup

**Status:** Draft
**Author:** Charles + Rod (QA Sprint #2)
**Date:** 2026-03-11
**Target:** `src/app/pp/deploy-requests/[requestId]/page.tsx`

---

## Problem

The deploy review detail page has too much UI chrome, redundant labels, and buries the action buttons below the fold. The approver's job is simple — "should this go live?" — but the page makes them scroll past noise to find the answer.

## Design Principle

**30-second approval flow:** Land → read PR title → skim summary → glance at risk → approve. Everything above the fold.

---

## Proposed Layout

```
← Back                                              [Deny]  [Approve]

fix: wire contact form to API with Discord webhook
permission-protocol/site  #162  →  main     by rod     2m ago

┌─────────────────────────────────────────────────────────────┐
│ AI summary text here. Just the text, no section header,     │
│ no "generated at" timestamp. Clean block.                   │
└─────────────────────────────────────────────────────────────┘

⚠ API  app/api/contact/route.ts                        MEDIUM

── Changed Files (10 files) ──────────────────────────────────
  app/api/contact/route.ts
  app/api/subscribe/route.ts
  ...
```

---

## What Changes

### 1. PR Title IS the page heading
- Replace "Manual approval required" / "Deploy Review" with the actual PR title
- Use `text-2xl font-semibold` — this is the most important text on the page
- Fallback: `Pull Request #162` if title unavailable, then `{capability}` for non-PR

### 2. Metadata collapses to one line
Replace the 4-card metadata grid with a single line:
```
permission-protocol/site  #162 (linked)  →  main     by rod     2m ago
```
- Repo: muted text
- PR number: linked to GitHub
- Arrow + target branch
- Author (resolved to GitHub login, not machine ID)
- Compact age (right-aligned or inline)
- No cards, no grid, no section header

### 3. Action buttons at TOP RIGHT
- `[Deny]` (secondary/outlined) and `[Approve]` (primary/green) in the header bar
- Visible without scrolling
- For production: Approve triggers the confirmation modal (existing behavior, keep it)
- For non-pending states: show status instead of buttons (Approved ✓, Denied ✗, Expired)

### 4. AI Summary as clean block
- Remove "AI Assessment" section header
- Remove "Generated summary of changes and deployment impact" description
- Remove timestamp
- Just render the summary text in a subtle card/block
- If no summary: hide entirely (don't show empty section)

### 5. Risk signals inline
- Remove "Risk Signals" section header and description
- Each signal: one line with severity badge + signal type + file path
- Only show section when signals exist
- Remove the card wrapper — just a list

### 6. Remove entirely
| Element | Why |
|---------|-----|
| "DEPLOY REVIEW" page label | Obvious from context |
| "Manual approval required" heading | Circular — you're here to approve |
| "Automatic verification did not pass..." | Circular |
| `pending` + `failed` status badges in header | Redundant with being on this page |
| Review URL + Copy button | Who copies URL from the review page |
| "Tenant: Permission Protocol" | You're logged into this tenant |
| "PR Metadata" section header + "Pull request context..." description | Labels describing labels |
| "AI Assessment" section header + description | Just show the summary |
| "Risk Signals" section header + "Pattern-based..." description | Just show the signals |
| AI assessment timestamp | Nobody cares when it was generated |

### 7. Keep (but clean up)
- Changed files section — useful, but make it collapsible and more compact
- Production confirmation modal — keep existing behavior
- Receipt details — move to a collapsible "Details" section at the bottom
- Verification failure details — show as a subtle warning banner, not a section
- Approval history (quorum) — keep if multi-signer, hide if single-signer

### 8. Non-pending states
When viewing an already-decided request:
- Show status prominently: "Approved by rod · 2m ago" or "Expired · 3h ago"
- Keep the same clean layout but swap action buttons for status
- Receipt info goes in a collapsible "Details" at bottom

---

## Technical Notes

### Data Already Available
The API response already includes:
- `prTitle`, `prUrl`, `prAuthor` (via enrichment or direct fields)
- `aiSummary` (enrichment)
- `riskSignals` (enrichment)
- `changedFiles`
- All approval/receipt metadata

### Key Sections to Refactor
The current 2,549-line file has these major sections:
1. Type definitions + interfaces (~100 lines)
2. Helper functions (~200 lines)
3. Main component with multiple nested sections (~2,200 lines)

Keep all the existing logic (approval flow, modals, polling, error handling).
Only change the visual layout and remove UI chrome.

### Don't Break
- Production confirmation modal flow
- Approval with reason
- Risk acceptance flow (for verification-failed requests)
- Polling for status updates
- Deep linking (review URL still works)
- Back navigation
- Mobile responsiveness

---

## Success Metrics
- Approve button visible without scrolling
- PR title is the first thing you read
- Page feels like a decision surface, not a dashboard
