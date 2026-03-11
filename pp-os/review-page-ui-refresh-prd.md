# PRD: Review Page UI Refresh

**Status:** Approved (v2 — rebased on permission-protocol/app)
**Author:** Charles
**Date:** 2026-03-09
**Thread:** #review-page-ui-refresh
**Target Repo:** `permission-protocol/app` (app.permissionprotocol.com)

---

## Problem

The deploy-requests pages (`/pp/deploy-requests` queue + `/pp/deploy-requests/[requestId]` detail) are functionally complete — lane grouping, verification workflows, risk acceptance, receipt crypto, mobile dot-nav. But the UX is optimized for **us** (power users who built it), not for **external users** seeing PP for the first time during the 28-day sprint. The pages need to answer "should this go live?" in under 30 seconds for someone who's never used the product before.

### What Already Works Well
- Lane grouping with history expand (queue page)
- Search by PR#, SHA, repo
- Status filter chips (Pending/Approved/Denied) — already implemented as Button toggles
- Sticky mobile bottom bar with Approve/Deny
- Section dot-nav for mobile (detail page)
- Confirmation dialog before approve
- Production safety checkbox
- Risk acceptance workflow for failed verification
- Receipt preview with crypto details (collapsed by default)
- GitHub rerun status tracking
- Company/tenant context with auto-switch

### What Needs Improvement

**Queue Page (`/pp/deploy-requests`)**
- No summary stats — no sense of "how much is pending and how long"
- Lane cards are dense tables — great for power users, overwhelming for new users
- No visual urgency differentiation — pending lanes look the same as approved history
- "Create Request" form is prominent but rarely used by external users (CI creates requests)
- Empty state says "No pending deploy requests" — misses onboarding opportunity

**Detail Page (`/pp/deploy-requests/[requestId]`)**
- "Awaiting Your Approval" card (the primary CTA) competes with 6 other cards for attention
- Risk signals are buried in their own card below blast radius — should be the FIRST thing after the approval CTA
- Blast radius context (changed files, commit message) is in a separate card from risk signals — these should be together
- Scope card shows canonical fields that external users don't understand (scopeType, scopeHash)
- Receipt preview card is always visible even for pending requests where it's just a preview — cognitive noise
- 6 section cards stacked vertically = a lot of scrolling before you can even see the approve button again
- The top action card has approve/deny but the bottom "Decision Options" card also has expiry/notes — split brain

**Design System**
- CSS variables are GitHub-inspired (good) but cards all look the same — no visual hierarchy
- No animation/motion library — transitions are abrupt
- Table layout (queue) doesn't scale well on tablet widths (920px min-width enforced)

---

## Goals

1. **Approval in <30 seconds** — New user lands, understands risk, decides. Half a minute.
2. **Trust at first glance** — Feels like critical infrastructure, not an internal tool
3. **Information hierarchy** — Most important info (risk + CTA) gets the most visual weight
4. **Mobile-first** — Phone notification → quick approve on mobile without scrolling
5. **Approver ≠ code reviewer** — The UI answers "should this go live?" not "is this code correct?"

---

## Non-Goals

- No new API endpoints or data model changes
- No auth/tenant changes
- No billing/onboarding UI
- No GitLab/Bitbucket support
- No changes to verification/receipt crypto logic

---

## Architecture Decisions (Approved Mar 9)

### D1: Tenant Model
**Decision:** Org-first with user fallback. GitHub App install event is the source of truth.

### D2: Compress Phase A + B → Single Flow
**Decision:** Skip standalone OAuth phase. GitHub App install creates tenant + keys. OAuth is just identity confirmation.

### D3: API Surface
**Decision:** `api.permissionprotocol.com` DNS pointing to Render. Clean separation, zero migration risk.

---

## Design Direction

### Visual Identity
- Keep dark theme (GitHub-inspired `--background: #0d1117`)
- IBM Plex Sans + JetBrains Mono (already set)
- **Permit teal (#44aa99)** = approved/trust, **Deny red (#aa4455)** = blocked/danger
- Use existing accent colors (blue, purple, green, yellow, red) more intentionally
- Reduce card count on detail page — combine related info

### Inspiration
- Vercel's deployment dashboard (status-forward, clean)
- Linear's issue detail (density without clutter)
- GitHub's own PR review page (familiar to our users)

---

## Spec: Queue Page (`/pp/deploy-requests`)

### Summary Stats Bar (new)
Above the search/filter row:
- **Pending count** — big number, amber-colored pulse if >0
- **Avg wait time** — computed from `createdAt` of pending requests
- **Last approved** — relative timestamp
- **Total lanes** — volume context
- Compact: single row, 4 stat blocks

### Lane Card Visual Hierarchy
- **Pending lanes:** Left accent border (amber), slightly elevated shadow
- **Non-pending lanes:** Lower contrast, recessed
- Lane header: keep existing badge layout, add relative time ("waiting 2h 15m")
- Consider card layout (not table) for the primary pending request in each lane — table for history only

### Empty State Enhancement
- Current "No pending deploy requests" → add:
  - "When CI runs with deploy-gate, authorization requests appear here"
  - Link to quickstart docs
  - Visual: GateSymbol animation (unsigned → signed)

### Remove/Demote "Create Request"
- Move from primary header to overflow menu or settings
- External users don't manually create requests — CI does

### Polling
- Keep current fetch-on-tab-focus pattern
- Add: auto-refresh every 10s for pending tab (visual indicator: subtle refresh icon spin)

---

## Spec: Detail Page (`/pp/deploy-requests/[requestId]`)

### Layout Restructure — Reduce from 6 cards to 3 zones

**Zone 1: Decision Zone (top, sticky on desktop)**
Merge current "Awaiting Your Approval" card + "Decision Options" card into ONE:
- Status + GateSymbol + Approve/Deny buttons (always visible)
- Expandable: decision note, expiry selector, deny options
- Production checkbox inline
- Risk acceptance section inline (when verification failed)
- On mobile: this IS the sticky bottom bar (already exists, keep it)

**Zone 2: Context Zone (scrollable middle)**
Merge "Risk Signals" + "Blast Radius Context" + "Context Links" into ONE card:
- **Risk signals first** — colored severity indicators, most important info
- **Changed files** — grouped by directory, with commit message
- **Links** — PR, commit, diff buttons inline
- If no risk signals: green "No elevated risk" banner (already exists, keep it)

**Zone 3: Technical Zone (collapsed by default)**
Merge "Scope" + "Receipt Preview" into collapsible sections:
- Scope fields: only show repo, env, capability, PR# prominently. Hide scopeType/scopeHash/mergeRef behind "Technical Details" toggle
- Receipt preview: only show for decided requests (not pending — it's noise during decision-making)
- Verification details: keep as collapsed `<details>` (already is)

### Section Dot-Nav
- Keep for mobile, update section IDs to match new 3-zone layout
- Remove dots for sections that are now collapsed/merged

### State Transitions
- Pending → Approved: GateSymbol animates from unsigned to signed, green flash on Decision Zone
- Confirmation dialog: keep existing modal pattern
- After approval: Decision Zone transforms to show receipt summary + GitHub rerun status
- Error: inline in Decision Zone with retry

### Mobile
- Sticky bottom bar: keep existing (already 56px-ish)
- Decision Zone at top on mobile should be compact — just status + "scroll down for context"
- Changed files: horizontal scroll for long paths (already handled with `break-all`)

---

## Component Inventory

### New Components
| Component | Description |
|-----------|-------------|
| `SummaryStatsBar` | Queue page stats row (pending count, avg wait, last approved, total) |
| `ContextCard` | Combined risk signals + blast radius + links |

### Existing Components to Modify
| Component | Changes |
|-----------|---------|
| `deploy-requests/page.tsx` | Add stats bar, visual lane priority, demote Create Request |
| `deploy-requests/[requestId]/page.tsx` | Merge 6 cards → 3 zones, promote risk signals, collapse scope/receipt |
| `empty-state.tsx` | Enhance with onboarding copy + GateSymbol animation |
| `gate-symbol.tsx` | Add transition animation for unsigned → signed |

### Existing Components — No Changes Needed
- `Button`, `Card`, `StatusBadge`, `RerunStatusBadge`, `TruncatedSha` — already solid
- `SectionDotNav` — update section IDs only
- Confirmation dialog pattern — keep as-is

---

## Technical Notes

- **Target repo:** `permission-protocol/app` (NOT permissionprotocol-site, NOT Breakout-Labs)
- **No framer-motion** in this repo — use CSS transitions/animations or add it
- **CSS variables** for colors (not Tailwind config) — `var(--permit)`, `var(--deny)`, etc.
- **Component library:** `src/components/ui/` — use existing Button, Card, etc.
- **Existing diff-viewer.tsx** — may be useful for inline diff display (stretch goal)
- **Lane grouping API:** `?groupBy=lane&includeHistory=true` — already implemented
- **Context API:** `/api/v1/deploy-requests/[id]/context` returns risk signals + changed files + commit summary
- **Receipt preview API:** `/api/v1/deploy-requests/[id]/receipt-preview` — already implemented

---

## Success Metrics

- **Time to decision** — <30s from page load to approve click (measure via timestamp diff)
- **Scroll depth before approval** — new user shouldn't need to scroll past fold to approve
- **Zero "where do I approve?" questions** from external users

---

## Phases

### Phase 0: Deploy-Gate Fix (BLOCKER)
- Fix `.result.valid` envelope bug in deploy-gate action/template YAML
- The workflow YAML that ships to new users must correctly unwrap the API response envelope
- Update quickstart/README with corrected YAML

### Phase 1: Foundation
- Queue: summary stats bar, visual lane priority (pending accent), demote Create Request
- Detail: merge Decision Zone (approval CTA + decision options into one card)
- Detail: merge Context Zone (risk signals + blast radius + links into one card)
- Detail: collapse Scope/Receipt into Technical Zone

### Phase 2: Polish
- Gate animation (unsigned → signed on approval)
- Auto-refresh indicator on queue
- Enhanced empty state with onboarding
- Directory grouping for changed files
- Mobile scroll optimization

### Phase 3: Delight (stretch)
- Inline diff snippets in context card
- Sound/haptic feedback on mobile approval
- WebSocket real-time updates (replace polling)

---

## Open Questions

1. **Add framer-motion?** The repo doesn't have it. CSS transitions may suffice, or we add it for the Gate animation. Low cost either way.
2. **Dark mode only?** Current palette is dark-only. Recommendation: yes, dark is the brand.
3. **Table vs card layout for pending lanes?** Current table works for power users. Cards might be friendlier for new users. Could A/B this or just go cards for the primary request, table for history.
