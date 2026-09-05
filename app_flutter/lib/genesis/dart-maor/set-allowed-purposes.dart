// ⚛️ אטום-Dart (דרגת-חוזה) · setAllowedPurposes — נרמול רשימת-הייעודים-המותרים לעובד/ת.
// מוצא: maor/src/lib/cloud.ts:112-121 · המקור: new/atoms/set-allowed-purposes.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import. חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//        במקור הערך הושם למשתנה-מודול allowedPurposes — ההשמה היא חיווט-קופסה
//        (חוק-1/חוק-5); האטום רק מחשב את הערך המנורמל.
//
// תפקיד: מערך לא-ריק ⇒ הוא-עצמו (זהות-הפניה — לא עותק; העובד/ת מוגבל/ת);
//        ריק/חסר ⇒ null = בלי-הגבלה (מנהל/בעלים — קריאה לא-מסוננת).
//
// הערות-המרה (מקור→Dart):
//  • `p && p.length ? p : null` — truthiness של JS (כלל-7 ב-DART-PORTING-RULES):
//    p falsy (null/undefined) ⇒ הענף-הכוזב ⇒ null; p.length===0 falsy ⇒ null;
//    אחרת ⇒ p עצמו. ב-Dart מפורש: `p == null || p.length == 0 ? null : p`.
//    ‏null של Dart מכסה גם null וגם undefined של JS (כלל-2 לא רלוונטי כאן —
//    שניהם ממופים לאותו פלט null, כמחויב בדוגמאות 3–4 של החוזה).
//  • זהות-הפניה (דוגמה 1 בחוזה): מוחזר p עצמו, לא עותק — Dart מחזיר את אותה
//    ההפניה בדיוק כמו JS.
//  • הסנטינל '_shared_' הוא נתון רגיל — עובר כמות-שהוא (עניין הצד-המושך).

/// Normalize a worker's allowed-purposes list: non-empty list ⇒ the list itself
/// (same reference, not a copy); empty/absent ⇒ null (no restriction).
/// Verbatim port of new/atoms/set-allowed-purposes.mjs (`setAllowedPurposes`).
dynamic setAllowedPurposes(dynamic p) {
  // JS: `p && p.length ? p : null` — truthiness מפורש (כלל-7).
  return p == null || p.length == 0 ? null : p;
}
