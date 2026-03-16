# Marco Requirements — Gap Analysis & Execution Plan

**Date:** 2026-03-16
**Based on:** `marco-user-requirements.md` (v2, 29 requirements)
**Compared against:** `permission-protocol/app` @ commit `671004f` and `permission-protocol/site` @ commit `6e89e69`

---

## Current State Summary

The app has gone through a major consolidation. All review/approval flows are now on `app.permissionprotocol.com`. The codebase already has:

- Deploy request capture via deploy-gate GitHub Action
- Enrichment pipeline (PR diff + risk signals + AI summary via Gemini)
- Dashboard with stats bar, list/stack views, repo filter pills, status filters
- Detail page with AI summary (parsed into risk level + action + details), risk badges, diff viewer, merge readiness checks, branch update, conflict detection
- Approve/deny with reason presets
- Receipts (create, verify, export, public view)
- Merge from PP (direct GitHub merge, not merge queue)
- Slack notifications
- Peer reviews from GitHub API
- Author track record (deploy history, "new author" warning)
- Deploy preview URL detection (fetches from GitHub Deployments API, embeds iframe)
- Mobile responsive dashboard + sticky approve/reject on detail page
- Bulk approve (low-risk, non-production)
- Timeline view
- Reject reason presets (Not ready, Needs tests, Wrong branch, Needs discussion)
- Approve note presets (LGTM, Routine deploy, Reviewed)

---

## Gap Analysis: Requirement by Requirement

### ✅ = Exists and complete
### 🟡 = Partially exists, needs enhancement
### 🔴 = Does not exist, needs to be built

---

### Core (Sprint 1-2)

| Req | Status | What Exists | Gap |
|---|---|---|---|
| **M1. Deploy Request Capture** | 🟡 | deploy-gate Action captures PRs, creates requests. Enrichment runs (diff + risk + AI summary). | **Missing:** Verification checklist generation. Origin context resolution (linked issue, factory source). Enrichment doesn't include verification steps. Preview URL is fetched on-demand, not pre-computed at capture. |
| **M2. Push Notification** | 🟡 | Slack notifications on approval (post-approval-actions.ts). Slack connector with governance. | **Missing:** Notification on NEW request arrival (current notifications fire on approval, not on PR creation). Email channel. Discord webhook channel. Browser push. Configurable trigger (all/high-risk/digest). Notification links to review page. This is inverted — notifications need to be the entry point, not just the outcome. |
| **M3. Review Page** | 🟡 | Detail page has: AI summary, risk badges, diff viewer, merge readiness, approve/deny, receipts, timeline, author track record, peer reviews, deploy preview iframe, PR metadata. | See sub-requirement gaps below. |
| **M3a. Visual Preview** | 🟡 | Preview URL detection exists! Fetches from GitHub Deployments API, renders iframe + "Open in new tab" link. | **Missing:** "Compare with production" link. API/schema diff for backend-only changes. Dependency change summary. Preview is fetched on-demand (not pre-computed). |
| **M3b. Verification Checklist** | 🔴 | Does not exist. | **Need:** AI-generated verification steps at enrichment time. Risk-tiered depth (LOW/MEDIUM/HIGH). Steps reference preview URL. Checkboxes for Marco to mark verified. |
| **M3c. Origin Context** | 🔴 | PR title and author shown, PR URL linked. But no issue resolution. | **Need:** Resolve linked GitHub issue from PR body (closes/fixes/resolves #N). Show issue title + description excerpt. Flag "No linked issue — untracked agent work." Factory/automation source detection. Display at TOP of review page. |
| **M4. AI Summary Quality** | 🟡 | Gemini 3.1 Flash Lite generates 2-4 sentence summary. Prompt asks "What does this change do and should it go live?" Parsed into risk level + action + what + details. | **Gap:** Prompt doesn't explicitly ask "what's unusual for this repo." No repo history context (summary sees the current diff in isolation). Temperature 0.2 is good. Max 180 tokens may be tight for complex PRs. Suggest expanding prompt with repo context and bumping to 250 tokens. |
| **M5. Risk Signal Detection** | ✅ | Pattern-based risk rules covering: Secrets (critical), Auth (high), Database (high), Infra (high), CI/CD (high), Deploy (high), API (medium), Dependencies (medium), Scripts (medium). | **Minor gap:** Missing BILLING and CONFIG categories from Marco spec. Missing API-BREAKING detection (current API rule catches routes but not breaking changes). Risk severity levels don't include LOW (current: critical/high/medium only). |
| **M6. Cryptographic Receipt** | ✅ | Full receipt system: create on approval, verify endpoint, public view at /r/[id], export. Includes signature, key ID, algorithm, timestamps. | **Minor gap:** Receipt doesn't include AI summary snapshot or risk signals at time of decision (just the approval metadata). Preview screenshots not included (v2 item). |
| **M7. Merge via GitHub Merge Queue** | 🟡 | Merge from PP exists — direct GitHub merge API call. Merge readiness checks (CI status, branch status, conflicts). Branch update. CI rerun. | **Key gap:** Currently does DIRECT MERGE, not GitHub merge queue integration. The Marco spec calls for adding to GitHub's native merge queue. This is a significant architectural change. Also missing: merge method selector (squash/merge/rebase), "Retry" for failed merges, real-time status polling post-merge. |
| **M17. Rejection with Reproduction Context** | 🟡 | Reject reason presets exist (Not ready, Needs tests, Wrong branch, Needs discussion). Free text reason. Posts to PR as comment. | **Missing:** Structured "which verification step failed" (needs M3b first). "What happened" structured options (500 error, wrong behavior, etc.). Screenshot upload/paste on rejection. Feedback loop notification ("PR updated — re-review?"). |
| **M19. Approval Revocation (Undo)** | 🔴 | Does not exist. There's a "reapprove" flow but no revocation. | **Need:** Revoke approval before merge completes. Remove from merge queue. Generate revocation receipt. Post-bulk-approve undo toast. |
| **M22. Incident Tracing & Revert** | 🔴 | Merge status tracking exists (merged, merge_failed, closed_without_merge). Merged timestamp stored. | **Missing:** "Recently merged" view. One-click revert (create revert PR). Revert receipt linking to original. Warning about dependent PRs. |

### Queue (Sprint 3-4)

| Req | Status | What Exists | Gap |
|---|---|---|---|
| **M8. Queue Dashboard** | 🟡 | Dashboard exists with: stats bar, list/stack view, repo filter pills, status filter tabs (Pending/Approved/Denied/Expired), sort by newest/oldest/risk, search. | **Missing:** Group by repo with collapsible sections (current: flat list with repo pills as filters). Stale requests section. Header stat for "oldest request age." |
| **M9. Bulk Approve** | 🟡 | Bulk approve exists — "Approve all pending low-risk non-production." | **Missing:** Confirmation modal showing what's being approved. Per-repo variant. Post-bulk undo toast (ties to M19). Currently approves but doesn't auto-queue for merge. |
| **M10. Queue Status View** | 🔴 | Dashboard shows approval status but not post-approval merge lifecycle. | **Need:** Per-PR lifecycle tracking: Approved → In merge queue → CI running → Merged → Deployed. Ejection reasons. Retry button. Session summary. |
| **M11. Agent Attribution** | 🟡 | `prAuthor` and `createdByRef` stored and shown. Author track record section exists. | **Missing:** Agent TYPE identification (Codex vs Claude Code vs Cursor vs Copilot). Currently shows GitHub username, not agent classification. Filter by agent in queue. |
| **M12. Request Age** | ✅ | Relative timestamps shown ("34m ago"). formatRelativeWithSuffix utility exists. | Complete. Sort by age within risk tier could be tightened. |
| **M18. Agent Trust Signals** | 🟡 | Author track record exists — fetches deploy history, shows previous deploy count, "New author" warning. | **Missing:** Per-AGENT (not per-author) stats. Rejection rate, revert rate. Elevated rate warning. Trailing 30-day window. |
| **M20. Review Iteration Tracking** | 🔴 | Does not exist. No concept of "review attempt" on a deploy request. | **Need:** Track review attempts (rejected → updated → re-review). Show previous rejection reasons. "Changes since last review" diff. Attempt counter > 2 flag. |
| **M21. Stale Request Handling** | 🔴 | Does not exist. Old requests stay in queue indefinitely. | **Need:** 48h threshold → mark as stale. Re-enrichment against current main. Stale warning. Separate queue section. |
| **M24. Summary Confidence** | 🔴 | Risk-level parsing exists (from summary text), but no disagreement detection between risk signals and summary. | **Need:** Cross-check risk signals vs summary tone. Large diff warning. Confidence indicator. |

### Polish (Sprint 5)

| Req | Status | What Exists | Gap |
|---|---|---|---|
| **M13. Auto-Approve Rules** | 🟡 | Policy evaluation engine exists (`permission-router/policy-evaluation.ts`). Auto-approve logic in settings. | **Need:** User-facing rule builder (file pattern + risk level + repo + agent). Rule management UI. Kill switch. Audit log per auto-approval. |
| **M14. Keyboard Navigation** | 🔴 | Does not exist. | Need: J/K queue nav, A/R approve/reject, Enter/Esc detail/back, Space expand, N/P next/prev. |
| **M15. Post-Merge Deploy Status** | 🟡 | mergeStatus field exists (pending_merge, merge_failed, merged). mergedAt timestamp. | **Missing:** Deploy status from Vercel/Render/GH Actions. Currently tracks merge, not deploy. |
| **M16. Empty State** | 🟡 | Dashboard has zero-state handling (idea-050: "hide Shipped Today 0 or show Last shipped"). | **Missing:** "All clear" celebratory state with session stats (approved count, rejected count, time). |
| **M23. Risk-Gated Friction** | 🔴 | Does not exist. | Need: Configurable toggle for HIGH risk requiring verification acknowledgment. |
| **M3a addendum: Preview Snapshots** | 🔴 | Does not exist. | Need: Screenshot capture at enrichment time for archival. |

---

## Summary Scorecard

| Status | Count | Requirements |
|---|---|---|
| ✅ Complete | 2 | M5 (risk signals — mostly), M12 (request age) |
| 🟡 Partial | 14 | M1, M2, M3, M3a, M4, M6, M7, M8, M9, M11, M13, M15, M16, M17, M18 |
| 🔴 Missing | 13 | M3b, M3c, M10, M14, M19, M20, M21, M22, M23, M24, preview snapshots, keyboard nav, review iteration |

**The app is ~40% of the way to Marco's full spec.** The foundation is solid — enrichment, risk detection, approval flow, receipts, merge, dashboard. The gaps are primarily in:

1. **Information hierarchy** — origin context, verification steps, summary confidence (the "WHY → WHAT → HOW TO VERIFY" stack)
2. **Post-approval lifecycle** — merge queue integration, queue status view, deploy tracking, incident tracing
3. **Feedback loops** — rejection reproduction context, review iteration tracking, agent trust signals
4. **Safety nets** — approval revocation, stale handling, undo

---

## Execution Plan

### Phase 1: Information Layer (Weeks 1-2)
*Goal: Marco sees the complete decision surface without reading code.*

**1.1 Origin Context (M3c)** — 2-3 days
- Backend: When enrichment runs, resolve linked issue from PR body (regex for `closes #N`, `fixes #N`, etc.)
  - Call GitHub Issues API: `GET /repos/{owner}/{repo}/issues/{number}`
  - Store: issue title, issue body (first 300 chars), issue URL, issue labels
  - If no linked issue: flag `untracked_origin: true`
- Frontend: Add "Origin" card at TOP of review page (above AI summary)
  - Issue title + excerpt + link
  - Or: "⚠️ No linked issue — untracked agent work"
- **Files:** `src/lib/enrichment/enrich.ts` (add `fetchLinkedIssue`), detail page component

**1.2 Verification Checklist (M3b)** — 3-4 days
- Backend: Add second LLM call in enrichment pipeline (can parallel with AI summary)
  - Input: diff + AI summary + risk signals + preview URL (if available)
  - Output: JSON array of 3-6 verification steps
  - Prompt: "Generate concrete verification steps for a non-technical reviewer. Reference the preview URL if available. Risk-tiered: LOW = 'CI green, approve', MEDIUM = flow walkthrough, HIGH = specific security checks."
  - Store in `ReviewEnrichment` as `verificationSteps: { step: string; riskTier: string }[]`
- Frontend: Verification checklist card (between preview and risk badges)
  - Checkboxes (optional, not blocking approval)
  - Risk-tier indicator per step
- **Files:** `src/lib/enrichment/enrich.ts` (add `generateVerificationSteps`), detail page component

**1.3 AI Summary Enhancement (M4)** — 1-2 days
- Expand Gemini prompt to include:
  - "Is anything unusual for this repository?" instruction
  - Previous enrichment patterns for the repo (if cached — lightweight, not a full RAG system)
- Bump max tokens from 180 → 250
- Add BILLING and CONFIG risk categories to `RISK_RULES`
- **Files:** `src/lib/enrichment/enrich.ts`

**1.4 Review Page Hierarchy Reorder** — 1 day
- Reorder detail page sections:
  1. Origin context (new)
  2. Verdict banner (exists — AI summary headline)
  3. AI summary card (exists)
  4. Deploy preview (exists — move up)
  5. Verification checklist (new)
  6. Risk + blast radius (exists)
  7. Author track record + peer reviews (exists)
  8. Timeline (exists)
  9. Diff (exists — keep in accordion, collapsed)
  10. Actions (exists — sticky bar)
- **Files:** Detail page component (reorder, no new logic)

**Phase 1 Deliverable:** Marco opens a review page and sees: WHY (origin) → WHAT (summary) → HOW IT LOOKS (preview) → HOW TO VERIFY (steps) → HOW DANGEROUS (risk) → CODE (collapsed) → ACTIONS.

---

### Phase 2: Safety & Feedback (Weeks 3-4)
*Goal: Marco can reject effectively, undo mistakes, and find problems post-merge.*

**2.1 Rejection Enhancement (M17)** — 2-3 days
- Add to rejection flow:
  - "Which verification step failed?" checkboxes (requires M3b)
  - "What happened?" structured options (500 error / Wrong behavior / Page didn't load / Looks wrong / Other)
  - Screenshot paste/upload (store in S3/R2, attach to PR comment)
- Enhance PR comment format: structured markdown with step reference + observed vs expected
- **Files:** Detail page reject flow, new upload component, PR comment formatter

**2.2 Approval Revocation (M19)** — 2-3 days
- Backend: New endpoint `POST /api/v1/deploy-requests/{id}/revoke`
  - Only allowed while status = approved AND mergeStatus != merged
  - Removes from GH merge queue (if applicable)
  - Sets status back to pending
  - Generates revocation receipt
- Frontend: "Revoke" button on approved-but-not-merged requests
- Post-bulk-approve: 10-second toast with "Undo all" (batch revoke)
- **Files:** New API route, receipt generation, detail page + dashboard UX

**2.3 Incident Tracing (M22)** — 3-4 days
- Backend: New endpoint `GET /api/v1/deploy-requests?mergedAfter={ISO}&mergedBefore={ISO}`
  - Returns recently merged requests with enrichment data
- Frontend: "Recently Merged" view/tab on dashboard
  - Per-PR: merge time, risk signals, files touched, receipt link
  - "Revert" button → calls GitHub API to create revert PR
  - Revert creates a new deploy request in PP (enters normal approval flow)
- **Files:** Dashboard tab, new API filter, revert integration

**2.4 Notification Inversion (M2)** — 2-3 days
- Current: Slack notification fires AFTER approval (post-approval-actions)
- Need: Notification fires WHEN NEW REQUEST ARRIVES
- Add notification trigger in deploy-gate webhook handler (or in the deploy request creation path)
- Add email channel (SendGrid/Postmark — Postmark already in 1Password)
- Add Discord webhook channel
- Settings page: per-channel toggle, trigger config (all / high-risk / digest)
- Notification payload includes: direct link to review page, PR title, risk level, repo
- **Files:** Webhook handler or request creation, new notification service, settings page update

**Phase 2 Deliverable:** Marco can reject with context, undo mistakes, trace incidents, and gets notified when PRs arrive (not just when they're approved).

---

### Phase 3: Merge Queue & Lifecycle (Weeks 5-6)
*Goal: Marco approves and walks away. PP handles the rest.*

**3.1 GitHub Merge Queue Integration (M7 upgrade)** — 4-5 days
- Replace direct merge with merge queue:
  - After approval + "Merge" click: add PR to GitHub merge queue via API
  - `PUT /repos/{owner}/{repo}/pulls/{pull_number}/merge` with `merge_method` → for direct merge
  - For merge queue: use `POST /repos/{owner}/{repo}/pulls/{pull_number}/merge-queue` (or the branch protection merge queue flow)
  - Actually: GitHub merge queue is triggered by adding the PR to the queue via the API or the "Merge when ready" button. Check current API support.
- Poll for merge queue status updates
- Merge method selector in settings (squash/merge/rebase per repo)
- **Decision needed:** GitHub's merge queue API is limited. May need to use the "enable auto-merge" mutation (`enablePullRequestAutoMerge` GraphQL) as the programmatic entry point. Research required.
- **Files:** Merge endpoint refactor, new polling worker, settings page

**3.2 Queue Status View (M10)** — 3-4 days
- Per-PR lifecycle states: Approved → Queued → CI Running → Merged → Deployed | Ejected
- Real-time updates (WebSocket or polling)
- Ejection reasons (CI failure, conflict)
- Retry button, remove from queue button
- Session summary: "8 merged · 1 conflict · 12 min"
- **Files:** Dashboard enhancement, WebSocket/polling infrastructure, new status model

**3.3 Summary Confidence (M24)** — 1-2 days
- Backend: At enrichment time, cross-check risk signals vs AI summary
  - If risk signals include AUTH/DB/BILLING but summary doesn't mention them → flag
  - If diff > 500 lines → flag
  - Store `confidenceLevel: 'high' | 'medium' | 'low'` and `confidenceWarnings: string[]`
- Frontend: Show warning below AI summary when confidence is low
- **Files:** Enrichment pipeline, detail page

**3.4 Stale Request Handling (M21)** — 2 days
- Backend: Cron job or on-access check: if request age > 48h → mark stale
  - Re-run enrichment against current main on stale requests (on-demand, not auto)
  - Store `isStale: boolean`, `staleAt: DateTime`
- Frontend: Stale badge on queue items. Separate "Stale" section in dashboard.
  - "Re-test" / "Close" / "Review anyway" actions
- **Files:** Staleness checker (cron or middleware), dashboard section, enrichment re-run

**Phase 3 Deliverable:** Approve → merge queue → status tracking. Stale requests handled. Summary confidence signals.

---

### Phase 4: Trust & Iteration (Weeks 7-8)
*Goal: Marco calibrates trust per agent. Rejection cycles tracked.*

**4.1 Agent Classification (M11 upgrade + M18)** — 3-4 days
- Backend: Classify PR author as agent type:
  - Parse from PR author username or commit metadata
  - Known patterns: `codex-bot`, `claude-code`, `cursor-*`, `copilot`
  - Fallback: `createdByType` field + custom labels in settings
  - Store `agentType: string` on deploy request
- Per-agent trailing stats (30-day window):
  - Total PRs, rejection count, revert count, rejection rate, revert rate
  - Compare to previous 30-day window for trend
- Frontend: Agent badge on queue items + detail page. Filter by agent in dashboard. Trust signal with trend warning.
- **Files:** Agent classifier, stats aggregation query, dashboard filter, detail page component

**4.2 Review Iteration Tracking (M20)** — 2-3 days
- Backend: Track review attempts per deploy request
  - On rejection: increment `reviewAttempt`, store rejection reason + timestamp
  - On re-review (new commits after rejection): link to previous attempt
  - Store `reviewHistory: { attempt: number, action: string, reason: string, timestamp: string }[]`
- Frontend: Attempt counter on detail page. Previous rejection reasons shown. "Changes since last review" diff toggle.
- **Files:** Deploy request model update, detail page

**4.3 Receipt Enhancement (M6 upgrade)** — 1-2 days
- Include AI summary snapshot + risk signals at decision time in receipt payload
- Revocation receipts (from M19) linked to original
- **Files:** Receipt generation, receipt display

**Phase 4 Deliverable:** Agent trust signals, iteration tracking, enriched receipts.

---

### Phase 5: Power User (Weeks 9-10)
*Goal: Day 30 Marco with auto-approve, keyboard nav, deploy tracking.*

**5.1 Auto-Approve Rule Builder (M13)** — 3-4 days
- Settings page: rule builder UI
  - Conditions: file pattern (glob), risk level (LOW only v1), repo scope, agent filter
  - Each rule has a name and can be enabled/disabled
- Backend: On deploy request creation, evaluate rules before sending notification
  - If rule matches: auto-approve, generate receipt, add to merge queue
  - Store `autoApprovedByRule: string` on request
- Kill switch: "Pause all auto-approve" toggle in settings
- Audit log: which rule fired for which request
- **Files:** Settings page, rule engine, request creation pipeline

**5.2 Keyboard Navigation (M14)** — 2 days
- Dashboard: J/K navigation, Enter to open, A to approve
- Detail page: A/R approve/reject, N/P next/prev, Space expand/collapse, Esc back
- Keyboard shortcut hint bar (dismissible)
- **Files:** Dashboard + detail page event handlers

**5.3 Post-Merge Deploy Status (M15)** — 2-3 days
- After merge, poll for deploy status:
  - Vercel: check deployment API or GitHub deployment statuses
  - GitHub Actions: check workflow runs triggered by push to main
- Show on queue status view: Merged → Deploying → Deployed ✅ or Failed ❌
- Link to deploy logs
- **Files:** Deploy status poller, queue status view update

**5.4 Empty State & Polish (M16, M23)** — 1-2 days
- Empty state: "✅ All clear — 12 requests processed" with session stats
- Risk-gated friction toggle in settings (optional, off by default)
- **Files:** Dashboard, settings page

**Phase 5 Deliverable:** Full Marco spec complete. Auto-approve, keyboard nav, deploy tracking, polish.

---

## Timeline Summary

| Phase | Weeks | Focus | Key Deliverables |
|---|---|---|---|
| **1: Information Layer** | 1-2 | Decision surface | Origin context, verification checklist, summary enhancement, page reorder |
| **2: Safety & Feedback** | 3-4 | Error handling | Rejection context, undo, incident tracing, arrival notifications |
| **3: Merge Queue & Lifecycle** | 5-6 | Post-approval | GH merge queue, lifecycle status, stale handling, confidence signals |
| **4: Trust & Iteration** | 7-8 | Agent intelligence | Agent classification, trust signals, iteration tracking, receipt enrichment |
| **5: Power User** | 9-10 | Polish | Auto-approve rules, keyboard nav, deploy status, empty state |

**Total: ~10 weeks to full Marco spec.**

---

## Effort Estimates

| Phase | Est. Days | New Files | Modified Files |
|---|---|---|---|
| Phase 1 | 8-10 | ~4 | ~3 |
| Phase 2 | 10-13 | ~6 | ~5 |
| Phase 3 | 10-13 | ~5 | ~4 |
| Phase 4 | 7-9 | ~3 | ~4 |
| Phase 5 | 8-11 | ~4 | ~5 |
| **Total** | **43-56 days** | **~22** | **~21** |

---

## Risk & Dependencies

| Risk | Mitigation |
|---|---|
| GitHub merge queue API limitations | Research GraphQL `enablePullRequestAutoMerge` mutation. May need to use "Merge when ready" equivalent programmatically. If API insufficient, defer to v2. |
| AI verification step quality | Test with 20 real PRs before shipping. Bad verification steps are worse than no verification steps. Include "Report bad steps" feedback button. |
| Notification spam | Default to high-risk-only notifications. Let Marco opt into all-PR notifications. Digest mode as fallback. |
| Enrichment pipeline latency | Currently on-demand. Moving to pre-compute at capture adds latency to webhook handler. Run enrichment async (queue job) so webhook returns fast. |
| Receipt schema migration | Adding AI summary + risk signals to receipt increases payload size. Ensure backward compatibility with existing receipts. |

---

## Quick Wins (Can Ship This Week)

These require minimal effort and close obvious gaps:

1. **Add BILLING + CONFIG risk categories** — 30 min (add to `RISK_RULES` in enrich.ts)
2. **Expand AI summary prompt** — 1 hour (add "unusual for this repo" instruction, bump tokens to 250)
3. **Reorder detail page sections** — 2-3 hours (move preview above diff, add spacing)
4. **"No linked issue" warning** — 2-3 hours (regex PR body for closes/fixes, show warning if absent)
5. **Arrival notification via Slack** — 3-4 hours (trigger Slack when deploy request is created, not just on approval)
