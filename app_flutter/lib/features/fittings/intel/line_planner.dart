// 🧠 מנוע-אביזרים · פאזה D (אינטליגנציה) — מתכנן-הקו (smart line build). **הגשר**
// בין גרף-החיבורים החי (`findShortestPath`/`buildInstallation` → מוצרי-קטלוג) לבין
// מנוע-האביזרים שלי: מוצרים → רצף-`RunElement` → 3D (`assembleRoute`) + spec
// (`buildableSpecFor`). היכולת מאחורי כפתור — מגודרת `kFittingEngineIntel` (default-OFF).
//
// 🔒 טהור · אף מסך-חי אינו מייבא ⇒ tree-shaken כשהדגל כבוי. `install_engine` כבר
// בבנייה-החיה (מסכי-התקנה), לכן ייבואו כאן אינו מוסיף קוד-חי — הזרימה byte-identical.
// מקורקע: `findShortestPath` (נתיב) · `familyOf`/`odOf`/`od2Of` (מיפוי-משפחה · פאזה 0).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/logic/install_engine.dart' show findShortestPath;
import 'package:flutter/foundation.dart' show immutable, listEquals;

/// תוכנית-קו של אביזרים: המוצרים בנתיב + רצף-ה-`RunElement` הפריס (ל-3D/spec) +
/// האם נמצא נתיב-חיבור שלם. מוצר לא-אביזרי (צינור/קבוע) נשמר ב-`products` אך מדולג
/// מ-`route` (המנוע מרנדר רק אביזרים · M1 · לעולם לא מיקום-שגוי).
@immutable
class FittingLinePlan {
  const FittingLinePlan({
    required this.products,
    required this.route,
    required this.complete,
  });

  /// המוצרים בנתיב (כולל צינורות/קבועים), בסדר-החיבור.
  final List<LipskeyCatalogProduct> products;

  /// תת-הרצף הפריס-במנוע (אביזרים בלבד) — מזין `assembleRoute`/`buildableSpecFor`.
  final List<RunElement> route;

  /// האם נמצא נתיב-חיבור שלם (findShortestPath ≠ null).
  final bool complete;

  bool get isRenderable => route.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is FittingLinePlan &&
      listEquals(other.products, products) &&
      listEquals(other.route, route) &&
      other.complete == complete;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(products), Object.hashAll(route), complete);
}

/// ממפה רצף-מוצרים לרצף-`RunElement` (הגשר הטהור · פאזה 0). מוצר שאינו אביזר-מנוע
/// (`familyOf`==null · צינור/קבוע) מדולג. ברך מקבלת כיוון-ברירת-מחדל `up` כדי שתתכופף
/// חזותית ב-3D (העידון-המרחבי = פרוסה מאוחרת); שאר האביזרים `right` (ישר).
List<RunElement> routeFromProducts(List<LipskeyCatalogProduct> products) {
  final out = <RunElement>[];
  for (final p in products) {
    final label = familyOf(p);
    if (label == null) continue; // צינור/קבוע — לא אביזר-מנוע
    final family = Family.fromLabel(label);
    if (family == null) continue;
    final od = odOf(p);
    if (od == null) continue;
    final dir = (family == Family.elbow90 || family == Family.elbow45)
        ? Dir.up
        : Dir.right;
    out.add(RunElement(family, od, dir: dir, od2: od2Of(p)));
  }
  return out;
}

/// **מתכנן-הקו** (D1): שני-קצוות → נתיב-חיבור (`findShortestPath`, מקורקע) → תוכנית-
/// קו אביזרים. אין נתיב → תוכנית-ריקה (`complete=false`), לעולם לא זריקה (M1).
FittingLinePlan planFittingLine(
  LipskeyCatalogProduct from,
  LipskeyCatalogProduct to, {
  int maxDepth = 6,
  int tempC = 20,
}) {
  final path = findShortestPath(from, to, maxDepth: maxDepth, tempC: tempC);
  if (path == null) {
    return const FittingLinePlan(products: [], route: [], complete: false);
  }
  return FittingLinePlan(
    products: path,
    route: routeFromProducts(path),
    complete: true,
  );
}
