// ⚛️ אטום-Dart (דרגת-חוזה) · isEncrypted — האם הערך מעטפת-הצפנה ($enc===2).
// מוצא: maor/src/lib/crypto.ts:101-104 · המקור: new/atoms/is-encrypted.mjs —
//   `export function isEncrypted(raw) {`
//   `  return !!raw && typeof raw === 'object' && raw.$enc === 2;`
//   `}`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מזהה מעטפת-הצפנה — אובייקט אמיתי שבו השדה `$enc` שווה למספר 2 בדיוק.
// שקע (חוק-1): raw — הערך הנבדק (dynamic; יכול להיות Map/null/String/int/...).
// קלט: השקע raw. פלט: bool.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • truthiness (כלל 7): `!!raw` של JS ⇒ תנאי-מפורש `raw != null`. המנוע פלט
//    `_falsy(_falsy(raw))` (falsy כפול) — שגוי; הכפילות מהמרת `!!` דרך `!` פעמיים,
//    אבל truthy≡`!falsy`, לא `falsy(falsy)`. תוקן לתנאי-מפורש.
//  • `typeof raw === 'object'` ⇒ `raw is Map` (typeof null==='object' נחסם כבר ב-raw!=null;
//    מחרוזת/מספר אינם object ⇒ false, זהה למקור). המנוע פלט `raw is Map` — נכון.
//  • `raw.$enc === 2` — המנוע פלט `raw.$enc` (גישת-שדה) — שגוי ב-Dart; ל-Map ניגשים
//    במפתח: `raw[r'$enc']`. `$` דורש raw-string (r'...') כדי לא להתפרש כאינטרפולציה.
//  • השוואת-strict `=== 2` ⇒ `== 2`: ב-Dart String '2' == int 2 ⇒ false (בלי throw),
//    ומפתח-חסר מחזיר null ⇒ null == 2 ⇒ false. זהה בדיוק למקור-ה-JS.
// אין locale/פורמט/getMonth/מוטביליות מעורבים.

/// True iff `raw` is a real object (Map) whose `$enc` field equals the number 2 —
/// the encryption-envelope marker. Verbatim behaviour of the JS `isEncrypted`.
bool isEncrypted(dynamic raw) {
  return raw != null && raw is Map && raw[r'$enc'] == 2;
}
