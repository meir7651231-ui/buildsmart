// ⚛️ אטום-Dart (דרגת-חוזה) · startCampaign — פתיחת קמפיין-חיוג: דדופ + סינון-falsy, הסדר נשמר.
// מוצא: maor/src/lib/dialer.ts:25-36 · המקור: new/atoms/start-campaign.mjs · חוזה: start-campaign.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מרשימת-מזהים (ייתכנו כפולים/ריקים) נבנה תור-חיוג — מופע-ראשון מנצח,
//        כל ערך falsy מסונן, סדר-ההזנה נשמר. מוחזרת מכונת-מצב טרייה:
//        {name, startedAt, queue, total, log:[]} — ‏total קפוא = queue.length.
// שקע (חוק-5): iso — חותמת-הפתיחה מוזרקת; האטום לא קורא לשעון.
//
// הערות-המרה (מקור→Dart):
// - ‏`!id` של JS = truthiness (חוק-7) ⇒ עוזר מקומי _falsy: ‏null / false / 0 / NaN / '' —
//   בדיוק קבוצת-ה-falsy של JS על הטיפוסים שנושא JSON (אין undefined/0n נפרדים ב-Dart:
//   ‏undefined⇒null, ‏BigInt לא מגיע מ-JSON).
// - ‏`new Set()` + ‏has/add של JS = ‏SameValueZero ⇒ ‏Set של Dart (==/hashCode) שקול
//   לערכים העוברים-סינון (מחרוזות/מספרים/אובייקטים — NaN/0/-0 ממילא falsy ומסוננים).
// - אין locale/תאריך/מיון/מוטציית-קלט — ids נקרא בלבד; queue/log מערכים טריים.

/// JS-truthiness (חוק-7): הערכים ה-falsy של JS — null (גם undefined), false,
/// 0/-0/NaN, ומחרוזת ריקה. כל השאר truthy.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    (v is num && (v == 0 || v.isNaN)) ||
    (v is String && v.isEmpty);

/// פתיחת קמפיין-חיוג: דדופ (מופע-ראשון מנצח) + סינון-falsy; הסדר המקורי נשמר.
/// מחזיר {name, startedAt, queue, total, log:[]} — התנהגות זהה למקור-ה-JS.
dynamic startCampaign(dynamic name, dynamic ids, dynamic iso) {
  final seen = <dynamic>{};
  final queue = <dynamic>[];
  for (final id in (ids as Iterable)) {
    if (_falsy(id) || seen.contains(id)) continue;
    seen.add(id);
    queue.add(id);
  }
  return {
    'name': name,
    'startedAt': iso,
    'queue': queue,
    'total': queue.length,
    'log': <dynamic>[],
  };
}
