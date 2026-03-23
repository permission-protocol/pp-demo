# Permission Protocol Demo

This file is used to trigger a deploy request for demonstration purposes.

## What is Permission Protocol?

Permission Protocol provides **cryptographically signed receipts** for AI agent deployments.
When an agent tries to deploy code, Permission Protocol:

1. **Captures** the exact commit, branch, and environment
2. **Requires** human approval before the deploy continues
3. **Signs** the approval with a tamper-proof receipt
4. **Unblocks** the CI pipeline to proceed

## Try It Now

This PR demonstrates the full flow:

1. A deploy request was created when this PR was opened
2. Click the approval link in the PR description or checks
3. Approve the deploy (no account needed for demo)
4. Watch the checks pass and merge become available

---

*This is a permanent demo PR. It resets automatically after approval.*
