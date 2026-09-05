// ⚛️ אטום-Dart (דרגת-חוזה) · isJunkContact — כרטיס-vCard זבל שאין טעם לייבא.
// מוצא: maor/src/lib/vcardImport.ts:229-235 · המקור: new/atoms/is-junk-contact.mjs.
// חוזה: new/atoms/is-junk-contact.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: כרטיס זבל = בלי שם (גם רווחים-בלבד ⇒ trim), או שכל הטלפונים קצרים-מדי
//        (פחות מ-5 ספרות אחרי חילוץ-ספרות) **וגם** אין אף מייל.
// שקעים (חוק-1 — קריאת-שכן הוזרקה כפרמטר):
//   digitsOnly(s) — מחלץ ספרות-בלבד ממחרוזת (במקור: (s||'').replace(/\D/g,'')).
// שקע c ממודל כ-Map: {'fullName': String, 'phones': List<Map{'value':String}>, 'emails': List}.
// קלט: c + שקע-digitsOnly. פלט: bool (true = זבל, לא לייבא).
//
// הערות-המרה (מקור→Dart):
//   • המנוע (dart-from-maor/is-junk-contact.dart.draft) פלט גישת-שדה `c.fullName`/`c.phones`/
//     `c.emails` על `dynamic c` — נכשל על Map (אין getter כזה). התיקון: גישת-מפתח.
//   • `!c.fullName.trim()` של JS: trim מחזיר String, `!''` = true ⇒ `.trim().isEmpty`.
//   • `realPhone` הוא bool אמיתי מ-`.some`/`.any` ⇒ `!realPhone` שלילה-בוליאנית ישירה;
//     שקע-ה-_falsy שהמנוע שתל מיותר (המקור לא מפעיל truthiness על ערך לא-בוליאני כאן).
//   • אין locale/פורמט/getMonth/מוטביליות מעורבים.

/// Returns whether a vCard contact is junk (not worth importing).
/// Verbatim behaviour of the JS source `isJunkContact`.
bool isJunkContact(Map c, dynamic Function(dynamic) digitsOnly) {
  if ((c['fullName'] as String).trim().isEmpty) return true;
  final phones = c['phones'] as List;
  final realPhone =
      phones.any((p) => (digitsOnly(p['value']) as String).length >= 5);
  return !realPhone && (c['emails'] as List).isEmpty;
}
