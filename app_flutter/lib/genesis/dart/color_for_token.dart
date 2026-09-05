// ⚛️ אטום-Dart (דרגת-חוזה) · colorForToken
// תפקיד: פתרון token-צבע-בעלים ('brand'/'warn'/'ink'/…) לפיגמנט הקונקרטי שלו,
//        או null ל-token לא-מוכר (כולל hex-גולמי שמודל המציא — לעולם לא נפתר).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:254-273
//        (‏_colorForToken, commit d3c57704; חוק-4 — התנהגות זהה, לא-משופרת).
//        פרטי-במקור ⇒ public.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). גנרי על T.
//
// שקעים (חוק-3 + חוק-5, דיבר-3): במקור כל case קורא שדה-שכן `BsTokens.*`
//        (‏theme/tokens.dart — ה-SSOT של הפיגמנטים). הפיגמנטים הם דאטה-הצבה ⇒
//        הוזרקו כ-7 פרמטרים-נקובים. **הידע שנשאר באטום** הוא המיפוי עצמו —
//        אוצר-המילים של 7 ה-tokens ואיזה שדה-SSOT כל אחד בוחר (‏'warn'⇒warnText
//        ולא warnBright · 'ink'⇒inkLight · 'muted'⇒mutedLight) + default⇒null.
//        כך אין תלות ב-dart:ui/Flutter ואפס-דאטה-צרובה במנוע.
//
// קלט:  token — שם-ה-token (nullable; null נופל ל-default).
//       brand·brandDark·success·danger·warnText·inkLight·mutedLight — שקעי-פיגמנט (T).
// פלט:  T? — הפיגמנט המוזרק המתאים, או null ל-token לא-מוכר/null.

/// Resolve an owner-facing color TOKEN to its concrete pigment, or `null` for an
/// unknown token (e.g. a raw hex the model invented — which never resolves).
/// The seven `BsTokens` pigments are injected as slots (no dart:ui dependency);
/// the token vocabulary and its field-choice mapping stay verbatim from
/// edit_safety.dart:254-273.
T? colorForToken<T>(
  String? token, {
  required T brand,
  required T brandDark,
  required T success,
  required T danger,
  required T warnText,
  required T inkLight,
  required T mutedLight,
}) {
  switch (token) {
    case 'brand':
      return brand;
    case 'brandDark':
      return brandDark;
    case 'success':
      return success;
    case 'danger':
      return danger;
    case 'warn':
      return warnText;
    case 'ink':
      return inkLight;
    case 'muted':
      return mutedLight;
    default:
      return null;
  }
}
