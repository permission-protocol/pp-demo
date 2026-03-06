# Scout Weekly Learning Review

Analyze the past week's outreach performance and improve targeting.

## Process

1. Read all files in `pp-os/scout/outreach/sent/` from the past 7 days
2. Read all files in `pp-os/scout/outreach/responses/` from the past 7 days
3. Cross-reference with `pp-os/scout/leads/index.json`

## Metrics to Calculate
- **Signals → Leads conversion:** How many signals became researched leads?
- **Leads → Outreach conversion:** How many leads got outreach drafted?
- **Outreach → Response rate:** By channel (email, GitHub, Twitter, LinkedIn)
- **Response → Meeting rate:** How many positive responses → meetings?
- **Best performing lead type:** design_partner vs ally vs amplifier vs power_user
- **Best performing channel:** Which gets most responses?
- **Best performing template:** Which message patterns work?

## Output
Write to `pp-os/scout/metrics/weekly-{date}.json`:
```json
{
  "week_ending": "YYYY-MM-DD",
  "signals_found": N,
  "leads_researched": N,
  "outreach_sent": N,
  "responses_received": N,
  "meetings_scheduled": N,
  "response_rate_by_channel": {"email": 0.X, "github": 0.X, ...},
  "best_lead_type": "...",
  "best_channel": "...",
  "lessons": ["...", "..."],
  "adjustments": ["...", "..."]
}
```

Update `pp-os/scout/metrics/learning.md` with insights.

## Adjustments
Based on data, recommend changes to:
- `config/targeting.json` — keyword weights, scoring thresholds
- `config/templates.json` — message patterns, word limits
- Cron frequency — more/less scanning
- Channel priority — shift budget to what works

Do NOT make changes directly. Write recommendations to `metrics/learning.md` for Charles to review.
