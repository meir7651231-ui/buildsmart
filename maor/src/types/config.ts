/**
 * קונפיגורציית ארגון (white-label) — קובעת מיתוג, ערכת נושא ומודולים פעילים.
 * נטענת ב-lib/config.ts לפי סדר: localStorage ← config.json ← ברירת מחדל.
 */

/** מפתחות המודולים הניתנים לכיבוי בניווט (בית והגדרות תמיד פעילים). */
export type ModuleKey = 'families' | 'courses' | 'calendar' | 'diary' | 'supporters' | 'reports';

export interface OrgConfig {
  /** מזהה קצר של הארגון (לשם קובץ/כתובת). */
  slug: string;
  /** שם הארגון למיתוג — ריק = השם השמור בנתונים (db.orgName). */
  orgName: string;
  /** לוגו כ-data URI (אופציונלי). */
  logoDataUri?: string;
  /** מפתח ערכת נושא: or-rishon / heichal / tsohar / kehila. */
  theme: string;
  /** דריסת צבע הדגשה ארגוני (hex) — נכתב כ---accent על ה-DOM. */
  accent?: string;
  /** מודולים פעילים — מפתח חסר = פעיל; false = מוסתר מהניווט. */
  modules: Partial<Record<ModuleKey, boolean>>;
  /** מילון מונחים מותאם (למשל "חוגים" ← "שיעורים"). */
  terms?: Record<string, string>;
  /** אינטגרציות עתידיות לפי שם. */
  integrations?: Record<string, { enabled: boolean }>;
}

export const DEFAULT_CONFIG: OrgConfig = {
  slug: 'default',
  orgName: '',
  theme: 'or-rishon',
  modules: {},
};
