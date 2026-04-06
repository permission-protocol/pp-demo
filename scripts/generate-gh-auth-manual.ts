import { chromium } from 'playwright';
import * as path from 'path';
import { execSync } from 'child_process';

async function generateAuth() {
  console.log('🚀 Starting manual GitHub auth session...');
  
  const password = execSync(`export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.openclaw/secrets/op-token) && op item get "GitHub" --vault "Charles on OpenClaw" --fields password --reveal`).toString().trim();

  const userDataDir = path.join(process.cwd(), '.auth/chrome_profile');
  
  const context = await chromium.launchPersistentContext(userDataDir, { 
    headless: false,
    channel: 'chrome', 
    args: [
      '--disable-blink-features=AutomationControlled'
    ]
  });
  
  const page = context.pages().length > 0 ? context.pages()[0] : await context.newPage();

  console.log('🌐 Navigating to GitHub login...');
  await page.goto('https://github.com/login');
  
  console.log('⌨️ Auto-filling credentials...');
  await page.fill('#login_field', 'cgoldber82');
  await page.fill('#password', password);
  await page.click('[name="commit"]');

  console.log('🛑 Waiting indefinitely. Let me know in Discord when you hit the dashboard.');
  
  // We will expose a global function to save state when triggered manually from the REPL
  (global as any).saveAndExit = async () => {
    console.log('✅ Manual trigger received. Closing...');
    await context.close();
    process.exit(0);
  };
}

generateAuth();
// Keep process alive
setInterval(() => {}, 1000);