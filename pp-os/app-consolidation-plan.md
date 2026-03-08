# PP App Consolidation Plan

## The Problem

`app.permissionprotocol.com` is a full Company OS platform with 20+ pages. Permission Protocol is just one tab in the left sidebar. Meanwhile, we built a purpose-built review surface on `permissionprotocol.com` with features (AI summaries, diff display, risk signals, Vercel previews) that don't exist in the app.

**Two parallel codebases, neither complete:**

| Feature | Marketing Site (permissionprotocol-site) | App (Breakout-Labs) |
|---------|------------------------------------------|---------------------|
| Deploy request list | ✅ with filters | ✅ with search |
| Deploy request detail | ✅ rich (AI summary, diff, risk) | ✅ basic (fields only) |
| Approve/reject | ✅ with reason field | ✅ |
| Merge & deploy | ✅ two-step UX | ✅ via post-approval action |
| AI assessment | ✅ Gemini Flash | ❌ |
| Diff display | ✅ colored additions/deletions | ❌ |
| Risk signals | ✅ deterministic regex | ❌ |
| Vercel preview embed | ✅ | ❌ |
| Real-time polling | ✅ 15s | ❌ |
| PR notifications (comments) | ✅ | ❌ |
| Auth | ✅ GitHub OAuth (new) | ✅ GitHub OAuth (existing) |
| Multi-tenant | ✅ (tenant map) | ✅ (DB-native) |
| Kill switches | ❌ | ✅ |
| Policy management | ❌ | ✅ |
| API keys management | ❌ | ✅ |
| Activity log | ❌ | ✅ |
| Audit trail | ❌ | ✅ |

## The Plan

### Phase 1: Strip the sidebar (Week 1)
**Goal:** When a user logs in, they see Permission Protocol — not Company OS.

1. **New default route:** `/` redirects to `/pp` (or make `/pp` the home page)
2. **Hide non-PP sidebar items:** Remove or collapse behind a toggle:
   - ~~Dashboard~~ (replace with PP dashboard)
   - ~~Company Setup~~
   - ~~CEO Planning~~
   - ~~Dev AI~~
   - ~~Tasks~~
   - ~~Approvals~~ (merge into PP)
   - ~~AI Operating Rules~~
   - ~~Artifacts~~
   - ~~Reports~~
   - ~~Activity~~ (keep, rename to "Activity Log")
   - ~~Companies~~ (keep for multi-tenant)
   - ~~Company Memory~~ (hide)
   - ~~Knowledge Base~~ (hide)
   - ~~GitHub~~ (hide, internal)
   - ~~Repo Indexing~~ (hide)
   - ~~PR Outbox~~ (hide)
   - ~~Job Runs~~ (hide)
3. **New PP-focused sidebar:**
   ```
   DEPLOY GATE
   ├── Review Queue (deploy-requests list)
   ├── Deploy Providers
   ├── API Keys
   └── Setup / Install
   
   ADMIN
   ├── Activity Log
   ├── Audit Trail
   ├── Settings
   └── Companies (if multi-tenant)
   ```
4. **Rename tabs inside /pp:**
   - "Dashboard" tab → "Overview" or remove (it shows kill switches — keep but make it the main view)
   - "Deploy Queue" tab → "Review Queue" (matches our language)

### Phase 2: Port the rich review UX (Week 1-2)
**Goal:** The best features from our marketing site review surface land in the app.

1. **AI Assessment panel** — Port `enrich.ts` logic (Gemini Flash summary) to Breakout-Labs
   - Add Gemini API key to Render env vars
   - Server-side enrichment on deploy request detail page
   - Show AI summary above the detail fields (same layout we designed)

2. **Diff display** — Port diff fetching + colored display
   - GitHub API call for PR diff (already have the code)
   - Render with additions (green) / deletions (red)

3. **Risk signals** — Port deterministic regex-based signals
   - File path analysis (infra changes, env files, etc.)
   - Display as badges/pills

4. **Approval reason field** — Add reason textarea to approve/reject flow
   - Quick-pick presets + free text
   - Store in DB, show in audit trail

5. **Real-time polling** — Add 15s refresh while request is pending
   - Already a pattern in the existing codebase

6. **PR notifications** — Post approval/rejection as GitHub PR comment
   - Receipt ID, reason, PP link
   - Already built in our API routes

7. **Vercel preview embed** — iframe showing preview deployment
   - Query Vercel API for preview URL by PR number
   - Show in detail page

### Phase 3: Polish + onboarding (Week 2-3)
**Goal:** New user experience is clean and guided.

1. **Onboarding flow overhaul:**
   - Step 1: Sign in with GitHub ✅ (exists)
   - Step 2: Create org / connect repos
   - Step 3: Install deploy-gate (copy YAML or one-click GitHub App)
   - Step 4: First deploy request appears

2. **PP-branded login page** — Use the design we built (clean dark, PP branding)
   - Replace existing sign-in page aesthetics

3. **Empty states** — When no deploy requests exist, show setup guide
   - "No deploy requests yet. Here's how to get started."
   - Link to quickstart docs

4. **Remove dead Company OS features** — Pages that aren't relevant:
   - CEO Planning, Dev AI, Artifacts, Reports (the entire "autonomous company OS" layer)
   - These can live in a separate app later if needed
   - For now: delete the routes or gate behind a feature flag

### Phase 4: GitHub App (Week 3+)
*As scoped in review-surface-mvp.md — unchanged.*

---

## Architecture Decision

**Option A: Modify Breakout-Labs in place** ← RECOMMENDED
- Pros: All the backend infra exists (DB, auth, API, Prisma, workers, Redis)
- Cons: Lots of dead code to manage
- Approach: Hide/delete Company OS routes, build on what's there

**Option B: Extract PP into its own Next.js app**
- Pros: Clean slate, no legacy baggage
- Cons: Rebuild auth, DB connections, API routes, deploy infra
- Not worth it — Breakout-Labs IS the backend

**Decision: Option A.** Strip, don't rebuild.

---

## Execution Order

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 1 | Strip sidebar to PP-only nav | Small | High — first impression |
| 2 | Make `/` redirect to `/pp` | Tiny | High — landing experience |
| 3 | Port AI assessment to detail page | Medium | High — key differentiator |
| 4 | Port diff display | Medium | High — reviewer needs this |
| 5 | Port risk signals | Small | Medium |
| 6 | Add approval reason field | Small | Medium |
| 7 | Add real-time polling | Small | Medium |
| 8 | Port PR notifications | Small | Medium |
| 9 | Vercel preview embed | Small | Low (only our repos) |
| 10 | Branded login page refresh | Small | Medium — first thing users see |
| 11 | Onboarding empty states | Medium | High — new user experience |
| 12 | Delete dead Company OS routes | Medium | Low (cleanup) |

**Tasks 1-2 can ship today.** They're sidebar config + one redirect.
**Tasks 3-8 are the meat** — porting our proven review UX into the real product.
**Tasks 9-12 are polish** — important but not blocking.

---

## What We Keep from Company OS

- **Auth system** (NextAuth + GitHub OAuth) — already working
- **Database** (Prisma + Postgres) — all deploy request data
- **API routes** (`/api/v1/*`) — the CLI, SDK, and GitHub Action depend on these
- **Workers** (Redis + BullMQ) — background processing
- **Audit trail** — valuable for compliance story
- **Activity log** — useful for visibility
- **Settings** — needed for configuration
- **Companies/multi-tenant** — foundation for team accounts

## What We Hide/Delete

- CEO Planning, Dev AI, Tasks, Artifacts, Reports, PR Outbox
- Knowledge Base, Repo Indexing, Job Runs
- Company Memory, AI Operating Rules
- Constitution page
- All "autonomous company" features
