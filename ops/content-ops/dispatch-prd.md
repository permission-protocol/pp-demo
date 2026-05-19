# Dispatch V1 PRD — Daily Human-in-the-Loop Content Action Launcher

**Status:** Draft ready for implementation  
**Owner:** Rod / Charles  
**Created:** 2026-05-19  
**Target build:** V1 internal tool  
**Primary surface:** Web UI, with Discord only as a doorbell  

---

## 1. Summary

Dispatch is a simple daily cockpit for founder-led public engagement.

Rod opens Dispatch once per day, clicks **Generate Today's Batch**, reviews 3-7 high-value actions across platforms, and clears them in one focused session. Charles generates drafts on demand from fresh signals. For V1A-0, all personal-account posting is human-final-submit. Dispatch helps Rod post from whatever computer/browser he is currently using: every action card always shows the full draft, a visible copy box, a manual target link, and a checklist before any posting action. V1B may add X API posting only after account posture is confirmed. Reddit and Blog/Medium may appear as suggestions in V1, but they are not first-class execution paths until the daily ritual proves itself.

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

- "Time to open Dispatch — generate today's batch when ready."
- "Breaking opportunity expires soon."
- "Posting action is ready — review the visible draft, open the target, submit yourself."

The actual queue, drafts, states, and history live in the Dispatch UI.

### 7.3 Human final-submit for risky platforms

For HN, X, and LinkedIn personal in V1A-0:

- Dispatch runs generation and scoring server-side.
- Posting assist runs in the browser/device Rod is currently using.
- Dispatch always shows the approved draft in a visible copy box before any posting assist.
- Dispatch always shows a manual target link.
- Dispatch may also try one-click copy and open-target helpers, but those are conveniences, not hidden steps.
- Rod pastes/reviews/submits from his own logged-in session.
- Dispatch never clicks final submit on restricted platforms.

Reddit and Blog/Medium can be surfaced as draft suggestions, but V1 should not invest in first-class execution for them until the HN/X/LinkedIn daily ritual proves itself.

This preserves account safety, lets Rod use Dispatch from any computer where he is logged into the relevant platform, and avoids non-human login patterns.

### 7.4 Small capped batches

Default daily batch cap: 3-7 total actions.

Suggested caps:

- HN: 0-1 action/day while account health is conservative; comments only; never required for batch success
- X: 1-2 manual Copy & Open actions/day in V1A-0
- LinkedIn: 0-1 manual Copy & Open action/day, 2-3x/week max
- Reddit: suggestion-only in V1; execute manually outside Dispatch if genuinely native
- Blog/Medium: suggestion-only in V1; usually derived from a winning prior idea

### 7.5 Skipping is a first-class outcome

If there is no high-quality HN opportunity, Dispatch should say:

> Skip HN today — nothing worth touching.

This avoids forced thought leadership.

### 7.6 Two-runtime architecture

Dispatch has two separate runtimes:

1. **Server/AI runtime** — collects signals, reads approved sources, scores opportunities, drafts content, tracks states, and sends doorbell alerts. This may run in OpenClaw, Firebase Functions, or another backend. It may be offline temporarily, but generation requires it to be available.
2. **Posting/browser runtime** — runs in Rod's current browser session on whatever computer he is using. This is where HN, LinkedIn, Reddit, Medium, or other logged-in sessions live. Public posting happens from Rod's trusted browser, not from a remote server.

V1 should default to local browser assistance: visible copy box, manual target link, and checklist. A future browser extension can fill forms locally, but still must not submit. OpenClaw remote browser control is an optional internal fallback, not the default product architecture.

### 7.7 Mobile posture

Mobile is a first-class review surface but not a guaranteed posting surface.

- Rod can open Dispatch on mobile, review drafts, edit, approve, skip, kill, and defer.
- V1A-0 mobile posting path is **copy + manual open**, with platform-specific caveats shown in the UI.
- If the mobile browser opens a native app or clipboard/open fails, Dispatch keeps the draft visible and offers **Defer to desktop**.
- Deferred items stay in the batch and show `deferred_to_desktop` until Rod clears them on a desktop browser.
- Mobile must not silently pretend posting assist worked.

### 7.8 Visibility-first posting

The visible copy box and manual target link are always available. They are not fallback UI.

Every action card must let Rod inspect exactly what he is about to post before clicking any helper action. Convenience helpers like clipboard copy, open-target, or future extension fill are optional layers on top of visible review, not replacements for it.

---

## 8. V1 Scope

### Included

V1A-0 is a platform-agnostic manual posting cockpit for HN/X/LinkedIn, with HN in conservative mode.

1. Web UI: Today's Dispatch batch view.
2. On-demand **Generate Today's Batch** action.
3. Background signal collection.
4. Platform grouping: HN, X, LinkedIn, plus suggestion lanes for Reddit and Blog/Medium.
5. Draft review: approve, edit, skip, kill.
6. Local posting assist for HN, X, and LinkedIn manual-submit actions: visible copy box, manual target link, optional Copy & Open helper, checklist.
7. X API auto-posting only in V1B where safe.
8. State tracking: draft, approved, ready_to_post, prepared_unconfirmed, submitted, submitted_unverified, verified, expired, skipped, killed, error.
9. Staleness/expiry handling.
10. Platform safety rules and cooldowns.
11. Basic outcome logging.
12. Discord doorbell alerts for urgent/breaking items only.
13. Content quality contract and platform-specific style checks.
14. Source classification for Discord/workspace-derived material.

### Excluded from V1

- Full analytics dashboard.
- Full calendar view.
- Automated posting to LinkedIn personal / HN / Reddit.
- First-class Reddit execution workflow.
- First-class Blog/Medium publishing workflow.
- Remote server-side posting from Rod's personal accounts.
- Browser extension form-fill automation in V1A-0.
- Multi-user roles.
- Team approval flow.
- Long-form editor for blog posts beyond draft suggestion + copy/open.
- Advanced AI voice scoring beyond the V1 style-anchor + judge pass.
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
7. For X in V1A-0:
   - Dispatch uses the same visible copy/open/manual-submit flow.
   - API posting is deferred to V1B.
8. For HN/LinkedIn:
   - Rod reviews the visible copy box and clicks **Copy & Open**.
   - Dispatch copies the draft when browser permissions allow, while keeping the visible copy box available.
   - Dispatch opens the target URL in Rod's current browser.
   - Rod pastes/reviews/submits from his own logged-in platform session.
9. Dispatch verifies the submit where possible, or asks Rod to confirm.
10. Reddit and Blog/Medium suggestions remain copy/open only in V1.
11. End screen shows:
   - Posted/commented.
   - Skipped.
   - Expired/missed.
   - Follow-up opportunities.

### 9.2 Breaking Opportunity

1. Background signal collector sees a relevant HN/X/LinkedIn opportunity cross threshold.
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

**Goal:** Build karma/account trust and participate in high-signal technical conversations without worsening account-health risk.

**V1A-0 posture:** conservative mode by default. HN is valuable but not required for daily success.

**Rules:**

- No automated posting.
- Comments only; no submissions until account trust stabilizes.
- Max 1 HN comment/day in conservative mode.
- HN lane may return `skip HN today` and still count the batch as successful.
- Require at least one adjacent/non-PP HN suggestion before showing a PP-adjacent HN suggestion, unless Rod manually captures a thread.
- Avoid single-topic campaign pattern.
- Use shorter, specific, question-driven comments.
- Add 30-40% adjacent/non-PP content over time.
- Cooldown after flags.
- Any new HN flag immediately moves HN to suggestion-only for 7 days.

**V1A-0 posting flow:**

- Show full HN draft in a visible copy box.
- Show source, why-now, score, and safety warnings.
- Provide **Copy & Open** convenience action.
- Always provide manual target link.
- Rod pastes, reviews, and clicks reply from his own logged-in HN session.

### 10.2 X

**Goal:** Maintain public pulse and create fast observations on a safer daily habit surface than HN.

**Rules:**

- V1A-0 uses visible copy box + manual target link + Copy & Open only.
- API auto-posting is V1B only, and only where keys/account posture are safe.
- Avoid burst posting.
- 1-2 posts/replies per day max in V1A-0.
- Daily batch success can be achieved with X + LinkedIn even when HN is skipped.

### 10.3 LinkedIn

**Goal:** Enterprise/founder credibility and a lower-risk cadence surface than HN, not technical comment wars.

**Rules:**

- No automated personal-account posting.
- 2-3 higher-quality actions/week.
- Founder voice, not corporate thought leadership.
- Prefer posts grounded in specific build/market observations.

### 10.4 Reddit

**Goal:** Only participate where native and useful.

**V1 posture:** suggestion-only, not a first-class execution path.

**Rules:**

- Default skip.
- Avoid obvious promotional behavior.
- No automation.
- Only comment when thread is highly relevant and the comment would stand alone without PP context.
- If a Reddit suggestion is accepted, Dispatch provides copy + target URL; Rod handles execution manually.

### 10.5 Blog / Medium

**Goal:** Expand winning ideas, not daily publishing.

**V1 posture:** suggestion-only, not a first-class execution path.

**Rules:**

- Not part of daily volume target.
- Trigger from proven signal: HN comment performed, X post resonated, repeated customer question.
- Draft ideas only in V1; publishing remains manual.
- Blog suggestions should not block the daily batch. They go to a separate "Expansion Ideas" lane.

---

## 11. Content Quality Contract

Dispatch must not produce generic AI thought leadership. Every generated action must satisfy a platform-specific contract before it can appear in the batch.

### 11.1 Global Rules

- One clear point per action.
- No product pitch unless the platform context explicitly asks for it.
- No repeated angle more than twice in a rolling 14-day window.
- Source-grounded: every draft must cite its internal source signal.
- Human-editable: keep drafts short enough that Rod can understand and improve them in under 60 seconds.
- Avoid AI-slop markers: inflated abstractions, grand conclusions, empty trios, excessive em dashes, and "the real question is"-style punditry.

### 11.2 Hacker News Contract

HN drafts should be:

- Shorter than Rod's previous long-form comments by default.
- Specific and technical.
- Grounded in one concrete implementation or failure mode.
- Written like a peer in the thread, not a whitepaper.
- Often ending with one real question.

HN drafts should avoid:

- Founder/product positioning.
- Repeating "authorization layer" language in every comment.
- Abstract enterprise framing unless the thread is already enterprise-focused.
- Manifesto comments on hot threads from a cold account.

### 11.3 X Contract

X drafts should be:

- One sharp observation.
- Self-contained.
- Under 240 characters unless a thread is explicitly approved.
- Scheduled/paced rather than burst-posted.

### 11.4 LinkedIn Contract

LinkedIn drafts should be:

- Founder/operator voice.
- Specific business consequence or market observation.
- Grounded in something Rod actually built, saw, or decided.
- No corporate "AI governance is important" sludge.

### 11.5 Reddit Contract

Reddit suggestions should be:

- Conversational and subreddit-native.
- Useful without mentioning PP.
- Default-skipped unless the thread has unusually strong fit.

### 11.6 Blog / Medium Contract

Blog suggestions should be:

- Expansions of proven ideas, not fresh daily inventions.
- Based on repeated signal: replies, customer questions, high-performing short posts, or strategic decisions.
- Separated from the daily execution batch so long-form work does not derail the daily ritual.

### 11.7 Voice and Style Mechanism

The quality contract must be enforced mechanically, not just aspirationally.

V1 requirements:

- Maintain a style-anchor corpus from Rod's best past HN comments, LinkedIn posts, X posts, and rejected drafts.
- Every generated draft uses platform-specific few-shot examples from that corpus.
- Every draft gets a lightweight judge pass before display:
  - sounds like Rod? yes/no
  - too AI/polished? yes/no
  - too campaign-y? yes/no
  - repeats recent angle? yes/no
  - one concrete point? yes/no
- Any failed judge criterion appears as a visible warning on the card.
- Rod can mark a draft `too AI`, `too long`, `too pitchy`, `good voice`, or `save as style anchor`.
- Feedback updates future generation prompts and the style-anchor set.

This mechanism is required for V1A-0. Without it, the content quality contract is not implemented.

---

## 12. Signal Sources

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
6. Adjacent/general-interest pool:
   - HN/OpenBSD/systems/security/devtools/infra/product threads Rod would plausibly comment on as a technical founder.
   - Rod-curated topics he cares about beyond PP.
   - Used to keep accounts human and avoid single-topic campaign behavior.
7. Reply/follow-up signals:
   - HN replies where available from public profile/thread checks.
   - X replies where API access exists.
   - LinkedIn reply checks are manual/deferred unless a safe source exists.

Signals should store source attribution so drafts do not feel generic.

### 12.1 Signal Collection Cadence

- HN Algolia polling: every 30-60 minutes for background signals, with backoff on rate limits.
- Manual capture: immediate.
- Workspace/source docs: on demand during batch generation, plus optional daily indexing.
- Platform history reconciliation: best-effort, platform-specific, and clearly labeled when unavailable.
- Discord source ingestion: best-effort; if Discord is unavailable, Dispatch still works from HN/manual/workspace sources.

---

## 13. Source Permissions and Classification

Dispatch will ingest internal material. That creates leakage risk. Every signal must be classified before it can influence public content.

### 13.1 Source Classes

- **Public-safe** — already public or intentionally publishable. Drafts may quote or directly reference it.
- **Internal strategic** — useful as inspiration, but must not be quoted directly. Examples: PP strategy channels, internal positioning notes, product debate.
- **Private/sensitive** — never use in external content. Examples: credentials, financial details, private family/personal content, legal details, internal incidents not intended for publication.
- **Customer/prospect** — anonymize by default. Never name a person/company unless Rod explicitly marks it public-safe.

### 13.2 Required Behavior

- Every signal stores `sourceClass`.
- Every signal stores author/source ownership where available.
- Channel-level defaults are allowed, but per-message/per-author classification overrides channel defaults.
- Draft generation may only quote `public-safe` sources written by Rod or already public.
- Draft generation may summarize `internal strategic` sources only after removing private names, sensitive operational details, and unreleased specifics.
- Collaborator-authored internal material may inspire a draft but must not be quoted or presented as Rod's thought without explicit approval.
- `private/sensitive` signals are excluded from generation.
- `customer/prospect` signals require anonymization and should default to general lessons, not anecdotes.
- If source classification is unknown, treat it as `internal strategic` and do not quote it.

---

## 14. Signal Scoring Model

Dispatch should not generate actions just because content exists. It should generate actions only when the opportunity clears a threshold.

Each candidate signal receives a score:

- **Topic relevance:** 0-5
- **Freshness:** 0-5
- **Audience value:** 0-5
- **Novelty vs recent posts:** 0-5
- **Estimated response quality:** 0-5
- **Account safety risk:** -5 to 0

Default threshold:

- `breaking`: total score >= 18 and freshness >= 4
- `today`: total score >= 15
- `suggestion-only`: total score >= 11
- below 11: ignore unless manually selected by Rod

Account safety risk should reduce score when:

- The account recently had a flagged/removed post.
- The draft repeats the same PP-adjacent angle too often.
- The platform/subreddit is hostile to promotion.
- The thread is politically charged or likely to become a flamewar.

If no candidate clears the threshold, Dispatch should explicitly recommend skipping that platform for the day.

---

## 15. Functional Requirements

### 15.1 Generate Today's Batch

- User can click **Generate Today's Batch**.
- System scans signals and fresh platform state.
- System scores candidate signals before drafting.
- System returns a capped list of actions grouped by platform.
- Each action includes:
  - Platform.
  - Draft content.
  - Source attribution.
  - Source classification.
  - Signal score and reason it cleared threshold.
  - Why this action matters.
  - Expiry/cooldown info.
  - Estimated time.
  - Safety warnings if applicable.

### 15.2 Action Review

For every action, user can:

- Approve.
- Edit.
- Skip.
- Kill.
- Regenerate.
- Copy & Open where supported.

### 15.2.1 Generation Failure and Fallback

Batch generation must degrade gracefully. Dispatch should never show a silent empty board when an upstream source fails.

Required fallback behavior:

- If HN API fails: generate from available non-HN sources and show `HN unavailable`.
- If Discord source read fails: generate from HN/manual/workspace sources and show `Discord source unavailable`.
- If workspace scan fails: generate from HN/manual/platform history and show `Workspace source unavailable`.
- If model generation fails: preserve scored signals and show `Draft generation failed — retry`.
- If model provider returns 429/529/spend-cap errors: retry once with backoff, then fall back to configured cheaper/backup model and label the batch `fallback model used`.
- If generation fails mid-batch: preserve completed actions, mark incomplete actions `generation_failed`, and allow per-action retry.
- If only weak signals exist: show explicit platform skips, not filler drafts.

Fallback message format:

> Generated from available sources only. HN unavailable. 3 actions found, 2 platforms skipped due to weak signal.

### 15.2.2 Manual Capture Fast Path

Rod can bypass the daily batch flow when he finds an opportunity himself.

Flow:

1. Rod pastes a URL or note into Dispatch.
2. Dispatch fetches available context.
3. Dispatch classifies source permissions.
4. Dispatch scores the opportunity.
5. If above threshold, Dispatch drafts an action.
6. Rod approves/edits/skips.
7. Dispatch presents visible copy box + manual target link, with optional Copy & Open convenience action.

Manual capture should work for HN threads, LinkedIn posts, X posts, Reddit threads, articles, and raw notes.

### 15.2.3 Clipboard/Open Behavior

The visible copy box and manual target link are always present.

Convenience helpers must be user-gesture driven:

- Clipboard writes only happen after Rod clicks **Copy** or **Copy & Open**.
- Opening a target URL only happens after Rod clicks **Open** or **Copy & Open**.
- If clipboard write fails, the copy box remains selected/visible for manual copy.
- If popup/open fails, the manual target link remains visible.
- Mobile browsers and native-app handoffs must show explicit caveats.

### 15.2.4 Draft Versioning

- Every edit creates a new draft version.
- Any edit after approval resets status to `draft`.
- Posting assist is allowed only for the currently approved version.
- Dispatch stores version history for debugging prompt drift and user feedback.

### 15.3 Local Posting Assist

System can assist posting from Rod's current browser/device on supported platforms. In V1A-0, this means visible copy box + manual open link + checklist, with optional one-click clipboard/open helpers. The visible copy box and manual link are always present, never just fallback. V1A-0 does not use remote browser control or automated form fill. In V1.5, a browser extension may fill forms locally, but must still stop before final submit.

Posting assist must return a visible state:

- `ready_to_post`
- `login_required`
- `challenge_required`
- `platform_changed`
- `target_missing`
- `content_too_long`
- `rate_limited`
- `forbidden_surface`
- `unknown_error`

Each state must include clear user-facing instructions. Screenshots are optional and should be avoided in V1A-0 unless strictly needed for debugging.

### 15.4 Manual Submit Verification

Dispatch must not treat local posting preparation as completion.

V1A-0 truth: without a browser extension, Dispatch usually cannot see what happened in the platform tab it opened. Verification is therefore manual by default.

V1A-0 verification flow:

1. Rod submits on the platform.
2. Rod clicks **I posted it** in Dispatch.
3. Dispatch marks the action `submitted`.
4. If Rod can paste the resulting URL/permalink, Dispatch stores it and marks `verified`.
5. If no URL is provided, Dispatch stores `submitted_unverified` or keeps `submitted` with `verification: manual`.
6. If an item remains `ready_to_post` for 45 minutes without confirmation, Dispatch shows one reminder and a **Still working** / **Mark skipped** / **I posted it** choice.

V1B may add platform-specific verification where feasible, but it must be explicitly enumerated per platform.

### 15.5 Posting Assist Safety Model

Posting assist is an authority boundary. The automation may prepare text and open the target surface, but it must not take final public action on restricted platforms.

Rules:

- Never click final submit/post/reply on HN, LinkedIn personal, Reddit, or Medium.
- Never enter credentials or handle 2FA.
- Never interact with DMs, inboxes, account settings, payments, ad managers, or security pages.
- Stop immediately on login walls, identity challenges, CAPTCHA, permission prompts, or unexpected modals.
- V1A-0 should avoid screenshots by default; if screenshots are later used, capture/crop only the active composer area and avoid unrelated tabs or personal content.
- Log platform, target URL, action ID, final state, and timestamp for every posting-assist attempt. If screenshots are used in V1.5+, log only screenshot hashes and enforce screenshot retention limits.
- If the page is not the expected compose/reply surface, return `forbidden_surface` or `platform_changed` instead of improvising.

### 15.6 Completion Tracking

Actions have explicit lifecycle states:

- `signal`
- `draft`
- `approved`
- `scheduled`
- `ready_to_post`
- `prepared_unconfirmed`
- `submitted`
- `verified`
- `skipped`
- `expired`
- `killed`
- `error`

A ready-to-post item is not done. It is done only when submitted/verified or manually confirmed.

State semantics:

- `skipped` = not today; may be suggested again if a future signal warrants it.
- `killed` = suppress this draft/angle/source pattern unless Rod manually revives it.
- `ready_to_post` = Rod has approved and Dispatch has shown copy/link/checklist.
- `prepared_unconfirmed` = Rod started the posting flow but has not confirmed completion.
- `submitted_unverified` = Rod says it was posted, but Dispatch has no permalink or platform verification.

### 15.7 Quality Gate Before Posting Assist

Dispatch must block **Copy & Open** unless the current draft passes all gates:

- Rod approved the current draft version. Any edit after approval resets status to `draft` and requires re-approval.
- Character limits pass.
- Source permissions pass.
- Platform content quality contract passes.
- Duplicate/near-duplicate check passes.
- Account cooldown check passes.
- Target URL is still reachable where applicable.
- Platform action cap is not exceeded.
- Topic/angle repetition check passes.

If any gate fails, Dispatch shows a named blocker and recommended fix. Posting assist should not be the place where obvious errors surface.

### 15.8 Portfolio Mix Rules

Batch assembly must prevent account-training into a single-topic campaign.

Rules:

- Max 60% of a batch may be direct PP / agent-authorization content.
- If batch has 4+ actions, include at least one adjacent/non-PP action or explicitly explain why none cleared threshold.
- No more than 2 actions may use the same core phrase, metaphor, or argument angle.
- HN should bias toward adjacent technical comments when account health is in cooldown or comments-only mode.
- Dispatch should show a visible warning when a batch is too thematically narrow.

### 15.9 Safety Rules

System enforces:

- Per-platform daily caps.
- Platform-specific cooldown triggers.
- Duplicate content detection.
- Topic repetition warnings.
- Character limits.
- Expiry windows.
- Source-permission restrictions.
- No auto-posting to HN/LinkedIn personal/Reddit. X auto-posting is V1B only.

### 15.10 Doorbell Alerts

Discord alerts are allowed only for:

- Daily ritual reminder: "time to open Dispatch".
- High-confidence breaking opportunity.
- Copy & Open action ready for Rod to submit manually.
- Expiring high-value action.
- Posting/login blocker.
- High-value reply/follow-up detected.

No full draft dumps into Discord by default.

### 15.11 Reply and Follow-Up Handling

V1 must close the loop after posting enough to prevent drive-by engagement.

V1A-0 minimum:

- Every submitted action can have a follow-up reminder time.
- HN actions can be checked via public thread/profile where available.
- If replies are detected, Dispatch creates a follow-up signal, not an automatic reply draft.
- Doorbell copy: `Your HN comment has 3 replies — review in Dispatch`.
- Rod can mark replies as `ignore`, `draft response`, or `handled`.

V1B may add X API reply checks and safer LinkedIn/manual reply capture.

---

## 16. Data Model

### 16.1 Signal

```ts
type Signal = {
  id: string;
  source: 'hn' | 'discord' | 'workspace' | 'manual' | 'platform_history';
  sourceClass: 'public_safe' | 'internal_strategic' | 'private_sensitive' | 'customer_prospect';
  authorId?: string;
  authorDisplay?: string;
  authorPermission: 'own' | 'collaborator' | 'public_author' | 'unknown';
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
  scoreBreakdown: {
    topicRelevance: number;
    freshness: number;
    audienceValue: number;
    novelty: number;
    estimatedResponseQuality: number;
    accountSafetyRisk: number;
  };
  urgency: 'breaking' | 'normal' | 'evergreen';
  status: 'new' | 'used' | 'ignored' | 'expired';
};
```

### 16.2 Platform Identity

```ts
type PlatformIdentity = {
  id: string;
  platform: 'hn' | 'x' | 'linkedin' | 'reddit' | 'medium';
  handleOrPage: string;
  kind: 'personal' | 'company_page' | 'publication' | 'throwaway' | 'other';
  status: 'active' | 'paused' | 'cooldown';
};
```

Account health and caps are keyed by `(platform, identityId)`, not platform alone.

### 16.3 Dispatch Action

```ts
type DispatchAction = {
  id: string;
  batchId: string;
  identityId: string;
  platform: 'hn' | 'x' | 'linkedin' | 'reddit' | 'medium';
  actionType: 'post' | 'comment' | 'reply' | 'draft_article';
  title?: string;
  body: string;
  targetUrl?: string;
  sourceSignalIds: string[];
  why: string;
  whyCheckedAt: string;
  estimatedMinutes: number;
  status:
    | 'draft'
    | 'approved'
    | 'scheduled'
    | 'ready_to_post'
    | 'prepared_unconfirmed'
    | 'submitted'
    | 'submitted_unverified'
    | 'verified'
    | 'skipped'
    | 'expired'
    | 'killed'
    | 'error';
  urgency: 'breaking' | 'today' | 'evergreen';
  expiresAt?: string;
  cooldownUntil?: string;
  safetyWarnings: string[];
  visibleDraftRequired: true;
  targetUrlRequired: boolean;
  qualityGate: {
    passed: boolean;
    blockers: string[];
  };
  createdAt: string;
  updatedAt: string;
};
```

### 16.4 Batch

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

### 16.5 Account Health

```ts
type AccountHealth = {
  identityId: string;
  platform: 'hn' | 'x' | 'linkedin' | 'reddit' | 'medium';
  handleOrPage: string;
  lastActionAt?: string;
  dailyActionCount: number;
  weeklyActionCount: number;
  flagsOrWarnings: number;
  cooldownUntil?: string;
  mode: 'normal' | 'cooldown' | 'comments_only' | 'manual_only' | 'paused';
  notes: string[];
};
```

---

## 17. Privacy, Retention, and Deletion

Dispatch stores internal source material, drafts, posting states, and possibly screenshots in future versions. Default posture should be minimal retention.

Requirements:

- Store minimal source snippets, not full Discord threads, unless explicitly needed.
- Do not store `private_sensitive` raw excerpts by default.
- Screenshot retention: default 7 days, then delete. V1A-0 should avoid screenshots entirely unless debugging requires them.
- Draft/action retention: keep by default for weekly review and learning, but allow manual deletion.
- Signals can be deleted individually.
- Raw source excerpts can be redacted without deleting the derived action history.
- No public indexing. Private auth required.
- Never store platform passwords, session cookies, 2FA codes, or browser profiles.
- Export/delete should be possible for all Dispatch data tied to Rod.

### 17.1 Auth, Sessions, and Secrets

- Dispatch auth is restricted to an explicit allowlist of Google accounts.
- Sessions should be revocable, with **sign out everywhere** support.
- Shared/public-computer usage should show a warning and short session duration.
- Secrets live only in managed server environment/secret storage, never in Firestore documents or client bundles.
- X API keys, LLM keys, Discord tokens, and future extension secrets must be scoped to the minimum required permissions.
- HN cookies/session credentials must not be stored in Dispatch.

### 17.2 Audit Log

Dispatch keeps an append-only audit log for debugging and prompt drift review:

- batch generated
- source signals used
- model/provider used, including fallback model
- draft version created/edited/approved
- quality gate result
- Copy/Open action triggered
- Rod confirmed posted/skipped/killed
- reply/follow-up signal detected

Audit entries should avoid storing raw sensitive content when source class is not public-safe.

---

## 18. Account Health Triggers

Account health rules must be concrete enough for implementation. Vague "be careful" warnings are not sufficient.

### 18.1 Hacker News

Rules apply per HN identity.

- Any flagged HN comment → 7-day cooldown on PP-adjacent comments.
- Any flagged HN submission → 14-day comments-only mode; no submissions.
- Two flagged HN actions in 30 days → HN mode becomes `manual_only`; Dispatch may suggest but not prepare browser actions.
- Three consecutive HN comments with no upvotes/replies → recommend adjacent/non-PP topics for the next 3 HN actions.
- Account karma decrease over a week → reduce HN cap to 1 action/day until trend stabilizes.

### 18.2 LinkedIn

Rules apply per LinkedIn identity/page.

- Identity challenge, suspicious-login prompt, or CAPTCHA → LinkedIn mode becomes `paused` until Rod manually clears it.
- Three consecutive low-engagement posts → reduce LinkedIn cadence to 1 post/week and prioritize comments/replies.
- Any post that Rod marks "too AI" → apply stricter LinkedIn content quality checks for 14 days.

### 18.3 X

- API failure due to auth/rate limit → disable auto-posting and fall back to browser/manual mode.
- Burst risk: never publish more than 2 X actions within 60 minutes unless Rod explicitly overrides.

### 18.4 Reddit

- Removed post/comment or subreddit warning → 30-day cooldown for that subreddit.
- Any moderator warning → Reddit mode becomes suggestion-only for all subreddits until reviewed.

---

## 19. UX Requirements

### 19.0 Onboarding and First-Open Empty State

First open must not be a blank dashboard.

Required setup flow:

- Confirm Rod's allowed Google account.
- Configure platform identities/handles. V1A-0 defaults: HN = Rod personal, X = Rod personal, LinkedIn = Rod personal. PP company/page identities are V1B unless manually enabled.
- Select approved signal sources and their default source classes.
- Seed Rod-curated adjacent topics.
- Seed style-anchor examples.
- Set daily ritual time, quiet hours, and mobile/defer preferences.

If setup is incomplete, Dispatch should show a checklist and allow manual capture as the first useful action.

### 19.1 Home Screen

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

### 19.2 Action Card

Each card shows:

- Platform.
- Identity/account/page the action applies to.
- Action type.
- Draft body in an always-visible copy box.
- Source attribution and source class.
- Redactions/anonymizations applied.
- Why now, with `whyCheckedAt` timestamp.
- Signal score and reason it cleared threshold.
- Expiry/cooldown.
- Safety warnings.
- Always-visible draft copy box.
- Manual target link.
- Buttons: Approve, Edit, Skip, Kill, Copy, Open, Copy & Open, Defer to desktop, I posted it.
- Device capability status: clipboard available, popup/open available, extension installed yes/no, platform login unknown.

### 19.3 End Screen

After batch completion:

- Completed actions.
- Skipped actions.
- Killed/suppressed angles.
- Expired/missed actions.
- Any required manual follow-up.
- Replies/follow-up items detected or pending.
- Next suggested check-in.

### 19.4 Mobile and Multi-Device Handoff

- Mobile can review, edit, approve, skip, kill, and defer.
- Mobile can use visible copy/manual open where platform behavior allows it.
- If a platform opens a native app or posting flow is awkward, user can tap **Defer to desktop**.
- State syncs through Firestore so an item approved on phone can be completed on laptop.
- The UI must clearly show current device capability and never imply a local login exists when Dispatch cannot know.

---

## 20. Technical Architecture

Recommended V1 stack:

- **Frontend:** Next.js or Vite React.
- **Auth:** Google SSO restricted to Rod.
- **Database:** Firebase Firestore.
- **Functions:** Firebase Cloud Functions or OpenClaw cron-backed API endpoints for generation and signal collection.
- **Posting assist V1A-0:** client-side copy/open/checklist in Rod's current browser. Works from any authenticated computer where Rod is logged into the target platform.
- **Posting assist V1.5:** optional Chrome extension for local form-fill only. Extension never clicks final submit.
- **OpenClaw browser control:** optional internal fallback for Rod's Mac, not the default product architecture.
- **Signal collection:** scheduled background jobs writing signals, not drafts.
- **Discord doorbell:** existing OpenClaw message integration.

### Suggested Deployment

- `dispatch.permissionprotocol.com`.
- Private/internal auth gate.
- No public indexing.
- UI must work from any computer/browser after Rod authenticates.
- If the local browser is not logged into the target social platform, Dispatch shows `login_required` guidance while still showing copy box + manual target link.
- Discord is not a hard dependency for use. If Discord input/output fails, Dispatch continues with in-app state and optional email/push fallback.

---

## 21. Edge Cases and Required Handling

### 21.1 Browser / Platform Edge Cases

- Local platform session missing/expired → show `login_required` with target URL and copy button.
- 2FA or identity challenge → stop and ask Rod to complete manually in that local browser.
- Platform UI changed → show `platform_changed`; do not retry blindly.
- Target thread deleted → mark `target_missing` and expire action.
- Content too long → block prepare until edited.
- Platform reformats content → Rod reviews final rendered text before submit; V1A-0 does not assume pasted text equals posted text.
- Clipboard write fails → visible copy box remains usable.
- Open target blocked by popup policy → manual target link remains usable.
- Native app handoff on mobile is unreliable → offer Defer to desktop.
- Rod closes target tab or does not confirm → mark `prepared_unconfirmed`, allow retry.
- Duplicate draft → warn/block.

### 21.2 Behavioral Edge Cases

- Rod ignores Dispatch for 3 days → no pile of old drafts; generate fresh next time.
- Batch too large → hard cap to 7 actions.
- Too much PP topic repetition → warn and insert adjacent/personal-founder topics.
- HN flagged account → enforce cooldown and recommend unrelated comments.
- Discord alert ignored → no repeated nag loops; one reminder max.
- Out-of-band posts by Rod → Dispatch reconciles where possible and otherwise allows manual entry to keep caps/cooldowns honest.
- Stale why-now → re-check `why` before Copy & Open if older than platform-specific freshness window.

---

## 22. Success Metrics

### Activation

- Rod opens Dispatch 4+ days/week.
- Rod completes first batch within 24h of V1 launch.
- Average batch completion time under 25 minutes.

### Output Quality

- 3+ meaningful public actions/week.
- At least 30% non-direct-PP/adjacent content mix.
- HN karma stable or increasing; no new flags from obvious campaign behavior.

### Operational

- Less than 10% posting-assist attempts fail silently. Target: 0 silent failures.
- Every action has explicit final state.
- No stale drafts older than expiry in active queue.

### Business Signal

- At least 1 useful reply/conversation per week.
- At least 1 post/comment per week reusable for outreach or blog expansion.

---

## 23. Customer Test Gate

### 23.1 First Real Usage Test

Before calling V1A-0 shippable, Rod should complete this concrete test:

1. Open Dispatch from a non-primary computer or browser session.
2. Generate a batch.
3. Produce either one safe HN adjacent comment or explicitly skip HN due to account-health gating.
4. Produce one X or LinkedIn action from fresh signals.
5. Inspect the always-visible copy boxes before using any helper action.
6. Use Copy & Open for at least one action.
7. Submit manually from Rod's logged-in platform session.
8. Click **I posted it** and confirm Dispatch logs the result.
9. Return the next day and generate a fresh batch without stale backlog guilt.

Pass condition:

> Rod says, "This is easier than doing it manually, and I can see myself opening it tomorrow."

### 23.2 Week-4 Behavioral Validation

The one-day test is not enough. Dispatch only works if it survives real usage.

Week-4 pass criteria:

- Rod opened Dispatch at least 4 days in one week.
- Rod completed at least 3 public actions that week.
- At least one action created a useful reply/conversation.
- At least one reply/follow-up was surfaced back into Dispatch.
- No new account-health incidents caused by obvious automation/campaign behavior.
- Rod still prefers opening Dispatch over ad hoc Discord/chat workflows.

---

## 24. Phased Roadmap

### V0 — PRD and Manual Prototype

- Use this PRD.
- Manually generate one batch in chat.
- Validate action caps and platform grouping.

### V1A-0 — First Shippable Slice

- Web UI with Google auth.
- On-demand batch generation from manual capture, HN signals, X/LinkedIn manual targets, adjacent/general-interest signals, and approved workspace/source docs.
- HN/X/LinkedIn as core lanes using one shared manual posting workflow.
- HN starts in conservative mode: comments only, max 1/day, no submissions, not required for batch success.
- Review/edit/skip/kill with explicit skipped vs killed semantics.
- Always-visible copy box + manual target link for every action.
- Copy & Open/checklist, no remote form fill, no extension, no API posting.
- Manual confirmation verification: Rod clicks **I posted it**.
- Minimal reply/follow-up signal for HN when permalink/comment ID exists.
- Completion states: draft, approved, ready_to_post, submitted, submitted_unverified, verified, skipped, killed, expired, error.
- Quality gate before posting assist.
- Mobile review + defer-to-desktop path.
- No weekly review yet.

### V1B — Full Internal Daily Dispatch

- Deeper LinkedIn/X source and reply handling.
- Discord source ingestion.
- Doorbell alerts plus email/push fallback.
- X API posting if keys/account posture are confirmed.
- Out-of-band post reconciliation where feasible.
- Weekly summary.
- Privacy/retention controls.

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

## 25. Open Questions

1. For V1B, should PP company/page identities be enabled alongside Rod personal identities?
2. Should Dispatch live inside the PP app repo or as a standalone internal app?
3. Which Discord channels are approved signal sources beyond `#hackernews` and `#1479273617689809097`?
4. Should `dispatch.permissionprotocol.com` be private behind Google auth or Tailscale-only?
5. Should V1.5 local form-fill use a Chrome extension, bookmarklet, or native browser share target?
6. What is the daily ritual time? Morning default seems best.

---

## 26. Recommendation

Build V1 as a **simple daily action cockpit**, not a social CMS.

The strongest version is:

- On-demand generation.
- Background signal collection.
- 3-7 capped daily actions.
- Human final-submit via Rod's current local browser session.
- Explicit states and cooldowns.
- Discord only for doorbell alerts.

This directly addresses the recurring failure pattern without creating a content treadmill or risking account bans.

---

## 27. Implementation Acceptance Criteria

V1A-0 implementation is complete when:

- Rod can authenticate into Dispatch from more than one device/browser.
- Rod can click **Generate Today's Batch**.
- Dispatch returns capped grouped actions with source attribution, source class, why-now timestamp, signal score, and visible copy box.
- Rod can approve/edit/skip/kill each action.
- Any edit after approval requires re-approval.
- Rod can complete one X or LinkedIn action using the always-visible copy box + manual target link from the current browser/device.
- HN can be skipped due to account health and the batch still counts as successful.
- If HN is used, it is comments-only, max 1/day, and conservative-mode gated.
- Copy & Open stops before submit and returns a clear state/checklist.
- Rod confirms **I posted it** and Dispatch records submitted/submitted_unverified/verified correctly.
- Dispatch tracks skipped/killed semantics and suppresses killed angles.
- Background collector writes signals but not finished drafts.
- Daily ritual reminder is phrased as "time to open Dispatch," not "batch ready".
- V1A-0 never hides the draft behind automation; Rod can always inspect/copy/open manually first.
- A minimal HN reply/follow-up signal can be surfaced after a submitted action.

---

*This PRD intentionally prioritizes behavior change over feature count. The product wins if Rod opens it daily and clears a small useful batch. Everything else is optional.*
