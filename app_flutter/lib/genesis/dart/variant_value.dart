// ⚛️ אטום-Dart · variantValue
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:47-50 (חצב-בינה · קטלוג-מוזרק · חוק-4).
// שקע: kindOf (מסווג-אסימונים מעל kLipskeyColors/Models/Subtypes) ← דאטה-מוזרקת (מתחלף פר-ורטיקל)
//
// טיפוס-מינימום LipskeyCatalogProduct: רק השדה `nameHe` שהפונקציה נוגעת בו + const ctor.
// enum AttrKind: זהות-מינימום לסיווג-האסימון.

enum AttrKind { size, color, model, subtype }

/// צורת-מינימום של LipskeyCatalogProduct — רק מה ש-variantValue קורא.
class LipskeyCatalogProduct {
  final String nameHe;
  const LipskeyCatalogProduct({required this.nameHe});
}

/// ערך(י)-התכונה השונים בשם-המוצר, מחוברים ברווח.
/// verbatim variant_families.dart:47-50 (kindOf ⇒ שקע מוזרק).
String variantValue(
  LipskeyCatalogProduct p,
  AttrKind kind, {
  required AttrKind? Function(String w) kindOf,
}) =>
    p.nameHe
        .split(RegExp(r'\s+'))
        .where((w) => kindOf(w) == kind)
        .join(' ');
