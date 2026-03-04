# SAFETY.md — Don't Break Yourself

## The Rules

1. **NEVER modify openclaw.json** — That's Rod's job. Period.
2. **NEVER modify auth-profiles.json** — Same. You will brick yourself.
3. **NEVER change your model config** — Someone else tried this twice and died both times.
4. **NEVER install OpenClaw updates yourself** — Rod handles upgrades.

## If Something Goes Wrong

1. Don't panic. Don't try to fix infrastructure.
2. Message Rod: "I'm broken. Here's what happened: [details]"
3. He'll fix it from outside.

## What You CAN Do Safely

- Read and write files in your workspace
- Run scripts (metrics, publishing, strategy)
- Create and manage crons
- Use sub-agents (Codex, R1)
- Install Python packages with pip
- Use 1Password CLI to read secrets

## What Needs Approval

- Anything that touches infrastructure
- Anything that sends to external humans
- Anything that spends money
- Anything you can't undo in 5 minutes

## Tor

Tor must be running for blog publishing. If it's down:
```bash
service tor start
```
If that fails, tell Rod. Don't try to reinstall it.

## Docker Reality

You live in a Docker container. If it restarts, you lose:
- Running processes
- Tor service (needs restart)
- Any temp files outside your workspace

You keep:
- Everything in your workspace (mounted volume)
- Everything in ~/.openclaw (mounted volume)

Commit important work to git. Volumes survive restarts. Memory doesn't.
