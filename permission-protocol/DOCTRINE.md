# Permission Protocol: Doctrine v1

## One-Line Doctrine

> **No autonomous system may change production without external, human-legible authorization and receipt.**

## Axiom

> **No receipt, no deploy. Receipts are the only currency of authorization.**

---

## Definitions

**Production** = any environment that serves real users or writes to real customer data.

**External** = outside the agent runtime and not alterable by the agent.

---

## The Invariant

Authorization must live **outside** the agent. This is not a design choice—it's structurally required.

Once an agent's actions:
- Have real-world consequences
- Outlive the agent's runtime
- Involve multiple agents or humans
- Require evidence for non-agent audiences (security, legal, leadership)

...internal agent governance collapses due to:
- **Conflict of interest** — agents cannot objectively authorize their own actions
- **Ephemerality** — agent state doesn't persist for audit
- **No separation of powers** — judge, jury, executor collapse into one

Even a perfectly aligned agent will request more resources, escalate privileges, and justify actions instrumentally—unless **external choke points** exist.

Runaway autonomy is prevented not by better goals, but by **external authorization at power-acquisition points**.

---

## The Wedge: Production Deploys

Permission Protocol v1 = **external authorization for autonomous production changes**.

Why deploys? Because they are:

| Property | Why It Matters |
|----------|----------------|
| **Frequent** | High surface area for enforcement |
| **Irreversible** (or costly to reverse) | Stakes are real |
| **Already governed socially** | Blame and approval already exist |
| **Already tied to postmortems** | Failure has consequences |
| **Already understood as approval events** | No new mental model required |

This collapses the search space. Deploys are where authorization already *should* exist—we're just making it machine-enforceable.

---

## What Permission Protocol Is

**The Signer of Record for agent actions.**

- An authority & enforcement layer, not an agent framework
- Produces tamper-evident receipts that answer: *who approved what, when, and why*
- Receipts are for humans **and** machines (dual-read)

**Alignment determines intent. Authorization determines legitimacy.**

Legitimacy must live outside the agent.

---

## What v1 Is NOT

Explicitly out of scope for v1:

- ❌ Money movement / payments
- ❌ Data access or deletion
- ❌ Infrastructure provisioning
- ❌ Safety/alignment features
- ❌ Broad GRC / compliance frameworks
- ❌ Multi-agent coordination
- ❌ Enterprise SSO / RBAC
- ❌ Polished approval UX (CLI/web is sufficient)

**Filter rule:** If it doesn't block a production deploy, it's not v1.

**v1 focuses on enforcement + verification; approval UX can be primitive.** Everything else fans out later—after the wedge is proven.

---

## The Receipt Contract

A receipt must be:
- **Machine-verifiable** — agents check existence + validity
- **Human-legible** — auditors, postmortems, leadership can read it

### Minimal Receipt (v1)

```json
{
  "receipt_id": "pp_rec_abc123",
  "decision": "ALLOW",
  "scope": {
    "action": "deploy",
    "repo": "acme/webapp",
    "commit": "a1b2c3d4",
    "environment": "production",
    "workflow": "deploy.yml",
    "artifact_digest": "sha256:e3b0c442..."
  },
  "approver": {
    "type": "human",
    "identity": "alice@acme.com"
  },
  "issued_at": "2026-02-09T15:00:00Z",
  "expires_at": "2026-02-09T16:00:00Z",
  "signature": "pp_sig_..."
}
```

Receipts bind to **immutable artifacts**: commit hash, workflow, and artifact/image digest when applicable.

### Two Readers, One Receipt

| Reader | Needs |
|--------|-------|
| **Machine** | `receipt_id`, `decision`, `scope`, `signature`, `expires_at` |
| **Human** | What changed, who approved, when, under what constraint |

**Key constraint:** Agents do not interpret authority. They only verify existence + validity of a receipt. This preserves separation of powers.

---

## Who This Is For

**First-order users:** Production deploy owners.

Specifically, the person who:
- Gates merges/releases/flags
- Gets paged when prod breaks
- Must explain bad deploys

**Qualification test:** Can they finish this sentence?
> "If an agent pushed a bad change to prod, I would be involved in explaining it."

If no → not first-order signal.

---

## Adoption Path

| Phase | Who | What |
|-------|-----|------|
| **v1** | Single frustrated deploy owner | Installs PP in a repo they own |
| **v2** | Team | Adopts because it works |
| **v3** | Org | Mandates because leadership wants receipts |

**Litmus test:** If a single on-call engineer can't install PP in a repo they own, v1 is wrong.

Enterprise shows up later asking for exports, SSO, and controls. That's when pricing power appears.

---

## Enforcement Point: GitHub Actions

v1 enforces at **GitHub Actions** because:
- Default deploy surface for agent-generated code
- Agent PRs → merges → Actions is the most common path
- Single deploy owner can install (no platform team required)
- Clear failure semantics ("check failed")
- Doesn't require changing how teams think about deploys

ArgoCD, Spinnaker, etc. come after inevitability is proven.

---

## The Ask (For Early Conversations)

Not: "Would you use this?"

Instead: "Walk me through your last bad deploy. Who approved it? How do you know? What would have caught it?"

We're extracting coordinates, not seeking belief.

---

*Permission Protocol v1 — February 2026*
