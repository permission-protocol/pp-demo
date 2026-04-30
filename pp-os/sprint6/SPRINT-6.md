# Sprint 6 — The Activation Sprint

*Created: 2026-04-30. Replaces the Sprint 5 install-count target.*
*Method: Musk's First Principles + The Algorithm, applied honestly.*

---

## The headline change

| | Sprint 5 (retired) | Sprint 6 (active) |
|---|---|---|
| **Goal** | 10 external installs by May 1 | 3 activated users by May 14 |
| **Audience** | Engineering VPs, VCs (LinkedIn) | Builders running real coding agents on real repos (Twitter/GitHub) |
| **Channel** | Templated outreach at scale (313 touches) | Hand-found targets, personal DMs, screen-share calls |
| **Success signal** | Click on "Install" | "I would be unhappy if PP went away" |
| **Mode** | War Room (90% failure prob) | Activation (success measurable in weeks, not days) |

---

## Why the change

We sent **313 outbound touches** over Sprint 5 and produced **0 activations**. That's not a volume problem — an Idiot Index of ∞ means a structural one.

The strip-to-atoms test for PMF:
> A real human, with consequence-bearing authority, used PP to deny or modify at least one agent action they would otherwise have missed, and would scream if PP disappeared tomorrow.

By that definition we have 0 of those today. We don't need 10. **We need 3.**

The 10-install target was reasoning by analogy ("that's what a Sprint goal looks like"). The 3-activation target is reasoning from the floor up.

---

## The Algorithm, applied

### Step 1 — Question every requirement (with names)

**DELETED on Apr 30 (Rod approved):**

- ❌ "10 installs by May 1" — vanity, not activation. Replaced with 3 deep activations.
- ❌ "Product Hunt launch by May 1" — DELETED. Step-5 amplification. PMF first.
- ❌ "GA4 conversion audit (idea-085)" — DELETED. Measuring conversion of a thing that isn't converting.
- ❌ "LinkedIn outreach to VCs" — DELETED from PMF path. Will email VCs directly **only** for warm intros into their portfolio companies, not for funding, not until first users exist.
- ❌ "Loom demo as a blocker" — resolves today: Rod records OR animated demo as fallback.
- ❌ "Homepage redesign as a blocker" — ship or close, not on PMF path.

Requirements kept:

- ✅ Install → first blocked PR in <2 minutes, on a stranger's repo (`SEE-TRY-PAY` Phase 1)
- ✅ The signer moment feels like a signature, not a button
- ✅ The consequence brief reads in plain language
- ✅ Find real builders running real agents on real repos
- ✅ Watch them install live and listen

### Step 2 — Delete (target: re-add no more than 10%)

**Frozen for Sprint 6:**
- idea-101 (Vercel wedge)
- idea-102 (Agent payments)
- idea-104 (Incident tracker)
- idea-085 (GA4 audit)
- idea-082 (X API write tier)
- idea-086 (Paperclip port)
- All marketing/SEO/PR/PH prep
- Any new app dashboard work

If we re-add anything, that's the signal we under-deleted. If nothing comes back by May 14, we over-deleted (good).

### Step 3 — Simplify (only what survives)

Five surfaces get attention. Nothing else.

1. **Install flow** — verify time-to-first-blocked-PR is genuinely <2 minutes for a stranger. Stopwatch test, not assumption.
2. **First-blocked moment** — the auto-PR from Apr 9 already exists; verify the consequence brief reads like a human wrote it.
3. **Signer screen** — the click should feel like signing. Test on three cold humans, watch faces.
4. **Target list** — 20 hand-found builders (delivered separately as `pp-os/sprint6/targets.md`).
5. **First conversation** — 20-minute screen share, watch them install, no pitching.

### Step 4 — Accelerate (only after the above is real)

Once 1 user is verified through the full loop:
- Measurement loop: install → activation moment ≤ 24h, visible in our own dashboard
- Cadence: 5 hand-found DMs/day, 1-hour reply SLA
- Iteration: weekly tuning of install copy, brief, signer screen, based on the latest 3 users

### Step 5 — Automate (after PMF is felt)

Only when ≥3 users would scream:
- Outbound automation (scout pipeline, templated DMs, batch enrichment)
- Funnel analytics dashboard
- Product Hunt, HN, paid acquisition
- Pricing/Stripe scale

---

## The 14-day schedule

| Day | What | Owner | Done = |
|---|---|---|---|
| **Day 0 (Apr 30)** | Sprint 6 doc shipped, target list shipped | Charles | This file + `targets.md` exist |
| **Day 0 (Apr 30)** | LinkedIn-VC track moved off PMF critical path | Rod | STATUS.md updated |
| **Day 1 (May 1)** | First 5 personal DMs sent (no templates) | Rod (or delegated) | 5 sent, logged in `outreach-log.jsonl` |
| **Day 2-3** | Reply handling, schedule first 3 screen-share calls | Rod + Charles | 3 calls on calendar |
| **Day 4-7** | Run 3 calls, watch installs, capture friction | Rod | 3 install attempts logged with friction notes |
| **Day 7** | Mid-sprint review: are we on track for 1 activation by Day 10? | Rod + Charles | Decision logged: continue / pivot |
| **Day 8-10** | Iterate the highest-friction surface from Day 4-7 notes | Charles | 1 surface measurably improved |
| **Day 10** | Target: 1 activated user (full loop done on real work) | Rod | The screen-share clip exists |
| **Day 11-14** | Repeat with 2 more from the list | Rod | 3 activated users by Day 14 |

---

## Success metric (singular)

**At least 3 humans, by May 14, who:**
1. Installed PP on a real repo running a real agent (not a demo)
2. Experienced PP block at least one action they were glad was blocked
3. Answer "yes, I'd be unhappy" to the Sean Ellis test

That's it. Not installs. Not stars. Not waitlist. Not signups. Three screamers.

---

## Failure modes to watch

- **Acceleration before deletion.** If anyone proposes "let's also do Product Hunt while we're at it" → no.
- **Optimizing the deleted thing.** If we're polishing LinkedIn copy in week 2, we've drifted.
- **Re-adding the dashboard.** Dashboard is a step-5 surface for paying customers, not an activation tool.
- **Smart-person requirements.** When Rod says "we should also..." stop and ask "whose name is on that requirement and what's the floor it's built on?"
- **The Loom trap.** If the demo Loom remains blocked, replace it with a real user's screen capture from Day 4-7. Real beats polished.

---

## VC track (deferred, not deleted)

Once 1–3 activations exist, email select VCs directly for warm intros into their portfolio companies that fit the agent-running profile. **Not for funding.** Not before activations. Held for now.

---

## Drought handling

This doc supersedes the Day-68 War Room framing. The drought counter pauses for Sprint 6. The new counter is **Days-to-First-Activation**, starting May 1.

If Day 10 passes with 0 activations:
- Stop. Run a 1-hour retrospective.
- Examine the call recordings.
- One of: (a) install flow is the bottleneck, (b) the audience is wrong, (c) the product itself doesn't solve a felt problem.
- Choose one and Sprint 7 attacks it. Do not "push harder."
