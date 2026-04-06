import { chromium } from 'playwright';
import * as path from 'path';
import { execSync } from 'child_process';

async function generateAuth() {
  console.log('🚀 Starting manual GitHub auth session...');
  
  const password = execSync(`export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.openclaw/secrets/op-token) && op item get "GitHub" --vault "Charles on OpenClaw" --fields password --reveal`).toString().trim();

  const browser = await chromium.launch({ 
    headless: false,
    channel: 'chrome', 
    args: [
      '--disable-blink-features=AutomationControlled'
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

  console.log('🛑 Waiting indefinitely. Let me know in Discord when you hit the dashboard.');
  
  // We will expose a global function to save state when triggered manually from the REPL
  (global as any).saveStateAndExit = async () => {
    const statePath = path.join(__dirname, '../.auth/github_state.json');
    await context.storageState({ path: statePath });
    console.log(`✅ Auth state saved to ${statePath}`);
    await browser.close();
    process.exit(0);
  };
}

generateAuth();
// Keep process alive
setInterval(() => {}, 1000);