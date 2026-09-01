// ⚛️ אטום-Dart (דרגת-חוזה) · clean
// מוצא: buildsmart/app_flutter/lib/features/word_finder/keyboard_predictions.dart:57-69 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_clean` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  raw — מחרוזות גולמיות; max — תקרה.
// פלט:  מקוצצות · בלי ריקות · בלי כפילויות (הראשונה נשמרת) · חתוך ל-max —
//        הכול שומר-סדר.

/// ניקוי [raw]: trim · dedup (ראשון) · חיתוך ל-[max], שומר-סדר. טהור.
List<String> clean(Iterable<String> raw, int max) {
  final seen = <String>{};
  final out = <String>[];
  for (final s in raw) {
    final t = s.trim();
    if (t.isEmpty) continue;
    if (!seen.add(t)) continue; // duplicate → keep the first occurrence only
    out.add(t);
    if (out.length >= max) break; // cap AFTER de-dup/blank-drop
  }
  return out;
}
