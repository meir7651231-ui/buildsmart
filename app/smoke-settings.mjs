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
  const menuBtn = page.locator('button[aria-label*="תפריט"]').first();
  await menuBtn.waitFor({ timeout: 5000 });
  await menuBtn.click();
  await page.waitForTimeout(900);

  const settingsTab = page.locator('button[aria-label="הגדרות"]:visible').first();
  await settingsTab.waitFor({ timeout: 5000 });
  await settingsTab.click();
  await page.waitForTimeout(900);
}

async function test1_DarkTheme(page) {
  await resetPage(page);
  await openMenu(page);

  const displayBtn = page.locator('button[aria-label="תצוגה"]:visible').first();
  await displayBtn.waitFor({ timeout: 5000 });
  await displayBtn.click();
  await page.waitForTimeout(600);

  const themeBtn = page.locator('button[aria-label="ערכת נושא"]:visible').first();
  await themeBtn.waitFor({ timeout: 5000 });
  await themeBtn.click();
  await page.waitForTimeout(600);

  const darkBtn = page.locator('button[aria-label="כהה"]:visible').first();
  await darkBtn.waitFor({ timeout: 5000 });
  await darkBtn.click();
  await page.waitForTimeout(800);

  const theme = await page.locator('html').getAttribute('data-theme');
  if (theme !== 'dark') throw new Error(`Expected data-theme="dark", got "${theme}"`);
}

async function test2_LargeText(page) {
  await resetPage(page);
  await openMenu(page);

  const displayBtn = page.locator('button[aria-label="תצוגה"]:visible').first();
  await displayBtn.waitFor({ timeout: 5000 });
  await displayBtn.click();
  await page.waitForTimeout(600);

  const textSizeBtn = page.locator('button[aria-label="גודל טקסט"]:visible').first();
  await textSizeBtn.waitFor({ timeout: 5000 });
  await textSizeBtn.click();
  await page.waitForTimeout(600);

  const largeBtn = page.locator('button[aria-label="גדול"]:visible').first();
  await largeBtn.waitFor({ timeout: 5000 });
  await largeBtn.click();
  await page.waitForTimeout(800);

  const textSize = await page.locator('html').getAttribute('data-text-size');
  if (textSize !== 'large') throw new Error(`Expected data-text-size="large", got "${textSize}"`);
}

async function test3_ReduceMotion(page) {
  await resetPage(page);
  await openMenu(page);

  const displayBtn = page.locator('button[aria-label="תצוגה"]:visible').first();
  await displayBtn.waitFor({ timeout: 5000 });
  await displayBtn.click();
  await page.waitForTimeout(600);

  const reduceMotionBtn = page.locator('button[aria-label="הפחתת אנימציות"]:visible').first();
  await reduceMotionBtn.waitFor({ timeout: 5000 });
  await reduceMotionBtn.click();
  await page.waitForTimeout(800);

  const reduceMotion = await page.locator('html').getAttribute('data-reduce-motion');
  if (reduceMotion !== 'true') throw new Error(`Expected data-reduce-motion="true", got "${reduceMotion}"`);
}

async function test4_NotificationsToggle(page) {
  await resetPage(page);
  await openMenu(page);

  const notifBtn = page.locator('button[aria-label="התראות"]:visible').first();
  await notifBtn.waitFor({ timeout: 5000 });
  await notifBtn.click();
  await page.waitForTimeout(600);

  const shipmentsBtn = page.locator('button[aria-label="עדכוני משלוחים"]:visible').first();
  await shipmentsBtn.waitFor({ timeout: 5000 });
  await shipmentsBtn.click();
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

  const regionBtn = page.locator('button[aria-label="אזור ושפה"]:visible').first();
  await regionBtn.waitFor({ timeout: 5000 });
  await regionBtn.click();
  await page.waitForTimeout(600);

  const currencyBtn = page.locator('button[aria-label="מטבע"]:visible').first();
  await currencyBtn.waitFor({ timeout: 5000 });
  await currencyBtn.click();
  await page.waitForTimeout(600);

  const usdBtn = page.locator('button[aria-label="$ דולר"]:visible').first();
  await usdBtn.waitFor({ timeout: 5000 });
  await usdBtn.click();
  await page.waitForTimeout(800);

  const currency = await page.locator('html').getAttribute('data-currency');
  if (currency !== 'usd') throw new Error(`Expected data-currency="usd", got "${currency}"`);
}

async function test6_AboutVersion(page) {
  await resetPage(page);
  await openMenu(page);

  const aboutBtn = page.locator('button[aria-label="מידע"]:visible').first();
  await aboutBtn.waitFor({ timeout: 5000 });
  await aboutBtn.click();
  await page.waitForTimeout(600);

  const versionBtn = page.locator('button[aria-label="גרסה"]:visible').first();
  await versionBtn.waitFor({ timeout: 5000 });
  await versionBtn.click();
  // Just ensure the button click works without throwing
  await page.waitForTimeout(600);
}

async function test7_AboutContact(page) {
  await resetPage(page);
  await openMenu(page);

  const aboutBtn = page.locator('button[aria-label="מידע"]:visible').first();
  await aboutBtn.waitFor({ timeout: 5000 });
  await aboutBtn.click();
  await page.waitForTimeout(600);

  const contactBtn = page.locator('button[aria-label="יצירת קשר"]:visible').first();
  await contactBtn.waitFor({ timeout: 5000 });
  await contactBtn.click();
  // Just ensure the button click works without throwing
  await page.waitForTimeout(600);
}

async function test8_ResetDefaults(page) {
  await resetPage(page);

  await openMenu(page);
  const displayBtn = page.locator('button[aria-label="תצוגה"]:visible').first();
  await displayBtn.waitFor({ timeout: 5000 });
  await displayBtn.click();
  await page.waitForTimeout(600);

  const themeBtn = page.locator('button[aria-label="ערכת נושא"]:visible').first();
  await themeBtn.waitFor({ timeout: 5000 });
  await themeBtn.click();
  await page.waitForTimeout(600);

  const darkBtn = page.locator('button[aria-label="כהה"]:visible').first();
  await darkBtn.waitFor({ timeout: 5000 });
  await darkBtn.click();
  await page.waitForTimeout(800);

  const menuBtn = page.locator('button[aria-label*="תפריט"]').first();
  await menuBtn.click();
  await page.waitForTimeout(600);

  await menuBtn.click();
  await page.waitForTimeout(900);

  const settingsTab = page.locator('button[aria-label="הגדרות"]:visible').first();
  await settingsTab.waitFor({ timeout: 5000 });
  await settingsTab.click();
  await page.waitForTimeout(900);

  const resetBtn = page.locator('button[aria-label="איפוס לברירת מחדל"]:visible').first();
  await resetBtn.waitFor({ timeout: 5000 });
  await resetBtn.click();
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

    try {
      await page.goto(SERVER_URL, { waitUntil: 'networkidle', timeout: 10000 });
    } catch (err) {
      throw new Error(`Cannot reach ${SERVER_URL}: ${err.message}`);
    }

    console.log('\n🧪 Smoke Tests — Settings Menu Navigation\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    await runTest('1️⃣ תצוגה → ערכת נושא → כהה', () => test1_DarkTheme(page));
    await runTest('2️⃣ תצוגה → גודל טקסט → גדול', () => test2_LargeText(page));
    await runTest('3️⃣ תצוגה → הפחתת אנימציות', () => test3_ReduceMotion(page));
    await runTest('4️⃣ התראות → עדכוני משלוחים', () => test4_NotificationsToggle(page));
    await runTest('5️⃣ אזור ושפה → מטבע → USD', () => test5_CurrencyUSD(page));
    await runTest('6️⃣ מידע → גרסה (button click)', () => test6_AboutVersion(page));
    await runTest('7️⃣ מידע → יצירת קשר (button click)', () => test7_AboutContact(page));
    await runTest('8️⃣ איפוס לברירת מחדל', () => test8_ResetDefaults(page));

    await context.close();
  } finally {
    await browser.close();
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = results.filter(r => r.status === 'FAIL').length;
  console.log(`📊 Results: ${passed} PASS, ${failed} FAIL (out of ${results.length})\n`);

  if (failed > 0) {
    console.log('❌ Failures:');
    results.filter(r => r.status === 'FAIL').forEach(r => {
      console.log(`  • ${r.name}: ${r.error}`);
    });
    process.exit(1);
  } else {
    console.log('✅ All tests passed!\n');
    process.exit(0);
  }
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
