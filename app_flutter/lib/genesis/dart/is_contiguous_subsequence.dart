// ⚛️ אטום-Dart (דרגת-חוזה) · isContiguousSubsequence
// תפקיד: האם needle מופיע כרצף-רציף (חלון עוקב) בתוך haystack — עם דרישת אורך-מינימלי 2.
// מוצא: buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:52-68 (‏_isContiguousSubsequence; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). אפס שקעים. פרטי-במקור (`_`) ⇒ פורסם public.
//        האח שמתחת (מיפוי-מיקום-מלאי) לא נקרא ⇒ לא-הוטבע.
//
// קלט:  needle   — רצף-החיפוש.
//        haystack — הרצף שבתוכו מחפשים.
// פלט:  bool — true אם needle (באורך ≥2 ו-≤ אורך-haystack) מופיע כחלון-עוקב זהה ב-haystack.

/// True iff [needle] appears as a contiguous window inside [haystack], requiring
/// `needle.length >= 2`. Verbatim of equipment_stock_join.dart:52-68.
bool isContiguousSubsequence(List<String> needle, List<String> haystack) {
  if (needle.length < 2 || needle.length > haystack.length) return false;
  final last = haystack.length - needle.length;
  outer:
  for (var i = 0; i <= last; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
