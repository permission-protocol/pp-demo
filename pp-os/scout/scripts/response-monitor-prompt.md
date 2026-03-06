# Scout Response Monitor

Check all channels for responses to PP outreach.

## Email
```bash
gog gmail list --query "is:inbox newer_than:1d" --max 20
```
Look for replies from any contacts in `pp-os/scout/leads/index.json`.
Check threads started by our outreach (search sent folder for Permission Protocol subjects).

## GitHub
Check for comments on issues we created:
- https://github.com/provos/ironcurtain/issues/67
- Any other issues listed in `pp-os/scout/outreach/sent/`

```bash
GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh api repos/provos/ironcurtain/issues/67/comments
```

## Response Classification
For each response found:
- **positive** → message Charles immediately with full context
- **meeting** → message Charles AND Rod — include suggested times
- **neutral** → log, schedule follow-up in 7 days
- **negative** → mark lead as "dead", add to do_not_contact in state.json

## Output
Update `pp-os/scout/outreach/responses/YYYY-MM-DD.json` with any responses found.
Update lead status in `pp-os/scout/leads/{slug}.json`.
Update `pp-os/scout/state.json` with last_response_check timestamp.

If no responses found, just update the timestamp silently.
