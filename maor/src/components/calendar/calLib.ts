/**
 * לוגיקת לוח השנה — פונקציות טהורות על ה-Db (ללא React).
 * כולל: רשת חודש לועזי, רשת חודש עברי מלא (א׳–ל׳), שכבות יום
 * (חגים · אירועים כולל חזרה שנתית לפי התאריך העברי · מפגשי חוגים)
 * ורשימת "אירועים קרובים" ל-14 הימים הבאים.
 */
import {
  HEBREW_RECURRING,
  type Course,
  type CourseSession,
  type Db,
  type EventType,
  type OrgEvent,
} from '../../types/domain';
import { gem, gemYear, hebParts, holidayOf, type HebParts } from '../../lib/hebrew';

/* ---------- תאריכים ---------- */

const fmtHebMonth = new Intl.DateTimeFormat('he-u-ca-hebrew', { month: 'long' });
const fmtHebYear = new Intl.DateTimeFormat('he-u-ca-hebrew', { year: 'numeric' });
const fmtMonthYear = new Intl.DateTimeFormat('he', { month: 'long', year: 'numeric' });

/** ISO מקומי (ללא הזחת אזור זמן של toISOString). */
export function isoOf(d: Date): string {
  const p2 = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p2(d.getMonth() + 1)}-${p2(d.getDate())}`;
}

/** תצוגת תאריך DD/MM/YYYY מתוך ISO. */
export function fmtD(iso: string): string {
  if (!iso) return '—';
  const [y, m, d] = iso.split('-');
  if (!y || !m || !d) return '—';
  return `${d}/${m}/${y}`;
}

function dateOf(iso: string): Date {
  return new Date(iso + 'T12:00:00');
}

/** חלקי תאריך עברי עם מטמון לפי ISO — Intl יקר, והרשת קוראת עשרות פעמים. */
const hpCache = new Map<string, HebParts>();
export function hpOf(iso: string, d?: Date): HebParts {
  let hp = hpCache.get(iso);
  if (!hp) {
    hp = hebParts(d ?? dateOf(iso));
    hpCache.set(iso, hp);
  }
  return hp;
}

export const DAY_NAMES = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'] as const;

/* ---------- מטא של סוגי אירועים (צבעים ותוויות verbatim מהמקור) ---------- */

export const EV_META: Record<EventType, { label: string; bg: string; c: string }> = {
  reminder: { label: 'תזכורת', bg: '#efe7f3', c: '#7c3aed' },
  call: { label: 'טלפון', bg: '#dff0ec', c: '#0f766e' },
  wedding: { label: 'חתונה', bg: '#fdeee0', c: '#b45309' },
  memorial: { label: 'אזכרה', bg: '#eceae2', c: '#4d463c' },
  anniversary: { label: 'יום נישואים', bg: '#fbeef3', c: '#be185d' },
  bday: { label: 'יום הולדת', bg: '#fbeef3', c: '#be185d' },
  org: { label: 'אירוע', bg: '#e7edf5', c: '#3a5a86' },
  custom: { label: 'אירוע', bg: '#e7edf5', c: '#3a5a86' },
};

export const SESSION_META = { label: 'מפגש קורס', bg: '#fdf1d4', c: '#9a6414' } as const;
export const HOLIDAY_META = { label: 'חג ומועד', bg: '#e4f5ea', c: '#12803c' } as const;

export const PRIORITY_COLOR: Record<string, string> = {
  red: '#dc2626',
  orange: '#d97706',
  green: '#16a34a',
};

export function evLabel(ev: OrgEvent): string {
  return (ev.type === 'custom' && ev.customType) || EV_META[ev.type].label;
}

/** מפגשי חוג — כמו במקור: אם אין sessions, נגזר מפגש יחיד מ-weekday/time. */
export function sessionsOf(c: Course): CourseSession[] {
  return c.sessions && c.sessions.length ? c.sessions : [{ day: c.weekday, time: c.time, label: '' }];
}

/* ---------- שכבות יום ---------- */

/**
 * האם אירוע חל ביום נתון: תאריך מדויק, או — לסוגים החוזרים (אזכרה /
 * יום נישואין / יום הולדת) — התאמת יום+חודש עבריים בכל שנה שאחרי המקור.
 */
export function eventOccursOn(ev: OrgEvent, iso: string, hp: HebParts): boolean {
  if (!ev.date) return false;
  if (ev.date === iso) return true;
  if (!HEBREW_RECURRING.has(ev.type) || iso <= ev.date) return false;
  const oh = hpOf(ev.date);
  return oh.day === hp.day && oh.month === hp.month;
}

export interface DayItem {
  key: string;
  /** טקסט הגלולה בתא. */
  label: string;
  /** tooltip מלא. */
  title: string;
  bg: string;
  c: string;
  typeLabel: string;
  sort: number;
  /** פס צבע דחיפות (transparent כשאין). */
  prC: string;
  ev?: OrgEvent;
  courseId?: string;
  /** מפגש חוג שנופל על חג — מוצג מסומן כלא מתקיים. */
  skipped?: boolean;
}

/** כל מה שקורה ביום: אירועים (כולל חוזרים) + מפגשי חוגים. חג מוחזר בנפרד בתא. */
export function dayItems(db: Db, d: Date): DayItem[] {
  const iso = isoOf(d);
  const hp = hpOf(iso, d);
  const hol = holidayOf(d);
  const out: DayItem[] = [];

  for (const ev of db.events) {
    // אירוע שסומן "בוצע" מוצג רק בתאריכו המקורי (מחוק-קו) ואינו חוזר שנתית.
    const hit = ev.done ? ev.date === iso : eventOccursOn(ev, iso, hp);
    if (!hit) continue;
    out.push({
      key: 'ev-' + ev.id,
      label: (ev.time ? ev.time + ' · ' : '') + ev.title,
      title: ev.title + (ev.done ? ' · בוצע ✓' : ''),
      bg: EV_META[ev.type].bg,
      c: EV_META[ev.type].c,
      typeLabel: evLabel(ev),
      sort: ev.priority === 'red' ? 0.5 : 1,
      prC: PRIORITY_COLOR[ev.priority] ?? 'transparent',
      ev,
    });
  }

  const dow = d.getDay();
  for (const c of db.courses) {
    if (c.start && iso < c.start) continue;
    if (c.end && iso > c.end) continue;
    for (const ss of sessionsOf(c)) {
      if (ss.day !== dow) continue;
      out.push({
        key: `crs-${c.id}-${ss.label || ss.time}`,
        label: (ss.time ? ss.time + ' · ' : '') + c.name + (ss.label ? ' · ' + ss.label : ''),
        title: c.name + (ss.label ? ' — ' + ss.label : '') + (hol ? ' · לא מתקיים — ' + hol : ''),
        bg: SESSION_META.bg,
        c: SESSION_META.c,
        typeLabel: SESSION_META.label,
        sort: 3,
        prC: 'transparent',
        courseId: c.id,
        skipped: !!hol,
      });
    }
  }

  return out.sort((a, b) => a.sort - b.sort);
}

/* ---------- רשת החודש ---------- */

export interface CalCell {
  iso: string;
  date: Date;
  /** מספר לועזי — בגריד עברי בפורמט "יום.חודש". */
  dayNum: string;
  /** היום העברי בגימטריה (בא׳ בחודש מצורף שם החודש בגריד הלועזי). */
  hebDay: string;
  inMonth: boolean;
  isToday: boolean;
  holiday: string | null;
  items: DayItem[];
}

export interface CalGrid {
  cells: CalCell[];
  /** כותרת לועזית (בגריד עברי: טווח התאריכים הלועזי). */
  monthLabel: string;
  /** כותרת עברית: חודש/ים + שנה בגימטריה. */
  hebLabel: string;
  /** ניווט בגריד עברי — עוגני החודש הקודם/הבא. */
  prevIso: string | null;
  nextIso: string | null;
}

function makeCell(db: Db, d: Date, inMonth: boolean, todayIso: string, hebMode: boolean): CalCell {
  const iso = isoOf(d);
  const hp = hpOf(iso, d);
  return {
    iso,
    date: d,
    dayNum: hebMode ? `${d.getDate()}.${d.getMonth() + 1}` : String(d.getDate()),
    hebDay: hebMode ? gem(hp.day) : gem(hp.day) + (hp.day === 1 ? ' ' + fmtHebMonth.format(d) : ''),
    inMonth,
    isToday: iso === todayIso,
    holiday: holidayOf(d),
    items: dayItems(db, d),
  };
}

/** רשת חודש לועזי — 42 תאים קבועים, ראשון עד שבת. */
export function buildGregorianGrid(db: Db, year: number, month: number): CalGrid {
  const first = new Date(year, month, 1);
  const gridStart = new Date(year, month, 1 - first.getDay());
  const todayIso = isoOf(new Date());
  const cells: CalCell[] = [];
  for (let i = 0; i < 42; i++) {
    const d = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
    cells.push(makeCell(db, d, d.getMonth() === month, todayIso, false));
  }
  const last = new Date(year, month + 1, 0);
  const m1 = fmtHebMonth.format(first);
  const m2 = fmtHebMonth.format(last);
  return {
    cells,
    monthLabel: fmtMonthYear.format(first),
    hebLabel: (m1 === m2 ? m1 : m1 + '–' + m2) + ' ' + gemYear(fmtHebYear.format(last)),
    prevIso: null,
    nextIso: null,
  };
}

/** רשת חודש עברי מלא (א׳–ל׳) סביב תאריך עוגן — כמו במקור. */
export function buildHebrewGrid(db: Db, anchorIso: string): CalGrid {
  const anchor = dateOf(anchorIso);
  const hp0 = hpOf(anchorIso, anchor);
  // א׳ בחודש: הליכה אחורה לפי היום העברי של העוגן.
  const first = new Date(anchor);
  first.setDate(first.getDate() - (hp0.day - 1));
  // אורך החודש: בדיקה האם יום 30 עדיין באותו חודש עברי.
  const d30 = new Date(first);
  d30.setDate(d30.getDate() + 29);
  const dim = hpOf(isoOf(d30), d30).month === hp0.month ? 30 : 29;
  const hmStart = isoOf(first);
  const lastH = new Date(first);
  lastH.setDate(lastH.getDate() + dim - 1);
  const hmEnd = isoOf(lastH);

  const gridStart = new Date(first);
  gridStart.setDate(gridStart.getDate() - first.getDay());
  const count = Math.ceil((first.getDay() + dim) / 7) * 7;
  const todayIso = isoOf(new Date());
  const cells: CalCell[] = [];
  for (let i = 0; i < count; i++) {
    const d = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
    const iso = isoOf(d);
    cells.push(makeCell(db, d, iso >= hmStart && iso <= hmEnd, todayIso, true));
  }

  const prevD = new Date(first);
  prevD.setDate(prevD.getDate() - 1);
  const nextD = new Date(first);
  nextD.setDate(nextD.getDate() + dim);
  return {
    cells,
    monthLabel: fmtD(hmStart) + ' – ' + fmtD(hmEnd),
    hebLabel: fmtHebMonth.format(first) + ' ' + gemYear(fmtHebYear.format(first)),
    prevIso: isoOf(prevD),
    nextIso: isoOf(nextD),
  };
}

/* ---------- אירועים קרובים ---------- */

export interface UpcomingRow {
  key: string;
  iso: string;
  /** היום העברי בגימטריה לבלוק התאריך. */
  dayGem: string;
  /** שם החודש העברי לבלוק התאריך. */
  monHeb: string;
  title: string;
  sub: string;
  typeLabel: string;
  bg: string;
  c: string;
  prC: string;
  ev: OrgEvent;
}

/** אירועים ותזכורות ב-14 הימים הקרובים, כולל חוזרים לפי התאריך העברי. */
export function upcomingRows(db: Db, days = 14): UpcomingRow[] {
  const out: UpcomingRow[] = [];
  const start = new Date();
  for (let i = 0; i < days; i++) {
    const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
    const iso = isoOf(d);
    const hp = hpOf(iso, d);
    for (const ev of db.events) {
      if (ev.done || !eventOccursOn(ev, iso, hp)) continue;
      out.push({
        key: `${iso}-${ev.id}`,
        iso,
        dayGem: gem(hp.day),
        monHeb: fmtHebMonth.format(d),
        title: ev.title,
        sub: fmtD(iso) + (ev.time ? ' · ' + ev.time : ''),
        typeLabel: evLabel(ev),
        bg: EV_META[ev.type].bg,
        c: EV_META[ev.type].c,
        prC: PRIORITY_COLOR[ev.priority] ?? 'transparent',
        ev,
      });
    }
  }
  return out;
}
