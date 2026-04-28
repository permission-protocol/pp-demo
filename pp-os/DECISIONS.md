# PP OS Decision Ledger

Tracking high-stakes decisions and Rod-dependent blockers.

| Date Created | Issue ID | Decision Required | Status | Days Stale | Impact |
|--------------|----------|-------------------|--------|------------|--------|
| 2026-04-07   | idea-092 | Sycamore / Sri Viswanath Outreach | PENDING | 12 | P0 Growth |
| 2026-04-09   | idea-098 | Trent AI / Eno Thereska Outreach | PENDING | 10 | P0 Growth |
| 2026-04-07   | idea-085 | GA4 / Search Console Re-auth | PENDING | 12 | P1 Metrics |
| 2026-03-25   | idea-082 | X API Tier Upgrade | PENDING | 25 | P1 Distro |
| 2026-04-07   | idea-086 | SSH pp-scout-sfo2 Access | PENDING | 12 | P2 Infra |

## Active Decision Cards

### Decision Card: Action Gate / Merge Gate Split (APPROVED 2026-04-28)
**Context:** Rod ran strategy sessions while away. New thesis: Action Gate (verifiable receipt layer for high-risk customer-facing AI-agent actions) primary, Merge Gate secondary. AIUC-1 mapping (B006/A003.3/A003.4/B008/D003/E015) as credibility hook.
**The Stake:** Source docs propose 30-day build+sell plan that repeats the Sprint 2/4/5 pattern (build wins, sell loses). 66-day drought is the evidence. Listen-First execution inverts this: no new build until 3+ validation calls confirm pain.
**Decision:** APPROVED with execution adjustments. See `pp-os/strategy/2026-04-28-action-gate-pivot.md`.
**Adjustments from source:** 30 quality DMs over 3 days (not 80 in 4 hrs); decide when 5 calls in bank (not Apr 30 evening); Merge Gate stays alive until Action Gate has paying/LOI; build moratorium until May 4.
**May 4 fork:** 3+ calls scoring 2-3 = build Action Gate. 0-1 = stay Merge Gate-primary. 2 = parallel 10-day plan.



### Decision Card: Sycamore Outreach (idea-092)
**Context:** P0 lead. Former CTO of Oracle. High signal match for Consequence Engine.
**The Stake:** Missing the April outreach window for this tier-1 partner. Cost of delay is a lost design partner slot.
**Decision Command:** `/approve idea-092`

### Decision Card: Trent AI Outreach (idea-098)
**Context:** P0 lead. Technical founder. Perfect fit for "Safety over Crypto" wedge.
**The Stake:** Lead goes cold. We lose the chance to be the authority layer for their agent fleet.
**Decision Command:** `/approve idea-098`

---
*Maintained by Charles Goldberg.*
- **2026-04-28 (SYS-022):** Rod authorized `pivot-batch-099` (idea-099: LinkedIn Day 14 Pivot — #2 contacts). Moving to ACTIVE execution.
