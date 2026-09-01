// ⚛️ אטום-Dart (דרגת-חוזה) · envPath — מסלול-מעטפת-ההצפנה בענן
// מוצא: maor/src/lib/cloud-diff.ts:59-63 · תורגם TS→JS מכונה.
//        המקור: new/atoms/env-path.mjs —
//        `return cloudRoot ? '_enc/envelope' : 'orgs/' + slug + '/_enc/envelope';`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה למקור-ה-JS.
//
// תפקיד: נתיב-מסמך של מעטפת-ההצפנה. cloudRoot אמיתי ⇒ נתיב-שורש '_enc/envelope';
//        אחרת ⇒ תחת ה-slug של הארגון: 'orgs/<slug>/_enc/envelope'.
// קלט:  slug — מזהה-ארגון (מחורז לנתיב), String · cloudRoot — דגל/ערך שנבחן ל-truthiness.
// פלט:  נתיב-המסמך, String.
//
// הערות-המרה (DART-PORTING-RULES):
//  • כלל-7 (truthiness): המקור מסתמך על `cloudRoot ? ...` — ל-JS יש truthiness משלו
//    (מחרוזת-ריקה="" נופלת ל-falsy, מחרוזת-לא-ריקה=truthy; 0/null/false=falsy). הקלטות-
//    הזהב מעבירות מחרוזות בלבד, אך משמרים את סמנטיקת-JS המלאה דרך `_truthy` מפורש —
//    לא `if (cloudRoot)` של Dart (שדורש bool). זו הסטייה היחידה שהמנוע היה מפספס.
//  • שרשור-מחרוזת: המקור עושה `'orgs/' + slug` — JS ממיר את slug למחרוזת. `_jsStr`
//    משקף זאת (String כמו-שהוא; null⇒"null" וכו') כדי לשמור זהות-ביט.

/// JS-truthiness (חוק-7): false/0/NaN/null/""=falsy; אחרת truthy. משקף `cloudRoot ?` שבמקור.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// שרשור-מחרוזת בסגנון-JS: String כמו-שהוא, null⇒"null", bool⇒"true"/"false", אחרת toString.
String _jsStr(dynamic v) {
  if (v is String) return v;
  if (v == null) return 'null';
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

/// Encryption-envelope document path. Verbatim behaviour of new/atoms/env-path.mjs.
String envPath(dynamic slug, dynamic cloudRoot) {
  return _truthy(cloudRoot) ? '_enc/envelope' : 'orgs/' + _jsStr(slug) + '/_enc/envelope';
}
