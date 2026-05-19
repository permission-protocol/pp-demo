# Dispatch V1 PRD — Daily Human-in-the-Loop Content Action Launcher

**Status:** Draft ready for implementation  
**Owner:** Rod / Charles  
**Created:** 2026-05-19  
**Target build:** V1 internal tool  
**Primary surface:** Web UI, with Discord only as a doorbell  

---

## 1. Summary

Dispatch is a simple daily cockpit for founder-led public engagement.

Rod opens Dispatch once per day, clicks **Generate Today's Batch**, reviews 3-7 high-value actions across platforms, and clears them in one focused session. Charles generates drafts on demand from fresh signals. For platforms with safe APIs, Dispatch can publish directly after approval. For HN, LinkedIn, Reddit, and Medium, Dispatch prepares Rod's real logged-in browser, fills the form, then stops before final submit.

The product exists to solve a specific recurring failure: we post/comment in bursts, then go quiet for weeks because the work is scattered across Discord, HN, LinkedIn, X, Reddit, docs, and memory. Discord notifications are not enough; they mix with everything else and get dropped. Dispatch gives the work a single-purpose home.

**Core principle:** AI prepares actions. Rod approves and submits. The system tracks what shipped, what expired, and what worked.

---

## 2. Problem Statement

Rod needs consistent public engagement around Permission Protocol and adjacent AI governance/security topics, but the current workflow fails in three ways:

1. **No single source of truth** — ideas live across Discord channels, HN screenshots, memory files, PP docs, and chat threads.
2. **Notification stream failure** — Discord is useful for alerts but poor for accountability; high-value posting opportunities get buried.
3. **Final-mile friction** — even when Charles drafts good content, Rod still has to find the thread, open the platform, paste, format, and submit. That friction causes ghost periods.

The result is a visible pattern: post/comment today, disappear for weeks, then come back and trigger platform/account suspicion.

Dispatch should create a daily ritual that makes public engagement boringly reliable without making Rod look automated.

---

## 3. Goals

### Product Goals

- Give Rod a single place to clear the day's highest-value public engagement actions.
- Generate drafts fresh on demand, not via stale daily content cron.
- Preserve human control over public posting, especially on platforms hostile to automation.
- Reduce final-mile posting friction to seconds per action.
- Track completion and account health so we do not repeat the HN flagged-account pattern.
- Build a reusable human-in-the-loop action workflow that mirrors Permission Protocol's broader thesis.

### Behavioral Goals

- Rod opens Dispatch 4+ days/week.
- Rod completes 3+ meaningful public actions/week.
- Dispatch produces small batches Rod can actually clear in 15-25 minutes.
- Skipping low-quality opportunities feels like success, not failure.

### Business Goals

- Increase PP surface area in relevant technical and enterprise conversations.
- Build credibility without spammy cross-posting.
- Convert high-signal content into outreach assets and future blog material.
- Grow HN karma/account trust safely over time.

---

## 4. Non-Goals

V1 is **not**:

- A full social media management platform.
- A content calendar.
- A growth-hacking automation tool.
- A Medium/Reddit/LinkedIn auto-poster.
- A CRM.
- A replacement for Rod's judgment.
- A system that posts from personal accounts without Rod's final action.

V1 should not optimize for volume. It should optimize for consistency, freshness, safety, and low friction.

---

## 5. Target User

### Primary User

**Rod** — founder/operator of Permission Protocol. Technically fluent, strategic, busy, gets distracted by higher-priority product/deployment work. Wants leverage, not another dashboard.

### Secondary User

**Charles** — AI assistant / operator. Generates drafts, detects opportunities, prepares browser actions, logs results.

### Future Users, Not V1

- VA / comms assistant.
- Founding marketer.
- Other founders with similar human-in-the-loop posting needs.

---

## 6. Product Thesis

The right interface is not a notification feed and not an infinite dashboard.

The right interface is a **daily batch run**:

> Open once. Generate fresh. Clear 3-7 actions. Leave.

Content should be generated on demand from current signals. Background systems should collect signals, not create finished drafts that rot.

---

## 7. Key Design Decisions

### 7.1 On-demand generation, not content cron

Dispatch should not create daily drafts automatically. Cron-created drafts become stale and create guilt.

Instead:

- Background jobs collect **signals**.
- Rod opens Dispatch and presses **Generate Today's Batch**.
- Charles uses fresh platform state + saved signals to generate a current batch.

### 7.2 Web UI as source of truth

Discord is only the doorbell:

- "Today's Dispatch is ready."
- "Breaking HN opportunity expires in 42 minutes."
- "Chrome tab prepared — hit Submit."

The actual queue, drafts, states, and history live in the Dispatch UI.

### 7.3 Human final-submit for risky platforms

For HN, LinkedIn personal, Reddit, and Medium:

- Dispatch/Charles opens Rod's real browser profile.
- Navigates to the correct composer/thread.
- Fills the draft.
- Shows a screenshot.
- Stops before submit.
- Rod clicks the final platform button.

This preserves account safety and avoids non-human login patterns.

### 7.4 Small capped batches

Default daily batch cap: 3-7 total actions.

Suggested caps:

- HN: 0-2 actions/day
- X: 1-2 actions/day
- LinkedIn: 0-1 action/day, 2-3x/week max
- Reddit: 0-1 action/day only when genuinely native
- Blog/Medium: 0-1 draft/week, usually derived from a winning prior idea

### 7.5 Skipping is a first-class outcome

If there is no high-quality HN opportunity, Dispatch should say:

> Skip HN today — nothing worth touching.

This avoids forced thought leadership.

---

## 8. V1 Scope

### Included

1. Web UI: Today's Dispatch batch view.
2. On-demand **Generate Today's Batch** action.
3. Background signal collection.
4. Platform grouping: HN, X, LinkedIn, Reddit, Blog/Medium.
5. Draft review: approve, edit, skip, kill.
6. Browser prep flow for manual-submit platforms.
7. X API auto-posting where safe.
8. State tracking: draft, approved, prepared, submitted, verified, expired, skipped, killed, error.
9. Staleness/expiry handling.
10. Platform safety rules and cooldowns.
11. Basic outcome logging.
12. Discord doorbell alerts for urgent/breaking items only.

### Excluded from V1

- Full analytics dashboard.
- Full calendar view.
- Automated posting to LinkedIn personal / HN / Reddit.
- Multi-user roles.
- Team approval flow.
- Long-form editor for blog posts beyond draft generation + copy/open.
- AI voice scoring beyond simple warnings.
- CRM/outreach integration.

---

## 9. Core User Journey

### 9.1 Daily Batch Run

1. Rod opens `dispatch.permissionprotocol.com`.
2. UI shows:
   - Last run date.
   - Account health summary.
   - Button: **Generate Today's Batch**.
3. Rod clicks button.
4. Dispatch scans fresh inputs and saved signals.
5. Dispatch returns 3-7 platform-grouped actions with estimated completion time.
6. Rod reviews each action:
   - Edit draft if needed.
   - Skip if low-value.
   - Approve if good.
7. For X:
   - Dispatch can schedule/post via API after approval.
8. For HN/LinkedIn/Reddit/Medium:
   - Rod clicks **Prepare in Chrome**.
   - Charles fills Rod's real browser.
   - Dispatch shows screenshot/status.
   - Rod clicks final submit on the platform.
9. Dispatch verifies or asks Rod to confirm.
10. End screen shows:
   - Posted/commented.
   - Skipped.
   - Expired/missed.
   - Follow-up opportunities.

### 9.2 Breaking HN Opportunity

1. Background signal collector sees relevant HN thread cross threshold.
2. Dispatch creates a signal, not a draft.
3. If the signal is high-confidence and time-sensitive, Discord doorbell pings Rod.
4. Rod opens Dispatch.
5. Dispatch generates a single breaking action or adds it to today's batch.
6. Rod approves/prepares/submits.
7. Dispatch logs outcome and monitors replies.

### 9.3 Weekly Review

1. Dispatch shows weekly summary:
   - Actions completed.
   - Skipped opportunities.
   - Expired opportunities.
   - Best performing items.
   - Overused topic warnings.
2. Charles suggests next week's content bias:
   - More short HN comments.
   - Fewer PP-direct framings.
   - More adjacent/non-campaign topics.

---

## 10. Platform Strategy

### 10.1 Hacker News

**Goal:** Build karma/account trust and participate in high-signal technical conversations.

**Rules:**

- No automated posting.
- Prefer comments over submissions until account trust stabilizes.
- Max 2 HN actions/day.
- Avoid single-topic campaign pattern.
- Use shorter, specific, question-driven comments.
- Add 30-40% adjacent/non-PP content over time.
- Cooldown after flags.

**Browser flow:**

- Open thread/reply URL in Rod's real Chrome profile.
- Fill comment.
- Screenshot filled form.
- Rod clicks reply.

### 10.2 X

**Goal:** Maintain public pulse and create fast observations.

**Rules:**

- Use API auto-posting only where keys and account posture are safe.
- Avoid burst posting.
- 1-2 posts/replies per day max in V1.
- Schedule rather than posting everything immediately after batch approval.

### 10.3 LinkedIn

**Goal:** Enterprise/founder credibility, not technical comment wars.

**Rules:**

- No automated personal-account posting.
- 2-3 higher-quality actions/week.
- Founder voice, not corporate thought leadership.
- Prefer posts grounded in specific build/market observations.

### 10.4 Reddit

**Goal:** Only participate where native and useful.

**Rules:**

- Default skip.
- Avoid obvious promotional behavior.
- No automation.
- Only comment when thread is highly relevant and the comment would stand alone without PP context.

### 10.5 Blog / Medium

**Goal:** Expand winning ideas, not daily publishing.

**Rules:**

- Not part of daily volume target.
- Trigger from proven signal: HN comment performed, X post resonated, repeated customer question.
- Draft only in V1; publishing remains manual.

---

## 11. Signal Sources

Dispatch should collect and index signals from:

1. HN Algolia API:
   - Trending/new threads.
   - Keywords around AI agents, MCP, prompt injection, authorization, governance, enterprise AI, agent security.
2. Discord channels:
   - `#hackernews`.
   - `#1479273617689809097` and other approved PP/source channels.
   - Relevant strategy/product discussions.
3. Workspace docs:
   - PP decisions.
   - Launch notes.
   - Runbooks.
   - Outreach logs.
   - Previous high-performing comments.
4. Platform history:
   - Last post dates.
   - Recent topics.
   - Flag/account warnings.
5. Manual capture:
   - Rod can paste a link or note into Dispatch and ask it to generate actions.

Signals should store source attribution so drafts do not feel generic.

---

## 12. Functional Requirements

### 12.1 Generate Today's Batch

- User can click **Generate Today's Batch**.
- System scans signals and fresh platform state.
- System returns a capped list of actions grouped by platform.
- Each action includes:
  - Platform.
  - Draft content.
  - Source attribution.
  - Why this action matters.
  - Expiry/cooldown info.
  - Estimated time.
  - Safety warnings if applicable.

### 12.2 Action Review

For every action, user can:

- Approve.
- Edit.
- Skip.
- Kill.
- Regenerate.
- Prepare in Chrome.

### 12.3 Browser Prep

System can prepare a post/comment using Rod's logged-in browser profile.

Browser prep must return a visible state:

- `ready_to_submit`
- `login_required`
- `platform_changed`
- `target_missing`
- `content_too_long`
- `rate_limited`
- `unknown_error`

Each state should include a cropped screenshot when possible.

### 12.4 Completion Tracking

Actions have explicit lifecycle states:

- `signal`
- `draft`
- `approved`
- `scheduled`
- `prepared`
- `submitted`
- `verified`
- `skipped`
- `expired`
- `killed`
- `error`

A prepared item is not done. It is done only when submitted/verified.

### 12.5 Safety Rules

System enforces:

- Per-platform daily caps.
- Cooldowns after flags or suspicious activity.
- Duplicate content detection.
- Topic repetition warnings.
- Character limits.
- Expiry windows.
- No auto-posting to HN/LinkedIn personal/Reddit.

### 12.6 Doorbell Alerts

Discord alerts are allowed only for:

- Today's batch ready reminder.
- High-confidence breaking opportunity.
- Prepared browser ready to submit.
- Expiring high-value action.
- Browser/login blocker.

No full draft dumps into Discord by default.

---

## 13. Data Model

### 13.1 Signal

```ts
type Signal = {
  id: string;
  source: 'hn' | 'discord' | 'workspace' | 'manual' | 'platform_history';
  sourceUrl?: string;
  sourceChannelId?: string;
  sourceMessageId?: string;
  title: string;
  summary: string;
  rawExcerpt?: string;
  detectedAt: string;
  expiresAt?: string;
  tags: string[];
  relevanceScore: number;
  urgency: 'breaking' | 'normal' | 'evergreen';
  status: 'new' | 'used' | 'ignored' | 'expired';
};
```

### 13.2 Dispatch Action

```ts
type DispatchAction = {
  id: string;
  batchId: string;
  platform: 'hn' | 'x' | 'linkedin' | 'reddit' | 'medium';
  actionType: 'post' | 'comment' | 'reply' | 'draft_article';
  title?: string;
  body: string;
  targetUrl?: string;
  sourceSignalIds: string[];
  why: string;
  estimatedMinutes: number;
  status:
    | 'draft'
    | 'approved'
    | 'scheduled'
    | 'prepared'
    | 'submitted'
    | 'verified'
    | 'skipped'
    | 'expired'
    | 'killed'
    | 'error';
  urgency: 'breaking' | 'today' | 'evergreen';
  expiresAt?: string;
  cooldownUntil?: string;
  safetyWarnings: string[];
  createdAt: string;
  updatedAt: string;
};
```

### 13.3 Batch

```ts
type DispatchBatch = {
  id: string;
  date: string;
  generatedAt: string;
  status: 'open' | 'completed' | 'partially_completed' | 'expired';
  estimatedMinutes: number;
  actionIds: string[];
  completedCount: number;
  skippedCount: number;
  expiredCount: number;
};
```

### 13.4 Account Health

```ts
type AccountHealth = {
  platform: 'hn' | 'x' | 'linkedin' | 'reddit' | 'medium';
  lastActionAt?: string;
  dailyActionCount: number;
  weeklyActionCount: number;
  flagsOrWarnings: number;
  cooldownUntil?: string;
  notes: string[];
};
```

---

## 14. UX Requirements

### 14.1 Home Screen

Home screen must answer:

> What should Rod do today?

Required elements:

- Date and batch status.
- Generate button.
- Estimated time.
- Account health summary.
- Platform sections.
- Clear "skip" states.
- No infinite feed.

### 14.2 Action Card

Each card shows:

- Platform.
- Action type.
- Draft body.
- Source attribution.
- Why now.
- Expiry/cooldown.
- Safety warnings.
- Buttons: Approve, Edit, Skip, Kill, Prepare in Chrome.

### 14.3 End Screen

After batch completion:

- Completed actions.
- Skipped actions.
- Expired/missed actions.
- Any required manual follow-up.
- Next suggested check-in.

---

## 15. Technical Architecture

Recommended V1 stack:

- **Frontend:** Next.js or Vite React.
- **Auth:** Google SSO restricted to Rod.
- **Database:** Firebase Firestore.
- **Functions:** Firebase Cloud Functions or OpenClaw cron-backed API endpoints.
- **Browser prep:** OpenClaw browser tool with `profile="user"` where safe.
- **Signal collection:** scheduled background jobs writing signals, not drafts.
- **Discord doorbell:** existing OpenClaw message integration.

### Suggested Deployment

- `dispatch.permissionprotocol.com`.
- Private/internal auth gate.
- No public indexing.

---

## 16. Edge Cases and Required Handling

### Browser / Platform Edge Cases

- Login expired → show `login_required` with screenshot.
- 2FA or identity challenge → stop and ask Rod to complete manually.
- Platform UI changed → show `platform_changed`; do not retry blindly.
- Target thread deleted → mark `target_missing` and expire action.
- Content too long → block prepare until edited.
- Platform reformats content → screenshot post-fill before submit.
- Rod closes tab mid-fill → mark `error`, allow retry.
- Duplicate draft → warn/block.

### Behavioral Edge Cases

- Rod ignores Dispatch for 3 days → no pile of old drafts; generate fresh next time.
- Batch too large → hard cap to 7 actions.
- Too much PP topic repetition → warn and insert adjacent/personal-founder topics.
- HN flagged account → enforce cooldown and recommend unrelated comments.
- Discord alert ignored → no repeated nag loops; one reminder max.

---

## 17. Success Metrics

### Activation

- Rod opens Dispatch 4+ days/week.
- Rod completes first batch within 24h of V1 launch.
- Average batch completion time under 25 minutes.

### Output Quality

- 3+ meaningful public actions/week.
- At least 30% non-direct-PP/adjacent content mix.
- HN karma stable or increasing; no new flags from obvious campaign behavior.

### Operational

- Less than 10% browser-prep attempts fail silently. Target: 0 silent failures.
- Every action has explicit final state.
- No stale drafts older than expiry in active queue.

### Business Signal

- At least 1 useful reply/conversation per week.
- At least 1 post/comment per week reusable for outreach or blog expansion.

---

## 18. Customer Test Gate

Before calling V1 successful, Rod should complete this test:

1. Open Dispatch once in the morning.
2. Generate a batch.
3. Complete at least 3 actions across at least 2 platforms.
4. Use Prepare in Chrome for at least 1 HN or LinkedIn action.
5. Submit manually.
6. Verify Dispatch logs the result.
7. Return the next day and generate a fresh batch without stale backlog guilt.

Pass condition:

> Rod says, "This is easier than doing it manually, and I can see myself opening it tomorrow."

---

## 19. Phased Roadmap

### V0 — PRD and Manual Prototype

- Use this PRD.
- Manually generate one batch in chat.
- Validate action caps and platform grouping.

### V1 — Internal Daily Dispatch

- Web UI.
- On-demand batch generation.
- Signal storage.
- Manual-submit browser prep.
- X API posting if keys are confirmed.
- Discord doorbell.
- Completion states.

### V1.5 — Learning Loop

- Weekly review.
- Basic performance metrics.
- Topic repetition analysis.
- HN account health scoring.

### V2 — Repurposing and Outreach Integration

- Turn winning HN/X comments into LinkedIn/blog drafts.
- Link posts to outreach targets.
- Draft replies to useful comments.
- Add VA/future-hire handoff mode.

---

## 20. Open Questions

1. Should X posting use Rod's personal account, PP company account, or both?
2. Should Dispatch live inside the PP app repo or as a standalone internal app?
3. Which Discord channels are approved signal sources beyond `#hackernews` and `#1479273617689809097`?
4. Should `dispatch.permissionprotocol.com` be private behind Google auth or Tailscale-only?
5. Should browser prep be initiated from the server via OpenClaw only, or via a small local Chrome companion later?
6. What is the daily ritual time? Morning default seems best.

---

## 21. Recommendation

Build V1 as a **simple daily action cockpit**, not a social CMS.

The strongest version is:

- On-demand generation.
- Background signal collection.
- 3-7 capped daily actions.
- Human final-submit via prepared browser.
- Explicit states and cooldowns.
- Discord only for doorbell alerts.

This directly addresses the recurring failure pattern without creating a content treadmill or risking account bans.

---

## 22. Implementation Acceptance Criteria

V1 implementation is complete when:

- Rod can authenticate into Dispatch.
- Rod can click **Generate Today's Batch**.
- Dispatch returns capped grouped actions with source attribution.
- Rod can approve/edit/skip/kill each action.
- Rod can prepare at least one HN/LinkedIn action in Chrome.
- Browser prep stops before submit and returns screenshot/state.
- Dispatch tracks submitted/verified/skipped/expired states.
- Background collector writes signals but not finished drafts.
- Discord sends only doorbell alerts.
- Weekly summary can be generated from action history.

---

*This PRD intentionally prioritizes behavior change over feature count. The product wins if Rod opens it daily and clears a small useful batch. Everything else is optional.*
