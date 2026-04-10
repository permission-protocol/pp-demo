# PRD: Polish V3 — Monospace Metadata & Section Labels

## Summary
Apply `font-mono` (JetBrains Mono) to all metadata elements: timestamps, commit SHAs, IDs, version numbers, and uppercase section labels. This reinforces the "terminal-chic" aesthetic from DESIGN.md.

## Problem
DESIGN.md specifies: "Use Space Mono for small metadata (timestamps, IDs, version numbers)" and section label typography. The app uses Inter for almost all metadata, making it feel like a generic SaaS tool rather than a developer protocol.

## Scope

NOTE: If the typography PRD (polish-v3-01) already handled sidebar section labels, skip those here. This PRD focuses on **metadata in the main content area**.

### 1. Sidebar Section Labels (`src/components/layout/sidebar.tsx`)
The `<p>` elements with `uppercase tracking-wider` text ("DEPLOY GATE", "ADMIN"):
- Add `font-mono` to their className

### 2. Dashboard Page (`src/app/pp/page.tsx`)
- **Stat card labels** — the small text above stat numbers (e.g., "Pending", "Approved Today") → add `font-mono`
- **Relative timestamps** — "3m ago", "2h ago" in recent activity and queue cards → add `font-mono`
- **Commit SHA displays** — any truncated SHA → add `font-mono`
- **PR number displays** — "PR #123" → add `font-mono` to the number part, or whole span

### 3. Deploy Request List (`src/app/pp/deploy-requests/page.tsx`)
- **Timestamps** in list items → `font-mono`
- **Status text** if displayed as text (not just badge) → `font-mono`

### 4. Deploy Request Detail (`src/app/pp/deploy-requests/[requestId]/page.tsx`)
- **Request ID** → `font-mono`
- **Commit SHA** → `font-mono`  
- **Timestamps** (created, updated, approved at, etc.) → `font-mono`
- **Environment labels** if displayed as text → `font-mono`
- **File paths** in diff viewer → `font-mono` (may already be applied)

### 5. API Keys Page (`src/app/pp/api-keys/page.tsx`)
- **Key prefix** (e.g., `pp_live_...`) → `font-mono` (may already have it)
- **Created/last used timestamps** → `font-mono`
- **Scope labels** → `font-mono`

### 6. Activity Page (`src/app/activity/page.tsx`)
- **Timestamps** → `font-mono`
- **Action IDs** → `font-mono`

### 7. Audit Page (`src/app/audit/page.tsx`)
- **Timestamps** → `font-mono`
- **Event IDs/types** → `font-mono`

### 8. Shared Components
**`src/components/ui/truncated-sha.tsx`** — add `font-mono` if not present
**`src/components/ui/environment-badge.tsx`** — add `font-mono` to the badge text
**`src/components/ui/status-badge.tsx`** — consider adding `font-mono` (status text like "pending", "approved" reads well in mono)

### Do NOT Change
- Headlines or body text
- Button labels
- Navigation text
- Form field labels or placeholders
- Long-form content (AI summaries, descriptions)

## Implementation Notes
- `font-mono` maps to `'JetBrains Mono', monospace` via tailwind.config.ts
- For timestamps, look for `formatRelativeTime`, `formatTimeAgo`, `formatDateTime` usage — wrap their output spans in `font-mono`
- For SHAs, look for `shortSha`, `truncatedSha`, or raw SHA substring displays
- The change is purely additive — adding a className

## Verification
- Timestamps across the app render in JetBrains Mono
- SHAs and IDs look distinctly monospace
- Sidebar section labels have a "terminal" feel
- `next build` passes
- No text overflow (JetBrains Mono is slightly wider than Inter at same size — verify no truncation issues)

## Customer Test
"Can you tell this is a developer tool at a glance?" — monospace metadata is the strongest signal.
