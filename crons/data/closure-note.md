# Error-Sensor Actuator Sprint Closure (2026-04-08)

## 1. What's Proven
The core infrastructure for an autonomous, signer-gated repair loop is now fully proven against a bounded sandbox repository:
*   **Actuator Mechanics:** Deterministic `repro` → `fix` → `verify` loop executing strictly inside an ephemeral `/tmp` git worktree for two failure classes (`test_failure` and `typecheck_failure`).
*   **Cryptographic Binding:** `diff_hash` and `head_sha` are extracted deterministically *after* the local repair commit, guaranteeing the `approval_request` is explicitly bound to the exact code change, not a mutable PR ID.
*   **Resiliency:** The state machine (`crons_runs` + `artifacts` in SQLite) gracefully handles idempotency, process crashes, and complete node-loss events (worktree destruction), recovering perfectly to the last stable milestone.
*   **Shadow Intake:** Real GitHub Actions payloads from `permission-protocol-app` can be successfully ingested, normalized, fingerprinted, and deduped into the SQLite ledger.
*   **Telemetry Hygiene:** Shadow-mode monitoring purposefully stops at the `detected` milestone and registers as a `success` to avoid polluting degraded-run telemetry.

## 2. What's Intentionally Not Built
To preserve focus on distribution and avoid premature complexity, the following were explicitly deferred:
*   **Generic LLM Patching:** `fix.ts` remains a deterministic string-replacer tailored to specific sandbox fixtures. We are not blindly feeding code to an LLM yet.
*   **Live Actuation:** Shadow mode will not generate patches, branches, or PRs against real repositories.
*   **Sentry Integration:** Ingestion remains strictly limited to GitHub Actions workflow failures to prevent noisy, environment-dependent pollution.
*   **Multi-Repo Actuation:** We are not running the actuator against `permission-protocol-app` or `core` to avoid monorepo/package-manager confounders.

## 3. What Would Justify Reopening
This actuator sprint remains locked until the following conditions are met:
1.  **Queue Quality (24-48h Bake):** Shadow mode must passively collect 10-20 high-signal, deduped GitHub failures demonstrating a clean supportability distribution (low garbage rate).
2.  **Strategic Necessity:** The next layer of complexity (Assisted Live Actuation or Generic LLM Patching) must be explicitly required to close a revenue pipeline deal or materially improve a demo.

## Next Focus
Immediate shift back to **distribution**, **revenue**, and **demo leverage**.