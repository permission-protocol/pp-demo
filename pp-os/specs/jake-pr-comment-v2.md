# Jake PR Comment V2 — Verdict-First Review Surface

## Problem
The PR comment is Jake's **only** review surface. He sees it in GitHub notifications, reads it in <10 seconds, and either clicks Approve or opens the full review page. Current format buries the verdict under "What this PR does" — Jake has to read 3 bullets + risk section before getting an answer to his only question: **"Is this safe to merge?"**

## Goals
1. **Minimize review time** — verdict visible in first line, full review in <5 seconds
2. **Maximize understanding** — Jake grasps what changed and what could go wrong without reading code
3. **Create demo "aha" moments** — the HIGH risk scenario makes viewers go "holy shit, I need this"

## Design Principles
- **Verdict first, context second.** Answer "safe to merge?" before explaining what changed.
- **One line per concept.** No paragraphs. No prose. Every line earns its space.
- **Risk specificity > risk labels.** "Could break checkout for returning customers" > "Medium risk"
- **No governance language.** No "Signer of Record", no "authorization", no "receipt generated" on the review surface. That's for the receipt page.

---

## Comment Format (LOW/MEDIUM risk)

```markdown
## 🔒 Permission Protocol

✅ **Safe to merge** — cosmetic changes only, no risk to production behavior.

**What changed:** Hero headline updated, social proof section added, pricing link rewired.

**Watch for:** Broken links if any nav paths reference the old `/pricing` route.

🟢 [**Authorize Deploy**](approve-url) · [Reject](reject-url)
```

## Comment Format (HIGH risk)

```markdown
## 🔒 Permission Protocol

🔴 **Review carefully** — this PR touches authentication and exposes a new public API route.

**What changed:** New `/api/users` endpoint returns user profiles. Auth middleware added but only checks session token, not role.

**Watch for:**
- Any logged-in user can access any other user's profile (no ownership check)
- Email addresses exposed in the response body without masking

🟡 [**Review Before Approving →**](review-url) · [Reject](reject-url)
```

## Comment Format (CRITICAL — e.g. secrets, DB migrations)

```markdown
## 🔒 Permission Protocol

🔴 **Do not merge** — this PR contains what appears to be a hardcoded API key.

**What changed:** Stripe integration added to checkout flow. Payment processing logic in `/api/checkout`.

**Blocked because:**
- `sk_live_` key found in `src/lib/stripe.ts` line 14 (should be in env var)
- Database migration drops the `users` table and recreates it (data loss)

❌ [**View Full Report →**](review-url) · [Reject](reject-url)
```

---

## Structured Review Prompt (Gemini)

The current `generateStructuredReview` prompt asks for bullets, riskBehaviors, etc. — but the output doesn't map cleanly to the verdict-first format. New prompt must produce output that maps 1:1 to the comment template.

### New JSON Schema

```typescript
type JakeReview = {
  verdict: 'safe' | 'review' | 'block';
  verdictReason: string;       // One sentence, plain English, why this verdict
  whatChanged: string;          // One line: what the user can now do/see that they couldn't before
  watchFor: string[];           // 0-2 specific observable risks. Empty array = nothing to watch
  recommendation: 'Approve' | 'Reject';
};
```

### Prompt

```
You are a code review assistant writing for a solo founder who merges 5-10 PRs per day from AI coding agents.

Your job: Tell them whether this PR is safe to merge, what it does, and what could go wrong — in plain English.

Rules:
- "verdict" is your top-line call:
  - "safe" = routine change, no risk to users or data
  - "review" = touches sensitive areas (auth, payments, data, infra), needs human eyes
  - "block" = active danger detected (exposed secrets, data loss, auth bypass)
- "verdictReason" = one sentence explaining why. Be specific. "Cosmetic changes only" or "New API route with no auth check" — not "Low risk changes detected."
- "whatChanged" = one line answering "what can users/operators do now that they couldn't before?" No file names, no function names.
- "watchFor" = 0-2 specific things that could go wrong in production. Not vague ("might cause issues") — specific ("returning customers might see a 500 on the checkout page if Stripe keys aren't in env"). Empty array if truly nothing to watch.
- "recommendation" = "Approve" or "Reject"

Respond with valid JSON only. No markdown, no explanation.

PR DETAILS:
Repository: {owner}/{repo}
PR: #{prNumber} {title}
Description: {body}
Risk signals: {riskSignalLines}
Changed files: {fileList}
Diff: {promptDiff}
```

---

## Implementation Changes

### 1. `src/lib/enrichment/enrich.ts`
- Add new type `JakeReview` alongside existing `StructuredReview`
- Add `generateJakeReview(diff: PrDiff): Promise<JakeReview>` — uses new prompt above
- `enrichDeployRequest()` should call `generateJakeReview` instead of `generateStructuredReview` (or in parallel, storing both)
- Keep backward compat: `structuredReview` field still populated for the in-app review page
- Add `jakeReview?: JakeReview` to `ReviewEnrichment` type

### 2. `src/lib/github-app/pr-review-comment.ts`
- Rewrite `buildReviewComment()` to use `JakeReview` format
- Verdict line first: `✅ **Safe to merge** — {verdictReason}`
- What changed line: `**What changed:** {whatChanged}`
- Watch for: only render if `watchFor.length > 0`
- Actions: single prominent Authorize button, secondary Reject link
- Remove: "Signer of Record" copy, "Decision" section, "Quick checks" section, "This action is recorded as authorization" footer
- Approval link goes to review page (for auth), not directly to approve endpoint

### 3. `src/lib/github-app/pr-review-comment.ts` — Action button styling
- `safe` verdict → 🟢 **Authorize Deploy** (prominent) + Reject (secondary)
- `review` verdict → 🟡 **Review Before Approving →** (links to full review page) + Reject
- `block` verdict → ❌ **View Full Report →** (links to review page) + Reject (prominent)

### 4. `src/app/pp/deploy-requests/[requestId]/page.tsx` — In-app review page
- `VerdictBanner` should use `jakeReview` verdict when available (replaces `parseAiSummary` heuristic)
- `MemoizedAiSummaryCard` gets the structured What/Risk/Action from `jakeReview` directly instead of regex-parsing the summary string
- No more `parseAiSummary` needed for the primary display path

### 5. Backward compatibility
- If `jakeReview` is null/undefined (old enrichments), fall back to current `parseAiSummary` behavior
- PR comment builder checks for `jakeReview` first, falls back to `structuredReview`

---

## Test Scenarios for Prompt Stress Testing

Before implementing, test the new Gemini prompt against these 7 scenarios to validate consistency:

| # | Scenario | Expected Verdict | Expected watchFor |
|---|---|---|---|
| 1 | Cosmetic: update hero text + add social proof | `safe` | Empty or broken links |
| 2 | New Stripe checkout integration (env vars correct) | `review` | Payment flow, webhook handling |
| 3 | New public API route `/api/users` with no auth | `block` | Auth bypass, data exposure |
| 4 | Hardcoded `sk_live_` key in source | `block` | Credential exposure |
| 5 | Prisma migration that adds a column (non-destructive) | `review` | Migration rollback |
| 6 | Prisma migration that drops + recreates table | `block` | Data loss |
| 7 | Large refactor: 15 files, rename utils → helpers | `safe` | Import paths |

Each scenario needs a synthetic diff to test against. Build these as fixtures.

---

## Success Criteria
- PR comment readable in <5 seconds
- Verdict is the first thing you read
- HIGH risk example makes viewer say "holy shit"
- Zero governance language visible before clicking Approve
- Demo video shows: boring PR (3 sec approve) → scary PR (catches auth bypass)

## Files Changed
- `src/lib/enrichment/enrich.ts` — new type + prompt + generator
- `src/lib/github-app/pr-review-comment.ts` — rewrite comment builder
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — use jakeReview in VerdictBanner + AiSummaryCard
- `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx` — add JakeReview type to exports
