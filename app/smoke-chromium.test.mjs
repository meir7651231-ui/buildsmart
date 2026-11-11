// node --test app/smoke-chromium.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { resolveChromium } from './smoke-chromium.mjs';

function fakeRoot(layout) {
  const root = mkdtempSync(join(tmpdir(), 'pw-'));
  for (const rel of layout) {
    const full = join(root, rel);
    mkdirSync(join(full, '..'), { recursive: true });
    writeFileSync(full, '');
  }
  return root;
}

test('PW_CHROMIUM wins over anything on disk', () => {
  const root = fakeRoot(['chromium-1243/chrome-linux64/chrome']);
  assert.equal(resolveChromium({ PW_CHROMIUM: '/x/chrome' }, root), '/x/chrome');
});

test('picks the newest revision, chrome-linux64 layout', () => {
  const root = fakeRoot([
    'chromium-1194/chrome-linux/chrome',
    'chromium-1243/chrome-linux64/chrome',
  ]);
  assert.equal(resolveChromium({}, root), join(root, 'chromium-1243/chrome-linux64/chrome'));
});

test('falls back to the legacy chrome-linux layout', () => {
  const root = fakeRoot(['chromium-1194/chrome-linux/chrome']);
  assert.equal(resolveChromium({}, root), join(root, 'chromium-1194/chrome-linux/chrome'));
});

test('ignores headless-shell and revisions with no binary', () => {
  const root = fakeRoot([
    'chromium_headless_shell-1300/chrome-linux/headless_shell',
    'chromium-1300/INSTALLATION_COMPLETE',
    'chromium-1243/chrome-linux64/chrome',
  ]);
  assert.equal(resolveChromium({}, root), join(root, 'chromium-1243/chrome-linux64/chrome'));
});

test('missing root → undefined (Playwright default browser)', () => {
  assert.equal(resolveChromium({}, '/nonexistent/pw-browsers'), undefined);
});
