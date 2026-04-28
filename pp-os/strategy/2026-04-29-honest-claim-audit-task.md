# Honest Claim Audit — Wednesday Apr 29 (Charles task)

**Status:** READY (no Rod approval needed, copy edit only)
**Deadline:** Apr 29 EOD
**Owner:** Charles (delegate to Codex)

## Why this is non-negotiable

For a security product, marketing language outpacing implementation is fatal. Current site uses "cryptographic / signed / immutable / non-repudiable" while Ed25519 signing has not actually shipped end-to-end. If Ed25519 doesn't ship by May 5 (which it won't under the build moratorium), every public-facing claim must be softened immediately.

## Scope

Repository: `permissionprotocol-site` (need to clone fresh tomorrow — not on local host)

Search & replace audit:

| Current language | Soften to | Notes |
|---|---|---|
| "cryptographically signed" | "tamper-evident" | unless Ed25519 verifier is live at /r/* |
| "cryptographic receipt" | "audit receipt" | |
| "signed receipt" | "tamper-evident receipt" | unless verifier is live |
| "immutable" | "tamper-evident" or remove | |
| "non-repudiable" | remove or "auditable" | |
| "cryptographic verification" | "verification" | |

## Pages to audit (priority order)

1. `/` (homepage hero + value prop)
2. `/platforms` (Action Gate page)
3. `/deploy-gate` (Merge Gate page)
4. `/r/<receipt_id>` (verifier page — keep accurate to actual implementation)
5. `/docs/*`
6. README, OG images, social copy

## When to restore

Strong language (cryptographic / signed / Ed25519) restored only when:
1. Ed25519 signing is live in production
2. Public verifier at `/r/<receipt_id>` validates real signatures
3. At least one signed receipt exists in the wild

Until all 3 are true: tamper-evident only.

## Delegation

Spawn Codex with `coding-agent` skill, background. Task: clone permissionprotocol-site, run audit replace, open PR titled "Honest claim audit: soften language until Ed25519 ships".

## Risk if skipped

If a prospect on a validation call asks "is this actually cryptographically signed?" and we have to admit no, the call ends. We've already had this scar (Apr 17 PAT leak). Same lesson: don't ship security claims you can't back up.
