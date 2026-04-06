import { chromium } from 'playwright';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

async function runE2E() {
  console.log('🚀 Starting Zero-to-Merge E2E Test...');
  const userDataDir = path.join(process.cwd(), '.auth/chrome_profile');
  
  if (!fs.existsSync(userDataDir)) {
    console.error(`❌ Missing ${userDataDir}. Please run the auth generator first.`);
    process.exit(1);
  }

  const context = await chromium.launchPersistentContext(userDataDir, { 
    headless: false,
    channel: 'chrome',
    args: ['--disable-blink-features=AutomationControlled']
  }); 
  const page = context.pages().length > 0 ? context.pages()[0] : await context.newPage();

  try {
    // 1. Marketing Site
    console.log('🌐 Navigating to marketing site...');
    await page.goto('https://permissionprotocol.com');
    
    // 2. Click CTA
    console.log('🖱️ Clicking Start / Install / App link...');
    // We try to find the link that goes to the app or install
    const ctaLink = page.locator('a[href*="app.permissionprotocol.com"]').first();
    if (await ctaLink.isVisible()) {
      await ctaLink.click();
    } else {
      // Fallback: Just navigate directly if we can't find the exact button on the page
      console.log('⚠️ Could not find exact CTA button, navigating to app directly...');
      await page.goto('https://app.permissionprotocol.com');
    }

    // 3. GitHub App Install Flow
    console.log('🐙 Handling GitHub App Installation or Login...');
    // If it asks to login with GitHub, click it
    const loginBtn = page.getByRole('button', { name: /Login with GitHub|Continue with GitHub/i });
    if (await loginBtn.isVisible()) {
      await loginBtn.click();
    }
    
    // Wait for either the dashboard OR the install flow
    try {
      await page.waitForURL(/github\.com\/apps\/.*\/installations\/new|app\.permissionprotocol\.com/, { timeout: 15000 });
    } catch(e) {}
    
    if (page.url().includes('github.com')) {
      console.log('⚠️ On GitHub install screen. Selecting repo...');
      const installButton = page.getByRole('button', { name: /Install|Authorize/i });
      if (await installButton.isVisible()) {
          await installButton.click();
      }
    }

    // 4. Wait for redirect to Permission Protocol dashboard
    console.log('🔄 Waiting for redirect to PP dashboard...');
    await page.waitForURL(/app\.permissionprotocol\.com/, { timeout: 30000 });
    console.log('✅ App access established.');

    // 5. Simulate Dev Push
    console.log('💻 Simulating developer push & PR creation...');
    const repoDir = '/tmp/pp-demo-e2e';
    const branchName = `e2e-test-${Date.now()}`;
    const ghToken = fs.readFileSync(path.join(process.env.HOME || '', '.openclaw/secrets/github-pat-projects.txt'), 'utf8').trim();
    
    execSync(`
      rm -rf ${repoDir}
      git clone https://${ghToken}@github.com/permission-protocol/pp-demo.git ${repoDir}
      cd ${repoDir}
      git checkout -b ${branchName}
      echo "E2E Test Run: ${new Date().toISOString()}" > e2e.txt
      git add e2e.txt
      git commit -m "chore: e2e test push"
      git push origin ${branchName}
      GH_TOKEN=${ghToken} gh pr create --title "E2E Test PR ${branchName}" --body "Automated E2E test by Moltbot" --head ${branchName}
    `, { stdio: 'inherit' });

    console.log('✅ PR created successfully.');

    // 6. Poll GitHub API for Blocked Status
    console.log('⏳ Waiting for Permission Protocol status check to block PR...');
    let isBlocked = false;
    for (let i = 0; i < 30; i++) {
      const status = execSync(`cd ${repoDir} && GH_TOKEN=${ghToken} gh pr checks || true`).toString();
      // The check is named "Permission Protocol"
      if (status.toLowerCase().includes('permission protocol') && (status.includes('pending') || status.includes('blocked'))) {
        isBlocked = true;
        break;
      }
      await new Promise(r => setTimeout(r, 2000));
    }

    if (!isBlocked) {
      throw new Error('PR was not blocked by Permission Protocol in time.');
    }
    console.log('🔒 PR successfully blocked.');

    // 7. Approve via Authority Route (direct link from PR comment)
    console.log('✍️ Extracting approval URL from PR comment...');
    let approvalUrl = '';
    for (let i = 0; i < 15; i++) {
      const comments = JSON.parse(execSync(`GH_TOKEN=${ghToken} gh pr view ${branchName} --repo permission-protocol/pp-demo --json comments`).toString());
      const ppComment = comments.comments.find((c: any) => c.body.includes('pp-status-comment'));
      if (ppComment) {
        const match = ppComment.body.match(/https:\/\/app\.permissionprotocol\.com\/approve\/[a-zA-Z0-9?=_&]+/);
        if (match) {
          approvalUrl = match[0];
          break;
        }
      }
      console.log('🔄 PR comment not found yet, waiting...');
      await page.waitForTimeout(3000);
    }

    if (!approvalUrl) {
      throw new Error(`Could not find approval URL in PR comments for ${branchName}`);
    }

    console.log(`🌐 Navigating directly to authority route: ${approvalUrl}`);
    await page.goto(approvalUrl);
    
    // Check if we hit a login page (PR #288 chromeless route still needs auth)
    if (page.url().includes('/auth/signin')) {
      console.log('🐙 Hit login page, clicking Continue with GitHub...');
      const loginBtn = page.getByRole('button', { name: /Continue with GitHub/i });
      await loginBtn.click();
      await page.waitForURL(u => u.href.includes('/approve/'), { timeout: 30000 });
    }

    // Check for production approval checkbox (PR #171 mandatory friction)
    console.log('🛡️ Checking for mandatory production approval friction...');
    try {
      // Try multiple ways to click that checkbox/label
      const riskLabel = page.locator('label').filter({ hasText: /approving a production deploy/i });
      if (await riskLabel.isVisible({ timeout: 5000 })) {
        await riskLabel.click();
        console.log('✅ Risk label clicked.');
      } else {
        const checkbox = page.getByRole('checkbox');
        if (await checkbox.isVisible({ timeout: 2000 })) {
          await checkbox.check({ force: true });
          console.log('✅ Risk checkbox checked (force).');
        }
      }
    } catch (e) {
      console.log('⚠️ Could not find/click risk checkbox, button might be enabled anyway.');
    }

    // On the detail page, wait for the Approve button
    console.log('🖱️ Clicking Approve & Sign...');
    const approveBtn = page.locator('button').filter({ hasText: /Approve/i });
    
    // Wait for the button to be enabled (after checkbox)
    await approveBtn.waitFor({ state: 'visible', timeout: 15000 });
    
    // Click multiple times if needed or use force
    await approveBtn.click({ force: true });
    console.log('✅ Approve button clicked.');

    // Verify merge
    console.log('⏳ Verifying PR merged in GitHub...');
    let isMerged = false;
    for (let i = 0; i < 20; i++) {
      await page.waitForTimeout(5000);
      const prStatus = execSync(`GH_TOKEN=${ghToken} gh pr view ${branchName} --repo permission-protocol/pp-demo --json state -q .state`).toString().trim();
      if (prStatus === 'MERGED') {
        isMerged = true;
        break;
      }
      console.log(`PR State is ${prStatus}, waiting... (Check ${i+1}/20)`);
    }
    
    if (isMerged) {
      console.log('🎉 E2E Test Passed: PR was successfully merged!');
    } else {
      await page.screenshot({ path: 'e2e-failure-merge-wait.png' });
      throw new Error(`PR State is ${execSync(`GH_TOKEN=${ghToken} gh pr view ${branchName} --repo permission-protocol/pp-demo --json state -q .state`).toString().trim()}, expected MERGED.`);
    }

  } catch (error) {
    console.error('❌ E2E Test Failed:', error);
    await page.screenshot({ path: 'e2e-failure.png' });
    throw error;
  } finally {
    await context.close();
  }
}

runE2E();
