import stableStringify from 'fast-json-stable-stringify';
import crypto from 'crypto';

export async function generateTestFixtures() {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('ed25519');
  const now = Math.floor(Date.now() / 1000);
  
  const payload = {
    request_id: 'req_123',
    action: 'deploy_code',
    args: { env: 'prod', commit: 'abc123' },
    issued_at: now,
    expires_at: now + 3600, // 1 hour
    nonce: crypto.randomBytes(8).toString('hex')
  };
  
  const canonicalString = stableStringify(payload);
  const payloadHash = crypto.createHash('sha256').update(canonicalString).digest('hex');
  
  const signature = crypto.sign(null, Buffer.from(payloadHash), privateKey);
  const signatureHex = signature.toString('hex');
  
  const token = {
    request_id: payload.request_id,
    decision: 'approved',
    payload_hash: `sha256:${payloadHash}`,
    signed_by: 'rod',
    signed_at: now + 10,
    expires_at: payload.expires_at,
    key_id: 'pp-prod-1',
    signature: signatureHex
  };
  
  return {
    privateKeyPem: privateKey.export({ type: 'pkcs8', format: 'pem' }),
    publicKeyPem: publicKey.export({ type: 'spki', format: 'pem' }),
    payload,
    token
  };
}
