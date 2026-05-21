/* @legacy index.html:6749 (appSettings) + resetSettings() at 6962-6971
 * + applySettings() at 6974. Persisted user preferences mirrored to
 * <html> data-* attributes by a single effect() so CSS picks them up. */
import { signal, effect } from '@preact/signals';

const STORAGE_KEY = 'bs.settings.v1';

export type Theme = 'light' | 'dark';
export type TextSize = 'small' | 'medium' | 'large';
export type Lang = 'he' | 'ar' | 'en';
export type Units = 'metric' | 'imperial';
export type Currency = 'ils' | 'usd';
export type HaulSize = 'small' | 'van' | 'truck';

export type NotifKey = 'shipments' | 'deals' | 'budget' | 'orders';

export type AppSettings = {
  display: {
    theme: Theme;
    textSize: TextSize;
    reduceMotion: boolean;
  };
  notif: Record<NotifKey, boolean>;
  region: {
    lang: Lang;
    units: Units;
    currency: Currency;
  };
  delivery: {
    defaultHaul: HaulSize;
    express: boolean;
  };
  accessibility: {
    highContrast: boolean;
  };
};

const DEFAULTS: AppSettings = {
  display: { theme: 'light', textSize: 'medium', reduceMotion: false },
  notif: { shipments: true, deals: true, budget: true, orders: true },
  region: { lang: 'he', units: 'metric', currency: 'ils' },
  delivery: { defaultHaul: 'small', express: false },
  accessibility: { highContrast: false },
};

function pick<T extends string>(v: unknown, allowed: readonly T[], fallback: T): T {
  return (allowed as readonly string[]).includes(v as string) ? (v as T) : fallback;
}

function load(): AppSettings {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULTS;
    const p = JSON.parse(raw);
    return {
      display: {
        theme: pick<Theme>(p?.display?.theme, ['light', 'dark'], 'light'),
        textSize: pick<TextSize>(p?.display?.textSize, ['small', 'medium', 'large'], 'medium'),
        reduceMotion: Boolean(p?.display?.reduceMotion),
      },
      notif: {
        shipments: p?.notif?.shipments !== false,
        deals: p?.notif?.deals !== false,
        budget: p?.notif?.budget !== false,
        orders: p?.notif?.orders !== false,
      },
      region: {
        lang: pick<Lang>(p?.region?.lang, ['he', 'ar', 'en'], 'he'),
        units: pick<Units>(p?.region?.units, ['metric', 'imperial'], 'metric'),
        currency: pick<Currency>(p?.region?.currency, ['ils', 'usd'], 'ils'),
      },
      delivery: {
        defaultHaul: pick<HaulSize>(p?.delivery?.defaultHaul, ['small', 'van', 'truck'], 'small'),
        express: Boolean(p?.delivery?.express),
      },
      accessibility: { highContrast: Boolean(p?.accessibility?.highContrast) },
    };
  } catch {
    return DEFAULTS;
  }
}

export const appSettings = signal<AppSettings>(load());

/* === Setters — all return shallowly-cloned signal values. === */

export function setTheme(t: Theme): void {
  const s = appSettings.value;
  appSettings.value = { ...s, display: { ...s.display, theme: t } };
}
export function setTextSize(sz: TextSize): void {
  const s = appSettings.value;
  appSettings.value = { ...s, display: { ...s.display, textSize: sz } };
}
export function setReduceMotion(b: boolean): void {
  const s = appSettings.value;
  appSettings.value = { ...s, display: { ...s.display, reduceMotion: b } };
}
export function toggleReduceMotion(): void {
  setReduceMotion(!appSettings.value.display.reduceMotion);
}

export function toggleNotif(key: NotifKey): void {
  const s = appSettings.value;
  appSettings.value = { ...s, notif: { ...s.notif, [key]: !s.notif[key] } };
}

export function setLang(l: Lang): void {
  const s = appSettings.value;
  appSettings.value = { ...s, region: { ...s.region, lang: l } };
}
export function setUnits(u: Units): void {
  const s = appSettings.value;
  appSettings.value = { ...s, region: { ...s.region, units: u } };
}
export function setCurrency(c: Currency): void {
  const s = appSettings.value;
  appSettings.value = { ...s, region: { ...s.region, currency: c } };
}

export function setDefaultHaul(h: HaulSize): void {
  const s = appSettings.value;
  appSettings.value = { ...s, delivery: { ...s.delivery, defaultHaul: h } };
}
export function toggleExpress(): void {
  const s = appSettings.value;
  appSettings.value = { ...s, delivery: { ...s.delivery, express: !s.delivery.express } };
}

export function toggleHighContrast(): void {
  const s = appSettings.value;
  appSettings.value = {
    ...s,
    accessibility: { ...s.accessibility, highContrast: !s.accessibility.highContrast },
  };
}

/* @legacy index.html:6962-6971 (resetSettings) — restores the defaults
 * exactly as the legacy version did. We don't toast yet (no toast). */
export function resetSettings(): void {
  appSettings.value = DEFAULTS;
}

if (typeof document !== 'undefined') {
  effect(() => {
    const s = appSettings.value;
    const root = document.documentElement;
    root.setAttribute('data-theme', s.display.theme);
    root.setAttribute('data-text-size', s.display.textSize);
    root.setAttribute('data-reduce-motion', s.display.reduceMotion ? 'true' : 'false');
    root.setAttribute('data-lang', s.region.lang);
    root.setAttribute('data-units', s.region.units);
    root.setAttribute('data-currency', s.region.currency);
    root.setAttribute('data-haul', s.delivery.defaultHaul);
    root.setAttribute('data-express', s.delivery.express ? 'true' : 'false');
    root.setAttribute('data-contrast', s.accessibility.highContrast ? 'high' : 'normal');
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
    } catch {
      /* storage unavailable — keep in-memory */
    }
  });
}
