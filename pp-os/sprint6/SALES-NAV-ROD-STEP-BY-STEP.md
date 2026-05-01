# Permission Protocol — LinkedIn Sales Navigator Setup

Follow this in order. Don’t optimize yet. The goal is to build the first clean outreach machine for the new wedge:

> AI-authored production-sensitive GitHub PRs should stay blocked until a named human signs the exact repo, PR, commit, policy, and action.

## What you are building

By the end, Sales Navigator should have:

- 7 Account Lists
- 7 Lead Lists
- 25 seed accounts saved
- Platform + AppSec lead searches saved
- a simple rule for deciding who gets contacted first

Primary first contacts:

1. Platform / Developer Infrastructure
2. AppSec / Security Engineering

Do **not** start with CEOs. Do **not** pitch generic AI governance.

---

# Part 1 — Create Account Lists

In Sales Navigator:

1. Open **Sales Navigator**.
2. Go to **Lists**.
3. Choose **Account Lists**.
4. Click **Create account list**.
5. Create these exactly:

- `PP - Tier 1 - First 25`
- `PP - Fintech / Payments`
- `PP - Healthcare / Life Sciences SaaS`
- `PP - Dev Infra / Security`
- `PP - Compliance B2B SaaS`
- `PP - AI-Native / Agents`
- `PP - Disqualified / Too Big / Too Small / Wrong Stack`

Done when all 7 account lists exist.

---

# Part 2 — Create Lead Lists

In Sales Navigator:

1. Go to **Lists**.
2. Choose **Lead Lists**.
3. Click **Create lead list**.
4. Create these exactly:

- `PP - Platform Primary`
- `PP - AppSec Primary`
- `PP - Exec Sponsors`
- `PP - GRC Validators`
- `PP - Warm Intro / TeamLink`
- `PP - Replied / Interested`
- `PP - Pilot Candidates`

Done when all 7 lead lists exist.

---

# Part 3 — Add the first 25 accounts manually

Do this manually. Do not use account search yet.

For each company:

1. Use the Sales Nav top search bar.
2. Search the company name.
3. Open the correct company account page.
4. Click **Save**.
5. Add it to `PP - Tier 1 - First 25`.
6. Also add it to the segment list shown below.

| Account | Also add to |
|---|---|
| Ramp | PP - Fintech / Payments |
| Mercury | PP - Fintech / Payments |
| Modern Treasury | PP - Fintech / Payments |
| Lithic | PP - Fintech / Payments |
| Unit | PP - Fintech / Payments |
| Alloy | PP - Fintech / Payments |
| Sardine | PP - Fintech / Payments |
| Benchling | PP - Healthcare / Life Sciences SaaS |
| Datavant | PP - Healthcare / Life Sciences SaaS |
| Redox | PP - Healthcare / Life Sciences SaaS |
| Cedar | PP - Healthcare / Life Sciences SaaS |
| Vercel | PP - Dev Infra / Security |
| Sentry | PP - Dev Infra / Security |
| Snyk | PP - Dev Infra / Security |
| LaunchDarkly | PP - Dev Infra / Security |
| CircleCI | PP - Dev Infra / Security |
| Harness | PP - Dev Infra / Security |
| Retool | PP - Compliance B2B SaaS |
| PlanetScale | PP - Dev Infra / Security |
| Neon | PP - Dev Infra / Security |
| Supabase | PP - Dev Infra / Security |
| PostHog | PP - Dev Infra / Security |
| Temporal | PP - Dev Infra / Security |
| Gusto | PP - Compliance B2B SaaS |
| Rippling | PP - Compliance B2B SaaS |

Done when `PP - Tier 1 - First 25` has 25 accounts.

---

# Part 4 — Find Platform / Dev Infra leads

This is the first buyer search.

In Sales Navigator:

1. Go to **Lead filters**.
2. Set **Account lists** to `PP - Tier 1 - First 25`.
3. Set **Seniority level** to:
   - Director
   - Head
   - VP
4. Set **Function** to:
   - Engineering
   - Information Technology
5. Set **Current job title** to this Boolean:

```text
("Head of Platform" OR "Director of Platform" OR "Platform Engineering" OR "Developer Infrastructure" OR "Developer Experience" OR DevEx OR "Engineering Productivity" OR "Infrastructure Engineering")
```

6. If there are too many results, add these filters in this order:
   - 2nd-degree connections
   - Posted on LinkedIn in past 30 days
   - Changed jobs in last 90 days
   - TeamLink intro, if available
7. Save 1–2 good leads per account to `PP - Platform Primary`.
8. Save the search as:

`PP Leads - Platform Primary - Tier 1`

Done when you have at least 15 Platform/Dev Infra leads saved.

---

# Part 5 — Find AppSec / Security Engineering leads

This is the second buyer search.

In Sales Navigator:

1. Go to **Lead filters**.
2. Set **Account lists** to `PP - Tier 1 - First 25`.
3. Set **Seniority level** to:
   - Manager
   - Director
   - Head
   - VP
4. Set **Function** to:
   - Engineering
   - Information Technology
5. Set **Current job title** to this Boolean:

```text
("Application Security" OR AppSec OR "Security Engineering" OR "Product Security" OR "Cloud Security" OR "Security Architect")
```

6. If there are too many results, add these filters in this order:
   - 2nd-degree connections
   - Posted on LinkedIn in past 30 days
   - Changed jobs in last 90 days
   - TeamLink intro, if available
7. Save 1–2 good leads per account to `PP - AppSec Primary`.
8. Save the search as:

`PP Leads - AppSec Primary - Tier 1`

Done when you have at least 15 AppSec/Security Engineering leads saved.

---

# Part 6 — Optional: add exec sponsors

Do this after Platform + AppSec are mapped.

In Sales Navigator:

1. Go to **Lead filters**.
2. Set **Account lists** to `PP - Tier 1 - First 25`.
3. Set **Seniority level** to:
   - VP
   - CXO
4. Set **Current job title** to this Boolean:

```text
("VP Engineering" OR "Vice President Engineering" OR CTO OR "Chief Technology Officer" OR CISO OR "Chief Information Security Officer")
```

5. Save useful people to `PP - Exec Sponsors`.
6. Save the search as:

`PP Leads - Exec Sponsors - Tier 1`

Do not message these first unless they are clearly active or you have a warm path.

---

# Part 7 — Optional: add GRC validators

Only use these people later to validate audit/evidence pain.

In Sales Navigator:

1. Go to **Lead filters**.
2. Set **Account lists** to `PP - Tier 1 - First 25`.
3. Set **Current job title** to this Boolean:

```text
(GRC OR "Security Compliance" OR "Compliance Engineering" OR "Trust" OR "Risk" OR "Audit")
```

4. Save useful people to `PP - GRC Validators`.
5. Save the search as:

`PP Leads - GRC Validators - Tier 1`

Do not lead with GRC.

---

# Part 8 — Decide which accounts are outreach-ready

An account is ready when you have at least:

- 1 Platform / Dev Infra lead
- 1 AppSec / Security Engineering lead

Best buying map per account:

1. Platform / Dev Infra lead
2. AppSec / Security Engineering lead
3. VP Eng / CTO / CISO sponsor
4. GRC / Compliance validator

Prioritize people with:

- TeamLink or warm intro
- 2nd-degree connection
- Posted on LinkedIn in the last 30 days
- Changed jobs in last 90 days
- Recent posts about AI, platform engineering, security, CI/CD, audits, GitHub, Copilot, Cursor, Claude Code, Terraform, SOC 2, PCI, HIPAA

---

# Part 9 — Score accounts quickly

Use a simple 0–15 score. Give 0–3 points for each:

1. GitHub / GitHub Actions signal
2. AI coding rollout signal: Copilot, Cursor, Claude Code, Codex, internal agents
3. Compliance pressure: SOC 2, ISO, PCI, HIPAA, SOX
4. Sensitive production paths: Terraform, IaC, deploy workflows, Kubernetes, DB migrations
5. Buyer density: 50–1,000 engineers plus visible Platform/AppSec team

Priority:

- 12–15: outreach now
- 9–11: include if warm path or strong activity
- 6–8: park
- 0–5: disqualify

Disqualify:

- Tiny startups
- Huge banks / Fortune 100 without warm intro
- Non-GitHub-heavy companies
- No compliance pressure
- Generic AI governance teams as first contact

---

# Part 10 — First-touch messages

Use these as connection notes or short InMails.

## Platform / Dev Infra

```text
Saw you lead platform/dev infra at {{Company}}. Curious how you’re handling AI-authored PRs that touch deploy workflows, Terraform, DB migrations, or prod-sensitive paths.
```

## AppSec

```text
Saw your security engineering work at {{Company}}. I’m looking at how AppSec teams handle AI-authored PRs touching sensitive repos without a signed human authorization trail.
```

## VP Eng / CTO

```text
Curious how {{Company}} is balancing AI coding adoption with production-change controls. We’re focused on signed human authorization for risky AI-authored PRs.
```

Do not send the same note to all personas.

---

# Part 11 — Follow-up cadence

## Day 0
Send the persona-specific opener.

## Day 2 — concrete risk

```text
The specific gap we’re seeing: AI can help create or modify a PR, but GitHub approval alone may not prove exactly what risky action a human authorized for a specific commit.

We’re testing a lightweight GitHub gate for deploy workflows, Terraform, DB migrations, and similar paths.
```

## Day 5 — pilot offer

```text
The pilot is simple: one production-adjacent repo, one required check, a test AI-authored PR, a blocked merge, and a signed receipt tied to repo, PR, commit, policy, signer, and timestamp.

Worth comparing notes?
```

## Day 10 — multithread

- If Platform does not respond, message AppSec.
- If AppSec engages but stalls, add VP Eng / CTO.
- If both Platform and AppSec engage, ask who owns GitHub branch protection / production change controls.

## Day 14 — breakup

```text
I’ll close the loop. My read is this only matters if AI coding tools are already touching production-sensitive GitHub paths and auditability is becoming a problem.

If that’s not true at {{Company}}, timing is probably wrong.
```

---

# Part 12 — Daily routine

Every morning:

1. Open **Sales Navigator Alerts**.
2. Filter by saved account and lead lists.
3. Look for:
   - job changes
   - recent posts
   - company updates
   - hiring/funding
   - AI coding posts
   - GitHub / CI/CD / security / compliance posts
4. Use those as the reason to engage.

---

# Part 13 — Weekly rhythm

Monday: Add 10 new accounts from saved searches.
Tuesday: Find Platform + AppSec leads.
Wednesday: Send first-touch messages.
Thursday: Follow up with active leads and TeamLink intros.
Friday: Review replies, move interested leads to `PP - Pilot Candidates`, disqualify weak accounts.

Track weekly:

- Accounts added
- Accounts with Platform lead found
- Accounts with AppSec lead found
- Connection requests sent
- Replies
- Meetings booked
- Pilot candidates
- Disqualified reason

---

# The actual buying question

Do not ask: “Do you need AI governance?”

Ask:

> Can you prove who authorized this AI-authored production change before it merged?
