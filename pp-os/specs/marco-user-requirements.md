# Marco — "The Solo Shipper" — User Requirements

**Status:** Final Draft v2
**Date:** 2026-03-16
**Author:** Charles + Rod
**Source:** Discord #user-requirements thread
**Last Updated:** 2026-03-16 13:05 MDT

---

## Who Is Marco

Ships with Codex/Claude Code daily. Wakes up to broken prod because the agent merged at 2am. Wants guardrails without process.

- **Quote:** "I need a seatbelt, not a speed limit."
- **Where:** r/ChatGPTPro, Cursor forums, X vibe-coding, Indie Hackers
- Solo developer, 1-3 repos, 10-20 agent PRs/day
- Deploys continuously (Vercel/Netlify)
- Reviews from phone and desktop
- May have a factory pipeline auto-creating issues and PRs — he doesn't always know why a PR exists

---

## Design Principles

1. **Approval ≠ Merge.** Approval is a permission decision (instant, human). Merge is an engineering operation (async, may fail). PP owns the decision; GitHub owns the merge plumbing.
2. **Delegate merge orchestration to GitHub merge queue (v1).** Don't rebuild sequential merge + CI retest infrastructure. PP adds the governance layer GitHub doesn't have.
3. **Pre-compute everything.** By the time Marco sees a notification, the AI summary, risk signals, diff, verification steps, and preview are ready. Never make him wait for enrichment on page load.
4. **Day 1 value in 60 seconds.** Notification → open link → read summary → approve → merged. No onboarding wizard, no dashboard required.
5. **The AI summary is the product.** If the summary is useless, PP is useless. This is the #1 quality gate.
6. **Marco may not read code.** The review page must enable confident approval decisions without ever opening the diff. Preview, summary, verification steps, and origin context are the primary review surfaces — the diff is a fallback.
7. **All state is server-side.** The UI is a view into the database. Multi-device, multi-session — always consistent. No client-side state that diverges.

---

## Adoption Curve

| Day 1 (just installed) | Day 7 (trusts the flow) | Day 30 (power user) |
|---|---|---|
| Single PR review page | Queue dashboard | Auto-approve rules |
| AI summary + risk badges | Bulk approve | Keyboard navigation |
| Visual preview + verification steps | Group by repo + risk sort | Agent analytics |
| Origin context | Push notification tuning | Risk-gated friction |
| Approve/reject/merge | Agent attribution | Preview snapshots |
| Receipt | Review iteration tracking | |
| Basic notification | Stale request handling | |
| Approval revocation (undo) | Agent trust signals | |
| Incident tracing | Summary confidence signals | |

---

## Dealbreakers (in priority order)

1. **AI summary quality** — Bad summary = no value over GitHub. Must answer: what changed functionally, what's risky, what's unusual.
2. **Approve → merge reliability** — If Marco approves and then has to go to GitHub to click merge, he's doing double work. Must work every time.
3. **Page load speed** — Enrichment pre-computed at PR creation, not on page open. Review page loads in <2s.
4. **Notification accuracy** — Right signal, right time. Too many = ignored. Too few = missed PRs.
5. **Verification clarity** — If Marco follows the verification steps and they're wrong/stale/irrelevant, trust in PP erodes fast.

---

## Architecture Decision: Merge Queue

**v1: Delegate to GitHub's native merge queue.**

GitHub's merge queue handles:
- Sequential merging with temporary merge_group branches
- Auto-tests PR against latest main + everything ahead in queue
- Auto-merges on pass, ejects on failure
- Conflict detection and branch updates

GitHub's merge queue does NOT handle:
- Approval governance (it's post-approval — starts after human clicks merge)
- Risk analysis or AI summary
- Bulk operations or prioritization
- Receipts or audit trail
- Deploy awareness

**PP's value chain:**
```
Agent creates PR
  → PP captures it (deploy-gate)
  → PP enriches it (AI summary, risk signals, diff, verification steps, preview)
  → Marco DECIDES (approve/reject)
  → PP adds to GitHub merge queue
  → PP TRACKS the outcome (receipt, deploy status)
```

**v2 (future): PP-owned merge queue** with prioritization, flaky test retry, batching, cross-repo orchestration.

---

## Requirements

### Core (Day 1 — must ship)

#### M1. Deploy Request Capture
- deploy-gate GitHub Action detects new PRs (non-draft, ready for review)
- Creates deploy request in PP backend
- Enrichment pipeline runs immediately on capture:
  - Fetch PR diff from GitHub
  - Detect risk signals via pattern matching
  - Generate AI summary via LLM
  - Generate verification checklist via LLM
  - Detect and store deploy preview URL
  - Resolve origin context (linked issue, automation source)
  - Cache all results (enrich once, serve many)
- Draft PRs ignored until marked ready

#### M2. Push Notification
- Notification when new deploy requests arrive
- Configurable trigger: all requests / high-risk only / hourly digest
- Notification links directly to the review page (not dashboard)
- Channels: email (default), Slack webhook, Discord webhook, browser push
- This is the product entry point — without it, Marco never opens PP

#### M3. Single PR Review Page

Information hierarchy (top to bottom):

**1. Origin Context (M3c) — WHY does this exist?**
- Link to originating GitHub issue (if PR references one via closes/fixes/resolves)
- Show issue title + first 2-3 lines of description
- If created by automation/factory: show the pipeline name + idea/rule that triggered it
- If no linked issue: flag "⚠️ No linked issue — untracked agent work"
- Displayed at the very top — context before content

**2. AI Summary (M4) — WHAT does it do?**
- 2-3 sentences: what changed functionally, why it matters, anything unusual
- Must answer three questions:
  1. What changed functionally?
  2. What's risky about this change?
  3. Is anything unusual for this repo?
- Bad: "Modified 3 files in src/auth/"
- Good: "Adds rate limiting to login endpoint. New Redis dependency. Auth middleware restructured — verify session handling still works."
- Uses full diff context, not just file names
- Quality of this feature determines whether PP lives or dies

**3. Visual Preview (M3a) — HOW does it look/behave?**
- Detect deploy preview URLs from GitHub deployment statuses or PR comments (Vercel, Netlify, Render, CF Pages)
- Embed preview in review page (iframe with fallback link)
- "Open in new tab" and "Compare with production" links
- For API-only changes: show endpoint diff and schema diff instead of preview
- For database changes: show before/after table structure
- For dependency changes: show added/removed/updated packages with version diff
- If no preview available: show "No preview — review via summary and verification steps"

**4. Verification Checklist (M3b) — HOW do I confirm it works?**
- AI-generated at enrichment time (pre-computed, not on-demand)
- 3-6 concrete steps tailored to the PR's content and risk level
- References preview URL directly when available ("Open preview → go to /settings")
- Risk-tiered depth:
  - LOW: "CI green, no functional changes — auto-approve candidate"
  - MEDIUM: Basic flow walkthrough, 3-5 steps
  - HIGH: Specific security + data integrity + regression checks, 5-8 steps
- Steps are actionable by someone with zero context on the PR
- Checkboxes — Marco can mark steps as verified (optional, not required for approval by default)

**5. Risk Badges (M5) — HOW dangerous is it?**
- Pattern-based scanning of diff content
- Categories:
  - AUTH — authentication/authorization changes
  - DB-MIGRATION — schema changes, migrations
  - SECRETS — env vars, keys, tokens
  - INFRA — Dockerfile, CI config, deploy config
  - BILLING — payment, subscription, pricing logic
  - API-BREAKING — endpoint changes, response shape changes
  - DEPENDENCY — new or updated packages
  - CONFIG — application configuration changes
- Severity levels: LOW (informational), MEDIUM (review recommended), HIGH (manual review required)
- Overall PR risk = highest severity signal detected
- Summary confidence indicator: if risk signals disagree with summary tone, flag it (M24):
  - Summary says "docs update" but risk says AUTH + HIGH → "⚠️ Summary may not reflect full scope"
  - For large diffs (500+ lines): "⚠️ Large diff — summary may miss details"

**6. PR Metadata**
- Title, author/agent, branch, target branch, files changed, lines changed
- Agent attribution: which agent created this PR (Codex, Claude Code, Cursor, Copilot, custom)
- Review attempt counter: "Review attempt: 1" (increments on rejection + re-review)

**7. Diff (expandable) — for those who want code details**
- File list with expandable patches, syntax highlighting
- Collapsed by default — most Marcos never open it
- If this is a re-review after rejection: option to show "Changes since last review" diff (only what agent modified after rejection)

**8. Actions**
- **Approve Button** — Sticky (visible while scrolling), one tap, no mandatory reason field
- **Reject Button** — Opens structured rejection flow (M17)
- **Merge Button** — Adds PR to GitHub merge queue (appears after approval)
- **Revoke Button** — Undo approval before merge completes (M19)
- **Receipt Link** — Shown immediately after approval

#### M4. AI Summary Quality
(Defined inline under M3 section 2 above)

#### M5. Risk Signal Detection
(Defined inline under M3 section 5 above)

#### M6. Cryptographic Receipt
- Generated on every approval action
- Contains:
  - What: PR reference + commit SHA at time of approval
  - Who: approver identity
  - When: timestamp
  - Context: risk signals + AI summary snapshot at decision time
  - Preview: screenshots of preview at approval time (v2, see M3a addendum)
- Immutable, linkable, independently verifiable
- Revocation receipts also generated if approval is revoked (M19)
- This is PP's core IP — proof that a human authorized the change

#### M7. Merge via GitHub Merge Queue
- After approve, "Merge" adds the PR to GitHub's native merge queue
- PP polls for status updates: queued → testing → merged → ejected
- Status shown on review page in real-time
- On merge success: update deploy request status, show receipt
- On merge failure:
  - Show reason (CI failure, conflict, etc.)
  - "Retry" button (re-adds to merge queue)
  - "Remove" button (cancels)
  - "View on GitHub" link
- Merge method configurable per-repo: squash (default), merge, rebase

#### M17. Rejection with Reproduction Context
- When Marco rejects, structured rejection flow:
  - "Which verification step failed?" — checkboxes matching the checklist
  - "What happened?" — structured options: "500 error" / "Wrong behavior" / "Page didn't load" / "Looks wrong visually" / "Other"
  - Free text description
  - Optional: paste or upload screenshot
- PP posts rejection to GitHub PR as structured comment:
  ```
  ❌ Rejected via Permission Protocol

  Failed verification step: #2 — "Click Sign up with Google"
  Observed: 500 Internal Server Error
  Expected: OAuth redirect to Google

  Screenshot: [attached]
  Reviewer: Marco
  Receipt: pp://receipt/b7f2a...
  ```
- Creates feedback loop: reject → agent reads comment → fixes → PR updated → PP re-enriches → Marco gets "PR updated — re-review?" notification

#### M19. Approval Revocation (Undo)
- "Revoke approval" available from approval until PR is merged
- Removes PR from GitHub merge queue
- Generates revocation receipt (audit trail: approved at T1, revoked at T2, with reason)
- After merge: revocation no longer possible — shifts to revert flow (M22)
- Post bulk-approve: 10-second toast — "N PRs approved. [Undo all]" before queue processing begins
- In queue view: "Undo" visible on recently-approved items

#### M22. Incident Tracing & Revert
- "Recently merged" view: all PRs merged in last N hours
- Per-PR: deploy status, risk signals at approval time, files touched, receipt link
- One-click "Revert" — creates revert PR on GitHub → enters PP approval flow
- Revert receipt links to original approval receipt (complete chain of custody)
- If reverting a PR that other PRs were merged after: warning "Subsequent PRs may depend on this change"
- For v1: manual identification of culprit via recently merged view. No automatic detection.

### Queue (Day 7 — when volume grows)

#### M8. Queue Dashboard
- All pending deploy requests in one view
- Grouped by repo with collapsible sections
- Per-repo summary: count + risk breakdown (e.g., "3 high · 5 med · 4 low")
- Default sort: risk (high → low), then age (oldest first) within risk tier
- Header stats: total pending, oldest request age
- Stale requests (M21) in separate section, not mixed with fresh ones
- Quick-scan: Marco reads this screen in under 10 seconds

#### M9. Bulk Approve
- "Approve all LOW risk" — single click
- Confirmation modal: shows titles + repos being approved, requires explicit confirm
- Never bulk-approves MEDIUM or HIGH risk
- Per-repo variant: "Approve all LOW in [repo]"
- After bulk approve: each PR auto-enters GitHub merge queue
- Each approval generates its own receipt
- 10-second "Undo all" toast after bulk approve (ties to M19)

#### M10. Queue Status View
- Post-approval lifecycle per PR:
  - Approved → In merge queue → CI running → Merged → Deployed
  - Approved → In merge queue → CI failed → Ejected (reason)
  - Approved → In merge queue → Conflict → Ejected (conflicting files)
- "Retry" button for ejected PRs
- "Remove from queue" to cancel merge
- View persists after completion — Marco sees the full session result
- Session summary at bottom: "8 merged · 1 conflict · 1 CI failure · 12 min"

#### M11. Agent Attribution
- Shows which agent created each PR: Codex, Claude Code, Cursor, Copilot, or custom label
- Displayed on review page and in queue list
- Filterable in queue: "Show only Codex PRs"

#### M12. Request Age Display
- Relative timestamp on each request ("3h ago")
- Older requests sort higher within same risk tier
- Age visible in queue view without clicking into detail

#### M18. Agent Trust Signals
- Per-agent trailing stats shown on the review page:
  ```
  Agent: Codex
  Last 30 days: 47 PRs · 2 rejected · 1 reverted
  Rejection rate: 4.3%
  ```
- If rejection or revert rate is elevated vs trailing average: show ⚠️
- Not a full analytics page — a trust signal at the point of decision
- Helps Marco calibrate: "Codex is reliable, approve faster" vs "Cursor has been flaky, look closer"

#### M20. Review Iteration Tracking
- Each deploy request tracks review attempts: attempt 1 (rejected, reason), attempt 2 (rejected, reason), attempt 3 (current)
- Previous rejection reasons visible on the review page
- "What changed since last review" diff option — shows only what agent modified after rejection, not full diff vs main
- If attempt count > 2: flag — "⚠️ This PR has been rejected twice. Consider: closing it, rewriting the issue, or switching agents."

#### M21. Stale Request Handling
- After configurable threshold (default: 48h), PP marks request as "Stale"
- Stale requests get re-enriched: updated AI summary checks relevance against current main
- Warning: "This PR was created N days ago. Main has advanced M commits. Preview may be outdated."
- Actions: "Re-test" (trigger branch update + re-enrichment) / "Close PR" / "Review anyway"
- Stale requests in separate queue section — not mixed with fresh items

#### M24. Summary Confidence & Disagreement Detection
- If risk signals contradict summary tone: explicit flag
  - "⚠️ Summary describes documentation changes but AUTH risk signals detected"
- For large/complex diffs: "⚠️ 847 lines changed — summary may not capture all changes"
- Confidence indicator: based on diff complexity, number of files, coherence of changes
- Safety net for when the AI is wrong — the summary is the product, but it's not infallible

### Polish (Day 30 — power user)

#### M13. Auto-Approve Rules
- Define rules as conditions:
  - File pattern match (e.g., `*.md`, `docs/**`)
  - Risk level (LOW only for v1)
  - Repo scope (specific repo or all)
  - Agent filter (optional: "only auto-approve Copilot PRs")
- Auto-approved PRs go directly to GitHub merge queue
- Shown in queue as "Auto-approved" (greyed, collapsible section)
- Each auto-approval still generates a receipt
- Kill switch: "Pause all auto-approve rules" — one toggle, instant effect
- Audit log: which rule auto-approved which PR

#### M14. Keyboard Navigation
- `J`/`K` — move through queue items
- `A` — approve current
- `R` — reject current
- `Enter` — open detail page
- `Esc` — back to queue
- `Space` — expand/collapse diff section
- `N`/`P` — next/previous PR within detail view

#### M15. Post-Merge Deploy Status
- Per merged PR: shows deploy status from Vercel/Render/GitHub Actions
- Simple states: Deploying → Deployed ✅ or Deploy failed ❌
- Link to deploy dashboard/logs
- No health monitoring, no canary, no rollback (Sarah's world)

#### M16. Empty State
- When queue hits zero: "✅ All clear"
- Session stats: approved count, rejected count, auto-approved count, total time
- Reinforcement that the queue is processed, not just empty

#### M23. Risk-Gated Approval Friction
- Configurable, off by default (Marco hates friction):
  - LOW risk: one-tap approve, no friction
  - MEDIUM risk: one-tap approve, brief confirmation prompt
  - HIGH risk: require at least one verification step checked before approve is enabled
- Marco turns this on after his first incident, not on Day 1
- Toggle in settings: "Require verification for HIGH risk"

#### M3a Addendum: Preview Snapshots
- At enrichment time, PP captures automated screenshots of the deploy preview
- Key pages detected from the diff (routes/pages affected)
- 2-5 screenshots stored as part of the deploy request record
- Included in receipt: "what did it look like when you approved"
- Solves: preview URLs die after merge, but screenshots persist for incident investigation

---

## Edge Cases & Decisions

### Agent pushes to a PR already in merge queue
- GitHub re-tests automatically (new push invalidates merge group)
- PP shows: "⚠️ PR updated while in merge queue — re-testing"
- Does NOT require re-approval (agent iterating, Marco already authorized)

### Flaky CI
- v1: PP shows "CI failed" + "Retry" button + "View logs" link
- v2: Auto-retry once for tests flagged as flaky, eject on second failure
- PP does NOT auto-retry in v1 (dangerous without flake detection)

### PR targeting non-default branch
- PP captures PRs against any protected branch with deploy-gate
- Target branch shown prominently on review page
- Risk signal: "⚠️ Targets `release/v2` not `main`"

### Draft PRs
- deploy-gate ignores drafts
- Captures when agent/dev marks PR "Ready for review"

### Stale approval (new commits after approve)
- Marco default: approval survives (trust mode)
- Branch updates from merge queue: approval always survives
- New human commits: flag but don't invalidate in v1
- (Sarah will get strict mode: invalidate on any new push)

### PR that keeps getting rejected (iteration loop)
- Tracked via M20 (review iteration tracking)
- After 2 rejections: flag suggesting alternative actions
- Rejection comments structured for agent consumption (M17)

### Orphan PR (pending for days)
- Handled by M21 (stale request handling)
- Re-enrichment against current main after 48h threshold
- Separate queue section prevents stale items from cluttering fresh queue

### Batch approve then regret
- Handled by M19 (approval revocation)
- 10-second undo toast after bulk approve
- Individual revocation available until merge completes

### Summary contradicts risk signals
- Handled by M24 (disagreement detection)
- Explicit flag when summary tone doesn't match detected risks
- Large diff warning when summary may miss details

### Offline / slow connection
- Approval is a server-side action — if the request reaches the server, it's recorded
- If connectivity drops mid-action: standard retry UX ("Failed to approve — retry?")
- No offline queue or local state — PP is server-authoritative

### Multi-repo PRs that are semantically linked
- Out of scope for Marco v1 (his repos are independent)
- Sarah's cross-repo dependency awareness (S4) addresses this
- Future: agent could tag related PRs in PR description, PP could detect and group

### Agent-initiated context
- Agents can include explanatory context in PR description (already supported by GitHub)
- PP's enrichment pipeline includes the PR description in the AI summary generation
- Future: structured agent metadata (JSON in PR body) that PP parses for richer context

---

## What's Explicitly Out of Scope (Marco v1)

| Feature | Why | When |
|---|---|---|
| PP-owned merge queue engine | GitHub handles merge orchestration. PP adds governance. | v2 (prioritization, batching, flaky retry) |
| Queue reordering / pause | Delegated to GitHub FIFO queue | v2 (PP-owned queue) |
| Deploy strategy selector | Marco deploys on every merge, no config needed | Sarah v1 |
| Staged deploy pipeline | No canary/staging gates | Sarah v1 |
| Stale approval strict mode | Marco trusts himself | Sarah v1 |
| Cross-repo dependencies | Marco's repos are independent | Sarah v1 |
| Role-based approval delegation | Solo user | Sarah v1 |
| Team analytics / reporting | Solo user | Sarah v1 |
| Mobile swipe gestures | Responsive design is sufficient | Maybe never |
| Conflict resolution UI | GitHub handles. PP shows status + links out | v2 |
| Automatic incident detection | Manual identification via recently merged view | v2 |
| Flaky test auto-retry | Needs flake detection system first | v2 |

---

## Build Order

### Sprint 1: Core Loop
M1 (Capture) + M3 (Review Page with origin/summary/preview/verification/risk/diff) + M6 (Receipt)

*Marco can: get notification → open enriched review page → see WHY the PR exists, WHAT it does, HOW it looks, HOW to verify → approve → get receipt*

### Sprint 2: Merge + Notify + Safety
M7 (Merge via GH Queue) + M2 (Notifications) + M17 (Rejection with context) + M19 (Approval revocation)

*Marco can: approve → merge from PP → get notified of new PRs → reject with structured feedback → undo mistakes*

### Sprint 3: Scale
M8 (Dashboard) + M9 (Bulk Approve) + M10 (Queue Status) + M11 (Agent Attribution) + M12 (Age) + M22 (Incident Tracing)

*Marco can: handle 21 PRs across 3 repos in one session → trace incidents post-merge → revert bad changes*

### Sprint 4: Trust & Hygiene
M18 (Agent Trust Signals) + M20 (Review Iteration Tracking) + M21 (Stale Requests) + M24 (Summary Confidence)

*Marco can: calibrate trust per agent → track rejection/fix cycles → keep queue clean → catch AI summary errors*

### Sprint 5: Power User
M13 (Auto-Approve Rules) + M14 (Keyboard Nav) + M15 (Deploy Status) + M16 (Empty State) + M23 (Risk-Gated Friction) + M3a Addendum (Preview Snapshots)

*Marco is a power user with tuned auto-approve, fast keyboard workflow, and archival-quality evidence*

---

## GitHub Merge Queue — Setup Requirement

Marco must add `merge_group` event to his CI workflow for GitHub merge queue to function:

```yaml
on:
  pull_request:
  merge_group:
```

PP onboarding should detect this and guide Marco through the one-line addition if missing.

---

## Competitive Positioning

| Feature | GitHub | Trunk/Graphite | PP |
|---|---|---|---|
| Merge orchestration | ✅ Native queue | ✅ Advanced (parallel, batch) | ❌ Delegates to GH (v1) |
| Approval governance | ❌ Post-approval only | ❌ Post-approval only | ✅ Core product |
| AI enrichment | ❌ | ❌ | ✅ Summary + risk + verification |
| Visual preview integration | ❌ | ❌ | ✅ Embedded previews |
| Verification steps | ❌ | ❌ | ✅ AI-generated checklists |
| Origin context | ❌ (just issue link) | ❌ | ✅ Full context at review time |
| Cryptographic receipts | ❌ | ❌ | ✅ Core IP |
| Bulk approve | ❌ | ❌ | ✅ Risk-gated |
| Risk-based prioritization | ❌ | Partial (priority labels) | ✅ Automatic detection |
| Agent attribution | ❌ | ❌ | ✅ First-class |
| Agent trust signals | ❌ | ❌ | ✅ Per-agent track record |
| Rejection feedback loop | ❌ (manual comments) | ❌ | ✅ Structured → agent-readable |
| Incident tracing | ❌ | ❌ | ✅ Merged → receipt → revert chain |
| Deploy awareness | ❌ | ❌ | ✅ Post-merge tracking |

**PP's moat:** Nobody else sits between "agent created a PR" and "human says go." GitHub starts after the human clicks merge. Trunk starts after the PR is approved. PP starts at PR creation — and gives Marco everything he needs to make the decision without reading code.

---

## Summary: Marco's Decision Surface

When Marco opens a PP review page, he sees (in order):

1. **WHY** — Origin issue, factory context, reason this PR exists
2. **WHAT** — AI summary of functional changes in plain English
3. **HOW IT LOOKS** — Live preview embed, compare with production
4. **HOW TO VERIFY** — 3-6 concrete steps he can follow right now
5. **HOW DANGEROUS** — Risk badges, confidence signal, agent trust score
6. **THE CODE** — Diff (collapsed, for those who want it)
7. **HIS OPTIONS** — Approve / Reject (with context) / Merge / Undo

He never needs to read a line of code. He never needs to remember why this PR exists. He never needs to guess if it works. PP gives him the complete decision surface in one screen.

That's the product.
