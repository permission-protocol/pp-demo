import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { exec } from 'node:child_process';
import { promisify } from 'node:util';

const execAsync = promisify(exec);

export type PreparedWorktree = {
  runRoot: string;
  worktreePath: string;
  outputsPath: string;
  cleanup: (mode: 'success' | 'degraded' | 'failed') => Promise<void>;
};

export async function prepareWorktree(input: {
  runId: string;
  sourceRepoPath: string;
  baseSha: string;
  fingerprint: string;
}): Promise<PreparedWorktree> {
  const workRoot = process.env.ERROR_SENSOR_WORKROOT || '/tmp/permission-protocol/error-sensor';
  const shortFingerprint = input.fingerprint.replace(/[^a-zA-Z0-9]/g, '-').substring(0, 12);
  const repoSlug = path.basename(input.sourceRepoPath);
  const dirName = `${input.runId}__${repoSlug}__${shortFingerprint}`;
  
  const runRoot = path.join(workRoot, 'runs', dirName);
  const worktreePath = path.join(runRoot, 'worktree');
  const outputsPath = path.join(runRoot, 'outputs');

  await fs.mkdir(runRoot, { recursive: true });
  await fs.mkdir(outputsPath, { recursive: true });

  const meta = {
    runId: input.runId,
    baseSha: input.baseSha,
    fingerprint: input.fingerprint,
    sourceRepoPath: input.sourceRepoPath,
    createdAt: new Date().toISOString()
  };
  await fs.writeFile(path.join(runRoot, 'meta.json'), JSON.stringify(meta, null, 2));

  try {
    // Check if worktree is already initialized cleanly
    try {
      await execAsync(`git -C "${worktreePath}" status`);
    } catch {
      // If broken or missing, ensure local dir is clean and repo is unlinked
      try { await execAsync(`git -C "${input.sourceRepoPath}" worktree remove --force "${worktreePath}"`); } catch {}
      await fs.rm(worktreePath, { recursive: true, force: true });
      
      // Re-create worktree at baseSha
      await execAsync(`git -C "${input.sourceRepoPath}" worktree add --detach "${worktreePath}" ${input.baseSha}`);
      // Switch to deterministic branch
      await execAsync(`git -C "${worktreePath}" switch -C "pp/error-sensor/${shortFingerprint}"`);
    }
  } catch (error) {
    // If setup fails, try to aggressively clean up
    try { await fs.rm(runRoot, { recursive: true, force: true }); } catch (_) {}
    throw error;
  }

  const cleanup = async (mode: 'success' | 'degraded' | 'failed') => {
    // 1. Remove the worktree mapping from the source repo
    try {
      await execAsync(`git -C "${input.sourceRepoPath}" worktree remove --force "${worktreePath}"`);
    } catch (e) {
      // Ignore errors if already removed
    }

    // 2. Handle directory persistence policy
    if (mode === 'success') {
      await fs.rm(runRoot, { recursive: true, force: true });
    } else {
      const quarantineRoot = path.join(workRoot, 'quarantine', dirName);
      await fs.mkdir(path.dirname(quarantineRoot), { recursive: true });
      await fs.rename(runRoot, quarantineRoot);
    }
  };

  return { runRoot, worktreePath, outputsPath, cleanup };
}
