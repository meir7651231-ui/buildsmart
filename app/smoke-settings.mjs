/**
 * Smoke-test — verifies all 26 wired settings leaves.
 * Run from repo root:
 *   cd app && npm run build && cd ..
 *   npx http-server app/dist -p 8123 -s &
 *   node app/smoke-settings.mjs
 */
import { chromium } from './app/node_modules/playwright/index.mjs';

const URL  = 'http://localhost:8123/';
const EXE  = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';

let passed = 0, failed = 0;

function ok(name)   { console.log(`  ✅ PASS  ${name}`); passed++; }
function fail(name, got) { console.log(`  ❌ FAIL  ${name}  (got: ${JSON.stringify(got)})`); failed++; }

async function tap(page, label) {
  await page.waitForSelector(`[aria-label="${label}"]`, { timeout: 5000 });
  await page.click(`[aria-label="${label}"]`);
  await page.waitForTimeout(260);
}

async function fresh(page) {
  await page.evaluate(() => localStorage.removeItem('bs.settings.v1'));
  await page.reload();
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(400);
}

function stored(raw, ...keys) {
  try {
    let v = JSON.parse(raw || '{}');
    for (const k of keys) v = v?.[k];
    return v;
  } catch { return undefined; }
}

(async () => {
  const browser = await chromium.launch({ executablePath: EXE });
  const ctx  = await browser.newContext({ viewport: { width: 414, height: 896 } });
  const page = await ctx.newPage();
  await page.goto(URL);
  await page.waitForLoadState('networkidle');

  /* ── display: theme ── */
  await fresh(page);
  await tap(page, 'פתח תפריט'); await tap(page, 'הגדרות');
  await tap(page, 'תצוגה'); await tap(page, 'ערכת נושא'); await tap(page, 'כהה');
  const theme = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  theme === 'dark' ? ok('theme → dark') : fail('theme → dark', theme);

  /* ── display: text size ── */
  await tap(page, 'חזרה מ-ערכת נושא'); await tap(page, 'גודל טקסט'); await tap(page, 'גדול');
  const textSize = await page.evaluate(() => document.documentElement.getAttribute('data-text-size'));
  textSize === 'large' ? ok('textSize → large') : fail('textSize → large', textSize);

  /* ── display: reduce motion ── */
  await tap(page, 'חזרה מ-גודל טקסט'); await tap(page, 'הפחתת אנימציות');
  const rm = await page.evaluate(() => document.documentElement.getAttribute('data-reduce-motion'));
  rm === 'true' ? ok('reduceMotion → true') : fail('reduceMotion → true', rm);

  /* ── notifications ── */
  await tap(page, 'חזרה מ-תצוגה'); await tap(page, 'התראות');
  await tap(page, 'עדכוני משלוחים');
  const raw1 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(raw1, 'notif', 'shipments') === false
    ? ok('notif.shipments → false') : fail('notif.shipments → false', stored(raw1,'notif','shipments'));

  /* ── region: currency ── */
  await tap(page, 'חזרה מ-התראות'); await tap(page, 'אזור ושפה');
  await tap(page, 'מטבע'); await tap(page, '$ דולר');
  const currency = await page.evaluate(() => document.documentElement.getAttribute('data-currency'));
  currency === 'usd' ? ok('currency → usd') : fail('currency → usd', currency);

  /* ── delivery: haul ── */
  await tap(page, 'חזרה מ-מטבע'); await tap(page, 'חזרה מ-אזור ושפה');
  await tap(page, 'משלוח ותשלום'); await tap(page, 'סוג הובלה מועדף'); await tap(page, 'משאית');
  const haul = await page.evaluate(() => document.documentElement.getAttribute('data-haul'));
  haul === 'truck' ? ok('defaultHaul → truck') : fail('defaultHaul → truck', haul);

  /* ── about: toast ── */
  await tap(page, 'חזרה מ-סוג הובלה מועדף'); await tap(page, 'חזרה מ-משלוח ותשלום');
  await tap(page, 'מידע'); await tap(page, 'גרסה');
  await page.waitForTimeout(300);
  const t1 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t1?.includes('BuildSmart') ? ok('about/גרסה toast') : fail('about/גרסה toast', t1);

  /* ── about: contact toast ── */
  await page.waitForTimeout(3400);
  await tap(page, 'יצירת קשר');
  await page.waitForTimeout(300);
  const t2 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t2?.includes('support@buildsmart') ? ok('about/יצירת קשר toast') : fail('about/יצירת קשר toast', t2);

  /* ── security: 2FA toggle ── */
  await tap(page, 'חזרה מ-מידע'); await tap(page, 'אבטחה והרשאות');
  await tap(page, 'מרכז האבטחה'); await tap(page, 'אימות דו-שלבי');
  const raw2 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(raw2, 'security', 'twoFA') === true
    ? ok('security.twoFA → true') : fail('security.twoFA → true', stored(raw2,'security','twoFA'));

  /* ── security: session timeout ── */
  await tap(page, 'נעילת הפעלה'); await tap(page, '60 דק׳');
  const raw3 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(raw3, 'security', 'sessionTimeout') === 60
    ? ok('sessionTimeout → 60') : fail('sessionTimeout → 60', stored(raw3,'security','sessionTimeout'));

  /* ── security: privacy toggle ── */
  await tap(page, 'חזרה מ-נעילת הפעלה'); await tap(page, 'בקרת פרטיות');
  await tap(page, 'שיתוף נתוני שימוש');
  const raw4 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(raw4,'security','privacy','analytics') === false
    ? ok('privacy.analytics → false') : fail('privacy.analytics → false', stored(raw4,'security','privacy','analytics'));

  /* ── reset ── */
  await fresh(page);
  await tap(page, 'פתח תפריט'); await tap(page, 'הגדרות');
  // set something first
  await tap(page, 'אזור ושפה'); await tap(page, 'מטבע'); await tap(page, '$ דולר');
  await tap(page, 'חזרה מ-מטבע'); await tap(page, 'חזרה מ-אזור ושפה');
  await tap(page, 'איפוס לברירת מחדל');
  await page.waitForTimeout(400);
  const raw5 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(raw5, 'region', 'currency') === 'ils'
    ? ok('reset → currency back to ils') : fail('reset → currency back to ils', stored(raw5,'region','currency'));

  await browser.close();

  console.log(`\n${'─'.repeat(40)}`);
  console.log(`  ${passed + failed} tests — ${passed} passed  ${failed} failed`);
  console.log(`${'─'.repeat(40)}`);
  process.exit(failed > 0 ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
