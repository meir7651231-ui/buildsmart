// ⚛️ אטום-Dart (דרגת-חוזה) · redemptionsCsvRows — שורות-CSV של כל מימושי-החנות.
// מוצא: maor/src/components/shop/lib.ts:656-680 · המקור: new/atoms/redemptions-csv-rows.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מטריצת-CSV — כותרת קבועה ואז שורה לכל מימוש בכל שיוך, בסדר-הנתונים.
//   מבוטל מסומן ('בוטל ב-<תאריך>') ולא מוסתר. שיוך בלי מימושים לא מפיק שורות.
// שקעים (חוק-1/חוק-3 — קריאות-השכן הוזרקו כפרמטרים):
//   beneficiaryLabel(db, a, config) ⇒ תווית-מוטב (השכן הוזרק). נקרא פעם-אחת פר-שיוך.
//   itemOf(db, comp)               ⇒ פריט-קטלוג {name} עבור רכיב (השכן הוזרק).
// קלט: db {shopAssignments, shopProducts} · config (מועבר כמות-שהוא) · שני השקעים.
// פלט: List<List<dynamic>> — תאים מעורבים מחרוזת/מספר (paid/value מספריים כמקור).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • גישת-שדה JS (a.productId/p.id/r.date…) ⇒ מפתחות-Map ['productId']/['id']/['date'].
//   • `product?.components.find(...)` — קיצור-אופציונלי: product==null ⇒ comp=null (short-circuit).
//   • `find` לא-נמצא ⇒ null (JS undefined) — לולאה עם עצירה במקום firstWhere-שזורק.
//   • `comp ? … : ''` ⇒ `comp != null` (comp הוא Map-או-null; חוק-4 truthiness).
//   • `product?.name ?? ''` ⇒ product==null || name==null ⇒ '' .
//   • `r.rid ?? ''` ⇒ חסר/null ⇒ '' (null==undefined כאן: מפתח-חסר או ערך-null).
//   • `r.voidedAt ? 'בוטל…' : ''` ⇒ truthiness: מחרוזת לא-ריקה = truthy; חסר/null/'' = falsy.
//   • paid/value מועברים כמות-שהם (dynamic) — המקור לא ממיר; אין locale/getMonth.

/// Builds the CSV matrix of every shop redemption across all assignments:
/// a fixed header row, then one row per redemption in data order. Voided
/// redemptions are marked ('בוטל ב-<date>'), never hidden. Verbatim behaviour
/// of the JS source. Sockets (Law-1): [beneficiaryLabel] yields the recipient
/// label (called once per assignment), [itemOf] yields a component's catalog
/// item {name}. Missing component ⇒ item ''; missing product ⇒ package '';
/// missing rid ⇒ ''; non-voided ⇒ ''.
List<List<dynamic>> redemptionsCsvRows(
  Map<String, dynamic> db,
  dynamic config,
  String Function(Map<String, dynamic> db, dynamic a, dynamic config) beneficiaryLabel,
  dynamic Function(Map<String, dynamic> db, dynamic comp) itemOf,
 {required String Function(String) term}) {
  final List<List<dynamic>> rows = [
    [term('taryk'), term('mvtb'), term('pryt'), term('chbylh'), term('shvlm'), term('shvvy'), term('ayshvr'), term('mbvtl')],
  ];
  for (final a in (db['shopAssignments'] as List)) {
    // product = db.shopProducts.find(p => p.id === a.productId) — undefined אם לא-נמצא.
    Map? product;
    for (final p in (db['shopProducts'] as List)) {
      if (p['id'] == a['productId']) {
        product = p as Map;
        break;
      }
    }
    final who = beneficiaryLabel(db, a, config);
    for (final r in (a['redemptions'] as List)) {
      // comp = product?.components.find(c => c.id === r.componentId)
      Map? comp;
      if (product != null) {
        for (final c in (product['components'] as List)) {
          if (c['id'] == r['componentId']) {
            comp = c as Map;
            break;
          }
        }
      }
      rows.add([
        r['date'],
        who,
        comp != null ? itemOf(db, comp)['name'] : '',
        product != null ? (product['name'] ?? '') : '',
        r['paid'],
        r['value'],
        r['rid'] ?? '',
        _truthy(r['voidedAt']) ? term('bvtl-b') + (r['voidedAt'] as String) : '',
      ]);
    }
  }
  return rows;
}

// truthiness של JS לערך-voidedAt: null/חסר/''/false/0 ⇒ false; מחרוזת לא-ריקה ⇒ true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0;
  return true;
}
