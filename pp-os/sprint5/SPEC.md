# Sprint 5 Outreach Master Build — Spec

**Goal:** Produce `pp-sprint5-master.csv` + `EXECUTE.md` so Rod can run a full-day outreach push Wednesday April 29, 2026.

**Inputs:**
- `source-list.md` — strategy session output: 50 founders/CTOs (List 1), 10 VCs (List 2), 20 ex-employees (List 3, 5 named + 15 search slots).
- `source-csv.csv` — slop CSV with fabricated emails. Mine for *names only* if useful; do not use any email from this file.

**Quality bar (mandatory, from the .md's own rules):**
1. **Never fabricate emails.** Only include an email if you can cite a public source where it appears (company "About"/"Press"/"Contact" page, conference speaker bio, GitHub commit, podcast show notes, public talk, founder personal site, Crunchbase, ProductHunt maker page, Twitter bio, etc.). Record the source URL in `EmailSource`.
2. **Never invent personalization.** If the source-list.md hook is `[HOOK – VERIFY]`, replace it with one verified hook from a public source, OR drop the row.
3. **Verify LinkedIn URLs.** Every URL must resolve to the right person at the right company. Mark `LI_Verified` true/false.
4. **Confidence tiers preserved:** 🟢 / 🟡 / 🔴. Drop 🔴 rows that fail verification.

**Output schema (`pp-sprint5-master.csv`):**

| Column | Notes |
|---|---|
| List | 1 / 2 / 3 |
| Tier | A (🟢 + email verified) / B (🟢 LI only) / C (🟡) / D (🔴 keep but flagged) |
| Priority | 1–N within tier (Rod sends top-down) |
| Name | Full name |
| Title | Role |
| Company | Company name |
| LinkedIn | Full URL |
| LI_Verified | true / false |
| Email | Verified email or empty |
| EmailSource | URL where email was found, or empty |
| Twitter | Handle if verified, else empty |
| Hook | Specific recent fact (last 6 months preferred), 1 sentence |
| LI_Original | The 281–299 char invite from source-list.md (verbatim if present) |
| LI_PilotHook | Rewritten 290-char invite leading with the 30-day pilot/install offer |
| Email_Long | 4–6 sentence cold email, subject line included as first line `Subject: ...` |
| Channel_Recommended | "email" if Email present, else "linkedin" |
| SendDay | Wed_AM / Wed_Midday / Wed_PM |
| Status | empty (Rod fills) |
| Notes | Anything Rod needs to know before sending |

**Tier mapping → SendDay:**
- Tier A (🟢 + email): Wed_AM (highest reply rate, send first via email)
- Tier B (🟢 LI only): Wed_Midday (LinkedIn invite)
- Tier C (🟡): Wed_PM (after morning replies start coming in)
- Tier D (🔴): only if specifically valuable + verified; otherwise drop

**EXECUTE.md must contain:**
- One-line drought counter
- Top 10 highest-confidence sends with copy-paste blocks
- Email sequence: Subject + body + send-from address
- LinkedIn sequence: profile URL + invite text
- Day-of timing recommendations (avoid sending all 80 in 1 hour — LinkedIn flags it)
- Reply triage rules: if accept → Day 3 follow-up; if email reply → respond within 1 hour with calendar link

**Process:**
1. Step 1 — Parse source-list.md into JSON: `prospects.json` with all 80 rows + the source-list's original LI invite text per row.
2. Step 2 — For each prospect, run web verification:
   - LinkedIn URL → does it resolve and is the person at the company per their bio?
   - Email → search company contact pages, founder personal site, Twitter bio, GitHub commits, conference bios.
   - Hook → if `[VERIFY]`, find one verifiable recent fact from last 6 months.
3. Step 3 — Generate `LI_PilotHook` and `Email_Long` per row using the verified hook.
4. Step 4 — Sort, tier, write `pp-sprint5-master.csv`.
5. Step 5 — Write `EXECUTE.md`.
6. Step 6 — Sanity check: 0 fabricated emails, all LinkedIn URLs resolve, hooks all from verifiable sources.

**Message templates — references:**

`LI_Original`: Use verbatim from the source .md.

`LI_PilotHook` template (≤290 chars):
> Hi [name] — [hook fragment, 1 short clause]. Permission Protocol: free 30-day Sentinel pilot to gate one real action with a signed receipt (AIUC-1 B006/A003 — Phil Venables' "SOC 2 for agents"). 15 min to set it up this week? Founder calls only.

`Email_Long` template (4–6 sentences, conversion-leaning):
> Subject: Free Sentinel pilot for [Company] — gate one real action
>
> Hi [name],
>
> [hook — 1 sentence specific to them, last 6 months].
>
> I'm running Permission Protocol — the verifiable receipt layer for AI agent actions, implementing AIUC-1 B006 / A003.3 / D003 (what Phil Venables called "SOC 2 for AI agents"). For Sprint 5 we're offering 5 customer-facing AI agent companies a free 30-day pilot: gate one real action with a signed Ed25519 receipt your enterprise buyers can independently verify. Two engineers, one afternoon, you keep the receipt artifacts.
>
> Quickest version: I send you a 5-line SDK snippet, you wrap your highest-stakes action with it, and on day 30 you have an audit trail no buyer has seen before. If it doesn't show up in a procurement conversation in 30 days, you owe me nothing and I delete the integration.
>
> 15 min Wed/Thu to scope which action to gate?
>
> — Rod
> Founder, Permission Protocol
> permissionprotocol.com · [calendar link]

**Hard constraints for the agent doing the work:**
- No fabrication. Empty cells beat invented ones.
- Cite every email source.
- If a hook can't be verified in 5 min of search, drop the row to Tier D or omit.
- For VCs (List 2), do NOT include their personal email unless it's published on their firm's "Team" page or a recent press release. If unsure, leave email blank and route via LinkedIn.
- For ex-employees (List 3 search slots), run the LinkedIn search yourself (where possible without auth) or leave the slot as `[SALES_NAV: <query>]` for Rod to run manually in 15 min.
