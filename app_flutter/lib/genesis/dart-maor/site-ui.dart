// ⚛️ אטום-Dart (דרגת-חוזה) · siteUi — תווית-הממשק של האתר-הציבורי
// מוצא: maor/src/lib/publicSite.ts:198-217 (siteUi).
//        המקור: new/atoms/site-ui.mjs —
//        `(uiLabels[lang] ?? uiLabels.he)[key] ?? uiLabels.he[key] ?? ''`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: תווית-הממשק לשפה+מפתח עם נפילה כפולה לעברית —
//        שפה לא-מוכרת ⇒ מילון-he; מפתח חסר בשפה ⇒ הערך העברי; חסר גם שם ⇒ ''.
// שקעים (חוק-1): uiLabels — מילון-התוויות פר-שפה {he:{...}, en?:{...}, ...}
//        (במקור: הקבוע-השכן SITE_UI, קודם כאטום-הנתונים site-ui-labels).
//        מפתח 'he' חובה (עוגן-הנפילה).
// קלט:  lang — קוד-שפה · key — מפתח-תווית · uiLabels — שקע-הנתונים.
// פלט:  מחרוזת-תווית (או '' כשאין).
//
// הערת-המרה (מקור→Dart): ה-`??` של JS מדלג על null וגם על undefined; ב-Dart
// גישה למפתח-חסר ב-Map מחזירה null, ולכן שרשרת-`??` זהה-התנהגות בדיוק —
// גם ערך-null-מפורש נופל הלאה בשתי השפות (כלל-2 לא רלוונטי: אין כאן
// הבחנת undefined/null, רק ??). אין locale/מיון/מספרים/truthiness מעורבים.

/// Public-site UI label for a language+key with a double Hebrew fallback:
/// unknown language ⇒ the `he` dictionary; key missing in the language ⇒ the
/// Hebrew value; missing there too ⇒ ''. Verbatim behaviour of the JS source
/// new/atoms/site-ui.mjs.
dynamic siteUi(dynamic lang, dynamic key, dynamic uiLabels) {
  return (uiLabels[lang] ?? uiLabels['he'])[key] ?? uiLabels['he'][key] ?? '';
}
