// ⚛️ אטום-Dart (דרגת-חוזה) · compatibleWith
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:437-443
//        (חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • kCompatCatalog — הקטלוג-הגלובלי (install_engine.dart:439) ⇒ שקע `catalog`.
//   • canConnect(anchor, p) (install_engine.dart:440) ⇒ שקע `canConnect`
//     (האטום can_connect.dart הנפרד — שכן, לא import).
//   • productSuitableForTemp(p, tempC) (install_engine.dart:440) ⇒ שקע
//     `suitableForTemp` (חוט-שכן).
//
// ⚠️ מטמון-הזיכרון `_compatCache` (install_engine.dart:436-439) הושמט: הוא
//    אופטימיזציית-ביצועים בלבד — הפלט זהה-ביט (התיעוד במקור: "the result depends
//    only on (anchor.sku, tempC) because the catalog is const"). כשהקטלוג מוזרק
//    כשקע, מטמון חוצה-קטלוגים היה **לא-נכון**; לכן הושמט, וההתנהגות (הרשימה
//    המוחזרת) נשמרת verbatim — הסינון והמיון זהים בדיוק למקור.
//
// קלט:  anchor          — CompatNode (sku · categoryHe).
//       catalog         — List<CompatNode>: מרחב-החיפוש (היה kCompatCatalog).
//       canConnect      — שקע bool Function(CompatNode a, CompatNode b).
//       suitableForTemp — שקע bool Function(CompatNode p, int tempC).
//       tempC           — טמפרטורת-הקו (°C, ברירת-מחדל 20 · install_engine.dart:438).
// פלט:  List<CompatNode> — כל מי שמתחבר-לעוגן וגם מתאים-לטמפ׳ (install_engine.dart:440),
//        ממויין כך שמוצרים באותה קטגוריה כמו העוגן קודמים (מפתח-מיון בינארי 0/1,
//        install_engine.dart:442-443).

/// מחזיק-קלט טהור: רק שני השדות ש-compatibleWith קורא (install_engine.dart:439-443).
/// `sku` מזהה-מוצר (מועבר לשקעים); `categoryHe` = קטגוריה-עברית למפתח-המיון.
class CompatNode {
  final String sku;
  final String categoryHe;
  const CompatNode({required this.sku, this.categoryHe = ''});
}

/// עד [k]-מתחברים לעוגן — התנהגות verbatim של install_engine.dart:437-443.
List<CompatNode> compatibleWith(
  CompatNode anchor, {
  required List<CompatNode> catalog,
  required bool Function(CompatNode a, CompatNode b) canConnect,
  required bool Function(CompatNode p, int tempC) suitableForTemp,
  int tempC = 20,
}) =>
    catalog
        .where((p) => canConnect(anchor, p) && suitableForTemp(p, tempC))
        .toList()
      ..sort((a, b) => (a.categoryHe == anchor.categoryHe ? 0 : 1)
          .compareTo(b.categoryHe == anchor.categoryHe ? 0 : 1));
