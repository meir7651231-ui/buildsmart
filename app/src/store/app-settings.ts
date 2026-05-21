/* @legacy index.html:6749 (appSettings) + applySettings() at index.html:6974.
 * Persisted display preferences. Mirrored to <html> data-* attributes
 * by an effect() so CSS rules in tokens.css and the reduce-motion
 * override in global.css pick them up. */
import { signal, effect } from '@preact/signals';

const STORAGE_KEY = 'bs.settings.v1';

export type Theme = 'light' | 'dark';
export type TextSize = 'small' | 'medium' | 'large';

export type AppSettings = {
  display: {
    theme: Theme;
    textSize: TextSize;
    reduceMotion: boolean;
  };
};

const DEFAULTS: AppSettings = {
  display: {
    theme: 'light',
    textSize: 'medium',
    reduceMotion: false,
  },
};

function load(): AppSettings {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULTS;
    const parsed = JSON.parse(raw);
    const theme: Theme = parsed?.display?.theme === 'dark' ? 'dark' : 'light';
    const sizeRaw = parsed?.display?.textSize;
    const textSize: TextSize =
      sizeRaw === 'small' || sizeRaw === 'large' ? sizeRaw : 'medium';
    return {
      display: {
        theme,
        textSize,
        reduceMotion: Boolean(parsed?.display?.reduceMotion),
      },
    };
  } catch {
    return DEFAULTS;
  }
}

export const appSettings = signal<AppSettings>(load());

export function setTheme(t: Theme): void {
  const s = appSettings.value;
  appSettings.value = { display: { ...s.display, theme: t } };
}

export function setTextSize(sz: TextSize): void {
  const s = appSettings.value;
  appSettings.value = { display: { ...s.display, textSize: sz } };
}

export function setReduceMotion(b: boolean): void {
  const s = appSettings.value;
  appSettings.value = { display: { ...s.display, reduceMotion: b } };
}

export function toggleReduceMotion(): void {
  setReduceMotion(!appSettings.value.display.reduceMotion);
}

if (typeof document !== 'undefined') {
  effect(() => {
    const s = appSettings.value;
    const root = document.documentElement;
    root.setAttribute('data-theme', s.display.theme);
    root.setAttribute('data-text-size', s.display.textSize);
    root.setAttribute('data-reduce-motion', s.display.reduceMotion ? 'true' : 'false');
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
    } catch {
      /* storage unavailable — keep in-memory */
    }
  });
}
