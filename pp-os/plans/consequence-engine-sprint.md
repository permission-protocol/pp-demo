# Consequence Engine Sprint — Apr 8–12, 2026

## The Bet
PP is the system that turns a PR into a **consequence brief**, a **policy decision**, and — when needed — a **human authorization event**. Not a reviewer. Not a comment bot. An authority system.

## What We Already Have (Audit)
After reviewing the codebase, we're further along than expected:

| Component | Status | Notes |
|---|---|---|
| GitHub App webhook handler | ✅ Done | Fires on PR open/sync/reopen, creates deploy request |
| Enrichment engine (`enrich.ts`) | ✅ Done | 1063 lines. Fetches diff, calls Gemini, returns structured review |
| PR comment system | ✅ Done | Posts placeholder → updates with enrichment. Jake format exists |
| Risk signal detection | ✅ Done | 11 categories (Auth, Secrets, CI/CD, DB, etc.) with severity |
| JakeReview format | ✅ Done | verdict/verdictReason/whatChanged/watchFor — close to what we need |
| ApprovalPolicyRule model | ✅ Exists | Prisma model with actionClass, resourcePattern, blastRadiusMax |
| Commit status gating | ✅ Done | Sets pending status, blocks merge until approved |
| Receipt infrastructure | ✅ Done | Receipt generation on approval |
| Deploy-gate action (standalone) | ✅ Done | Composite action, but requires pp-api-key (not zero-config) |

**Key insight:** 80% of the infrastructure exists. The work is reframing, not rebuilding.

---

## Architecture Changes

### 1. Consequence Brief (replaces "risk assessment")
**Current:** `JakeReview` returns verdict/whatChanged/watchFor
**New:** Add `consequenceBrief` to enrichment output:
```ts
type ConsequenceBrief = {
  potentialConsequence: string;     // "sign-in disruption for active users"
  whyFlagged: string[];             // ["session expiry changed from 24h to 1h", "no migration path"]
  verifyBefore: string[];           // ["is 1h expiry intentional?", "rate limiting on refresh?"]
};
```

This is NOT a code review. It answers: **"what could this change do to production?"**

### 2. Three Policy Outcomes (replaces verdict spectrum)
```ts
type PolicyOutcome = 'cleared' | 'escalated' | 'blocked';
```

| Outcome | PR Comment | Commit Status | Receipt Type |
|---|---|---|---|
| `cleared` | One-liner + classification receipt link | ✅ success | Classification |
| `escalated` | Full consequence brief + signer request | ⏳ pending | Authorization (after sign-off) |
| `blocked` | Full consequence brief + block notice | ❌ failure | None until unblocked |

### 3. Three Receipt Types (data model)
Add `receiptType` enum to receipts:
- `classification` — PP analyzed, applied policy, no human involved
- `authorization` — human signer approved exact action
- `execution` — action actually ran (future, for deploy-time)

### 4. Comment Format (consequence-first)
Replace the Jake format with consequence-first language:

**Cleared (low risk):**
```
## 🔒 Permission Protocol

✅ **Cleared under default policy** — cosmetic changes only, no production impact.

**What changed:** Hero headline updated, pricing link rewired.

📋 [View classification receipt](link)
```

**Escalated (medium/high risk):**
```
## 🔒 Permission Protocol

⚠️ **Human sign-off required** — this PR could cause sign-in disruption.

**Why PP flagged this PR:**
• session expiry changed from 24h to 1h in `src/auth/session.ts`
• new refresh endpoint added without rate limiting
• no migration path for existing sessions

**Verify before authorizing:**
• is the 1h expiry intentional?
• where is rate limiting handled?

**Signer required:** @rod

🔒 [Authorize this change →](link)

---
<sub>🔒 Permission Protocol · [Why was this flagged?](link)</sub>
```

**Blocked (critical):**
```
## 🔒 Permission Protocol

🔴 **Blocked from merging to main**

**This change could:** expose production credentials in source code.

**Why PP blocked this PR:**
• `sk_live_` key found in `src/lib/stripe.ts` line 14
• database migration drops `users` table

**Human sign-off required before unblock:** @rod

🔒 [View authorization request →](link)
```

### 5. Zero-Config Context Inference
PP already infers risk from file paths. Extend to infer repo context on first PR:
- Detect frameworks (Next.js, Rails, Django) from package.json/Gemfile/requirements.txt
- Identify protected branch patterns
- Map common auth/billing/infra directories
- Store as `repoProfile` on first enrichment, refine on subsequent PRs

No configuration screen. PP just gets smarter about your repo.

---

## Execution Plan

### Day 1 (Wed Apr 8) — Consequence Analysis Engine

#### Charles
1. **Rewrite enrichment prompt** (`enrich.ts`, Jake review section)
   - Current prompt: "is this safe to merge, what changed, what could go wrong"
   - New prompt: "what could this change do to production, why should PP flag it, what must a signer verify"
   - Output schema changes:
     ```ts
     // Replace JakeReview with:
     type ConsequenceReview = {
       outcome: 'cleared' | 'escalated' | 'blocked';
       potentialConsequence: string;     // max 12 words
       whyFlagged: string[];             // 1-3 items, specific to diff
       verifyBefore: string[];           // 0-2 items, only for escalated/blocked
       whatChanged: string;              // one sentence
     };
     ```
   - Temperature stays at 0.2 for consistency
   - Add Gemini response schema enforcement (already used for Jake)

2. **Test against 20 real PRs**
   - Pull 20 PRs from: vercel/next.js, supabase/supabase, maybe our own repos
   - Grade each output: is `potentialConsequence` specific? Is the outcome correct?
   - Iterate on prompt until outputs are sharp, not generic
   - Store test results in `pp-os/plans/consequence-engine-test-results.md`

3. **Add receiptType to data model**
   - Prisma migration: add `receiptType` enum field to receipt table
   - Default existing receipts to `authorization`
   - New auto-cleared PRs get `classification` receipts

4. **Wire outcome to commit status**
   - `cleared` → status: success (currently only approval does this)
   - `escalated` → status: pending (current behavior)
   - `blocked` → status: failure (new — currently everything is pending)

#### Rod
- **Grade 10 consequence analysis outputs** (30 min)
  - Charles will post them to #wedges or DM
  - For each: "Would this make me trust PP on my repo?" Y/N + why
  - Be harsh on generic outputs ("this PR modifies code" = fail)
- **Pause outreach** until Day 3 messaging is locked

---

### Day 2 (Thu Apr 9) — PR Comment + Policy Routing

#### Charles
1. **Rewrite `pr-review-comment.ts`**
   - Replace Jake/structured formats with consequence-first format (see above)
   - Three templates: cleared, escalated, blocked
   - Footer: no "edit policies" — just "Why was this flagged?" link + receipt link
   - Classification receipt link for cleared PRs (new)
   - Authorization request link for escalated/blocked PRs (existing)

2. **Build classification receipt generation**
   - When outcome is `cleared`, auto-generate a receipt:
     - Type: `classification`
     - Signer: `system/pp-engine` (not a human)
     - Contains: consequence brief, policy outcome, diff hash
   - Receipt page shows: "PP analyzed this change and cleared it under default policy"

3. **Policy outcome routing in webhook handler**
   - After enrichment returns `ConsequenceReview`:
     - `cleared` → generate classification receipt → update comment → set status success
     - `escalated` → keep current flow (pending status, await human)
     - `blocked` → set status failure → comment with block notice
   - The deploy-gate GH Action (for non-App users) gets the same routing via `/api/v1/receipts/verify` response

4. **End-to-end test**
   - Test repo PRs covering all three outcomes
   - Verify: comment format, commit status, receipt generation, approval page

#### Rod
- **Set up 3 test scenarios** (20 min)
  - One PR that should clear (docs/tests only)
  - One that should escalate (auth code change)
  - One that should block (hardcoded secret or destructive migration)
  - Can use existing test repos or create quick ones

---

### Day 3 (Fri Apr 10) — Website + Messaging + Wedge Discovery

#### Charles
1. **Rewrite homepage** (`permissionprotocol-site/app/page.tsx`)
   - New hero: focused on consequence analysis + authority, not "approve deploys"
   - Headline candidates:
     - "Every PR gets a consequence brief. High-risk changes require a human signer."
     - "Know what AI-generated code could do before it ships."
   - Three scenario cards (replaces current features section):
     - Cleared: test file update → auto-cleared with receipt
     - Escalated: auth code change → human sign-off required
     - Blocked: hardcoded secret → blocked from merge
   - Each card shows the actual PR comment format

2. **Build wedge discovery into signup**
   - After "Get Started" click, show: "What matters most to your team?"
   - Options:
     - 🔒 **Deploy Authorization** — consequence analysis + human sign-off for risky PRs *(live)*
     - 🛡️ **Agent Guardrails** — rules for what AI agents can change in your codebase *(coming soon)*
     - 📋 **Audit Trail** — tamper-evident record of every AI-generated change *(coming soon)*
     - 🔑 **Secrets & Infra Gate** — block AI from touching production secrets without approval *(coming soon)*
     - 🧰 **Tool Access Control** — control which external APIs your AI agents can call *(coming soon)*
   - Live wedge → install flow. Coming soon → email capture + "Talk to us about design partnership"
   - Track which wedge gets clicked (PostHog event)

3. **Draft new outreach templates**
   - Lead with consequence analysis, not "approve from PP"
   - Include screenshot of a real PR comment
   - Short: 3 sentences max for cold outreach

4. **Update OG image + meta tags**

#### Rod
- **Record 60-sec Loom demo** (20 min)
  - Show: install on test repo → AI opens PR → consequence brief appears → show receipt
  - No narration fluff. "Watch what happens when an AI agent opens a PR on a repo with PP installed."
- **Review homepage copy before deploy** (15 min)
- **Review outreach templates** (10 min)

---

### Day 4 (Sat Apr 11) — Dogfood + Harden

#### Charles
1. **Run on all PP repos for full day**
   - Monitor every PR comment that fires
   - Tune consequence analysis prompt for false positives
   - Ensure cleared PRs don't get noisy comments (one-liner max)

2. **Performance optimization**
   - Target: consequence brief appears in PR comment within 10 seconds of PR open
   - Current: placeholder → enrichment → update (already async)
   - Optimize: parallelize diff fetch + risk signal detection

3. **Edge cases**
   - Massive PRs (100+ files) → truncate intelligently, flag as "large change, manual review recommended"
   - Binary files → skip from analysis, note in brief
   - Empty diffs → handle gracefully
   - Repos with no code (docs-only) → always clear

4. **Configurable comment verbosity** (stretch)
   - Cleared: one-liner (default) or silent (receipt only, no comment)
   - Escalated: full consequence brief (always)
   - Blocked: full consequence brief (always)

#### Rod
- **Open 5-10 varied PRs throughout the day** (45 min total)
  - Mix: trivial, medium, dangerous
  - Grade every consequence brief: specific or generic? Outcome correct?
  - Flag any false positives/negatives immediately
- **Write "what we built" narrative** (20 min)
  - 3 paragraphs for LinkedIn/community
  - Lead with the problem, show the solution, end with CTA

---

### Day 5 (Sun Apr 12) — Launch Push

#### Charles
1. **Final production deploy**
   - All changes merged, deployed, verified
   - Fresh install test: new GitHub account → install → first PR → consequence brief appears

2. **Community posts**
   - dev.to article: "We stopped building a PR review tool and built an authority system instead"
   - Reddit: r/programming, r/devops (short, link to demo)
   - Relevant Discord servers

3. **Send updated outreach**
   - 6 LinkedIn targets + BlackLocus contacts with new messaging + demo video
   - Include screenshot of consequence brief on a real PR

4. **Tracking verification**
   - Wedge selection events flowing to PostHog
   - PR comment rendering correctly on fresh installs
   - Receipt pages loading for classification receipts

#### Rod
- **Post Loom + narrative on LinkedIn** (15 min)
- **Personal outreach to 3-5 people** (20 min)
  - "Install this on one repo, tell me what you think of the PR comments"
  - Target people already using AI coding tools
- **Review wedge selection data** (10 min)
- **Sprint decision:** based on feedback + wedge data, commit direction for next 2 weeks

---

## Rod's Task Summary

| Day | Task | Time |
|---|---|---|
| D1 | Grade 10 consequence analysis outputs, pause outreach | 30 min |
| D2 | Create 3 test scenario PRs | 20 min |
| D3 | Record 60-sec Loom demo | 20 min |
| D3 | Review/approve homepage copy | 15 min |
| D3 | Review outreach templates | 10 min |
| D4 | Open 5-10 test PRs, grade consequence briefs | 45 min |
| D4 | Write "what we built" narrative | 20 min |
| D5 | Post Loom + narrative on LinkedIn | 15 min |
| D5 | Personal outreach to 3-5 people | 20 min |
| D5 | Review wedge data + sprint decision | 10 min |
| **Total** | | **~3.5 hours** |

---

## Success Criteria (End of Day 5)

1. Fresh install → first PR gets consequence brief in <10 seconds
2. Three distinct outcomes work: cleared/escalated/blocked
3. Classification receipts exist as separate artifact from authorization receipts
4. Comment language is consequence + authority, never "review"
5. At least 5 external people have seen the new flow
6. Wedge selection data exists (any amount)
7. Clear signal on whether this angle resonates

---

## What We Don't Do This Week

- No policy editor UI (outcome routing uses smart defaults)
- No new wedge implementations (just measure demand)
- No GitLab/Bitbucket support
- No pricing changes
- No "edit policies" in first-run experience
- No AI-author detection dependency

---

## Language Guide

| ❌ Don't Say | ✅ Do Say |
|---|---|
| Risk assessment | Consequence brief |
| Intelligent reviewer | Consequence analysis engine |
| Auto-approved with receipt | Cleared under default policy |
| Review carefully | Human sign-off required |
| Better PR comments | Authority routing |
| AI-authored PR detection | Consequential change analysis |
| Edit policies | Require sign-off next time |

---

*Created: 2026-04-07 10:20 PM MDT*
*Source: #wedges thread — Rod + Charles strategy session*
