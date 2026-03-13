# Permission Protocol Roadmap

## Current Status: Pre-v1.0

Permission Protocol is in active development with design partners. The SDK and receipt schema are stabilizing toward v1.0 freeze.

## v1.0 Freeze (Imminent)

The following are **frozen for v1.0** and will not change without a major version bump:

### SDK Public API

```typescript
// Two methods, one class
PermissionRouter.configure(opts: ConfigureOptions): void
PermissionRouter.execute<TInput, TResult>(opts: ExecuteOptions<TInput>): Promise<ExecuteResult<TResult>>

// Five exported types
ConfigureOptions
ExecuteOptions<TInput>
ExecuteResult<TResult>
PermissionReceipt
HashablePayloadV1

// One error class
PermissionProtocolError

// Three utilities
computeHash(payload: HashablePayloadV1): string
canonicalize(obj: unknown): string
buildHashablePayload(opts): HashablePayloadV1
```

### PermissionReceipt Schema v1

| Field | Type | Status |
|-------|------|--------|
| `receiptId` | string | Required |
| `tenantId` | string | Required |
| `agentId` | string | Required |
| `tool` | string | Required |
| `operation` | string | Required |
| `inputHash` | string | Required |
| `decision` | enum | Required |
| `reasonCodes` | string[] | Required |
| `approver` | enum | Required |
| `createdAt` | string | Required |
| `policyVersion` | string | Optional |
| `receiptSig` | string | Optional (future) |
| `sigAlg` | enum | Optional (future) |

### Specifications

| Spec | Version | Status |
|------|---------|--------|
| Hashable Payload | `pp.hashable_payload.v1` | Frozen |
| Status Mapping | `pp.status_mapping.v1` | Frozen |
| Protocol Version | `1` | Frozen |

## What IS Allowed After v1.0

| Change Type | Example | Allowed? |
|-------------|---------|----------|
| New spec versions | `pp.hashable_payload.v2` | Yes |
| New playbooks | `docs/playbooks/new-pattern.md` | Yes |
| Better documentation | Clarifications, examples | Yes |
| New optional receipt fields | `sigAlg` implementation | Yes |
| Bug fixes | SDK error handling | Yes |

## What IS NOT Allowed After v1.0

| Change Type | Example | Allowed? |
|-------------|---------|----------|
| Silent behavior changes | Changing hash algorithm | No |
| "Helpful" SDK additions | New methods on PermissionRouter | No |
| Breaking schema changes | Removing/renaming required fields | No |
| UI creep | Dashboards, admin panels | No |
| Policy builder features | Visual policy editors | No |

These constraints protect you from ourselves. v1.0 freezes the primitive.

## Post-v1.0 (Phase 4+)

After v1.0 ships and design partners validate the standard:

| Area | Description | Phase |
|------|-------------|-------|
| Monetization | Hosted enforcement, exports, SLAs | 4 |
| Selective UI | Approval inbox only (no dashboards) | 4 |
| Compliance positioning | SOC 2, audit tooling | 4 |
| Enterprise features | SSO, team management | 5+ |

Phase 4+ only works if v1.0 is stable and adopted.

## Non-Goals (Permanent)

These will **never** be part of Permission Protocol core:

- Policy builders / visual editors
- Analytics dashboards
- "AI safety" theater
- General-purpose audit logging
- Workflow orchestration

Permission Protocol is a receipt primitive. It stays narrow.

## Timeline

| Milestone | Status |
|-----------|--------|
| SDK alpha (`0.1.0-alpha.1`) | Complete |
| Design Partner Program | Active |
| v1.0 freeze | ~6 weeks |
| v1.0 release | After design partner validation |

## Contributing

Before proposing changes, read this roadmap. If your proposal:

- Adds new SDK methods → Probably no
- Adds UI → Definitely no
- Improves docs → Yes
- Fixes bugs → Yes
- Adds a new spec version → Maybe (needs RFC)

Open a GitHub Discussion for proposals that don't fit existing patterns.
