import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { prepareWorktree } from './worktree';

export async function verifyCandidateFix(ctx: any) {
  const { runRoot, worktreePath, outputsPath } = await prepareWorktree({
    runId: ctx.run.runId,
    sourceRepoPath: path.resolve('error-sensor-sandbox'),
    baseSha: ctx.incident.raw.head_sha as string,
    fingerprint: ctx.incident.fingerprint,
  });
  
  const logFile = path.join(outputsPath, 'verify.log');

  const commandStr = ctx.incident.raw.command as string;
  const commandArgs = commandStr.replace('npm ', '').split(' ');
  
  let passed = false;
  let summary = '';

  try {
    const { stdout, stderr } = await runCommand('npm', commandArgs, worktreePath, 60000);
    passed = true;
    summary = 'All tests pass.';
    await fs.writeFile(logFile, 'Verification Passed:\n' + summary + '\n' + stdout + '\n' + stderr);
  } catch (error: any) {
    passed = false;
    summary = 'Tests failed after fix.';
    await fs.writeFile(logFile, (error.stdout || '') + '\n' + (error.stderr || ''));
  }

  return {
    passed,
    title: passed ? 'Verification Passed' : 'Verification Failed',
    url: `local://${runRoot}/outputs/verify.log`,
    externalRef: 'verify-' + ctx.incident.fingerprint,
    summary,
    metadata: { command: commandStr }
  };
}

async function runCommand(bin: string, args: string[], cwd: string, timeoutMs: number): Promise<{ stdout: string, stderr: string }> {
  return new Promise((resolve, reject) => {
    const child = spawn(bin, args, { cwd, shell: false, timeout: timeoutMs });
    
    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (data) => stdout += data.toString());
    child.stderr.on('data', (data) => stderr += data.toString());

    child.on('close', (code) => {
      if (code === 0) resolve({ stdout, stderr });
      else reject({ code, stdout, stderr });
    });
    child.on('error', (err) => reject({ code: -1, stdout, stderr: err.message }));
  });
}
