const fs = require('fs');
const yaml = require('js-yaml');

const THREADS_PATH = '/Users/moltbot/.openclaw/workspace/ops/threads.yaml';
const DECISIONS_PATH = '/Users/moltbot/.openclaw/workspace/ops/decisions.md';

const rawYaml = fs.readFileSync(THREADS_PATH, 'utf8');
let doc = yaml.load(rawYaml);
if (!doc) doc = { threads: [] };

let thread = doc.threads.find(t => t.id === '1489650324879708351');
if (!thread) {
  thread = {
    id: '1489650324879708351',
    title: 'Onboarding Flow QA',
    channel: 'rc-main',
    owner: 'rod',
    priority: 'high',
    status: 'ARCHIVED',
    created_at: '2026-04-03',
    open_tasks: [],
    decisions: []
  };
  doc.threads.unshift(thread);
}

thread.status = 'ARCHIVED';
thread.updated_at = '2026-04-08';
thread.archived_at = '2026-04-08';
thread.summary = 'Overhauled the Permission Protocol onboarding flow into a deterministic, server-orchestrated "Hello World" loop. Squashed race conditions and built the Control Room UI with PostHog telemetry.';
thread.resolution_artifact = 'PRs #288–#308 merged';
thread.decisions = [
  'Activation = blocked action -> signer decision -> receipt (not just App installation).',
  'State machine locked steps must be resumable to self-heal.',
  'GitHub App installation callbacks require exponential backoff when querying repos due to internal propagation delays.',
  'Legacy auto-setup requiring administration:write is permanently deprecated in favor of scoped contents:write and workflows:write.'
];

fs.writeFileSync(THREADS_PATH, yaml.dump(doc));

const newDecisions = `
## 2026-04-08 — Onboarding Flow QA (rc-main)
- Activation = blocked action -> signer decision -> receipt (not just App installation).
- State machine locked steps must be resumable to self-heal.
- GitHub App installation callbacks require exponential backoff when querying repos due to internal propagation delays.
- Legacy auto-setup requiring administration:write is permanently deprecated in favor of scoped contents:write and workflows:write.
`;

fs.appendFileSync(DECISIONS_PATH, newDecisions);
