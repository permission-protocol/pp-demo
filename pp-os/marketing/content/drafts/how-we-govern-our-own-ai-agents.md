# How We Govern Our Own AI Agents: A Field Report

On March 2, 2026, we realized we had a problem: we didn't actually know how many autonomous processes were running in our own environment, or what authority they had.

We are building Permission Protocol to govern AI agents for our customers, but we had a "cobbler's children" situation. Our internal operations—everything from planning tasks to posting on social media—rely on a fleet of cron jobs and background agents.

This is the story of how we mapped, audited, and enforced governance on our own system.

## The Inventory: What Was Actually Running?

We started by creating a source of truth called the **Autonomous Process Ledger**. We scanned our crons, LaunchAgents, and Docker containers to build a complete inventory.

We found 16 distinct autonomous processes. To make sense of them, we defined four levels of authority:

| Level | Description | Examples |
|-------|-------------|----------|
| **A** | Read-only access | Metrics collection, incident scanning |
| **B** | Internal write access | Creating PRs, updating internal boards |
| **C** | External/public action | Posting to social media, merging PRs, deploying infra |
| **D** | Prohibited autonomously | Payments, secret rotation, deleting user data |

Mapping our 16 processes against these levels was eye-opening.

## The Discovery: Authority C with No Gate

The audit revealed several processes with **Authority C** (external action capability) that had no hard governance gates.

For example, our LinkedIn poster was generating drafts and scheduling them to Buffer. While we had prompt-level instructions telling it to "wait for review," there was no programmatic enforcement. If the LLM hallucinated or the instructions were ignored, the agent could post directly to a public channel without a human ever seeing it.

In a governance context, prompt-level instructions are not enforcement. They are suggestions.

## The Enforcement: Tokens, Drift, and SLAs

We moved from suggestions to enforcement by implementing three specific controls:

### 1. The Token Gate (GOV-001)
We built a token-minting system for any process requiring Authority C. 

Now, when our board executor wants to create a PR or merge code, it can't just call the GitHub API. It must first present an **Approval Token**. This token is minted only after an out-of-band approval via Telegram from a verified sender ID. The token contains a content hash of the proposed change, ensuring the agent can't swap the approved content for something else.

### 2. Drift Detection
Inventory is only useful if it's accurate. We set up a daily "Integrity Check" (GOV-001) that compares our live cron state against the ledger. If it finds an unregistered process or a process running on a different schedule than documented, it alerts us immediately.

### 3. The 30-Day Review SLA
Every process with Authority B or C now has a "Last Reviewed" date in the ledger. If a process hasn't been manually reviewed in 30 days, the governance check **automatically disables it**. This prevents "zombie agents" from running indefinitely without oversight.

## The Surprise: Governance Must Govern Itself

One of the most interesting findings was that the governance system itself needed governance. Our drift detector has the authority to disable other crons—making it an Authority C process. We had to ensure the logic for *disabling* a process was just as robust as the logic for *enabling* one.

## The Architecture

Our internal flow now looks like this:

1. **Agent** creates a draft (e.g., a PR description or a social post).
2. **Agent** sends the content hash to a Telegram bot.
3. **Human (Rod)** receives the notification and reviews the draft.
4. **Human** sends an `/approve` command.
5. **Minting Script** verifies the Telegram sender ID and issues a signed **Approval Token**.
6. **Execution Boundary** (e.g., the git push script) verifies the token and content hash before proceeding.
7. **Verification** is logged in an append-only audit trail.

## Code Snippet: Token Verification

Here is the core logic we use to verify an approval token at the execution boundary. This ensures the agent cannot act without a valid, content-bound permission.

```bash
# company-os/governance/scripts/verify-approval.sh

#!/bin/bash
set -eo pipefail

TOKEN_FILE=$1
DRAFT_FILE=$2

# 1. Verify token exists and is recent
if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "❌ Error: No approval token found."
  exit 1
fi

# 2. Extract metadata from token
TOKEN_HASH=$(jq -r '.content_hash' "$TOKEN_FILE")
ISSUED_AT=$(jq -r '.issued_at' "$TOKEN_FILE")
APPROVER=$(jq -r '.approver' "$TOKEN_FILE")

# 3. Compute current draft hash
CURRENT_HASH=$(shasum -a 256 "$DRAFT_FILE" | awk '{print $1}')

# 4. Enforce exact match
if [[ "$TOKEN_HASH" != "$CURRENT_HASH" ]]; then
  echo "❌ Error: Content mismatch. Approved hash differs from current draft."
  exit 1
fi

# 5. Check expiry (e.g., 24 hours)
# [Expiry logic here...]

echo "✅ Verified: Approved by $APPROVER at $ISSUED_AT"
```

## Conclusion

The result of this sprint is that we now have a "Fail-Closed" environment. If our governance system is down, or if an agent tries to act outside its boundaries, the action simply fails. 

We didn't just build a diary of what happened; we built an enforcement layer that guarantees it.

---
*By Charles Goldberg · March 19, 2026*
