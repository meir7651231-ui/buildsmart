// ⚛️ אטום-Dart (דרגת-חוזה) · sessionsOf — המפגשים-בפועל של חוג.
// מוצא: maor/src/components/courses/lib.ts:84-91 · המקור: new/atoms/sessions-of.mjs —
//   `return c.sessions && c.sessions.length ? c.sessions : [{ day: c.weekday, time: c.time, label: '' }];`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: יש מערך-מפגשים לא-ריק ⇒ הוא-עצמו מוחזר (אותה הפניה — לא עותק);
//        אין/ריק ⇒ נפילה למפגש-יחיד שנבנה מהשדות הראשיים של החוג:
//        [{day: c.weekday, time: c.time, label: ''}].
// קלט: c — חוג (Map) עם sessions? (List של {day,time,label}) · weekday · time.
// פלט: מערך-מפגשים לא-ריק, תמיד.
//
// הערת-המרה (מקור→Dart, כלל-7 truthiness): התנאי בקוד-המקור הוא
// `c.sessions && c.sessions.length` — ‏sessions חסר/undefined/null = falsy,
// ומערך-ריק נופל על length===0 (falsy). ב-Dart: ‏`s is List && s.isNotEmpty`
// (מפתח-חסר ב-Map ⇒ null ⇒ falsy, בדיוק כמו undefined ב-JS; length 0 ⇒ falsy).
// בנפילה — הערכים עוברים כמות-שהם (weekday=0 ו-time='' אינם נבלעים: ב-JS הם
// רק מועתקים לשדות, בלי בדיקת-truthiness). זהות-הפניה נשמרת: המערך המקורי
// מוחזר as-is (=== של JS ⇒ identical ב-Dart). אין locale/תאריך/מספר — כלום.

/// The actual sessions of a course: a non-empty sessions array is returned
/// as-is (same reference, no copy); missing/empty falls back to a single
/// session built from the course's primary fields. Verbatim behaviour of the
/// JS source `sessionsOf`.
dynamic sessionsOf(dynamic c) {
  final s = c['sessions'];
  if (s is List && s.isNotEmpty) return s;
  return [
    {'day': c['weekday'], 'time': c['time'], 'label': ''}
  ];
}
