# Scout Follow-up Checker

Check for leads that need follow-up and draft second-touch messages.

## Process

1. Read `pp-os/scout/outreach/sent/` — find messages sent 3+ days ago
2. Cross-reference with `pp-os/scout/outreach/responses/` — skip if already responded
3. For leads with no response after 72h, draft a follow-up

## Follow-up Rules
- **Email:** Short, different angle. Reference something new (a tweet, a blog post, a new incident). Max 3 sentences.
- **Twitter DM:** Like one of their recent tweets first (engagement signal), then follow up 24h later
- **GitHub:** NO follow-up. They'll respond or they won't.
- **LinkedIn:** NO follow-up on first message.
- **Max 2 follow-ups total per lead.** After that, mark as `cold` and wait 30 days.

## Follow-up Template
```
Subject: Re: {original subject}

{Name} — quick follow-up. {New hook: recent incident/news/their tweet about agents}.

Our SDKs are live if you want to test: pip install permission-protocol

Happy to do a 15-min walkthrough anytime.

Rod
```

## Output
Save follow-ups to `pp-os/scout/outreach/pending/{slug}-followup-{n}.md`
Update lead status to `followup_pending`
