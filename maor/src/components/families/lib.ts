/**
 * עזרי מודול המשפחות — פורמט תאריכים, גיל, דרגות אמינות ותוויות משותפות.
 * עזרים מקומיים בלבד — אין כאן גישה ל-store או ל-DOM.
 */
import type { CSSProperties } from 'react';
import type { Db, Enrollment, Family, FamilyStatus } from '../../types/domain';

/** תצוגת תאריך DD/MM/YYYY (פנימית נשמר ISO). */
export function fmtDate(iso: string): string {
  if (!iso) return '—';
  const [y, m, d] = iso.slice(0, 10).split('-');
  if (!y || !m || !d) return '—';
  return `${d}/${m}/${y}`;
}

export function isoToday(): string {
  return new Date().toISOString().slice(0, 10);
}

/** גיל בשנים מלאות מתאריך לידה, או null אם אין תאריך. */
export function ageOf(birth: string): number | null {
  if (!birth) return null;
  const d = new Date(birth);
  if (isNaN(d.getTime())) return null;
  const n = new Date();
  let a = n.getFullYear() - d.getFullYear();
  const md = n.getMonth() - d.getMonth();
  if (md < 0 || (md === 0 && n.getDate() < d.getDate())) a--;
  return a;
}

export const STATUS_META: Record<FamilyStatus, { label: string; bg: string; c: string }> = {
  active: { label: 'פעילה', bg: '#e4f5ea', c: '#12803c' },
  pending: { label: 'ממתינה', bg: '#fdf1d4', c: '#9a6414' },
  inactive: { label: 'לא פעילה', bg: '#eceae2', c: '#8b8474' },
};

export interface Tier {
  key: 'titan' | 'lion' | 'pale' | 'red';
  label: string;
  bg: string;
  c: string;
  dot: string;
}

/** דרגת מדד האמינות — זהה לחלוקה במקור (950/800/500). */
export function tierOf(score: number): Tier {
  if (score >= 950) return { key: 'titan', label: 'טיטאן', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' };
  if (score >= 800) return { key: 'lion', label: 'לביאה', bg: '#e4f5ea', c: '#12803c', dot: '#16a34a' };
  if (score >= 500) return { key: 'pale', label: 'טעון שיפור', bg: '#fdf1d4', c: '#9a6414', dot: '#d97706' };
  return { key: 'red', label: 'סיכון נטישה', bg: '#fdeaea', c: '#b91c1c', dot: '#dc2626' };
}

/** כל השיבוצים של בני המשפחה. */
export function famEnrollments(db: Db, fam: Family): Enrollment[] {
  const ids = new Set(fam.members.map((m) => m.id));
  return db.enrollments.filter((e) => ids.has(e.memberId));
}

/** ערכי הבחירה בטופס — verbatim מהמקור; '__other' פותח הקלדה חופשית. */
export const MARITAL_OPTIONS = ['נשואים', 'גרושים', 'אלמן/ה', 'פרודים'];
export const LANGUAGE_OPTIONS = ['עברית', 'יידיש', 'רוסית', 'צרפתית', 'אנגלית'];
export const OTHER = '__other';
export const OTHER_LABEL = 'אחר — הקלדה חופשית…';

/** תוויות/צבעי סוגי אירועים (כמו evMeta במקור). */
export const EVENT_META: Record<string, { label: string; bg: string; c: string }> = {
  reminder: { label: 'תזכורת', bg: '#efe7f3', c: '#7c3aed' },
  call: { label: 'טלפון', bg: '#dff0ec', c: '#0f766e' },
  wedding: { label: 'חתונה', bg: '#fdeee0', c: '#b45309' },
  memorial: { label: 'אזכרה', bg: '#eceae2', c: '#4d463c' },
  anniversary: { label: 'יום נישואים', bg: '#fbeef3', c: '#be185d' },
  bday: { label: 'יום הולדת', bg: '#fbeef3', c: '#be185d' },
  org: { label: 'אירוע', bg: '#e7edf5', c: '#3a5a86' },
  custom: { label: 'אירוע', bg: '#e7edf5', c: '#3a5a86' },
};

/** צ'יפ סטטוס/דרגה קטן בסגנון אחיד. */
export function chipStyle(bg: string, c: string): CSSProperties {
  return {
    display: 'inline-block',
    padding: '3px 10px',
    borderRadius: 999,
    fontSize: 12,
    fontWeight: 700,
    background: bg,
    color: c,
    whiteSpace: 'nowrap',
  };
}
