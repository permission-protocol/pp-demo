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

**Critical architecture rule:** The LLM writes the consequence brief. **Deterministic signals decide the outcome.** The LLM never gates a merge.

### 1b. Deterministic Outcome Routing (hard rules, not LLM)
The policy outcome is decided by deterministic rules based on risk signals and file patterns:

**Cleared (deterministic):**
- Only docs, tests, static assets, copy changes
- No risk signals detected
- No files matching protected patterns

**Denied (deterministic):**
- Hardcoded secrets detected (`sk_live_`, `ghp_`, API keys in source)
- Destructive migrations (DROP TABLE, column removal)
- Known dangerous patterns (auth bypass, PII exposure without auth)
- `denied` = **hard stop.** No signer button, no authorization path on the PR. Developer must fix the code and push again. Admin override available on PP dashboard only (rare, legitimate cases).

**Approval Required (deterministic):**
- Any file matching auth/billing/permissions/deploy/infra patterns
- CI/CD workflow changes
- Dependency changes with risk signals
- Everything that isn't clearly `cleared` or `denied`

**Branch scoping (prevents over-escalation):**
- PRs targeting default/protected branches → full routing (cleared/approval_required/denied)
- PRs targeting feature branches → consequence brief posted as comment, commit status always `success`. Informational only, no gating.

The LLM then writes the consequence brief for whatever the deterministic engine decided. It explains, it doesn't decide.

### 2. Three Policy Outcomes (replaces verdict spectrum)
```ts
type PolicyOutcome = 'cleared' | 'approval_required' | 'denied';
```

| Outcome | PR Comment | Commit Status | Receipt Type |
|---|---|---|---|
| `cleared` | One-liner + clearance receipt link (first 3-5 PRs only, then quiet) | ✅ success | Clearance |
| `approval_required` | Full consequence brief + signer request | ⏳ pending | Authorization (after sign-off) |
| `denied` | Full consequence brief + block notice | ❌ failure | None until overridden |

### 3. Three Receipt Types (data model)
Add `receiptType` enum to receipts:
- `clearance` — PP analyzed and cleared under policy, no human involved
- `authorization` — human signer approved exact action
- `execution` — action actually ran (future, for deploy-time)

### 4. Comment Format (consequence-first)
Replace the Jake format with consequence-first language:

**Cleared** (shown for first 3-5 PRs after install, then quiet):
```
## 🔒 Permission Protocol

✅ **Cleared under default policy** — cosmetic changes only, no production impact.

**What changed:** Hero headline updated, pricing link rewired.

📋 [View clearance receipt](link)
```

**Approval Required:**
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

**Denied** (hard stop — no signer button, developer must fix and re-push):
```
## 🔒 Permission Protocol

🔴 **Blocked from merging to main**

**This change could:** expose production credentials in source code.

**Why PP blocked this PR:**
• `sk_live_` key found in `src/lib/stripe.ts` line 14
• database migration drops `users` table

**Fix required:** remove secrets from source, use environment variables. Rewrite migration to preserve data.

📋 [View details](link)
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
   - LLM output schema (brief only — NO outcome decision):
     ```ts
     type ConsequenceBrief = {
       potentialConsequence: string;     // max 12 words
       whyFlagged: string[];             // 1-3 items, specific to diff
       verifyBefore: string[];           // 0-2 items
       whatChanged: string;              // one sentence
     };
     ```
   - Temperature stays at 0.2 for consistency
   - Add Gemini response schema enforcement (already used for Jake)

2. **Build deterministic outcome router**
   - Takes risk signals + file patterns → returns `cleared | approval_required | denied`
   - Hard rules only — no LLM in the decision path
   - Docs/tests only → cleared. Secrets detected → denied. Auth/infra touched → approval_required.
   - Falls back to `approval_required` for anything ambiguous (safe default)

3. **Build gold standard test set (30 fixture PRs)**
   - 10 that should clear (docs, tests, static copy, renames)
   - 10 that should require approval (auth changes, billing logic, infra config, CI workflows)
   - 10 that should deny (hardcoded secrets, destructive migrations, PII exposure)
   - Grade against rubric: is consequence specific? Is outcome correct? Is evidence tied to diff?
   - Store in `pp-os/plans/consequence-engine-test-results.md`

4. **Add receiptType to data model**
   - Prisma migration: add `receiptType` enum field to receipt table
   - Default existing receipts to `authorization`
   - New auto-cleared PRs get `clearance` receipts

5. **Wire outcome to commit status**
   - `cleared` → status: success (currently only approval does this)
   - `approval_required` → status: pending (current behavior)
   - `denied` → status: failure (new — currently everything is pending)

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
   - Three templates: cleared, approval_required, denied
   - Footer: no "edit policies" — just "Why was this flagged?" link + receipt link
   - Clearance receipt link for cleared PRs (new)
   - Authorization request link for approval_required/denied PRs (existing)

2. **Build clearance receipt generation**
   - When outcome is `cleared`, auto-generate a receipt:
     - Type: `clearance`
     - Signer: `system/pp-engine` (not a human)
     - Contains: consequence brief, policy outcome, diff hash
   - Receipt page shows: "PP analyzed this change and cleared it under default policy"

3. **Cleared comment quieting logic**
   - Track PR comment count per installation (simple counter on installation record)
   - First 3-5 PRs after install: post cleared comment (teaches team what PP does)
   - After that: cleared = check + receipt only, no top-level comment
   - `approval_required` and `denied` always get full comments

4. **Policy outcome routing in webhook handler**
   - Deterministic router decides outcome from risk signals
   - LLM writes consequence brief in parallel
   - Combine: outcome + brief → comment + status + receipt
     - `cleared` → generate clearance receipt → maybe comment → set status success
     - `approval_required` → keep current flow (pending status, await human)
     - `denied` → set status failure → comment with block notice

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

### Day 3 (Fri Apr 10) — Website + Messaging

#### Charles
1. **Rewrite homepage** (`permissionprotocol-site/app/page.tsx`)
   - New hero: focused on consequence analysis + authority, not "approve deploys"
   - Headline candidates:
     - "Every PR gets a consequence brief. High-risk changes require a human signer."
     - "Know what AI-generated code could do before it ships."
   - Three scenario cards (replaces current features section):
     - Cleared: test file update → auto-cleared with receipt
     - Approval required: auth code change → human sign-off required
     - Denied: hardcoded secret → blocked from merge
   - Each card shows the actual PR comment format
   - **No wedge discovery in signup flow** — one live wedge, zero friction to install
   - Wedge interest capture goes on thank-you page or secondary CTA, not before install

2. **Draft new outreach templates**
   - Lead with consequence analysis, not "approve from PP"
   - Include screenshot of a real PR comment
   - Short: 3 sentences max for cold outreach

3. **Update OG image + meta tags**

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
   - PR comment rendering correctly on fresh installs
   - Clearance receipt pages loading correctly
   - Cleared comment quieting working after threshold

#### Rod
- **Post Loom + narrative on LinkedIn** (15 min)
- **Personal outreach to 3-5 people** (20 min)
  - "Install this on one repo, tell me what you think of the PR comments"
  - Target people already using AI coding tools
- **Sprint decision:** based on feedback, commit direction for next 2 weeks

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
| D5 | Sprint decision | 10 min |
| **Total** | | **~3.5 hours** |

---

## Success Criteria (End of Day 5)

1. Fresh install → first PR gets consequence brief in <10 seconds
2. Three distinct outcomes work: cleared / approval_required / denied
3. Deterministic signals decide outcomes, LLM writes briefs
4. Clearance receipts exist as separate artifact from authorization receipts
5. Comment language is consequence + authority, never "review"
6. Cleared comments quiet down after first 3-5 PRs per install
7. At least 5 external people have seen the new flow
8. Clear signal on whether this angle resonates

---

## What We Don't Do This Week

- No policy editor UI (outcome routing uses smart defaults)
- No wedge discovery in signup (capture interest post-install or via outreach)
- No deploy-gate standalone action changes (GitHub App is the wedge)
- No GitLab/Bitbucket support
- No pricing changes
- No "edit policies" in first-run experience
- No AI-author detection dependency
- No LLM in the outcome decision path

---

## Language Guide

| ❌ Don't Say | ✅ Do Say |
|---|---|
| Risk assessment | Consequence brief |
| Intelligent reviewer | Consequence analysis engine |
| Auto-approved with receipt | Cleared under default policy |
| Escalated / blocked | Approval required / denied |
| Classification receipt | Clearance receipt |
| Review carefully | Human sign-off required |
| Better PR comments | Authority routing |
| AI-authored PR detection | Consequential change analysis |
| Edit policies | Require sign-off next time |
| LLM decides the gate | Deterministic rules decide the gate |

---

*Created: 2026-04-07 10:20 PM MDT*
*Updated: 2026-04-08 6:25 AM MDT — incorporated 6 corrections + denied semantics fix + branch scoping*
*Source: #wedges thread — Rod + Charles strategy session*
