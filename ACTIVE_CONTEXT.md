# Active Context — 2026-05-21 10:30 MDT

## 🟢 ACTIVE DEAL 1: Pamela Clegg / Inca Digital
**Status:** Collateral sent (May 21, 10:50 MDT). Awaiting client intro + CTO call.

**What happened:** 1-hour call. She volunteered: (1) Inca → PP partnership (wallet risk scores into our policy gate), (2) warm intro to her agentic-payments client, (3) CTO briefing scheduled.

**Sent today:** Two branded PDFs from `ops/outreach/pamela-clegg/`
- `inca-cto-integration-sketch.pdf` — for her engineering team
- `agentic-payments-client-onepager.pdf` — for her client

**Open asks (in email):** Forward client one-pager today; share client's name.

**Next checkpoint:** Early June post-vacation. Win = client intro.

---

## 🟢 ACTIVE DEAL 3: Santi Weight / Bridgewater
**Status:** Tech brief + email sent May 21 PM (~14:40 MDT). Awaiting his website review next week back in office.

**What happened:** Originally peer-intel call, became real Bridgewater evaluation opening. Santi confirmed authorization pain at Bridgewater, shared work email after call, will evaluate PP next week.

**Three unblockers he named:**
1. GitLab integration (not GitHub) — committed 1-2 weeks
2. Entra ID SSO — Q3 roadmap, can fast-track for pilot
3. VPS / single-tenant — already supported

**Sent today:** Tech brief from `ops/outreach/santi-bridgewater/pp-for-bridgewater-technical-brief.pdf`
- Subject: "PP follow-up: GitLab, Entra, sandboxing"
- 3 numbered follow-ups with sandboxing framing baked in

**Critical positioning locked:** Sandbox → PP policy auto-approve → PP human escalation → audit defensibility. NOT "99% sandbox, 1% human." Use this framing in all future engineer-at-agent-shop conversations.

**Risks:** Bridgewater builds everything (build-vs-buy bias). Santi spoke in personal capacity. May push sandboxing harder when not on Zoom.

**Next checkpoint:** Next week. Win = one Bridgewater workflow committed as evaluation target + single-tenant sandbox stood up.

---

## 🟢 ACTIVE DEAL 2: Francis Ofungwu / Efeeo
**Status:** Reference architecture received (May 21 PM, same day as call) — PP is now in Efeeo's published architecture with logo and 4 capabilities. Reply sent suggesting peer-not-stacked reframe + push for named client. Awaiting his POV + named client commit next week.

**Diagram lift-line:** "AGT + PP signed runtime records · Ed25519 / ML-DSA-65 + named-human receipts"

**What happened:** 30-min call (second touch). Demo PR #51 in pp-demo landed clean. Francis committed to (1) testing PP in his repo, (2) showing fintech clients, (3) delivering POV next week.

**Sent today:** Partnership sketch from `ops/outreach/francis-ofungwu/`
- `efeeo-pp-partnership-sketch.pdf` — maps PP into his DCP framework as Constrain layer, preempts AGT question
- `agt-vs-pp-brief.md` — internal, not sent

**Key positioning locked:** "AGT decides what an agent can do. PP records who said it could."

**DCP mapping:** Efeeo owns Design + Prove. PP runs Constrain.

**Risks:** Don't get pulled into custom workflows. Don't let him DIY signoff on top of AGT.

**Next checkpoint:** Next week, his POV. Win = signed partnership structure + named shared client.

---

## Current PP UI Work
- **PR #557 open:** Deploy request signer detail page redesign (`feat/deploy-request-signer-detail-page`).
- **PR #555 open:** Spec for deploy request signer detail page (`spec/deploy-request-detail-signer-page`).

## Verification for PR #557 (still valid)
- `npx vitest run tests/deploy-request-detail-signer-page-source.test.ts` ✅
- `npx tsc --noEmit` ✅
- `git diff --check` ✅
- `npm run build` ✅

## Durable Goal Status: pp-external-activation
- ✅ 7-PR single-path activation flow shipped (PRs #527–533)
- ✅ Rehearsal loop confirmed end-to-end
- ✅ Branch protection updated
- ✅ Repo cleanup done
- 🔴 **ONE TASK REMAINING**: Rod approves outreach to Tier A external candidate

## One Pending Decision (Rod)
Approve sending activation invite to one Tier A candidate:
- **Vivek Trivedy (LangChain, Agents team)** — already replied, enterprise framing confirmed
- **Faruk (mfyz)** — developer, willing tester
- **Max Krivich** — guardrails.md author
- Onboarding URL: <https://app.permissionprotocol.com/onboarding>

## Highest-Priority Follow-ups (Outreach)
1. **Pamela Clegg / Inca Digital** — early June post-vacation, push client intro
2. **Santi Weight / Bridgewater** — next week, his website + sandbox review. Spin up single-tenant + GitLab integration spec.
3. **Francis Ofungwu / Efeeo** — next week, his POV. Lock partnership structure + push for one named shared client. Email + partnership sketch sent May 21 PM.
4. **Art Dunal (Kranz/ex-Dover CFO)** — cancelled last-minute May 21, reschedule pending. Send light LinkedIn reschedule note with 2-3 windows next week. CFO+manufacturing+Rice agentic AI class angle.
5. **LinkedIn batch sent 5/21** (10 DMs) — review reply rate Mon 5/26. Tracker: `ops/outreach/2026-05-21-linkedin-batch.md`
   - Highest odds: Orinthea S. Smith, Al King, Cory Wagner (Collibra), Jenn Hartfield (Southwest)
   - Altimetrik watch: Adam Caplan + Amit K. Singh (compete at consulting layer)
5. Vivek Trivedy — send one-pager + book 15 min (day 7 is May 26)
6. Patrick McQuillan (Visa) — governance buyer
7. Caryn Lusinchi — EU AI Act auditor
8. Day 14 backup contacts: June 2

## System Stability
- **Cron Health:** Stable
- **Production:** Healthy at last check
- **pp-demo:** Clean — only PR #50 (green, ready to merge) and #35 (demo example)
- **pp-app:** Open PRs include #555 spec and #557 implementation

## Carry-Forward (Needs Rod)
- Approve first external activation outreach
- GA4/Search Console tokens
- X API Tier upgrade
- (New) Pamela's client name when she shares it

## 🔥 THIS WEEK: OWASP Agentic Top 10 Land-Grab
OWASP just legitimized PP's category. Move before others claim the human-signer lane.
1. ✅ `/compliance/owasp` page **LIVE** (shipped + verified May 21 PM)
2. ✅ Two blog posts **LIVE** (`/blog/permission-protocol-owasp-agentic-top-10`, `/blog/agt-vs-permission-protocol`)
3. Homepage badge "Built for OWASP Agentic Top 10 (Dec 2025)" linking `/compliance/owasp` — still to do
4. Send Sotiropoulos LinkedIn DM (draft at `ops/outreach/owasp-sotiropoulos-dm.md`). Then Keren Katz (Tenable). — send Monday
5. Add ASI codes to all future outreach docs.

Canonical line: "AGT covers the deterministic policy half of OWASP Agentic Top 10. PP covers the human-approval and named-signer half. Together you get 10/10. Alone, neither does."

## 🎯 GTM / Outreach (Active Segment)
- **Draft List for Tomorrow (May 26) created:** Organized and enriched 12 high-priority targets across Mid-market Regulated SaaS, Banks/Hedge Funds, and AI-Native Platforms.
- **Enriched Target File:** `/Users/moltbot/.openclaw/workspace/ops/outreach/2026-05-26-outreach-targets.md`
- **Top Targets:** Karim Atiyeh (Ramp), Maximilian Tagher & Steve Pearlman (Mercury), Jadee Hanson (Vanta), Jeffrey Wecker (Two Sigma), Sam Aarons (Modern Treasury).

## ⚠️ Security hygiene (separate, not urgent but worth this week)
- Two PATs are baked into git remote URLs (visible in `git config`):
  - `/Users/moltbot/repos/permissionprotocol-site` origin
  - `~/.openclaw/workspace` (Roca-Ventures backup) origin
- Rotate both + switch to credential-helper or SSH. Workspace-backup PAT is already stale, so it's the better candidate to rotate first.

## ✅ Auto-bot hardened (May 21 PM)
`pp-os/scout/scripts/add-incident-to-tracker.sh` now hard-fails on validation errors. Five guarantees in place. The May 21 outage pattern (single-file tsc + "WARN proceeding anyway") cannot recur. Active script is updated; backup repo push pending PAT rotation.
