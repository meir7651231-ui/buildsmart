// ⚛️ אטום-Dart (דרגת-חוזה) · intakeLog — יומן קליטות-מלאי: שורות חדש-ראשון + סה"כ עלויות.
// מוצא: maor/src/components/shop/lib.ts:588-593 · המקור: new/atoms/intake-log.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: לכל קליטה ב-db.shopIntakes מצרפים את שם-הפריט (itemId → shopItems; פריט-חסר
//        או name חסר ⇒ "—"), ממיינים תאריך-יורד (חדש-ראשון; שוויון-תאריך = סדר-ההזנה,
//        מיון יציב) ומסכמים totalCost של כל העלויות (תרומה-בעין cost=0 לא מוסיפה).
// קלט:  db = {shopIntakes:[{itemId, date, cost, …}], shopItems:[{id, name, …}]}.
// פלט:  {rows:[{intake, itemName}], totalCost}.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  · כלל 1 (מיון-יציב): JS Array.sort יציב; Dart List.sort לא-יציב ל-≥32. לכן ממיינים
//    רשימת-אינדקסים עם האינדקס-המקורי כשובר-שוויון (decorate-sort-undecorate) —
//    שוויון-תאריך שומר סדר-הזנה בדיוק כמו המקור.
//  · localeCompare על מחרוזות-ISO ('YYYY-MM-DD', ASCII) ≡ compareTo של Dart (code-unit).
//    b.date.localeCompare(a.date) = סדר-יורד ⇒ db.compareTo(da).
//  · כלל 2/7 (null≠undefined / truthiness): `find(...)?.name ?? '—'` — פריט-חסר או
//    name-חסר ⇒ '—'. ב-Dart מפתח-חסר מחזיר null ⇒ `?? '—'` תופס את שני המקרים.
//  · שימור-רפרנס: ה-intake מוחזר כמו-שהוא (אותה רפרנס), בלי העתקה (חוק-4).

/// Intake log for shop stock. Each intake is paired with its item name
/// (itemId → shopItems; missing item or missing name ⇒ "—"), sorted by date
/// descending (newest-first; equal dates keep insertion order — stable), plus
/// the sum of all costs (in-kind donation cost=0 does not add). Verbatim
/// behaviour of the JS source `intakeLog`.
Map<String, Object?> intakeLog(Map<String, Object?> db) {
  final intakes = db['shopIntakes'] as List;
  final items = db['shopItems'] as List;

  // map: לכל קליטה — שם-הפריט התואם (first match), או "—".
  final rows = <Map<String, Object?>>[];
  for (final intake in intakes) {
    final itemId = (intake as Map)['itemId'];
    Object? name;
    for (final it in items) {
      if ((it as Map)['id'] == itemId) {
        name = it['name'];
        break;
      }
    }
    rows.add({'intake': intake, 'itemName': name ?? '—'});
  }

  // מיון-יציב תאריך-יורד: ממיינים אינדקסים, אינדקס-מקורי = שובר-שוויון.
  final order = List<int>.generate(rows.length, (i) => i);
  order.sort((ia, ib) {
    final da = ((rows[ia]['intake'] as Map)['date'] as String);
    final db2 = ((rows[ib]['intake'] as Map)['date'] as String);
    final c = db2.compareTo(da); // descending (newest-first)
    if (c != 0) return c;
    return ia - ib; // stable tie-break — preserves insertion order
  });
  final sorted = <Map<String, Object?>>[for (final i in order) rows[i]];

  // totalCost = סכום כל העלויות (cost=0 לא מוסיף).
  num totalCost = 0;
  for (final r in sorted) {
    totalCost += ((r['intake'] as Map)['cost'] as num);
  }

  return {'rows': sorted, 'totalCost': totalCost};
}
