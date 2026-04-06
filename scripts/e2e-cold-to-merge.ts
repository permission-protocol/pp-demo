import { chromium } from 'playwright';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

async function runE2E() {
  console.log('🚀 Starting Zero-to-Merge E2E Test...');
  const storageStatePath = path.join(__dirname, '../.auth/github_state.json');
  
  if (!fs.existsSync(storageStatePath)) {
    console.error(`❌ Missing ${storageStatePath}. Please run the auth generator first.`);
    process.exit(1);
  }

  const browser = await chromium.launch({ headless: false }); // Run visibly for debugging
  const context = await browser.newContext({ storageState: storageStatePath });
  const page = await context.newPage();

  try {
    // 1. Marketing Site
    console.log('🌐 Navigating to marketing site...');
    await page.goto('https://permissionprotocol.com');
    
    // 2. Click CTA
    console.log('🖱️ Clicking Start Free Trial / Install...');
    // We will adjust this selector based on the exact live CTA text
    await page.getByRole('link', { name: /Start Free Trial|Install/i }).first().click();

    // 3. GitHub App Install Flow
    console.log('🐙 Handling GitHub App Installation...');
    await page.waitForURL(/github\.com\/apps\/.*\/installations\/new/);
    
    console.log('⚠️ Select "pp-test-target" repo if prompted, or click Install.');
    const installButton = page.getByRole('button', { name: /Install|Authorize/i });
    if (await installButton.isVisible()) {
        await installButton.click();
    }

    // 4. Wait for redirect to Permission Protocol dashboard
    console.log('🔄 Waiting for redirect to PP dashboard...');
    await page.waitForURL(/app\.permissionprotocol\.com/);
    console.log('✅ Installation complete.');

    // 5. Simulate Dev Push
    console.log('💻 Simulating developer push & PR creation...');
    const repoDir = '/tmp/pp-test-target';
    const branchName = `e2e-test-${Date.now()}`;
    
    execSync(`
      rm -rf ${repoDir}
      git clone https://github.com/cgoldber82/pp-test-target.git ${repoDir}
      cd ${repoDir}
      git checkout -b ${branchName}
      echo "E2E Test Run: ${new Date().toISOString()}" > e2e.txt
      git add e2e.txt
      git commit -m "chore: e2e test push"
      git push origin ${branchName}
      gh pr create --title "E2E Test PR ${branchName}" --body "Automated E2E test" --head ${branchName}
    `, { stdio: 'inherit' });

    console.log('✅ PR created successfully.');

    // 6. Poll GitHub API for Blocked Status
    console.log('⏳ Waiting for Permission Protocol status check to block PR...');
    let isBlocked = false;
    for (let i = 0; i < 30; i++) {
      const status = execSync(`cd ${repoDir} && gh pr checks || true`).toString();
      if (status.includes('permission-protocol') && (status.includes('pending') || status.includes('blocked'))) {
        isBlocked = true;
        break;
      }
      await new Promise(r => setTimeout(r, 2000));
    }

    if (!isBlocked) {
      throw new Error('PR was not blocked by Permission Protocol in time.');
    }
    console.log('🔒 PR successfully blocked.');

    // 7. Approve in Dashboard
    console.log('✍️ Navigating to PP Dashboard to sign receipt...');
    await page.goto('https://app.permissionprotocol.com/dashboard');
    await page.getByText(branchName).click(); // Click the specific PR we just opened
    await page.getByRole('button', { name: /Approve/i }).click();

    // 8. Verify Merge
    console.log('⏳ Verifying PR merged...');
    await page.waitForTimeout(5000); // Give webhook time to hit GitHub
    const prStatus = execSync(`cd ${repoDir} && gh pr view --json state -q .state`).toString().trim();
    
    if (prStatus === 'MERGED') {
      console.log('🎉 E2E Test Passed: PR was successfully merged!');
    } else {
      console.error(`❌ PR State is ${prStatus}, expected MERGED.`);
    }

  } catch (error) {
    console.error('❌ E2E Test Failed:', error);
  } finally {
    await browser.close();
  }
}

runE2E();
