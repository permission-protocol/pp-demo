import { verifyAuthorization, CanonicalPayload, SignedToken } from './verifier';

export async function interceptToolCall(
  jsonRpcMessage: any,
  publicKeyPem: string
): Promise<{ allowed: boolean; reason?: string }> {
  // Only intercept tool calls
  if (jsonRpcMessage.method !== 'tools/call') {
    return { allowed: true };
  }

  const toolName = jsonRpcMessage.params?.name;
  
  // High-risk action enforcement
  if (toolName === 'deploy_code') {
    console.log(`\n🛡️ [MCP Guard] Intercepting high-risk action: ${toolName}`);
    const args = jsonRpcMessage.params?.arguments || {};
    
    // Extract authorization wrapper
    const authorization = args._authorization;
    if (!authorization) {
      console.log('❌ [MCP Guard] DENY: No _authorization block provided.');
      return { allowed: false, reason: 'Missing _authorization block' };
    }

    const payload: CanonicalPayload = authorization.payload;
    const token: SignedToken = authorization.token;

    if (!payload || !token) {
      console.log('❌ [MCP Guard] DENY: Malformed authorization block.');
      return { allowed: false, reason: 'Malformed authorization block' };
    }

    // Exact argument binding: The arguments requested MUST match what was signed
    const { _authorization, ...executionArgs } = args;
    
    // Check that the payload action matches the tool we are calling
    if (payload.action !== toolName) {
      console.log(`❌ [MCP Guard] DENY: Payload action mismatch. Expected ${toolName}, got ${payload.action}`);
      return { allowed: false, reason: 'Payload action mismatch' };
    }

    // Deep compare execution arguments against signed payload arguments
    // Simple JSON comparison works because they should be identical objects
    if (JSON.stringify(executionArgs) !== JSON.stringify(payload.args)) {
      console.log(`❌ [MCP Guard] DENY: Arguments mismatch. Execution arguments do not exactly match the signed payload.`);
      return { allowed: false, reason: 'Arguments mismatch' };
    }

    try {
      // Call the strict verifier
      await verifyAuthorization(payload, token, publicKeyPem);
      console.log(`✅ [MCP Guard] ALLOW: Authorization verified for ${toolName}.`);
      return { allowed: true };
    } catch (err: any) {
      console.log(`❌ [MCP Guard] DENY: Verification failed - ${err.message}`);
      return { allowed: false, reason: err.message };
    }
  }

  // Allow anything not strictly governed by this test
  return { allowed: true };
}
