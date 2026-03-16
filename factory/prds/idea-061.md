# PRD: idea-061 — Role-based dashboard views (Sarah vs Marco)

**Issue:** permission-protocol/app#142
**Priority:** P3
**Repo:** permission-protocol/app
**Size:** M

## Problem
Security leads (Sarah) and engineering managers (Marco) see identical dashboards. Their priorities are completely different:
- **Sarah** cares about: audit trails, compliance status, policy violations, risk exposure
- **Marco** cares about: PR velocity, blocked deploys, team throughput, approval queue

Showing everyone the same view means nobody gets their ideal view.

## User Journey (Current)
1. Sarah logs in → sees generic stats (total requests, repos, recent deploys)
2. Has to click into Audit Log to find compliance-relevant data
3. Dashboard doesn't surface what she actually needs

## User Journey (Expected)
1. User opens Settings → selects their role (Security / Engineering / Custom)
2. Dashboard rearranges to show role-relevant widgets first
3. Sarah's view: compliance score, policy violations this week, risk distribution, audit trail preview
4. Marco's view: pending approvals, avg approval time, blocked PRs, deployment velocity

## Requirements

### Must Have
1. **Role selector:** In Settings (or on first visit), user picks their role:
   - `security` — Sarah persona
   - `engineering` — Marco persona
   - (No "admin" or "custom" in v1 — keep it simple)
2. **Dashboard layout per role:**

   **Security (Sarah):**
   - Top row: Pending high-risk requests (count), Policy violations this week, Audit events today
   - Second row: Risk distribution chart (routine/review/high-risk breakdown)
   - Third row: Recent audit trail (last 10 entries, inline, no click-through needed)
   - Queue: sorted by risk level (high-risk first)

   **Engineering (Marco):**
   - Top row: Pending approvals (count), Avg approval time, Deployments today
   - Second row: Blocked PRs requiring action, Team deployment velocity (week over week)
   - Third row: Recent deploy requests (the current queue view)
   - Queue: sorted by wait time (oldest first)

3. **Shared elements:** Both views keep the repo list, nav bar, and settings access
4. **Default:** If no role selected, show current dashboard (backwards compatible)
5. **Persistence:** Role stored in user preferences (localStorage or DB)

### Implementation
- Role preference: add to user settings (localStorage for v1 is fine — DB in v2)
- Dashboard page: read role, conditionally render widget layout
- Widgets: create reusable stat cards that pull from existing API data
  - Most data already exists: deploy requests have risk levels, timestamps, status
  - Audit log data exists in the audit API
  - Velocity/timing metrics can be computed client-side from recent requests
- New components:
  - `src/app/pp/components/dashboard-security.tsx`
  - `src/app/pp/components/dashboard-engineering.tsx`
  - `src/app/pp/components/role-selector.tsx`

### Must NOT Do
- Don't add RBAC/permissions — this is about *views*, not *access control*
- Don't create separate pages — both roles use the same `/pp` dashboard route
- Don't add new API endpoints in v1 — compute metrics client-side from existing data
- Don't remove any existing dashboard functionality — role views add widgets, they don't remove

## Acceptance Criteria
- [ ] Settings page has role selector (Security / Engineering)
- [ ] Dashboard renders different widget layout per role
- [ ] Security view shows risk-focused metrics and audit preview
- [ ] Engineering view shows velocity-focused metrics and approval queue
- [ ] No role selected → current dashboard (backwards compatible)
- [ ] Role persists across sessions
- [ ] Both views are responsive (mobile-friendly)
