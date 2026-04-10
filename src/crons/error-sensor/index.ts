// src/crons/error-sensor/index.ts
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import * as path from 'node:path';

import { detectIncidents } from './detect';
import { buildIncidentBundle } from './bundle';
import { attemptRepro } from './repro';
import { generateCandidateFix } from './fix';
import { verifyCandidateFix } from './verify';
import { publishDraftPr } from './publish';
import { createApprovalRequest } from './approve';
import { createLedgerStore } from './store';
import { prepareWorktree } from './worktree';

import type {
  ErrorSensorConfig,
  IncidentCandidate,
  LedgerStore,
  NextAction,
  PersistedRun,
  RunResult,
  StableStep,
} from './types';

const CRON_ID = 'error-sensor';

const TERMINAL_DEGRADED_STEPS = new Set<StableStep>([
  'repro_failed',
  'verification_failed',
]);

const NEXT_ACTION_FROM_STEP: Record<StableStep, NextAction | null> = {
  detected: 'bundle',
  bundled: 'repro',
  repro_succeeded: 'fix',
  repro_failed: null,
  candidate_fix_generated: 'verify',
  verification_passed: 'publish',
  verification_failed: null,
  draft_pr_opened: 'approve',
  approval_request_created: null,
};

type ExecutionContext = {
  store: LedgerStore;
  config: ErrorSensorConfig;
  run: PersistedRun;
  incident: IncidentCandidate;
  lastArtifactId?: string;
};

export async function runErrorSensor(
  overrideConfig: Partial<ErrorSensorConfig> = {},
): Promise<RunResult> {
  const config = loadConfig(overrideConfig);
  const store = await createLedgerStore(config);

  await store.ensureCronDefinition({
    cronId: CRON_ID,
    name: 'error-sensor',
    purpose:
      'Detect one high-signal incident, generate a candidate fix, publish a draft PR, and create a signer-gated approval request.',
    cadence: config.cadence,
    defaultModel: config.defaultModel,
    expectedArtifactType: 'approval_request',
    budgetUsdDay: config.budgetUsdDay,
    successSlo: '2 clean runs + valid approval_request artifact',
    killCriteria: 'Disable if 7d cost exceeds budget without verified artifacts',
  });

  const incident = await selectNextIncident(store, config);

  if (!incident) {
    await store.recordNoopRun({
      cronId: CRON_ID,
      reason: 'No eligible incidents detected',
    });

    return { status: 'noop' };
  }

  let run = await store.createOrResumeRun({
    cronId: CRON_ID,
    idempotencyKey: incident.idempotencyKey,
    incidentFingerprint: incident.fingerprint,
    initialStep: 'detected',
    initialStatus: 'running',
    title: incident.title,
    repo: incident.repo,
    baseBranch: incident.baseBranch,
    metadata: {
      severity: incident.severity,
      source: incident.source,
      detectedAt: incident.detectedAt,
    },
  });

  await store.upsertArtifact({
    runId: run.runId,
    type: 'incident_detected',
    title: incident.title,
    externalRef: incident.fingerprint,
    metadata: incident.raw,
    validationStatus: 'valid',
  });

  // SHADOW MODE OVERRIDE
  // When TEST_CASE_ID is omitted and we are running in live shadow mode,
  // we STOP execution here before triggering actuation.
  if (!process.env.TEST_CASE_ID || process.env.FORCE_SHADOW_MODE) {
    console.log(`\n[SHADOW MODE] Halting pipeline after detection phase for ${incident.fingerprint}`);
    await store.completeRun({
      runId: run.runId,
      currentStep: 'detected', // Stop at detected
    });
    return { status: 'success' };
  }

  run = await executeIncidentRun({
    store,
    config,
    run,
    incident,
  });

  return {
    status: run.status,
    runId: run.runId,
    currentStep: run.currentStep,
  };
}

async function executeIncidentRun(ctx: ExecutionContext): Promise<PersistedRun> {
  let run = ctx.run;

  while (true) {
    if (run.currentStep === 'approval_request_created') {
      if (run.status !== 'success') {
        await ctx.store.completeRun({
          runId: run.runId,
          currentStep: run.currentStep,
        });
      }

      return ctx.store.getRun(run.runId);
    }

    if (TERMINAL_DEGRADED_STEPS.has(run.currentStep)) {
      if (run.status !== 'degraded') {
        await ctx.store.stopRunDegraded({
          runId: run.runId,
          currentStep: run.currentStep,
          errorClass: 'TERMINAL_DEGRADED_STEP',
          errorSummary: `${run.currentStep} reached; human review required`,
        });
      }

      return ctx.store.getRun(run.runId);
    }

    const nextAction = NEXT_ACTION_FROM_STEP[run.currentStep];
    if (!nextAction) {
      throw new Error(`No next action for stable step: ${run.currentStep}`);
    }

    await ctx.store.recordStepAttempt({
      runId: run.runId,
      action: nextAction,
    });

    try {
      const result = await executeAction(
        {
          ...ctx,
          run,
        },
        nextAction,
      );
      run = result;
      ctx.lastArtifactId = result.lastArtifactId;
    } catch (error) {
      await ctx.store.failRun({
        runId: run.runId,
        currentStep: run.currentStep,
        errorClass: classifyError(error),
        errorSummary: summarizeError(error),
      });

      throw error;
    }
  }
}

async function executeAction(
  ctx: ExecutionContext,
  action: NextAction,
): Promise<PersistedRun & { lastArtifactId?: string }> {
  switch (action) {
    case 'bundle': {
      const bundle = await buildIncidentBundle({
        config: ctx.config,
        store: ctx.store,
        run: ctx.run,
        incident: ctx.incident,
      });

      const { artifactId } = await ctx.store.upsertArtifact({
        runId: ctx.run.runId,
        type: 'incident_bundle',
        title: bundle.title,
        url: bundle.url,
        externalRef: bundle.externalRef,
        metadata: bundle.metadata,
        validationStatus: 'valid',
      });

      await ctx.store.advanceRun({
        runId: ctx.run.runId,
        currentStep: 'bundled',
      });

      return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: artifactId };
    }

    case 'repro': {
      // NODE LOSS RECOVERY
      // If we're resuming at 'repro' or later, the /tmp worktree might have been lost.
      // prepareWorktree handles creating it idempotently based on the runId and baseSha.
      const repro = await attemptRepro({
        config: ctx.config,
        store: ctx.store,
        run: ctx.run,
        incident: ctx.incident,
      });

      const { artifactId } = await ctx.store.upsertArtifact({
        runId: ctx.run.runId,
        type: 'repro_report',
        title: repro.title,
        url: repro.url,
        externalRef: repro.externalRef,
        metadata: repro.metadata,
        validationStatus: repro.succeeded ? 'valid' : 'invalid',
      });

      if (!repro.succeeded) {
        await ctx.store.stopRunDegraded({
          runId: ctx.run.runId,
          currentStep: 'repro_failed',
          errorClass: 'REPRO_NOT_CONFIRMED',
          errorSummary: repro.summary,
        });

        return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: artifactId };
      }

      await ctx.store.advanceRun({
        runId: ctx.run.runId,
        currentStep: 'repro_succeeded',
      });

      return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: artifactId };
    }

    case 'fix': {
      const fix = await generateCandidateFix({
        config: ctx.config,
        store: ctx.store,
        run: ctx.run,
        incident: ctx.incident,
      });

      const { artifactId } = await ctx.store.upsertArtifact({
        runId: ctx.run.runId,
        type: 'candidate_fix',
        title: fix.title,
        url: fix.url,
        externalRef: fix.externalRef,
        metadata: fix.metadata,
        validationStatus: 'valid',
      });

      await ctx.store.advanceRun({
        runId: ctx.run.runId,
        currentStep: 'candidate_fix_generated',
      });

      return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: artifactId };
    }

    case 'verify': {
      const verification = await verifyCandidateFix({
        config: ctx.config,
        store: ctx.store,
        run: ctx.run,
        incident: ctx.incident,
      });

      const { artifactId } = await ctx.store.upsertArtifact({
        runId: ctx.run.runId,
        type: 'verification_report',
        title: verification.title,
        url: verification.url,
        externalRef: verification.externalRef,
        metadata: verification.metadata,
        validationStatus: verification.passed ? 'valid' : 'invalid',
      });

      if (!verification.passed) {
        await ctx.store.stopRunDegraded({
          runId: ctx.run.runId,
          currentStep: 'verification_failed',
          errorClass: 'VERIFICATION_FAILED',
          errorSummary: verification.summary,
        });

        return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: artifactId };
      }

      await ctx.store.advanceRun({
        runId: ctx.run.runId,
        currentStep: 'verification_passed',
      });

      return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: artifactId };
    }

    case 'publish': {
      // Re-hydrate the worktree if we crashed and are resuming directly at 'publish'
      await prepareWorktree({
        runId: ctx.run.runId,
        sourceRepoPath: path.resolve('error-sensor-sandbox'),
        baseSha: ctx.incident.raw.head_sha as string,
        fingerprint: ctx.incident.fingerprint,
      });

      const publication = await publishDraftPr({
        config: ctx.config,
        store: ctx.store,
        run: ctx.run,
        incident: ctx.incident,
      });

      const { artifactId } = await ctx.store.upsertArtifact({
        runId: ctx.run.runId,
        type: 'draft_pr',
        title: publication.title,
        url: publication.prUrl,
        externalRef: String(publication.prNumber),
        metadata: publication.metadata,
        validationStatus: 'valid',
        diffHash: publication.diffHash,
      });

      if (process.env.STUB_CRASH_AFTER === 'artifact_write_publish') {
        console.error('STUB_CRASH_AFTER: artifact_write_publish - exiting abruptly!');
        process.exit(1);
      }

      await ctx.store.advanceRun({
        runId: ctx.run.runId,
        currentStep: 'draft_pr_opened',
        baseSha: publication.baseSha,
        headSha: publication.headSha,
        treeSha: publication.treeSha,
        diffHash: publication.diffHash,
      });

      const updatedRun = await ctx.store.getRun(ctx.run.runId);

      if (process.env.STUB_CRASH_AFTER === 'advance_run_publish') {
        console.error('STUB_CRASH_AFTER: advance_run_publish - exiting abruptly!');
        process.exit(1);
      }

      return { ...updatedRun, lastArtifactId: artifactId };
    }

    case 'approve': {
      // Re-hydrate lastArtifactId if resuming directly at 'approve'
      let artifactId = ctx.lastArtifactId;
      if (!artifactId) {
        const id = await ctx.store.getLatestArtifactId({ runId: ctx.run.runId, type: "draft_pr" });
        if (id) artifactId = id;
      }
      const approval = await createApprovalRequest({
        config: ctx.config,
        store: ctx.store,
        run: ctx.run,
        incident: ctx.incident,
        lastArtifactId: artifactId,
      });

      await ctx.store.persistApprovalRequest({
        runId: ctx.run.runId,
        artifactId: approval.artifactId,
        actionType: approval.actionType,
        repo: approval.repo,
        baseBranch: approval.baseBranch,
        targetShaOrDiffHash: approval.targetShaOrDiffHash,
        signerRequired: approval.signerRequired,
        status: approval.status,
        receiptId: approval.receiptId,
        actionPayloadHash: approval.actionPayloadHash,
        policyHash: approval.policyHash,
        requiredSigners: approval.requiredSigners,
      });

      await ctx.store.advanceRun({
        runId: ctx.run.runId,
        currentStep: 'approval_request_created',
      });

      await ctx.store.completeRun({
        runId: ctx.run.runId,
        currentStep: 'approval_request_created',
      });

      return { ...await ctx.store.getRun(ctx.run.runId), lastArtifactId: undefined };
    }

    default: {
      const exhaustiveCheck: never = action;
      throw new Error(`Unhandled action: ${String(exhaustiveCheck)}`);
    }
  }
}

async function selectNextIncident(
  store: LedgerStore,
  config: ErrorSensorConfig,
): Promise<IncidentCandidate | null> {
  const candidates = await detectIncidents({ store, config });

  if (candidates.length === 0) return null;

  const sorted = [...candidates].sort((a, b) => {
    const severityDelta = rankSeverity(b.severity) - rankSeverity(a.severity);
    if (severityDelta !== 0) return severityDelta;

    return new Date(b.detectedAt).getTime() - new Date(a.detectedAt).getTime();
  });

  // v1: one incident per invocation keeps runtime bounded and recovery simple.
  return sorted[0] ?? null;
}

function rankSeverity(severity: IncidentCandidate['severity']): number {
  switch (severity) {
    case 'critical':
      return 4;
    case 'high':
      return 3;
    case 'medium':
      return 2;
    case 'low':
      return 1;
    default:
      return 0;
  }
}

function classifyError(error: unknown): string {
  if (error instanceof Error && error.name) return error.name;
  return 'UNHANDLED_ERROR';
}

function summarizeError(error: unknown): string {
  if (error instanceof Error) {
    return `${error.name}: ${error.message}`.slice(0, 1000);
  }

  return String(error).slice(0, 1000);
}

function loadConfig(
  overrideConfig: Partial<ErrorSensorConfig>,
): ErrorSensorConfig {
  return {
    cadence: overrideConfig.cadence ?? process.env.ERROR_SENSOR_CADENCE ?? 'hourly',
    defaultModel:
      overrideConfig.defaultModel ??
      process.env.ERROR_SENSOR_DEFAULT_MODEL ??
      'google/gemini-3-flash-preview',
    budgetUsdDay:
      overrideConfig.budgetUsdDay ??
      Number(process.env.ERROR_SENSOR_BUDGET_USD_DAY ?? '2'),
    ...overrideConfig,
  };
}

const isDirectExecution = (() => {
  try {
    return process.argv[1] === fileURLToPath(import.meta.url);
  } catch {
    return false;
  }
})();

if (isDirectExecution) {
  runErrorSensor().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
