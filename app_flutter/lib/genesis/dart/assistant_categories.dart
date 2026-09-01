// ⚛️ אטום-Dart (דרגת-חוזה) · assistantCategories
// מוצא: buildsmart/app_flutter/lib/logic/assistant_intent.dart:52-59 (assistantCategories;
//        חוק-4 — התנהגות זהה, לא-משופרת). המקור: קבוצה מ-categoryHe של כל מוצר,
//        המרה לרשימה ומיון: `<String>{for (final p in resolvedCatalogProducts) p.categoryHe}.toList()..sort()`.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט dart:core).
// שקע (חוק-3/דיבר-3: קריאה-לשכן ⇒ פרמטר-שקע):
//   השכן `resolvedCatalogProducts` (מקור-הקטלוג הפעיל, v2-מודע) + הגישה `p.categoryHe`
//   הופכים לשקע `categories` — רצף מחרוזות-הקטגוריה הגולמי (טרם דדופ/מיון).
//   טיפוס-השכן `Product` גדול מכדי-להטביע (לא enum/record קטן) ⇒ מסוקט כרצף-מחרוזות.
// קלט:  categories — Iterable<String>: categoryHe פר-מוצר (עם כפילויות, בסדר-המקור).
// פלט:  List<String> — קטגוריות ייחודיות, ממוינות בסדר-ברירת-המחדל (String.compareTo,
//        קוד-יחידות UTF-16 ⇒ סדר-אלפבית עברי). דדופ שומר-הופעה-ראשונה ⇒ ואז מיון.

/// Distinct, sorted Hebrew category list of the active catalog.
/// Verbatim behaviour of assistant_intent.dart:52-59 with the catalog source injected:
/// dedup into a Set, then `toList()..sort()` (default lexicographic / UTF-16 order).
List<String> assistantCategories({required Iterable<String> categories}) {
  final set = <String>{for (final c in categories) c};
  return set.toList()..sort();
}
