# Improvements Pending Rod's Approval

_Items Charles wants to implement but needs a decision on._

---

## [1] Direct Telegram Alerts for Critical Deadlines

**Problem:** When a deadline is ≤24h away and blocked on Rod, a #daily-log post isn't a reliable alert. Rod may not check the channel in time.

**Proposed Fix:** Update the daily-log cron to send a direct Telegram DM to Rod (chat ID: 6091356144) when:
- Any item is within 24h of its deadline AND still blocked
- Filter: only CRITICAL priority items (not every stale item)

**Example trigger:** NIST RFI was due March 9. I flagged it 🚨🚨🚨 in the log but never DMed Rod directly.

**Why it needs approval:** Sending Telegram messages to Rod proactively without asking is a push notification change — Rod should opt into this behavior.

**Estimated effort:** Low — add 10 lines to the daily cron's alert section.

---

## [2] Blocked-Items Weekly DM to Rod

**Problem:** Board has been frozen 4 days. Items blocked on Rod for 4+ days aren't getting unblocked because flags in #daily-log aren't creating action.

**Proposed Fix:** Sunday weekly review automatically sends Rod a Telegram DM with:
- Items blocked on him for >3 days (name, days blocked, why it matters)
- Critical path impact (what can't happen until this is unblocked)
- Max 5 items, sorted by urgency

**Why it needs approval:** Same as above — proactive Telegram DMs to Rod.

## [4] Automated Visual QA for Coding Agent PRs

**Problem:** Codex and Claude Code can produce code that passes functional tests but has UI regressions (broken layouts, wrong colors). Currently requires Rod to manually open the branch and check.

**Proposed Fix:** Add a `scripts/visual-qa.sh` that:
1. Spawns a background browser session on the PR branch.
2. Navigates to key pages (Home, Dashboard, Settings).
3. Takes screenshots and uploads them to Cloudinary.
4. Posts the screenshot links in the PR comment or Discord thread.

**Why it needs approval:** Requires running a background server on the agent's machine and uses Cloudinary bandwidth/storage.

---

## [5] Weekly "Technical Debt" Audit by Agent

**Problem:** Fast iteration on the Permission Protocol app (5+ PRs today) is creating small inconsistencies (e.g., duplicated helper logic, stale environment variable references).

**Proposed Fix:** A Sunday morning cron that:
1. Performs a `grep` audit for `TODO`s and `FIXME`s.
2. Checks for duplicated utility functions across `src/app/api`.
3. Compares `.env.example` against the last 7 days of PRs to find missing vars.
4. Generates a "Tech Debt" report in `pp-os/TECH-DEBT.md`.

**Why it needs approval:** Broad codebase scans can be resource-intensive and might generate noise.

---

## [6] Factory Pipeline: Error-Aware Retry

**Problem:** When a Create Factory build fails (e.g., TypeScript error), the `qa.sh` auto-retry prompt to Codex is generic ("It failed, try again"). This leads to repeated identical failures because the agent lacks context on *why* it failed.

**Proposed Fix:** Modify `qa.sh` to capture the `stdout`/`stderr` of the failed command (e.g., `npm run build` or `tsc`) and include the last 20 lines of the error log in the retry prompt.

**Estimated effort:** Low (bash script update).

---

## [7] Factory Pipeline: Sequential Merge Orchestrator

**Problem:** Merging 7+ PRs into one repo (like today's UI audit) causes "Conflict Cascades." Each merge moves `main`, making all other open branches stale and prone to merge conflicts.

**Proposed Fix:** Create a script `scripts/factory-merge.sh` that:
1. Merges PR #1.
2. Waits for CI green.
3. Automatically rebases PR #2 onto `main` and pushes.
4. Repeats for all PRs in the queue.

**Estimated effort:** Medium (git/gh CLI orchestration).

