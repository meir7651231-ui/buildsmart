import 'dart:math' as math;

/// חוט · fit-dimensions — ממדי-יעד להקטנת-תמונה (שימור-יחס, בלי הגדלה).
/// המרה נאמנה מ-new/atoms/fit-dimensions.mjs (חוק-4: המקור קדוש) · מוצא: maor/src/lib/photoGallery.ts:28-37.
/// אפס import פנימי (רק dart:core + dart:math).
///
/// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
///  • הפלט `{w, h}` של JS ⇒ `Map<String, int>` (מוסכמת component-counts/day-progress).
///  • `Math.min(1, ...)` — הכוח היה int 1 מול double; ב-Dart `math.min(1, double)` תקין.
///  • `Math.round` על ערך-חיובי-בלבד (אחרי שער w>0,h>0,scale>0) ⇒ `.round()` זהה ל-JS
///    (חצי-כלפי-מעלה זהה לשניהם בטווח החיובי; אין ערך שלילי כאן).
///  • `Math.max(1, round)` — רצפת-1 לצלע חוקית שלא תתאפס בעיגול; שני האופרנדים int ⇒ int.
///  • קלט `num` (מספר-JS): רוחב/גובה/max יכולים להיות שלמים או שברים; אין locale/פורמט.
Map<String, int> fitDimensions(num w, num h, num max) {
  if (w <= 0 || h <= 0) return {'w': 0, 'h': 0};
  final scale = math.min(1, max / math.max(w, h));
  return {
    'w': math.max(1, (w * scale).round()),
    'h': math.max(1, (h * scale).round()),
  };
}
