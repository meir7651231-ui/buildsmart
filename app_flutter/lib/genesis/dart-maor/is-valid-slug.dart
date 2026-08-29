// ⚛️ אטום-Dart (דרגת-חוזה) · isValidSlug — תקינות-slug של ארגון
// מוצא: maor/src/components/platform/lib.ts:34-38 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/is-valid-slug.mjs —
//        `export function isValidSlug(slug) { return /^[a-z0-9-]{2,40}$/.test(slug); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: slug חוקי = 2–40 תווים, אך ורק אותיות-קטנות a–z, ספרות 0–9, ומקף. כל תו-אחר
//        (רווח, אות-עברית, @, :, /, T גדולה) פוסל. אורך מחוץ ל-2..40 פוסל.
// קלט:  slug — String.
// פלט:  bool — האם התבנית תואמת (JS `RegExp.test`).
//
// הערת-המרה (מקור→Dart, DART-PORTING-RULES):
//   • המקור הוא `RegExp.test` בלבד — אין locale/getMonth/truthiness/מוטביליות/מודולו,
//     ולכן אף אחד מ-11 כללי-ההמרה אינו רלוונטי מעבר לזהות-התבנית.
//   • תבנית-JS `^[a-z0-9-]{2,40}$` ⇒ raw-string ב-Dart זהה תו-אחר-תו; המקף בסוף
//     מחלקת-התווים הוא מקף-מילולי בשתי השפות.
//   • JS `$` ללא דגל-m עוגן-סוף-מוחלט; אין `multiLine` ב-Dart RegExp כאן ⇒ שקול.
//     (מחלקת-התווים ממילא אינה כוללת newline, כך שגם קלט רב-שורתי נפסל בשתיהן.)
//   • `.test(...)` (bool) ⇒ `.hasMatch(...)` (bool) — שקול ביט.

/// Organisation-slug validity: 2–40 chars, only lowercase `a–z`, digits `0–9`,
/// and hyphen. Verbatim behaviour of the JS source new/atoms/is-valid-slug.mjs.
bool isValidSlug(String slug) => RegExp(r'^[a-z0-9-]{2,40}$').hasMatch(slug);
