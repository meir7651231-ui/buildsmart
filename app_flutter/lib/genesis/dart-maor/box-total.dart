// ⚛️ אטום-Dart (דרגת-חוזה) · boxTotal — סך-הריקונים של קופת-צדקה.
// מוצא: maor/src/components/tzedaka/lib.ts:52-55 · המקור: new/atoms/box-total.mjs —
//   `box.collections.reduce((a,c) => a + (Number.isFinite(c.amount) ? c.amount : 0), 0)`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: סכימת `amount` על `box.collections`; רק מספר-סופי נספר — NaN / Infinity /
//        מחרוזת ("50") / null נבלעים כ-0 (המקור אינו מכפה מחרוזות).
// שקע (חוק-1): אין — אטום עצמאי מוחלט (Number.isFinite = שפה).
// קלט: box עם collections: List של Map בעלי מפתח 'amount'. פלט: num (0 כשאין ריקונים).
//
// הערת-המרה (מקור→Dart, המנוע לא הפיק טיוטה — נכתב מהמקור):
//  • Number.isFinite(x) של JS **אינו מכפה** ⇒ '50' (String) מחזיר false, נבלע כ-0.
//    ב-Dart: int תמיד-סופי; double רק כש-isFinite; כל טיפוס-אחר (String/null) = לא-סופי.
//  • amount הטרוגני (int/double/String/null) ⇒ הטיפוס Object?; הצבירה num מ-0 (כמו reduce,0).
//  • אין locale/פורמט/getMonth/מוטביליות; total = var num (נצבר), c/amount = final.

/// True only for a JS-`Number.isFinite`-style finite number: a Dart [int] (always
/// finite), or a [double] that is finite (not NaN/±Infinity). Any other type —
/// String, null, bool — is not a finite number, exactly like JS (no coercion).
bool _isFiniteNumber(Object? v) => v is int || (v is double && v.isFinite);

/// Sum of `amount` over `box['collections']`, counting only finite numbers.
/// NaN / Infinity / a numeric string ("50") / null are swallowed as 0 — verbatim
/// behaviour of the JS source `boxTotal`.
num boxTotal(Map box) {
  final collections = box['collections'] as List;
  num total = 0;
  for (final c in collections) {
    final amount = (c as Map)['amount'];
    total += _isFiniteNumber(amount) ? (amount as num) : 0;
  }
  return total;
}
