import { chromium } from './node_modules/playwright/index.mjs';

const SERVER_URL = 'http://localhost:8123';
const CHROMIUM_PATH = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';

let results = [];

async function runTest(name, testFn) {
  try {
    await testFn();
    results.push({ name, status: 'PASS' });
    console.log(`✅ ${name}`);
  } catch (err) {
    results.push({ name, status: 'FAIL', error: err.message });
    console.log(`❌ ${name}: ${err.message}`);
  }
}

// Helper to wait for selector
async function waitForButton(page, text, timeout = 10000) {
  return page.locator(`button:has-text("${text}")`).first().waitFor({ timeout });
}

// Helper: clear localStorage and reload
async function resetPage(page) {
  await page.goto(SERVER_URL);
  await page.waitForLoadState('networkidle');
  await page.evaluate(() => {
    try {
      localStorage.removeItem('bs.settings.v1');
    } catch (e) {}
  });
  await page.reload();
  await page.waitForLoadState('networkidle');
}

async function openMenu(page) {
  const menuBtn = page.locator('[aria-label*="תפריט"]').first();
  await menuBtn.waitFor({ timeout: 5000 });
  await menuBtn.click();
  await page.waitForTimeout(500);
}

async function test1_DarkTheme(page) {
  await resetPage(page);
  await openMenu(page);

  // Navigate through menu tree
  const displayBtn = page.locator(`button:has-text("תצוגה")`).first();
  await displayBtn.waitFor({ timeout: 5000 });
  await displayBtn.click();
  await page.waitForTimeout(300);

  const themeBtn = page.locator(`button:has-text("ערכת נושא")`).first();
  await themeBtn.waitFor({ timeout: 5000 });
  await themeBtn.click();
  await page.waitForTimeout(300);

  const darkBtn = page.locator(`button:has-text("כהה")`).first();
  await darkBtn.waitFor({ timeout: 5000 });
  await darkBtn.click();
  await page.waitForTimeout(800);

  const theme = await page.locator('html').getAttribute('data-theme');
  if (theme !== 'dark') throw new Error(`Expected data-theme="dark", got "${theme}"`);
}

async function test2_LargeText(page) {
  await resetPage(page);
  await openMenu(page);

  await page.locator(`button:has-text("תצוגה")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("תצוגה")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("גודל טקסט")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("גודל טקסט")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("גדול")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("גדול")`).first().click();
  await page.waitForTimeout(800);

  const textSize = await page.locator('html').getAttribute('data-text-size');
  if (textSize !== 'large') throw new Error(`Expected data-text-size="large", got "${textSize}"`);
}

async function test3_ReduceMotion(page) {
  await resetPage(page);
  await openMenu(page);

  await page.locator(`button:has-text("תצוגה")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("תצוגה")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("הפחתת אנימציות")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("הפחתת אנימציות")`).first().click();
  await page.waitForTimeout(800);

  const reduceMotion = await page.locator('html').getAttribute('data-reduce-motion');
  if (reduceMotion !== 'true') throw new Error(`Expected data-reduce-motion="true", got "${reduceMotion}"`);
}

async function test4_NotificationsToggle(page) {
  await resetPage(page);
  await openMenu(page);

  await page.locator(`button:has-text("התראות")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("התראות")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("עדכוני משלוחים")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("עדכוני משלוחים")`).first().click();
  await page.waitForTimeout(800);

  const settings = await page.evaluate(() => {
    try {
      const s = localStorage.getItem('bs.settings.v1');
      return s ? JSON.parse(s) : null;
    } catch { return null; }
  });

  if (!settings || settings.notif?.shipments !== false) {
    throw new Error(`Expected notif.shipments=false, got ${settings?.notif?.shipments}`);
  }
}

async function test5_CurrencyUSD(page) {
  await resetPage(page);
  await openMenu(page);

  await page.locator(`button:has-text("אזור ושפה")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("אזור ושפה")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("מטבע")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("מטבע")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("$ דולר")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("$ דולר")`).first().click();
  await page.waitForTimeout(800);

  const currency = await page.locator('html').getAttribute('data-currency');
  if (currency !== 'usd') throw new Error(`Expected data-currency="usd", got "${currency}"`);
}

async function test6_AboutVersion(page) {
  await resetPage(page);
  await openMenu(page);

  await page.locator(`button:has-text("מידע")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("מידע")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("גרסה")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("גרסה")`).first().click();
  await page.waitForTimeout(800);

  const toast = page.locator('[role="status"]').first();
  await toast.waitFor({ timeout: 5000 });
  const text = await toast.textContent();
  if (!text?.includes('BuildSmart') || !text?.includes('אב-טיפוס')) {
    throw new Error(`Toast should contain BuildSmart version`);
  }
}

async function test7_AboutContact(page) {
  await resetPage(page);
  await openMenu(page);

  await page.locator(`button:has-text("מידע")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("מידע")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("יצירת קשר")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("יצירת קשר")`).first().click();
  await page.waitForTimeout(800);

  const toast = page.locator('[role="status"]').first();
  await toast.waitFor({ timeout: 5000 });
  const text = await toast.textContent();
  if (!text?.includes('support@buildsmart.demo')) {
    throw new Error(`Toast should contain support email`);
  }
}

async function test8_ResetDefaults(page) {
  await page.goto(SERVER_URL);
  await page.waitForLoadState('networkidle');

  // Set dark theme
  await openMenu(page);
  await page.locator(`button:has-text("תצוגה")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("תצוגה")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("ערכת נושא")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("ערכת נושא")`).first().click();
  await page.waitForTimeout(300);

  await page.locator(`button:has-text("כהה")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("כהה")`).first().click();
  await page.waitForTimeout(800);

  // Reset
  await openMenu(page);
  await page.locator(`button:has-text("איפוס לברירת מחדל")`).first().waitFor({ timeout: 5000 });
  await page.locator(`button:has-text("איפוס לברירת מחדל")`).first().click();
  await page.waitForTimeout(1000);

  const theme = await page.locator('html').getAttribute('data-theme');
  if (theme !== 'light') throw new Error(`After reset, theme should be "light", got "${theme}"`);
}

async function main() {
  const browser = await chromium.launch({
    executablePath: CHROMIUM_PATH,
    headless: true,
  });

  try {
    const context = await browser.newContext();
    const page = await context.newPage();

    // Test connection
    try {
      await page.goto(SERVER_URL, { waitUntil: 'networkidle', timeout: 10000 });
    } catch (err) {
      throw new Error(`Cannot reach ${SERVER_URL}: ${err.message}`);
    }

    console.log('\n🧪 Smoke Tests — Settings Leaves (26 items)\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    await runTest('1️⃣ תצוגה → ערכת נושא → כהה', () => test1_DarkTheme(page));
    await runTest('2️⃣ תצוגה → גודל טקסט → גדול', () => test2_LargeText(page));
    await runTest('3️⃣ תצוגה → הפחתת אנימציות', () => test3_ReduceMotion(page));
    await runTest('4️⃣ התראות → עדכוני משלוחים (toggle)', () => test4_NotificationsToggle(page));
    await runTest('5️⃣ אזור ושפה → מטבע → $ דולר', () => test5_CurrencyUSD(page));
    await runTest('6️⃣ מידע → גרסה', () => test6_AboutVersion(page));
    await runTest('7️⃣ מידע → יצירת קשר', () => test7_AboutContact(page));
    await runTest('8️⃣ איפוס לברירת מחדל', () => test8_ResetDefaults(page));

    await context.close();
  } finally {
    await browser.close();
  }

  // Summary
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = results.filter(r => r.status === 'FAIL').length;
  console.log(`📊 Results: ${passed} PASS, ${failed} FAIL (out of ${results.length})`);

  if (failed > 0) {
    console.log('\n❌ Failures:\n');
    results.filter(r => r.status === 'FAIL').forEach(r => {
      console.log(`  • ${r.name}\n    ${r.error}\n`);
    });
    process.exit(1);
  } else {
    console.log('\n✅ All smoke tests passed!\n');
    process.exit(0);
  }
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
