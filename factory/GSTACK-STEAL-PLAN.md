# gstack → Factory Pipeline: Comprehensive Steal Plan

**Source:** https://github.com/garrytan/gstack (analyzed 2026-03-16)
**Goal:** Extract the highest-value patterns and adapt them for our autonomous factory pipeline.
**Principle:** We don't use gstack directly (it's Claude Code only). We steal ideas and build them into our agent-agnostic, cron-driven pipeline.

---

## What We Already Have vs What gstack Has

| Capability | Our Factory | gstack | Gap |
|---|---|---|---|
| Product challenge | ✅ `review-idea.sh` (CEO review) | `/plan-ceo-review` (3 scope modes) | We lack scope modes + eng review |
| Architecture review | ❌ None | `/plan-eng-review` (10 sections) | **Big gap** |
| Code review (paranoid) | ❌ None post-build | `/review` (2-pass checklist) | **Big gap** |
| Build/ship | ✅ `build.sh` + `ship.sh` | `/ship` (bisectable commits) | Ship needs VERSION/CHANGELOG |
| QA (automated checks) | ✅ `qa.sh` (tsc/lint/tests + health score) | `/qa` (browser-based, 11 phases) | We lack browser QA in pipeline |
| QA (browser) | 🟡 Peekaboo/iPhone (manual) | `/browse` (persistent headless Chromium) | Not wired into auto pipeline |
| Retro | ❌ None | `/retro` (team-aware, metrics) | Nice-to-have, not critical |
| Doc update | ❌ None | `/document-release` | Nice-to-have |

---

## PRIORITY 1: Paranoid Code Review (`review.sh`) — HIGH VALUE

### What gstack does
Post-diff, pre-merge review with a **structured checklist** organized into CRITICAL (blocks ship) and INFORMATIONAL categories:

**CRITICAL (blocks ship):**
- SQL & Data Safety (string interpolation, TOCTOU races, N+1)
- Race Conditions & Concurrency (read-check-write without uniqueness, find_or_create without index)
- LLM Output Trust Boundary (unvalidated AI-generated values hitting DB)
- Enum & Value Completeness (new enum value not handled in all consumers)

**INFORMATIONAL:**
- Conditional Side Effects (branch missing side effect)
- Magic Numbers & String Coupling
- Dead Code & Consistency
- LLM Prompt Issues (0-indexed lists, tool mismatch)
- Test Gaps (negative paths without side-effect assertions)
- Crypto & Entropy (truncation instead of hashing, non-constant-time comparison)
- Time Window Safety
- Type Coercion at Boundaries
- View/Frontend (inline styles, O(n*m) in views)

### What we steal
The **checklist structure** adapted for our stack (Next.js/TypeScript instead of Rails/Ruby). Run as a Gemini pass on the diff between `main` and the factory branch, AFTER build and BEFORE QA.

### Implementation: `factory/scripts/review.sh`

```bash
#!/usr/bin/env bash
# Factory Script 4.5: Paranoid Review
# Post-build, pre-QA code review. Catches bugs that pass CI.
# Runs Gemini against the git diff with a structured checklist.
#
# Usage:
#   bash factory/scripts/review.sh [idea-id]
#   bash factory/scripts/review.sh --auto
#
# Flow:
#   1. Get git diff (main vs factory branch)
#   2. Send to Gemini with paranoid checklist prompt
#   3. Parse response for CRITICAL vs INFORMATIONAL findings
#   4. CRITICAL findings → block QA, re-queue to build with notes
#   5. INFORMATIONAL → append to QA report, continue

# Pipeline position: build.sh → ship.sh → review.sh → qa.sh
```

**Checklist to adapt (TypeScript/Next.js version):**

CRITICAL:
- **SQL/Prisma Safety**: Raw SQL with string interpolation, `prisma.$executeRaw` without parameterization, missing `where` clauses on updates/deletes
- **Race Conditions**: Check-then-write without transactions, `upsert` without unique constraint, status transitions without optimistic locking
- **Auth/Trust Boundary**: Unvalidated user input in API routes, missing auth checks on new endpoints, LLM output written to DB without validation
- **Type Safety**: `as any` casts on external data, missing Zod/schema validation on API boundaries, `!` non-null assertions on user-controlled data
- **Enum Completeness**: New status/type added but not handled in all switch/if chains

INFORMATIONAL:
- **Dead Code**: Unused imports, unreachable branches, commented-out code
- **DRY Violations**: Same logic in 2+ places (grep for duplicate patterns)
- **Error Handling**: Bare `catch(e)` that swallows errors, missing error boundaries in React components
- **Performance**: N+1 in API routes (missing Prisma `include`), unindexed queries, large payloads without pagination
- **Test Gaps**: New endpoints without test coverage, negative paths untested

**Scoring integration:**
- Each CRITICAL finding: -15 points from health score
- Each INFORMATIONAL finding: -3 points from health score
- Findings appended to QA report's new "Code Review" section

**Pipeline change:**
```
build.sh → ship.sh → review.sh (NEW) → qa.sh
```

If CRITICAL findings exist in `--auto` mode: re-queue idea to `prd-ready` with review notes appended to PRD (same retry pattern as QA failures).

---

## PRIORITY 2: Engineering Review Gate (`eng-review.sh`) — HIGH VALUE

### What gstack does
Pre-implementation architecture review with 4 core sections + mandatory outputs:
1. Architecture (dependency graph, data flow, scaling, security, rollback)
2. Code Quality (DRY, error handling, over/under-engineering)
3. Test Review (diagram of ALL new things → test coverage map)
4. Performance (N+1, memory, caching, slow paths)

Plus: failure modes registry, "NOT in scope" section, TODOS cross-reference.

### What we steal
Run between CEO review and spec. The CEO review asks "is this the right thing?" The eng review asks "will this implementation plan actually work?"

### Implementation: `factory/scripts/eng-review.sh`

```bash
# Factory Script 2.75: Engineering Review
# Challenges the TECHNICAL approach before spec/build.
# Run AFTER CEO review APPROVED, BEFORE spec.sh
#
# Gemini analyzes the idea + relevant source code and produces:
#   1. Architecture concerns (coupling, scaling, failure modes)
#   2. Existing code leverage (don't rebuild what exists)
#   3. Test plan (what MUST be tested)
#   4. Failure modes (what can go wrong in prod)
#
# Output: factory/reviews/{idea-id}-eng-review.md
# This file is injected into the spec prompt for PRD context.

# Pipeline position: review-idea.sh → eng-review.sh → spec.sh
```

**Prompt structure for Gemini:**

```
You are a staff engineer reviewing a feature proposal before implementation.

## The Idea
{title, description, target repo}

## Current Codebase Context
{relevant source code from repo cache — same extraction as spec.sh}

## Your Review (answer ALL sections)

### 1. Existing Code Leverage
- What existing code already solves parts of this?
- Are we rebuilding anything that exists?
- Can we wrap existing APIs instead of building new ones?

### 2. Architecture Concerns
- What components does this touch?
- What new coupling does it introduce?
- What's the failure mode if [external service] goes down?
- What's the rollback plan?

### 3. Required Test Coverage
For each new codepath, list:
- The happy path test
- The failure path test
- The edge case test

### 4. Failure Modes
| Codepath | Failure | Handled? | User Sees |
|---|---|---|---|

### 5. Verdict
PROCEED — implementation plan is sound
REVISE — needs changes before spec (list specific changes)
SIMPLIFY — overbuilt, suggest minimal version
```

**Output consumed by spec.sh:**
- The eng review file is read alongside the PRD template during spec generation
- The spec prompt includes: "Engineering review identified these concerns. Address each one in the Codex Prompt section."

**Pipeline change:**
```
ideate → organize → CEO review → eng review (NEW) → spec → build → ship → review → qa
```

---

## PRIORITY 3: Structured QA Report Template — MEDIUM VALUE

### What gstack does
Standardized QA report with:
- Health score per category (Console: 15%, Links: 10%, Visual: 10%, Functional: 20%, UX: 15%, Performance: 10%, Content: 5%, Accessibility: 15%)
- Issue taxonomy with severity levels (critical/high/medium/low)
- Before/after screenshot evidence
- Ship-readiness summary
- Regression mode (compare against baseline)

### What we steal
Our QA reports are currently freeform text files. Adopt a structured template that works with our existing automated checks AND future browser QA.

### Implementation: `factory/templates/qa-report.md`

New template file + update `qa.sh` to populate it instead of writing freeform markdown.

**Key additions to current qa.sh:**
- Category-level scoring (not just one total score)
- Issue taxonomy classification (from `qa/references/issue-taxonomy.md`)
- Baseline storage in `factory/qa-reports/{idea-id}-baseline.json` for regression comparison
- Ship-readiness verdict based on score thresholds

**Scoring weights adapted for our pipeline:**
| Category | Weight | Source |
|---|---|---|
| TypeScript | 25% | `tsc --noEmit` |
| Tests | 20% | `npm test` |
| Lint | 10% | `npm run lint` |
| Code Review | 20% | `review.sh` findings |
| File Coverage | 10% | PRD files vs diff |
| Build Health | 15% | Clean compile, no warnings |

---

## PRIORITY 4: Review Checklist File — MEDIUM VALUE

### What gstack does
`review/checklist.md` — a versioned, maintained checklist that the review process reads every time. Separates the review criteria from the review script. Allows updating what we check without changing code.

### What we steal
Create `factory/checklists/review-checklist.md` — the checklist that `review.sh` sends to Gemini alongside the diff. Versionable, auditable, evolvable independently of the script.

### Implementation: `factory/checklists/review-checklist.md`

```markdown
# Factory Code Review Checklist
Version: 1.0

## Pass 1 — CRITICAL (blocks QA)

### Prisma/DB Safety
- Raw SQL with string interpolation
- Missing WHERE on UPDATE/DELETE
- Transactions missing on multi-step mutations
- N+1 queries (Prisma select without include where relation used)

### Auth & Trust
- New API route without auth check
- User input passed to Prisma without validation
- Missing CSRF on mutation endpoints
- LLM output stored to DB without format validation

### Race Conditions
- Status transitions without optimistic locking or atomic WHERE
- Concurrent upsert without unique constraint
- Shared mutable state in API routes (module-level variables)

### Type Safety
- `as any` on external data boundaries
- Missing Zod schema on API input
- Non-null assertion (!) on user-controlled data
- Untyped environment variables used directly

## Pass 2 — INFORMATIONAL

### Error Handling
- Bare catch(e) that swallows without logging
- Missing error boundary in React page components
- API route returns 200 on error conditions
- Try/catch around Prisma without specific error types

### Code Quality
- Same logic in 2+ files (DRY violation)
- Unused imports or variables
- Console.log left in production code
- TODO/FIXME without linked issue

### Test Gaps
- New API route with no test
- Edge case described in PRD with no test
- Error path with no negative test

## Suppressions — DO NOT flag
- Pre-existing issues not in the PR diff
- Style-only differences (formatting, import order)
- TypeScript `any` in test files
- Console.log in development-only code paths
```

---

## PRIORITY 5: Diff-Aware Browser QA — LOWER PRIORITY (FUTURE)

### What gstack does
`/qa` in diff-aware mode:
1. Analyzes `git diff` to find affected pages/routes
2. Auto-detects running dev server (localhost:3000, 4000, 8080)
3. Navigates to each affected page with headless browser
4. Takes screenshots, checks console, tests interactions
5. Produces before/after evidence
6. Fixes bugs with atomic commits

### What we steal (future phase)
Wire OpenClaw's browser tool into the factory QA pipeline. Our browser tool already exists — it's just not connected to the factory.

### Implementation sketch (not for this sprint)
Add a `--browser` flag to `qa.sh` that:
1. Reads the diff to find affected pages
2. Starts the Next.js dev server in the workdir
3. Uses OpenClaw browser tool to navigate each affected page
4. Screenshots + console error check
5. Deducts from health score for visual issues or console errors

This requires the factory to run on the Mac (not a remote server), which it already does.

---

## PRIORITY 6: Bisectable Commits in ship.sh — LOW VALUE

### What gstack does
`/ship` splits changes into logical, independently-valid commits:
1. Infrastructure (migrations, config, routes)
2. Models & services (with their tests)
3. Controllers & views (with their tests)
4. VERSION + CHANGELOG (final commit)

### What we steal
Our `ship.sh` currently commits everything as one commit. For factory PRs this is fine — they're typically small. But for larger builds, bisectable commits would help debugging.

### Implementation
Skip for now. Our factory PRs are single-feature, typically <200 LOC. Bisectable commits add complexity for minimal benefit at our scale. Revisit if PRs grow larger.

---

## SKIP LIST (not worth stealing)

| gstack Feature | Why Skip |
|---|---|
| `/retro` | Team ceremony for a 2-entity operation. Our daily notes + MEMORY.md serve the same purpose. |
| `/document-release` | We don't maintain separate ARCHITECTURE/CONTRIBUTING docs per repo. |
| `/setup-browser-cookies` | Our browser tool handles auth differently (OpenClaw has native browser control). |
| Greptile integration | Paid dependency for PR comment triage. `gh pr review` is sufficient. |
| Conductor (parallel sessions) | We already have parallel Codex sessions. This is their paid product, not a technique to steal. |
| SKILL.md template system | Cool engineering but solves a problem we don't have (Claude Code skill drift). |
| Contributor mode | Self-improvement feedback loop for gstack itself. We have our own `self-improving-agent` skill. |
| TODOS.md integration | Our pipeline uses `ideas.jsonl` + factory status tracking instead. |

---

## Implementation Order

### Sprint 1: Review Pipeline (2 new scripts)
1. **`factory/checklists/review-checklist.md`** — the checklist file
2. **`factory/scripts/review.sh`** — paranoid code review (post-build, pre-QA)
3. **Update `qa.sh`** — call `review.sh` in auto mode before running checks, integrate findings into health score
4. **`factory/templates/qa-report.md`** — structured report template

### Sprint 2: Engineering Review Gate (1 new script)
5. **`factory/scripts/eng-review.sh`** — architecture/technical challenge (post-CEO-review, pre-spec)
6. **Update pipeline** — wire eng-review between CEO review and spec in cron/manual flows
7. **Update `spec.sh`** — read eng-review output and inject into spec prompt

### Sprint 3: Integration & Polish
8. **Update cron jobs** — add review.sh to the build+qa cron
9. **Update `discord-helper.sh`** — new Discord notifications for review pass/fail
10. **Test full pipeline** — end-to-end: idea → CEO → eng → spec → build → ship → review → QA

---

## Pipeline: Before vs After

**BEFORE:**
```
ideate → organize → [CEO review] → spec → build → ship → QA (tsc/lint/tests) → done
```

**AFTER:**
```
ideate → organize → [CEO review] → [eng review] → spec → build → ship → [paranoid review] → QA (tsc/lint/tests + review score) → done
```

Two new gates. Both catch different failure classes:
- **Eng review** catches "this will be a nightmare to implement" before we waste a Codex run
- **Paranoid review** catches "this code has a race condition / auth gap / trust boundary violation" before we merge

---

## Codex Execution Spec

Each new script follows the same pattern as existing factory scripts:
- Bash script, sources `discord-helper.sh`
- `--auto` flag for cron-driven execution
- Uses `gemini_generate` for LLM calls (cheap, fast)
- Reads/writes `ideas.jsonl` for status tracking
- Posts updates to Discord channels
- Stores artifacts in `factory/reviews/` and `factory/checklists/`

**Estimated token cost per run:**
- review.sh: ~5K tokens input (diff + checklist), ~2K output = ~$0.02 on Gemini Flash
- eng-review.sh: ~8K tokens input (idea + code context), ~3K output = ~$0.03 on Gemini Flash
- Total added cost per factory item: ~$0.05

All scripts are designed for Codex to implement. The prompts, templates, and integration points are fully specified above.
