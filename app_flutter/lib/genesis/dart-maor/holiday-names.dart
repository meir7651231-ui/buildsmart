// ⚛️ אטום-Dart (דרגת-חוזה) · holidayNames — כל שמות-החגים בסריקת 400 יום מעוגן-קבוע.
// מוצא: maor/src/components/shop/lib.ts:153-179 · המקור: new/atoms/holiday-names.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השכן holidayOf
//        (שם-חג לתאריך) מוזרק כשקע (חוק-1). המטמון-המודולרי של המקור הושמט (חוק-5).
//
// תפקיד: סורק 400 יום מ-2026-01-01 ומחזיר את שמות-החגים הייחודיים בסדר-הופעתם.
// קלט:  holidayOf — פונקציה DateTime→שם-חג (String) או ערך-שקרי (null/'') לאין-חג.
// פלט:  List<String> — שמות ייחודיים בסדר הופעתם הראשונה.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · getMonth (כלל בונה-תאריך): ה-JS משתמש ב-`start.getMonth()` (0-מבוסס) בתוך
//    `new Date(y, m, day+i)`; ב-Dart החודש 1-מבוסס. שני הצדדים עקביים בשיטתם
//    (ינואר), ולכן `DateTime(start.year, start.month, start.day + i)` שקול בדיוק —
//    אין להחסיר 1 (טעות-הטיוטה שהעבירה את הבסיס לדצמבר).
//  · truthiness (כלל 7): ה-JS בודק `if (name && ...)` — null/'' שקריים ⇒ מדולגים.
//    ב-Dart אין truthiness מרומז; שיקוף מפורש דרך `_truthy`.
//  · גלישת-יום: `DateTime(2026, 1, 1 + i)` עד i=399 מגלגל לחודשים הבאים בדיוק כמו
//    `new Date` של JS — סמנטיקת-Date משותפת, אין round-trip-guard כאן.
//  · הפלט הוא List<String> — הקלט המדולג לעולם null/'' ולכן ה-List טהור-String.

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// Scans 400 days from 2026-01-01 and returns the unique holiday names in first-
/// appearance order. `holidayOf` maps a date to a holiday name (falsy = no holiday).
/// Verbatim behaviour of the JS source new/atoms/holiday-names.mjs.
List<String> holidayNames(Object? Function(DateTime) holidayOf) {
  final out = <String>[];
  final seen = <String>{};
  final start = DateTime(2026, 1, 1, 12, 0, 0);
  for (var i = 0; i < 400; i++) {
    final d = DateTime(start.year, start.month, start.day + i);
    final name = holidayOf(d);
    if (_truthy(name) && !seen.contains(name)) {
      final s = name as String;
      seen.add(s);
      out.add(s);
    }
  }
  return out;
}
