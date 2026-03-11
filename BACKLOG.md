# BACKLOG.md — Non-Urgent Fixes & Improvements

*Captured in the moment, executed later. Reviewed every heartbeat.*

---

## Infrastructure
- [ ] **Render auto-deploy disabled on pp-web** — Enable auto-deploy for the `company-os-web` (pp-web) Render service so main branch pushes deploy automatically. Currently only pp-workers auto-deploys. (2026-03-06)

## Code
- [ ] **Extract shared `fetchRequestDetails` into `app/api/review/lib.ts`** — Currently copy-pasted across GET, approve, and merge routes. Single source of truth prevents drift bugs. (2026-03-06)
- [ ] **Post-merge Vercel build verification** — After merging to permissionprotocol-site, curl production endpoint to confirm deploy. Consider adding a Discord notification on Vercel build failure (webhook). (2026-03-06)
- [ ] **Remove `_raw_*` debug fields from review API** — `mapToReviewRequest()` in `app/api/review/[id]/route.ts` still returns debug fields. Cosmetic cleanup. (2026-03-06)
- [ ] **Actor shows "Unknown"** — `createdByRef` is `cli` for deploy-gate requests. Need to pass actor info from CI context. (2026-03-06)
- [ ] **Close duplicate issue (#87 or #88)** on permissionprotocol-site. (2026-03-06)

## Security
- [ ] **Create fine-grained CI PAT** — Replace classic `ghp_nvhKjx...` PAT (has full `repo` admin scope) with fine-grained token scoped to `contents:write`, `statuses:write`, `pull_requests:write` only. Agent should enforce the gate, not modify the gate's rules. Update on Vercel + local. (2026-03-06)
- [ ] **Token scoping docs for onboarding** — Document the two-token pattern (CI token vs admin token) for client onboarding. Principle: "The agent that enforces permissions must not have permission to modify the enforcement rules." Dogfooding story. (2026-03-06)

## Future
- [ ] **`api.permissionprotocol.com` CNAME** — Set up DNS so we don't need `PP_API_URL` env var workaround. (2026-03-05)
- [ ] **GitHub PAT with `workflow` scope** — Needed for deploy-gate.yml update that posts PR comments with review links. (2026-03-05)

---

*Format: `- [ ] **Title** — Description. (date added)`*
*When done: change `[ ]` to `[x]` and add completion date.*
