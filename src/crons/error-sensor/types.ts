// src/crons/error-sensor/types.ts
export type StableStep =
  | 'detected'
  | 'bundled'
  | 'repro_succeeded'
  | 'repro_failed'
  | 'candidate_fix_generated'
  | 'verification_passed'
  | 'verification_failed'
  | 'draft_pr_opened'
  | 'approval_request_created';

export type NextAction =
  | 'bundle'
  | 'repro'
  | 'fix'
  | 'verify'
  | 'publish'
  | 'approve';

export type RunStatus = 'running' | 'success' | 'degraded' | 'failed' | 'noop';

type IncidentCandidate = {
  fingerprint: string;
  idempotencyKey: string;
  title: string;
  repo: string;
  baseBranch: string;
  source: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  detectedAt: string;
  raw: Record<string, any>;
};

export type PersistedRun = {
  runId: string;
  cronId: string;
  status: RunStatus;
  currentStep: StableStep;
};

export type RunResult = {
  status: RunStatus;
  runId?: string;
  currentStep?: StableStep;
};

export type ErrorSensorConfig = {
  cadence: string;
  defaultModel: string;
  budgetUsdDay: number;
};

export interface LedgerStore {
  ensureCronDefinition(input: {
    cronId: string;
    name: string;
    purpose: string;
    cadence: string;
    defaultModel: string;
    expectedArtifactType: string;
    budgetUsdDay: number;
    successSlo: string;
    killCriteria: string;
  }): Promise<void>;

  recordNoopRun(input: {
    cronId: string;
    reason: string;
  }): Promise<void>;

  createOrResumeRun(input: {
    cronId: string;
    idempotencyKey: string;
    incidentFingerprint: string;
    initialStep: StableStep;
    initialStatus: RunStatus;
    title: string;
    repo: string;
    baseBranch: string;
    metadata?: Record<string, unknown>;
  }): Promise<PersistedRun>;

  getRun(runId: string): Promise<PersistedRun>;

  getLatestArtifactId(input: {
    runId: string;
    type: string;
  }): Promise<string | null>;

  recordStepAttempt(input: {
    runId: string;
    action: NextAction;
  }): Promise<void>;

  upsertArtifact(input: {
    runId: string;
    type: string;
    title: string;
    url?: string;
    externalRef?: string;
    metadata?: Record<string, unknown>;
    validationStatus: 'valid' | 'invalid' | 'unknown';
  }): Promise<{ artifactId: string }>;

  advanceRun(input: {
    runId: string;
    currentStep: StableStep;
    baseSha?: string;
    headSha?: string;
    treeSha?: string;
    diffHash?: string;
  }): Promise<void>;

  stopRunDegraded(input: {
    runId: string;
    currentStep: StableStep;
    errorClass: string;
    errorSummary: string;
  }): Promise<void>;

  failRun(input: {
    runId: string;
    currentStep: StableStep;
    errorClass: string;
    errorSummary: string;
  }): Promise<void>;

  completeRun(input: {
    runId: string;
    currentStep: StableStep;
  }): Promise<void>;

  persistApprovalRequest(input: {
    runId: string;
    artifactId: string;
    actionType: string;
    repo: string;
    baseBranch: string;
    targetShaOrDiffHash: string;
    signerRequired: string;
    status: string;
    receiptId?: string;
    actionPayloadHash: string;
    policyHash: string;
    requiredSigners?: string[];
  }): Promise<void>;

  getArtifactDiffHash(artifactId: string): Promise<string | null>;
}
