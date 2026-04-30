# Sprint 6 — Hand-Found Activation Targets

*Created: 2026-04-30. Goal: 20 builders running real coding agents on real repos. Source: live web search of public posts in the last ~60 days, not enrichment.*

---

## How to read this list

- **Tier A** = direct evidence within last 60 days of running an autonomous coding agent against their own code with public commentary on the safety/approval problem. **Highest activation probability.** Approach first.
- **Tier B** = visible expert / influencer in the agentic-coding space, may not be a personal user but understands the problem deeply and could amplify. Approach second.
- **Tier C** = candidate worth 5-min verification before reaching out. Listed last.

Each entry includes: handle, evidence link, the specific hook (their words, not ours), and the recommended first DM angle.

**Rule from FOCUS.md / VOICE:** open with "I'm the founder of Permission Protocol," not "I'm building." Reference their *specific* post.

---

## Tier A — Direct evidence, run-now candidates

### 1. Faruk Ateş / mfyz
- **Handle:** site mfyz.com, likely @kurafire on X
- **Evidence:** ["Claude Code on Loop: The Ultimate YOLO Mode" (Oct 2025)](https://mfyz.com/claude-code-on-loop-autonomous-ai-coding/)
- **His words:** *"It's scary because you're giving up control."*
- **Hook:** He literally articulated the problem PP solves, in public, on his own blog.
- **First DM angle:** "Saw your YOLO loop post. The 'scary giving up control' part — I'm the founder of Permission Protocol, we built the gate that runs between the agent and merge so you don't have to. Worth 15 min to watch you install on a real repo and see if it kills the scary part?"
- **Channel priority:** X DM > email via blog contact form

### 2. Author of guardrails.md
- **Handle:** unclear — site is anonymous but the prose suggests a single dev
- **Evidence:** [guardrails.md (Jan 28, 2026)](https://guardrails.md/)
- **Their words:** *"Agent optimized queries by directly modifying production schema without migrations."* Built a manifesto around this.
- **Hook:** They've already done the conceptual work — wrote rules for autonomous agent safety. PP is the *enforcement layer* for what they've already specified.
- **First DM angle:** "I read guardrails.md end to end. We're building the enforcement primitive that runs your rules against agent actions before merge. Want to see your own rules running on a live repo?"
- **Channel priority:** GitHub issue / find author via site footer

### 3. Max Krivich
- **Handle:** @maxkrivich (dev.to, likely same on X/GitHub)
- **Evidence:** ["AI Coding Agent Security: Practical Guardrails for Claude Code, Copilot, and Codex" (Apr 2026)](https://dev.to/maxkrivich/ai-coding-agent-security-practical-guardrails-for-claude-code-copilot-and-codex-och)
- **His words:** Wrote a 3-week-old practical guide on agent guardrails — exactly PP's category.
- **Hook:** He's already publishing on this, has audience interest validated.
- **First DM angle:** "Your dev.to piece on agent guardrails — we built the runtime enforcement layer that turns those rules into signed receipts at merge time. Want a 5-min walkthrough on your own repo?"

### 4. Ralphify (ralph)
- **Handle:** ralphify.co, find author on About page
- **Evidence:** ["How to Run Claude Code, Aider, or Codex in an Autonomous Loop" (Apr 2026)](https://ralphify.co/docs/agents/)
- **Their words:** *"In an autonomous loop, nobody is there to approve — so the agent would hang forever."*
- **Hook:** They are *literally building autonomous coding loops* and explicitly call out the approval gap. PP is their missing piece.
- **First DM angle:** "Your docs page nails it — autonomous loop + approval = open problem. PP closes it without breaking the loop. Want to see it run on your stack?"

### 5. The r/ClaudeCode "guardrails" thread OP
- **Evidence:** [Reddit thread (Jan 2026)](https://www.reddit.com/r/ClaudeCode/comments/1q19o4r/what_guardrails_are_you_using_in_the_claudecode/) — OP asked the community what guardrails they use
- **Hook:** Direct demand signal. Not us pitching, them asking.
- **First DM angle:** Reddit DM — "Saw your thread. We built the primitive — happy to walk through it on your repo, no pitch, just feedback."

### 6. The Reddit "YOLO mode without wrecking my environment" OP
- **Evidence:** [r/ClaudeCode (Dec 2025)](https://www.reddit.com/r/ClaudeCode/comments/1pct552/my_setup_for_running_claude_code_in_yolo_mode/)
- **Their words:** Built a sandbox setup, complains it doesn't help with Postgres/Redis/OAuth dependencies.
- **Hook:** Identifies the limit of sandbox-based safety. PP works at the action layer, not the environment layer.
- **First DM angle:** Reddit DM — "Sandbox isolation is the wrong level. We gate at the action (PR/deploy) level — works for Postgres, OAuth, all of it. Want to try?"

### 7. Olivia Moore (a16z)
- **Handle:** [@omooretweets](https://x.com/omooretweets/status/2014010732061638949)
- **Evidence:** "Cursor + Claude Code: How to build an agentic workspace (for non-technical people)"
- **Hook:** a16z partner publicly running agents on her own work. High-leverage if activated. Even a "no thanks" still gets PP into her radar at the right firm.
- **First DM angle:** "Your agentic workspace post — I'm the founder of Permission Protocol. We built the layer that lets non-technical operators safely run those agents past the approval line. Worth 15 min if it's interesting to you or a portfolio company?"
- **Note:** Doubles as a VC-validation hit, which keeps the VC track useful without distracting from activation.

### 8. Lee Robinson (Vercel VP DX)
- **Handle:** [@leerob](https://x.com/leerob/status/1929727742821413331)
- **Evidence:** Public thread about his actual workflow with Cursor, Claude Code, and v0
- **Hook:** Vercel intersects directly with `idea-101` (Vercel wedge, currently frozen). Lee uses agents personally; getting him as user 1 is also a partnership opening.
- **First DM angle:** "Read your agent workflow thread. I'm the founder of Permission Protocol — built the gate that stops an agent from shipping the wrong thing. Most relevant to Vercel as a deploy-target story but I'd love your eyes on the primitive itself first. 15 min?"

### 9. Daniel San (@dani_avila7)
- **Handle:** [@dani_avila7](https://x.com/dani_avila7/status/2010814983026733119)
- **Evidence:** Posts about Agent Skills in Cursor/Claude Code, technical, hands-on
- **Hook:** Already deep in the agent tooling ecosystem. Likely has a repo running agents.
- **First DM angle:** "Saw your Skills post. Skills define what agents can do; PP defines what they're allowed to ship. Want to run it against one of your repos?"

### 10. George (@nurijanian, prodmgmt.world)
- **Handle:** [@nurijanian](https://x.com/nurijanian/status/2034992369284887015)
- **Evidence:** PM running Claude Code/Cursor on small projects, writes guides
- **Hook:** Non-technical-leaning user — PP's "non-technical signer" persona fits cleanly.
- **First DM angle:** "Your post about PMs shipping with Claude Code — that's exactly who PP is for. The PM signs, the agent ships. Worth 15 min?"

---

## Tier B — Influencers / experts, lower personal-activation probability but high amplification

### 11. Zvi Mowshowitz
- **Handle:** thezvi.substack.com, [@TheZvi](https://twitter.com/TheZvi)
- **Evidence:** ["Claude Code, Codex and Agentic Coding #7: Auto Mode" (~2 weeks ago)](https://thezvi.substack.com/p/claude-code-codex-and-agentic-coding)
- **Hook:** Most-read AI safety writer on Substack. Even one mention in his weekly roundup is worth 50 cold DMs. Doesn't need to be a user.
- **First DM angle:** Send him the Permission Protocol primer + one paragraph on why the Anthropic Auto Mode launch validates the category. Ask for honest read.
- **Note:** This is a press / amplification target, not an activation. Keep separate from the 3-activation target metric.

### 12. Greg Baugues (@greggyb)
- **Handle:** [@greggyb](https://x.com/greggyb/status/1900279653493072055)
- **Evidence:** "Cursor vs. Claude Code. Which is the better AI coding agent?" — hands-on comparison
- **Hook:** Has audience for tooling comparisons. Good for a "where does PP fit?" comparison piece.

### 13. elvis (@omarsar0)
- **Handle:** [@omarsar0](https://x.com/omarsar0/status/2044172949003911532)
- **Evidence:** Recent post on Codex / Cursor / Claude Code UI convergence
- **Hook:** Big AI educator audience. PP fits the "what's missing from these tools" narrative.

### 14. Anthropic Auto Mode launch coverage author
- **Handle:** find via [techbuzz.ai article (Mar 24, 2026)](https://www.techbuzz.ai/articles/anthropic-launches-auto-mode-safety-guardrails-for-claude-code)
- **Hook:** Anthropic shipped *partial* governance in Auto Mode. PP is the enterprise / cross-vendor version. Pitch as "Anthropic confirmed the category; here's the open primitive."

### 15. Codacy (blog: equipping Claude Code with guardrails)
- **Evidence:** [blog.codacy.com](https://blog.codacy.com/equipping-claude-code-with-deterministic-security-guardrails)
- **Hook:** Codacy is a code-quality vendor. Either a customer (their devs use agents) or a partnership (PP as the runtime gate they pair with).

---

## Tier C — Verify in 5 minutes before contacting

These showed up in adjacent searches but need a quick check that they're (a) real builders not just commentators, (b) active in last 60 days, (c) have a public way to be reached.

16. **Paolo Anzn** ([@paoloanzn](https://x.com/paoloanzn/status/2007671013857796441)) — bullish on Claude Code wrappers; verify if he runs agents on his own product.
17. **Migel Tissera** ([@migtissera](https://x.com/migtissera/status/2043556878177992908)) — checking Cursor agent internals; technical user.
18. **Author of "Claude Code Q1 2026 Update Roundup"** at MindStudio — clearly an active practitioner; their company may be the activation target rather than them personally.
19. **Author of lushbinary.com "AI Agent Production Guardrails: Prevent Data Loss"** (Apr 2026) — wrote the *day-old* incident analysis on the Apr 25 production-DB-wipe agent disaster. Living validation for PP. Get them on a call.
20. **r/ClaudeAI moderator(s)** — gatekeepers to a high-density audience of exact target persona. Even a single AMA appearance there hits hundreds of qualified humans.

---

## Two warm leads to revisit (already in pp-os)

Cross-check against `pp-os/idea-097` warm-lead shortlist and `pp-os/sprint5/` LinkedIn responses. If any of the 63 LinkedIn connections from Apr 29 have **publicly** discussed running agents on their own code in last 60 days, *promote them to Tier A* and contact again with the new angle.

---

## Outreach cadence (per Sprint 6 plan)

- **Day 1 (May 1):** First 5 DMs — pick from Tier A, top of list. Personal DMs, no templates.
- **Day 2-3:** Replies + scheduling. Goal: 3 screen-share calls booked.
- **Day 4-7:** Run calls. Watch installs live.
- **If 0 of first 10 reply by Day 5:** the message is the problem, not the list. Iterate the opener, don't widen the list.

## Hard rule

If we re-add CSV enrichment, scout pipeline, or templated outbound during Sprint 6 — we under-deleted. The whole point is hand-found, hand-written, watched-live.

## What I (Charles) need from Rod to start

1. Approval to start with Tier A entries 1-5 today as the first DM batch.
2. The Loom recording on `demo-repository` as backup material for cold replies (or explicit decision to delete the requirement).
3. A "yes" or "edits" on the SPRINT-6.md doc (sibling file).
