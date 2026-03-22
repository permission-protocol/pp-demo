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

## UI Requirements
Replace "Approve" with "Sign & Authorize".
Add text: "You will be recorded as the signer."

## Non-negotiables
- ❌ Never trust DB `is_approved`
- ❌ Never approve by `request_id` only
- ✅ Approval MUST bind to exact args
- ✅ Signature MUST be verified at execution
- ✅ Token should be single-use or short-lived

## Build Order (Truth Boundary Backward)
1. **MCP Guard Verifier** (The Lock)
   - Stable stringify (deterministic JSON)
   - SHA-256 payload hashing
   - Ed25519 signature verification (`verifyAuthorization(payload, token)`)
   - Expiry & replay checks
   - Hard fail if any check misses.
2. **PP Backend Signer** (The Keymaker)
   - Emits exactly what MCP Guard expects.
   - Signs with PP backend private key (Frontend DOES NOT sign).
3. **PP Frontend / UI** (The Button)
   - Replaces "Approve" with "Sign & Authorize".
   - Warns user they are recorded as the signer.
