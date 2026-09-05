// ⚛️ אטום-Dart (דרגת-חוזה) · reenrollCounts — ספירת החלטות-חידוש-רישום.
// מוצא: maor/src/components/courses/lib.ts · המקור: new/atoms/reenroll-counts.mjs.
// טוהר: פונקציית top-level עצמאית + עוזרים פרטיים, אפס import (רק שפה/סטנדרט: dart:core).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: עובר על `rows` וסופר total + פילוח decision (yes/no/hold/undecided) + renewed.
// קלט:  rows — נתון-איטרבילי כלשהו (בשימוש-אמת: List<Map> עם decision/renewed).
// פלט:  Map בסדר-מקור {total, yes, no, hold, undecided, renewed}.
//
// הערות-המרה (מקור→Dart) — הסטיות שהמנוע פספס:
//  • ה-Golden מזין **מחרוזות**: ‏JS `for (const r of rows)` על String מרנן קוד-פוינטים,
//    כל תו הוא r. לתו אין `.renewed/.decision` ⇒ undefined ⇒ כל תו נספר כ-undecided.
//    ב-Dart String אינו Iterable ⇒ שקע-מרנן: `rows.runes` (קוד-פוינטים, נאמן ל-for..of).
//  • `r.renewed` / `r.decision` על ערך-לא-אובייקט = undefined ב-JS ⇒ `_prop` מחזיר null
//    לכל מה שאינו Map (חוק DART-PORTING #2: null≠undefined — כאן שניהם ⇒ ענף-else/falsy).
//  • truthiness של `if (r.renewed)` ≠ Dart bool ⇒ שקע `_truthy` מפורש
//    (DART-PORTING #7: falsy = null/false/0/NaN/'' ).
//  • טיפוסי-הספירה מוטבלים במפורש (int) — אין `c.total++` על map-literal (המנוע יצר קוד לא-מתקמפל).

/// עובר על [rows] וסופר total + פילוח החלטות (yes/no/hold/undecided) + renewed.
/// פורט ביט-זהה של new/atoms/reenroll-counts.mjs (`reenrollCounts`).
Map<String, int> reenrollCounts(dynamic rows) {
  final c = <String, int>{
    'total': 0,
    'yes': 0,
    'no': 0,
    'hold': 0,
    'undecided': 0,
    'renewed': 0,
  };
  for (final r in _iter(rows)) {
    c['total'] = c['total']! + 1;
    if (_truthy(_prop(r, 'renewed'))) c['renewed'] = c['renewed']! + 1;
    final decision = _prop(r, 'decision');
    if (decision == 'yes') {
      c['yes'] = c['yes']! + 1;
    } else if (decision == 'no') {
      c['no'] = c['no']! + 1;
    } else if (decision == 'hold') {
      c['hold'] = c['hold']! + 1;
    } else {
      c['undecided'] = c['undecided']! + 1;
    }
  }
  return c;
}

/// מרנן נאמן ל-`for...of` של JS: String ⇒ קוד-פוינטים (כל אחד כתו-בודד); אחרת Iterable כמו-שהוא.
Iterable<dynamic> _iter(dynamic rows) {
  if (rows is String) {
    return rows.runes.map((cp) => String.fromCharCode(cp));
  }
  return rows as Iterable<dynamic>;
}

/// גישת-שדה נאמנה ל-JS: על Map מחזירה את הערך (חסר ⇒ null); על כל דבר אחר ⇒ null (=undefined).
dynamic _prop(dynamic r, String key) {
  if (r is Map) return r[key];
  return null;
}

/// truthiness של JS: falsy = null/false/0/NaN/'' ; כל השאר truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
