import { generateTestFixtures } from './src/fixtures';
import { verifyAuthorization } from './src/verifier';

async function run() {
  const fixtures = await generateTestFixtures();
  console.log('✅ Generated Static Fixtures:');
  console.log(JSON.stringify(fixtures, null, 2));

  console.log('\n🔍 Running Verifier...');
  try {
    const isValid = await verifyAuthorization(
      fixtures.payload,
      fixtures.token,
      fixtures.publicKeyPem as string
    );
    if (isValid) {
      console.log('✅ Verification PASSED - Token and Payload bound correctly!');
    }
  } catch (err: any) {
    console.error('❌ Verification FAILED:', err.message);
  }
}

run();
