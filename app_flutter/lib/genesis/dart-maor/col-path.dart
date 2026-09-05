// ⚛️ אטום-Dart (דרגת-חוזה) · colPath — נתיב אוסף בענן (שורש/פר-ארגון)
// מוצא: maor/src/lib/cloud-diff.ts:45-49 (אחיו של meta-path; חוק-4 — התנהגות זהה
//        למקור-ה-JS, לא-משופרת). המקור: new/atoms/col-path.mjs —
//        `cloudRoot ? col : 'orgs/' + slug + '/' + col`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: בונה את נתיב-אוסף-הענן. ארגון-שורש (cloudRoot=true) ⇒ האוסף כשמו; אחרת
//        ⇒ ממוקם תחת 'orgs/<slug>/<col>'.
// קלט:  slug — מזהה-ארגון (String) · cloudRoot — האם נתיבי-שורש (bool) · col — שם-אוסף (String).
// פלט:  נתיב-האוסף, String.
//
// הערת-המרה (מקור→Dart): ה-JS משתמש ב-`+` לשרשור-מחרוזות; ב-Dart שרשור-String עם `+`
// שקול. cloudRoot כאן bool מפורש (במקור truthiness — כל הקריאות מעבירות boolean).
// אין locale/פורמט/getMonth/מוטביליות מעורבים — אטום טהור בן שורה אחת, ללא שקעים.

/// Cloud collection path (root vs per-org). `cloudRoot` true ⇒ the collection as-is;
/// otherwise ⇒ `'orgs/<slug>/<col>'`. Verbatim behaviour of the JS source
/// new/atoms/col-path.mjs.
String colPath(String slug, bool cloudRoot, String col) =>
    cloudRoot ? col : 'orgs/' + slug + '/' + col;
