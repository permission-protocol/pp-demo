import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { prepareWorktree } from './worktree';

export async function generateCandidateFix(ctx: any) {
  const { runRoot, worktreePath } = await prepareWorktree({
    runId: ctx.run.runId,
    sourceRepoPath: path.resolve('error-sensor-sandbox'),
    baseSha: ctx.incident.raw.head_sha as string,
    fingerprint: ctx.incident.fingerprint,
  });

  // VERY STUBBED FIX: We know the bug depending on the failure_class
  // For the sake of the deterministic actuator loop, we will hardcode the exact fix string.
  const failureClass = ctx.incident.raw.failure_class;
  let metadataPatched = '';

  if (failureClass === 'typecheck_failure') {
    const targetFile = path.join(worktreePath, 'src', 'config.ts');
    let content = await fs.readFile(targetFile, 'utf-8');
    content = content.replace('port: "8080"', 'port: 8080');
    await fs.writeFile(targetFile, content);
    metadataPatched = 'src/config.ts';
  } else {
    const targetFile = path.join(worktreePath, 'src', 'normalizeAction.ts');
    const patchContent = `export function normalizeAction(input: string): string {
  return input.trim().replace(/\\s+/g, '_');
}
`;
    await fs.writeFile(targetFile, patchContent);
    metadataPatched = 'src/normalizeAction.ts';
  }

  // Note: We do NOT commit here yet. We just alter the files in the worktree.
  // publish.ts will handle diff_hash computation and the actual commit to the repair branch.

  return {
    title: 'Candidate Fix generated',
    url: `local://${runRoot}/worktree`,
    externalRef: 'fix-' + ctx.incident.fingerprint,
    metadata: { patchedFile: metadataPatched }
  };
}