// ⚛️ אטום-Dart (דרגת-חוזה) · purposeKeyOf — מפתח-הפיצול של תרומה (מסלול-B).
// מוצא: maor/src/lib/donationPartition.ts:24-33 · המקור: new/atoms/purpose-key-of.mjs —
//        `const p = (d.purpose ?? '').trim(); return p || SHARED_PURPOSE_KEY;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ה-purpose המחוטא (גזום-רווחים) של תרומה; ריק/רווחים/חסר ⇒ המפתח-המשותף
//        '_shared_'. מפתח-הפיצול = purpose (מסנן-הרשאה-פר-עובד) — לא designation (SHOP9).
// שקע (חוק-1): purpose — שדה-ה-purpose של אובייקט-התרומה (String?), הוזרק כפרמטר במקום
//        גישת-שדה d.purpose. פלט: String — הייעוד הגזום, או '_shared_'.
//
// הערות-המרה (מקור→Dart):
//  • `d.purpose ?? ''` — ב-JS `??` תופס גם undefined (שדה-חסר) וגם null. הפרמטר `String?`
//    מדגם את שניהם כ-null יחיד (חוק-2: כאן זה נכון — הקלט הוא הערך, לא map, ואין הבחנת
//    null/undefined לשמר). `purpose ?? ''` זהה.
//  • `.trim()` → `.trim()` — לדוגמאות-החוזה (רווח-ASCII) זהה-ביט; שתיהן גוזמות רווח לבן.
//  • `p || SHARED` — truthiness של JS על מחרוזת: '' בלבד falsy (רול 7). ⇒ תנאי-מפורש
//    `p.isEmpty ? SHARED : p`, אפס הישענות על truthiness.
//  • מוטביליות: `final p`; אין var מוקצה-מחדש. אין locale/פורמט/getMonth.

/// The shared partition key — sanitized purpose that is empty/blank/absent maps here.
/// Verbatim from the JS source (SHARED_PURPOSE_KEY = '_shared_').
const String sharedPurposeKey = '_shared_';

/// Partition key of a donation: the trimmed `purpose`; empty/blank/absent ⇒ '_shared_'.
/// Verbatim port of new/atoms/purpose-key-of.mjs (`purposeKeyOf`). The field access
/// `d.purpose` is injected as the socket parameter `purpose` (Law 1/3).
String purposeKeyOf(String? purpose) {
  final p = (purpose ?? '').trim();
  return p.isEmpty ? sharedPurposeKey : p;
}
