// ⚛️ אטום-Dart (דרגת-צילום-ערך) · MAX_EMBED_BYTES — תקרת-בייטים למסמך מוטמע.
// מוצא: maor/src/lib/imagePick.ts · המקור: new/atoms/max-embed-bytes.mjs
//        (`export const MAX_EMBED_BYTES = 3 * 1024 * 1024;`) · חוזה: max-embed-bytes.contract.md.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — ערך
//        זהה-ביט למקור-ה-JS (המקור קדוש). זהו אטום-קבוע (צילום-ערך), לא פונקציה.
//
// תפקיד: תקרת 3MB (‏3145728 בייט) לקובץ מוטמע. הביטוי נשמר כלשונו — 3 × 1024 × 1024 —
//        כדי שהערך יישאר מובן-מאליו ולא "מספר-קסם". השימוש בפועל (השוואה מול גודל-קובץ,
//        הצגת-שגיאה) הוא חיווט-קופסה, לא האטום (חוק-5).
//        פלט: int קבוע = 3145728.
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  • `export const MAX_EMBED_BYTES = 3 * 1024 * 1024` → `const int maxEmbedBytes = 3 * 1024 * 1024`.
//    המנוע פלט `var MAX_EMBED_BYTES` (מוטבילי + PascalCase) — תוקן: `const int` (בלתי-משתנה,
//    שקול ל-frozen של המקור) + lowerCamelCase (מוסכמת-Dart). הביטוי המספרי נשמר כלשונו.
//  • אין locale/פורמט/getMonth/truthiness/substring/מודולו-שלילי/parse מעורבים — קבוע-שלם
//    טהור, ללא שקעים. ‏3 × 1024 × 1024 מחושב זהה ב-JS וב-Dart (מכפלת-שלמים בטווח).

/// The embed ceiling: 3MB (`3145728` bytes) per embedded file. The expression is
/// preserved verbatim (`3 * 1024 * 1024`). Value-snapshot port of
/// new/atoms/max-embed-bytes.mjs (`MAX_EMBED_BYTES`).
const int maxEmbedBytes = 3 * 1024 * 1024; // 3MB לקובץ מוטמע
