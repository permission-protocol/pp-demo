# PRD: PR Comment with Receipt Link + AI Summary

**Idea:** idea-001  
**Priority:** P1  
**Complexity:** M (half-day)  
**Persona:** Both (Marco + Sarah)  
**Status:** prd-wip → prd-ready  

---

## Summary

After a deploy-gate request is approved, post a GitHub PR comment showing the receipt link and the AI-generated summary. This is the primary product touchpoint — every developer on the team sees PP on every gated PR, without needing to visit the dashboard.

## Problem

When PP approves a deploy request today, it:
1. Sets a commit status ("Permission Protocol: success") ✅
2. Optionally triggers a GitHub re-run ✅
3. Optionally enables auto-merge ✅

But there's **no PR comment**. The approval is invisible to anyone who doesn't check the commit status details. Marco's teammates don't know PP exists. Sarah has no in-PR audit trail.

The commit status `target_url` links to the receipt page, but most developers never click commit status links. A PR comment is impossible to miss.

## Solution

Add a PR comment step to the post-approval flow. After approval + commit status + rerun, post a comment on the PR with:

```markdown
## ✅ Authorized by Permission Protocol

**Summary:** Added config validator utility with JSON schema validation for deployment configs.

| | |
|---|---|
| **Approver** | @rod-carvalho |
| **Environment** | production |
| **Risk** | 🟢 Low |
| **Receipt** | [View authority proof →](https://www.permissionprotocol.com/review/{requestId}) |

<sub>🔒 Cryptographically signed receipt · Verified by [Permission Protocol](https://permissionprotocol.com)</sub>
```

### Key design decisions:
- **Always comment**, even on auto-approved requests. Auto-approved = low-risk, but the comment still creates visibility.
- **AI summary from enrichment**, not a new LLM call. The `enrichmentJson.summary` field already exists on the deploy request.
- **Risk level from enrichment** risk signals (critical/high/medium → 🔴/🟡/🟢).
- **Receipt link** uses existing public receipt URL pattern: `https://www.permissionprotocol.com/review/{requestId}`
- **No comment on denial** — denied requests don't get a comment (separate feature, idea-011).

## User Journey

1. AI agent (Codex) opens PR → deploy-gate blocks with "Permission Protocol" pending status
2. Marco opens PP, reviews, clicks Approve
3. Post-approval flow fires: commit status ✅ → rerun ✅ → **PR comment posted** ✅
4. Every developer on the PR sees the comment in their notification feed
5. Sarah clicks "View authority proof →" and gets the cryptographic receipt page

## Files to Change

### Primary:
1. **`src/lib/services/deploy-gate-post-approval.ts`** — Add `postPrComment()` call after `setCommitStatusAfterApproval()` succeeds. This is the orchestration point.

2. **`src/lib/post-approval-actions.ts`** — Add new exported function:
   ```typescript
   export async function postApprovalPrComment(
     request: DeployGateRequest,
     enrichment: ReviewEnrichment | null,
     receiptId: string | null
   ): Promise<PostApprovalActionResult>
   ```
   Uses GitHub REST API: `POST /repos/{owner}/{repo}/issues/{prNumber}/comments`

### Secondary:
3. **`src/lib/enrichment/enrich.ts`** — May need to export a helper `summarizeRiskLevel(signals: RiskSignal[]): 'low' | 'medium' | 'high' | 'critical'` to map risk signals to a single badge.

### No changes needed:
- Prisma schema (no new fields)
- Frontend (this is a backend-only change)
- GitHub Action (already posts status, this adds a comment)

## Acceptance Criteria

- [ ] After approval, a comment appears on the GitHub PR within 30 seconds
- [ ] Comment includes: AI summary (from enrichment), approver name, environment, risk badge, receipt link
- [ ] Comment uses the GitHub App token (not PAT) when available, matching existing `setCommitStatusAfterApproval` pattern
- [ ] If enrichment is missing (no AI summary), comment still posts with a generic "This deploy request was approved" message
- [ ] If receiptId is null (signing key not configured), receipt link is omitted
- [ ] Comment failure does NOT block the approval flow — it's best-effort, logged but non-fatal
- [ ] Auto-approved requests also get comments
- [ ] No duplicate comments on re-approval (check for existing PP comment before posting)
- [ ] Comment renders correctly on GitHub (markdown, table, links)

## Edge Cases

1. **Enrichment not yet loaded** — Comment posts without AI summary. Generic message: "Deploy request approved."
2. **GitHub App not installed on repo** — Falls back to PAT, matching existing pattern in `post-approval-actions.ts`.
3. **PR already merged** — Comment still posts (GitHub allows comments on merged PRs). This is fine — it's audit evidence.
4. **Rate limiting** — GitHub API rate limit hit. Log error, don't retry. The commit status + rerun are more important.
5. **Re-approval** — Check if a PP comment already exists (search for "Authorized by Permission Protocol" in PR comments). If found, edit the existing comment instead of creating a duplicate.
6. **Very long AI summary** — Truncate to 200 chars with "..." to keep the comment clean.

## Out of Scope

- PR comment on denial (that's idea-011)
- PR comment when gate first blocks (that's idea-004)
- Customizable comment template (future)
- Slack/email notification (that's idea-008)

## Codex Prompt

```
Add a GitHub PR comment to the post-approval flow for deploy-gate requests.

CONTEXT:
- After a deploy request is approved, the system already sets a commit status and optionally triggers a GitHub rerun (see src/lib/services/deploy-gate-post-approval.ts).
- Enrichment data (AI summary + risk signals) is stored in the deploy request's `enrichmentJson` field as a JSON string conforming to the `ReviewEnrichment` type from src/lib/enrichment/enrich.ts.
- GitHub API authentication uses App installation tokens via `getAppTokenForRepo()` from src/lib/github-app/installation-token.ts, with PAT fallback.

CHANGES:
1. In src/lib/post-approval-actions.ts, add a new exported function `postApprovalPrComment` that:
   - Takes a DeployGateRequest, parsed ReviewEnrichment (or null), and receiptId (or null)
   - Posts a markdown comment to the PR via GitHub REST API: POST /repos/{owner}/{repo}/issues/{prNumber}/comments
   - Uses getAppTokenForRepo() for auth, falling back to process.env.GITHUB_TOKEN
   - Before posting, checks existing PR comments for one containing "Authorized by Permission Protocol" — if found, updates it (PATCH) instead of creating a new one
   - Comment format:
     ## ✅ Authorized by Permission Protocol
     **Summary:** {enrichment.summary, truncated to 200 chars}
     | | |
     |---|---|
     | **Environment** | {request.environment} |
     | **Risk** | {risk badge from signals} |
     | **Receipt** | [View authority proof →](https://www.permissionprotocol.com/review/{requestId}) |
     <sub>🔒 Cryptographically signed · Verified by Permission Protocol</sub>
   - If enrichment is null, use "Deploy request approved." as summary
   - If receiptId is null, omit the Receipt row
   - Returns PostApprovalActionResult

2. Add a helper function `summarizeRiskLevel(signals: RiskSignal[]): string` that returns "🔴 Critical" | "🟡 High" | "🟡 Medium" | "🟢 Low" based on the highest severity signal. No signals = "🟢 Low".

3. In src/lib/services/deploy-gate-post-approval.ts, in processDeployGatePostApprovalJob:
   - After the commit status is set successfully, call postApprovalPrComment()
   - Parse enrichmentJson from the request into ReviewEnrichment
   - Pass the request, parsed enrichment, and request.receiptId
   - Log the result but do NOT fail the overall job if the comment fails
   - Store the comment result in postApprovalActionResult alongside the existing status result

CONSTRAINTS:
- Do not modify the Prisma schema
- Do not modify any frontend files
- Follow the existing error handling pattern in post-approval-actions.ts (try/catch, return PostApprovalActionResult)
- Use the same GitHub API headers pattern as setCommitStatusAfterApproval
- Import ReviewEnrichment and RiskSignal types from @/lib/enrichment/enrich
```

---

*PRD written by Charles · Create Factory · 2026-03-13*
