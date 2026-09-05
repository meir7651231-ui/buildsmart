// ⚛️ אטום-Dart (דרגת-חוזה) · filterProducts — סינון חבילות-הקטלוג (שם/תיאור, פעילות-בלבד רשות).
// מוצא: maor/src/components/shop/lib.ts:538-546 · המקור: new/atoms/filter-products.mjs —
//   export function filterProducts(products, q, onlyActive, smartFilter) {
//     const base = onlyActive ? products.filter((p) => p.active) : [...products];
//     return smartFilter(q, base, (p) => [p.name, p.desc]);
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-1 — השכן smartFilter
//        הוזרק כשקע-פרמטר (אפס import פנימי). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// הערות-המרה (DART-PORTING-RULES):
//  • כלל-7 (truthiness): `onlyActive ?` ו-`.filter((p) => p.active)` הם truthiness של JS,
//    לא bool-בלבד. שקע `_truthy` מחקה את falsy-JS (false/0/NaN/''/null) — לא `if(x)` של Dart.
//  • מוטביליות: `[...products]` = עותק-רדוד (מערך-חדש, אותם אלמנטים) ⇒ `List.of` בענף-else;
//    `.where(...).toList()` בענף-onlyActive מייצר גם הוא מערך-חדש (out !== products, כמו במקור).
//  • סדר: `.where`/`List.of` שומרים סדר-מקור (יציב) — אין מיון, אין חשש כלל-1.
//  • getTerms: `(p) => [p.name, p.desc]` ⇒ `[p['name'], p['desc']]` (אובייקט-JS ⇒ Map-Dart).

/// Filters catalog product packages. When [onlyActive] is truthy the base is the
/// active-only products; otherwise a shallow copy of all products (source order).
/// The neighbour [smartFilter] is injected as a socket (Law-1) and applied over the
/// base with a term-extractor yielding [name, desc]. Verbatim behaviour of the JS source.
dynamic filterProducts(
  List products,
  Object? q,
  Object? onlyActive,
  dynamic Function(Object? q, List base, List Function(dynamic p) getTerms) smartFilter,
) {
  final List base = _truthy(onlyActive)
      ? products.where((p) => _truthy(p['active'])).toList()
      : List.of(products);
  return smartFilter(q, base, (p) => [p['name'], p['desc']]);
}

/// JS truthiness (mirrors `onlyActive ?` / `.filter((p) => p.active)`).
/// Falsy in JS: false, 0, NaN, '', null/undefined — everything else truthy.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
