import { chromium } from 'playwright';
import * as path from 'path';
import { execSync } from 'child_process';
import * as fs from 'fs';

async function generateAuth() {
  console.log('🚀 Starting interactive GitHub auth session...');
  
  // Get password from 1Password
  console.log('🔑 Fetching credentials from 1Password...');
  const password = execSync(`export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.openclaw/secrets/op-token) && op item get "GitHub" --vault "Charles on OpenClaw" --fields password --reveal`).toString().trim();

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log('🌐 Navigating to GitHub login...');
  await page.goto('https://github.com/login');
  
  console.log('⌨️ Auto-filling credentials...');
  await page.fill('#login_field', 'cgoldber82');
  await page.fill('#password', password);
  await page.click('[name="commit"]');

  console.log('⚠️ Waiting for 2FA to complete. (Rod, please approve on your device or screen!)');
  
  // Wait for successful login redirect
  await page.waitForURL('https://github.com/', { timeout: 120000 }); // 2 minutes for 2FA
  
  const authDir = path.join(__dirname, '../.auth');
  if (!fs.existsSync(authDir)) {
    fs.mkdirSync(authDir, { recursive: true });
  }

  const statePath = path.join(authDir, 'github_state.json');
  await context.storageState({ path: statePath });
  console.log(`✅ Auth state saved to ${statePath}`);

  await browser.close();
}

generateAuth();