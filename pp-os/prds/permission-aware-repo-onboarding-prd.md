# PRD: Permission-Aware Repository Onboarding

Generated: 2026-05-19
Status: Revised Draft
Revision: 2026-05-19 — v3 hardened after external authority-model review
Owner: Product / Engineering
Product area: Permission Protocol activation, GitHub App install, repo protection

---

## 1. Executive Summary

Permission Protocol onboarding currently treats GitHub repository setup as a mostly invisible backend concern. When a repo is missing from an installation, a workspace has a stale primary repo, or the GitHub App lacks permissions for an optional test-PR action, users can hit generic failures like `GitHub API request failed` with no useful path forward.

This is unacceptable for the product category PP is trying to own. PP sells trust, authority, and deterministic control over consequential agent actions. The onboarding experience must embody that trust from the first minute.

The correct long-term fix is to redesign repo onboarding around a permission-aware state machine and a hard protection verifier contract:

1. Separate core repo protection from optional demo/test PR creation.
2. Require only low-trust permissions for the core product.
3. Make the install target explicit: workspace → GitHub account/installation → repository → branch/environment.
4. Run preflight checks before mutation.
5. Convert every GitHub/API/setup failure into a named, repairable state.
6. Track two activation milestones separately:
   - Receipt activation: user experiences Blocked Action → Signer Decision → Receipt.
   - Repo protection activation: user's own repo is actually protected by a required PP-authored check.
7. Verify repo protection with evidence, not configuration assumptions.
8. Treat admin handoff, stale-install repair, webhook idempotency, and cross-tenant safety as first-class requirements.
9. Define the receipt, signer authority, outage, replay, and merge semantics that make repo protection auditable.

The goal is not merely to fix one `dispatch` onboarding issue. The goal is to make PP onboarding deterministic, trust-building, and enterprise-ready.

---

## 2. Problem Statement

### Current observed failure

A user tried to add `permission-protocol/dispatch` to their PP account. The flow showed:

- Workspace still referencing `permission-protocol/site` as the current repo.
- The walkthrough attempting to create a test PR.
- A generic `GitHub API request failed` banner.
- No explanation of whether the issue was repo access, workspace state, missing permissions, branch protection, or GitHub API failure.

Investigation showed several overlapping weaknesses:

- The GitHub App installation can be repo-scoped, so newly created repos may not be accessible until explicitly added.
- The core app had enough access to read/protect/status repos, but not enough permission to create a test PR by writing files/branches.
- The UI treated `primaryRepoFullName` as the repo context even when the user was trying to connect a different repo.
- The activation flow collapsed distinct states into a generic error.

### Core product problem

PP currently conflates three jobs:

1. Install PP on a GitHub account/repo.
2. Protect a real repo with a PP-authored required check.
3. Create a demonstration PR to show the approval/receipt loop.

Those jobs have different permission requirements, different user expectations, and different success criteria. Combining them creates fragile onboarding and unnecessary trust friction.

---

## 3. Goals

### Product goals

- Users can connect and protect a repo without granting unnecessary write permissions.
- Users always know exactly which workspace, GitHub installation, repo, and branch PP is configuring.
- Users can reach a first receipt quickly without depending on write access to their own repo.
- Users can verify their own repo is protected through a deterministic checklist.
- Every setup failure is specific, named, and repairable.

### Business goals

- Increase successful activation rate: Blocked Action → Signer Decision → Receipt.
- Increase trust with security-conscious buyers by minimizing requested permissions.
- Reduce founder/support intervention during repo onboarding.
- Make onboarding credible for enterprise users who cannot grant repo write access or automatic ruleset mutation.

### Technical goals

- Replace implicit primary-repo behavior with explicit repo selection state.
- Add a repo setup preflight system with named states and remediation actions.
- Separate mutation-capable test PR creation from core protection.
- Add observability for each onboarding state, failure, and repair action.

---

## 4. Non-Goals

This PRD does not require:

- Building a full enterprise admin console.
- Supporting every Git provider beyond GitHub.
- Replacing the Deploy Gate primitive.
- Requiring PP to create branches/files in customer repositories by default.
- Automatically configuring every possible branch protection/ruleset variant on day one.
- Solving pricing, billing, or organization management.

---

## 5. User Personas

### 5.1 Founder / technical evaluator

Wants to try PP quickly on a real or demo repo. May be comfortable granting permissions, but will lose trust if errors are opaque.

### 5.2 Engineering manager / platform lead

Needs to know PP can enforce approval gates without dangerous broad repository write permissions.

### 5.3 Security / compliance buyer

Cares about auditability, least privilege, provenance of checks, and explicit human approval. Generic errors or excessive permissions damage trust immediately.

### 5.4 GitHub org admin

Controls App installation and permissions. May not be the same person using PP. Needs clear instructions and re-approval links.

---

## 6. Key Product Principles

1. **Least privilege by default**
   Core repo protection should not require Contents write.

2. **Permission requirements are product surface**
   If PP lacks a permission, the UI must say exactly which permission is missing, why it matters, and whether it is optional or required.

3. **No invisible repo context**
   Every flow must show the explicit tuple: workspace → GitHub account/installation → repo → branch/environment.

4. **Preflight before mutation**
   PP must never attempt to create branches/files/PRs before confirming it has the needed permissions and repo access.

5. **Two activations, not one**
   Demo receipt activation and real repo protection activation are both valuable, but they are not the same milestone.

6. **Every error has a repair path**
   No generic `GitHub API request failed`. Every failure maps to a named state and a next action.

7. **Trust beats magic**
   A manual copy-paste command can be better than a magical write operation if it preserves user trust.

---


## 6A. Core Authority Model

Repo onboarding is not just a GitHub setup problem. It is the first concrete encounter a user has with PP's authority primitive. The PRD must therefore define the artifacts and actors involved in a protected action.

### 6A.1 Receipt contract

A receipt is the durable proof that PP evaluated an action, routed it through the applicable policy, captured the authorized human/system decision, and emitted a verifiable result.

V1 receipt shape should be versioned and boring:

```json
{
  "version": "pp.receipt.v1",
  "receiptId": "rcpt_...",
  "issuedAt": "2026-05-19T17:52:00Z",
  "workspace": {
    "id": "...",
    "name": "..."
  },
  "action": {
    "kind": "github_pr_merge_gate",
    "repoId": 1243788998,
    "repoFullName": "permission-protocol/dispatch",
    "pullRequest": 12,
    "headSha": "abc123",
    "baseBranch": "main",
    "diffHash": "sha256:..."
  },
  "policy": {
    "policyId": "pol_...",
    "policyVersion": "2026-05-19",
    "decisionRequired": "human_approval",
    "policyHash": "sha256:..."
  },
  "decision": {
    "outcome": "approved",
    "signerId": "usr_...",
    "signerRole": "workspace_owner",
    "decisionAt": "2026-05-19T17:53:00Z",
    "channel": "pp_dashboard",
    "reason": "Approved release to main"
  },
  "proof": {
    "signatureKind": "jws_ed25519",
    "keyId": "pp_live_2026_05",
    "signature": "...",
    "publicKeyUrl": "https://permissionprotocol.com/.well-known/pp-keys.json"
  }
}
```

Required properties:

- Receipt binds to exact action context, including repo ID and PR head SHA.
- Receipt embeds or references the evaluated policy version/hash.
- Receipt names the signer and their authority basis at decision time.
- Receipt is independently verifiable through published PP public keys.
- Receipt remains verifiable if PP's app is unavailable later.
- Receipt is immutable after issue; corrections require superseding receipts, not mutation.

V1 can start with PP-hosted verification and CLI/export support, but the data model must not depend on PP being online forever to prove a historical receipt.

### 6A.2 Receipt retention, export, and deletion

Enterprise buyers will ask how long receipts live and who controls them.

Requirements:

- Workspace-level retention policy, defaulting to long-lived audit retention.
- Export API for receipts by repo, PR, signer, date range, and policy.
- Public receipt URLs may be disabled or access-controlled per workspace.
- Deletion must preserve audit integrity where legally allowed; prefer tombstone/supersession over silent deletion.
- GDPR deletion requests must be handled by separating personal data redaction from cryptographic audit facts where possible.
- Customer-owned storage/export is a future enterprise path and should not be blocked by v1 schema choices.

### 6A.3 Signer identity and authority

The signer is the person or system authorized to approve a protected action for a workspace under a policy.

V1 requirements:

- Workspace has explicit signer roster.
- Signer authority is scoped by workspace, repo, environment/branch, and action category where possible.
- Every approval records signer ID, auth method, role, and authority source.
- Revoked signers cannot approve new actions.
- Historical receipts preserve signer authority at decision time.
- If no signer is available, action remains pending until expiry or break-glass.

Self-approval policy must be explicit:

- Default recommendation for protected production branches: PR author cannot be sole approver.
- V1 may allow self-approval for single-user/dev workspaces, but the receipt must flag `selfApproval: true`.
- Policy should allow later enforcement of no-self-approval without schema rewrite.

### 6A.4 Policy and quorum extensibility

V1 can ship single-signer approval, but the data model must not bake in single-approver as the permanent primitive.

Policy model must leave room for:

- M-of-N approvals.
- Role-restricted approvers.
- Path-scoped approvers.
- Environment-scoped approvers.
- Bot-specific policies.
- Risk-tier-specific policies.
- Founder/admin veto.

V1 schema should represent approval requirements as an array or policy object, not a single nullable `approvedBy` field.

### 6A.5 Notification model for signers

Activation metrics depend on signers knowing action is pending.

V1 notification requirements:

- Dashboard pending queue.
- Email notification for signer requests.
- Webhook/Slack/Discord notification as an optional workspace integration.
- Notification includes repo, PR, risk summary, requested action, expiry, and signing URL.
- Notification state is tracked: sent, delivered where available, opened where available, expired.

Do not rely on GitHub PR comments as the only notification path.

### 6A.6 Outage and break-glass model

Fail-closed is correct for safety, but enterprise buyers need a documented emergency path.

Requirements:

- Define PP service status states: healthy, degraded, unavailable.
- Protected repo behavior during PP outage is explicit: default fail-closed.
- Break-glass can be enabled per workspace by admin policy.
- Break-glass invocation requires elevated workspace role and strong confirmation.
- Break-glass emits a receipt or emergency audit record.
- Break-glass has expiry and scope: repo, branch/environment, time window, reason.
- Break-glass does not silently mark PP approval; it records emergency bypass.
- Dashboard and export must show break-glass events prominently.

Open business question: enterprise SLA and support response time are out of scope for v1 implementation, but the product surface must not pretend outages do not exist.

### 6A.7 SHA, replay, force-push, and merge semantics

Approval must be bound to the exact code state reviewed.

Requirements:

- Approval binds to exact PR head SHA and relevant diff/policy hash.
- Any PR synchronize event with a new head SHA supersedes prior pending/approved signer requests unless an explicit carry-forward rule proves the diff is unchanged or only merge-base changed.
- Force-push after approval requires new approval unless carry-forward rule passes.
- Approval has expiry; expired approval cannot green a required signal.
- Receipts are one-time or scope-bound where verification/redeem semantics apply.
- Status/check posting must target exact SHA, never branch name alone.
- If squash/rebase merge produces a different merge commit SHA, the receipt remains bound to the approved PR head SHA plus merge metadata. The merge record should link approved head SHA → resulting merge commit SHA.
- If GitHub reports mergeability inconsistently or delayed, verifier state is `unknown`/`pending`, not `active`.

### 6A.8 Bot PR policy

Bot PRs are common and high-volume. Onboarding must not surprise users when Dependabot/Renovate/internal bot PRs appear.

V1 requirements:

- Identify bot actor in action context and receipt.
- Default bot PRs follow same gate as human PRs unless policy says otherwise.
- Policy model leaves room for auto-clear rules for low-risk dependency patch bumps, lockfile-only updates, or internal trusted bots.
- Auto-clear must still emit receipt/audit evidence.

### 6A.9 Grandfathering open PRs at install time

Turning on PP for a repo with existing open PRs needs an explicit migration policy.

V1 recommendation:

- Existing open PRs are discovered during protection setup.
- User chooses one of:
  - apply PP gate to all open PRs,
  - apply only to new PRs after activation timestamp,
  - manually select PRs to gate.
- The choice is recorded in workspace audit history.
- Default for production protection should be conservative: new PRs after activation, with visible warning about existing PRs.

---

## 7. Activation Milestones

### 7.1 Receipt activation

Definition: user experiences a full PP decision loop:

Blocked Action → Signer Decision → Signed Receipt

This may happen in:

- PP-owned demo repo.
- User-owned demo repo.
- User's production/staging repo.

This proves the authority receipt loop.

### 7.2 Repo protection activation

Definition: a user-selected repo has a PP-authored required signal that blocks merging until PP signs.

Required evidence:

- Repo is connected to the intended workspace.
- PP GitHub App is installed on the repo.
- Required signal is configured for the target branch/ruleset.
- Required signal is produced by the PP GitHub App, not a PAT, user token, or unrelated workflow identity.
- PP can post the required signal on the exact commit SHA under evaluation.
- A verifier confirms the PR is unmergeable before approval.
- Approval flips the PP-authored signal green.
- Merge becomes possible only after the PP approval receipt exists.

This proves the governance primitive.

### 7.2.1 Required signal v1 decision

For v1, PP should continue using the current commit status path if Deploy Gate already depends on it. Do not block this PRD on a full migration to GitHub Checks.

However, implementation must introduce a `RequiredSignal` abstraction so the verifier can support both:

- `status` — GitHub commit status context, v1 default.
- `check` — GitHub Check Run / Check Suite, future-compatible.

The product copy should say "required PP check" to users, but the implementation should not hard-code business logic to one GitHub primitive.

### 7.3 Why separate them

A demo receipt can be achieved quickly and reliably. Real repo protection may require GitHub admin rights, branch protection, ruleset permissions, or internal approval. Combining them creates fake success or opaque failure.

---

## 8. Proposed UX: Three Internal Lanes, One Guided User Sequence

The architecture has three lanes, but the UI should not present three equal doors to a new user. That creates choice paralysis and exposes implementation structure too early.

Default user-facing sequence:

1. Primary CTA: `Get your first signed receipt`.
2. After receipt success: `Protect a real repo`.
3. Inline optional action: `Use my repo for the test instead`.

Internally, the product still supports three lanes.

### Lane A: Demo receipt lane

User-facing label: `Get your first signed receipt`
Internal lane: `demo_receipt`

Purpose: prove the PP approval loop fast.

Characteristics:

- Uses PP-owned demo/template repo or controlled sandbox.
- Guaranteed setup.
- No customer repo write permissions required.
- Ends with a real receipt and public receipt page.

Success state:

- `Receipt loop verified`
- CTA: `Protect your first real repo`

Important: this must not mark the workspace as fully activated. Demo receipt activation is useful, but production activation requires real repo protection verification.

### Lane B: Real repo protection lane

User-facing label: `Protect a real repo`
Internal lane: `real_repo_protection`

Purpose: configure actual enforcement on a user-selected repo.

Characteristics:

- User explicitly selects workspace, GitHub account/install, repo, branch.
- PP runs preflight.
- PP can auto-configure when permissions allow.
- Otherwise PP provides manual setup instructions and verifies after user/admin completes them.
- Does not require Contents write.

Success state:

- `Repo protection active`
- Evidence panel shows protected branch/check/status provenance.

### Lane C: Assisted test PR lane

User-facing label: `Use my repo for the test instead` or `Create a test PR`
Internal lane: `assisted_test_pr`

Purpose: generate a realistic PR that triggers PP.

Characteristics:

- Optional convenience path.
- Requires Contents write if PP creates the branch/file itself.
- If Contents write is missing, offer:
  - Request elevated permission.
  - Copy-paste git commands.
  - Open GitHub web instructions.

Success state:

- Test PR exists.
- PP signer request created.
- User signs.
- Receipt attached.
- Required check turns green.

---

## 9. Permissions Model

### 9.1 Core GitHub App permissions

Core PP should request only what is necessary to protect and evaluate repos.

Expected baseline:

- Metadata: read
- Pull requests: read/write if PP comments or enriches PRs; read-only if comments are removed from core path
- Contents: read if PP inspects diffs/file contents
- Statuses: write
- Checks: write if moving from commit statuses to GitHub Checks
- Actions: read if workflow state is inspected

Core PP should **not** require Contents write.

### 9.2 Optional elevated permissions

Only needed for assisted mutation flows:

- Contents: write — create test branch/file/PR content
- Administration: write — configure rulesets/branch protection automatically, if supported and approved

These should be framed as optional capabilities:

- `Let PP create a test PR for me`
- `Let PP configure branch protection for me`


### 9.4 Declared vs effective capabilities

PP must distinguish two capability layers:

1. **Declared capability** — what GitHub says the App installation has permission to do.
2. **Effective capability** — what PP has actually verified it can do against the selected repo/branch.

Declared permission is not enough. A repo may be archived, branch-protected, transferred, renamed, policy-restricted, or otherwise unable to accept an operation even when the App has the declared permission.

Capability examples:

| Capability | Declared check | Effective check |
|---|---|---|
| `canReadRepo` | Installation contains repo | Fetch repo metadata by repo ID |
| `canReadPullRequests` | Pull requests permission | List PRs for selected repo |
| `canPostRequiredSignal` | Statuses/checks write | Post/update a harmless status/check on a known test SHA or controlled verification target |
| `canInspectRisk` | Contents read | Fetch changed files/diff metadata for a PR |
| `canCreateTestPr` | Contents write + PR write | Confirm branch/file/PR mutation path is available before attempting full test PR creation |
| `canAutoConfigureProtection` | Administration write | Verify ruleset/branch-protection read/write APIs are available for selected branch |

Preflight responses must expose both layers when they differ.

### 9.3 Permission copy

Each permission should have human-readable explanations:

- `Contents read`: lets PP inspect changed files and classify risk. PP cannot change your code.
- `Statuses write`: lets PP post the required merge-blocking status from the PP GitHub App.
- `Contents write`: optional; lets PP create a temporary test branch and `.pp-test` file. Not required for protection.
- `Administration write`: optional; lets PP configure rulesets automatically. You can configure them manually instead.

---


### 9.5 Required signal naming

GitHub required signal matching is brittle. PP must define canonical and legacy contexts explicitly.

V1 canonical required signal:

- Kind: `status`
- Context: `Permission Protocol`
- Expected producer: PP GitHub App ID `3065051`
- User-facing label: `Permission Protocol`

Requirements:

- Do not silently change the status context.
- If legacy contexts exist, detect and show migration guidance.
- Branch protection/ruleset verification must compare exact context string.
- Status posting must target exact commit SHA.
- Any future GitHub Checks support must map through `RequiredSignal`, not fork business logic.

### 9.6 PR comments v1 decision

For v1, PR comments are optional UX, not core enforcement.

Recommendation:

- Core governance path should rely on required status + dashboard/signing URL.
- If PR comments are enabled, `pull_requests: write` must be disclosed as optional/enhanced UX unless another core flow truly requires it.
- If PP lacks PR write, protection should still work.
- Activation copy should not imply comments are required for enforcement.

---


### 9.7 GitHub Enterprise Server extension point

V1 may target github.com only, but the design must not make GitHub Enterprise Server impossible.

Requirements:

- Store GitHub host/base URL with installation/provider records.
- Do not hard-code `https://api.github.com` in new abstractions where provider config belongs.
- Webhook verification and API client construction should accept host configuration.
- Capability checks should tolerate GHES version differences.
- Product copy may say GHES is not supported in v1, but architecture should be provider-host aware.

---

## 10. Repo Onboarding State Machine

### 10.1 Entity model

Explicit onboarding target:

```text
Workspace
  → GitHubInstallation
    → Repository
      → Branch / Environment
        → ProtectionTarget
```

The user's current onboarding session should store this tuple. It must not infer repo context from stale `Company.primaryRepoFullName` unless no explicit target exists.

### 10.2 Core states

```text
START
  → WORKSPACE_SELECTED
  → INSTALLATION_SELECTED
  → REPO_SELECTED
  → PREFLIGHT_RUNNING
  → PREFLIGHT_FAILED_REPAIRABLE
  → PREFLIGHT_PASSED
  → PROTECTION_CONFIGURING | MANUAL_SETUP_REQUIRED
  → PROTECTION_VERIFYING
  → REPO_PROTECTION_ACTIVE
```

Optional test PR states:

```text
PREFLIGHT_PASSED
  → TEST_PR_MODE_SELECTED
  → TEST_PR_PERMISSION_CHECK
  → TEST_PR_MANUAL_INSTRUCTIONS | TEST_PR_CREATING
  → TEST_PR_CREATED
  → SIGNER_REQUEST_CREATED
  → RECEIPT_SIGNED
```

### 10.3 Named failure states

Every failure must map to one of these or a similarly specific code.

| Code | Meaning | User-facing repair |
|---|---|---|
| `APP_NOT_INSTALLED_ON_ACCOUNT` | PP GitHub App is not installed on selected GitHub account/org | Install PP on GitHub account/org |
| `APP_NOT_INSTALLED_ON_REPO` | Installation exists but selected repo is not included | Add this repo to the GitHub App installation |
| `INSTALLATION_NOT_LINKED_TO_WORKSPACE` | GitHub installation exists but is not linked to this PP workspace | Link install to workspace |
| `REPO_NOT_CONNECTED_TO_WORKSPACE` | Repo exists in GitHub but no connected PP DB record for this workspace | Sync repositories / reconnect install |
| `MULTIPLE_INSTALLATIONS_NEED_SELECTION` | User has multiple accessible installs | Choose GitHub account/org |
| `PRIMARY_REPO_STALE` | Workspace primary repo differs from explicit selected repo | Confirm/switch selected repo |
| `MISSING_STATUSES_WRITE_FOR_GATE` | PP cannot post required status | Re-approve App permissions |
| `MISSING_CHECKS_WRITE_FOR_GATE` | PP cannot post required check | Re-approve App permissions |
| `MISSING_CONTENTS_READ_FOR_RISK` | PP cannot inspect repo contents/diffs | Re-approve App permissions or use limited mode |
| `MISSING_CONTENTS_WRITE_FOR_TEST_PR` | PP cannot create branch/file for test PR | Use manual PR instructions or grant optional permission |
| `MISSING_ADMIN_WRITE_FOR_AUTO_RULESET` | PP cannot configure rulesets automatically | Manual setup or grant optional permission |
| `RULESET_API_UNAVAILABLE` | GitHub plan/API cannot verify ruleset | Show manual verification path |
| `REQUIRED_CHECK_NOT_CONFIGURED` | Branch does not require PP check | Configure required status/check |
| `CHECK_PROVENANCE_INVALID` | Check exists but not from PP GitHub App | Reconfigure required check to PP App-authored context |
| `GITHUB_RATE_LIMITED` | GitHub API rate limit hit | Retry after timestamp; preserve setup state |
| `GITHUB_API_UNAVAILABLE` | GitHub outage/transient failure | Retry; status page link; do not mutate |

---


### 10.4 Partial setup and recovery states

Setup is allowed to partially succeed. Repair must be idempotent and should not require starting over.

Named partial states:

| State | Meaning | Repair |
|---|---|---|
| `WORKFLOW_INSTALLED_SECRET_MISSING` | Deploy Gate workflow exists but API/verify secret missing | inject secret or show manual secret step |
| `SECRET_PRESENT_WORKFLOW_MISSING` | Secret exists but workflow missing | install workflow |
| `SIGNAL_CONFIGURED_WRONG_CONTEXT` | Branch protection requires a non-canonical PP context | migrate required signal context |
| `RULESET_BRANCH_MISMATCH` | Ruleset exists but targets wrong branch/pattern | update target or select matching branch |
| `APP_UNINSTALLED` | GitHub App removed after activation | reinstall app and resync |
| `APP_PERMISSIONS_DOWNGRADED` | App remains installed but no longer has required permissions | admin handoff for re-approval |
| `REPO_REMOVED_FROM_INSTALLATION` | Repo no longer included in selected installation | add repo back or choose new repo |
| `REPO_RENAMED_OR_TRANSFERRED` | Repo ID moved to new owner/name | update repo record and rerun verifier |
| `PR_SHA_SUPERSEDED` | Approval/check applies to old SHA | create new signer request for current SHA |

Repair actions must preserve audit history and supersede stale activation attempts instead of deleting them.

### 10.5 Source-of-truth precedence

When multiple records disagree, implementation must use this precedence:

1. Current explicit onboarding target.
2. Active verified protection target.
3. Current activation attempt target.
4. Company default repo (`primaryRepoFullName`) as dashboard default only.
5. GitHub synced repos as selectable inventory.
6. Client-supplied repo string only as a request to validate, never as authority.

No onboarding mutation or verifier call may use `primaryRepoFullName` if an explicit onboarding target exists.


### 10.6 Concurrent onboarding

Two workspace members may attempt onboarding in parallel.

Requirements:

- Onboarding target updates are versioned or use optimistic concurrency.
- User sees when another member changed the active target.
- Separate onboarding attempts can coexist, but only one can become active protection target for the same repo/branch at a time.
- Activation attempts are keyed by workspace + repoId + branch + lane, not workspace alone.
- Superseding an attempt records who superseded it and why.

---

## 11. Preflight Requirements

### 11.1 Repo access preflight

Input:

- workspaceId
- installationId
- repoFullName
- targetBranch

Checks:

- User belongs to workspace.
- Installation is linked to workspace.
- Installation token can be minted for selected repo.
- Repo appears in installation repositories.
- Repo DB record exists and is `connected`.
- Repo metadata can be fetched.
- Target branch exists.

Output:

```json
{
  "status": "passed" | "repairable" | "blocked",
  "target": {
    "workspaceId": "...",
    "installationId": 123,
    "repoFullName": "org/repo",
    "branch": "main"
  },
  "capabilities": {
    "canReadContents": true,
    "canWriteStatuses": true,
    "canWriteChecks": false,
    "canCreateTestPr": false,
    "canAutoConfigureRuleset": false
  },
  "issues": [
    {
      "code": "MISSING_CONTENTS_WRITE_FOR_TEST_PR",
      "severity": "optional",
      "message": "PP can protect this repo but cannot create a test PR for you.",
      "repairActions": ["manual_test_pr", "request_contents_write"]
    }
  ]
}
```

### 11.2 Protection preflight

Checks:

- PP can post a status/check from GitHub App installation token.
- Required check/ruleset exists for branch.
- Required check is the expected PP context.
- If using GitHub Actions workflow, workflow file exists.
- Required secret/API key exists if deploy-gate action is used.
- Fail-closed behavior is configured.

### 11.3 Test PR preflight

Checks:

- Can create branch.
- Can write file.
- Can create PR.
- Existing deterministic branch/PR does not conflict, or can be reused.

If missing write permission, do not call GitHub mutation APIs.

---


## 11A. User Journeys

This PRD must be implemented from user journeys, not only from backend states. The following journeys are required for v1 planning and QA.

### 11A.1 New user: first receipt, then real repo

1. User signs up.
2. User sees primary CTA: `Get your first signed receipt`.
3. User completes demo receipt lane without granting customer repo write permissions.
4. User sees `Receipt loop verified`, not `Workspace activated`.
5. User is prompted to protect a real repo.
6. User selects GitHub account, repo, and branch.
7. PP runs preflight and shows exact readiness/repair checklist.
8. PP verifies protection or shows repair actions.

### 11A.2 Returning user: existing GitHub install

1. User lands in onboarding or dashboard.
2. PP detects existing installations accessible to the user.
3. User chooses the GitHub account/org if more than one exists.
4. PP syncs repos for the selected installation.
5. User chooses repo and branch explicitly.
6. PP does not infer target from stale `primaryRepoFullName`.

### 11A.3 Repo not included in installation

1. User selects or searches for a repo that GitHub App cannot access.
2. PP returns `APP_NOT_INSTALLED_ON_REPO`.
3. User sees a repair action: add repo to installation.
4. If user is not admin, user generates admin handoff.
5. After admin completes GitHub action, user clicks `Sync repos`.
6. PP reruns preflight automatically.

### 11A.4 Non-admin evaluator with admin handoff

1. User selects a repo requiring admin action.
2. PP explains that protection is blocked by GitHub admin permissions, not PP failure.
3. User generates shareable admin handoff.
4. Admin sees exact repo, branch, required permissions, optional permissions, and reason for each.
5. Admin completes GitHub action.
6. User receives or manually triggers completion sync.
7. PP continues from previous onboarding target, not from the beginning.

### 11A.5 Real repo test without Contents write

1. User selects real repo protection lane.
2. PP preflight passes core protection permissions but detects missing Contents write for assisted test PR.
3. PP does not attempt branch/file/PR mutation.
4. User sees manual PR commands or optional permission upgrade.
5. User creates PR manually.
6. PP verifies signer request, approval, receipt, and required signal behavior.

### 11A.6 Existing workspace with stale primary repo

1. Workspace primary repo is `permission-protocol/site`.
2. User selects `permission-protocol/dispatch` as onboarding target.
3. Every onboarding screen shows `dispatch`.
4. Activation attempt and verifier use `dispatch`.
5. `primaryRepoFullName` is updated only after explicit confirmation or successful target selection.

---


### 11.4 Probe safety classification

Effective capability checks must not accidentally mutate customer repos. Every probe must be classified before implementation:

| Probe class | Meaning | Default allowed? | Example |
|---|---|---:|---|
| `read_only` | Reads GitHub state only | Yes | fetch repo metadata, branch, ruleset, PR files |
| `reversible_write` | Creates/updates removable state | Only with explicit user approval | temporary status/check on controlled SHA |
| `visible_write` | Creates visible repo artifacts | Only in assisted/manual test PR lane | branch, commit, PR, comment |
| `destructive_or_policy_write` | Changes durable policy/enforcement | Only after admin confirmation | branch protection/ruleset writes |

Default customer repo preflight must use read-only probes. Write probes require user/admin consent and must be idempotent with cleanup or clear persistence semantics.

---


### 11.5 GitHub mechanism clarity: App, workflow, statuses, rulesets

Implementation must crisply separate these responsibilities:

- **GitHub App**: owns installation, repo access, webhook handling, signer request creation, and PP-authored required signal posting.
- **Deploy Gate workflow**: optional repo-side mechanism that calls PP during CI/deploy workflows when the user wants workflow-native gating or receipt verification.
- **Required signal**: the GitHub status/check that branch protection/rulesets require before merge.
- **Branch protection/rulesets**: GitHub enforcement configuration that blocks merge until required signal is green.

V1 should not imply the workflow is required if App-authored status enforcement is sufficient. If the workflow is required for a specific path, the UI must explain why.

Branch protection vs rulesets:

- Verifier must inspect both when available.
- If both exist and disagree, state is `PROTECTION_CONFLICT`.
- The UI must show which mechanism is enforcing PP.
- Migration guidance must exist for legacy/wrong required signal contexts.

Rate budget strategy:

- Preflight and verifier calls should be cached per target with short TTL.
- Polling must use backoff and stop conditions.
- Webhooks should trigger state refresh rather than brute-force polling.
- Rate-limit responses must surface retry time and preserve user state.

---


### 11.6 Risk classifier contract

The PRD references risk classification because PP's value is not merely blocking merges; it is routing consequential changes to the right authority.

V1 risk classifier inputs:

- repoId/repoFullName
- PR number
- head SHA/base SHA
- changed files list
- diff metadata where permission allows
- actor identity, including bot/human
- target branch/environment
- policy context

V1 outputs:

```json
{
  "riskTier": "low" | "medium" | "high" | "unknown",
  "decision": "cleared" | "approval_required" | "denied",
  "reasons": ["protected_branch", "production_deploy", "sensitive_file_changed"],
  "confidence": "high" | "medium" | "low"
}
```

Failure mode:

- If classifier lacks required inputs, it returns `unknown` and policy determines fail-open/fail-closed behavior.
- For protected production branches, unknown should default to approval required, not cleared.
- Risk classifier inputs and output hash should be included or referenced in the receipt.

---

## 12. UX Requirements


### 12.0 Terminology, accessibility, mobile, and i18n

Terminology:

- User-facing term: `workspace`.
- Internal legacy model: `Company`.
- Product copy should say workspace. Code may still reference Company until renamed, but PRD/API docs should clarify the mapping.

Accessibility:

- Checklists, banners, drawers, and repair actions must be keyboard navigable.
- Status must not rely on color alone.
- Error banners must be announced to screen readers.
- Copy-paste command blocks need accessible labels and copy buttons.

Mobile signing:

- Signer request page must be usable on mobile.
- Critical approval context — repo, PR, SHA, risk, policy, signer identity — must appear above the fold or in a clear summary.
- Signing action must require deliberate confirmation, not an accidental tap.

Internationalization:

- Full i18n is deferred.
- User-facing strings added for this flow should be centralized enough to translate later.


### 12.1 Install target header

Every onboarding screen must show:

```text
Workspace: Rodrigo's Workspace
GitHub: permission-protocol org
Repo: permission-protocol/dispatch
Branch: main
Mode: Protect repo / Demo receipt / Test PR
```

If any value is missing, show a picker. Do not infer silently.

### 12.2 Setup checklist

Use a checklist with status, evidence, and repair action.

Example:

```text
Repository access
✓ PP is installed on permission-protocol/dispatch

Permissions
✓ Can read pull requests
✓ Can post required status
⚠ Cannot create a test PR
  PP needs Contents write only if you want us to create the test PR.
  [Use manual PR commands] [Grant optional permission]

Protection
✓ Workflow installed
⚠ Required check not configured on main
  [Configure automatically] [Show manual steps]
```

### 12.3 Error handling

No generic banners. Every banner must include:

- What failed.
- Why it matters.
- Whether core protection is blocked or only optional automation is blocked.
- One primary repair action.
- Details drawer for raw GitHub error.

Bad:

```text
GitHub API request failed
```

Good:

```text
PP can protect this repo, but cannot create a test PR yet.
GitHub has not granted Contents write to the PP App on permission-protocol/dispatch.
Use manual PR commands or grant optional Contents write.
```

### 12.4 Manual test PR path

If PP cannot create a test PR, show copy-paste commands:

```bash
git checkout -b pp-test-<short-id>
echo "Permission Protocol test file" > .pp-test
git add .pp-test
git commit -m "Add Permission Protocol test file"
git push origin pp-test-<short-id>
gh pr create --title "Permission Protocol test: approval required" --body "..."
```

Also provide GitHub web UI instructions for non-CLI users.

### 12.5 Admin handoff

If current user lacks GitHub org admin ability, generate a shareable admin request:

```text
Rod wants to protect permission-protocol/dispatch with Permission Protocol.
Required: Statuses write, Pull requests read, Contents read.
Optional: Contents write for assisted test PR creation.
Admin action: Add repo to installation / approve updated permissions.
```

---


## 12A. ProtectionVerifier Contract

The `ProtectionVerifier` is the core deliverable of this PRD. It determines whether a repo is truly protected by PP. Configuration alone is not enough.

### 12A.1 Input

```json
{
  "companyId": "...",
  "installationId": 115918626,
  "repoId": 1243788998,
  "repoFullName": "permission-protocol/dispatch",
  "branch": "main",
  "requiredSignal": {
    "kind": "status",
    "context": "Permission Protocol"
  }
}
```

### 12A.2 Output

```json
{
  "status": "active" | "repairable" | "blocked" | "unknown",
  "evidence": {
    "repoConnected": true,
    "installationMatchesWorkspace": true,
    "requiredSignalConfigured": true,
    "requiredSignalKind": "status",
    "requiredSignalContext": "Permission Protocol",
    "requiredSignalProvenance": "github_app:3065051",
    "targetBranch": "main",
    "testSha": "abc123",
    "preApprovalMergeable": false,
    "postApprovalSignalGreen": true,
    "postApprovalMergeable": true,
    "receiptId": "rcpt_..."
  },
  "issues": []
}
```

### 12A.3 Verifier levels

The verifier must not overclaim. Static configuration checks cannot prove runtime enforcement. Verification is layered:

| Level | Meaning | Requires PR? | Workspace badge |
|---|---|---:|---|
| `configuration_verified` | Repo/install/branch/ruleset/status context appear configured correctly | No | `Protection configured` |
| `signal_provenance_verified` | PP can post the required signal with GitHub App provenance on a known SHA | Usually no, but may require controlled SHA | `PP signal verified` |
| `merge_block_verified` | A PR is demonstrably unmergeable before PP approval | Yes | `Merge block verified` |
| `approval_release_verified` | Approval receipt flips the exact SHA green and makes merge possible | Yes | `Protection active` |

The product may show progress for lower levels, but must not show `Repo protection active` until `approval_release_verified` or an explicitly accepted enterprise/manual equivalent is complete.

### 12A.4 Required verifier checks

The verifier must confirm:

1. The selected repo belongs to the selected installation and workspace.
2. The selected branch exists.
3. The PP App can post the required signal on the relevant commit SHA.
4. GitHub branch protection or ruleset requires the PP signal for the selected branch.
5. The required signal context matches exactly.
6. The signal is produced by the PP GitHub App, not a PAT/user token.
7. A PR is not mergeable before PP approval.
8. After approval, PP posts green on the exact SHA.
9. The approval has a receipt.
10. Mergeability changes only after the approval/signature state changes.

### 12A.5 Verifier modes

- `static` — verifies configuration and provenance without creating a PR.
- `manual_pr` — verifies against a PR the user created.
- `assisted_pr` — verifies against a PR PP created after optional elevated permissions.

### 12A.6 Failure philosophy

If the verifier cannot prove protection, the product must say `Protection not verified` rather than `Protected`.

---

## 13. Data Model Requirements

### 13.1 Add explicit onboarding target

Create or extend an activation/onboarding model to store:

- companyId
- userId
- installationId
- accountLogin
- repoFullName
- targetBranch
- selectedLane: `demo_receipt` | `real_repo_protection` | `assisted_test_pr`
- preflightStatus
- preflightIssues JSON
- capabilities JSON
- lastGitHubErrorCode
- lastGitHubErrorMessage
- lastSyncedAt

### 13.2 Avoid stale primary repo coupling

`Company.primaryRepoFullName` may remain for dashboard defaults, but onboarding must prefer explicit onboarding target.

Rules:

1. If onboarding target exists, use it.
2. If not, ask user to select repo.
3. Only set `primaryRepoFullName` after the user explicitly selects a repo or after a single-repo install with clear confirmation.
4. Never show `Current repo: X` as if it is the repo being installed unless it matches the explicit target.


### 13.4 Migration and stale state repair

Existing users may already have:

- Active GitHub installations.
- `GitHubAppRepo` records.
- `Company.primaryRepoFullName` values.
- Activation attempts tied to old repos.
- Repos added/removed from GitHub installations after PP last synced.

Migration requirements:

1. Do not break existing protected repos.
2. Add a non-destructive `repo_state_repair` path that can:
   - resync installation repos,
   - detect stale primary repo values,
   - detect activation attempts pointing to unavailable repos,
   - suggest explicit target selection when ambiguity exists.
3. Backfill onboarding targets only when there is exactly one active connected repo and no conflicting activation attempt.
4. If multiple connected repos exist, require explicit user selection.
5. Keep `primaryRepoFullName` as a dashboard default only; do not use it as authoritative onboarding state.
6. Add internal/admin debug view for workspace repo state:
   - companyId,
   - primaryRepoFullName,
   - active installations,
   - connected repos,
   - latest onboarding target,
   - latest activation attempt,
   - verifier status.

### 13.3 Repository records

`GitHubAppRepo` should track capability snapshots:

- canReadContents
- canWriteStatuses
- canWriteChecks
- canCreateTestPr
- canAutoConfigureRuleset
- lastCapabilityCheckAt
- lastCapabilityIssues

This can be computed dynamically first and persisted later if needed.

---

## 14. API Requirements

### 14.1 `GET /api/v1/github-app/installations`

Returns installations accessible to current user, with account metadata and linked workspace status.

### 14.2 `POST /api/v1/github-app/select-target`

Input:

```json
{
  "companyId": "...",
  "installationId": 115918626,
  "repoFullName": "permission-protocol/dispatch",
  "branch": "main",
  "lane": "real_repo_protection"
}
```

Behavior:

- Validates user membership.
- Validates accessible installation.
- Stores onboarding target.
- Does not mutate GitHub.

### 14.3 `POST /api/v1/github-app/preflight`

Runs repo/protection/test-PR capability checks.

Must return named issue codes and repair actions.

### 14.4 `POST /api/v1/github-app/sync-repos`

Refreshes repos for an installation and upserts DB records.

Must be callable after a user adds a repo to an existing GitHub App installation.

### 14.5 `POST /api/v1/github-app/configure-protection`

Attempts automatic workflow/secret/ruleset setup only after preflight confirms required permissions.

If admin permissions are missing, returns `MANUAL_SETUP_REQUIRED` with instructions.

### 14.6 `POST /api/v1/github-app/create-test-pr`

Must first call or internally run test PR preflight.

If Contents write is missing, return:

```json
{
  "code": "MISSING_CONTENTS_WRITE_FOR_TEST_PR",
  "coreProtectionBlocked": false,
  "message": "PP can protect this repo but cannot create a test PR for you.",
  "repairActions": ["manual_test_pr", "request_contents_write"]
}
```

No generic 500 for known GitHub permission states.

---

## 15. Observability Requirements

Track events:

- `onboarding_lane_selected`
- `github_installation_selected`
- `repo_target_selected`
- `repo_preflight_started`
- `repo_preflight_passed`
- `repo_preflight_failed`
- `repo_preflight_repair_action_clicked`
- `repo_sync_started`
- `repo_sync_succeeded`
- `repo_sync_failed`
- `protection_config_started`
- `protection_config_manual_required`
- `protection_config_succeeded`
- `test_pr_preflight_failed`
- `test_pr_manual_commands_viewed`
- `test_pr_create_succeeded`
- `receipt_activation_completed`
- `repo_protection_activation_completed`

Each event should include:

- companyId
- userId if available
- installationId
- repoFullName
- lane
- issue codes
- GitHub status code where relevant

Dashboards:

- Activation funnel by lane.
- Top preflight failure codes.
- Time from signup to receipt activation.
- Time from signup to repo protection activation.
- Permission re-approval drop-off.

Alerts:

- Spike in `GITHUB_API_UNAVAILABLE`.
- Spike in generic/unknown GitHub failures.
- Create-test-PR failures above threshold.
- Repo protection verifier failures after previously active.

---

## 16. Security & Trust Requirements

- Do not request Contents write by default.
- Do not store installation tokens beyond short-lived cache.
- Always use GitHub App installation tokens for PP status/check posting.
- Never use PAT/user tokens for required PP check provenance.
- Show raw GitHub errors only in details/debug drawer, not primary UX.
- Record audit events for permission changes and protection changes.
- Distinguish optional convenience permissions from required governance permissions.

### 16.1 Tenant and repo spoofing protections

The server must never trust `repoFullName`, `installationId`, or `companyId` from the client by themselves.

Requirements:

- Verify the authenticated user belongs to the workspace.
- Verify the installation is linked to that workspace or is accessible to the user and intentionally being linked.
- Verify repo by GitHub `repoId`, not only by `owner/name`.
- Verify the repo belongs to the selected installation.
- Webhooks must map by installation ID + repo ID where possible, not only `repoFullName`.
- Repo rename and transfer events must update records or mark the repo as needing repair.
- Prevent a repo from being linked to the wrong tenant through stale names or duplicated names after transfer.
- Do not allow client-supplied `companyId` to override tenant context.

### 16.2 Webhook idempotency and race safety

GitHub events can arrive out of order, be retried, or be delivered after the user changes selection.

Requirements:

- Repo sync must be idempotent per `installationId + repoId`.
- Test PR creation must be idempotent per `companyId + repoId + branch + deterministicTestKey`.
- Signer request creation must be idempotent per `repoId + prNumber + headSha + environment`.
- Approval/status posting must target exact SHA, never branch name alone.
- Webhook handlers must tolerate missing repo records by triggering repair/sync instead of silently skipping where safe.
- Out-of-order events must not move an activation attempt backward.
- Closed/superseded PRs must not receive green statuses after a newer SHA requires approval.


---


## 16A. Admin Handoff Requirements

Admin handoff is a must-have for real repo protection, not a nice-to-have. In the target market, the person evaluating PP often will not be the GitHub org admin.

### 16A.1 Handoff package

Generate a shareable admin handoff page/message containing:

- Requesting user and workspace.
- GitHub account/org.
- Repo(s) requested.
- Target branch/environment.
- Required permissions.
- Optional permissions clearly separated.
- Why each permission is needed.
- Exact GitHub action link: install app, add repo to installation, or approve permission update.
- Callback/deep link to return to PP after completion.

### 16A.2 Admin completion detection

After admin action, PP must support:

- `Sync repos` action.
- Automatic re-preflight.
- Notification/event when the requested repo becomes available.
- Clear state if admin grants only partial permissions.

### 16A.3 Copy standard

The admin handoff should be written for a security-conscious GitHub admin, not a developer already convinced by PP.

---

## 17. Success Metrics


### 17.1 Funnel metrics

Track exact step conversion:

1. `signup_started → signup_completed`
2. `github_install_started → github_install_linked`
3. `github_install_linked → repo_selected`
4. `repo_selected → preflight_passed`
5. `preflight_passed → first_signer_request_created`
6. `first_signer_request_created → receipt_signed`
7. `repo_selected → protection_verified`
8. `protection_verified → first_real_repo_approval`

Metrics must be segmented by lane:

- `demo_receipt`
- `real_repo_protection`
- `assisted_test_pr`
- `manual_test_pr`

### 17.2 Trust failure metrics

Track:

- Unknown GitHub errors.
- Generic error fallbacks.
- Permission repair starts/completions.
- Admin handoff generated/completed.
- Stale primary repo detected.
- Verifier inconclusive results.

### Activation metrics

- 80%+ of users who connect GitHub complete preflight without generic error.
- 60%+ of new users reach receipt activation within 5 minutes.
- 40%+ of users who select real repo lane reach repo protection activation.
- <5% of GitHub setup failures produce unknown/generic errors.

### Trust metrics

- Reduction in support/founder intervention for repo onboarding.
- Fewer abandoned installs after permission screen.
- Higher completion for least-privilege install vs broad write install.

### Engineering metrics

- 100% of known GitHub setup errors mapped to named issue codes.
- All mutation endpoints have preflight gates.
- All onboarding target states observable in analytics/logs.

---

## 18. Acceptance Criteria

### Must-have

- User can select exact workspace, installation, repo, and branch.
- UI never uses stale primary repo as activation target when explicit target exists.
- Preflight shows whether core protection is possible.
- Missing Contents write blocks only assisted test PR, not repo protection.
- `create-test-pr` does not attempt mutation if Contents write is missing.
- Known GitHub errors map to named issue codes.
- User can complete receipt activation through demo lane.
- User can complete real repo protection without granting Contents write.
- Manual setup path exists when auto ruleset configuration is unavailable.

### Should-have

- Shareable admin handoff link/copy.
- Capability snapshot persisted per repo.
- Repair buttons deep-link to GitHub App installation settings.
- Manual PR commands generated with deterministic branch name.


### Verifier acceptance criteria

- `ProtectionVerifier` can prove active protection with structured evidence.
- Product never displays `Repo protection active` unless verifier status is `active`.
- Static/manual/assisted verifier modes are supported.
- A stale primary repo cannot cause verifier to check the wrong repo.
- Green status/check must be tied to exact SHA and receipt.

### Migration acceptance criteria

- Existing workspaces load without losing current repo records.
- Multi-repo workspaces are asked to choose explicit target.
- Stale `primaryRepoFullName` produces a repairable state, not silent misrouting.
- Existing activation attempts are preserved but superseded safely when user selects a new target.

### Admin handoff acceptance criteria

- Non-admin user can generate a handoff request.
- Admin can complete GitHub-side action and return/sync.
- Partial admin completion produces named remaining issues.

### Nice-to-have

- Separate optional elevated GitHub App for mutation-heavy actions.
- GitHub Checks migration from statuses if UX/provenance improves.
- In-app branch protection/ruleset visualizer.

---


## 18A. V1 Cutline

The PRD is intentionally comprehensive. Implementation must be staged to avoid a sprawling first PR.

### V1: must ship first

- Explicit target selection: workspace → installation → repo → branch.
- Repo sync repair for existing installations.
- Named GitHub/setup errors for known failure modes.
- Missing Contents write handled as optional assisted-test blocker, not generic failure.
- Static `ProtectionVerifier` with `configuration_verified` and initial `signal_provenance_verified` where safely possible.
- Manual PR fallback commands.
- Basic admin handoff package.
- Source-of-truth precedence enforced in onboarding.
- PRD compliance checklist in implementation PR.

### V1.5: next

- Runtime verifier using manual or assisted PR: `merge_block_verified` and `approval_release_verified`.
- Admin handoff completion callback/notification.
- Partial setup repair flows.
- Improved observability dashboard.

### Later

- Automatic ruleset creation as a polished flow.
- Full effective mutation probing.
- Separate elevated GitHub App for mutation-heavy actions, if needed.
- GitHub Checks UI migration, if it improves provenance/UX.
- Advanced repo transfer/rename automation beyond mark-and-repair.

---

## 19. Implementation Phases

### Phase 1: Stop trust-killing errors

Scope:

- Add named error mapping for create-test-pr.
- Add preflight before test PR mutation.
- Return `MISSING_CONTENTS_WRITE_FOR_TEST_PR` instead of generic 500.
- Update UI copy to explain optional permission vs core blocker.
- Fix stale `Current repo` language.
- Add repo sync repair action for "repo added to existing installation".
- Add instrumentation for unknown GitHub error fallback.

Outcome:

- Current `dispatch` issue becomes understandable and repairable.

### Phase 1.5: ProtectionVerifier foundation

Scope:

- Introduce `RequiredSignal` abstraction with v1 status support.
- Implement static verifier checks for repo/install/workspace/branch/signal configuration.
- Add structured verifier output and evidence model.
- Ensure UI cannot claim protection active without verifier evidence.

Outcome:

- Real repo protection becomes evidence-backed instead of assumed from config.

### Phase 2: Explicit target selection

Scope:

- Add onboarding target model/state.
- Require explicit workspace/install/repo/branch tuple.
- Add repo sync action for existing installations.
- Stop relying on `primaryRepoFullName` in onboarding.

Outcome:

- Multi-repo/multi-install users get deterministic flow.

### Phase 3: Three-lane activation

Scope:

- Add lane selection UI.
- Build demo receipt lane.
- Build real repo protection checklist.
- Move assisted test PR into optional lane.

Outcome:

- Users can activate without unnecessary repo write permissions.

### Phase 4: Protection verifier

Scope:

- Verify required check/status on branch.
- Verify PP GitHub App provenance.
- Support manual setup confirmation.
- Add observability dashboard.

Outcome:

- Repo protection activation becomes a real, evidence-backed milestone.

### Phase 5: Enterprise hardening

Scope:

- Admin handoff flow.
- Better audit logs.
- Permission re-approval recovery.
- Ruleset/branch protection variants.
- Optional elevated app strategy decision.

Outcome:

- Flow supports real org buyers, not just founder demos.

---

## 20. Open Questions

1. Should demo receipt lane use a PP-owned repo, a generated user repo, or GitHub template flow?
2. Do we want separate GitHub Apps for core governance vs optional repo mutation?
3. Should `primaryRepoFullName` remain a company-level dashboard default long-term, or move to workspace repo settings?
4. What permissions are absolutely required for risk classification across private repos?
5. Should automatic ruleset creation be offered in v1 or deferred behind manual setup?
6. What is the safest way to verify pre-approval unmergeability without requiring PP to create a PR?
7. What should happen when a repo is renamed or transferred between GitHub orgs after protection is active?

Resolved for v1:

- Required signal: commit statuses now, with `RequiredSignal` abstraction for future checks support.
- Admin handoff: must-have for real repo protection.
- Demo receipt and real repo protection are separate milestones.

---

## 21. Risks

### Risk: Demo activation creates false confidence

Mitigation: label receipt activation and repo protection activation separately. Do not mark workspace fully activated until real repo protection is verified.

### Risk: Least-privilege install cannot support rich risk analysis

Mitigation: degrade gracefully. Explain that deeper analysis requires Contents read. Do not require Contents write.

### Risk: Manual setup reduces completion

Mitigation: keep manual setup copy-paste simple, then verify automatically. Offer auto-config only when permission exists.

### Risk: More states increase UI complexity

Mitigation: show simple checklist to user; keep detailed codes in drawer/logs.

### Risk: Existing users have stale installs/permissions

Mitigation: add repo sync and permission repair flows. Avoid forced migration unless necessary.

### Risk: Authority model remains implicit

Mitigation: receipt, signer, policy, quorum, break-glass, and replay semantics are now explicit PRD sections. Implementation cannot claim enterprise readiness without satisfying the v1 portions.

### Risk: GitHub mechanism ambiguity creates false protection

Mitigation: verifier must name whether branch protection or rulesets enforce PP, detect conflicts, and refuse to claim active protection when enforcement is ambiguous.

---

## 22. Product Copy Direction

### Positioning line

`Protect your repo with least-privilege GitHub permissions. Add write access only when you want PP to automate setup for you.`

### Permission banner

`PP can protect this repo without writing code to it. To create a test PR automatically, grant optional Contents write or use manual commands.`

### Success banner

`Repo protection is active. Pull requests to main now require a Permission Protocol decision before merge.`

### Failure banner example

`This repo is not included in the GitHub App installation. Add permission-protocol/dispatch to the PP GitHub App installation, then click Sync repos.`

---

## 23. Recommended Decision

Adopt the three-lane, permission-aware onboarding model.

Do not solve this by simply broadening the GitHub App to Contents write by default. That would make the current demo smoother while weakening the enterprise trust story.

The product should make least-privilege protection the default, demo receipt activation fast, and repo mutation explicitly optional.

---


## 23A. PRD Compliance Ship Gate

Every implementation PR for this PRD must include a checklist in the PR description or review notes:

- [ ] No generic GitHub error is shown for known setup/permission/access cases.
- [ ] No GitHub mutation occurs before preflight and explicit user/admin consent where required.
- [ ] Onboarding uses explicit target selection, not stale `primaryRepoFullName`.
- [ ] Tenant checks validate workspace membership plus installation ID plus repo ID.
- [ ] Missing Contents write does not block core repo protection.
- [ ] Manual fallback exists for test PR creation.
- [ ] `Protection active` is shown only at the appropriate verifier level.
- [ ] Required signal context matches canonical v1 naming.
- [ ] Webhook/idempotency behavior is covered for changed files.
- [ ] Regression coverage includes the `site` vs `dispatch` incident.

Reviewer must compare the implementation diff against this PRD before merge. This is a trust-critical onboarding path; no rubber-stamp shipping.

---

## 24. Immediate Next Action

Create an engineering implementation plan for Phase 1, Phase 1.5, and Phase 2:

1. Named error mapping for known GitHub setup failures.
2. Test PR preflight before mutation.
3. Receipt and signer authority v1 schema alignment.
4. ProtectionVerifier foundation with `RequiredSignal` v1 status support.
5. Explicit selected repo target in onboarding.
6. Repo sync repair action for existing installations.
7. UI copy cleanup to remove stale/current repo confusion.
8. Admin handoff requirements for real repo protection.
9. SHA/replay/break-glass policy decisions for v1.

Phase 1 should be treated as urgent because generic GitHub setup failures directly undermine PP's trust claim. Phase 1.5 should follow immediately because `repo protection active` must become evidence-backed before we optimize more onboarding UI.

---

## 25. Test Plan

### 25.1 Unit tests

- Error-code mapping from GitHub API responses to PP issue codes.
- Capability resolver: declared vs effective capabilities.
- RequiredSignal abstraction for status/check variants.
- Tenant/repo authorization guards.
- Repo rename/transfer mapping logic.

### 25.2 Integration tests

- Receipt binds repo ID, PR number, head SHA, policy hash, signer authority, and signature key ID.
- Revoked signer cannot approve new protected action.
- Self-approval policy is enforced or flagged according to workspace policy.
- Break-glass creates emergency audit record and expires.
- Force-push after approval supersedes old approval and requires new approval.
- Squash/rebase merge links resulting merge commit to approved PR head SHA.
- Bot PR is classified and routed according to policy.
- Repo not included in installation → `APP_NOT_INSTALLED_ON_REPO`.
- Installation linked to different workspace → blocked cross-tenant state.
- Missing Contents write → assisted test PR blocked, core protection not blocked.
- Missing statuses/checks write → real protection blocked.
- Stale primary repo → explicit target required.
- Repo sync after GitHub installation repository added.
- Manual setup verify flow.

### 25.3 E2E tests

- Demo receipt lane completes without customer repo permissions.
- Real repo protection lane with least-privilege permissions completes verifier static path.
- Assisted test PR lane gracefully falls back to manual commands when Contents write is missing.
- Admin handoff generated by non-admin and completed after repo permission update.
- Approval flips PP-authored required signal green on exact SHA.

### 25.4 Webhook/idempotency, chaos, and scale tests

- Duplicate installation_repositories events.
- PR opened before repo sync completes.
- PR synchronize supersedes previous pending request.
- Approval arrives after PR SHA changed and must not green old/new wrong SHA.
- Webhook replay does not create duplicate signer requests.
- GitHub API rate limit during verifier preserves state and exposes retry time.
- PP API outage while required signal pending produces documented fail-closed/break-glass behavior.
- Two users selecting different repos concurrently cannot corrupt active target.
- Load test repo sync/verifier path across many repos without exhausting rate budget.
- Security tests cover tenant spoofing via forged companyId, repoFullName, installationId, and repo rename/transfer.

### 25.5 Regression tests from observed incident

- Workspace has `primaryRepoFullName=permission-protocol/site`; user selects `permission-protocol/dispatch`; activation uses dispatch, not site.
- `permission-protocol/dispatch` installed but missing Contents write; UI says PP can protect repo but cannot create test PR automatically.
- Generic `GitHub API request failed` is not shown for known permission/access failures.

