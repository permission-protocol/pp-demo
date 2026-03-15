# PP Development Process

*Lessons learned from building the review surface. Updated 2026-03-13.*

---

## Agent Workflow for permission-protocol/site

### Setup
```bash
# Clone to persistent directory (NOT /tmp)
cd ~/pp-agent-work
git clone git@github.com:permission-protocol/site.git pp-site-feature-name
cd pp-site-feature-name
git checkout -b feature-branch-name
npm install
```

### Prompt Storage
Store agent prompts at: `pp-os/agent-prompts/<feature>.txt`
Reference with: `codex exec --full-auto "$(cat ~/.openclaw/workspace/pp-os/agent-prompts/feature.txt)"`

### Post-Agent Checklist
1. `grep -r "<<<<<<" . --include="*.ts" --include="*.tsx"` — no conflict markers
2. `git checkout origin/main -- app/layout.tsx` — revert agent font hacks
3. `npx next build` — must pass
4. `git push` — immediately, before anything else
5. Create PR via `gh pr create`

### Conflict-Prone Files
These files are touched by almost every feature. **Never run parallel agents that both modify these:**
- `app/review/[id]/ReviewPageClient.tsx` — the main review page
- `app/review/ReviewDashboard.tsx` — the queue/list page
- `app/api/review/lib/shared.ts` — shared utilities
- `app/api/review/lib/enrich.ts` — enrichment pipeline

**Safe to parallelize:** New API routes, new components, new lib files.

---

## Pattern Stealing (PP App → Marketing Site)

### Audit Cadence
Monthly: diff feature sets between `permission-protocol/app` and `permission-protocol/site`.

### Key Source Files in PP App
| Area | PP App Path | What to Look For |
|------|-------------|-----------------|
| Post-approval | `src/lib/services/deploy-gate-post-approval.ts` | Merge, rerun orchestration |
| Rerun | `src/lib/services/github-rerun.ts` | Hybrid rerun strategy |
| Reconciliation | `src/lib/services/reconcile-stale-requests.ts` | Stale request cleanup |
| Review helpers | `src/app/pp/deploy-requests/[requestId]/review-page-helpers.tsx` | Timeline, types, UI helpers |
| Deploy gate | `src/lib/deploy-gate/review.ts` | Lane deduplication, state |

### Already Ported (as of 2026-03-13)
- [x] Auto-rerun after approval (PR #180)
- [x] Superseded request handling (PR #190)
- [x] Manual rerun button (PR #190)
- [x] Request timeline (PR #191)
- [x] Stale reconciliation (PR #191)
- [x] Rerun shared lib extraction (PR #190)

### Not Yet Ported
- [ ] Update branch / behind detection
- [ ] Request expiry + reapproval
- [ ] Recovery request flow
- [ ] Rate limiting on approval actions
- [ ] Branch status enrichment (behind/ahead/conflict)

---

## PRD → Implementation Flow

1. **Design conversation** — think from the user's perspective (VP Eng persona)
2. **Write PRD** to `pp-os/prds/` — include phases, success metrics, what we're NOT building
3. **Create GitHub issues** — one per phase, add to PP Product board
4. **Write agent prompt** to `pp-os/agent-prompts/` — reference PRD, list exact files and changes
5. **Spawn agent** — Codex first (free), Claude Code for complex reasoning
6. **Build verify** → **push** → **create PR** → **screenshot before merge**
7. **Update STATUS.md** with what shipped

---

## Shared Utilities

| Utility | Location | Purpose |
|---------|----------|---------|
| `triggerGitHubRerun` | `app/api/review/lib/rerun.ts` | Hybrid rerun (check_run → actions_run) |
| `fetchGithubPrStatus` | `app/api/review/lib/shared.ts` | Cached GitHub PR state check |
| `parseRepoParts` | `app/api/review/lib/shared.ts` | Split "org/repo" safely |
| `fetchRequestDetails` | `app/api/review/lib/shared.ts` | Fetch from PP API across all statuses |
| `enrichReviewRequest` | `app/api/review/lib/enrich.ts` | AI summary, risk signals, blast radius |
| `formatTimestamp` / `timeAgo` | `lib/time.ts` | Shared time formatting |
