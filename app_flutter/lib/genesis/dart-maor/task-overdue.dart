// ⚛️ אטום-Dart (דרגת-חוזה) · taskOverdue — האם משימה באיחור: יש due לפני-היום והיא עוד פתוחה.
// מוצא: maor/src/lib/worktasks.ts:34-36 · המקור: new/atoms/task-overdue.mjs —
//        `return !t.doneAt && !!t.due && t.due < todayIso;`
// חוזה: new/atoms/task-overdue.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: משימה באיחור רק אם (א) אין doneAt (פתוחה), (ב) יש due (truthy),
//        (ג) ‏due < todayIso לקסיקוגרפית על ISO ‏YYYY-MM-DD — יעד **היום** אינו איחור.
// קלט: ‏t — Map של משימה ‏{doneAt?, due?} (מפתח-חסר ≡ undefined ≡ כוזב) · ‏todayIso — מחרוזת ‏YYYY-MM-DD.
// פלט: bool.
//
// הערות-המרה (מקור→Dart):
// - ‏truthiness של JS (‏!x / ‏!!x) ⇒ ‏_falsy מפורש (חוק-7 בתקציר): ‏null/''/false/0/-0/NaN כוזבים.
// - גישת-שדה ‏t.doneAt על אובייקט-JS ⇒ ‏t['doneAt'] על Map (מפתח-חסר ⇒ null ≡ undefined-כוזב).
// - ‏`<` של JS על שתי מחרוזות = השוואת-code-units לקסיקוגרפית ⇒ ‏compareTo(...) < 0 של Dart —
//   זהה-ביט על מחרוזות (שתיהן UTF-16 code units). קצה ה-‏!!t.due מבטיח שההשוואה רצה רק
//   כש-due הוא מחרוזת לא-ריקה (בדומיין due הוא תמיד ISO-string או חסר).

/// JS truthiness — כוזב: null / false / '' / 0 / -0 / NaN. הכול חוץ מזה — אמת.
bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN));

/// True when the task is overdue: open (no doneAt), has a due date, and due < todayIso
/// (lexicographic ISO compare — due **today** is not overdue). Verbatim JS behaviour.
bool taskOverdue(dynamic t, dynamic todayIso) {
  final dynamic doneAt = (t is Map) ? t['doneAt'] : null;
  final dynamic due = (t is Map) ? t['due'] : null;
  return _falsy(doneAt) &&
      !_falsy(due) &&
      (due as String).compareTo(todayIso as String) < 0;
}
