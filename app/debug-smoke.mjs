import { chromium } from './node_modules/playwright/index.mjs';

const SERVER_URL = 'http://localhost:8123';
const CHROMIUM_PATH = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';

const browser = await chromium.launch({
  executablePath: CHROMIUM_PATH,
  headless: true,
});

try {
  const context = await browser.newContext();
  const page = await context.newPage();

  await page.goto(SERVER_URL);
  await page.waitForLoadState('networkidle');

  console.log('\n📸 Page loaded. Looking for elements...\n');

  // Find all buttons
  const buttons = await page.locator('button').all();
  console.log(`Found ${buttons.length} buttons total\n`);

  // List first 10 buttons with their text
  for (let i = 0; i < Math.min(10, buttons.length); i++) {
    const text = await buttons[i].textContent();
    console.log(`  Button ${i}: "${text}"`);
  }

  // Look for menu button
  const menuBtn = page.locator('[aria-label*="תפריט"]').first();
  const count = await menuBtn.count();
  console.log(`\nMenu button count: ${count}`);

  if (count > 0) {
    console.log('\nClicking menu button...');
    await menuBtn.click();
    await page.waitForTimeout(1500);

    // Now look for תצוגה button
    const displayBtns = await page.locator(`button:has-text("תצוגה")`).all();
    console.log(`Found ${displayBtns.length} "תצוגה" buttons after menu open`);

    // List more buttons now
    const allButtons = await page.locator('button').all();
    console.log(`\nTotal buttons after menu: ${allButtons.length}`);
    console.log('\nFirst 20 buttons:');
    for (let i = 0; i < Math.min(20, allButtons.length); i++) {
      const text = await allButtons[i].textContent();
      console.log(`  ${i}: "${text}"`);
    }
  }

  await page.waitForTimeout(5000);
  await context.close();
} finally {
  await browser.close();
}
