// ⚛️ אטום-Dart (דרגת-חוזה) · itemOf — פענוח רכיב-בחבילה לפריט-הקטלוג + דריסות (SHOP4, הכרעה 18)
// מוצא: maor/src/components/shop/lib.ts:49-78 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/item-of.mjs · החוזה: item-of.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). אין שקעים —
//        קריאה ישירה על db בלבד (חוק-1), בדיוק כמקור.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • כלל-2 (null≠undefined): JSON.stringify של JS **משמיט מפתחות בעלי-ערך undefined**.
//    בענף-הנפילה המקור כותב תמיד `stock: comp.stock` / `validDays: comp.validDays`,
//    ורכיב-ישן בלי השדות ⇒ undefined ⇒ המפתח נעלם מה-JSON (דוגמה 4). כדי לשקף
//    את הפלט-הנצפה ביט-אחר-ביט, אנו **מוסיפים את המפתח רק כשהערך non-null** —
//    Dart Map = LinkedHashMap ⇒ סדר-ההוספה נשמר בדיוק כסדר-object-literal של JS.
//  • `comp.value ?? 0` / `?? item.value`: JS `??` תופס null+undefined; Dart `??` תופס null.
//    ערך 0 מוגדר ⇒ אינו null ⇒ דורס (דוגמה 2, basePrice:0). התנהגות זהה.
//  • אין locale/פורמט/getMonth/מודולו/מיון מעורבים — שאר הכללים לא רלוונטיים.
//
/// Resolve a package component to its catalog item + component overrides:
/// the item (found in db.shopItems by comp.itemId) wins on identity fields,
/// while value/basePrice of the component override (?? — only when defined).
/// A pre-migration component (empty/broken itemId) falls back to its own
/// compatibility fields: no `holidays`, active:true, value/basePrice ?? 0.
/// Verbatim of the JS source new/atoms/item-of.mjs (Law 4).
Map<String, dynamic> itemOf(Map<String, dynamic> db, Map<String, dynamic> comp) {
  final List items = db['shopItems'] as List;
  Map<String, dynamic>? item;
  for (final i in items) {
    if ((i as Map)['id'] == comp['itemId']) {
      item = i.cast<String, dynamic>();
      break;
    }
  }

  if (item == null) {
    // נפילת-תאימות: שדות-הרכיב עצמו, בלי holidays, active:true.
    final Map<String, dynamic> out = {
      'itemId': comp['itemId'],
      'name': comp['label'],
      'kind': comp['kind'],
      'storeId': comp['storeId'],
      'value': comp['value'] ?? 0,
      'basePrice': comp['basePrice'] ?? 0,
    };
    // כלל-2: undefined ⇒ המפתח מושמט מ-JSON.stringify.
    if (comp['stock'] != null) out['stock'] = comp['stock'];
    if (comp['validDays'] != null) out['validDays'] = comp['validDays'];
    out['active'] = true;
    return out;
  }

  // מצביע תקין: הפריט גובר על שדות-הזהות; value/basePrice של הרכיב דורסים (?? ).
  final Map<String, dynamic> out = {
    'itemId': item['id'],
    'name': item['name'],
    'kind': item['kind'],
    'storeId': item['storeId'],
    'value': comp['value'] ?? item['value'],
    'basePrice': comp['basePrice'] ?? item['basePrice'],
  };
  if (item['stock'] != null) out['stock'] = item['stock'];
  if (item['validDays'] != null) out['validDays'] = item['validDays'];
  if (item['holidays'] != null) out['holidays'] = item['holidays'];
  out['active'] = item['active'];
  return out;
}
