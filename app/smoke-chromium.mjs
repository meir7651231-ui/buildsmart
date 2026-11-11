/**
 * Chromium binary for the smoke scripts — resolved, never hard-coded to one revision.
 *
 * Order: $PW_CHROMIUM → newest /opt/pw-browsers/chromium-<rev>/chrome-linux{64,}/chrome
 * → undefined (Playwright launches its own bundled browser).
 *
 * The old fixed path (chromium-1194/chrome-linux) broke as soon as the image
 * moved to chromium-1243/chrome-linux64.
 */
import { existsSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

export function resolveChromium(env = process.env, root = '/opt/pw-browsers') {
  if (env.PW_CHROMIUM) return env.PW_CHROMIUM;
  let dirs;
  try { dirs = readdirSync(root); } catch { return undefined; }
  const revs = dirs
    .map(d => /^chromium-(\d+)$/.exec(d))
    .filter(Boolean)
    .sort((a, b) => Number(b[1]) - Number(a[1]));
  for (const m of revs) {
    for (const sub of ['chrome-linux64', 'chrome-linux']) {
      const exe = join(root, m[0], sub, 'chrome');
      if (existsSync(exe)) return exe;
    }
  }
  return undefined;
}
