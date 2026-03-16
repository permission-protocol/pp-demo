# PRD: idea-047 — Fix False "GitHub App Not Installed" Banner

**Issue:** permission-protocol/app#123
**Priority:** P1
**Repo:** permission-protocol/app

## Problem
Deploy request detail page shows "GitHub App not installed on this repo (permission-protocol/app)" with "Install →" link, even when the GitHub App IS installed (3 repos visible on Repositories tab with installation ID #115918626).

## Requirements

### Must Have
1. Fix the installation detection logic on the deploy request detail page
2. If the GitHub App is installed for the repo's organization/owner, hide the banner
3. If partially configured (installed but missing workflow/API key/branch protection), show a different, accurate message: "Setup incomplete — configure workflow and API key" with link to `/c/repos`

### Implementation Notes
- The banner likely checks a flag on the deploy request record or does a lookup
- The issue may be that the check looks at repo-level installation rather than org-level
- Or: the check was written before the GitHub App was connected and uses stale data
- Check the component that renders the "GitHub App not installed" banner — it's on the deploy request detail page
- The Repositories page already knows the correct installation status — reuse that logic

### Must NOT Do
- Don't remove the banner entirely — it's useful when the app genuinely isn't installed
- Don't change the Repositories page logic
