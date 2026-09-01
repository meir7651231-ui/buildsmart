// ⚛️ אטום-Dart (דרגת-חוזה) · profileForBrand — מנוע-נקי (מנגנון-בלבד, אפס-דאטה).
// מוצא: buildsmart/app_flutter/lib/domain/brand_profile.dart:435-436 (‏commit 6a7fdd79 · חוק-4 — לוגיקה verbatim).
// אחים-שהוזרקו (חוק-3, תקדים estimate_price "אפס דאטה-צרובה במנוע"):
//   • `profiles` — שקע במקום ה-const ‏`kBrandProfiles` (‏:425-429 — 'פולירול'/'חוליות'/'ליפסקי').
//   • `fallback` — שקע במקום ה-const ‏`kLipskeyProfile` (‏:416-422 — התנהגות-ה-else של כל סולם).
//   • `BrandProfile` ⇒ גנרי `T` (הטיפוס נושא קטלוג+WaterSystem חיצוני — לא-מוטבע; המנוע אדיש לצורה).
//
// קלט:  brandName — מחרוזת-מותג (או null); אפס נרמול — הושוואה כמו-שהיא.
//       profiles  — שקע: מפת מותג⇒פרופיל לפי המפתחות המדויקים של סולמות-ה-if.
//       fallback  — שקע: פרופיל-ברירת-המחדל (ה-else של כל סולם).
// פלט:  profiles[brandName] אם קיים; אחרת (כולל null / לא-ממופה / ריק) ⇒ fallback.
//       לעולם לא זורק ולא מחזיר null.

/// The profile for [brandName], or [fallback] — verbatim
/// `kBrandProfiles[brandName] ?? kLipskeyProfile` (brand_profile.dart:436) with
/// the map and the default injected. Any string that is not an exact key
/// (including null and unmapped brands like AQUATEC) gets [fallback].
T profileForBrand<T>(
  String? brandName, {
  required Map<String, T> profiles,
  required T fallback,
}) =>
    profiles[brandName] ?? fallback;
