# PRD/RFC: Authority Model v1

Generated: 2026-05-19
Status: Draft / companion spec
Owner: Product / Security / Engineering
Product area: Permission Protocol receipts, signer authority, policy, audit

---

## 1. Purpose

This companion spec holds the authority-model work intentionally removed from the repo-onboarding PRD.

Repo onboarding must not define PP's full receipt/signer/quorum/break-glass model. It only needs to avoid blocking it. This document is where the authority primitive should be designed with proper security/legal/product review.

Related onboarding PRD:

- `pp-os/prds/permission-aware-repo-onboarding-prd.md`

---

## 2. Scope

This spec should eventually define:

- receipt contract,
- signer identity and authority,
- policy and quorum model,
- notification model,
- replay / SHA / force-push semantics,
- break-glass and outage behavior,
- retention / export / deletion,
- bot PR policy,
- grandfathering open PRs at install time.

This draft is intentionally not implementation-ready. It captures requirements and contradictions to resolve before enterprise hardening.

---

## 3. Receipt Contract

A receipt is durable proof that PP evaluated an action, routed it through policy, captured the authorized decision, and emitted a verifiable result.

Open design requirements:

- What exact action context is signed?
- Is the receipt cryptographically verifiable offline?
- What key format and rotation model is used?
- Does the receipt embed the policy hash/version?
- How does a third party verify receipt authenticity?
- Are receipts immutable, superseded, or mutable with audit history?
- Which fields are public vs workspace-private?

Important onboarding dependency:

- Repo-protection receipts must bind to repo ID, PR number, head SHA/diff context, policy context, signer decision, and issued timestamp.

---

## 4. Signer Identity and Authority

Questions to resolve:

- Who may sign for a workspace?
- How is authority granted, scoped, revoked, and rotated?
- Is self-approval allowed? Under what policy?
- What happens when no signer is available?
- How is signer auth method recorded?
- What happens to historical receipts after signer revocation?

V1 direction:

- Signer authority should be explicit and scoped.
- Receipts should record authority basis at decision time.
- Self-approval should be policy-controlled and visible in receipts.

---

## 5. Policy / Quorum Model

Do not bake in single-approver forever.

The model should leave room for:

- single signer,
- M-of-N quorum,
- role-restricted approvals,
- path-scoped approvals,
- branch/environment-scoped approvals,
- risk-tier-specific approvals,
- founder/admin veto,
- bot-specific auto-clear rules.

Open contradiction to resolve:

- If receipt schema has scalar `decisionRequired: "human_approval"`, it may conflict with future quorum. Prefer a structured policy requirement object.

---

## 6. Notifications

Signer request delivery affects activation and production usability.

Channels to evaluate:

- dashboard queue,
- email,
- Slack/Discord/webhook,
- GitHub PR comment,
- mobile push later.

Requirements:

- notification includes repo, PR/action, risk, policy, expiry, and signing link,
- notification state is auditable where possible,
- GitHub comments are not the only notification path.

---

## 7. Outage and Break-Glass

Fail-closed is safe but can freeze production.

Questions:

- What is PP's documented outage behavior?
- Is break-glass enabled by default or opt-in?
- Who can invoke break-glass?
- What scope/time window applies?
- Does break-glass create a receipt or emergency audit record?
- How is it surfaced in dashboards/exports?

Principle:

- Break-glass must never masquerade as normal PP approval. It is an explicit emergency bypass with audit evidence.

---

## 8. Replay, Force-Push, and Merge Semantics

Required decisions:

- Approval binds to exact PR head SHA and relevant diff/policy hash.
- New head SHA should supersede previous approval unless carry-forward proves no meaningful diff change.
- Force-push after approval requires re-approval unless carry-forward passes.
- Approval should expire.
- Status/check posting targets exact SHA.
- Squash/rebase merge produces a different merge commit SHA; receipt must link approved PR head SHA to resulting merge metadata.

---

## 9. Bot PR Policy

Bot PRs will dominate volume.

Questions:

- Are Dependabot/Renovate/internal bots gated the same as humans by default?
- Which bot changes can auto-clear?
- What risk classifier evidence is required?
- How are auto-clear receipts represented?

Default conservative position:

- Bot PRs follow the same gate unless policy explicitly auto-clears them.
- Auto-clear still emits receipt/audit evidence.

---

## 10. Grandfathering Open PRs

When PP is installed on an active repo, existing PRs need migration policy.

Options:

1. Gate all open PRs immediately.
2. Gate only new PRs after activation timestamp.
3. Let admin select PRs/branches.

Default recommendation for onboarding UX:

- Gate new PRs after activation by default, with visible warning about existing open PRs.

---

## 11. Retention, Export, Deletion

Enterprise questions:

- How long are receipts retained?
- Can customer export all receipts?
- Can public receipt pages be disabled?
- How are GDPR deletion requests handled without destroying audit integrity?
- Can customer store receipts in their own archive?

Direction:

- Prefer exportability and tombstone/supersession over silent deletion.
- Separate personal data redaction from immutable audit facts where legally possible.

---

## 12. Next Step

This draft should become a real RFC before PP sells enterprise-grade auditability:

1. Define receipt schema and verification model.
2. Define signer authority schema.
3. Define SHA/replay/carry-forward rules.
4. Define break-glass policy.
5. Review with security/legal buyer lens.
