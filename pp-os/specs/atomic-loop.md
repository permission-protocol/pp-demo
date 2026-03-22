# Atomic Loop (v1 Spec)
Date: 2026-03-22
Source: Rod (Discord #atomic-loop)

## Core Principle
Turn approval into cryptographic authorization.
Canonical payload → hash → signed token → strict verification → receipt.
The system trusts the signature, not the database state.

## 1. Canonical Payload (What is being approved)
Deterministic JSON (stable ordering). Args MUST match execution exactly. Short expiry.
```json
{
 "request_id": "req_123",
 "action": "deploy_code",
 "args": { "env": "prod", "commit": "abc123" },
 "issued_at": 1711111111,
 "expires_at": 1711111411,
 "nonce": "random"
}
```

## 2. Hash
Bind approval to action.
`payload_hash = SHA256(canonical_payload)`

## 3. Signed Decision
Sign with Ed25519.
```json
{
 "request_id": "req_123",
 "decision": "approved",
 "payload_hash": "sha256:...",
 "signed_by": "rod",
 "signed_at": 1711111122,
 "expires_at": 1711111411,
 "key_id": "pp-prod-1"
}
```

## 4. Executor (MCP Guard) Verification
Before execution:
- verify signature (public key)
- check expiry
- recompute payload_hash
- compare hashes
- ensure decision == approved
If ANY fail → block.

## 5. Receipt (Evidence)
Derived from: payload + signed decision + execution result.
Produces an immutable proof of authorization.

## Build Order (Truth Boundary Backward)
1. **MCP Guard Verifier** (The Lock) [DONE]
   - Stable stringify (deterministic JSON)
   - SHA-256 payload hashing
   - Ed25519 signature verification (`verifyAuthorization(payload, token)`)
   - Expiry & replay checks
   - Hard fail if any check misses.
2. **MCP Guard Interceptor** (The Enforcement Slice) [DONE]
   - Stdio proxy interception of `tools/call`.
   - Parses authorization block from arguments.
   - Deep compares execution arguments against signed payload.
   - Triggers Verifier and fails closed.
3. **PP Backend Signer** (The Keymaker) [DONE]
   - Emits exactly what MCP Guard expects.
   - Signs with PP backend private key `PP_PRIVATE_KEY_PEM` (Frontend DOES NOT sign).
   - Generates the deterministic JSON payload matching execution requirements.
   - `POST /api/authorization/sign` endpoint built.
4. **PP Frontend / UI** (The Button) [DONE]
   - Replaced "Approve" with "Sign & Authorize".
   - Added text: "You will be recorded as the signer." and "Authorization is bound to exact args."
   - Handled atomic execution directly on UI level: `sign` → `execute` → fallback to DB state.
5. **Receipts & Accountability** [DONE]
   - Generates immutable receipts containing canonical payload + verified token claims.
   - Saves to `pp-receipts.jsonl`.
6. **Generalization & Hardening** [DONE]
   - Supports multi-tool mapping (`deploy_code`, `delete_user_data`).
   - Strong schema validation and Trust Boundary validation (`key_id`).
   - Upgraded to Durable Redis Cache for Replay Protection.
7. **YAML Policy Layer** [DONE]
   - `pp.config.yaml` defining tools, protected status, max TTL, and allowed signers.
   - Dynamic enforcement mapped into verifier.
8. **Audit Viewer** [DONE]
   - Built UI to display parsed receipts, proving "who authorized what, under which policy, and what executed".
   - Policy hashes appended to receipts.
