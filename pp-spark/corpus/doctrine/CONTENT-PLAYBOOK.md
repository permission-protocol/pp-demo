# Content Creation Playbook

*Born 2026-03-07. Evolved same day through 3 iterations with multi-model testing.*

---

## The Pipeline

### Step 0: Signal + Channel + Archetype
- **What happened?** (1-2 lines)
- **What are people saying?** (the default public framing)
- **What's wrong with that framing?** (what annoys me about the conversation)
- **What's the real issue?** (one sentence — if you can't say it in one sentence, you don't have it yet)
- **What doctrine principle does this reveal?** (check `DOCTRINE-LIBRARY.md`)
- **Post archetype:** Reframe / Doctrine / Breakdown / Prediction / Founder Lens / Category Creation
- **Which channels?** LinkedIn / X / Blog / HN — each gets its own adapted draft

### Step 1: Three Questions (per channel)
1. **Who is reading this?** (Technical? Executive? General audience?)
2. **What's the one feeling they should have?** Not the takeaway — the *feeling*.
3. **What's the one image they should see in their head?** No image = not ready.

### Step 2: Draft (3 versions per channel)
- Write 3 versions with different angles, drawing from the doctrine library
- Pick the best using the three questions as the filter
- Every draft MUST contain a concrete scene. Abstract-only = not ready.
- Default to "Sunday afternoon" not "enforcement layer"

### Step 3: Gemini 3.1 Pro Review — Diagnostic (automated via API)
Send to Gemini with diagnostic prompt + voice calibration + doctrine context.
Gemini identifies what's wrong and WHY. Does NOT rewrite.

**API:** `gemini-3.1-pro-preview` via `generativelanguage.googleapis.com`
**Key:** `~/.openclaw/secrets/gemini-api.json`

### Step 4: Self-Revise
Fix every flagged issue MYSELF using Rod's voice as reference.
No AI rewrites. I write the fixes.

### Step 5: GPT 5.4 Review — Authenticity (automated via API)
Send to GPT with authenticity prompt. GPT's only job: flag every line that sounds AI-generated.

**API:** `gpt-5.4` via `api.openai.com` (use `max_completion_tokens` not `max_tokens`)
**Key:** `~/.openclaw/secrets/openai-api-key.txt`

### Step 6: Self-Revise Again
Fix flagged AI phrases myself. Goal: sounds like a rattled founder, not composed thought leadership.

### Step 7: Civilian Reader Test (automated via API — Gemini Flash)
Prompt a model AS the target reader (not an editor). "Would you stop scrolling?"

**API:** `gemini-3-flash-preview` (cheapest, fast)

### Step 8: Editorial Checklist
Before presenting, run this gate:

**Thesis:**
- [ ] Exactly one core idea?
- [ ] Smart reader identifies the point in 10 seconds?

**Substance:**
- [ ] Concrete example/scene?
- [ ] Broader than the specific event?
- [ ] At least one quotable doctrine line?

**Voice:**
- [ ] Sounds like a founder with a thesis, not a commentator?
- [ ] No "LinkedIn thought leader template" phrases?
- [ ] Category-building voice, not content-production voice?

**Compression:**
- [ ] Can 15-25% more be cut?
- [ ] Nothing repetitive?
- [ ] Every paragraph earns its place?

**Strategic fit:**
- [ ] Reinforces PP's worldview?
- [ ] Product/category implied naturally, not forced?

### Step 9: Present to Rod
One message with:
- The final draft (copy-paste ready)
- One-line summary of what each reviewer flagged
- What I changed and why
- ✅ post / 🔄 revise / ❌ kill

### Step 10: Post-Publish
- Log to #published
- **Update DOCTRINE-LIBRARY.md** with any new strong lines, principles, or contrasts
- Save to swipe file if it performed well

---

## Channel Specs

### LinkedIn
- **Voice:** Thinker (how you see the world)
- **Length:** 1500-3000 characters
- **Structure:** Narrative arc with deliberate line breaks
- **Links:** NEVER in post body. First comment only.
- **Goal:** Stop the scroll, plant one idea
- **AI smell tolerance:** Very low
- **Key rule:** Double-returns between paragraphs

### X / Twitter
- **Voice:** Provocateur (sharp, edgy, opinionated)
- **Length:** 280 chars/tweet, 5-8 tweet threads
- **Structure:** Each tweet stands alone AND escalates
- **Links:** OK in tweets
- **Goal:** Spark debate, get QTs
- **AI smell tolerance:** Low
- **Key rule:** First tweet must work in isolation

### Blog
- **Voice:** Builder (prove depth, show you've built this)
- **Length:** 800-2000 words
- **Structure:** Argument with evidence, can be technical
- **Links:** Inline, encouraged
- **Goal:** Prove depth, SEO, reference material
- **AI smell tolerance:** Medium
- **Key rule:** Must add something the social posts don't

### Hacker News
- **Voice:** Technical peer (no marketing, no hype)
- **Length:** Title + URL only
- **Structure:** Blog post IS the submission
- **Links:** The submission IS the link
- **Goal:** Earn technical respect
- **AI smell tolerance:** Zero
- **Key rule:** If the title sounds like LinkedIn, HN will kill it

---

## Prompt Templates

### Gemini Diagnostic (Step 3)
```
You are reviewing a [CHANNEL] post for a tech founder. Be a harsh, honest editor.

CONTEXT:
- Author: Founder of an AI authorization startup
- Audience: [FROM STEP 1]
- Goal: [FEELING FROM STEP 1]. NOT a product pitch. Pure thought leadership.
- Platform: [CHANNEL + CONSTRAINTS]
- Post archetype: [FROM STEP 0]
- Voice calibration — lines that set the quality bar:
  [PASTE 4-5 LINES FROM DOCTRINE-LIBRARY.md → Strong Lines]

THE POST:
[DRAFT]

REVIEW (identify problems and explain WHY — do NOT rewrite):
1. Would the target audience stop scrolling? Why or why not?
2. Flag every phrase that sounds AI-generated. Be specific.
3. Any jargon that would lose a general business audience?
4. Is the scenario/hook vivid and earned?
5. What's the weakest section? Why?
6. What's the strongest line? Why?
7. Rate 1-10: scroll-stopping, emotional impact, clarity, memorability.
8. Compared to the voice calibration lines, does this match that quality?
```

### GPT Authenticity (Step 5)
```
You're checking a [CHANNEL] post for authenticity. Your ONLY job is detecting AI voice.

THE POST:
[REVISED DRAFT]

VOICE CALIBRATION:
[PASTE 4-5 LINES FROM DOCTRINE-LIBRARY.md → Strong Lines]

CHECK:
1. Flag every phrase that sounds AI-generated, synthetic, or templated. Be specific.
2. Does this read like a real founder who just saw something alarming, or like someone composing "thought leadership"?
3. Where does it feel "too written"? Where does it feel real?
4. Rate 1-10: how human does this sound?
5. Does it match the calibration voice in directness and punch?
```

### Civilian Reader (Step 7)
```
You are a [TARGET PERSONA]. It's [TIME/CONTEXT]. You see hundreds of posts a day and skip most.

Read this [CHANNEL] post and react honestly. Do NOT analyze as an editor.

THE POST:
[FINAL DRAFT]

REACT:
1. Skip, skim, read fully, or share?
2. Where exactly did you get hooked or lose interest?
3. One thing you'd remember an hour later?
4. Would you click the author's profile?
5. Would you comment? What would you say?
6. Does this make you want to check something at work?
7. Anything that made you think "this person is selling something"?
```

---

## Model Stack

| Model | Role | API | Key |
|---|---|---|---|
| **Gemini 3.1 Pro Preview** | Diagnostic (structure, craft) | generativelanguage.googleapis.com | gemini-api.json |
| **GPT 5.4** | Authenticity (AI voice detection) | api.openai.com | openai-api-key.txt |
| **Gemini 3 Flash Preview** | Civilian reader sim | generativelanguage.googleapis.com | gemini-api.json |
| ~~R1 on Spark~~ | ~~Nothing~~ | ~~Hallucinated in test~~ | ~~Dead~~ |

---

## Self-Improvement Rules

### Per-Draft Self-Check (before entering pipeline)
1. Did I write multiple versions and pick the best?
2. Does it have a scene someone can picture?
3. Would a non-technical person stop scrolling?
4. Am I ending on a truth or a product pitch?
5. Did I draw from the doctrine library?

### What NOT to Do
- Don't present a first draft for Rod to coach into shape
- Don't let models REWRITE — they diagnose, I fix
- Don't default to builder vocabulary for a thinker audience
- Don't use AI alternatives as replacement lines
- Don't skip the editorial checklist

### Ongoing
- **Update doctrine library** after every published post
- **Build the swipe file** — posts that actually land on each platform
- **Study how non-technical people talk about AI risks**

---

## Key Files

- `CONTENT-PLAYBOOK.md` — this file (the process)
- `DOCTRINE-LIBRARY.md` — the worldview (principles, contrasts, language, strong lines)
- `swipe-file/` — posts that work, organized by platform

---

*This playbook evolves. Update after every major content session.*
*Last updated: 2026-03-07*
