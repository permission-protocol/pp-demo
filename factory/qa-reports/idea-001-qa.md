# QA Report: idea-001 — PR comment with receipt link + 1-line AI summary on auto-approved PRs
**Date:** 2026-03-13 19:00 UTC
**PR:** https://github.com/permission-protocol/app/pull/99
**Retry:** #0

## Automated Checks
- [x] TypeScript: clean (0 errors)
- [x] Lint: clean
- [x] Tests: passed
## Diff Summary
Files changed: 4
```
 .../deploy-requests/[requestId]/approve/route.ts   |  17 ++
 src/lib/deploy-gate-approval.ts                    |  17 ++
 src/lib/post-approval-actions.ts                   | 192 +++++++++++++++++++--
 src/lib/services/deploy-gate-post-approval.ts      |  35 +++-
 4 files changed, 248 insertions(+), 13 deletions(-)
```
## Visual Capture
Peekaboo screenshots pending — Charles to capture

## PRD Acceptance Criteria
- [ ] After approval, a comment appears on the GitHub PR within 30 seconds
- [ ] Comment includes: AI summary (from enrichment), approver name, environment, risk badge, receipt link
- [ ] Comment uses the GitHub App token (not PAT) when available, matching existing `setCommitStatusAfterApproval` pattern
- [ ] If enrichment is missing (no AI summary), comment still posts with a generic "This deploy request was approved" message
- [ ] If receiptId is null (signing key not configured), receipt link is omitted
- [ ] Comment failure does NOT block the approval flow — it's best-effort, logged but non-fatal
- [ ] Auto-approved requests also get comments
- [ ] No duplicate comments on re-approval (check for existing PP comment before posting)
- [ ] Comment renders correctly on GitHub (markdown, table, links)
## Verdict
Automated checks: PASSED
Visual review: PENDING
PRD criteria: PENDING
