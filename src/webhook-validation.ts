/**
 * Webhook Signature Validation
 * HMAC-SHA256 verification for incoming production webhooks
 */

import { createHmac, timingSafeEqual } from 'crypto';

export interface WebhookValidationResult {
  valid: boolean;
  error?: string;
}

export function validateWebhookSignature(
  payload: string,
  signature: string,
  secret: string,
): WebhookValidationResult {
  if (!signature || !signature.startsWith('sha256=')) {
    return { valid: false, error: 'Missing or malformed signature header' };
  }

  const expected = createHmac('sha256', secret)
    .update(payload, 'utf8')
    .digest('hex');

  const received = signature.slice('sha256='.length);

  if (expected.length !== received.length) {
    return { valid: false, error: 'Signature length mismatch' };
  }

  const isValid = timingSafeEqual(
    Buffer.from(expected, 'hex'),
    Buffer.from(received, 'hex'),
  );

  return isValid
    ? { valid: true }
    : { valid: false, error: 'Signature verification failed' };
}
