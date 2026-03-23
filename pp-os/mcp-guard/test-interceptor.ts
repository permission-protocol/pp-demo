import { generateTestFixtures } from './src/fixtures';
import { interceptToolCall } from './src/interceptor';

async function run() {
  const fixtures = await generateTestFixtures();
  const publicKeyPem = fixtures.publicKeyPem;

  const validArgs = {
    env: 'prod',
    commit: 'abc123',
    _authorization: {
      payload: fixtures.payload,
      token: fixtures.token,
    }
  };

  const validMessage = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
      name: 'deploy_code',
      arguments: validArgs
    }
  };

  const missingTokenMessage = {
    jsonrpc: '2.0',
    id: 2,
    method: 'tools/call',
    params: {
      name: 'deploy_code',
      arguments: {
        env: 'prod',
        commit: 'abc123'
      }
    }
  };

  const mismatchedArgsMessage = {
    jsonrpc: '2.0',
    id: 3,
    method: 'tools/call',
    params: {
      name: 'deploy_code',
      arguments: {
        env: 'prod',
        commit: 'DEF456', // Changed from abc123
        _authorization: {
          payload: fixtures.payload,
          token: fixtures.token,
        }
      }
    }
  };

  const invalidTokenMessage = {
    jsonrpc: '2.0',
    id: 4,
    method: 'tools/call',
    params: {
      name: 'deploy_code',
      arguments: {
        env: 'prod',
        commit: 'abc123',
        _authorization: {
          payload: fixtures.payload,
          token: {
            ...fixtures.token,
            signature: fixtures.token.signature.replace('a', 'b') // Tampered signature
          }
        }
      }
    }
  };

  const expiredTokenMessage = {
    jsonrpc: '2.0',
    id: 5,
    method: 'tools/call',
    params: {
      name: 'deploy_code',
      arguments: {
        env: 'prod',
        commit: 'abc123',
        _authorization: {
          payload: fixtures.payload,
          token: {
            ...fixtures.token,
            expires_at: Math.floor(Date.now() / 1000) - 3600 // Expired an hour ago
          }
        }
      }
    }
  };

  console.log('--- TEST 1: Missing Token ---');
  await interceptToolCall(missingTokenMessage, publicKeyPem);

  console.log('\n--- TEST 2: Mismatched Execution Args ---');
  await interceptToolCall(mismatchedArgsMessage, publicKeyPem);

  console.log('\n--- TEST 3: Invalid/Tampered Signature ---');
  await interceptToolCall(invalidTokenMessage, publicKeyPem);

  console.log('\n--- TEST 4: Expired Token ---');
  await interceptToolCall(expiredTokenMessage, publicKeyPem);

  console.log('\n--- TEST 5: Valid Signed Token ---');
  await interceptToolCall(validMessage, publicKeyPem);
}

run();
