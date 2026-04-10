import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import { createHash } from 'node:crypto';
import { prepareWorktree } from './worktree';

const execAsync = promisify(exec);

export async function publishDraftPr(ctx: any) {
  const { runRoot, worktreePath } = await prepareWorktree({
    runId: ctx.run.runId,
    sourceRepoPath: path.resolve('error-sensor-sandbox'),
    baseSha: ctx.incident.raw.head_sha as string,
    fingerprint: ctx.incident.fingerprint,
  });

  const shortFingerprint = ctx.incident.fingerprint.replace(/[^a-zA-Z0-9]/g, '-').substring(0, 12);

  // 1. Compute deterministic diff hash against HEAD
  // At this point, the changes are uncommitted in the worktree.
  // NOTE: If this is a resumed run after a crash, the changes might ALREADY be committed.
  // To get a stable diff hash regardless of commit state, diff HEAD~1..HEAD if clean, or diff against HEAD~1 if dirty.
  
  // 2. Commit the fix to the repair branch
  // Note: worktree was detached at baseSha, then checked out as a new branch `pp/error-sensor/<shortFingerprint>`
  await execAsync(`git -C "${worktreePath}" add -A`);
  try {
    await execAsync(`git -C "${worktreePath}" commit -m "Fix: ${ctx.incident.title}"`);
  } catch (error: any) {
    if (!error.stdout?.includes('nothing to commit')) {
      throw error;
    }
  }

  // 3. Extract final hashes
  const { stdout: baseSha } = await execAsync(`git -C "${worktreePath}" rev-parse HEAD~1`);
  const { stdout: headSha } = await execAsync(`git -C "${worktreePath}" rev-parse HEAD`);
  const { stdout: treeSha } = await execAsync(`git -C "${worktreePath}" rev-parse HEAD^{tree}`);

  // Now that we are guaranteed committed, compute the diffHash between base and head
  const { stdout: diff } = await execAsync(`git -C "${worktreePath}" diff HEAD~1 HEAD`);
  const diffHash = createHash('sha256').update(diff).digest('hex');

  // 3. Mock/Open Draft PR
  // In a real scenario, we'd: git push origin branch && gh pr create --draft
  // For the sandbox fixture-driven phase, we'll record the intent and the exact hashes.
  const prNumber = 101;
  const prUrl = `https://github.com/permission-protocol/error-sensor-sandbox/pull/${prNumber}`;

  return {
    title: 'Fix: ' + ctx.incident.title,
    prUrl,
    prNumber,
    baseSha: baseSha.trim(),
    headSha: headSha.trim(),
    treeSha: treeSha.trim(),
    diffHash,
    metadata: { 
      branch: `pp/error-sensor/${shortFingerprint}`,
      diffSize: diff.length
    }
  };
}
