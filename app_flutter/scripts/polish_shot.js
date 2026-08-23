// Polish screenshot — Playwright headless chromium shot of the Flutter web build.
// ignoreHTTPSErrors: the sandbox proxies external hosts with an untrusted cert.
// Args: <url> <out.png> [waitMs]
const { chromium } = require('playwright');

const URL = process.argv[2] || 'http://localhost:8099/';
const OUT = process.argv[3] || '/tmp/polish/app.png';
const WAIT = parseInt(process.argv[4] || '13000', 10);

(async () => {
  const browser = await chromium.launch({
    args: ['--no-sandbox', '--disable-gpu', '--ignore-certificate-errors'],
  });
  const context = await browser.newContext({
    ignoreHTTPSErrors: true,
    viewport: { width: 412, height: 915 },
    deviceScaleFactor: 2,
  });
  const page = await context.newPage();
  page.on('pageerror', e => console.log('  [pageerror]', e.message));
  await page.goto(URL, { waitUntil: 'load', timeout: 60000 });
  await page.waitForTimeout(WAIT); // canvaskit paints after load
  await page.screenshot({ path: OUT });
  await browser.close();
  console.log('OK screenshot →', OUT);
})().catch(e => { console.error('FAIL', e); process.exit(1); });
