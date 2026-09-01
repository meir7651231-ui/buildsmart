// ⚛️ אטום-Dart · smartProductsForCat
// מוצא: buildsmart/app_flutter/lib/data/smart_tree.dart:2549-2550 (חצב-בינה · קטלוג-מוזרק · חוק-4).
// שקע: kSmartProducts ← דאטה-מוזרקת (מתחלף פר-ורטיקל)
//
// טיפוס-מינימום SmartProduct: רק השדה `cat` שהפונקציה נוגעת בו + const ctor.

/// צורת-מינימום של SmartProduct — רק מה ש-smartProductsForCat קורא.
class SmartProduct {
  final String cat;
  const SmartProduct({required this.cat});
}

/// המוצרים-החכמים בקטגוריה [cat] מתוך הקטלוג-המוזרק.
/// verbatim smart_tree.dart:2549-2550 (kSmartProducts ⇒ שקע catalog).
List<SmartProduct> smartProductsForCat(
  String cat, {
  required List<SmartProduct> catalog,
}) =>
    catalog.where((p) => p.cat == cat).toList();
