# Action Gate Pivot — Strategy Decision

**Date:** 2026-04-28
**Status:** APPROVED — Listen-First execution
**Drought:** Day 66 | Sprint 5: 0/10 installs | T-3 to May 1 deadline

---

## The Decision

Adopt **Action Gate / Merge Gate split** as the new company thesis:

- **Action Gate** (PRIMARY) — verifiable receipt layer for high-risk customer-facing AI-agent actions. $7,500 30-day pilot. Sold to customer-facing AI agent companies in active enterprise sales.
- **Merge Gate** (SECONDARY) — GitHub adapter and proof loop. Stays alive but does not define the company.

Receipt primitive: **No receipt, no execution.** The receipt is the product, not the approval UI.

## Why we pivoted

1. Merge Gate-only positioning collapses into "GitHub branch protection." We've heard variants of this for weeks.
2. The real pain isn't AI-authored PRs. It's customer-facing agents taking write actions while enterprise security review balloons to 3+ weeks.
3. The Chad Bayer signal (Apr 9: Safety > Crypto) maps cleanly to Action Gate, not Merge Gate.
4. AIUC-1 mapping (B006 / A003.3 / A003.4 / B008 / D003 / E015) gives us a credibility hook we did not have before. "MFA provider to SOC 2" analogy is clean.

## Execution: Listen-First sprint, NOT the docs' build+sell plan

**Build moratorium through May 4.** No new product code on Action Gate this week. The only product work this week is the honest-claim audit (soften "cryptographic/signed/immutable" → "tamper-evident audit record" until Ed25519 actually ships).

### Apr 29 – May 3: Listen sprint
- 50-company tight list (CX/support agent companies, 20-200 people, active enterprise sales, named founder with public LinkedIn)
- 30 LinkedIn DMs over 3 days (10/day), research-framed not pitch
- AIUC-1 LinkedIn post published (Charles drafts, Rod approves)
- Direct outreach to AIUC-1 organizers + Schellman
- Goal: 5 calls booked, 3 calls completed by May 3 evening
- Day 14 pivot rule applies — drop primaries who ghost, hit secondaries

### May 4: Decision point
- 3+ calls scoring 2 or 3 → green-light Action Gate build sprint, 7 days
- 0–1 calls scoring 2 or 3 → Action Gate is wrong company thesis. Stay Merge Gate-primary. Ship 10–15 paying repos by June 1 as PMF story.
- 2 calls in band → run parallel 10-day plan, force decision May 14

### Build sprint (only if validated)
- Ed25519 signing + public verifier
- Receipt Format v0.1 spec (open-sourced)
- Refund/email demo
- Updated /platforms page with AIUC-1 mapping

## Adjusted from the source docs

| Source plan | Adjustment | Reason |
|---|---|---|
| 80 cold contacts in 4 hours | 30 in 3 days from 50-company tight list | Quality > volume. Section 16 of source doc admits the 200-list iteration was bad. |
| Decide Apr 30 evening | Decide when 5 calls are in the bank | Don't decide on incomplete data — that's the bug we keep hitting. |
| Demote Merge Gate immediately | Demote only after Action Gate has paying/LOI customer | Don't kill what's working before what's new is real. |
| Build Action Gate this week | Build only after validation (May 4+) | Build always wins, sell always loses. 66-day drought is the evidence. |
| 100% bandwidth assumed | 60% bandwidth reality | Third sprint making this mistake. |
| AIUC-1 partnership = Open Question #3 | Direct outreach to Schellman + organizers Week 1 | Highest-leverage relationship in the deck. |

## Risk: what if signing slips past May 5?

Honest-claim audit is non-negotiable. By Wednesday Apr 29:
- Every "cryptographic / signed / immutable" claim on permissionprotocol.com → "tamper-evident audit record"
- Restore stronger language only when Ed25519 + public verifier actually ship

This is a copy edit, not a build. It cannot slip.

## June 1 PMF bar (60% bandwidth-realistic)

Minimum credible:
- 1 LOI or paid pilot (Action Gate OR Merge Gate)
- 5 prospects naming the same pain in their own words
- 5 paying or evaluation Merge Gate repos
- Signed receipts live in 1 environment
- One case-study-quality quote

NOT the "strong PMF" version from the docs. We can't hit it at current bandwidth.

## Open questions answered by execution (not analysis)

1. Does a real customer-facing AI agent founder name pre-execution authorization as an active procurement blocker on a real call? — Apr 29 to May 3
2. Does AIUC-1 framing land harder than approval-workflow framing? — same calls
3. Will any AIUC-1 consortium member partner? — direct outreach Week 1
4. Can Action Gate sales cycle compress to 30 days from cold-sourced pipeline? — May 14 milestone
5. If validation fails, does Merge Gate generate 10–15 paying repos by June 1? — HN/PH/Marketplace launch Week 1 if Plan B activates

## Source

Consolidates two strategy summaries Rod ran while away (Apr 28). Full source archived at `pp-os/strategy/source/2026-04-28-source-summaries/`.

---

*Charles Goldberg, 2026-04-28.*
