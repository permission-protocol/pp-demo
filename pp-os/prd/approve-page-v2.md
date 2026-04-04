# PRD: Dedicated Approval Route (`/approve/:id`)

**Author:** Charles Goldberg  
**Date:** 2026-04-03  
**Status:** Ready for Build  
**Scope:** New chromeless authorization page replacing the current in-app deploy request review flow

---

## 0. Non-Negotiables (locked before build)

These are the hard-to-reverse decisions. They are not suggestions.

1. **`/approve/:id` is fully chromeless.** No control-plane shell, no sidebar, no nav tabs, no search, no Observe/Freeze, no queue badges, no ambient app chrome. Period.
2. **The page leads with the bound action being signed.** Repo, env, commit, PR, expiry — visible within 2 seconds of landing. The PR title is secondary to the authorization semantics.
3. **The exact execution/authorization preview is visible by default.** Always. Including compact mode. This is the moat. Without it, the page is still just a polished review screen.
4. **The default path is 3 blocks: What / Why flagged / Control status.** No accordion stack as the primary experience.
5. **The compact controls row ships in v1.** Not follow-up.
6. **Generated analysis is visually subordinate to deterministic facts.** Labelled "System Summary" or "Analysis," never "AI Review." Positioned below deterministic signals, inside "Inspect full context."
7. **Post-sign transitions into receipt state.** Not just a success banner. Receipt link + "Back to PR → Merge" button. Ships in Phase 1.
8. **Risk-adaptive density ships in Phase 1.** Low-risk compact vs high-risk full. Not pushed to Phase 2.
9. **Mobile behavior is specified now.** Not a "polish pass" — it's in the spec and ships with Phase 1.
10. **"No backend changes needed" is a convenience, not a constraint.** If a thin backend addition is needed to surface the bound action cleanly, do it.

### The 2-Second Test

> Can the user see the exact action being cryptographically authorized within 2–3 seconds of landing?

If the answer is anything less than **yes**, the implementation is not done. This test outranks typography, component reuse, or whether the helper file already supports the layout.

---

## 1. Problem

The current approval page (`/pp/deploy-requests/:requestId` and `/c/:slug/deploy-requests/:requestId`) wraps the authorization decision inside the full app shell — sidebar nav, top tabs, deploy queue badge, account chrome. When a signer arrives from GitHub (the primary entry point), they land in a control-plane dashboard when they should land on a focused signing screen.

This creates four real problems:

1. **Cognitive load.** The signer must parse ~7 accordion sections + app chrome before reaching the CTA.
2. **Blurred separation of concerns.** The page tries to be both a PR review dashboard and an authorization screen.
3. **Mobile friction.** On mobile (Slack/Teams/email notification click-through), the app shell eats viewport space.
4. **Audit defensibility.** The actual bound action (what the signer puts their name on) is buried under metadata.

## 2. Solution

A new dedicated route `/approve/:id` that renders a **chromeless, single-purpose authorization screen**. No sidebar. No nav tabs. No search. One job: "Do I want to put my name on this production action?"

### Core principle

> **GitHub is the source of truth for code review. Permission Protocol is the source of truth for authorization.**

The page should not try to replicate GitHub's PR review. It should present the authorization decision with enough context to sign confidently.

## 3. Current Data Model (what we have to work with)

### Primary request object: `DeployGateRequest`

```typescript
{
  id, companyId, company: { slug, name },
  repo, ref, commitSha, capability, env,
  prNumber, prTitle, prUrl, prAuthor, headSha,
  status: 'pending' | 'approved' | 'denied' | 'expired' | 'superseded' | 'cancelled',
  verificationStatus: 'NOT_ATTEMPTED' | 'VERIFIED' | 'FAILED',
  decidedBy, approvedBy, decidedAt, reason,
  expiresAt, receiptId, mergeStatus, mergedAt, mergeCommitSha,
  postApprovalActionStatus, post_approval_result,
  githubRerunStatus, quorum,
  createdAt, updatedAt
}
```

### Enrichment (async, from `/api/v1/deploy-requests/:id/enrichment`):

```typescript
ReviewEnrichment {
  summary: string,                    // AI-generated text summary
  jakeReview: {                       // Structured AI verdict
    verdict: 'safe' | 'review' | 'block',
    verdictReason, whatChanged, watchFor[], recommendation
  },
  riskSignals: [{ category, severity, reason, files[] }],
  diff: { files[], promptDiff, title, body, url },
  peerReviews: { total, approved, changes_requested, commented },
  linkedIssue: { title, bodyExcerpt, url, labels[] },
  verificationSteps: [{ step, riskTier }],
  confidenceWarnings: string[]
}
```

### Context (async, from `/api/v1/deploy-requests/:id/context`):

```typescript
RequestContextDetails {
  githubConnected, fallbackMessage,
  commitSummary: { message, author, timestamp },
  changedFiles: string[],
  riskSignals: [{ code, label, severity, why }],
  githubReviewSummary: { status, approvals, changeRequestedBy[] }
}
```

### Merge readiness (async, from `/api/v1/deploy-requests/:id/merge-readiness`):

```typescript
MergeReadiness {
  mergeable, mergeable_state, behind_by,
  checks: [{ name, status, conclusion }],
  checks_passing, checks_total
}
```

### Existing API endpoints (all reusable — no backend changes needed):

- `GET /api/v1/deploy-requests/:id` — primary request
- `GET /api/v1/deploy-requests/:id/context` — context details
- `GET /api/v1/deploy-requests/:id/enrichment` — AI enrichment
- `GET /api/v1/deploy-requests/:id/merge-readiness` — merge status
- `POST /api/v1/deploy-requests/:id/approve` — approve action
- `POST /api/v1/deploy-requests/:id/deny` — deny action
- `POST /api/v1/deploy-requests/:id/merge` — merge PR
- `POST /api/v1/deploy-requests/:id/update-branch` — update branch
- `POST /api/v1/deploy-requests/:id/rerun` — re-run checks
- `GET /api/user` — current user (signer identity)

## 4. Page Structure

### 4.1 Header — The Bound Action

The single most important thing on the page. Answers: "What am I signing?"

```
┌─────────────────────────────────────────────────────────┐
│  🚨 HIGH RISK · PRODUCTION                             │
│                                                         │
│  Authorize production deploy for PR #297                │
│  This is not a GitHub review. This signs deploy         │
│  authorization for commit d3f44f... in                  │
│  permission-protocol/app.                               │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │ deploy_code(                                      │  │
│  │   repo:   permission-protocol/app                 │  │
│  │   pr:     #297                                    │  │
│  │   commit: d3f44f...                               │  │
│  │   env:    production                              │  │
│  │   cap:    deploy                                  │  │
│  │   expiry: 2026-04-04T13:29Z                       │  │
│  │ )                                                 │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Data sources:**
- Risk level: `enrichment.jakeReview.verdict` → map to HIGH/MEDIUM/LOW. Override to HIGH for `env === 'production'`.
- Title: `request.prTitle` or fallback to `enrichment.diff.title`
- Execution preview: `request.repo`, `request.prNumber`, `request.commitSha`, `request.env`, `request.capability`, `request.expiresAt`
- Distinction line: Static copy, always present.

### 4.2 Block 1 — What Will Happen

Plain-English summary of the change and the authorization action.

```
┌─ What will happen ───────────────────────────────────────┐
│  Deploy to: production                                   │
│  Capability: deploy                                      │
│  Author: Charles Goldberg                                │
│  Commit: d3f44f...                                       │
│  Summary: Implements PR6 full funnel telemetry with      │
│           PostHog                                        │
│  After approval: Checks rerun, PR becomes authorized     │
│                  for production. Merge still required     │
│                  in GitHub.                               │
└──────────────────────────────────────────────────────────┘
```

**Data sources:**
- Env: `request.env`
- Capability: `request.capability`
- Author: `request.prAuthor` → `contextDetails.commitSummary.author` → `request.createdByRef`
- Commit: `request.commitSha` (linked to GitHub)
- Summary: `enrichment.jakeReview.whatChanged` → `enrichment.summary` (parsed `.what`) → `request.prTitle`
- After approval: `getAfterApprovalText(request)` — existing helper

### 4.3 Block 2 — Why It Was Flagged

Only show signals that change the decision. No normal facts.

```
┌─ Why it was flagged ─────────────────────────────────────┐
│  ⚠️  Touches deploy approval route                       │
│  ⚠️  Touches webhook API route                           │
│  ⚠️  No linked issue                                     │
│  🔴  No GitHub reviews (0 approvals)                     │
└──────────────────────────────────────────────────────────┘
```

**Data sources (merged + deduplicated):**
- `enrichment.riskSignals[]` — category + reason
- `contextDetails.riskSignals[]` — label + why
- `enrichment.jakeReview.watchFor[]` — each item as a flag
- `contextDetails.githubReviewSummary` — surface if `status !== 'approved'`
- `enrichment.linkedIssue` — surface if `null` (no linked issue)

**Anomaly-based surfacing rules:**
- GitHub reviews: only show if `approvals === 0` or `changes_requested > 0`
- Linked issue: only show if missing
- Author history: only show if `previousDeploys === 0` (new author)
- Each signal item gets severity icon: 🔴 high/critical, ⚠️ medium, ℹ️ low

### 4.4 Block 3 — Control Status (compact row)

One-line signal density. Always visible.

```
┌─ Control status ─────────────────────────────────────────┐
│  CI: ✅ passing · Reviews: ⚠️ 0 · Issue: ❌ none ·     │
│  Rollback: unknown · Expiry: 23h                         │
│                                                          │
│  View diff in GitHub →                                   │
└──────────────────────────────────────────────────────────┘
```

**Data sources:**
- CI: `mergeReadiness.checks_passing === mergeReadiness.checks_total` → ✅/❌/⏳
- Reviews: `enrichment.peerReviews.approved` count
- Issue: `enrichment.linkedIssue` → yes/no
- Rollback: future (static "unknown" for now)
- Expiry: computed from `request.expiresAt` - `now`
- GitHub link: `request.prUrl` or constructed from `request.repo` + `request.prNumber`

### 4.5 Inspect Full Context (collapsed by default)

Everything that doesn't fit the three blocks. Available but not in the default flow.

Uses a single `<details>` element, collapsed by default. Internal sections are flat (no nested accordions).

**Ordering is intentional — deterministic facts first, generated analysis last:**

1. **Changed files** — `enrichment.diff.files[]` or `contextDetails.changedFiles[]`. Collapsed file list with +/- counts. Link to "View diff in GitHub."
2. **Verification steps** — `enrichment.verificationSteps[]`. Concrete, specific steps only (see Non-Negotiable #6).
3. **Peer reviews** — `enrichment.peerReviews` detail.
4. **Author history** — previous deploy count, "new author" badge if `previousDeploys === 0`.
5. **Timeline** — existing `getTimelineEvents(request)`.
6. **Raw request metadata** — repo, commit, env, capability, created/expires timestamps.
7. **System Summary** _(last)_ — `enrichment.jakeReview` or `enrichment.summary`. Labelled "System Summary" (never "AI Review"). Visually de-emphasized: muted border, smaller font, `text-[var(--muted)]` label reading "Auto-generated · not the source of truth." This is subordinate to every deterministic signal above it.

### 4.6 Sticky Signer Footer

Always visible at bottom of viewport. The ceremony.

```
┌──────────────────────────────────────────────────────────┐
│  Signer: rod@permissionprotocol.com                      │
│                                                          │
│  ☑ I am approving a production deploy. I will be         │
│    recorded as the signer. (production only)             │
│                                                          │
│  [LGTM] [Routine] [Reviewed] [Add note...]              │
│                                                          │
│  ┌─────────────────────────┐  ┌────────────────────────┐ │
│  │   Approve & Sign →      │  │       Reject           │ │
│  │      Production         │  │                        │ │
│  └─────────────────────────┘  └────────────────────────┘ │
│                                                          │
│  This action will be cryptographically recorded.         │
└──────────────────────────────────────────────────────────┘
```

**Dynamic CTA logic:**
- Default: **"Approve & Sign"**
- Production env: **"Approve & Sign → Production"**
- AI block verdict + risk accepted: **"Approve Anyway & Sign"**
- Submitting: **"Approving & Signing..."**

The word "Sign" always stays. It's the moat.

**Signer identity:** `currentUser.email` → `currentUser.name` (from `GET /api/user`)

**Checkboxes (conditional):**
- Production confirmation: shown when `request.env === 'production'`
- Risk acceptance: shown when `verificationStatus === 'FAILED'` or `jakeReview.verdict === 'block'`

**Keyboard:** `Cmd+Enter` / `Ctrl+Enter` triggers approve (when not disabled).

### 4.7 Post-Sign → Receipt State

After approval, the page transitions to the signed receipt view (existing `ApprovedSuccessState` component, cleaned up):

- Green checkmark + "Deploy authorized. Human signature recorded."
- Receipt ID linked to `/r/:receiptId`
- "Back to PR → Merge" button (primary CTA)
- Remove the conversion block for non-demo flows (or keep only for first-time users)

## 5. Risk-Adaptive Density

Two modes based on effective risk level:

### Low-risk compact mode

When `jakeReview.verdict === 'safe'` AND `env !== 'production'`:

- Header condenses: single-line title + inline execution preview (same `deploy_code(...)` block, same data, tighter layout — NOT hidden)
- Blocks 1-3 merge into a single compact card (key-value pairs, no separate sections)
- "Why flagged" section omitted if zero risk signals
- Footer shows approve button without production checkbox
- Entire page fits in one desktop viewport

**The execution preview is always visible, even in compact mode.** This is non-negotiable. The bound action is the product.

### High-risk full mode

When `env === 'production'` OR `jakeReview.verdict === 'block'` OR `jakeReview.verdict === 'review'`:

- Full three-block layout as specified above
- Execution preview visible
- Production checkbox required
- Risk acceptance checkbox if AI-blocked
- Footer has full ceremony

## 6. Mobile Behavior

**Viewport targets:** iPhone SE (375px), iPhone 15 (390px), Android mid-range (360px)

**Layout changes at `< 640px`:**
- Header: execution preview stacks vertically, smaller font
- Blocks 1-3: full-width cards, reduced padding (px-3 py-3 vs px-4 py-4)
- Control status row: wraps to 2 lines instead of 1
- Footer: becomes a fixed bottom sheet with `safe-area-inset-bottom` padding
  - Approve button full-width, 48px height minimum touch target
  - Reject button below or beside (flex-wrap)
  - Note presets horizontally scrollable
- "Inspect full context" accordion: touch-friendly 44px tap targets
- No iframe preview (hide `VisualPreview` on mobile — too heavy)

**Sticky footer specifics:**
- `position: sticky; bottom: 0; z-index: 50`
- `backdrop-blur-md` + `bg-[var(--card)]/85`
- `padding-bottom: calc(env(safe-area-inset-bottom) + 12px)` for notched phones
- Content area gets `padding-bottom: 320px` (footer height) to avoid occlusion

## 7. Keyboard Behavior

| Key | Action |
|---|---|
| `⌘+Enter` / `Ctrl+Enter` | Submit approve (when approve is not disabled) |
| `Escape` | Close deny options panel if open |
| `Tab` | Navigate through: note presets → note field → checkboxes → approve → reject |

Implementation: `useEffect` with `keydown` listener on `document`, checking `e.metaKey || e.ctrlKey` + `e.key === 'Enter'`.

## 8. Routing & Layout

### New file structure

```
src/app/approve/[id]/
  layout.tsx    — chromeless layout (no PPLayout, no sidebar)
  page.tsx      — the new approval page component
```

### `layout.tsx`

```typescript
// No PPLayout wrapper. Clean HTML shell.
export default function ApproveLayout({ children }) {
  return (
    <div className="min-h-screen bg-[var(--background)]">
      {children}
    </div>
  );
}
```

### Redirects

The existing routes should remain functional:
- `/pp/deploy-requests/:requestId` — existing page (for in-app navigation)
- `/c/:slug/deploy-requests/:requestId` — existing page (for in-app navigation)
- `/review/:id` — existing public review page (for expired/status checks)

The GitHub App webhook PR comment should link to `/approve/:id` instead of the current `/review/:id` → redirect → `/pp/deploy-requests/:id` chain.

Update in: `src/lib/permission-protocol-v1/deploy-gate/approval-links.ts` (or wherever the PR comment URL is constructed).

## 9. Instrumentation

### PostHog events (extend existing pattern)

| Event | Properties | When |
|---|---|---|
| `pp_approve_page_viewed` | `request_id, env, risk_level, status, compact_mode` | Page load |
| `pp_approve_time_to_decision` | `request_id, env, decision, duration_ms` | Approve or deny submitted |
| `pp_approve_inspect_opened` | `request_id, section` | "Inspect full context" expanded |
| `pp_approve_inspect_section_opened` | `request_id, section_name` | Individual section within inspect opened |
| `pp_approve_keyboard_submit` | `request_id` | `⌘+Enter` approve |
| `pp_approve_compact_mode` | `request_id, env` | Low-risk compact mode rendered |
| `pp_approve_return_to_pr` | `request_id` | "Back to PR" clicked post-approval |

### Key metrics to watch

1. **Time to approve** — median time from page load to approve click (goal: <15s for routine, <60s for high-risk)
2. **Inspect open rate** — % of approvals where "Inspect full context" was opened (goal: <30% for routine = good default density)
3. **Reject rate by risk level** — should correlate with risk (high risk → more rejects = signals working)
4. **Return-to-PR rate** — % clicking "Back to PR" post-approval (should be >80%)
5. **Compact mode conversion** — % of low-risk approvals completed without expanding to full mode

## 10. Implementation Plan

### Phase 1 — This week (ships as one unit)

1. Create `/approve/[id]/layout.tsx` — chromeless shell
2. Create `/approve/[id]/page.tsx` — new component using existing data fetching hooks extracted from current page
3. Implement header with bound action + execution preview (the 2-second test)
4. Implement three-block layout (What / Why flagged / Controls row — compact controls row included)
5. Implement sticky signer footer with dynamic CTA
6. Implement "Inspect full context" collapsed section (move existing accordion content here)
7. Post-sign → receipt state transition (receipt link + "Back to PR → Merge")
8. Risk-adaptive density (compact mode for low-risk, full mode for high-risk/production)
9. Mobile viewport pass (sticky footer with safe-area, touch targets, responsive blocks)
10. Keyboard shortcut (`⌘+Enter` to approve, `Escape` to close deny panel)
11. Update approval link generation to point to `/approve/:id`
12. Wire up existing approve/deny API calls

### Phase 2 — Next week (P1)

1. PostHog instrumentation (all 7 events + time-to-decision tracking)
2. Merge readiness + merge action integration in post-approval state
3. "Return to PR" flow optimization
4. Instrument and analyze time-to-decision metrics

### Phase 3 — Follow-up (P2)

1. A/B test compact mode thresholds
2. Adaptive friction refinements based on instrumentation data

## 11. What's Explicitly Out of Scope

- **No changes to existing routes.** `/pp/deploy-requests/:id` stays for in-app nav.
- **No changes to the approval/deny logic.** Same API calls, same payloads.
- **No diff viewer.** "View diff in GitHub" link only. GitHub handles code review.
- **No design system migration.** Uses existing CSS variables and component library.

### Backend changes: allowed if needed

Existing endpoints cover the current data model well. But if surfacing the bound action cleanly requires a thin backend addition (e.g., a computed `boundAction` object on the deploy request response, or a dedicated `/approve-context` endpoint that bundles the header data in one call), that's allowed. Convenience of zero backend changes does not outrank UX clarity.

## 12. Component Reuse Plan

From the current `review-page-helpers.tsx` (reuse directly):
- All TypeScript types (`DeployGateRequest`, `ReviewEnrichment`, `RequestContextDetails`, `MergeReadiness`, etc.)
- Helper functions: `formatDateTime`, `formatTimeAgo`, `formatExpiryDuration`, `getAfterApprovalText`, `getApprovedByText`, `getBlastRadiusText`, `parseAiSummary`, `getSeverityClasses`, `getTimelineEvents`, `shortSha`, `areAllChecksPassing`, `getCheckSummary`
- `DENY_REASON_OPTIONS` constant

From existing components (reuse directly):
- `EnvironmentBadge`
- `StatusBadge`
- `TruncatedSha`
- `Button`, `Card`, `CardContent`, `CardHeader`, `CardTitle`, `CardDescription`

**New components to build:**
- `ExecutionPreview` — the `deploy_code(...)` block
- `ApproveHeader` — bound action header
- `SignalBlock` — "Why it was flagged" with anomaly filtering
- `ControlStatusRow` — compact one-line status
- `SignerFooter` — sticky bottom with dynamic CTA
- `InspectContext` — collapsed advanced section

## 13. User Journey

1. Developer opens PR on `permission-protocol/app` targeting `main`
2. Deploy-gate GitHub Action creates a deploy request, posts a PR comment with a link: `https://app.permissionprotocol.com/approve/abc123`
3. Signer (engineering manager) clicks the link from GitHub
4. **Page loads.** No login redirect if already authenticated. Chrome-free. They see:
   - "Authorize production deploy for PR #297" with the execution preview
   - Three tight blocks: What / Why flagged / Control status
   - Sticky footer with "Approve & Sign → Production"
5. **Routine flow (15 seconds):** Signer scans header, sees ✅ CI passing, clicks "LGTM" chip, hits `⌘+Enter`. Done.
6. **Careful flow (60 seconds):** Signer sees ⚠️ "No reviews" + "Touches webhook route". Opens "Inspect full context", checks the system summary, clicks "View diff in GitHub", returns, approves.
7. **Page transitions to receipt.** "Deploy authorized. Human signature recorded." With receipt link and "Back to PR → Merge" button.
8. Signer clicks "Back to PR → Merge", completes the merge on GitHub.

## 14. Customer Test Gate

> Would a new external user arriving from a GitHub PR comment understand this page without help?

If they'd get stuck on any of these questions, the design has failed:
- "What am I authorizing?" → Header + execution preview must answer in 2 seconds
- "Why does this need my approval?" → "Why flagged" block must answer in 5 seconds
- "What happens when I click approve?" → "After approval" line + footer copy must be unambiguous
- "Where's my proof?" → Post-sign receipt must be immediately visible
