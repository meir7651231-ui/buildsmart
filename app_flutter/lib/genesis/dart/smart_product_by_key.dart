// ⚛️ אטום-Dart · smartProductByKey
// מוצא: buildsmart/app_flutter/lib/data/smart_tree.dart:2553-2558 (חצב-בינה · קטלוג-מוזרק · חוק-4).
// שקע: kSmartProducts ← דאטה-מוזרקת (מתחלף פר-ורטיקל)
//
// טיפוס-מינימום SmartProduct: רק השדה `key` שהפונקציה נוגעת בו + const ctor.

/// צורת-מינימום של SmartProduct — רק מה ש-smartProductByKey קורא.
class SmartProduct {
  final String key;
  const SmartProduct({required this.key});
}

/// מציאת מוצר-חכם לפי [key] בקטלוג-המוזרק; null אם אין. verbatim smart_tree.dart:2553-2558.
SmartProduct? smartProductByKey(
  String key, {
  required List<SmartProduct> catalog,
}) {
  for (final p in catalog) {
    if (p.key == key) return p;
  }
  return null;
}
