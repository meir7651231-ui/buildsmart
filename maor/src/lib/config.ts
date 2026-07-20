/**
 * מנוע הקונפיגורציה — טעינת קונפיגורציית הארגון והחלת ערכת הנושא על ה-DOM.
 *
 * סדר הרזולוציה של loadOrgConfig():
 * 1. localStorage 'maor_org_config' — דריסת ריצה (ישמש את אשף ההקמה).
 * 2. fetch('./config.json') — קובץ סטטי יחסי ל-base (פר-פריסה של ארגון).
 * 3. DEFAULT_CONFIG — כשאין קובץ / הקובץ פגום (404, JSON שבור).
 */
import { DEFAULT_CONFIG, type OrgConfig } from '../types/config';

const LS_CONFIG_KEY = 'maor_org_config';

/** נרמול קלט לא-אמין (localStorage / רשת) לצורת OrgConfig מלאה, או null אם לא שמיש. */
function normalize(raw: unknown): OrgConfig | null {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
  const c = raw as Partial<OrgConfig>;
  if (typeof c.slug !== 'string' && typeof c.orgName !== 'string' && typeof c.theme !== 'string') {
    return null;
  }
  return {
    ...DEFAULT_CONFIG,
    ...c,
    slug: typeof c.slug === 'string' && c.slug ? c.slug : DEFAULT_CONFIG.slug,
    orgName: typeof c.orgName === 'string' ? c.orgName : DEFAULT_CONFIG.orgName,
    theme: typeof c.theme === 'string' && c.theme ? c.theme : DEFAULT_CONFIG.theme,
    modules: c.modules && typeof c.modules === 'object' ? { ...c.modules } : {},
  };
}

/** דריסת הריצה השמורה בדפדפן, אם קיימת ותקינה. */
export function readConfigOverride(): OrgConfig | null {
  try {
    const raw = localStorage.getItem(LS_CONFIG_KEY);
    return raw ? normalize(JSON.parse(raw)) : null;
  } catch {
    return null;
  }
}

/** שמירת דריסת ריצה (אשף ההקמה / setConfig ב-store). */
export function saveConfigOverride(cfg: OrgConfig): void {
  try {
    localStorage.setItem(LS_CONFIG_KEY, JSON.stringify(cfg));
  } catch {
    /* localStorage חסום — הקונפיגורציה תחזיק עד רענון */
  }
}

/** טעינת קונפיגורציית הארגון לפי סדר הרזולוציה המתועד למעלה. */
export async function loadOrgConfig(): Promise<OrgConfig> {
  const override = readConfigOverride();
  if (override) return override;
  try {
    const res = await fetch('./config.json', { cache: 'no-cache' });
    if (res.ok) {
      const cfg = normalize(await res.json());
      if (cfg) return cfg;
    }
  } catch {
    /* אין קובץ / רשת — נמשיך לברירת המחדל */
  }
  return DEFAULT_CONFIG;
}

/** החלת ערכת נושא + דריסת צבע הדגשה על ה-DOM. */
export function applyTheme(theme: string, accent?: string): void {
  const el = document.documentElement;
  el.dataset.theme = theme || DEFAULT_CONFIG.theme;
  if (accent) el.style.setProperty('--accent', accent);
  else el.style.removeProperty('--accent');
}

/** החלת קונפיגורציה שלמה (ערכה + צבע) — נוחות לאשף/בדיקות. */
export function applyConfig(cfg: OrgConfig): void {
  applyTheme(cfg.theme, cfg.accent);
}
