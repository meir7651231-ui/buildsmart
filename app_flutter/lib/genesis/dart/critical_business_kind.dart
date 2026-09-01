// ⚛️ אטום-Dart (דרגת-חוזה) · criticalBusinessKind
// תפקיד: סיווג רכיב-ממשק כ"קריטי-עסקית" — בקרת-אישור-הזמנה או בקרת-מחיר — לפי
//        מזהה-הרכיב ותווית-העברית שלו; אחרת null. משמש שער-בטיחות-עריכה (edit_safety).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:189-212 (‏_criticalBusinessKind; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור ⇒ public.
// אחים-שהוטבעו: ה-enum `_CriticalKind` (‏confirmOrder/price) הוטבע verbatim כ-enum public
//        `CriticalKind`; שדות-`ElementDescriptor` הרלוונטיים (‏id/labelHe) כפרמטרים-בשם
//        (טיפוס-שכן ⇒ inline, חוק-3). אחים-שסוקטו: — (אין קריאה-לשכן).
//
// קלט:  id      — מזהה-הרכיב (String). מומר ל-lowercase לפני בדיקות-ה-contains.
//       labelHe — תווית-הרכיב העברית (String), נבדקת כפי-שהיא.
// פלט:  CriticalKind? — confirmOrder / price / null.

/// סיווג-הקריטיות (הוטבע verbatim מ-`_CriticalKind`, edit_safety.dart).
enum CriticalKind { confirmOrder, price }

/// Classify an element as business-critical (order-confirmation / price control),
/// else null. `id` is lower-cased before matching; `labelHe` matched as-is.
/// confirmOrder takes precedence over price. Verbatim behaviour of edit_safety.dart:189-212.
CriticalKind? criticalBusinessKind({required String Function(String) term, required String id, required String labelHe}) {
  final lid = id.toLowerCase();
  final label = labelHe;
  // (c) order-confirmation control — the plan's exact "אשר הזמנה" surface.
  if (label.contains(term('ashr-hzmnh')) ||
      lid.contains('confirmorder') ||
      lid.contains('approveorder')) {
    return CriticalKind.confirmOrder;
  }
  // (b) price control.
  if (lid.contains('price') || label.contains(term('mchyr'))) {
    return CriticalKind.price;
  }
  return null;
}
