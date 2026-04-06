import { chromium } from 'playwright';
import * as path from 'path';
import { execSync } from 'child_process';
import * as fs from 'fs';

async function generateAuth() {
  console.log('🚀 Starting interactive GitHub auth session...');
  
  // Get password from 1Password
  console.log('🔑 Fetching credentials from 1Password...');
  const password = execSync(`export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.openclaw/secrets/op-token) && op item get "GitHub" --vault "Charles on OpenClaw" --fields password --reveal`).toString().trim();

  const browser = await chromium.launch({ 
    headless: false,
    channel: 'chrome', 
    args: [
      '--disable-blink-features=AutomationControlled',
      '--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
    ]
  });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log('🌐 Navigating to GitHub login...');
  await page.goto('https://github.com/login');
  
  console.log('⌨️ Auto-filling credentials...');
  await page.fill('#login_field', 'cgoldber82');
  await page.fill('#password', password);
  await page.click('[name="commit"]');

  console.log('🔄 Waiting for GitHub dashboard...');
  console.log('⚠️ Rod: Please complete the Google/2FA login on your device.');
  
  try {
    // Wait for ANY URL that indicates we've logged in (not just the root)
    await page.waitForFunction(() => {
        return window.location.href.includes('github.com') && 
               !window.location.href.includes('/login') && 
               !window.location.href.includes('/sessions');
    }, { timeout: 600000 }); // 10 minutes
    
    const authDir = path.join(__dirname, '../.auth');
    if (!fs.existsSync(authDir)) {
      fs.mkdirSync(authDir, { recursive: true });
    }

    const statePath = path.join(authDir, 'github_state.json');
    await context.storageState({ path: statePath });
    console.log(`✅ Auth state saved to ${statePath}`);
  } catch (e) {
    console.error('❌ Failed to land on dashboard. Taking screenshot of current state...');
    await page.screenshot({ path: 'github-auth-fail.png' });
  } finally {
    await browser.close();
  }
}

generateAuth();