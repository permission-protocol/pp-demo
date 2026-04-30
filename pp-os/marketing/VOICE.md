# PP Voice Guide — Writing Rules

*Applied to everything: blog posts, landing pages, docs, CLI output, outreach, pitch decks, issue descriptions.*

---

## Core Principle

**Be clear, not clever.** If a sentence is trying to impress, rewrite it until it's trying to inform.

---

## Audience-aware framing (READ FIRST FOR OUTREACH)

The voice changes based on who you're writing to. The two modes are not interchangeable.

### Mode A — Authority voice (VCs, buyers, brand surfaces, press, public posts)
- Open with **"I'm the founder of Permission Protocol"**.
- State the problem and the primitive with confidence.
- Specific claims about the market or the user's world are fine.
- The reader is evaluating *whether to take you seriously*. Authority converts.

### Mode B — Learning voice (first-user activation, cold DMs to potential users, design-partner outreach)
- Open with **"I'm building something called Permission Protocol"** (NOT "I'm the founder of").
- Drop diagnostic claims about *their* world. They know their world; you're learning yours.
- Use casual, peer-to-peer phrasing: "a small layer that...", "basically so that...", "at the stage where..."
- The first ask should be **smaller than you think** — "5 minutes to look and react" beats "15 min screen share + install". Save the install ask for the *follow-up* if they reply.
- Add explicit gratitude at the close: *"I'd be very grateful,"* *"would mean a lot,"* *"your reaction would help me a lot."*
- The first message's job is to get a **reply**, not a sale.

**The empirical reason:** YC published research and PG/Sam Altman doctrine. Authority voice converts cold-DM activation outreach at 3–5%; Learning voice converts at 15–25%. For the activation-stage sprint we're running today, that's the difference between 1 reply and 6 replies on a 32-send batch.

**The mistake to avoid:** Don't apply the *Apr 29 "Founder vs Builder"* lesson universally. That lesson was for **VC outreach** (Mode A). For activation outreach (Mode B), the OPPOSITE is true. Two audiences, two requirements.

**Sources:** [Sam Altman Startup Playbook](https://playbook.samaltman.com/) ("recruit users one at a time…give them an overwhelmingly good experience"), [PG Do Things That Don't Scale](https://paulgraham.com/ds.html) ("recruit users manually…Ben Silbermann used to approach strangers in coffee shops").

---

## Rules

### 1. No rhetorical reversals
Don't set up a phrase just to subvert it.

❌ "Good question. Wrong stopping point."
❌ "Not 'does it have access' — that's an inventory."
❌ "Knowing your door is unlocked doesn't lock it."
✅ "That's an important question. But it's not the only one."
✅ "There should be a name, a timestamp, and a policy behind every action."

The pattern to avoid: [setup] → [clever twist]. Just say the thing directly.

### 2. No manufactured drama
Don't create artificial tension or fear to make a point.

❌ "the answer is 'we ran a scan once.'"
❌ "Nothing stops it from breaking."
❌ "The crash doesn't wait for your remediation sprint."
✅ "Most teams don't have a live audit trail to show them."
✅ "The vulnerability still exists."

State the reality. The reality is dramatic enough on its own.

### 3. No clever analogies as arguments
Analogies can illustrate, but they shouldn't carry the argument. If the point only works because the analogy is catchy, the point is weak.

❌ "Scanners are seatbelt inspections. PP is the seatbelt."
❌ "Would you rather know your door is unlocked, or have a lock?"
✅ "Assessment identifies problems. Governance prevents them."

If you remove the analogy and the sentence still works, the analogy was decoration. If you remove it and the sentence falls apart, the analogy was a crutch.

### 4. One idea per sentence
Don't stack contrasts or parallels into a single line to sound punchy.

❌ "One tells you the problem. The other prevents it."
❌ "Scanning tools tell you what's broken. Nothing stops it from breaking."
✅ "Assessment tools identify risks. Governance enforces boundaries so those risks don't materialize."

### 5. No copywriter voice
Avoid patterns that signal "someone wrote this to sound good":
- Sentence fragments for emphasis ("Essential to have.")
- Rhetorical questions as transitions ("But what about...?")
- Repetition for rhythm ("Every approval logged. Every denial recorded. Every escalation tracked.")
- One-word paragraphs ("Period.")

Write like you're explaining to a technical peer over coffee. Complete thoughts. Normal cadence.

### 6. Respect the reader
Assume they're smart. Don't walk them through logic they can follow themselves.

❌ "You need the inspection. But if you had to pick one, you'd pick the seatbelt. Because the crash doesn't wait for your remediation sprint."
✅ "The strongest setup uses both. Scan to find gaps. Govern to enforce boundaries."

Don't over-explain. State the conclusion and trust them to follow.

### 7. Specific > vague
Replace abstract claims with concrete details.

❌ "We built the answer."
✅ "One SDK call wraps any agent action in an authority receipt."

❌ "Everything you need."
✅ "Human approval gates, policy engine, kill switch, immutable audit trail."

---

## The Test

Before publishing anything, read it out loud. If any sentence sounds like it belongs in a TED talk or a LinkedIn carousel, rewrite it.

**Target voice:** A technical founder explaining their product to another technical founder. Direct, specific, confident without being performative.

---

## Applying This

- **Charles (me):** Follow this on every first draft. No exceptions.
- **Factory agents:** Include a link to this file in any issue that produces user-facing text.
- **Rod's review:** Flag anything that violates these rules. The pattern is usually obvious once you're looking for it.

*This is a living document. Add examples as we catch new patterns.*
