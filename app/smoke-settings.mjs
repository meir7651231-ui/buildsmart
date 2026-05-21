/**
 * Smoke-test — verifies wired settings leaves end-to-end.
 *
 * Coverage:
 *   display · notifications · region · delivery · about · security ·
 *   support · account · payment · reset
 *
 * Run from repo root:
 *   cd app && npm run build && cd ..
 *   npx http-server app/dist -p 8123 -s &
 *   node app/smoke-settings.mjs
 */
import { chromium } from './node_modules/playwright/index.mjs';

const URL = 'http://localhost:8123/';
const EXE = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';

let passed = 0, failed = 0;
function ok(n)         { console.log(`  ✅ PASS  ${n}`); passed++; }
function fail(n, got)  { console.log(`  ❌ FAIL  ${n}  (got: ${JSON.stringify(got)})`); failed++; }

async function tap(page, label) {
  await page.waitForSelector(`[aria-label="${label}"]`, { timeout: 5000 });
  await page.click(`[aria-label="${label}"]`);
  await page.waitForTimeout(260);
}

async function fresh(page) {
  await page.evaluate(() => {
    localStorage.removeItem('bs.settings.v1');
    localStorage.removeItem('bs.profile.v1');
  });
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
  const ctx = await browser.newContext({ viewport: { width: 414, height: 896 } });
  const page = await ctx.newPage();
  await page.goto(URL);
  await page.waitForLoadState('networkidle');

  /* ───────── DISPLAY ───────── */
  await fresh(page);
  await tap(page, 'פתח תפריט'); await tap(page, 'הגדרות');
  await tap(page, 'תצוגה'); await tap(page, 'ערכת נושא'); await tap(page, 'כהה');
  const theme = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
  theme === 'dark' ? ok('theme → dark') : fail('theme → dark', theme);

  await tap(page, 'חזרה מ-ערכת נושא'); await tap(page, 'גודל טקסט'); await tap(page, 'גדול');
  const ts = await page.evaluate(() => document.documentElement.getAttribute('data-text-size'));
  ts === 'large' ? ok('textSize → large') : fail('textSize → large', ts);

  await tap(page, 'חזרה מ-גודל טקסט'); await tap(page, 'הפחתת אנימציות');
  const rm = await page.evaluate(() => document.documentElement.getAttribute('data-reduce-motion'));
  rm === 'true' ? ok('reduceMotion → true') : fail('reduceMotion → true', rm);

  /* ───────── NOTIFICATIONS ───────── */
  await tap(page, 'חזרה מ-תצוגה'); await tap(page, 'התראות');
  await tap(page, 'עדכוני משלוחים');
  const r1 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(r1, 'notif', 'shipments') === false
    ? ok('notif.shipments → false') : fail('notif.shipments → false', stored(r1, 'notif', 'shipments'));

  /* ───────── REGION ───────── */
  await tap(page, 'חזרה מ-התראות'); await tap(page, 'אזור ושפה');
  await tap(page, 'מטבע'); await tap(page, '$ דולר');
  const cur = await page.evaluate(() => document.documentElement.getAttribute('data-currency'));
  cur === 'usd' ? ok('currency → usd') : fail('currency → usd', cur);

  /* ───────── DELIVERY ───────── */
  await tap(page, 'חזרה מ-מטבע'); await tap(page, 'חזרה מ-אזור ושפה');
  await tap(page, 'משלוח ותשלום'); await tap(page, 'סוג הובלה מועדף'); await tap(page, 'משאית');
  const haul = await page.evaluate(() => document.documentElement.getAttribute('data-haul'));
  haul === 'truck' ? ok('defaultHaul → truck') : fail('defaultHaul → truck', haul);

  /* ───────── PAYMENT (R9 inline input) ───────── */
  await tap(page, 'חזרה מ-סוג הובלה מועדף');
  await tap(page, 'אמצעי תשלום');
  await page.fill('input.dial__input', 'אשראי');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(300);
  const pay = await page.evaluate(() => JSON.parse(localStorage.getItem('bs.profile.v1') || '{}').payment);
  pay === 'אשראי' ? ok('payment → אשראי (R9)') : fail('payment → אשראי', pay);

  /* ───────── ABOUT ───────── */
  await tap(page, 'חזרה מ-משלוח ותשלום'); await tap(page, 'מידע'); await tap(page, 'גרסה');
  await page.waitForTimeout(300);
  const t1 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t1?.includes('BuildSmart') ? ok('about/גרסה toast') : fail('about/גרסה toast', t1);

  await page.waitForTimeout(3400);
  await tap(page, 'יצירת קשר');
  await page.waitForTimeout(300);
  const t2 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t2?.includes('support@buildsmart') ? ok('about/יצירת קשר toast') : fail('about/יצירת קשר toast', t2);

  /* ───────── SECURITY ───────── */
  await tap(page, 'חזרה מ-מידע'); await tap(page, 'אבטחה והרשאות');
  await tap(page, 'מרכז האבטחה'); await tap(page, 'אימות דו-שלבי');
  const r2 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(r2, 'security', 'twoFA') === true
    ? ok('security.twoFA → true') : fail('security.twoFA → true', stored(r2, 'security', 'twoFA'));

  await tap(page, 'נעילת הפעלה'); await tap(page, '60 דק׳');
  const r3 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(r3, 'security', 'sessionTimeout') === 60
    ? ok('sessionTimeout → 60') : fail('sessionTimeout → 60', stored(r3, 'security', 'sessionTimeout'));

  await tap(page, 'חזרה מ-נעילת הפעלה'); await tap(page, 'בקרת פרטיות');
  await tap(page, 'שיתוף נתוני שימוש');
  const r4 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(r4, 'security', 'privacy', 'analytics') === false
    ? ok('privacy.analytics → false') : fail('privacy.analytics → false', stored(r4, 'security', 'privacy', 'analytics'));

  await tap(page, 'חזרה מ-בקרת פרטיות'); await tap(page, 'הצפנת נתונים');
  await tap(page, 'תקשורת מוצפנת (HTTPS/TLS)');
  await page.waitForTimeout(300);
  const t3 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t3?.includes('HTTPS') ? ok('encryption toast') : fail('encryption toast', t3);

  await page.waitForTimeout(3400);
  await tap(page, 'חזרה מ-הצפנת נתונים'); await tap(page, 'הרשאות גישה');
  await tap(page, 'קבלן');
  await page.waitForTimeout(300);
  const t4 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t4?.includes('קבלן') ? ok('RBAC קבלן toast') : fail('RBAC קבלן toast', t4);

  /* ───────── SUPPORT ───────── */
  await page.waitForTimeout(3400);
  await tap(page, 'חזרה מ-הרשאות גישה'); await tap(page, 'חזרה מ-מרכז האבטחה');
  await tap(page, 'חזרה מ-אבטחה והרשאות');
  await tap(page, 'שירות ותמיכה'); await tap(page, 'מרכז השירות');
  await tap(page, 'מוקד תמיכה');
  await page.waitForTimeout(300);
  const t5 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t5?.includes('מוקד תמיכה') ? ok('support/מוקד תמיכה toast') : fail('support/מוקד תמיכה toast', t5);

  await page.waitForTimeout(3400);
  await tap(page, 'מחשבון כמויות'); await tap(page, 'בטון');
  await page.waitForTimeout(300);
  const t6 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t6?.includes('בטון') ? ok('support/מחשבון/בטון toast') : fail('support/מחשבון/בטון toast', t6);

  await page.waitForTimeout(3400);
  await tap(page, 'חזרה מ-מחשבון כמויות');
  await tap(page, 'סיור היכרות'); await tap(page, 'מסך הבית');
  await page.waitForTimeout(300);
  const t7 = await page.evaluate(() => document.querySelector('.toast')?.textContent?.trim());
  t7?.includes('חיפוש מהיר') ? ok('support/סיור/מסך הבית toast') : fail('support/סיור/מסך הבית toast', t7);

  /* ───────── ACCOUNT (R9 inline input — 4 fields) ───────── */
  await page.waitForTimeout(3400);
  await tap(page, 'חזרה מ-סיור היכרות'); await tap(page, 'חזרה מ-מרכז השירות');
  await tap(page, 'חזרה מ-שירות ותמיכה');
  await tap(page, 'חשבון');

  await tap(page, 'שם הקבלן');
  await page.fill('input.dial__input', 'אבי');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(300);
  const pn = await page.evaluate(() => JSON.parse(localStorage.getItem('bs.profile.v1') || '{}').name);
  pn === 'אבי' ? ok('account.name → אבי (R9)') : fail('account.name → אבי', pn);

  await page.waitForTimeout(3400);
  await tap(page, 'טלפון');
  await page.fill('input.dial__input', '054-1234567');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(300);
  const pp = await page.evaluate(() => JSON.parse(localStorage.getItem('bs.profile.v1') || '{}').phone);
  pp === '054-1234567' ? ok('account.phone → 054-… (R9)') : fail('account.phone', pp);

  // Esc cancellation
  await tap(page, 'סוג עוסק');
  await page.fill('input.dial__input', 'עוסק פטור');
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  const pb = await page.evaluate(() => JSON.parse(localStorage.getItem('bs.profile.v1') || '{}').business);
  pb === '' ? ok('Esc cancels (business not saved)') : fail('Esc cancel', pb);

  /* ───────── RESET ───────── */
  await fresh(page);
  await tap(page, 'פתח תפריט'); await tap(page, 'הגדרות');
  await tap(page, 'אזור ושפה'); await tap(page, 'מטבע'); await tap(page, '$ דולר');
  await tap(page, 'חזרה מ-מטבע'); await tap(page, 'חזרה מ-אזור ושפה');
  await tap(page, 'איפוס לברירת מחדל');
  await page.waitForTimeout(400);
  const r5 = await page.evaluate(() => localStorage.getItem('bs.settings.v1'));
  stored(r5, 'region', 'currency') === 'ils'
    ? ok('reset → currency back to ils') : fail('reset → currency back to ils', stored(r5, 'region', 'currency'));

  await browser.close();

  console.log(`\n${'─'.repeat(40)}`);
  console.log(`  ${passed + failed} tests — ${passed} passed  ${failed} failed`);
  console.log(`${'─'.repeat(40)}`);
  process.exit(failed > 0 ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
