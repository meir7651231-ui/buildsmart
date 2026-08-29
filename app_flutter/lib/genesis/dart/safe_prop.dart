// ⚛️ אטום-Dart (דרגת-חוזה) · safeProp
// מוצא: buildsmart/app_flutter/lib/logic/studio/component_palette.dart:284-296 (‏_safeProp; חוק-4).
//        פרטי-במקור → נחשף כ-top-level. האטום = `_safeProp` בלבד; שאר-הטיוטה
//        (‏AddComponentRequest/Verdict/validateAddComponent) אינו היעד. הקובץ אינו קיים
//        עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: dispatch טהור. שקעים (חוק-3):
//        · `kLabelProps`/`kBodyProps` — קבוצות-מפתחות const-שכנות לא-ניתנות-לשחזור ⇒ שקעים.
//        · `promptSafeText(value, {maxLen, collapseWhitespace})` — עוזר-חיטוי-שכן ⇒ שקע-פונקציה.
//
// קלט:  key · value · (שקעים).
// פלט:  מפתח-תווית ⇒ חיטוי עם maxLen:200 + כיווץ-רווחים · מפתח-גוף ⇒ חיטוי בברירת-מחדל ·
//        אחרת ⇒ `value.trim()` בלבד.

/// Sanitise a component prop [value] by its [key] role:
///  · [key] ∈ [labelProps] → `promptSafeText(value, maxLen:200, collapseWhitespace:true)`;
///  · [key] ∈ [bodyProps]  → `promptSafeText(value)` (helper defaults: 600 chars, no collapse);
///  · otherwise            → `value.trim()`.
/// Verbatim behaviour of component_palette.dart:284-296 with the two key-sets
/// and the `promptSafeText` helper injected as sockets.
String safeProp(
  String key,
  String value, {
  required Set<String> labelProps,
  required Set<String> bodyProps,
  required String Function(String value,
          {int maxLen, bool collapseWhitespace})
      promptSafeText,
}) {
  if (labelProps.contains(key)) {
    return promptSafeText(value, maxLen: 200, collapseWhitespace: true);
  }
  if (bodyProps.contains(key)) {
    return promptSafeText(value);
  }
  return value.trim();
}
