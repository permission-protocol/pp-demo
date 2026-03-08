# Content: Clinejection — The Gap Between Access and Authorization
**Platform:** linkedin
**Type:** incident_reaction
**Signal:** https://simonwillison.net/2026/Mar/6/clinejection/
**Priority:** hot
**Timeliness:** Publish today — trending NOW (Simon Willison coverage + secondary wave)

## Content

4,000 developer machines. One GitHub issue title.

That's the Clinejection attack — a prompt injection via a malicious issue that hijacked an AI triage bot and poisoned the npm release pipeline. No malware. No phishing. Just text the bot read and treated as a command.

Here's what happened architecturally: the agent had legitimate access to GitHub and the release pipeline. It read the issue. It interpreted the content. It acted on it. No system ever asked whether that specific action was authorized.

That's not a bug. That's the default design.

Most AI agents self-authorize. They infer intent from context and execute. The access control you set up — role-based permissions, API keys, OAuth scopes — controls what the agent *can* reach. It doesn't control what the agent *decides to do* with that reach.

Those are two different problems.

The Clinejection bot had every permission it needed to do its job. The attacker didn't exploit a misconfigured permission — they exploited the gap between observation and action. Read a thing → act on it. No gate in between.

PP is built to close that gap. Authorization at the action boundary, not just the access boundary. Signed receipt before the pipeline runs. If the receipt isn't there, nothing executes — regardless of what the agent read.

A malicious issue title is noise if the agent doesn't have authority to act on it.

The attack surface isn't just what your agents can access. It's what they can self-authorize.

## Image
N/A (LinkedIn doesn't use auto-gen image for this format)

## Approval
- [x] Human-gated (LinkedIn post)
- [ ] Auto-approved

Status: draft
Created: 2026-03-06T08:06:00-07:00
