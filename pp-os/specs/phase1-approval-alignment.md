# Phase 1: Approval Surface Visual Alignment + Cross-Linking

**Goal:** Make the marketing site (`permissionprotocol.com`) and app (`app.permissionprotocol.com`) approval pages feel like the same product without moving any code between repos.

**Scope:** Visual alignment + cross-linking only. No shared components yet (that's Phase 2).

---

## Current State

### Marketing Site (permissionprotocol-site)
- **Pages:** `/review`, `/review/{id}`, `/approve/{id}`, `/r/{id}`
- **Colors:** void `#0a0a0a`, ash `#1a1a1a`, card `#111`, border `#222`, permit `#44aa99`
- **Fonts:** Space Grotesk + Space Mono
- **Corners:** `rounded-2xl` (16px), `rounded-xl` (12px)
- **Vibe:** Custom/branded, teal accent, Framer Motion animations, radial gradient bg
- **Approval UX:** Sticky bar with reason presets, approve/reject, merge & deploy, receipt link

### App Platform (pp-app)
- **Pages:** `/pp/deploy-requests`, `/pp/deploy-requests/{id}`
- **Colors:** bg `#0d1117`, card `#161b22`, border `#30363d`, permit `#44aa99`, accent-blue `#58a6ff`
- **Fonts:** IBM Plex Sans + JetBrains Mono
- **Corners:** `rounded-lg` (8px)
- **Vibe:** GitHub-inspired, blue/purple accents, no animations, shadcn components
- **Approval UX:** Full-page with sections, receipt preview, crypto details, risk acceptance, CI rerun

### What They Share Already
- `permit` color: `#44aa99` (used in both)
- `deny` / `danger`: red tones
- Dark backgrounds (close but not identical)
- Same PP backend API

### Key Visual Gaps
| Property | Marketing Site | App | Decision |
|---|---|---|---|
| Background | `#0a0a0a` | `#0d1117` | → `#0a0a0a` (darker, more premium) |
| Card bg | `#111111` | `#161b22` | → `#111111` on approval pages |
| Border | `#222222` | `#30363d` | → `#222222` (subtler) |
| Primary text | `#c8c8c8` | `#e6edf3` | → `#c8c8c8` (less stark) |
| Secondary text | `#888888` | `#8b949e` | → `#888888` |
| Primary accent | `#44aa99` (permit) | `#58a6ff` (blue) | → `#44aa99` on approval pages |
| Font | Space Grotesk | IBM Plex Sans | Keep each site's font (acceptable difference) |
| Corners | `2xl` (16px) | `lg` (8px) | → `xl` (12px) on app approval pages |
| Approve button | bg-[#10B981] | shadcn default | → `#10B981` (same green) |
| Deny button | border-danger + danger/10 | shadcn variant="danger" | → same red treatment |

---

## Changes

### 1. App Approval Page — Visual Update (pp-app)

**File:** `src/app/pp/deploy-requests/[requestId]/page.tsx`

Add a scoped CSS class or inline overrides on the approval page only (don't change the whole app theme — the dashboard, settings, etc. can stay GitHub-styled):

```css
/* Approval page overrides — scoped to .approval-surface */
.approval-surface {
  --background: #0a0a0a;
  --card: #111111;
  --card-hover: #1a1a1a;
  --border: #222222;
  --foreground: #c8c8c8;
  --muted: #888888;
}
```

Update the approval page wrapper:
- Add `className="approval-surface"` to the root div
- Change Card border-radius to `rounded-xl` (12px) on this page
- Change approve button to `bg-[#10B981]` (matching marketing site green)
- Change deny button styling to match: `border-[#EF4444] bg-[#EF4444]/10`

**Estimated effort:** 1-2 hours. Scoped overrides, no cascading risk.

### 2. Approve Button Consistency

Both sites should use the same approve/deny visual language:

| Action | Background | Text | Border |
|---|---|---|---|
| Approve | `#10B981` | `#0a0a0a` (void) | none |
| Deny / Reject | `transparent` | `#c8c8c8` (signal) | `#EF4444` |
| Merge & Deploy | `#6366F1` (indigo) | `#ffffff` | none |

Marketing site already matches this. App needs button styling updated on the approval page.

### 3. Status Badge Alignment

Both should render status the same way:

| Status | Style |
|---|---|
| Pending / Review Required | `border-warning/60 bg-warning/15 text-warning` |
| Approved | `border-[#10B981]/60 bg-[#10B981]/15 text-[#10B981]` |
| Denied | `border-danger/60 bg-danger/15 text-danger` |
| Expired / Cancelled | `border-border bg-card text-muted` |

Marketing site uses this pattern. App uses a `StatusBadge` component — update its colors to match.

### 4. Cross-Linking

#### Marketing Site → App
Add to `/review/{id}` page, below the approval card (when request has receipt or post-decision):

```
🔐 View full audit trail → app.permissionprotocol.com/pp/deploy-requests/{id}
```

- Only show when user is authenticated
- Links to same request ID on the app
- Small, secondary text — not a CTA

#### App → Marketing Site
Add to `/pp/deploy-requests/{id}` page, in the top header area:

```
🔗 Shareable link: permissionprotocol.com/review/{id}  [Copy]
```

- Always visible (the whole point is sharing)
- Copy button copies the marketing site URL
- This is how people share approval links externally

#### Receipt Cross-Link
App's post-approval receipt section should link to the marketing site receipt page:

```
View receipt → permissionprotocol.com/r/{receiptId}
```

The marketing site receipt page (`/r/{id}`) is the shareable, public-friendly receipt. The app receipt section is detailed/internal.

### 5. "Same Product" Signals

Small touches that make both feel like one product:

- **PP logo/wordmark** in the same position (top-left) on both approval pages
- **"Powered by Permission Protocol"** footer on both (marketing site has it, app doesn't)
- **Same favicon** (verify both use the PP shield icon)

---

## What NOT to Change

- **App dashboard/settings/nav** — keep the GitHub-inspired look. Only the approval page gets aligned.
- **Marketing site** — it's the reference. No changes needed (it's already the target visual).
- **Fonts** — Space Grotesk vs IBM Plex Sans is fine. They're both clean sans-serifs. Forcing one font across both adds build complexity for minimal visual gain.
- **Animations** — Don't add Framer Motion to the app. The app can stay static. The marketing site can keep its motion.
- **Component library** — App keeps shadcn. Marketing site keeps raw Tailwind. Phase 2 handles component sharing.

---

## Implementation Order

1. **App approval page color overrides** (30 min) — scoped CSS variables
2. **App approve/deny button styling** (30 min) — match marketing site colors
3. **App status badge colors** (20 min) — update StatusBadge component
4. **App border-radius on approval page** (10 min) — `rounded-xl`
5. **Cross-links: app → marketing site** (30 min) — shareable link + receipt link
6. **Cross-links: marketing site → app** (30 min) — audit trail link
7. **Footer + favicon check** (15 min) — consistency

**Total estimated: ~3 hours of coding**

---

## Success Criteria

- [ ] Screenshots of both approval pages side-by-side look like the same product
- [ ] Approve/deny buttons are visually identical
- [ ] Status badges use the same colors
- [ ] User can get from marketing site → app audit trail in one click
- [ ] User can copy shareable marketing site link from the app
- [ ] Receipt links work cross-site

---

## Phase 2 Preview (Not In Scope)

Extract shared `@pp/approval-ui` component package:
- `ApprovalCard` — the core approve/reject + reason UI
- `StatusBadge` — consistent status rendering
- `RiskSignals` — risk signal display
- `ReceiptCard` — post-approval receipt view
- Monorepo (Turborepo) with both sites as apps, shared packages
- Single source of truth for approval UX
