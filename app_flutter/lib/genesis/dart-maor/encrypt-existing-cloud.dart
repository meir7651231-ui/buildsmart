// ⚛️ אטום-Dart (דרגת-חוזה) · encryptExistingCloud — מיגרציית-הצפנה חד-פעמית:
// כל ה-DB נדחף מחדש מוצפן דרך נתיב-ה-push הקיים והבדוק.
// מוצא: maor/src/lib/cloud.ts:481-489 → new/atoms/encrypt-existing-cloud.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). השכנים pushDiff/fullDbDiff/
//        supKeyMapOf הוזרקו כשקעים (חוק-1 — אפס import פנימי).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: pushDiff(fullDbDiff(db), dek, supKeyMapOf(db.supporters)) — הרכבה בלבד.
//        fullDbDiff ו-supKeyMapOf סינכרוניים; pushDiff מוחזק ב-await.
// קלט:  db (עם supporters) · dek · 3 שקעים (pushDiff · fullDbDiff · supKeyMapOf).
// פלט:  Future<void>. דחיית pushDiff מבעבעת כלשונה (אין catch) — כמו במקור-ה-JS.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • גישת-תכונה `db.supporters` של JS ⇒ חיפוש-מפה `db['supporters']` ב-Dart
//    (db הוא אובייקט/Map); רפרנס-הרשימה נשמר זהה (אותה כתובת) ⇒ identical עובד.
//  • סדר-הערכת-ארגומנטים שמאל→ימין זהה בשתי השפות; fullDbDiff לפני supKeyMapOf.
//  • await על תוצאת pushDiff — נכון גם ל-Future וגם לערך-מיידי (סמנטיקת JS await).

typedef PushDiff = dynamic Function(dynamic diff, dynamic dek, dynamic keyMap);
typedef FullDbDiff = dynamic Function(dynamic db);
typedef SupKeyMapOf = dynamic Function(dynamic supporters);

/// One-shot cloud re-encryption migration: push the full DB (entities + meta)
/// back up encrypted, via the existing tested push path — the full DB as a
/// diff, with the DEK, and the skey map (data-enforcement: if on, the migration
/// also keeps skey on enforced collections). Verbatim behaviour of the JS source
/// new/atoms/encrypt-existing-cloud.mjs.
Future<void> encryptExistingCloud(
  dynamic db,
  dynamic dek,
  PushDiff pushDiff,
  FullDbDiff fullDbDiff,
  SupKeyMapOf supKeyMapOf,
) async {
  // אכיפת-נתונים: אם דלוקה, גם מיגרציית-ההצפנה שומרת skey על אוספים-נאכפים.
  await pushDiff(fullDbDiff(db), dek, supKeyMapOf(db['supporters']));
}
