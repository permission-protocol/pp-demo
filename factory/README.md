# Create Factory

Semi-automated product improvement pipeline. Decoupled scripts, shared state, manual triggers.

## Philosophy
- **Ideas come from context, not cold generation.** Charles generates ideas because he knows the codebase, the users, and the focus.
- **Ranking is informed, not automated.** Charles ranks based on FOCUS.md, STATUS.md, and what's actually buildable.
- **Code ships through PRs.** Every change is a diff, a branch, a review. No mystery assets.
- **Start manual, automate later.** Every script runs by hand until we trust it.

## Pipeline

| Step | Script | Who | Automated? | Input | Output |
|------|--------|-----|-----------|-------|--------|
| 1. Ideate | `ideate.sh` | Charles | Manual trigger | Target config + product knowledge | 3 ideas → ideas.jsonl |
| 2. Organize | `organize.sh` | Charles | Manual trigger | ideas.jsonl | Ranked backlog (max 100, overflow archived) |
| 3. Spec | `spec.sh` | Charles | Manual trigger | Top idea | PRD → factory/prds/ |
| 4. Build | `build.sh` | Codex | **Fully automated** | PRD + repo | Clone → Codex → push → PR |
| 5. QA | `qa.sh` | Charles + Peekaboo | **Semi-automated** | PR branch + PRD | Checks → screenshots → pass/retry/fail |

## QA Retry Loop
Failed builds get sent back through the pipeline:
1. Charles writes failure notes → appended to PRD
2. Status reset to `prd-ready` with P0 priority
3. `build.sh` picks it up first (P0 skips the line)
4. Codex retries with failure context
5. Max 3 retries, then flagged for human intervention

## Status Lifecycle

```
idea-generated → backlog-ready → prd-wip → prd-ready → build-wip → build-ready → qa-wip → qa-passed → shipped
                                    ↑                                                  |
                                    └──────────── qa-failed (escalate P0) ─────────────┘
```

## File Structure

```
factory/
  ideas.jsonl            # Active backlog (max 100)
  ideas-archive.jsonl    # Overflow, searchable
  targets/               # Config per product
    pp.json
  prds/                  # Generated specs
    idea-001.md
  scripts/               # The pipeline
    ideate.sh
    organize.sh
    spec.sh
    build.sh
    qa.sh
```

## Usage

```bash
# Generate 3 new ideas for PP
bash factory/scripts/ideate.sh pp

# Rank and clean the backlog
bash factory/scripts/organize.sh

# Write a PRD for the top idea
bash factory/scripts/spec.sh

# Build it with Codex
bash factory/scripts/build.sh

# Run QA
bash factory/scripts/qa.sh
```

## Adding a Target

Create `factory/targets/<name>.json`:
```json
{
  "name": "My Product",
  "repo": "org/repo",
  "personas": ["Alice (Role)", "Bob (Role)"],
  "context_files": ["path/to/FOCUS.md", "path/to/STATUS.md"],
  "branch_prefix": "factory/",
  "ideate_prompt": "What are the top 3 product improvements..."
}
```
