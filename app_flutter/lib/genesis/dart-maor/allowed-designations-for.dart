// ⚛️ אטום-Dart (דרגת-חוזה) · allowedDesignationsFor — ייעודי-תרומה מותרים לעובד/ת.
// מוצא: maor/src/components/platform/lib.ts · המקור: new/atoms/allowed-designations-for.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכנים isOrgManager/overrideOf
//        הוזרקו כשקעים (חוק-1/חוק-3 — חוט לא מייבא שכן).
//
// תפקיד: מנהל-ארגון ⇒ null (כל הייעודים מותרים, אין הגבלה). עובד/ת ⇒ רשימת-הייעודים
//        מכרטיס-העובד (override); רשימה ריקה/חסרה ⇒ null (אין הגבלה).
// קלט:  email · org (Map) · השקע isOrgManager(email, org) ⇒ bool · השקע
//        overrideOf(email, org) ⇒ Map (כרטיס-העובד; {} כשאין). פלט: List? (הרשימה או null).
//
// הערות-המרה (מקור→Dart) — מה שמנוע-ה-AST פספס בזנב:
//  • `overrideOf(...).designations` (גישת-מאפיין ב-JS) → `overrideOf(...)['designations']`
//    (אינדוקס-מפה ב-Dart) — למפה אין getter בשם designations. חסר-מפתח ⇒ null (כמו undefined).
//  • truthiness `d && d.length` → `d != null && d.isNotEmpty`: null/undefined ⇒ null;
//    רשימה-ריקה (length 0, falsy ב-JS) ⇒ null; רשימה-מלאה ⇒ הרשימה. זהה-ביט.
//  • מוטביליות: `const d` → `final d` (מוקצה-פעם-אחת). אין locale/פורמט/getMonth.
//  • הטרינרי מחזיר את d עצמו (אותה רפרנס) — נשמר.

/// Allowed donation designations for a member. Org manager ⇒ null (no restriction);
/// otherwise the member-card designation list, or null when empty/absent.
/// Verbatim port of new/atoms/allowed-designations-for.mjs (`allowedDesignationsFor`).
/// Neighbours `isOrgManager`/`overrideOf` are injected as sockets (Law 1/3).
List<dynamic>? allowedDesignationsFor(
  String email,
  Map<String, dynamic> org,
  bool Function(String, Map<String, dynamic>) isOrgManager,
  Map<String, dynamic> Function(String, Map<String, dynamic>) overrideOf,
) {
  if (isOrgManager(email, org)) return null;
  final d = overrideOf(email, org)['designations'] as List<dynamic>?;
  return (d != null && d.isNotEmpty) ? d : null;
}
