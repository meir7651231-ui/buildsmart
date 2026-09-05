// ⚛️ אטום-Dart (דרגת-חוזה) · smartProductInSystem
// מוצא: buildsmart/app_flutter/lib/logic/system_division.dart:118-124 (חוק-4).
//        האטום = `smartProductInSystem` בלבד; `filterSmartBySystem` שבטיוטה אינו היעד.
//        הקובץ אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: פרדיקט-שייכות טהור. שקעים (חוק-3):
//        · `smartProductSystems(sp)` (עוזר-שכן שמפיק קבוצת-מערכות) ⇒ תוצאתו מוזרקת כ-`systems`.
//        · `SmartProduct`/`WaterSystem` (טיפוסים-שכנים) ⇒ מיותרים: האטום גנרי מעל `S`
//          ומשתמש רק בשוויון/`contains`, כך שאין צורך ב-enum הקונקרטי (טוהר מלא).
//
// קלט:  systems — קבוצת-המערכות של המוצר (פלט העוזר) · system — המערכת-המסננת (nullable).
// פלט:  `true` אם אין סינון (system==null), או המוצר חסר-שיוך (systems ריק), או מכיל את system.

/// Membership predicate: a product with [systems] belongs to [system] when
/// [system] is `null` (no filter), OR [systems] is empty (unresolved → visible
/// everywhere), OR [systems] contains [system].
/// Verbatim behaviour of system_division.dart:118-124 with the neighbour call
/// `smartProductSystems(sp)` injected as [systems]; generic over `S` so the
/// concrete `WaterSystem` enum is not needed.
bool smartProductInSystem<S>(Set<S> systems, S? system) {
  if (system == null) return true;
  return systems.isEmpty || systems.contains(system);
}
