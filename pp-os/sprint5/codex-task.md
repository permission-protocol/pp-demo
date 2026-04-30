# Sprint 5 Outreach Enrichment Task

You are running an enrichment pass for Permission Protocol's 72-hour validation sprint. Read SPEC.md fully before starting. Read source-list.md fully. Then execute.

## What you must do

1. **Parse source-list.md into prospects.json**: 50 founder/CTO rows (List 1) + 10 VC rows (List 2) + 5 named ex-employee rows (List 3, the 5 with names — skip the 15 search-slot placeholders, but include them as 15 stub rows with `[SALES_NAV: <company> <role>]` in the LI_Original field for Rod to run manually).

2. **Verify + enrich each row** using web_search (via curl to Brave Search API or DuckDuckGo HTML, or the WebFetch tool if available — use whatever your harness provides). For each prospect:
   - Confirm the LinkedIn URL resolves and the bio matches the listed company.
   - Hunt for a verifiable email. Sources to check: company "About"/"Team"/"Contact"/"Press" pages, founder personal site, Twitter/X bio, GitHub profile/commits (search `git log --format='%ae'` style mentions in their public repos), Crunchbase, ProductHunt maker page, podcast show notes where they appeared, conference speaker pages, recent press releases with quotes.
   - If hook is `[HOOK – VERIFY]`, find ONE verifiable recent fact from last 6 months.
   - **Never fabricate.** Empty Email beats invented Email. Record EmailSource URL.

3. **Write the two new message variants per row**:
   - `LI_PilotHook` (≤290 chars) — see SPEC.md template
   - `Email_Long` (4–6 sentences with `Subject: ...` first line) — see SPEC.md template

4. **Tier and sort**:
   - Tier A: 🟢 + verified email (top priority, send via email Wed AM)
   - Tier B: 🟢, LI only (Wed midday)
   - Tier C: 🟡 verified (Wed PM)
   - Tier D: 🔴 — only keep if you verified them yourself; else drop

5. **Write outputs**:
   - `pp-sprint5-master.csv` with the full schema from SPEC.md
   - `EXECUTE.md` — one-page runbook for Rod tomorrow
   - `enrichment-log.md` — note which rows you dropped and why, which emails you found (cite source), which hooks you replaced

## Hard rules
- No fabricated emails, ever. If you can't cite a source, leave Email blank.
- Use real public sources only. If a source doesn't load, mark it and move on.
- Aim for high signal: better to ship 50 verified rows than 80 mixed rows.
- If you hit search rate limits, slow down — don't fall back to invention.
- Time budget: ~2-3 hours. Don't spiral. If verification on a row takes >3 min, mark it Tier C/D and move on.

## Time of day
Tonight (Tue Apr 28 evening MDT). Rod sends Wed Apr 29 all day.

## Final deliverable structure
```
pp-os/sprint5/
├── SPEC.md (already there)
├── source-list.md (already there)
├── source-csv.csv (already there, do not use emails from it)
├── prospects.json (your parse + enrichment intermediate)
├── pp-sprint5-master.csv ⭐ Rod sends from this
├── EXECUTE.md ⭐ Rod's runbook
└── enrichment-log.md (your audit trail)
```

When done, write a one-paragraph summary to `DONE.md` with: row counts per tier, # emails verified, # hooks verified, # rows dropped, biggest unknowns.

Begin now.
