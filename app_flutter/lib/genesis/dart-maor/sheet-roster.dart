// ⚛️ אטום-Dart (דרגת-חוזה) · sheetRoster — גיליון-נוכחות (roll-call) של חוג.
// מוצא: maor/src/components/courses/lib.ts:391-395 · המקור: new/atoms/sheet-roster.mjs —
//        `enrollments.filter((e) => e.courseId === courseId && e.status !== 'ended' && e.status !== 'wait')`
// חוזה: new/atoms/sheet-roster.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מסנן מכלל השיבוצים את שיבוצי-החוג הפעילים/המוקפאים — לא מי שסיימו
//        (status==='ended') ולא רשימת-ההמתנה (status==='wait'). כל סטטוס אחר —
//        כולל **חסר** (שיבוצי-עבר בלי שדה status) — נכלל.
// קלט: enrollments — מערך שיבוצים ({courseId, status?, …} — כאן List של Map) ·
//        courseId — מזהה-החוג.
// פלט: מערך-משנה **חדש** (filter ⇒ toList), הסדר המקורי נשמר, האיברים עוברים
//        בזהות-הפניה (אותם אובייקטים, לא עותקים).
//
// 🔧 תיקון-הסגר (כלל-2 · courseId חסר מול null): המקור משתמש ב-`===`. כש-הארגומנט
//    courseId הוא null, ב-JS ‏`e.courseId === null` אמת **רק** כשהמפתח קיים בערך null
//    (מפתח-חסר ⇒ undefined, ו-undefined===null ⇒ false). הפורט הישן השווה
//    `e['courseId'] == courseId`, ו-ב-Dart מפתח-חסר מחזיר null ⇒ null==null ⇒ true,
//    ולכן שורה-חסרת-מפתח דלפה לגיליון. התיקון: בענף courseId==null בודקים
//    containsKey — רק מפתח-קיים-בערך-null נכלל. לשאר הערכים (מחרוזת) `==` של Dart
//    על String ≡ `===` של JS, ומפתח-חסר (null) לעולם לא שווה למחרוזת ⇒ זהה.

/// Roll-call roster of a course: the course's active/frozen enrollments —
/// excludes 'ended' and 'wait'; any other status, including a MISSING status
/// (legacy rows), is included. Returns a NEW list (filter), original order kept,
/// elements pass by reference identity. Verbatim behaviour of the JS `===`.
List<dynamic> sheetRoster(dynamic enrollments, dynamic courseId) {
  return (enrollments as List)
      .where((e) =>
          _strictEqCourse(e, courseId) &&
          e['status'] != 'ended' &&
          e['status'] != 'wait')
      .toList();
}

/// JS `e.courseId === courseId` נאמן: כש-courseId הוא null, מפתח-חסר (undefined)
/// אינו שווה ⇒ נדרש containsKey; לערך לא-null, השוואת-ערך רגילה מספיקה.
bool _strictEqCourse(dynamic e, dynamic courseId) {
  final m = e as Map;
  if (courseId == null) {
    return m.containsKey('courseId') && m['courseId'] == null;
  }
  return m['courseId'] == courseId;
}
