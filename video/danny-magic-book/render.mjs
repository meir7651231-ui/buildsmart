// Frame renderer: drives scene.html in headless Chromium, captures PNG frames.
// Usage:
//   node render.mjs preview 0 1.8 3.5 6.3 8 9.6 11.5   -> render sample frames at given times
//   node render.mjs all [workers]                       -> render all 360 frames
import { chromium } from 'playwright-core';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const DIR = path.dirname(fileURLToPath(import.meta.url));
const FPS = 30, DUR = 12, TOTAL = FPS * DUR;
const OUT = path.join(DIR, 'frames');
fs.mkdirSync(OUT, { recursive: true });

const mode = process.argv[2] || 'preview';

async function makePage(browser) {
  const page = await browser.newPage({ viewport: { width: 400, height: 700 } });
  page.on('pageerror', e => { console.error('PAGE ERROR:', e.message); process.exitCode = 1; });
  page.on('console', m => { if (m.type() === 'error') console.error('CONSOLE:', m.text()); });
  await page.goto('file://' + path.join(DIR, 'scene.html'));
  await page.waitForFunction('window.SCENE_READY === true', null, { timeout: 30000 });
  return page;
}

function saveDataUrl(dataUrl, file) {
  fs.writeFileSync(file, Buffer.from(dataUrl.slice('data:image/png;base64,'.length), 'base64'));
}

const browser = await chromium.launch({
  executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
  args: ['--no-sandbox', '--disable-dev-shm-usage', '--allow-file-access-from-files'],
});

if (mode === 'preview') {
  const times = process.argv.slice(3).map(Number);
  const page = await makePage(browser);
  for (const t of times) {
    const url = await page.evaluate(tt => window.captureFrame(tt), t);
    const f = path.join(OUT, `preview_${t.toFixed(2).replace('.', '_')}.png`);
    saveDataUrl(url, f);
    console.log('wrote', f);
  }
} else {
  const workers = Number(process.argv[3] || 4);
  const chunk = Math.ceil(TOTAL / workers);
  const t0 = Date.now();
  let done = 0;
  await Promise.all(Array.from({ length: workers }, async (_, w) => {
    const page = await makePage(browser);
    const start = w * chunk, end = Math.min(TOTAL, start + chunk);
    for (let i = start; i < end; i++) {
      const url = await page.evaluate(tt => window.captureFrame(tt), i / FPS);
      saveDataUrl(url, path.join(OUT, `f${String(i).padStart(4, '0')}.png`));
      if (++done % 30 === 0) console.log(`${done}/${TOTAL} frames  (${((Date.now() - t0) / 1000).toFixed(0)}s)`);
    }
    await page.close();
  }));
  console.log(`DONE ${TOTAL} frames in ${((Date.now() - t0) / 1000).toFixed(0)}s`);
}
await browser.close();
