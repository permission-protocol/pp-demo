# PRD: Mobile-First Approval Screen

**Status:** Draft
**Author:** Charles + Rod
**Date:** 2026-03-11
**Context:** [Discord thread — Ideal Approval Screen](https://discord.com/channels/1479269120334762008/1481392726070005770)

---

## Problem

The person approving a deploy is answering one question: **"Should this go live?"**

That's not a code review. It's a trust decision. But today, every approval tool — GitHub, GitLab, internal dashboards — treats the approver like a code reviewer. Diffs, file trees, syntax highlighting. On desktop, that's tolerable. On mobile, it's unusable.

The result: approvals bottleneck on "when the approver is at their laptop." Deploy velocity drops. Teams build workarounds (auto-approve, skip gates). The gate that was supposed to create accountability becomes a speed bump people route around.

**PP's opportunity:** Own the approval moment. Make it so fast and clear that approvers *prefer* doing it from their phone. A 5-second approval from a coffee line beats a 5-minute approval at a desk.

---

## Design Principles

1. **Decision-first, not data-first.** The screen answers "should this go live?" — not "what changed in the code."
2. **Glanceable trust.** Risk, test status, author reputation — all visible without scrolling. If I need to scroll to decide, we've failed.
3. **One-tap default path.** 90% of approvals should be a single tap. The remaining 10% (high-risk, production, unfamiliar author) earn friction.
4. **Progressive disclosure.** Summary → signals → details. Each layer is optional. Most approvers never go past the summary.
5. **Mobile-native, not mobile-adapted.** Designed for thumb reach zones, variable network, interruption-heavy contexts. Not a desktop layout squeezed into 390px.

---

## User Persona

**The Approver** — VP Eng, Team Lead, Senior Dev, or Ops Lead.

- Gets a push notification while doing something else
- Has 10–30 seconds of attention, not 10 minutes
- Understands the system but isn't reading diffs on their phone
- Trusts the process (tests, reviews) more than their own code reading
- Approves 5–15 requests/week, mostly routine
- Wants to feel confident, not thorough

---

## Screen Anatomy (Top → Bottom)

### Layer 0: Push Notification

Before the screen, there's the notification. This is the first impression.

```
Permission Protocol
🟡 Deploy request: "Add rate limiting to /auth"
staging → production · medium risk · 2 min ago
[Approve]  [View]
```

**Requirements:**
- Rich notification with inline action buttons (iOS/Android)
- **Approve** button works directly from notification for low-risk, non-production requests
- **View** deep-links to the approval screen (not a dashboard, not a list)
- Environment + risk visible in the notification body
- Notification groups by org (don't spam with individual pings)

---

### Layer 1: Identity Strip (Fixed Header)

The "who and where" context. Always visible.

```
┌─────────────────────────────────────┐
│ 👤 Sarah Chen        2 min ago      │
│ 🔴 PRODUCTION    permission-protocol/app │
└─────────────────────────────────────┘
```

**Fields:**
| Field | Source | Notes |
|-------|--------|-------|
| Requester avatar + name | GitHub profile | Humanizes the request |
| Time since request | Request timestamp | "2 min ago", not "2026-03-11T14:32:00Z" |
| Environment badge | Deploy request metadata | Color-coded: 🔴 Production, 🟡 Staging, 🔵 Dev |
| Repository | Deploy request metadata | `org/repo` format, truncated if needed |

**Environment badge behavior:**
- **Production** — Red background, bold. Unmissable.
- **Staging** — Yellow/amber outline. Notable but not alarming.
- **Dev/Preview** — Blue/grey outline. Routine.

---

### Layer 2: AI Summary Card

The core decision surface. This replaces the diff.

```
┌─────────────────────────────────────┐
│                                     │
│  Adds rate limiting to the /auth    │
│  endpoint (100 req/min per IP).     │
│  No database migrations. No API     │
│  contract changes.                  │
│                                     │
│  Risk: 🟡 Medium                    │
│  "Touches authentication logic"     │
│                                     │
│  Blast radius: Login flow,          │
│  API consumers, mobile app          │
│                                     │
└─────────────────────────────────────┘
```

**Fields:**
| Field | Source | Notes |
|-------|--------|-------|
| Summary | AI-generated from diff | 2-3 sentences max. Plain English, no jargon. |
| Risk score | AI analysis + heuristics | Low 🟢 / Medium 🟡 / High 🔴 with one-line rationale |
| Blast radius | AI analysis of affected surfaces | What user-facing things could break |

**Risk scoring heuristics (v1):**
- Files touched in `/auth`, `/payments`, `/admin` → bump risk
- Database migrations present → bump risk
- >500 lines changed → bump risk
- Only test files changed → lower risk
- Author's recent deploy history (rollbacks?) → factor in
- Environment (production > staging > dev) → multiplier

**AI Summary requirements:**
- Must state what the change *does*, not what files it touches
- Must call out dangerous operations explicitly: migrations, env var changes, permission changes, dependency upgrades
- Must flag if the summary couldn't be generated (e.g., binary files, massive diff) — show "Summary unavailable" with file count instead of hallucinating
- Regenerate if code changes after summary was created (stale detection)

---

### Layer 3: Trust Signals

The checklist that lets you approve without reading code.

```
┌─────────────────────────────────────┐
│  ✅  Tests passing (47/47)          │
│  ✅  2 peer reviews (GitHub)        │
│  ✅  No secrets detected            │
│  ⚠️  No staging deploy yet          │
│  ✅  Author: 12 clean deploys       │
└─────────────────────────────────────┘
```

**Signal types (v1):**
| Signal | Source | States |
|--------|--------|--------|
| CI status | GitHub Checks API | ✅ Pass / ❌ Fail / ⏳ Running / ⚪ None |
| Peer reviews | GitHub PR reviews | ✅ N approved / ⚠️ Changes requested / ⚪ None |
| Secret scanning | GitHub / custom | ✅ Clean / 🔴 Detected |
| Staging deploy | PP deploy history | ✅ Deployed / ⚠️ Skipped |
| Author track record | PP approval history | ✅ N clean / ⚠️ Recent rollback / ⚪ New author |

**Behavior:**
- Each signal is tappable → expands to detail (test names, reviewer names, etc.)
- Signals with warnings (⚠️) appear above green signals
- Failed signals (❌) appear first and are visually prominent
- If CI is still running, show spinner + "Tests running (est. 3 min)" with live updates
- If any signal is ❌ (tests failing), the Approve button should require a confirmation step

---

### Layer 4: Action Buttons (Fixed Footer)

The decision point. Always visible, always reachable by thumb.

```
┌─────────────────────────────────────┐
│                                     │
│  ┌───────────────────────────────┐  │
│  │        ✅  APPROVE            │  │
│  └───────────────────────────────┘  │
│                                     │
│       Reject  ·  Delegate  ·  ...   │
│                                     │
└─────────────────────────────────────┘
```

**Approve button:**
- Full-width, prominent green. Thumb-zone optimized (bottom of screen).
- **Low risk + non-production:** Single tap. Instant. Haptic feedback + animation.
- **High risk OR production:** Swipe-to-confirm or hold-to-confirm (1s). Adds intentionality without a modal.
- **Tests failing:** Tap opens a confirmation: "Tests are failing. Approve anyway?" with a text field for justification.

**Secondary actions (smaller, below Approve):**
- **Reject** — Opens a quick-reply sheet. Pre-populated suggestions: "Not ready", "Needs tests", "Wrong branch". Free text + voice-to-text.
- **Delegate** — "Send to [person]" — reassign to another approver.
- **Snooze** — "Remind me in 30 min / 1 hour / tomorrow" — for when you need more context but don't want to reject.
- **Comment** — Add a note without approving or rejecting.

**Post-action feedback:**
- Approve → screen transitions to confirmation: "Approved ✅ — merging..." with a 5-second undo window
- Reject → "Rejected. [Author] notified." with option to add more context
- All actions produce a UAR (Universal Action Receipt) with a shareable proof link

---

### Layer 5: Below the Fold (Expandable Detail)

For the 10% who want to dig deeper. Never required for the decision.

**Sections (collapsed by default):**

**Changed Files**
```
  📄 src/middleware/rate-limit.ts  (+82, -3)   NEW
  📄 src/routes/auth.ts           (+4, -1)
  📄 tests/rate-limit.test.ts     (+45)        NEW
```
- Tappable → shows inline diff (syntax-highlighted, light mode)
- Not a full diff viewer. Shows the "interesting" hunks, not everything.

**Visual Preview** (if frontend changes detected)
- Side-by-side screenshot: before → after
- Swipeable comparison (like those design before/after sliders)
- Only shown for changes to UI routes/components
- Generated by PP's preview pipeline (Vercel preview deploy screenshots, or headless browser captures)

**Audit Trail**
- Previous approvals for this PR (if re-requested)
- Related deploys (same repo, last 7 days)
- Who else was requested to review

**Full PR Link**
- "View on GitHub →" — the escape hatch
- Should rarely be needed if the summary and signals are doing their job

---

## Batch Mode ("Deploy Stack")

When multiple requests are pending, don't show a list — show a swipeable stack.

```
┌─────────────────────────────────────┐
│  3 pending approvals                │
│                                     │
│  ┌─────────────────────────┐        │
│  │  [Approval Card 1]      │ ←swipe │
│  └─────────────────────────┘        │
│                                     │
│  ● ○ ○   (pagination dots)          │
│                                     │
│  ┌───────────────────────────────┐  │
│  │     ✅  APPROVE               │  │
│  └───────────────────────────────┘  │
│  Approve All (3) · Skip · Reject    │
└─────────────────────────────────────┘
```

**Behavior:**
- Swipe left = next request. Swipe right = previous.
- "Approve All" available only when ALL requests are low-risk + non-production
- Each card is a condensed version of the full approval screen
- Approving one advances to the next automatically

---

## Stale & Conflict Handling

**Stale summary:**
```
⚠️ Code updated 4 min after this summary was generated.
Summary may be outdated. [Regenerate]
```
- Yellow banner at top of AI Summary card
- Shows when PR HEAD SHA ≠ the SHA the summary was generated from
- "Regenerate" triggers a new AI analysis and refreshes the card

**Merge conflicts:**
```
🔴 This PR has merge conflicts.
Cannot merge until conflicts are resolved.
[Notify Author]
```
- Approve button disabled (greyed out)
- "Notify Author" sends a ping via PP + GitHub

**Superseded request:**
```
ℹ️ A newer deploy request exists for this PR.
[View Latest]
```
- When a new push creates a new request, the old one shows this banner
- Tapping "View Latest" navigates to the current request

---

## Technical Architecture

### Data Flow

```
GitHub PR event
    ↓
PP API (receives webhook via GitHub App)
    ↓
AI Summary Pipeline (async)
    ├── Fetch diff via GitHub API (installation token)
    ├── Generate summary (LLM — configurable model)
    ├── Score risk (heuristics + LLM)
    ├── Identify blast radius
    └── Store result on deploy request record
    ↓
Push Notification (FCM / APNs via web push or future native app)
    ↓
Mobile Web Screen (permissionprotocol.com/review/[id])
    ↓
Approve action → PP API → GitHub merge API → UAR generated
```

### Implementation Approach

**Phase 1: Mobile Web (PWA)** — Not a native app.
- Responsive Next.js page, optimized for mobile viewports
- Web Push API for notifications (Chrome, Safari 16.4+, Firefox)
- Add-to-homescreen (PWA manifest) for app-like experience
- Service worker for offline queuing (approve offline, sync when connected)

**Phase 2: Native wrapper (if needed)**
- Capacitor or React Native shell around the web view
- Only if web push limitations become a real blocker
- Rich notifications with inline actions require native

### API Endpoints (new or modified)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/requests/:id/summary` | GET | Fetch AI summary for a deploy request |
| `/api/requests/:id/summary` | POST | Regenerate summary |
| `/api/requests/:id/signals` | GET | Fetch trust signals (CI, reviews, etc.) |
| `/api/requests/:id/approve` | POST | Approve with optional comment |
| `/api/requests/:id/reject` | POST | Reject with reason |
| `/api/requests/:id/delegate` | POST | Reassign to another approver |
| `/api/requests/:id/snooze` | POST | Snooze with duration |
| `/api/author/:id/track-record` | GET | Author's deploy history stats |
| `/api/notifications/subscribe` | POST | Register push subscription |

### AI Summary Pipeline

**Input:** GitHub diff (via API, not git clone)
**Model:** Configurable per org. Default: fast model (Gemini Flash / GPT-4o-mini) for summary, heavier model for risk scoring on high-change PRs.
**Latency target:** Summary available within 30 seconds of PR event.
**Caching:** Summary cached per commit SHA. Invalidated on new push.
**Fallback:** If AI summary fails, show structured metadata (files changed, lines added/removed, CI status) without natural language summary.

---

## Phased Rollout

### Phase 1 — Core Screen (Week 1-2)
- [ ] Mobile-optimized `/review/[id]` page
- [ ] Identity strip with environment badge
- [ ] AI summary card (summary + risk + blast radius)
- [ ] Trust signals (CI status, review count, secret scan)
- [ ] Approve/Reject buttons with appropriate friction levels
- [ ] Post-action confirmation with undo window
- [ ] Deep-link from existing notification channels (Discord, email)

### Phase 2 — Intelligence (Week 3-4)
- [ ] AI summary pipeline (diff → summary → risk score)
- [ ] Author track record calculation
- [ ] Stale summary detection + regeneration
- [ ] Visual preview for frontend changes
- [ ] Batch mode (swipeable stack)

### Phase 3 — Notifications (Week 5-6)
- [ ] Web Push notification registration
- [ ] Rich push notifications with inline Approve action
- [ ] PWA manifest + add-to-homescreen prompt
- [ ] Notification preferences (which envs, which repos, quiet hours)
- [ ] Snooze + delegation

### Phase 4 — Polish (Week 7-8)
- [ ] Offline approve + sync
- [ ] Swipe-to-confirm for production deploys
- [ ] Haptic feedback patterns
- [ ] Audit trail section
- [ ] Comment without decision
- [ ] Superseded request handling

---

## Success Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| Median approval time (tap notification → approved) | < 8 seconds | The coffee-sip test |
| % of approvals from mobile | > 40% within 3 months | Proves the mobile experience works |
| Approval-to-merge latency | < 2 minutes | Approve → merge should feel instant |
| Push notification → action rate | > 60% | People act on PP notifications, not ignore them |
| Approver NPS | > 50 | Approvers like using this |
| Rejection rate with reasons | > 80% of rejections include a reason | The reject UX makes it easy to explain why |

---

## What We're NOT Building

- **Full diff viewer for mobile.** If you need to read every line of code, go to your laptop. We're not competing with GitHub's diff view.
- **Native app (Phase 1).** PWA first. Native only if push notification limitations force it.
- **Approval chains/workflows.** Single approver for v1. Sequential/parallel chains are Phase 2+.
- **Org-wide analytics dashboard.** This PRD is about the approval *moment*, not reporting.
- **Custom risk rules.** AI + heuristics for v1. User-configurable rules later.
- **Chat/comments thread.** A comment field, yes. A full conversation thread, no. That's GitHub's job.

---

## Open Questions

1. **Swipe-to-confirm vs hold-to-confirm for production?** Swipe feels more intentional. Hold is more standard (Apple Pay pattern). Need to prototype both.
2. **How much AI summary context is too much?** 2-3 sentences feels right, but some changes might need more. Should there be an "expand summary" option?
3. **Notification-level approve (without opening app) — how far do we go?** iOS/Android have different capabilities. Actionable notifications are powerful but require native push infrastructure.
4. **Author track record — privacy implications?** Showing "this author had a rollback last week" is useful but could feel surveillant. Need to frame it as system health, not performance review.
5. **Offline approve queue — conflict resolution?** If you approve offline and the PR was already merged/closed by the time you reconnect, what happens? Silent discard + notification?

---

## Appendix: Competitive Landscape

| Product | Mobile Approval? | Trust Signals? | AI Summary? |
|---------|-----------------|----------------|-------------|
| GitHub Mobile | PR review, not deploy approval | CI status only | No |
| GitLab | Basic MR approval | Some | No |
| Sleuth | Deploy tracking, no approval | Yes (DORA metrics) | No |
| LinearB | No mobile approval | Yes (review analytics) | No |
| Vercel | Deploy preview, no approval gate | Build status | No |
| **Permission Protocol** | **Purpose-built** | **Comprehensive** | **Core feature** |

Nobody is building an approval *experience*. Everyone treats it as a checkbox in a larger workflow. That's the gap.
