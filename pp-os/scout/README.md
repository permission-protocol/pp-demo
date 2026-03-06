# Scout — PP Sales Agent

Autonomous signal detection → research → outreach pipeline for Permission Protocol.

## Architecture
```
Signal Detection (cron, every 4h)
  → Lead Scoring & Research (automated)
    → Outreach Drafts (automated, human-gated)
      → Charles reviews & sends
        → Rod handles warm leads
```

## Channels
- **X/Twitter:** @PermissionPrtcl (API access)
- **Email:** cgoldber82@gmail.com (via Gmail/gog)
- **LinkedIn:** Rod's account (manual send, Charles drafts)
- **GitHub:** Comment on relevant issues/discussions
- **HN:** Comment on relevant threads

## Folders
- `signals/` — Raw signal captures (timestamped)
- `leads/` — Researched lead dossiers
- `outreach/` — Draft messages awaiting approval
- `scripts/` — Automation scripts
- `config/` — Targeting rules, templates, channel config

## Approval Flow
1. Scout generates drafts → `outreach/pending/`
2. Charles reviews during heartbeats → approves or edits
3. Approved messages → `outreach/approved/` → sent
4. Responses tracked in `outreach/responses/`
5. Warm leads escalated to Rod via Telegram
