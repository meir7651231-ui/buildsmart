import { signal, effect } from '@preact/signals';

export const bsOpen = signal(false);

export function toggleBs(): void {
  bsOpen.value = !bsOpen.value;
}
export function closeBs(): void {
  bsOpen.value = false;
}

export type BsToolKind = 'home' | 'theme' | 'language' | 'help';
export const bsActiveTool = signal<BsToolKind | null>(null);

export function setBsTool(t: BsToolKind | null): void {
  bsActiveTool.value = t;
}

/* ===== Theme ===== */
export type ThemeMode = 'light' | 'dark' | 'auto';
const THEME_KEY = 'bs.theme.v1';

function loadTheme(): ThemeMode {
  try {
    const raw = localStorage.getItem(THEME_KEY);
    if (raw === 'light' || raw === 'dark' || raw === 'auto') return raw;
  } catch {
    /* ignore */
  }
  return 'light';
}

export const theme = signal<ThemeMode>(loadTheme());

export function setTheme(t: ThemeMode): void {
  theme.value = t;
  try {
    localStorage.setItem(THEME_KEY, t);
  } catch {
    /* ignore */
  }
}

effect(() => {
  const m = theme.value;
  const root = document.documentElement;
  if (m === 'auto') {
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    root.dataset.theme = mq.matches ? 'dark' : 'light';
  } else {
    root.dataset.theme = m;
  }
});

/* ===== Language ===== */
export type Language = 'he' | 'en' | 'ar';
const LANG_KEY = 'bs.lang.v1';

function loadLang(): Language {
  try {
    const raw = localStorage.getItem(LANG_KEY);
    if (raw === 'he' || raw === 'en' || raw === 'ar') return raw;
  } catch {
    /* ignore */
  }
  return 'he';
}

export const language = signal<Language>(loadLang());

export function setLanguage(l: Language): void {
  language.value = l;
  try {
    localStorage.setItem(LANG_KEY, l);
  } catch {
    /* ignore */
  }
}
