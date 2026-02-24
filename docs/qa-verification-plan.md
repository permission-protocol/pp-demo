# QA Verification System — Plan v2

**Goal:** Automated verification of completed PP Product Board work using DGX Spark (R1 70B) as a free QA reviewer, closing the internal feedback loop.

---

## Architecture

```
Done item lands on board
  → Sonnet cron (overnight) picks it up, moves to "QA Review"
  → Check: does issue have AC: block?
    → No → FAIL immediately, comment "Add acceptance criteria", reopen
    → Yes → Continue
  → Determine template type from labels/title
    → Can't determine? → AMBIGUOUS → R1 suggests template
  → Deterministic test scripts run per template
  → Build proof map: each AC item → status (proven/unproven/false) + evidence
  → All proven? → Auto-verify, move to "Verified" ✅
  → Any false? → FAIL, reopen with specific evidence ❌
  → Any unproven? → Ship proof map to R1 70B on Spark
  → R1 judges only the unproven criteria, writes verdict
  → Sonnet reads verdict, routes: Verified ✅ or Reopened ❌
  → Generate verification receipt (proof map + verdict + artifacts)
  → Monthly: review rejection patterns, update executor prompts
```

**Sonnet** = orchestrator (fast tool calling, cheap on cron)
**Deterministic scripts** = arms and legs (free, instant)
**R1 70B** = brain for ambiguous cases only (free, slow, overnight)

---

## Core Rules

### PASS / FAIL / AMBIGUOUS Definitions

These are hard rules. No exceptions.

- **PASS** = every acceptance criterion has a deterministic proof (artifact produced by a test script, not manually attached)
- **FAIL** = any criterion is proven false OR a required artifact is missing OR acceptance criteria are absent
- **AMBIGUOUS** = all tests are green but one or more criteria remains unproven

### Acceptance Criteria Policy

QA only runs automatically if the issue includes an `AC:` block:

```markdown
## AC:
- [ ] Logo renders as Space Grotesk typography lockup
- [ ] Colors match brand palette (void, ash, signal, permit, deny)
- [ ] Page loads in <3s

## How to verify:
- URL: https://permissionprotocol.com
- Screenshot: header area
- Command: curl -s -o /dev/null -w "%{http_code}" https://permissionprotocol.com
```

**Minimum viable AC:** At least 1 deterministic criterion (checkable by script) and 1 verification target (URL, command, or screenshot target).

**If AC block is missing or insufficient:** QA immediately fails with comment: "QA blocked — add `AC:` block with at least one deterministic criterion and a verification target."

**Executor responsibility:** The `pp-os-execute-ready` cron must include AC blocks when creating issues. This keeps the burden automated, not on Rod.

### Evidence Strength by Issue Type

| Type | Auto-verify OK? | Required evidence |
|---|---|---|
| Blog post | Yes | HTTP 200 + quality gate pass + meta tags present |
| Visual/brand | Yes | CSS values match spec + screenshot captured |
| PR/code | Yes | PR merged + CI green + no unresolved reviews |
| API change | Yes | Endpoint responds correctly + error handling verified |
| Infra/security | Only with strong proof | CI green + health check pass + no error spike in logs |

Infra/security items need stronger deterministic proof, not human sign-off. But never auto-verify on weak evidence (e.g., "deploy succeeded" alone isn't enough — verify the result).

---

## Board Changes

Add two columns to PP Product Board (#2):
- **QA Review** — item is being tested
- **Verified** — item passed QA with evidence

Flow: Ready → In Progress → Done → QA Review → Verified (or → Ready with QA notes)

---

## Phase 1: Foundation

### 1.1 Golden Reference Specs

Separate specs per product:

**`qa/pp-brand-spec.json`** — Permission Protocol
```json
{
  "brand": {
    "fonts": {"primary": "Space Grotesk", "mono": "Space Mono"},
    "colors": {
      "void": "#0a0a0a",
      "ash": "#1a1a1a",
      "signal": "#c8c8c8",
      "permit": "#44aa99",
      "deny": "#aa4455"
    },
    "logo": {
      "text_primary": "PERMISSION",
      "text_secondary": "PROTOCOL",
      "favicon_hash": null
    }
  },
  "urls": {
    "site": "https://permissionprotocol.com",
    "demo_repo": "https://github.com/permission-protocol/pp-demo",
    "github_action": "https://github.com/permission-protocol/deploy-gate"
  },
  "viewport": {"width": 1440, "height": 900},
  "screenshot_diff_threshold_pct": 5,
  "spec_version": "2026-02-24"
}
```

**`qa/xdares-brand-spec.json`** — Xdares
```json
{
  "urls": {
    "blog": "https://blog.xdares.com",
    "app": "https://xdares.com"
  },
  "seo": {
    "min_word_count": 300,
    "required_elements": ["h2", "meta_description", "internal_links", "title"]
  },
  "spec_version": "2026-02-24"
}
```

Specs are versioned by date. Update `spec_version` when brand changes ship.

### 1.2 Test Templates

Create `qa/templates/` with one template per issue type:

**`visual-change.json`**
- Screenshot target URL at pinned viewport (1440×900)
- Extract CSS variables from DOM
- Compare colors/fonts against brand spec
- Element-level snapshots preferred over full-page when possible
- Pixel-diff against golden reference if it exists (threshold: 5%)
- Check favicon hash

**`blog-post.json`**
- GET the live URL, verify 200
- Run quality-gate.sh (already built)
- Check canonical URL, meta tags, OG tags
- Verify internal links resolve (no 404s)

**`api-change.json`**
- curl endpoint, verify response shape
- Check error handling (bad input → proper error)
- Verify auth required where expected

**`infra-config.json`**
- Verify deploy/build succeeded (gh CLI)
- Check DNS/SSL if applicable
- Verify health endpoint returns OK
- Check error logs for spike post-deploy

**`pr-code.json`**
- PR merged? (gh pr view)
- CI passed? (gh run list)
- No open review comments unaddressed?

### 1.3 Proof Map Format

Every test run produces a proof map — the bridge between deterministic scripts and R1:

```json
{
  "issue": 215,
  "title": "Replace static logo with animated brand lockup",
  "template": "visual-change",
  "timestamp": "2026-02-25T02:15:00Z",
  "criteria": [
    {
      "ac": "Logo renders as Space Grotesk typography lockup",
      "status": "proven",
      "evidence": ["font-family extracted: 'Space Grotesk'", "screenshot: qa/screenshots/215-header.png"]
    },
    {
      "ac": "Colors match brand palette",
      "status": "proven",
      "evidence": ["--void: #0a0a0a ✓", "--permit: #44aa99 ✓", "--deny: #aa4455 ✓"]
    },
    {
      "ac": "Animation transitions smoothly",
      "status": "unproven",
      "evidence": ["Cannot verify animation timing deterministically"]
    }
  ],
  "summary": {
    "proven": 2,
    "unproven": 1,
    "false": 0
  }
}
```

R1 only receives and judges the **unproven** criteria, not the entire issue.

### 1.4 Template Detection

Priority order:
1. **Label** `type:visual`, `type:blog`, `type:api`, `type:infra`, `type:pr` → authoritative
2. **Title/keyword heuristics** → best effort
3. **Neither** → AMBIGUOUS → R1 suggests template + comments "please add `type:*` label"

Over time the system trains itself to be label-driven.

### 1.5 Test Runner Script
`scripts/qa-test-runner.sh`:
- Input: issue number + template type (or "auto" for label-first detection)
- Reads issue body from GitHub, parses AC block
- If no AC block or insufficient (missing deterministic criterion / verification target) → exit 1 (FAIL)
- If template is "auto" and can't determine from label or title → exit 2 (AMBIGUOUS, needs R1 to suggest template)
- Runs the matching template's deterministic checks
- Builds proof map JSON
- Exit codes: 0 = all proven (PASS), 1 = any false (FAIL), 2 = unproven items exist (AMBIGUOUS)

### 1.6 R1 Judgment Script
`scripts/qa-r1-judge.sh`:
- Input: proof map JSON (only unproven criteria + issue context)
- Sends to R1 70B via Ollama API on Spark
- Prompt requires strict JSON output per criterion:
  ```json
  [{"ac": "...", "verdict": "pass|fail", "reason": "one sentence"}]
  ```
- Non-JSON response = system error → retry once → keep in QA Review if still fails
- Returns structured verdict per criterion
- No credentials or secrets in the payload (trust zone)

---

## Phase 2: Board Integration

### 2.1 New Board Columns
Add "QA Review" and "Verified" status options via GraphQL mutation.

### 2.2 QA Cron Job
`pp-os-qa-review` cron:
- Schedule: `0 2 * * *` (2 AM daily — overnight)
- Model: Sonnet (orchestration only)
- Flow:
  1. Query all items in "Done" status
  2. For each: check AC block exists (min 1 deterministic criterion + 1 verification target)
  3. Determine template type: label `type:*` first, title/keywords second, AMBIGUOUS if neither
  4. Move to "QA Review"
  5. Run test runner → get proof map
  6. All proven → move to "Verified", attach receipt
  7. Any unproven → call R1 on Spark, apply verdict
  8. Any false or R1 fail → move to "Ready" with QA comment on issue
  9. Announce summary: "QA reviewed N items: X verified, Y reopened, Z need AC"
  - Max 20 items per night, oldest-first
  - If backlog > 20 → alert Rod

### 2.3 Spark Offline Safety
If Spark is unreachable:
- Items stay in "QA Review"
- Comment on issue: "Spark offline — awaiting QA judgment"
- Do NOT auto-verify
- Alert Rod in morning summary

---

## Phase 3: Learning Loop

### 3.1 Rejection Tracking
`qa/rejection-log.json`:
```json
[
  {
    "issue": 215,
    "date": "2026-02-25",
    "type": "visual-change",
    "reason": "missing_internal_links",
    "details": "No internal links found in published page"
  }
]
```
Track every QA failure with structured reason codes.

### 3.2 Executor Prompt Tuning
When patterns emerge (3+ similar failures):
- Identify the recurring failure type
- Add specific prevention rule to executor cron prompt
- Example: after 3 "missing internal links" failures → add "Always include at least 2 internal links" to executor prompt
- Log the prompt change in rejection-log for traceability

### 3.3 Golden Reference Updates
When brand changes ship:
- Update spec JSON + bump `spec_version`
- Capture new golden screenshots at pinned viewport
- Update favicon hash
- Old goldens archived (not deleted)

---

## Phase 4: Verification Receipts (PP Dogfooding)

When an item moves to "Verified," attach a receipt:

```json
{
  "receipt_type": "qa_verification",
  "issue": 215,
  "verified_at": "2026-02-25T02:18:00Z",
  "proof_map": { ... },
  "r1_verdict": { ... },
  "artifacts": [
    "qa/screenshots/215-header.png",
    "https://github.com/Roca-Ventures/Breakout-Labs/actions/runs/12345"
  ],
  "verifier": "charles-qa-system",
  "spec_version": "2026-02-24"
}
```

Receipts stored in repo at `qa/receipts/YYYY-MM/issue-NNN.json` and linked from the issue comment. Immutable once committed. This is Permission Protocol applied to ourselves — **verified isn't a label, it's evidence.**

---

## Implementation Order

| Step | What | Effort | Depends on |
|---|---|---|---|
| 1 | Brand spec files (PP + Xdares) | 15 min | — |
| 2 | Test templates (5 types) | 1 hr | Step 1 |
| 3 | Proof map format + test runner script | 1-2 hr | Step 2 |
| 4 | R1 judgment script | 30 min | — |
| 5 | Board columns (QA Review, Verified) | 15 min | — |
| 6 | QA cron job | 1 hr | Steps 3-5 |
| 7 | Rejection log + tracking | 30 min | Step 6 |
| 8 | Update executor prompt (require AC blocks) | 15 min | Step 6 |
| 9 | Verification receipt generation | 30 min | Step 6 |
| 10 | First live overnight run | — | Steps 1-8 |

**Total: ~half day to build, then iterate based on real results.**

---

## Trust Zone
- R1 on Spark is a different trust zone
- NEVER send credentials, API keys, or private data to Spark
- Send only: proof maps, issue bodies (public repo), test results, URLs, CSS values
- Spark offline → items wait, never auto-verify

---

## Success Criteria
- Done items get verified within 24 hours of completion
- QA catches at least 1 real issue in the first week
- Missing AC blocks get flagged automatically (not silently passed)
- Executor prompt improves based on rejection patterns within 30 days
- Zero API cost for R1 reasoning
- Every "Verified" item has a traceable proof chain
