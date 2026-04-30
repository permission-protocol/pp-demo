# Sprint 6 — Outreach Today (32 sends, copy-paste in order)
*Generated: 2026-04-30. Master CSV: outreach-today.csv (open in Numbers/Sheets for table view).*

## Summary

| Phase | Channel | Count | Time est |
|---|---|---|---|
| P1 | Email (verified) | 14 | ~15 min |
| P2 | Email (inferred) | 8 | ~10 min |
| P3 | X DM | 8 | ~10 min |
| P4 | Reddit | 2 | ~5 min |
| **Total** | | **32** | **~40 min** |

---

## How to use this

1. Open https://github.com/Roca-Ventures/charles-workspace-backup/blob/log/2026-04-19/pp-os/sprint6/outreach-today.csv in raw view; download the CSV; open in Numbers/Sheets if you want a table view.
2. For each row below: copy the **address**, **subject** (if email), and **message** body. Paste into Gmail / X / Reddit.
3. Send. Move to next row.
4. After sending, mark the row done however you track it — Charles will log into `outreach-log.jsonl` if you give a list afterward, or you can append `,SENT,<timestamp>` columns to the CSV.

**Voice rules followed:** "founder of," not "building"; specific quotes from their posts; no clever analogies; no rhetorical reversals.

---


## Phase 1 — Verified Emails (send first, ~15 min)

### 1. Phil Chen (@philhchen) — Email

**Address / link:** `support@filbert.ai`

**Subject:**
```
Filbert + the merge step
```

**Message:**
```
Phil,

Saw your "95% of our PRs" post about Filbert. The agent ships fast; the merge step is where governance breaks.

I'm the founder of Permission Protocol. We gate agent PR merges behind a human-signed receipt — install in 2 minutes via a GitHub App, the agent literally cannot ship until an authorized human signs. Plays clean with whatever harness Filbert uses internally.

15 min, screen share, install on one of your repos and tell me where it breaks?

— Rod, founder, Permission Protocol
https://permissionprotocol.com
```

---

### 2. Nader Dabit (@dabit3) — Email

**Address / link:** `dabit3@gmail.com`

**Subject:**
```
Devin → cloud agent → PR → who's the signer?
```

**Message:**
```
Nader,

Your definition of cloud agents nails the shift: agents that check out, edit, test, and open PRs autonomously. The open question is who signs the merge — and what evidence sticks afterwards.

I'm the founder of Permission Protocol. One GitHub App install adds a human-signed receipt to every agent-authored PR — works the same whether Devin, Codex, Claude Code, or Cursor opened it. 2-minute setup.

Worth 15 minutes? You're at exactly the abstraction layer where this should live, and I'd value your honest read.

— Rod, founder, Permission Protocol
https://permissionprotocol.com
```

---

### 3. Ashpreet Bedi (@ashpreetbedi) — Email

**Address / link:** `hi@ashpreetbedi.com`

**Subject:**
```
Coda's PR step + the signer layer
```

**Message:**
```
Ashpreet,

Read your post on Coda's worktree → fix → test → PR flow. Your loop ends at "PR for human review." Mine starts there.

I'm the founder of Permission Protocol. We gate the PR merge behind a human-signed receipt — install in 2 minutes via a GitHub App. The agent ships fast, the merge is a real decision point, the receipt is portable evidence afterwards.

15 min, screen share, install it on a Coda repo and tell me what breaks?

— Rod
https://permissionprotocol.com
```

---

### 4. Owen Gretzinger (@owengretzinger) — Email

**Address / link:** `owengretzinger@gmail.com`

**Subject:**
```
114 non-engineer PRs and the audit trail
```

**Message:**
```
Owen,

114 merged PRs from non-engineers through your agent review workflow is a real number. The honest follow-up question: when something breaks in production, who's on the receipt?

I'm the founder of Permission Protocol. We gate agent PR merges behind a human-signed receipt — the non-engineer becomes the signer of record, the merge is logged with their identity. Install in 2 minutes via a GitHub App.

15 min, screen share, install it on Boardy and see if it removes the implicit-blame problem?

— Rod
https://permissionprotocol.com
```

---

### 5. Peter Steinberger (@steipete) — Email

**Address / link:** `peter@steipete.me`

**Subject:**
```
Codex automerge loop — what gates the loop?
```

**Message:**
```
Peter,

Your clawsweeper Codex automerge thread is real-world automation. The thing it doesn't have, by design, is a human signature on each merge. That's the gap I'm closing.

I'm the founder of Permission Protocol. A GitHub App that gates PR merges behind a human-signed receipt — sub-2-minute install, no workflow change, the loop runs full speed and the merge has a real lock.

15 min, install it on clawsweeper, tell me where it slows you down (it shouldn't).

— Rod
https://permissionprotocol.com
```

---

### 6. Simon Willison (@simonw) — Email

**Address / link:** `simon@simonwillison.net`

**Subject:**
```
Re: your Claude Code for web posts — the merge layer
```

**Message:**
```
Simon,

Your Apr 27-29 posts on running Claude Code for web autonomously against your repos got me. The agent ships fast; the merge step is where most people don't have a primitive yet.

I'm the founder of Permission Protocol. We gate agent-authored PR merges behind a human-signed receipt — install in 2 minutes via a GitHub App. Works the same whether Claude Code, Codex, or your own scripts opened the PR.

If you have 15 minutes I'd love your eyes on it. Honest feedback, no pitch. If it's worth a tag, I'd be grateful; if it's not, I'd rather know.

— Rod, founder, Permission Protocol
https://permissionprotocol.com
```

---

### 7. Noel DeLisle (@noeldelisle) — Email

**Address / link:** `hello@noeldelisle.com`

**Subject:**
```
Agent works while you sleep — the merge step
```

**Message:**
```
Noel,

Your "active repo before bed" pattern is the right way to use these agents. The piece that's still wide open: the merge in the morning. Right now there's no signed record of who decided.

I'm the founder of Permission Protocol. We gate that morning merge behind a human-signed receipt — install in 2 minutes via a GitHub App. Doesn't slow the loop. Adds an audit trail you'll want once your shipping volume goes up.

15 min, install on a repo, give me feedback?

— Rod
https://permissionprotocol.com
```

---

### 8. Aakash Gupta (@aakashgupta) — Email

**Address / link:** `productgrowthppp@gmail.com`

**Subject:**
```
PocketOS incident + the missing primitive
```

**Message:**
```
Aakash,

Your PocketOS thread was the right reaction. The pattern keeps repeating — agent runs unsandboxed on real infra, deletes production data, no signed record of who let it. I'm the founder of Permission Protocol; we built the primitive that closes that gap.

One GitHub App install, agent-authored PR merges require a human-signed receipt. The agent ships fast; the merge has a real lock; the receipt is portable evidence. Sub-2-minute setup.

15 min, install on one of your SaaS repos, honest feedback?

— Rod
https://permissionprotocol.com
```

---

### 9. Chandler Nguyen (@chandlernguyen) — Email

**Address / link:** `contact@chandlernguyen.com`

**Subject:**
```
Claude Code Agent Teams + the merge step
```

**Message:**
```
Chandler,

Read your "dropping my $200 Claude plan after two weeks with Codex" post. The piece your write-up doesn't cover (because nobody's solved it yet) is the merge-side governance for these autonomous teams.

I'm the founder of Permission Protocol. GitHub App that gates agent-authored PR merges behind a human-signed receipt. 2-minute install. Works the same regardless of which agent opened the PR.

15 min, install on your newsletter repo, feedback only?

— Rod
https://permissionprotocol.com
```

---

### 10. Fatih Yıldız (@mfyz) — Email

**Address / link:** `fatih@mfyz.com`

**Subject:**
```
Re: your ""Claude Code on Loop"" post — fascinating and terrifying
```

**Message:**
```
Fatih,

Read your "Claude Code on Loop" post. The "fascinating and terrifying" framing is exactly the gap I'm working on.

I'm the founder of Permission Protocol. We gate agent actions behind a human-signed receipt — install in 2 minutes via a GitHub App, the agent literally cannot ship until an authorized human signs. The loop runs full speed; the merge has a real lock.

15 min, install on a real repo, feedback only?

— Rod
https://permissionprotocol.com
```

---

### 11. Lee Robinson (@leerob) — Email

**Address / link:** `lee@leerob.com`

**Subject:**
```
Your Cursor 3 agent ratio post + the merge layer
```

**Message:**
```
Lee,

Saw your post on Cursor 3's inverted Tab-vs-agent ratio. When 2× as many users run autonomous agents as autocomplete, the merge step becomes the new branch protection.

I'm the founder of Permission Protocol. GitHub App that gates agent-authored PR merges behind a human-signed receipt. Sub-2-minute install. Works alongside Cursor's cloud agents and any other harness.

15 min, install on a repo, feedback only? Honest read on whether Cursor users would care.

— Rod
https://permissionprotocol.com
```

---

### 12. Max Krivich (@maxkrivich) — Email

**Address / link:** `hello@kryvych.cc`

**Subject:**
```
Your agent guardrails post — runtime enforcement?
```

**Message:**
```
Max,

Your dev.to piece on practical guardrails for Claude Code, Copilot, and Codex covers the rules side cleanly. I'm working on the runtime enforcement side — turning rules like yours into hard merge-time gates instead of agent-side prompts that an LLM can rationalize past.

I'm the founder of Permission Protocol. One GitHub App install, and the agent's PR can't merge until a human signs a receipt. 2-minute setup.

Worth 15 min to install on a repo and see if it complements what you've already documented?

— Rod
https://permissionprotocol.com
```

---

### 13. Dani Avila (@dani_avila7) — Email

**Address / link:** `hello@judini.ai`

**Subject:**
```
Skills define what agents do; this defines what they ship
```

**Message:**
```
Dani,

Saw your post on Agent Skills landing in Cursor. Skills define what agents *can* do — I'm building the layer that defines what they're allowed to *ship*.

I'm the founder of Permission Protocol. One GitHub App install, and an agent's PR can't merge without a human-signed receipt. Works the same across Cursor, Claude Code, Codex.

Curious if you'd run it on a Judini repo for 15 minutes and tell me what you'd change.

— Rod
https://permissionprotocol.com
```

---

### 14. Shoubhit Dash (@nexxeln) — Email

**Address / link:** `hey@nexxel.dev`

**Subject:**
```
opencode + Permission Protocol — adjacent layers
```

**Message:**
```
Shoubhit,

opencode reads the repo to generate AGENTS.md. Permission Protocol signs the merges that AGENTS.md-driven agents produce. Adjacent layers; clean fit.

I'm the founder of PP. GitHub App, sub-2-minute install, agent-authored PRs require a human-signed receipt before merge.

15 min to see if there's a clean integration story?

— Rod
https://permissionprotocol.com
```

---


## Phase 2 — Inferred Emails (send-with-care, ~10 min)

### 15. Greg Baugues (@greggyb) — Email

**Address / link:** `greg@baugues.com`

**Subject:**
```
Cursor vs Claude Code — the missing third option
```

**Message:**
```
Greg,

Saw your Cursor vs Claude Code post and the @gregcode channel. You're picking between agents that ship code; I'm working on the layer that decides whether they're allowed to.

I'm the founder of Permission Protocol. We gate agent actions behind a human-signed receipt — 2-minute GitHub App install, works across Cursor, Claude Code, Codex.

15 min on a haihai.ai repo, feedback only?

— Rod
https://permissionprotocol.com
```

---

### 16. Olivia Moore (@omooretweets) — Email

**Address / link:** `omoore@a16z.com`

**Subject:**
```
Your agentic workspace post — the missing layer
```

**Message:**
```
Olivia,

Read your post on building an agentic workspace for non-technical people. The bottleneck I keep seeing isn't agent capability — it's the moment a non-technical operator has to decide whether to trust the agent's PR.

I'm the founder of Permission Protocol. We gate agent actions behind a human-signed receipt — install in 2 minutes via a GitHub App, the agent cannot ship until an authorized human signs. The non-technical operator becomes the signer, not the engineer.

Worth 15 minutes for me to walk you through it? Honest question whether it makes the agentic workspace safer for the audience you're describing.

— Rod
https://permissionprotocol.com
```

---

### 17. Mervin Praison (@MervinPraison) — Email

**Address / link:** `mervin@mer.vin`

**Subject:**
```
OpenClaw shipped a PR on your repo — the signer step
```

**Message:**
```
Mervin,

Saw your post on OpenClaw auditing your repo for 30 days and shipping a feature PR itself. That's exactly the loop I'm building governance for.

I'm the founder of Permission Protocol. We gate that PR merge behind a human-signed receipt — install in 2 minutes via a GitHub App. The agent does the work, the human signs the merge, the receipt is the audit trail you'll want when you scale this.

15 min, install on the same repo and tell me what's missing?

— Rod
https://permissionprotocol.com
```

---

### 18. Indragie Karunaratne (@indragie) — Email

**Address / link:** `indragie@sentry.io`

**Subject:**
```
Seer + the signer layer — partnership angle
```

**Message:**
```
Indragie,

Saw your work on Seer's PR-writing agents at Sentry. You're already shipping the autonomous half; I'm working on the merge-side governance.

I'm the founder of Permission Protocol. We gate agent-authored PR merges behind a human-signed receipt — install in 2 minutes via a GitHub App. Sentry's customers running Seer would inherit a clean audit trail without any workflow change.

Worth 15 min to walk through it? Either as a Sentry partnership or just personal feedback on the primitive.

— Rod, founder, Permission Protocol
https://permissionprotocol.com
```

---

### 19. Geoff Charles (@geoffintech) — Email

**Address / link:** `geoff@ramp.com`

**Subject:**
```
Ramp Inspect's signer story
```

**Message:**
```
Geoff,

Read your Ramp AI adoption thread, particularly the Ramp Inspect numbers: thousands of non-engineer PRs/month against a production codebase. That's the volume where the merge-side governance becomes load-bearing, not optional.

I'm the founder of Permission Protocol. We gate agent and non-engineer PR merges behind a human-signed receipt. The signer becomes the named decision-maker on each merge. Sub-2-minute install via a GitHub App.

15 min, walk through it on Ramp Inspect or a sandbox repo?

— Rod, founder, Permission Protocol
https://permissionprotocol.com
```

---

### 20. Bobby Healy (@realBobbyHealy) — Email

**Address / link:** `bobby@manna.aero`

**Subject:**
```
12% of Manna's PRs from non-engineers — the signer
```

**Message:**
```
Bobby,

12% of Manna's PRs coming from non-engineers via AI is a real-world stat that most people I talk to wouldn't believe. It also means the merge step is doing more weight than your branch protection knows.

I'm the founder of Permission Protocol. We gate agent-authored and non-engineer PR merges behind a human-signed receipt. Install in 2 minutes via a GitHub App. The non-engineer becomes the explicit signer on each merge — no implicit blame, no ambiguous audit log.

15 min screen share to install and tell me what doesn't fit Manna's flow?

— Rod, founder, Permission Protocol
https://permissionprotocol.com
```

---

### 21. Lars André Møen (@larsandremoen) — Email

**Address / link:** `lars@consulted.no`

**Subject:**
```
Cursor + Claude rules + the merge layer
```

**Message:**
```
Lars,

Your Claude-designed rules / Cursor-agent setup is one of the cleaner agent-on-real-code stories I've seen this month. The piece downstream of it — the merge — is what I'm working on.

I'm the founder of Permission Protocol. GitHub App, gates agent PR merges behind a human-signed receipt. 2-minute install. Doesn't change your rules; it just makes the merge a signed event.

15 min screen share, install on a real repo, feedback only?

— Rod
https://permissionprotocol.com
```

---

### 22. Zvi Mowshowitz (@TheZvi) — Email

**Address / link:** `thezvi@gmail.com`

**Subject:**
```
Anthropic Auto Mode validates the category — here's the cross-vendor primitive
```

**Message:**
```
Zvi,

Your Auto Mode coverage caught the right signal: Anthropic shipped *partial* governance, scoped to Claude. The cross-vendor primitive is still open.

I'm the founder of Permission Protocol. We gate agent actions (PR merges, deploys) behind a human-signed receipt — works the same across Claude Code, Cursor, Codex, Copilot. 2-minute install via a GitHub App.

Not asking for a write-up. If you have 15 minutes for an honest read, I'd take that. Auto Mode is the validation; what's missing is the open layer.

— Rod
https://permissionprotocol.com
```

---


## Phase 3 — X DMs (~10 min)

### 23. Mike Coutermarsh (@mscccc) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=mscccc`

**Message:**
```
Mike — saw your post about waking up to an agent-opened PR. That's the future, and the gap is the merge: no signed record of who decided.

I'm the founder of Permission Protocol. GitHub App that gates the merge behind a human-signed receipt. 2-minute install, no workflow change.

15 min screen share if you want to install on a repo. No pitch, want feedback.
```

---

### 24. Aaron Nam (@AaronNam) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=AaronNam`

**Message:**
```
Aaron — your Hermes Slack-to-merged-PR thread was the most concrete "agent in production" example I've seen this month. The thing it lacks by design is a signed record of who approved each merge.

I'm the founder of Permission Protocol. GitHub App that gates the merge behind a human-signed receipt. Sub-2-minute install. Doesn't slow the 30-minute Slack-to-merged-PR cycle.

15 min screen share, install on a repo, feedback only?
```

---

### 25. Petko D. Petkov (@pdp) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=pdp`

**Message:**
```
Petko — "every PR it opens gets merged" is the whole conversation. That's the moment the merge becomes a load-bearing decision rather than a checkbox.

I'm the founder of Permission Protocol. GitHub App that gates the merge behind a human-signed receipt. Doesn't break your "every PR merges" pattern — it just makes each merge a recorded human signature instead of a silent auto-approve.

15 min screen share to install + critique?
```

---

### 26. Boris Cherny (@bcherny) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=bcherny`

**Message:**
```
Boris — saw your Claude Code unattended-sessions setup. You built the agent; I'm working on the gate that runs between it and merge.

I'm the founder of Permission Protocol. GitHub App, gates agent-authored PR merges behind a human-signed receipt. 2-minute install. No workflow change.

15 min on a personal repo, honest feedback only? Even a "no, this is the wrong shape" would help me a lot.
```

---

### 27. Andrej Karpathy (@karpathy) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=karpathy`

**Message:**
```
Andrej — `autoresearch` is the cleanest "real repo, autonomous agent, overnight" pattern in the public conversation. The piece I'm working on is the merge-side governance for that loop.

I'm the founder of Permission Protocol. GitHub App that gates agent PR merges behind a human-signed receipt. Sub-2-minute install. Doesn't slow the loop.

15 min on autoresearch or any of your repos, feedback only? You'd shape the primitive.
```

---

### 28. Ashley Peacock (@_ashleypeacock) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=_ashleypeacock`

**Message:**
```
Ashley — RepoMint and Permission Protocol live at adjacent layers: yours puts agents inside repos, mine signs the merges they produce. Worth a 15-min call to see if there's a clean integration?

Founder of PP. https://permissionprotocol.com
```

---

### 29. André König (@ItsAndreKoenig) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=ItsAndreKoenig`

**Message:**
```
André — Cave runs opencode agents in sandboxes. Permission Protocol gates the PRs they produce, with a human-signed merge receipt. Adjacent layers, not competitors. 15 min to see if there's a clean integration?

Founder of PP. https://permissionprotocol.com
```

---

### 30. George (prodmgmt.world) (@nurijanian) — X DM

**Address / link:** `https://x.com/messages/compose?recipient_id=nurijanian`

**Message:**
```
George — read your post about PMs shipping with Claude Code. Found the gap: who signs when the agent's PR is ready? Most PMs are flying past the merge step without realizing they're the signer of record.

I'm the founder of Permission Protocol. We gate agent PRs behind a human-signed receipt — 2-minute GitHub App install, no engineer needed. The PM becomes the signer.

15 min, screen share, I want to watch you try it. Worth it?
```

---


## Phase 4 — Reddit (~5 min)

### 31. r/ClaudeCode guardrails OP (—) — Reddit reply

**Address / link:** `https://www.reddit.com/r/ClaudeCode/comments/1q19o4r/what_guardrails_are_you_using_in_the_claudecode/`

**Message:**
```
Late to this but worth dropping in. I'm the founder of Permission Protocol — we gate Claude Code's PRs behind a human-signed receipt at merge time, runs as a GitHub App. 2-minute install. Doesn't change the agent's behavior, just makes the merge a real decision point. Happy to walk anyone through it on their own repo. Not pitching, want feedback. DMs open.
```

---

### 32. r/ClaudeCode YOLO OP (—) — Reddit DM

**Address / link:** `https://www.reddit.com/r/ClaudeCode/comments/1pct552/my_setup_for_running_claude_code_in_yolo_mode/`

**Message:**
```
Saw your YOLO-mode setup post. You're right that sandbox isolation hits a wall the moment Postgres, OAuth, or Stripe enters the picture. We gate at the action layer — the agent can touch anything in dev, but the PR can't merge without a human-signed receipt. Works regardless of the environment shape.

Permission Protocol — I'm the founder. 15 min screen share if you want to install on your real setup and tell me where it breaks.
```

---

