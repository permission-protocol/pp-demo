import { randomUUID } from 'node:crypto';
import type { IncidentCandidate, PersistedRun, ErrorSensorConfig } from './types';

export async function createApprovalRequest(ctx: {
  config: ErrorSensorConfig;
  store: any;
  run: PersistedRun & { code_version?: string };
  incident: IncidentCandidate;
  lastArtifactId?: string;
}) {
  // 1. We use the lastArtifactId (the draft_pr artifact) to link the request
  const artifactId = ctx.lastArtifactId;
  if (!artifactId) throw new Error('No artifact ID provided for approval request');

  // 2. Fetch the artifact content to get the real diffHash
  // If run.code_version wasn't correctly loaded into context on resume,
  // we pull it directly from the artifact record as a fallback
  let diffHash = ctx.run.code_version;
  
  if (!diffHash) {
    diffHash = await ctx.store.getArtifactDiffHash(artifactId);
  }

  return {
    artifactId,
    actionType: 'merge_draft_pr',
    repo: ctx.incident.repo,
    baseBranch: ctx.incident.baseBranch,
    targetShaOrDiffHash: diffHash || 'unknown-diff-hash',
    signerRequired: 'true',
    status: 'pending',
    receiptId: '',
    actionPayloadHash: 'payload-hash-' + ctx.incident.fingerprint,
    policyHash: 'policy-v1',
    requiredSigners: ['rod7471']
  };
}
