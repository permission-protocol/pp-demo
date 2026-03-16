# PRD: Rich Gate-Failure CI Output

**Idea:** idea-004  
**Priority:** P2  
**Complexity:** M (half-day)  
**Persona:** Marco  

---

## Summary

When deploy-gate blocks a PR in CI, the GitHub Actions output is the first thing Marco sees. Currently it shows a request ID and approval URL — functional but forgettable. Transform this into a rich product touchpoint: file summary grouped by risk tier, AI-generated change summary, and a direct approve link.

## Problem

The current gate-failure output looks like:
```
⚠️  No receipt found for this scope
📋 Deploy gate request created:
   Request ID: abc123
🔗 APPROVE HERE: https://app.permissionprotocol.com/pp/deploy-requests/abc123
❌ FAIL: PP_APPROVAL_REQUIRED - Waiting for human approval
```

This is informational but not useful. Marco sees "something blocked my deploy" but gets no context about *what* PP is protecting him from. He has to click through to the dashboard to understand the change.

**The gate-failure moment is PP's most powerful product touchpoint.** Every developer who uses an AI agent will see this output. It needs to sell the value proposition in 5 seconds.

## Solution

Enhance the verify endpoint's response for the `RECEIPT_NOT_FOUND` + request-created case to include enrichment data. Then update the GitHub Action to display it.

### What the developer sees in CI:

```
🔐 Permission Protocol — Approval Required
═══════════════════════════════════════════

📋 Deploy Request Created
   PR #42: feat: add config validator utility
   Environment: production
   Actor: codex-bot (AI Agent)

📊 Change Summary (AI-Generated)
   Adds JSON schema validation for deployment configs.
   New utility function with 3 test files.

📁 Changed Files (6 files)
   🔴 CRITICAL
      src/lib/auth/config.ts (+12 -3)
   🟡 STANDARD
      src/lib/validators/config.ts (+85 -0)
      src/app/api/v1/validate/route.ts (+42 -0)
   🟢 LOW RISK
      tests/config-validator.test.ts (+120 -0)
      docs/validation.md (+30 -0)
      package.json (+1 -0)

🔗 APPROVE: https://app.permissionprotocol.com/pp/deploy-requests/abc123

❌ Blocked — Waiting for human approval
   Push a new commit after approval to re-trigger.
```

### Key design decisions:
- **Enrichment data comes from the API response**, not computed in the action. The verify endpoint already triggers enrichment when creating a deploy request. We add summary fields to the response.
- **Risk tiers are server-computed** using the existing `RiskSignal` categorization from `enrich.ts`.
- **File list with risk badges** — group changed files by risk tier (critical/standard/low) with additions/deletions counts.
- **AI summary** — the 1-line summary from the enrichment. If enrichment hasn't completed yet, show "Analyzing changes..." (it's async).
- **Fallback gracefully** — if enrichment data isn't available, show the current minimal output. Never block on enrichment.

## User Journey

1. AI agent (Codex) pushes code → PR triggers CI workflow
2. Deploy-gate action runs → calls verify endpoint
3. No receipt found → endpoint creates deploy request + triggers enrichment
4. Endpoint returns request details + available enrichment data
5. Action formats rich output in CI log
6. Marco opens failed CI check → sees file summary, risk tiers, approve link
7. Marco clicks approve link → approves in dashboard
8. Marco re-runs CI → gate passes

## Files to Change

### API Side (permission-protocol/app):
1. **`src/app/api/v1/receipts/verify/route.ts`** — When returning a `RECEIPT_NOT_FOUND` response with a created request, include enrichment summary fields in the response:
   ```typescript
   // Add to the response when requestId is returned:
   enrichment?: {
     summary: string | null;       // AI-generated summary
     riskLevel: string;            // "critical" | "high" | "medium" | "low"
     files: Array<{
       filename: string;
       riskTier: "critical" | "standard" | "low";
       additions: number;
       deletions: number;
     }>;
   }
   ```
   Pull from the deploy request's `enrichmentJson` field. If enrichment hasn't completed, return `enrichment: null`.

2. **`src/lib/enrichment/enrich.ts`** — Export a new helper:
   ```typescript
   export function categorizeFileRisk(filename: string, signals: RiskSignal[]): "critical" | "standard" | "low"
   ```
   Uses existing `RiskSignal` categories. Files matching critical signals → critical, files in signal list → standard, everything else → low.

### Action Side (same repo):
3. **`.github/actions/verify/action.yml`** — In the `RECEIPT_NOT_FOUND` case, parse the new enrichment fields from the API response and format the rich output using `::group::` and echo statements. This is bash in the action's `run` block.

## Acceptance Criteria

- [ ] When deploy-gate blocks a PR, the CI output shows: PR title, environment, actor type
- [ ] AI-generated summary appears if enrichment is available
- [ ] Changed files are listed grouped by risk tier (🔴 critical / 🟡 standard / 🟢 low)
- [ ] Each file shows additions/deletions count
- [ ] Approve URL is prominently displayed
- [ ] If enrichment is not yet available, output falls back to current minimal format gracefully
- [ ] No change to existing success/error flows — only the `RECEIPT_NOT_FOUND` + request-created case
- [ ] Works with both PR_HEAD and GIT_REF_COMMIT scope types

## Edge Cases

1. **Enrichment not yet loaded** — Verify endpoint returns `enrichment: null`. Action shows minimal output (current behavior) with a note: "Change analysis pending..."
2. **No files in diff** — Empty file list (e.g., workflow-only change). Show "No file changes detected."
3. **Very large PRs (50+ files)** — Truncate to top 10 files by risk, show "+ N more files" count.
4. **Non-PR events** — The action also runs on push events. PR title and number may be missing. Show repo + commit SHA instead.
5. **Rate-limited enrichment API** — Don't block on enrichment. Return what's available.

## Out of Scope

- Post-approval PR comment (that's idea-001)
- Blast radius indicator on the web approval page (that's idea-002)
- Slack/email notifications (that's idea-008)
- Customizable output templates

## Codex Prompt

```
Enhance the deploy-gate CI output to show rich change context when a PR is blocked.

CONTEXT:
- The GitHub Action at .github/actions/verify/action.yml calls the verify endpoint. When no receipt is found and a deploy request is created, the action shows a minimal "APPROVE HERE" message.
- The verify endpoint at src/app/api/v1/receipts/verify/route.ts creates deploy requests and triggers enrichment (AI analysis).
- Enrichment data (summary + risk signals + file list) is stored in DeployGateRequest.enrichmentJson as a JSON string. The type is ReviewEnrichment from src/lib/enrichment/enrich.ts.

CHANGES:

1. In src/app/api/v1/receipts/verify/route.ts:
   - When returning a response that includes requestId + approvalUrl (the "request created" case), also read the deploy request's enrichmentJson field.
   - If enrichmentJson is not null, parse it as ReviewEnrichment.
   - Add to the response JSON:
     enrichment: {
       summary: enrichment.summary (string, or null if not available),
       riskLevel: computed from enrichment.riskSignals (highest severity: critical > high > medium > "low" if none),
       files: enrichment.diff.files.map(f => ({
         filename: f.filename,
         riskTier: categorizeFileRisk(f.filename, enrichment.riskSignals),
         additions: f.additions,
         deletions: f.deletions
       })).slice(0, 15)
     }
   - If enrichmentJson is null (enrichment hasn't run yet), set enrichment: null in response.

2. In src/lib/enrichment/enrich.ts:
   - Export a new function: categorizeFileRisk(filename: string, signals: RiskSignal[]): "critical" | "standard" | "low"
   - Logic: if any signal with severity "critical" or "high" has the filename in its files array → "critical". If any signal mentions the file → "standard". Otherwise → "low".

3. In .github/actions/verify/action.yml:
   - In the RECEIPT_NOT_FOUND case (after "Deploy gate request created"), parse new fields from HTTP_BODY using jq:
     ENRICHMENT_SUMMARY=$(echo "$HTTP_BODY" | jq -r '.enrichment.summary // empty')
     ENRICHMENT_RISK=$(echo "$HTTP_BODY" | jq -r '.enrichment.riskLevel // empty')
     ENRICHMENT_FILES=$(echo "$HTTP_BODY" | jq -r '.enrichment.files // empty')
     PR_TITLE from existing scope context or HTTP_BODY
   - If ENRICHMENT_SUMMARY is not empty, format rich output:
     echo "🔐 Permission Protocol — Approval Required"
     echo "═══════════════════════════════════════════"
     echo ""
     echo "📋 Deploy Request Created"
     echo "   PR #${PP_PR_NUMBER}: ${PR_TITLE}"
     echo "   Environment: ${PP_ENVIRONMENT}"
     echo ""
     echo "📊 Change Summary"
     echo "   ${ENRICHMENT_SUMMARY}"
     echo ""
     Then loop through files grouped by riskTier using jq:
     echo "📁 Changed Files"
     for each tier (critical, standard, low) with appropriate emoji
     Then show APPROVAL_URL prominently
   - If enrichment is null, keep current minimal output unchanged.

CONSTRAINTS:
- Do NOT modify the Prisma schema.
- Do NOT change the verify endpoint's success flow or other error flows.
- Only modify the response for the "request created" case (where requestId is returned).
- The action.yml changes are bash — use jq for JSON parsing (already available in the action).
- Import categorizeFileRisk from @/lib/enrichment/enrich in the verify route.
- Follow existing error handling patterns in verify/route.ts.
- Truncate file list to 15 files max in the API response.
```

---

*PRD written by Charles · Create Factory · 2026-03-13*
