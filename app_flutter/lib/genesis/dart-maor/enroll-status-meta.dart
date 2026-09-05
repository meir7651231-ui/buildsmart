// ⚛️ אטום-Dart (דרגת-חוזה) · enrollStatusMeta — תווית+צבעי-צ'יפ לסטטוס-שיבוץ.
// מוצא: maor/src/components/courses/lib.ts:412-420 · המקור: new/atoms/enroll-status-meta.mjs —
//        `export function enrollStatusMeta(e) {...}`
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מחזיר {label, bg, c} לפי e.status. 'wait' מקבל תווית משלו (קודם נפל ל"פעיל" והטעה);
//         כל סטטוס לא-מוכר (כולל חסר) ⇒ "פעיל". הצבעים = פיגמנטים (חוק-5) — התפקיד בקופסה.
// קלט:  e — מפה עם 'status' אופציונלי.
// פלט:  מפה {label, bg, c} — תווית + hex-רקע + hex-טקסט.
//
// הערת-המרה (מקור→Dart, מול DART-PORTING-RULES.md):
//   • JS `e.status === 'paused'`: קריאת-שדה-חסר ⇒ undefined ⇒ לא-שווה. ב-Dart `e['status']`
//     על מפתח-חסר ⇒ null ⇒ לא-שווה לאף מחרוזת ⇒ נופל לברירת-המחדל. כלל-2 (null≠undefined)
//     אינו נוגע כאן — אין השוואת-שוויון-רופפת, רק שרשרת === מפורשת מול מחרוזות.
//   • אין locale/פורמט/getMonth/מיון/תאריך/substring/truthiness — דיספאטץ' מחרוזות טהור.
//   • מפה חדשה בכל קריאה (ליטרל טרי) ⇒ אין מוטציה משותפת בין קריאות (טוהר).

/// Enrollment-status chip label + colors — verbatim behavior of the JS source
/// new/atoms/enroll-status-meta.mjs. Any unknown/absent status ⇒ "פעיל".
Map<String, String> enrollStatusMeta(Map<String, dynamic> e, {required String Function(String) term}) {
  if (e['status'] == 'paused') {
    return {'label': term('mvkpa'), 'bg': '#fdf1d4', 'c': '#9a6414'};
  }
  if (e['status'] == 'ended') {
    return {'label': term('hstyym'), 'bg': '#eceae2', 'c': '#8b8474'};
  }
  // ⏳ רשימת-המתנה — קודם נפלה ל"פעיל" והטעתה (למשל בכרטיס ⚙ ניהול-שיבוץ)
  if (e['status'] == 'wait') {
    return {'label': term('rshymthmtnh'), 'bg': '#e7edf5', 'c': '#3a5a86'};
  }
  return {'label': term('payl'), 'bg': '#e4f5ea', 'c': '#12803c'};
}
