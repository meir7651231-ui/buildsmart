// ⚛️ אטום-Dart (דרגת-חוזה) · famEnrollments — כל שיבוצי בני-המשפחה (כולל ended/wait).
// מוצא: maor/src/components/families/lib.ts:69-78 · המקור: new/atoms/fam-enrollments.mjs —
//   `export function famEnrollments(db, fam) {
//      const ids = new Set(fam.members.map((m) => m.id));
//      return db.enrollments.filter((e) => ids.has(e.memberId));
//    }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: סינון db.enrollments לפי חברות-הבן במשפחה (Set של member-ids). בלי סינון-סטטוס —
//        ended/wait נכללים (היסטוריה/דוחות). הגרסה ה"חיה" (famLiveEnrollments) = חוט אחר מעל זה.
// שקעים (חוק-1): db (Map עם 'enrollments' → List) · fam (Map עם 'members' → List של Map בעלי 'id').
// קלט: db, fam. פלט: מערך-שיבוצים — אותן הפניות בדיוק לרשומות-המקור (=== של JS ⇒ identical), סדר-המקור נשמר.
//
// הערת-המרה (מקור→Dart): המנוע לא הפיק טיוטה — הומר ידנית מהמקור. filter של JS = where/comprehension
//        ב-Dart — שומר גם סדר וגם זהות-הפניה (מוסיף את e עצמו, לא עותק). ids כ-Set שומר סמנטיקת has.
//        אין locale/פורמט/getMonth/truthiness/מוטביליות במקור — כלל-המרה כלשהו לא חל.

/// All enrollments of a family's members (including ended/wait — full history).
/// Filters `db['enrollments']` by member-id membership. Verbatim behaviour of the
/// JS source `famEnrollments`: source order preserved, records returned by identity.
List<Object?> famEnrollments(Map db, Map fam) {
  final members = fam['members'] as List;
  final ids = <Object?>{for (final m in members) (m as Map)['id']};
  final enrollments = db['enrollments'] as List;
  return [
    for (final e in enrollments)
      if (ids.contains((e as Map)['memberId'])) e,
  ];
}
