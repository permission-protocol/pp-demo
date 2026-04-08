# Coding & Build Protocols — On-Demand

*Load when doing coding agent work, PR reviews, or deployment tasks.*

---

## Branch & PR Rules
- **ALWAYS create a NEW branch from latest `main` for each PR.** Never push additional commits to an already-merged branch.
- Before creating a branch: `git checkout main && git pull origin main`
- One branch = one PR = one logical change

## Coding Agent Workspace Rules

### Worktree Rules
- **Never use `/tmp` for agent worktrees.** macOS cleans it overnight. Use `~/pp-agent-work/` or `~/.openclaw/workspace/tmp/`.
- **Store prompts in `pp-os/agent-prompts/`**, not `/tmp`.
- **Always push immediately after agent commits.** A committed-but-not-pushed branch is one reboot from gone.

### Pre-merge Build Gate (every agent, every time)
- [ ] `next build` (or equivalent) passes
- [ ] `layout.tsx` / config files match main (agents love "fixing" fonts)
- [ ] Branch is pushed to remote
- [ ] No `<<<<<<` conflict markers in any file

### Sequential > Parallel When Files Overlap
If two features touch the same files → run sequentially. Conflict resolution costs more than parallelism saves.

---

## Batch Codex Protocol

### Parallel Sprint Protocol
Use when 3+ independent features with no file overlap:
1. Partition into discrete PRDs
2. Launch in separate persistent worktrees (`~/Projects/worktrees/pp-{feature}`)
3. Merge sequentially into `main`, rebase remaining branches after each merge
4. Full system build/test after final merge

### Pre-Flight
1. Verify package manager (check `package.json` for `packageManager`, look for lockfiles)
2. Use persistent worktree dirs
3. Check for existing branches before creating

### Monitoring
**DO NOT rely on `process log` for Codex.** PTY buffering makes it show `(no output yet)`. Instead:
- Poll `git status --short` and `git log --oneline` in worktree
- Check `ps aux | grep codex`
- Check remote branches

### Post-Agent
1. Check remote FIRST — Codex may have pushed + created PRs
2. Push immediately if committed but not pushed
3. Run `tsc`/build — Codex often misses imports
4. One type-fix commit is fine — don't re-run the whole agent

### Batch Rules
- Stagger launches if repos overlap
- Create PRs yourself — don't rely on agents
- Set 15-min timeouts

---

## Git Hygiene (HARD RULES)
- **NEVER `git add -A` or `git add .` in a shared worktree.** Always `git add <specific files>`.
- **Run `scripts/git-hygiene-check.sh` before every commit.**
- **Run `git status` before creating a branch.**
- **Review `git diff --stat` before pushing.**

---

## Post-Codex Checklist
1. Read the diff — `git diff main --stat` then skim changes
2. Check against each PRD requirement
3. Check for ReferenceErrors — verify all new variables are defined/imported
4. Check for removed elements
5. Walk the user journey mentally
6. Flag gaps — fix or re-run, don't push and hope
7. GitHub Plan Awareness — fallback for Free plan if using Pro features
8. Visual QA — `scripts/pre-merge-review.sh`, screenshot desktop + mobile

---

## Deployment Rules
- **Merged ≠ Deployed.** Verify Vercel/Render build succeeded before claiming "live."
- Post-merge: wait ~2 min → `curl` prod endpoint → confirm new code running
- Never copy-paste utility functions across route files — extract shared modules
- Test on production, not assumptions

---

## Branch Protection Awareness
- `strict: true` = GitHub updates PR branches when main advances → HEAD SHA changes
- **NEVER cache PR SHAs.** Always fetch current HEAD from API before setting status.
- "Permission Protocol" is a required status check on permission-protocol/app
- Agent should never have admin scope on branch protection

---

## GitHub Actions Patterns
- `if:` conditions skip after failed steps by default. Use `always()` if depending on outputs not success.
- Workflow files on PR branches override main.

---

## UX Race Conditions
- Users click faster than CI runs. Handle "too early" gracefully.
- Show retry button on failure, not dead-end error.

---

## GitHub App Status Integrity
- Use App installation token (JWT → installation token → POST /statuses), not PAT
- Use `pending` (yellow) for gated PRs, not `failure` (red)
- `<!-- skip-enrich -->` prevents webhook overwrite of manually edited bot comments

---

## Factory Pipeline Management
- **Stuck Threshold:** 48h in any non-Done state
- Diagnostic: read PRD, check last 3 status reports, identify blocker
- Escalate: give Rod choice of (A) Unstick Plan or (B) Kill/Archive

---

## PRD Requirements
- Include "User Journey" section (step-by-step actions, not just screen descriptions)
- Include "Customer Test" gate
- Compare existing before redesigning

---

## Architecture Rules
- Two surfaces for one thing = tech debt. Schedule the merge immediately.
- Embedded > external for default path.
