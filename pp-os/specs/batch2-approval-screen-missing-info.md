# Spec: Approval Screen — Missing Information Marco & Sarah Need

## Context
Marco is an engineering manager. Sarah is a security lead. Both get a link to approve a deploy. What questions do they have that the current screen doesn't answer?

## Missing for Marco (Engineering Manager)

### 1. Who requested this deploy?
Not the commit author — the person/system that triggered the deploy gate. Was it a CI pipeline? A developer pushing to main? An AI agent? The screen shows "Charles Goldberg" as the commit author but doesn't distinguish between "a human pushed this" vs "an AI agent opened this PR."

**Add:** "Triggered by: GitHub Actions (automated)" or "Triggered by: @devname (manual push)"

### 2. What does this change DO in plain English?
The AI Summary helps, but Marco wants a one-liner he can read in 2 seconds. Not "This change introduces a centralized logging utility..." — more like "Adds `log()` function. No existing code changed."

**Add:** One-line "What changed" at the very top (covered in batch 2 spec #1)

### 3. Is anyone else reviewing this?
In a team, Marco wants to know: am I the only approver? Did someone else already look at it? Is there a PR review on GitHub?

**Add:** 
- "GitHub PR reviews: 1 approved, 0 changes requested" (pull from GitHub API)
- "Quorum: 0/1 approvals" (already exists in sidebar but buried — bring to main view)

### 4. What happens after I approve?
Marco clicks Approve and... then what? Does it auto-merge? Does it deploy to staging first? Does someone else also need to approve?

**Add:** A clear "After approval" line:
- "After approval → checks re-run → auto-merge to main" 
- Or "After approval → waiting for 1 more approver"
- Or "After approval → you'll need to click Merge"

### 5. Diff preview / visual preview
The "Changed Files" section shows file names and line counts, but no actual diff. Marco might want to glance at what changed without going to GitHub.

**Add:** Expandable inline diff view (already partially there with the file expanders, but make sure they work well)

## Missing for Sarah (Security Lead)

### 6. Has this been code-reviewed on GitHub?
Sarah wants to know the PR wasn't just pushed and immediately sent for deploy approval. Was there a proper code review?

**Add:** PR review status from GitHub:
- "✅ Code review: 2 approved" 
- "⚠️ No code review" (flag this prominently)
- "❌ Changes requested by @reviewer"

### 7. Does this touch sensitive files?
Risk Signals partially covers this, but Sarah wants explicit callouts for:
- Secrets / env files
- Auth / permissions code
- Infrastructure / deployment configs
- Database migrations

**Add:** Sensitive file badges (some of this exists in Risk Signals — make it more prominent and specific)

### 8. Blast radius — what services/users are affected?
"Blast radius" exists in the current AI summary but it's buried in a paragraph. Sarah needs it front and center.

**Add:** Dedicated "Blast radius" line: "Affects: logging pipeline for all repos" or "Affects: authentication for all users"

### 9. Can I see the receipt after approval?
Sarah cares about the audit trail. After approving, she wants a permalink to the receipt she can file or share.

**Add:** After approval, prominent receipt link: "📋 Audit receipt: permissionprotocol.com/r/xxx" (partially exists but should be more prominent)

### 10. Rollback plan
If this goes wrong, what's the recovery? For production deploys, Sarah wants to know there's a way back.

**Add:** "Rollback: revert PR or redeploy previous commit" — even a generic message helps

## Priority Ranking for Implementation

| # | Item | Who needs it | Effort | Impact |
|---|---|---|---|---|
| 4 | What happens after approve | Both | Low | High — reduces uncertainty |
| 6 | GitHub PR review status | Sarah | Medium | High — trust signal |
| 3 | Other reviewers / quorum | Marco | Low | Medium — already have data |
| 1 | Who triggered this | Both | Low | Medium — context |
| 8 | Blast radius (prominent) | Sarah | Low | Medium — already in AI summary |
| 10 | Rollback plan | Sarah | Low | Low-Medium — generic is fine |
| 5 | Inline diff preview | Marco | Medium | Medium — nice to have |
| 7 | Sensitive file badges | Sarah | Medium | Medium — partially exists |
| 9 | Receipt link post-approval | Sarah | Low | Low — partially exists |
| 2 | One-line what changed | Marco | Low | High — covered in spec #1 |

## Files Likely Changed
- Approval page component — add new info sections
- API/backend — fetch GitHub PR review status
- AI summary prompt — extract blast radius as structured field

## Priority
High — these are trust signals. Without them, Marco and Sarah are approving blind.
