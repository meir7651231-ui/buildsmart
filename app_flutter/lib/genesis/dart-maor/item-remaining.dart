// חוט · item-remaining (Dart) — הנותר-במלאי של פריט-קטלוג (לב הכרעה 18).
// חוזה: item-remaining.contract.md
// המרה מ-new/atoms/item-remaining.mjs — התנהגות זהה-לחלוטין (חוק-4).
// אפס import (dart-core + dart:math בלבד). השכן liveRedemptions = שקע-הצבה (חוק-1).
import 'dart:math';

int? itemRemaining(
  Map<String, dynamic> db,
  String itemId,
  Iterable<dynamic> Function(dynamic assignment) liveRedemptions,
) {
  // db.shopItems.find(i => i.id === itemId)  →  null אם לא-נמצא (JS find מחזיר undefined)
  Map<String, dynamic>? item;
  for (final i in (db['shopItems'] as List)) {
    if ((i as Map)['id'] == itemId) {
      item = i.cast<String, dynamic>();
      break;
    }
  }
  // !item || item.stock === undefined  →  כלל-2: מפתח-חסר, לא null-מפורש
  if (item == null || !item.containsKey('stock')) return null;

  var used = 0;
  for (final a in (db['shopAssignments'] as List)) {
    // db.shopProducts.find(x => x.id === a.productId)
    Map<String, dynamic>? p;
    for (final x in (db['shopProducts'] as List)) {
      if ((x as Map)['id'] == (a as Map)['productId']) {
        p = x.cast<String, dynamic>();
        break;
      }
    }
    if (p == null) continue; // if (!p) continue

    for (final r in liveRedemptions(a)) {
      // p.components.find(x => x.id === r.componentId)  →  אופציונלי (c?.itemId)
      Map<String, dynamic>? c;
      for (final x in (p['components'] as List)) {
        if ((x as Map)['id'] == (r as Map)['componentId']) {
          c = x.cast<String, dynamic>();
          break;
        }
      }
      if (c != null && c['itemId'] == itemId) used++;
    }
  }

  // Math.max(0, item.stock - used)
  return max(0, (item['stock'] as num).toInt() - used);
}
