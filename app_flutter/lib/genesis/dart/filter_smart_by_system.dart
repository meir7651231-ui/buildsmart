// ⚛️ אטום-Dart · filterSmartBySystem
// מוצא: buildsmart/app_flutter/lib/logic/system_division.dart:125-130 (חצב-בינה · קטלוג-מוזרק · חוק-4).
// שקע: smartProductInSystem (חיווי-שייכות מעל catalogRepo()/kLipskeyCatalog) ← דאטה-מוזרקת (מתחלף פר-ורטיקל)
//
// טיפוס-מינימום SmartProduct: הפונקציה לא נוגעת בשדה — צורת-מינימום ריקה + const ctor.
// enum WaterSystem: זהות-מינימום (supply/drainage) לשער ה-null בלבד.

/// צורת-מינימום של SmartProduct — הסינון מעביר את הפריט לשקע-החיווי בלבד.
class SmartProduct {
  const SmartProduct();
}

/// זהות-מערכת-המים (verbatim lipskey_verified_connections.dart:41).
enum WaterSystem { supply, drainage }

/// טהור: שמור את מוצרי-העץ-החכם השייכים ל-[system] (null ⇒ הכול).
/// verbatim system_division.dart:125-130 (smartProductInSystem ⇒ שקע inSystem).
List<SmartProduct> filterSmartBySystem(
  List<SmartProduct> list,
  WaterSystem? system, {
  required bool Function(SmartProduct p, WaterSystem system) inSystem,
}) =>
    system == null
        ? list
        : list.where((p) => inSystem(p, system)).toList();
