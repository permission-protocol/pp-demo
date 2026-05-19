# PRD: Permission-Aware Repository Onboarding

Generated: 2026-05-19
Status: Revised Draft
Revision: 2026-05-19 — v5 scope-cut for shippable onboarding repair
Owner: Product / Engineering
Product area: Permission Protocol activation, GitHub App install, repo protection

---

## 1. Executive Summary

Permission Protocol onboarding currently conflates three jobs:

1. Connect a GitHub installation/repository to a PP workspace.
2. Protect a real repo with a PP-authored required signal.
3. Create a demo/test PR to prove the approval/receipt loop.

Those jobs have different permission requirements and success criteria. The current flow can fall through to generic errors like `GitHub API request failed`, especially when:

- the selected repo is not included in the GitHub App installation,
- the workspace has a stale `primaryRepoFullName`, or
- the App can protect the repo but cannot create a test PR because it lacks Contents write.

This PRD is intentionally scoped to the urgent onboarding repair: make repo onboarding explicit, permission-aware, verifier-backed, and shippable.

Full receipt/signer/quorum/break-glass policy is **out of scope** here and belongs in the companion authority spec:

- `pp-os/prds/authority-model-v1-prd.md`

---

## 2. Goals

### Product goals

- User always knows the exact target being configured: workspace → GitHub account/install → repo → branch/pattern.
- PP never attempts GitHub mutation before preflight and user/admin consent.
- Missing optional permissions produce repairable states, not generic failures.
- Core repo protection does not require Contents write.
- PP does not claim “repo protection active” unless verifier evidence supports it.

### Technical goals

- Replace implicit primary-repo onboarding behavior with explicit target selection.
- Add named error states for known GitHub setup failures.
- Split declared vs effective capabilities.
- Add a static `ProtectionVerifier` foundation with verifier levels.
- Add repo sync repair for repos added to existing installations.
- Add regression tests for the `site` vs `dispatch` incident.

### Non-goals

This PRD does **not** implement:

- signer roster / quorum / M-of-N approvals,
- receipt RFC / full JSON schema,
- break-glass policy,
- GDPR deletion / retention policy,
- GHES support,
- automatic ruleset creation as a polished enterprise flow,
- full runtime merge-block verifier.

It must not preclude those future capabilities.

---

## 3. Incident Context

Observed user failure:

- User wanted to add `permission-protocol/dispatch`.
- UI still referenced `permission-protocol/site` as current repo.
- Walkthrough attempted test PR creation.
- GitHub App had repo access after repair, but no Contents write for test PR mutation.
- UI showed generic `GitHub API request failed`.

Root product issue:

- repo target selection, repo protection, and assisted test PR creation are blurred together.

---

## 4. Product Principles

1. **Least privilege by default** — core protection must not require Contents write.
2. **Permission state is product surface** — show exactly what PP can/cannot do.
3. **No invisible repo context** — never infer onboarding target from stale company defaults.
4. **Preflight before mutation** — no branch/file/PR writes before capability checks and consent.
5. **Configured ≠ enforcing** — verifier levels must prevent false activation claims.
6. **Tests over checklist theater** — regressions should be caught in CI/test coverage, not only PR prose.

---

## 5. Authority Model Boundary

Onboarding touches the authority primitive, but should not define the full authority model.

V1 onboarding only needs these constraints:

- approval/protection must bind to the selected repo/branch/SHA path where applicable,
- approval must not be falsely reused after a head SHA changes,
- data structures should not block future signer roster/quorum/receipt upgrades,
- verifier must not claim protection without evidence.

Detailed receipt, signer, quorum, replay, retention, and break-glass semantics live in:

- `pp-os/prds/authority-model-v1-prd.md`

---

## 6. User Journeys

### 6.1 New user: first receipt, then real repo

1. User signs up.
2. Primary CTA: `Get your first signed receipt`.
3. User completes demo receipt lane without granting customer repo write permissions.
4. UI shows `Receipt loop verified`, not `Workspace activated`.
5. User is prompted: `Protect a real repo`.
6. User selects GitHub account/install, repo, and branch/pattern.
7. PP runs preflight and shows readiness/repair checklist.
8. PP reaches a verifier-backed protection state or shows next repair action.

### 6.2 Returning user: existing GitHub install

1. User lands in onboarding/dashboard.
2. PP detects accessible GitHub App installations.
3. If multiple installs exist, user chooses account/org.
4. PP syncs repos.
5. User chooses repo and branch/pattern explicitly.
6. PP does not infer target from `Company.primaryRepoFullName`.

### 6.3 Repo not included in installation

1. User selects/searches for repo unavailable to the App.
2. PP returns `APP_NOT_INSTALLED_ON_REPO`.
3. UI offers: add repo to GitHub App installation.
4. If user is not admin, generate admin handoff.
5. After admin action, user clicks `Sync repos`.
6. PP reruns preflight from the same target.

### 6.4 Real repo test without Contents write

1. User selects real repo protection.
2. Core protection preflight passes.
3. Assisted test PR preflight detects missing Contents write.
4. PP does not attempt branch/file/PR mutation.
5. UI offers manual PR commands or optional permission upgrade.

### 6.5 Existing workspace with stale primary repo

1. Workspace default repo is `permission-protocol/site`.
2. User selects `permission-protocol/dispatch`.
3. Every onboarding screen shows `dispatch`.
4. Activation/preflight/verifier use `dispatch`.
5. Company default repo changes only after explicit selection/confirmation.

---

## 7. UX Model

Architecture has three internal lanes, but UI should guide users sequentially.

### Default sequence

1. `Get your first signed receipt` — demo receipt lane.
2. `Protect a real repo` — real repo protection lane.
3. Optional inline action: `Use my repo for the test instead` — assisted/manual test PR lane.

### Required UI states

#### Install target header

Every onboarding screen must show:

```text
Workspace: Rodrigo's Workspace
GitHub: permission-protocol org
Repo: permission-protocol/dispatch
Branch/pattern: main
Mode: Protect repo
```

If any value is missing, show a picker. Do not infer silently.

#### Setup checklist

Example:

```text
Repository access
✓ PP is installed on permission-protocol/dispatch

Core protection
✓ Can read pull requests
✓ Can post required status
⚠ Required PP status is not configured on main
  [Show manual steps] [Configure automatically if allowed]

Test PR automation
⚠ PP cannot create a test PR automatically
  Missing optional Contents write.
  [Use manual PR commands] [Request optional permission]
```

#### Error banner standard

Bad:

```text
GitHub API request failed
```

Good:

```text
PP can protect this repo, but cannot create a test PR automatically.
GitHub has not granted Contents write to the PP App on permission-protocol/dispatch.
Use manual PR commands or grant optional Contents write.
```

### Wireframe requirement

Before implementation beyond Phase 1, add lightweight wireframes/sketches for:

- target header,
- setup checklist,
- repairable error banner,
- manual PR fallback,
- admin handoff.

A text-only description is acceptable for Phase 1 incident repair, but Phase 1.5+ should not proceed without sketches.

### Accessibility/mobile basics

- Checklists and repair actions keyboard navigable.
- Status not color-only.
- Error banners screen-reader announced.
- Manual command blocks have accessible labels and copy buttons.
- Signing/approval pages remain mobile usable.

---

## 8. Permission Model

### Core GitHub App permissions

Core protection should require only what is needed for governance:

- Metadata: read
- Pull requests: read, write only if PR comments are treated as core
- Contents: read if risk inspection requires changed-file content
- Statuses: write for v1 required signal
- Checks: future-compatible, not v1 blocker
- Actions: read only if workflow state is inspected

Core protection should **not** require Contents write.

### Optional elevated permissions

- Contents write — only for PP-created test branch/file/PR.
- Administration write — only for automatic ruleset/branch-protection configuration.

### PR comments v1 decision

PR comments are optional UX, not core enforcement. If PP lacks PR write, protection should still work through required signal + dashboard/signing link.

### Declared vs effective capabilities

PP must distinguish:

- **Declared capability** — what GitHub says the App may do.
- **Effective capability** — what PP has verified it can do for this repo/branch.

Capability checks:

| Capability | Declared check | Effective check |
|---|---|---|
| `canReadRepo` | installation includes repo | fetch repo metadata by repo ID |
| `canReadPullRequests` | PR permission | list/read PRs for selected repo |
| `canPostRequiredSignal` | statuses/checks write | infer from permission in V1; write probe only with consent |
| `canInspectRisk` | contents read | fetch changed files/diff metadata where available |
| `canCreateTestPr` | contents write + PR write | only attempt mutation after user chooses assisted test PR |
| `canAutoConfigureProtection` | administration write | verify branch-protection/ruleset APIs if user/admin chooses auto-config |

### Probe safety classification

| Probe class | Meaning | Default allowed? |
|---|---|---:|
| `read_only` | reads GitHub state only | yes |
| `reversible_write` | creates/updates removable state | explicit consent |
| `visible_write` | creates visible repo artifacts | explicit assisted/manual test lane |
| `policy_write` | changes branch protection/rulesets | admin confirmation |

Default customer repo preflight must be read-only.

---

## 9. Required Signal v1

V1 uses GitHub commit statuses unless the existing app code already requires otherwise.

Canonical required signal:

- Kind: `status`
- Context: `Permission Protocol`
- Expected producer: PP GitHub App ID `3065051`
- User-facing label: `Permission Protocol`

Requirements:

- Do not silently change context string.
- Detect legacy/wrong contexts and show migration guidance.
- Branch protection/ruleset verifier must compare exact context string.
- Status posting must target exact commit SHA, never branch name.
- Future Checks support must map through `RequiredSignal`, not fork business logic.

---

## 10. State Machine

### Entity model

```text
Workspace
  → GitHubInstallation
    → Repository
      → BranchOrPattern
        → ProtectionTarget
```

### Core states and transitions

```text
START
  → WORKSPACE_SELECTED
  → INSTALLATION_SELECTED
  → REPO_SELECTED
  → BRANCH_OR_PATTERN_SELECTED
  → PREFLIGHT_RUNNING
  → PREFLIGHT_PASSED
  → PROTECTION_CONFIGURED
  → PROTECTION_VERIFIED_LEVEL_1
  → PROTECTION_VERIFIED_LEVEL_2
```

Repair loop:

```text
PREFLIGHT_RUNNING
  → PREFLIGHT_FAILED_REPAIRABLE
  → REPAIR_ACTION_STARTED
  → SYNC_REPOS | ADMIN_HANDOFF | MANUAL_SETUP
  → PREFLIGHT_RUNNING
```

Blocked loop:

```text
PREFLIGHT_RUNNING
  → PREFLIGHT_BLOCKED
  → TARGET_CHANGE_REQUIRED | ADMIN_REQUIRED | UNSUPPORTED_REPO_STATE
```

Optional test PR loop:

```text
PREFLIGHT_PASSED
  → TEST_PR_MODE_SELECTED
  → TEST_PR_PREFLIGHT
  → MANUAL_TEST_PR_INSTRUCTIONS | ASSISTED_TEST_PR_CREATING
  → TEST_PR_CREATED_OR_DETECTED
```

### Source-of-truth precedence

When records disagree, use:

1. Current explicit onboarding target.
2. Active verified protection target.
3. Current activation attempt target.
4. Company default repo (`primaryRepoFullName`) as dashboard default only.
5. GitHub synced repos as selectable inventory.
6. Client-supplied repo string only as a request to validate.

No onboarding mutation or verifier call may use `primaryRepoFullName` if explicit target exists.

### Scoping

Protection target is branch/pattern scoped, not merely repo scoped.

V1 supports one selected branch/pattern per onboarding attempt. Multi-branch or `release/*` protection should be represented as separate protection targets or deferred, but the data model must not assume one repo has only one protection target.

### Concurrent onboarding

- Onboarding target updates should be versioned or use optimistic concurrency.
- Activation attempts keyed by workspace + repoId + branch/pattern + lane, not workspace alone.
- Only one active protection target may exist for the same repo + branch/pattern.

---

## 11. Named Failure States

| Code | Meaning | Repair |
|---|---|---|
| `APP_NOT_INSTALLED_ON_ACCOUNT` | no PP install for selected GitHub account/org | install PP App |
| `APP_NOT_INSTALLED_ON_REPO` | install exists but repo not included | add repo to installation |
| `INSTALLATION_NOT_LINKED_TO_WORKSPACE` | install exists but not linked to workspace | link install |
| `REPO_NOT_CONNECTED_TO_WORKSPACE` | repo not synced/connected in PP DB | sync repos |
| `MULTIPLE_INSTALLATIONS_NEED_SELECTION` | user has multiple installs | choose install |
| `PRIMARY_REPO_STALE` | company default differs from explicit target | confirm/switch target |
| `MISSING_STATUSES_WRITE_FOR_GATE` | cannot post required v1 signal | reapprove permissions |
| `MISSING_CONTENTS_WRITE_FOR_TEST_PR` | cannot create branch/file/PR | manual PR or optional permission |
| `MISSING_ADMIN_WRITE_FOR_AUTO_RULESET` | cannot auto-configure protection | manual setup or admin permission |
| `REQUIRED_SIGNAL_NOT_CONFIGURED` | branch/ruleset does not require PP signal | configure required signal |
| `SIGNAL_CONFIGURED_WRONG_CONTEXT` | required signal context mismatch | migrate context |
| `PROTECTION_CONFLICT` | branch protection and rulesets disagree | show conflict and manual fix |
| `GITHUB_RATE_LIMITED` | GitHub rate limit hit | retry after timestamp |
| `GITHUB_API_UNAVAILABLE` | transient GitHub outage | retry, preserve state |

Known setup/access/permission failures must not return generic 500s to the UI.

---

## 12. ProtectionVerifier Foundation

### Verifier levels

| Level | Meaning | Requires PR? | User label |
|---|---|---:|---|
| `configuration_verified` | repo/install/branch/signal configuration appears correct | no | `Protection configured` |
| `signal_provenance_verified` | PP can or is expected to post canonical required signal as App | no or consented probe | `PP signal verified` |
| `merge_block_verified` | PR is demonstrably unmergeable before approval | yes | `Merge block verified` |
| `approval_release_verified` | approval receipt flips exact SHA green and enables merge | yes | `Protection active` |

V1 scope: implement static/configuration verification and the data model/API shape. Do not overclaim runtime merge blocking in static mode.

### Required verifier input

```json
{
  "companyId": "...",
  "installationId": 115918626,
  "repoId": 1243788998,
  "repoFullName": "permission-protocol/dispatch",
  "branchOrPattern": "main",
  "requiredSignal": {
    "kind": "status",
    "context": "Permission Protocol"
  }
}
```

### V1 verifier output

```json
{
  "level": "configuration_verified",
  "target": {
    "repoId": 1243788998,
    "repoFullName": "permission-protocol/dispatch",
    "branchOrPattern": "main"
  },
  "requiredSignal": {
    "kind": "status",
    "context": "Permission Protocol",
    "expectedProducer": "github_app:3065051"
  },
  "issues": []
}
```

---

## 13. API Requirements

### `GET /api/v1/github-app/installations`

List installations accessible to current user with linked workspace status.

### `POST /api/v1/github-app/select-target`

Stores explicit onboarding target. Validates user membership, installation access, repo ID/repo access, branch/pattern format. Does not mutate GitHub.

### `POST /api/v1/github-app/sync-repos`

Refreshes repositories for an installation. Used after a repo is added to an existing GitHub App installation.

### `POST /api/v1/github-app/preflight`

Runs read-only capability checks and returns named issues + repair actions.

### `POST /api/v1/github-app/create-test-pr`

Must run test PR preflight first. If Contents write is missing, return `MISSING_CONTENTS_WRITE_FOR_TEST_PR` with manual fallback. Do not attempt mutation.

### `POST /api/v1/github-app/verify-protection`

Runs static verifier for V1. Returns verifier level, evidence, and issues.

---

## 14. Security Requirements

Server must never trust client `repoFullName`, `installationId`, or `companyId` alone.

Requirements:

- Validate authenticated user belongs to workspace.
- Validate installation is linked to workspace or intentionally being linked.
- Verify repo by GitHub repo ID where possible.
- Verify repo belongs to selected installation.
- Webhooks should map by installation ID + repo ID, not only repo name.
- Repo rename/transfer marks protection target as needing repair.
- Status/check posting uses GitHub App installation token, not PAT/user token.
- Approval/status posting targets exact SHA where applicable.

---

## 15. Admin Handoff

Admin handoff is V1 for real repo protection because the evaluator may not be GitHub org admin.

Handoff package includes:

- requesting user/workspace,
- GitHub org/account,
- repo and branch/pattern,
- required permissions,
- optional permissions clearly separated,
- why each permission is needed,
- GitHub action link,
- return/sync link.

After admin action, PP supports `Sync repos` and reruns preflight.

---

## 16. V1 Cutline

### Must ship first

- Explicit target selection: workspace → installation → repo → branch/pattern.
- Repo sync repair for existing installations.
- Named GitHub/setup errors for known failure modes.
- Missing Contents write handled as optional assisted-test blocker.
- No mutation before preflight + consent.
- Static `ProtectionVerifier` with `configuration_verified` level.
- Manual PR fallback commands.
- Basic admin handoff.
- Source-of-truth precedence enforced.
- Regression tests for observed incident.

### V1.5 follow-up

- Runtime verifier with manual/assisted PR.
- `merge_block_verified` and `approval_release_verified`.
- Partial setup repair flows.
- Wireframes for all high-leverage UX states.
- Better observability dashboard.

### Later / separate PRDs

- Authority Model v1 implementation.
- Quorum/signer roster.
- Break-glass.
- GHES.
- Automatic ruleset creation polish.
- GitHub Checks migration.

---

## 17. Test Plan / Ship Gate

Tests are the ship gate. Implementation PRs should add or update tests for these cases.

### Unit tests

- GitHub error → named issue-code mapping.
- Source-of-truth precedence.
- RequiredSignal canonical context matching.
- Tenant/repo validation helpers.
- Test PR preflight: missing Contents write.

### Integration tests

- Repo not included in installation → `APP_NOT_INSTALLED_ON_REPO`.
- Missing Contents write → core protection not blocked; assisted test PR blocked.
- Stale `primaryRepoFullName=permission-protocol/site`; selected target `permission-protocol/dispatch`; onboarding uses dispatch.
- Sync repos after repo added to existing installation.
- Wrong required signal context → `SIGNAL_CONFIGURED_WRONG_CONTEXT`.
- Branch protection/ruleset conflict → `PROTECTION_CONFLICT`.

### E2E / smoke tests

- Demo receipt lane completes without customer repo write permissions.
- Real repo protection lane reaches `configuration_verified` with least-privilege permissions.
- Assisted test PR lane falls back to manual commands when Contents write is missing.
- Non-admin can generate admin handoff.

---

## 18. Observability

Track events:

- `onboarding_target_selected`
- `repo_sync_started`
- `repo_sync_succeeded`
- `repo_sync_failed`
- `repo_preflight_started`
- `repo_preflight_passed`
- `repo_preflight_failed`
- `repo_preflight_repair_action_clicked`
- `protection_verifier_started`
- `protection_verifier_completed`
- `test_pr_preflight_failed`
- `manual_test_pr_commands_viewed`
- `admin_handoff_generated`

Segment by lane and issue code.

---

## 19. Open Questions

1. Should demo receipt lane use PP-owned demo repo, generated user repo, or GitHub template?
2. What is the minimal acceptable static verifier evidence for V1 launch?
3. Should automatic ruleset configuration stay deferred until runtime verifier exists?
4. Should `primaryRepoFullName` be renamed/deprecated in favor of protection targets?

Resolved for V1:

- Commit status is v1 required signal; Checks are future-compatible.
- Contents write is optional for assisted test PR only.
- Demo receipt and real repo protection are separate milestones.
- Static verifier cannot claim full runtime protection.

---

## 20. Immediate Engineering Prompt

Implement Phase 1 only:

1. explicit target selection,
2. named GitHub/setup errors,
3. preflight before test PR mutation,
4. repo sync repair,
5. stale primary repo fix,
6. static verifier foundation,
7. regression tests.

Do not build authority model, quorum, break-glass, GHES, full runtime verifier, or automatic ruleset polish in this pass.
