// ⚛️ אטום-Dart (דרגת-חוזה) · normSearch
// תפקיד: נירמול-חיפוש עברי — lower-case · הסרת-ניקוד · קיפול-אותיות-סופיות ·
//        הסרת-מפרידים (גרש/מרכאות/מקף/נקודה/קו-תחתי) · trim.
// מוצא: buildsmart/app_flutter/lib/logic/text_normalize.dart:24-33 (‏normSearch; חוק-4).
// אחים-שסוקטו/הוטבעו:
//   • const-האח `kHebrewFinalFold` (מפת קיפול-סופיות; ערכיה לא בגוף-הטיוטה) ⇒
//     **הוטבע inline** כ-`_kHebrewFinalFold` verbatim. הערכים הוסקו מ**שם-הקבוע**
//     ("final-fold") ומהתקן העברי — 5 אותיות-סופיות → צורת-הבסיס: ך→כ · ם→מ ·
//     ן→נ · ף→פ · ץ→צ (חוק-8/דיבר 11: הסקה מגוף-הטיוטה, מתועדת).
//     המקור text_normalize.dart אינו בריפו ⇒ grep יחזיר ריק; הסקה במקום מקור.
//   • האח `normName` (טיוטה) הוא שכן, לא האטום.
// טוהר: אפס import (dart:core בלבד; RegExp מובנה).
//
// קלט:  t — טקסט-חיפוש חופשי (עברית/לועזית).
// פלט:  String מנורמל להשוואת-חיפוש.

// הוטבע verbatim (כלל const-אח): קיפול אות-סופית → אות-בסיס.
const Map<String, String> _kHebrewFinalFold = {
  'ך': 'כ', // U+05DA → U+05DB
  'ם': 'מ', // U+05DD → U+05DE
  'ן': 'נ', // U+05DF → U+05E0
  'ף': 'פ', // U+05E3 → U+05E4
  'ץ': 'צ', // U+05E5 → U+05E6
};

/// Hebrew search-normalization: lower-case, strip niqqud, fold final letters,
/// strip separators, trim. Verbatim behaviour of text_normalize.dart:24-33
/// (the sibling const `kHebrewFinalFold` inlined per the const-sibling rule).
String normSearch(String t) {
  var s = t.toLowerCase();
  s = s.replaceAll(RegExp('[֑-ׇ]'), ''); // ניקוד עברי (U+0591..U+05C7)
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(_kHebrewFinalFold[ch] ?? ch);
  }
  s = b.toString().replaceAll(RegExp('[\'"׳״\\-–._]'), '');
  return s.trim();
}
