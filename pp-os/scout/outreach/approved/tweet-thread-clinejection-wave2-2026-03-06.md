# Tweet Thread — Clinejection Secondary Wave
**Account:** @PermissionPrtcl
**Status:** APPROVED
**Approved by:** Rod (2026-03-06 09:54 MST)
**Priority:** 🔴 HIGH — time-sensitive (trending now)
**Type:** Original thread (3 tweets)

---

## Tweet 1
An attacker typed a GitHub issue title. That title compromised Cline's production releases and pushed a backdoored package to ~4,000 developer machines.

No exploit kit. No zero-day. Just a sentence that an AI triage bot treated as an instruction.

🧵

## Tweet 2
The attack chain:
1. Prompt injection in issue title
2. AI triage bot (Claude Code) runs `npm install` on attacker's package
3. Cache poisoning crosses workflow boundaries
4. Nightly release workflow loads poisoned cache
5. Attacker steals NPM publish secrets

Every step was "authorized" — by the agent itself.

## Tweet 3
This is what deploying agents without a permission layer looks like.

The bot couldn't distinguish "instruction from a maintainer" from "instruction from an attacker." Because there was no external checkpoint. No receipt. No gate.

Agents need authorization infrastructure, not just monitoring.

---

**Source:** https://simonwillison.net/2026/Mar/6/clinejection/
