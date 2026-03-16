# PP Voice Guide — Writing Rules

*Applied to everything: blog posts, landing pages, docs, CLI output, outreach, pitch decks, issue descriptions.*

---

## Core Principle

**Be clear, not clever.** If a sentence is trying to impress, rewrite it until it's trying to inform.

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
