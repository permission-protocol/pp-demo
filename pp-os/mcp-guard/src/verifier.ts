import stableStringify from 'fast-json-stable-stringify';
import crypto from 'crypto';

export interface CanonicalPayload {
  request_id: string;
  action: string;
  args: Record<string, any>;
  issued_at: number;
  expires_at: number;
  nonce: string;
}

export interface SignedToken {
  request_id: string;
  decision: string;
  payload_hash: string;
  signed_by: string;
  signed_at: number;
  expires_at: number;
  key_id: string;
  signature: string; // Hex string
}

export async function verifyAuthorization(
  payload: CanonicalPayload,
  token: SignedToken,
  publicKeyPem: string
): Promise<boolean> {
  // 1. Check Expiry
  const now = Math.floor(Date.now() / 1000);
  if (token.expires_at < now) {
    throw new Error('Authorization token expired');
  }
  if (payload.expires_at < now) {
    throw new Error('Payload expired');
  }

  // 2. Enforce Decision
  if (token.decision !== 'approved') {
    throw new Error(`Invalid decision: ${token.decision}`);
  }

  // 3. Stable Stringify & Hash
  const canonicalString = stableStringify(payload);
  const recomputedHash = crypto.createHash('sha256').update(canonicalString).digest('hex');

  // 4. Compare Hashes
  if (recomputedHash !== token.payload_hash.replace('sha256:', '')) {
    throw new Error('Payload hash mismatch - args were modified after approval');
  }

  // 5. Verify Signature
  // For Ed25519, crypto.verify algorithm parameter is null
  const isValidSig = crypto.verify(
    null,
    Buffer.from(recomputedHash),
    publicKeyPem,
    Buffer.from(token.signature, 'hex')
  );

  if (!isValidSig) {
    throw new Error('Cryptographic signature verification failed');
  }

  return true;
}
