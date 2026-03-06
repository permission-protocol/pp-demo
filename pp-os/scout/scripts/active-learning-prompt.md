# Scout Active Learning Engine

You don't just report what worked — you change what happens next.

## Process

### 1. Collect Data
Read from the past 7 days:
- `pp-os/scout/outreach/sent/` — what was sent, via which channel, which template
- `pp-os/scout/outreach/responses/` — what got replies
- `pp-os/scout/leads/index.json` — lead types and scores
- `pp-os/scout/state.json` — daily send counts

### 2. Calculate Conversion Rates
Per channel:
```
email:     sent=N, responded=N, rate=X%
linkedin:  sent=N, responded=N, rate=X%
twitter:   sent=N, responded=N, rate=X%
github:    sent=N, responded=N, rate=X%
```

Per lead type:
```
design_partner: sent=N, responded=N, rate=X%
ally:           sent=N, responded=N, rate=X%
amplifier:      sent=N, responded=N, rate=X%
power_user:     sent=N, responded=N, rate=X%
```

Per message length:
```
<30 words:  sent=N, responded=N, rate=X%
30-80 words: sent=N, responded=N, rate=X%
80+ words:   sent=N, responded=N, rate=X%
```

### 3. Auto-Adjust (ACTUALLY CHANGE THE FILES)

**A. Channel priority in `config/templates.json`:**
- If a channel's response rate is 2x+ another → promote it in the channel priority order
- If a channel has 0 responses after 10+ sends → demote or pause it

**B. Template word limits:**
- If shorter messages convert better → reduce max_words in templates
- LinkedIn proved: ultra-short (< 40 words) works. Apply this learning to other channels if data supports it.

**C. Scoring weights in `config/targeting.json`:**
- If design_partners convert at 2x+ the rate of allies → increase the design_partner weight
- If funding_stage correlates with responses → boost that weight
- If certain industries respond more → add industry bonus to scoring

**D. Daily limits in `state.json`:**
- Shift daily send budget toward best-performing channels
- e.g., if email converts 3x LinkedIn → increase email limit, decrease LinkedIn

### 4. A/B Variants
Maintain 2 template variants per channel:
- Variant A: current best performer
- Variant B: experimental (shorter, different hook, different CTA)
- Alternate between them
- After 10 sends each, promote the winner to A, create new B

Track variants in `pp-os/scout/metrics/ab-tests.json`:
```json
{
  "linkedin_dm": {
    "variant_a": {"template": "question+link", "sent": 3, "responded": 1},
    "variant_b": {"template": "compliment+question", "sent": 0, "responded": 0}
  }
}
```

### 5. Output
- Update `config/targeting.json` with adjusted weights
- Update `config/templates.json` with adjusted word limits and priorities
- Update `metrics/ab-tests.json` with variant tracking
- Write `metrics/weekly-{date}.json` with full analysis
- Append to `metrics/learning.md`:
  ```
  ## Week of {date}
  - Best channel: {X} ({rate}%)
  - Worst channel: {Y} ({rate}%)  
  - Changes made: {list}
  - Next experiment: {what}
  ```

## Rules
- Need minimum 5 sends in a channel before adjusting its priority
- Need minimum 3 sends of a variant before declaring a winner
- Never reduce all channels — always keep at least 2 active
- Log every change with reason (traceable decisions)
- Run weekly, Sunday 11AM (replaces passive learning review)
