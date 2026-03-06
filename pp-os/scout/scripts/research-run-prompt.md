# Scout Research Run

Read `pp-os/scout/signals/latest-scan.json` for new research targets.
For each target with action "research", build a lead dossier following the process in `pp-os/scout/scripts/research-engine-prompt.md`.

Use web_search and web_fetch to research each company:
1. Company website — what they do, what agents they run
2. Crunchbase/funding data — stage, investors, total raised
3. Team — CEO, CTO, security lead, contact info
4. Tech stack — from job postings, GitHub, docs
5. PP fit — which agent actions need receipts

Write dossiers to `pp-os/scout/leads/{slug}.json`.
Update `pp-os/scout/leads/index.json` with new entries.
Mark leads scoring 4.0+ as "outreach_ready".

After research, update `pp-os/scout/state.json` with last_research_run timestamp.

Do NOT send any outreach. Research only.
