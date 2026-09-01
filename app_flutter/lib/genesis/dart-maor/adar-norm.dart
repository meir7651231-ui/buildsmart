// ⚛️ אטום-Dart (דרגת-חוזה) · adarNorm — דין-אדר
// מוצא: maor/src/lib/hebrew.ts (adarNorm; חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/adar-norm.mjs —
//        `const adarNorm = (monthEn) => (monthEn === 'Adar II' ? 'Adar' : monthEn);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: דין-אדר לחזרה שנתית — אדר-ב׳ ("Adar II") מנורמל ל-"Adar" כדי שאזכרה/יום-
//        הולדת שנקבעו באדר-רגיל יחזרו באדר-ב׳ בשנה מעוברת (וההפך). כל שם-אחר עובר כמו-שהוא.
// קלט:  monthEn — שם-חודש אנגלי (Intl), String.
// פלט:  שם מנורמל, String: "Adar II" ⇒ "Adar"; אחרת ⇒ הקלט עצמו.
//
// הערת-המרה (מקור→Dart): ה-JS משווה זהות-מחרוזת עם `===`; ב-Dart `==` על String הוא
// השוואת-ערך, ולכן שקול בדיוק. אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים
// — אטום טהור בן שורה אחת, ללא שקעים.

/// Adar law for annual recurrence. `'Adar II'` normalises to `'Adar'`; every other
/// month name passes through unchanged. Verbatim behaviour of the JS source
/// new/atoms/adar-norm.mjs.
String adarNorm(String monthEn) => monthEn == 'Adar II' ? 'Adar' : monthEn;
