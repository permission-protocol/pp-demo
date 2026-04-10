import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import { createHash } from 'node:crypto';
import type { IncidentCandidate } from './types';

const execAsync = promisify(exec);

// ============================================================================
// GITHUB ACTIONS SHADOW DETECT
// ============================================================================
// Ingests live GitHub workflow failures, normalizes, and fingerprints them.
// Currently hardcoded to target `error-sensor-sandbox` or configured repos.
// Returns incidents marked with supportability labels, but stops before actuation.

export async function detectIncidents(ctx: any): Promise<IncidentCandidate[]> {
  const mode = process.env.STUB_DETECT_MODE;
  if (mode === 'noop') return [];

  // If a test case ID is provided, use the deterministic fixture (Actuator testing mode)
  if (process.env.TEST_CASE_ID) {
    const testCaseId = process.env.TEST_CASE_ID;
    const isTypecheck = process.env.FIXTURE_TYPE === 'typecheck';
    const isAppTypecheck = process.env.FIXTURE_TYPE === 'app_typecheck';
    const fixtureName = isAppTypecheck ? 'fixture-app-typecheck.normalized.json' 
                      : isTypecheck ? 'fixture-gha-typecheck.normalized.json' 
                      : 'fixture-gha-failure.normalized.json';
    const fixturePath = path.resolve(`crons/data/${fixtureName}`);
    const fixtureData = JSON.parse(await fs.readFile(fixturePath, 'utf-8'));

    // Normalize supportability label deterministically
    let supportability = 'unsupported_failure_class';
    if (fixtureData.failure_class === 'test_failure') {
      supportability = 'supported_now';
    } else if (fixtureData.failure_class === 'typecheck_failure' || fixtureData.failure_class === 'lint_failure') {
      supportability = 'needs_human_triage';
    }

    return [{
      fingerprint: 'stub-fp:' + testCaseId,
      idempotencyKey: 'stub-idem:' + testCaseId,
      title: `Test Failure: ${fixtureData.failing_job} in ${fixtureData.repo}`,
      repo: fixtureData.repo,
      baseBranch: fixtureData.base_branch,
      source: fixtureData.source,
      severity: supportability === 'supported_now' ? 'high' : 'low',
      detectedAt: fixtureData.detected_at,
      raw: { ...fixtureData, supportability }
    }];
  }

  // --- LIVE SHADOW MODE ---
  // In a full implementation, this would call the GitHub API:
  // GET /repos/{owner}/{repo}/actions/runs?status=failure
  // For now, we simulate pulling the latest failed run from the sandbox repo.
  
  const repo = process.env.SHADOW_DETECT_REPO || 'permission-protocol/error-sensor-sandbox';
  const token = process.env.GITHUB_TOKEN;
  
  if (!token) {
    console.warn('[detect] No GITHUB_TOKEN provided for shadow mode. Returning empty.');
    return [];
  }

  console.log(`[detect] Polling live GitHub workflow failures for ${repo} in shadow mode...`);
  
  try {
    const response = await fetch(`https://api.github.com/repos/${repo}/actions/runs?status=failure&per_page=5`, {
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: 'application/vnd.github.v3+json',
        'X-GitHub-Api-Version': '2022-11-28',
      }
    });

    if (!response.ok) {
      console.error(`[detect] GitHub API error: ${response.status} ${response.statusText}`);
      return [];
    }

    const data = await response.json();
    const incidents: IncidentCandidate[] = [];

    for (const run of data.workflow_runs) {
      // Only process runs on 'main' branch
      if (run.head_branch !== 'main') continue;

      // 1. Fetch failed jobs to find the specific step
      const jobsResponse = await fetch(run.jobs_url, {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'application/vnd.github.v3+json',
        }
      });
      
      let failureClass = 'unknown_failure';
      let failingJobName = 'unknown';
      let logExcerpt = '';

      if (jobsResponse.ok) {
        const jobsData = await jobsResponse.json();
        const failedJob = jobsData.jobs.find((j: any) => j.conclusion === 'failure');
        if (failedJob) {
          failingJobName = failedJob.name;
          
          // Categorize based on job/step name heuristics
          const lowerName = failingJobName.toLowerCase();
          if (lowerName.includes('test') || lowerName.includes('jest')) failureClass = 'test_failure';
          else if (lowerName.includes('lint') || lowerName.includes('eslint')) failureClass = 'lint_failure';
          else if (lowerName.includes('type') || lowerName.includes('tsc')) failureClass = 'typecheck_failure';

          // Attempt to fetch logs for the excerpt (In a real system, this requires downloading the zip)
          // For shadow mode MVP, we just record that we found it.
          logExcerpt = `Failed at job: ${failedJob.name}. Logs require zip extraction.`;
        }
      }

      const fingerprintData = `${repo}:${run.id}:${run.run_attempt}:${failureClass}`;
      const fingerprint = createHash('sha256').update(fingerprintData).digest('hex').substring(0, 16);
      const idempotencyKey = `gha-${run.id}-${run.run_attempt}`;

      // 2. Assess supportability
      let supportability = 'unsupported_failure_class';
      if (failureClass === 'test_failure') {
        supportability = 'supported_now';
      } else if (failureClass === 'typecheck_failure' || failureClass === 'lint_failure') {
        supportability = 'needs_human_triage';
      }

      // 3. Construct Normalized Incident
      const normalized = {
        source: 'github_actions',
        repo,
        workflow_name: run.name,
        workflow_run_id: run.id,
        run_attempt: run.run_attempt,
        head_branch: run.head_branch,
        base_branch: 'main', // Assuming PRs target main, or run is on main
        head_sha: run.head_sha,
        failure_class: failureClass,
        failing_job: failingJobName,
        failing_step: 'unknown', // Requires log parsing
        command: 'unknown', // Requires log parsing
        log_excerpt: logExcerpt,
        detected_at: run.updated_at,
        supportability
      };

      incidents.push({
        fingerprint,
        idempotencyKey,
        title: `GHA Failure: ${run.name} (${failingJobName}) in ${repo}`,
        repo,
        baseBranch: 'main',
        source: 'github_actions',
        severity: supportability === 'supported_now' ? 'high' : 'low',
        detectedAt: run.updated_at,
        raw: normalized
      });
    }

    // Sort by most recent
    incidents.sort((a, b) => new Date(b.detectedAt).getTime() - new Date(a.detectedAt).getTime());

    // SHADOW MODE OUTPUT
    if (incidents.length > 0) {
      console.log(`\n--- SHADOW MODE DETECTED ${incidents.length} INCIDENTS ---`);
      incidents.forEach(inc => {
        console.log(`- ${inc.fingerprint} | ${inc.raw.supportability.padEnd(25)} | ${inc.title}`);
      });
      console.log('--------------------------------------------------\n');
    }

    return incidents;

  } catch (error) {
    console.error('[detect] Shadow mode polling failed:', error);
    return [];
  }
}