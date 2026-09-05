// ⚛️ אטום-Dart (דרגת-חוזה) · pad2 — ריפוד-שמאל ל-2 תווים באפסים
// מוצא: maor · new/atoms/pad2.mjs —
//        `export function pad2(n) { return String(n).padStart(2, '0'); }`
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת.)
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: ממיר את הקלט למחרוזת ומרפד אותו משמאל באפסים עד אורך-מינימום 2.
//        מחרוזת באורך ≥2 עוברת כמו-שהיא; ""⇒"00"; "1"⇒"01" (אין דוגמה כזו בזהב).
// קלט:  n — כל ערך; מומר למחרוזת (כמו String(n) ב-JS).
// פלט:  String מרופד-שמאל לאורך ≥2.
//
// הערת-המרה (מקור→Dart): המנוע פלט `._padStart(2,'0')` — שם-שיטה שגוי שאינו קיים
// ב-Dart. ה-verbatim הוא `String.padLeft(2, '0')` (padLeft ≡ padStart של JS:
// ריפוד-שמאל עד רוחב-מינימום; מחרוזת ארוכה-דיה עוברת ללא-שינוי). `String(n)` ⇒
// `n.toString()` (על String מחזיר את-עצמו, זהה לזהב). אין locale/getMonth/מודולו/
// truthiness מעורבים — ריפוד-אפס טהור, ללא שקעים.

/// Left-pads the string form of [n] with `'0'` to a minimum length of 2.
/// Verbatim behaviour of the JS source new/atoms/pad2.mjs
/// (`String(n).padStart(2, '0')`).
String pad2(dynamic n) => n.toString().padLeft(2, '0');
