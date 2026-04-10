-- crons/ledger_schema.sql
-- Minimal SQLite schema for cron telemetry and signer-gated workflows

CREATE TABLE IF NOT EXISTS cron_definitions (
    cron_id TEXT PRIMARY KEY,
    name TEXT,
    purpose TEXT,
    owner TEXT,
    cadence TEXT,
    enabled BOOLEAN DEFAULT 1,
    default_model TEXT,
    budget_usd_day REAL,
    expected_artifact_type TEXT,
    success_slo REAL,
    kill_criteria TEXT
);

CREATE TABLE IF NOT EXISTS cron_runs (
    run_id TEXT PRIMARY KEY,
    cron_id TEXT NOT NULL REFERENCES cron_definitions(cron_id),
    started_at DATETIME,
    finished_at DATETIME,
    status TEXT, -- (success | degraded | noop | failed | timeout)
    current_step TEXT, -- (detected | bundled | repro_succeeded | repro_failed | candidate_fix_generated | verification_passed | verification_failed | draft_pr_opened | approval_request_created)
    idempotency_key TEXT UNIQUE,
    incident_fingerprint TEXT,
    attempt_count INTEGER DEFAULT 1,
    model TEXT,
    input_tokens INTEGER,
    output_tokens INTEGER,
    runtime_ms INTEGER,
    api_cost_usd REAL,
    tool_calls_json TEXT,
    prompt_version TEXT,
    code_version TEXT,
    error_class TEXT,
    error_summary TEXT
);

CREATE TABLE IF NOT EXISTS artifacts (
    artifact_id TEXT PRIMARY KEY,
    run_id TEXT NOT NULL REFERENCES cron_runs(run_id),
    type TEXT, -- (alert | incident_bundle | draft_pr | outreach_draft | report)
    title TEXT,
    external_ref TEXT,
    url TEXT,
    verification_status TEXT,
    base_sha TEXT,
    head_sha TEXT,
    tree_sha TEXT,
    diff_hash TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(run_id, type, external_ref)
);

CREATE TABLE IF NOT EXISTS approval_requests (
    request_id TEXT PRIMARY KEY,
    artifact_id TEXT NOT NULL REFERENCES artifacts(artifact_id),
    action_type TEXT,
    action_payload_hash TEXT UNIQUE,
    repo TEXT,
    base_branch TEXT,
    target_sha_or_diff_hash TEXT,
    policy_hash TEXT,
    signer_required TEXT,
    required_signers_json TEXT,
    status TEXT,
    receipt_id TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME
);