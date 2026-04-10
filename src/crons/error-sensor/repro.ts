import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { spawn } from 'node:child_process';
import type { IncidentCandidate, PersistedRun, ErrorSensorConfig } from './types';
import { prepareWorktree } from './worktree';

export async function attemptRepro(ctx: {
  config: ErrorSensorConfig;
  store: any;
  run: PersistedRun;
  incident: IncidentCandidate;
}) {
  const { runRoot, worktreePath, outputsPath, cleanup } = await prepareWorktree({
    runId: ctx.run.runId,
    sourceRepoPath: path.resolve('error-sensor-sandbox'),
    baseSha: ctx.incident.raw.head_sha as string,
    fingerprint: ctx.incident.fingerprint,
  });

  const logFile = path.join(outputsPath, 'repro.log');

  let succeeded = false;
  let summary = '';
  
  // 1. Install dependencies first
  try {
    await runCommand('npm', ['install'], worktreePath, 120000);
  } catch (error: any) {
    succeeded = false;
    summary = 'Failed to install dependencies before repro.';
    await fs.writeFile(logFile, `INSTALL ERROR:\n${error.stdout}\n${error.stderr}`);
    return { succeeded, title: 'Repro Failed', url: `local://${runRoot}/outputs/repro.log`, externalRef: 'repro-' + ctx.incident.fingerprint, summary, metadata: {} };
  }

  // 2. Run the allowlisted structured command
  const commandStr = ctx.incident.raw.command as string;
  const commandArgs = commandStr.replace('npm ', '').split(' ');
  try {
    await runCommand('npm', commandArgs, worktreePath, 60000);
    // If it passes, the repro failed (it's supposed to fail)
    succeeded = false;
    summary = 'Command succeeded unexpectedly. Could not reproduce the failure.';
    await fs.writeFile(logFile, summary);
  } catch (error: any) {
    // If it fails, check if the output matches the expected failure signature
    const output = (error.stdout || '') + '\n' + (error.stderr || '');
    const failureClass = ctx.incident.raw.failure_class;

    if (failureClass === 'typecheck_failure' && output.includes('TS2322') && output.includes('config.ts')) {
      succeeded = true;
      summary = 'Reproduced successfully via ' + commandStr;
    } else if (failureClass === 'test_failure' && output.includes('delete_user_data') && output.includes('normalizeAction.test.ts')) {
      succeeded = true;
      summary = 'Reproduced successfully via ' + commandStr;
    } else {
      succeeded = false;
      summary = 'Command failed, but signature did not match expected bug.';
    }
    await fs.writeFile(logFile, output);
  }

  return {
    succeeded,
    title: succeeded ? 'Repro Confirmed' : 'Repro Failed',
    url: `local://${runRoot}/outputs/repro.log`,
    externalRef: 'repro-' + ctx.incident.fingerprint,
    summary,
    metadata: { command: 'npm test -- --runInBand' }
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
