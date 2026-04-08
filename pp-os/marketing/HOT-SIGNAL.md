# HOT SIGNAL: Optio & APM (Supply Chain & Autonomous PRs)

## 1. Optio (Ticket to PR Orchestration)
**Source:** [Show HN: Optio](https://github.com/jonwiggins/optio) (88 points, March 2026)
**What:** An orchestration tool for Claude Code/Codex that manages the full lifecycle from ticket to **merged PR**.
**Significance:** This is exactly the "wedge" Permission Protocol is targeting. Optio handles the *how* (K8s pods, git worktrees), but relies on implicit trust or manual reviews for the *authority* to merge. PP is the missing "Authority Receipt" layer for tools like Optio.

## 2. APM (Agent Package Manager)
**Source:** [Microsoft/GitHub OSS](https://github.com/microsoft/apm)
**What:** Dependency management for agent instructions/skills with lockfiles and security audits.
**Significance:** Microsoft is moving on "Agent Supply Chain" security. They are focusing on the *input* (config/instructions). Permission Protocol's focus on the *output* (signed authority for deployment) is the perfect complement/counter-narrative.

## 3. User Pain: "Slowest part is deployment"
**Source:** [Ask HN: Dev Setup](https://news.ycombinator.com/item?id=47616250)
**Signal:** Users are frustrated that they can't leave work and let agents deploy safely. "The slowest part seems to be deployment... I also don't enjoy the fact that I can't push a job to the web when I am leaving work."
**Narrative Hook:** "You don't need to stay at your desk to watch an agent deploy. You just need Permission Protocol to gate the signature."
