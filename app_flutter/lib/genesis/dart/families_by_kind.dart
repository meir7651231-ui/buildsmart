// ⚛️ אטום-Dart · familiesByKind
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:143-147 (חצב-בינה · קטלוג-מוזרק · חוק-4).
// שקע: allVariantFamilies() (משפחות-הווריאנטים הנגזרות מ-kLipskeyCatalog, ממוטמן) ← דאטה-מוזרקת (מתחלף פר-ורטיקל)
//
// טיפוס-מינימום VariantFamily: רק השדה `kind` שהפונקציה נוגעת בו + const ctor.
// enum AttrKind: זהות-מינימום לסינון-לפי-סוג.

enum AttrKind { size, color, model, subtype }

/// צורת-מינימום של VariantFamily — רק מה ש-familiesByKind קורא.
class VariantFamily {
  final AttrKind kind;
  const VariantFamily({required this.kind});
}

/// המשפחות התואמות לסינון-סוג-התכונה [kind] (או הכול כאשר null).
/// verbatim variant_families.dart:143-147 (allVariantFamilies() ⇒ שקע families).
List<VariantFamily> familiesByKind(
  AttrKind? kind, {
  required List<VariantFamily> families,
}) {
  final all = families;
  if (kind == null) return all;
  return all.where((f) => f.kind == kind).toList();
}
