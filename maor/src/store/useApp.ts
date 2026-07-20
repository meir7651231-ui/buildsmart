/**
 * ה-store המרכזי (Zustand) — כל מצב האפליקציה ופעולות העסקים.
 *
 * עקרונות:
 * - אין מוטציה במקום: כל פעולה מחזירה עותקים חדשים (חוזה עם ההתמדה וה-render).
 * - כל שינוי נתונים עובר דרך setDb() שמפעיל שמירה אוטומטית (debounced).
 * - מזהים נוצרים אך ורק דרך nextId().
 */
import { create } from 'zustand';
import {
  emptyDb,
  type Absence,
  type Course,
  type Db,
  type Donation,
  type Enrollment,
  type Family,
  type Member,
  type OrgEvent,
  type Payment,
  type Room,
  type Supporter,
  type Teacher,
} from '../types/domain';
import { dailySnapshot, exportBackupFile, loadDb, saveDb } from './persist';

export type View =
  | 'home'
  | 'families'
  | 'courses'
  | 'calendar'
  | 'diary'
  | 'supporters'
  | 'reports'
  | 'settings';

export interface Toast {
  id: number;
  text: string;
}

interface AppState {
  db: Db;
  ready: boolean;
  corrupt: boolean;
  saveOk: boolean;
  view: View;
  /** משפחה/קורס נבחרים לתצוגת פירוט. */
  selFamilyId: string | null;
  selCourseId: string | null;
  toasts: Toast[];
  paletteOpen: boolean;

  // מחזור חיים
  init: () => Promise<void>;
  setDb: (patch: Partial<Db> | ((db: Db) => Partial<Db>)) => void;
  nextId: (prefix: string) => string;

  // ניווט
  go: (view: View) => void;
  selectFamily: (id: string | null) => void;
  selectCourse: (id: string | null) => void;
  setPalette: (open: boolean) => void;

  // הודעות
  toast: (text: string) => void;
  dismissToast: (id: number) => void;

  // משפחות ובני משפחה
  upsertFamily: (fam: Family) => void;
  deleteFamily: (id: string) => void;
  upsertMember: (famId: string, member: Member) => void;
  deleteMember: (famId: string, memberId: string) => void;
  addCred: (famId: string, delta: number, reason: string) => void;

  // חוגים ושיבוצים
  upsertCourse: (course: Course) => void;
  deleteCourse: (id: string) => void;
  upsertEnrollment: (e: Enrollment) => void;
  deleteEnrollment: (id: string) => void;
  punch: (enrollmentId: string) => void;
  addAbsence: (enrollmentId: string, absence: Absence) => void;
  addPayment: (enrollmentId: string, payment: Omit<Payment, 'rid'>) => void;

  // יומן ואירועים
  upsertEvent: (ev: OrgEvent) => void;
  deleteEvent: (id: string) => void;

  // צוות, חדרים, תורמים
  upsertTeacher: (t: Teacher) => void;
  deleteTeacher: (id: string) => { ok: boolean; error?: string };
  upsertRoom: (r: Room) => void;
  upsertSupporter: (s: Supporter) => void;
  deleteSupporter: (id: string) => void;
  addDonation: (supporterId: string, donation: Omit<Donation, 'rid'>) => void;

  // גיבוי ושחזור
  exportBackup: () => void;
  restoreDb: (db: Db) => void;
  resetAll: () => void;
}

let saveTimer: ReturnType<typeof setTimeout> | undefined;
let toastSeq = 1;

function isoToday(): string {
  return new Date().toISOString().slice(0, 10);
}

export const useApp = create<AppState>()((set, get) => {
  /** שמירה אוטומטית — חצי שנייה אחרי השינוי האחרון. */
  function scheduleSave() {
    clearTimeout(saveTimer);
    saveTimer = setTimeout(async () => {
      const ok = await saveDb(get().db);
      if (ok !== get().saveOk) set({ saveOk: ok });
      if (!ok) {
        get().toast('⚠ השמירה נכשלה — הורידו גיבוי מלא ובדקו מקום פנוי בדפדפן');
      }
    }, 500);
  }

  function setDb(patch: Partial<Db> | ((db: Db) => Partial<Db>)) {
    set((s) => ({ db: { ...s.db, ...(typeof patch === 'function' ? patch(s.db) : patch) } }));
    scheduleSave();
  }

  /** upsert גנרי לפי id — חדש נכנס לראש הרשימה (כמו במקור). */
  function upsertIn<T extends { id: string }>(list: T[], item: T): T[] {
    const i = list.findIndex((x) => x.id === item.id);
    if (i < 0) return [item, ...list];
    const out = list.slice();
    out[i] = item;
    return out;
  }

  return {
    db: emptyDb(),
    ready: false,
    corrupt: false,
    saveOk: true,
    view: 'home',
    selFamilyId: null,
    selCourseId: null,
    toasts: [],
    paletteOpen: false,

    async init() {
      const { db, corrupt } = await loadDb();
      set({ db, corrupt, ready: true });
      void dailySnapshot(db);
      if (corrupt) {
        get().toast('⚠ הנתונים השמורים נמצאו פגומים — נשמר עותק בצד. שחזרו מגיבוי דרך הגדרות ← ייבוא');
      }
    },

    setDb,

    nextId(prefix) {
      const seq = get().db.seq;
      setDb({ seq: seq + 1 });
      return prefix + seq;
    },

    go: (view) => set({ view }),
    selectFamily: (id) => set({ selFamilyId: id, view: 'families' }),
    selectCourse: (id) => set({ selCourseId: id, view: 'courses' }),
    setPalette: (open) => set({ paletteOpen: open }),

    toast(text) {
      const id = toastSeq++;
      set((s) => ({ toasts: [...s.toasts, { id, text }] }));
      setTimeout(() => get().dismissToast(id), 4000);
    },
    dismissToast: (id) => set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) })),

    upsertFamily(fam) {
      setDb((db) => ({ families: upsertIn(db.families, fam) }));
    },
    deleteFamily(id) {
      setDb((db) => {
        const memberIds = new Set(
          db.families.find((f) => f.id === id)?.members.map((m) => m.id) ?? [],
        );
        return {
          families: db.families.filter((f) => f.id !== id),
          enrollments: db.enrollments.filter((e) => !memberIds.has(e.memberId)),
          events: db.events.filter((ev) => ev.famId !== id),
        };
      });
    },
    upsertMember(famId, member) {
      setDb((db) => ({
        families: db.families.map((f) =>
          f.id === famId
            ? {
                ...f,
                members: f.members.some((m) => m.id === member.id)
                  ? f.members.map((m) => (m.id === member.id ? member : m))
                  : [...f.members, member],
              }
            : f,
        ),
      }));
    },
    deleteMember(famId, memberId) {
      setDb((db) => ({
        families: db.families.map((f) =>
          f.id === famId ? { ...f, members: f.members.filter((m) => m.id !== memberId) } : f,
        ),
        enrollments: db.enrollments.filter((e) => e.memberId !== memberId),
      }));
    },
    addCred(famId, delta, reason) {
      setDb((db) => ({
        families: db.families.map((f) =>
          f.id === famId
            ? {
                ...f,
                cred: {
                  score: Math.max(0, Math.min(1000, (f.cred?.score ?? 500) + delta)),
                  log: [{ date: isoToday(), delta, reason }, ...(f.cred?.log ?? [])].slice(0, 200),
                },
              }
            : f,
        ),
      }));
    },

    upsertCourse(course) {
      setDb((db) => ({ courses: upsertIn(db.courses, course) }));
    },
    deleteCourse(id) {
      setDb((db) => ({
        courses: db.courses.filter((c) => c.id !== id),
        enrollments: db.enrollments.filter((e) => e.courseId !== id),
      }));
    },
    upsertEnrollment(e) {
      setDb((db) => ({ enrollments: upsertIn(db.enrollments, e) }));
    },
    deleteEnrollment(id) {
      setDb((db) => ({ enrollments: db.enrollments.filter((e) => e.id !== id) }));
    },
    punch(enrollmentId) {
      setDb((db) => ({
        enrollments: db.enrollments.map((e) =>
          e.id === enrollmentId && e.plan === 'punch' && e.used < e.purchased
            ? { ...e, used: e.used + 1 }
            : e,
        ),
      }));
    },
    addAbsence(enrollmentId, absence) {
      setDb((db) => ({
        enrollments: db.enrollments.map((e) =>
          e.id === enrollmentId ? { ...e, absences: [absence, ...e.absences] } : e,
        ),
      }));
    },
    addPayment(enrollmentId, payment) {
      const rid = 'R-' + get().db.seq;
      setDb((db) => ({
        seq: db.seq + 1,
        enrollments: db.enrollments.map((e) =>
          e.id === enrollmentId ? { ...e, payments: [{ ...payment, rid }, ...e.payments] } : e,
        ),
      }));
    },

    upsertEvent(ev) {
      setDb((db) => ({ events: upsertIn(db.events, ev) }));
    },
    deleteEvent(id) {
      setDb((db) => ({ events: db.events.filter((e) => e.id !== id) }));
    },

    upsertTeacher(t) {
      setDb((db) => ({ teachers: upsertIn(db.teachers, t) }));
    },
    deleteTeacher(id) {
      const used = get().db.courses.some((c) => c.teacherId === id);
      if (used) return { ok: false, error: 'למורה יש חוגים משויכים — העבירו אותם קודם למורה אחרת' };
      setDb((db) => ({ teachers: db.teachers.filter((t) => t.id !== id) }));
      return { ok: true };
    },
    upsertRoom(r) {
      setDb((db) => ({ rooms: upsertIn(db.rooms, r) }));
    },
    upsertSupporter(s) {
      setDb((db) => ({ supporters: upsertIn(db.supporters, s) }));
    },
    deleteSupporter(id) {
      setDb((db) => ({ supporters: db.supporters.filter((s) => s.id !== id) }));
    },
    addDonation(supporterId, donation) {
      const rid = 'D-' + get().db.seq;
      setDb((db) => ({
        seq: db.seq + 1,
        supporters: db.supporters.map((s) => {
          if (s.id !== supporterId) return s;
          const donations = [{ ...donation, rid }, ...s.donations];
          return {
            ...s,
            donations,
            count: donations.length,
            ils: s.ils + (donation.cur === '₪' ? donation.amount : 0),
            usd: s.usd + (donation.cur === '$' ? donation.amount : 0),
            first: s.first || donation.date,
            last: donation.date > (s.last || '') ? donation.date : s.last,
          };
        }),
      }));
    },

    exportBackup() {
      exportBackupFile(get().db);
      get().toast('קובץ גיבוי מלא ירד למחשב ✓');
    },
    restoreDb(db) {
      set({ db });
      scheduleSave();
      void dailySnapshot(db);
      get().toast('הנתונים שוחזרו מהגיבוי ✓');
    },
    resetAll() {
      set({ db: emptyDb() });
      scheduleSave();
      get().toast('המערכת אופסה — כל הנתונים נמחקו');
    },
  };
});

/** בוחרי עזר נפוצים. */

export function useFamily(id: string | null): Family | undefined {
  return useApp((s) => s.db.families.find((f) => f.id === id));
}

export function useCourse(id: string | null): Course | undefined {
  return useApp((s) => s.db.courses.find((c) => c.id === id));
}

/** כל בני המשפחה בכל המשפחות, עם שם המשפחה. */
export interface MemberWithFamily extends Member {
  famId: string;
  famName: string;
}

export function allMembers(db: Db): MemberWithFamily[] {
  const out: MemberWithFamily[] = [];
  for (const f of db.families) {
    for (const m of f.members) out.push({ ...m, famId: f.id, famName: f.name });
  }
  return out;
}
