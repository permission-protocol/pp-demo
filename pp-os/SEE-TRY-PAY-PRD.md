# PRD: See Try Pay — Activation Loop

**Goal:** Install → Blocked PR → Approval in <2 minutes with zero thinking.

**Definition of Done:** Someone clicks a link and in 2 minutes sees something get blocked and has to approve it.

---

## Phase 1: SEE — Force the First Blocked Action

### Feature: Auto-Create Blocked PR on Install

**Trigger:** GitHub App installation callback completes (user lands on `/pp?connected=true`)

**Behavior:**
1. Detect that user just completed installation (no pending/resolved requests exist)
2. Auto-create a test PR in the user's first connected repo
3. The PR triggers the deploy-gate workflow
4. User immediately sees:
   - ❌ "Awaiting approval" status
   - "HIGH RISK: deploy to prod" in the comment
   - Approval link in the dashboard

**Implementation:**
- Add API endpoint `POST /api/v1/github-app/create-test-pr`
- Call from QuickstartWizard after install detected
- Create a branch with a single innocuous change (e.g., add `.pp-test` file)
- Open PR with scary title: "🚨 [Test] Production deployment - Permission Protocol verification"
- The existing webhook handler will create the deploy request automatically

**Files to modify:**
- `src/app/api/v1/github-app/create-test-pr/route.ts` (new)
- `src/app/pp/page.tsx` (call after install)

---

## Phase 2: TRY — Quick Start Wizard

### Feature: One-Button "Test Enforcement"

**Location:** Dashboard at `/pp` (QuickstartWizard component)

**Behavior:**
1. After GitHub App is connected, show single CTA: **"Test Enforcement →"**
2. One click:
   - Creates a test PR in the connected repo
   - Shows loading state "Creating test PR..."
   - Redirects to the approval page when deploy request is created

**UX Flow:**
```
[Button: Test Enforcement →]
       ↓ click
[Creating test PR...] (spinner)
       ↓ 3-5 seconds
[Redirect to /pp/deploy-requests/{id}]
```

**Files to modify:**
- `src/app/pp/page.tsx` — add "Test Enforcement" button to QuickstartWizard
- Reuse `create-test-pr` endpoint

---

## Phase 3: Fix the Approval Moment

### Feature: Make Approval Feel Like Signing

**Location:** Deploy request review page `/pp/deploy-requests/[requestId]`

**Current UX (weak):**
- Generic "Approve" button
- No identity emphasis
- Feels like clicking OK on a dialog

**Target UX (visceral):**
- Clear consequence: "This will deploy to production"
- Identity emphasis: "You are the signer of record"
- Action recorded: "This action will be cryptographically recorded"
- Weighty CTA: **"Approve & Sign"** (not just "Approve")

**Copy changes:**
- Button: "Approve" → **"Approve & Sign"**
- Above button: "You are signing as [user name/email]"
- Below button: "This approval is permanent and auditable"
- For production env: Show red warning "⚠️ PRODUCTION — This cannot be undone"

**Files to modify:**
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — approval button section

---

## Phase 4: Instrumentation (Non-Negotiable)

### Events to Track (PostHog)

| Event | When |
|-------|------|
| `pp_github_app_installed` | GitHub App callback completes |
| `pp_test_pr_created` | Test PR auto-created |
| `pp_deploy_request_viewed` | User views a deploy request page |
| `pp_approval_clicked` | User clicks Approve & Sign |
| `pp_first_approval` | User's first approval ever (companyId-scoped) |

### Metrics Dashboard

Track conversion funnel:
1. GitHub App installed → Test PR created
2. Test PR created → Approval page viewed
3. Approval page viewed → Approved
4. Time from install to first approval (target: <2 min)

**Files to modify:**
- `src/app/pp/page.tsx` — track install and test PR creation
- `src/app/pp/deploy-requests/[requestId]/page.tsx` — track view and approval
- `src/lib/analytics.ts` or PostHog integration

---

## Parallel Work (Low Effort, High Leverage)

### README Rewrite

**Goal:** Top of README = 60s demo path. No theory.

**New structure:**
```markdown
## Try It Now (60 seconds)

1. Fork [pp-demo](https://github.com/permission-protocol/pp-demo)
2. Install the [GitHub App](https://github.com/apps/permission-protocol)
3. Open any PR → see it get blocked
4. Click the approval link → sign it
5. PR unblocks → done

That's Permission Protocol.
```

**Files to modify:**
- `README.md`

### Demo PR Refresh

**Goal:** Keep `pp-demo#35` (or current) always live and scary.

**Scary examples to rotate:**
- "Deploy to production"
- "Delete user database"
- "Modify payment configuration"
- "Update security credentials"

**Files to modify:**
- `permission-protocol/pp-demo` repo — rotate the blocked PR content periodically

---

## NOT in Scope

- Stripe integration
- Pricing page
- Billing flows
- Invoice/email flows

---

## Implementation Order

1. **Create test PR endpoint** — API to auto-create a blocked PR
2. **Wire up QuickstartWizard** — Call endpoint after install, show "Test Enforcement" button
3. **Fix approval UX** — Make it feel like signing
4. **Add instrumentation** — Track the funnel
5. **README rewrite** — 60s demo path at top
