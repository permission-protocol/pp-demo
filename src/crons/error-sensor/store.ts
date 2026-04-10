import { randomUUID } from 'node:crypto';
import sqlite3 from 'sqlite3';
import { open, Database } from 'sqlite';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';

import type {
  ErrorSensorConfig,
  LedgerStore,
  PersistedRun,
  RunStatus,
  StableStep,
  NextAction,
} from './types';

export async function createLedgerStore(config: ErrorSensorConfig): Promise<LedgerStore> {
  await fs.mkdir('crons/data', { recursive: true });
  
  const db = await open({
    filename: 'crons/data/ledger.db',
    driver: sqlite3.Database
  });

  // Strict SQLite Pragmas
  await db.exec(`
    PRAGMA journal_mode = WAL;
    PRAGMA synchronous = NORMAL;
    PRAGMA busy_timeout = 5000;
    PRAGMA foreign_keys = ON;
  `);

  // Load schema
  const schemaPath = path.resolve('crons/ledger_schema.sql');
  const schema = await fs.readFile(schemaPath, 'utf-8');
  await db.exec(schema);

  return new SQLiteLedgerStore(db);
}

class SQLiteLedgerStore implements LedgerStore {
  constructor(private db: Database<sqlite3.Database, sqlite3.Statement>) {}

  async ensureCronDefinition(input: any): Promise<void> {
    await this.db.run(`
      INSERT INTO cron_definitions (
        cron_id, name, purpose, cadence, default_model, expected_artifact_type, budget_usd_day, success_slo, kill_criteria
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(cron_id) DO UPDATE SET
        name=excluded.name,
        purpose=excluded.purpose,
        cadence=excluded.cadence,
        default_model=excluded.default_model,
        expected_artifact_type=excluded.expected_artifact_type,
        budget_usd_day=excluded.budget_usd_day,
        success_slo=excluded.success_slo,
        kill_criteria=excluded.kill_criteria
    `, [
      input.cronId, input.name, input.purpose, input.cadence, input.defaultModel, 
      input.expectedArtifactType, input.budgetUsdDay, input.successSlo, input.killCriteria
    ]);
  }

  async recordNoopRun(input: any): Promise<void> {
    const runId = randomUUID();
    await this.db.run(`
      INSERT INTO cron_runs (run_id, cron_id, status, started_at, finished_at, error_summary)
      VALUES (?, ?, 'noop', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ?)
    `, [runId, input.cronId, input.reason]);
  }

  async createOrResumeRun(input: any): Promise<PersistedRun> {
    const existing = await this.db.get(`SELECT run_id, cron_id, status, current_step FROM cron_runs WHERE idempotency_key = ?`, [input.idempotencyKey]);
    if (existing) {
      return {
        runId: existing.run_id,
        cronId: existing.cron_id,
        status: existing.status as RunStatus,
        currentStep: existing.current_step as StableStep
      };
    }

    const runId = randomUUID();
    await this.db.run(`
      INSERT INTO cron_runs (
        run_id, cron_id, idempotency_key, incident_fingerprint, current_step, status, started_at
      ) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
    `, [
      runId, input.cronId, input.idempotencyKey, input.incidentFingerprint, input.initialStep, input.initialStatus
    ]);

    return {
      runId,
      cronId: input.cronId,
      status: input.initialStatus,
      currentStep: input.initialStep
    };
  }

  async getRun(runId: string): Promise<PersistedRun & { code_version?: string }> {
    const row = await this.db.get(`SELECT run_id, cron_id, status, current_step, code_version FROM cron_runs WHERE run_id = ?`, [runId]);
    if (!row) throw new Error(`Run ${runId} not found`);
    return {
      runId: row.run_id,
      cronId: row.cron_id,
      status: row.status,
      currentStep: row.current_step,
      code_version: row.code_version || undefined
    };
  }

  async getLatestArtifactId(input: { runId: string; type: string }): Promise<string | null> {
    const row = await this.db.get(
      `SELECT artifact_id FROM artifacts WHERE run_id = ? AND type = ? ORDER BY created_at DESC LIMIT 1`,
      [input.runId, input.type]
    );
    return row ? row.artifact_id : null;
  }

  async recordStepAttempt(input: { runId: string; action: NextAction }): Promise<void> {
    await this.db.run(`UPDATE cron_runs SET attempt_count = attempt_count + 1 WHERE run_id = ?`, [input.runId]);
  }

  async upsertArtifact(input: any): Promise<{ artifactId: string }> {
    const artifactId = randomUUID();
    await this.db.run(`
      INSERT INTO artifacts (
        artifact_id, run_id, type, title, external_ref, url, verification_status, diff_hash
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(run_id, type, external_ref) DO UPDATE SET
        title=excluded.title,
        url=excluded.url,
        verification_status=excluded.verification_status,
        diff_hash=excluded.diff_hash
    `, [
      artifactId, input.runId, input.type, input.title, input.externalRef, input.url, input.validationStatus, input.diffHash || null
    ]);

    // In a real scenario with ON CONFLICT, we might want to fetch the existing ID if it was an update.
    // For this implementation, returning the generated or existing one is fine.
    const row = await this.db.get(`SELECT artifact_id FROM artifacts WHERE run_id = ? AND type = ? AND external_ref = ?`, 
      [input.runId, input.type, input.externalRef || null]);
    
    return { artifactId: row.artifact_id };
  }

  async advanceRun(input: any): Promise<void> {
    await this.db.run(`
      UPDATE cron_runs 
      SET current_step = ?, code_version = ? 
      WHERE run_id = ?
    `, [input.currentStep, input.diffHash || null, input.runId]);
  }

  async stopRunDegraded(input: any): Promise<void> {
    await this.db.run(`
      UPDATE cron_runs 
      SET status = 'degraded', current_step = ?, error_class = ?, error_summary = ?, finished_at = CURRENT_TIMESTAMP
      WHERE run_id = ?
    `, [input.currentStep, input.errorClass, input.errorSummary, input.runId]);
  }

  async failRun(input: any): Promise<void> {
    await this.db.run(`
      UPDATE cron_runs 
      SET status = 'failed', current_step = ?, error_class = ?, error_summary = ?, finished_at = CURRENT_TIMESTAMP
      WHERE run_id = ?
    `, [input.currentStep, input.errorClass, input.errorSummary, input.runId]);
  }

  async completeRun(input: any): Promise<void> {
    await this.db.run(`
      UPDATE cron_runs 
      SET status = 'success', current_step = ?, finished_at = CURRENT_TIMESTAMP
      WHERE run_id = ?
    `, [input.currentStep, input.runId]);
  }

  async persistApprovalRequest(input: any): Promise<void> {
    const requestId = randomUUID();
    await this.db.run(`
      INSERT INTO approval_requests (
        request_id, artifact_id, action_type, repo, base_branch, target_sha_or_diff_hash,
        signer_required, status, receipt_id, action_payload_hash, policy_hash, required_signers_json
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(action_payload_hash) DO NOTHING
    `, [
      requestId, input.artifactId, input.actionType, input.repo, input.baseBranch, input.targetShaOrDiffHash,
      input.signerRequired, input.status, input.receiptId, input.actionPayloadHash, input.policyHash,
      JSON.stringify(input.requiredSigners || [])
    ]);
  }

  async getArtifactDiffHash(artifactId: string): Promise<string | null> {
    const row = await this.db.get(`SELECT diff_hash FROM artifacts WHERE artifact_id = ?`, [artifactId]);
    return row ? row.diff_hash : null;
  }
}
