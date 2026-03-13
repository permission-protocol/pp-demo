# Security Policy

Permission Protocol is security-critical infrastructure. It gates production deployments and enforces authority boundaries for autonomous systems.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | ✅ Active support  |
| < 1.0   | ❌ Not supported   |

## Reporting a Vulnerability

**Do not open public issues for security vulnerabilities.**

Email: security@permissionprotocol.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Your recommended fix (if any)

We will acknowledge receipt within 48 hours and provide a timeline for resolution.

## Security Architecture

### Cryptographic Signing

**Algorithm:** Ed25519 (via `@noble/ed25519`)

**Key Generation:**
```bash
openssl rand -base64 32
```
This produces 32 random bytes encoded in base64. The base64 output must be decoded to 32 raw bytes before being used as the Ed25519 seed. The application handles this decoding automatically when reading `PP_SIGNING_PRIVATE_KEY`.

**Key Storage:**
- Private key: `PP_SIGNING_PRIVATE_KEY` environment variable (base64-encoded)
- Public key: Derived at runtime, stored in `PermissionSigningKey` table
- Key ID: `PP_SIGNING_KEY_ID` environment variable

**Signing Flow:**
1. Receipt data is canonicalized (JCS - sorted keys, deterministic JSON)
2. Canonical form is SHA-256 hashed
3. Hash is signed with Ed25519 private key
4. Signature stored as base64 in `signatureValue` field

**Verification:**
1. External systems fetch public key via `/api/v1/keys/:keyId`
2. Reconstruct canonical form from receipt fields
3. Verify Ed25519 signature against public key

### Key Rotation

1. Generate a new Ed25519 seed (`openssl rand -base64 32`)
2. Register new key with `status=active`
3. Mark old key as `rotated` (verification allowed, new signing disabled)
4. After migration window, mark old key as `revoked`

### API Key Authentication

**Modern Keys (recommended):**
- Format: `pp_live_<random>` or `pp_test_<random>`
- Storage: Scrypt hash in `ApiKey` table
- Validation: Constant-time comparison via `crypto.timingSafeEqual`

**Environment Keys (simple setup):**
- `PP_VERIFY_API_KEY`: Single shared key for verify endpoint
- Validated with constant-time comparison
- Intended for single-tenant or internal deployments. For multi-tenant environments, use modern per-company API keys.

**Legacy Keys (migration only):**
- Format: `companyId:secret`
- Disabled by default (`PP_ALLOW_LEGACY_VERIFY_API_KEY=true` to enable)
- Requires `PP_LEGACY_VERIFY_API_SECRET` for validation
- **Deprecated:** Migrate to modern keys

### Receipt Security

**Immutability:**
- Receipts are append-only
- No update or delete operations
- `idemKey` prevents duplicate creation

**Single-Use Redemption:**
- `redeemedAt` timestamp set atomically on first verify with `redeem=true`
- Subsequent redemption attempts return `RECEIPT_ALREADY_REDEEMED`
- Prevents replay attacks

**Expiration:**
- `expiresAt` enforced on verify
- Default: 1 hour (`PP_RECEIPT_EXPIRATION_MS`)
- Expired receipts return `RECEIPT_EXPIRED`

**Signing Enforcement:**
- `PP_SIGNING_MODE=required` (default): ALLOW/APPROVED receipts MUST be signed
- Unsigned execution receipts are rejected with `PP_UNSIGNED_RECEIPT`
- No bypass path exists

### Tenant Isolation

**Session-Based:**
- Company context derived from authenticated session + `CompanyMember` lookup
- No client-controlled tenant headers accepted (blocked in middleware)

**CLI Authentication:**
- `Authorization: Basic base64(tenantId:CLI_API_KEY)` + `X-Tenant-Id` header
- `CLI_API_KEY` must be stored server-side as an environment variable
- The `tenantId` must correspond to a valid company record in the database
- Both header values must match; mismatch results in authentication failure

**Belt + Suspenders:**
- All tenant-scoped database queries must include `companyId` in the WHERE clause
- Even with scoped DB wrapper, explicit filtering is required

## Rate Limiting

Applies to `/api/v1/receipts/verify` and other sensitive endpoints:

- **IP-based:** 100 requests/minute per IP
- **Token-based:** 200 requests/minute per API key

Returns `429 RATE_LIMITED` with `Retry-After` header.

## Security Invariants

1. **No execution without signed receipt** (when signing required)
2. **No cross-tenant data access** (enforced at query level)
3. **No receipt reuse** (atomic redemption)
4. **No unsigned ALLOW/APPROVED** (rejected with hard error)
5. **No client-controlled tenant context** (blocked in middleware)

## Bug Bounty

Currently no formal bug bounty program. Responsible disclosure is appreciated. With permission, contributors will be acknowledged in release notes.

## Security Contact

Email: security@permissionprotocol.com
