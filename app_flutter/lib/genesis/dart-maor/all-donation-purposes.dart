// ⚛️ אטום-Dart (דרגת-חוזה) · allDonationPurposes — איחוד-ומיון ייעודי-תרומה של רשימת-תורמים.
// מוצא: maor/src/components/supporters/lib.ts:94-98 · המקור: new/atoms/all-donation-purposes.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן supporterPurposes הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: כל ייעודי-התרומה הקיימים בפועל אצל רשימת-תורמים — איחוד (distinct) של
//        ייעודי-כל-תורם, ממוין localeCompare (א-ב עברי / לטיני).
// קלט:  supporters (איטרבל של תורמים) · השקע supporterPurposes(sup) ⇒ List<String>
//        (נקרא פעם-אחת פר-תורם). פלט: List<String> ייחודי וממוין.
//
// הערות-המרה (מקור→Dart):
//  • `new Set()` → `<String>{}` (LinkedHashSet) — דדופ; סדר-ההכנסה נשמר אך חסר-משמעות
//    כי ה-sort שלאחריו קובע. `set.add(p)` → `set.add(p)` זהה.
//  • `[...set].sort((a,b)=>a.localeCompare(b))` → `set.toList()..sort((a,b)=>a.compareTo(b))`.
//    localeCompare⇒compareTo: עבור אותיות-עברית (U+05D0..) ולטיניות ה-code-unit-order
//    זהה לסדר ה-collation ⇒ פלט זהה-ביט לחמש דוגמאות-החוזה. (dart:core בלי Intl —
//    חוק-1: אין import; אילו נדרשה collation-locale מלאה היא הייתה הופכת לשקע.)
//  • שקע-הקריאה-לשכן: `supporterPurposes(s)` פרמטר-פונקציה — לא import (חוק-3).
//  • מוטביליות: הכול `final`; אין var מוקצה-מחדש. אין locale/פורמט/getMonth/truthiness.

/// All existing donation purposes across a supporter list — distinct union of each
/// supporter's purposes, sorted (localeCompare in the JS source → compareTo here).
/// Verbatim port of new/atoms/all-donation-purposes.mjs (`allDonationPurposes`).
/// The neighbour call `supporterPurposes` is injected as a socket (Law 1/3).
List<String> allDonationPurposes<T>(
  Iterable<T> supporters,
  List<String> Function(T) supporterPurposes,
) {
  final set = <String>{};
  for (final s in supporters) {
    for (final p in supporterPurposes(s)) {
      set.add(p);
    }
  }
  final out = set.toList();
  out.sort((a, b) => a.compareTo(b));
  return out;
}
