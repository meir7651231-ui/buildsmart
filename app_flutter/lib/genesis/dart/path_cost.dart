// ⚛️ אטום-Dart (דרגת-חוזה) · pathCost
// תפקיד: עלות-נתיב — סכום עלויות-הקשת על-פני נתיב-מוצרים סמוכים.
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:496-502
//        (‏_pathCost, פרטי-במקור). מקודם ל-public (כלל-הגלגול). חוק-4.
// אחים-שסוקטו/הוטבעו:
//   • `_edgeCost(a, b)` (עוזר-שכן, install_engine.dart) ⇒ **שקע** `edgeCost`
//     (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע).
//   • `LipskeyCatalogProduct` (טיפוס-קטלוג גדול) ⇒ **פרמטר-טיפוס גנרי** `<T>`
//     (האטום נוגע רק במבנה-הרשימה) — חוק-1.
// טוהר: אפס import-אטום (dart:core בלבד).
//
// קלט:  path     — נתיב-מוצרים מסודר (List<T>).
//       edgeCost — שקע: עלות-הקשת בין שני מוצרים סמוכים (int).
// פלט:  int — סכום `edgeCost(path[i], path[i+1])` על כל הזוגות הסמוכים (0 אם ‏<2).

/// Total path cost: sum of [edgeCost] over consecutive pairs of [path].
/// Verbatim behaviour of install_engine.dart:496-502, with the sibling
/// `_edgeCost` injected as a socket and the catalog type made generic.
int pathCost<T>(
  List<T> path, {
  required int Function(T a, T b) edgeCost,
}) {
  var c = 0;
  for (var i = 0; i < path.length - 1; i++) {
    c += edgeCost(path[i], path[i + 1]);
  }
  return c;
}
