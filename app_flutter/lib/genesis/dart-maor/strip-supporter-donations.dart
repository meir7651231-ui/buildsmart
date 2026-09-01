// ⚛️ אטום-Dart (דרגת-חוזה) · stripSupporterDonations — ריקון donations ממסמכי-תומך ב-diff
// (מסלול-B: התרומות באוסף-נפרד). מוצא: maor/src/lib/cloud-diff.ts:75-83 ·
// המקור: new/atoms/strip-supporter-donations.mjs · החוזה: strip-supporter-donations.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-4 — התנהגות זהה-ביט
//        למקור-ה-JS. אין שכנים ⇒ אין שקעים.
//
// תפקיד: מחזיר diff חדש שבו כל set של col==='supporters' עם data-אובייקט מקבל data חדש
//        עם donations:[] (ריסוס מפורש — המפתח נוסף גם אם לא היה, דוגמה 6). כל השאר —
//        אוספים אחרים, data:null, שדות-אחים (deletes/meta) — עובר זהה-רפרנס.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `{...diff, sets: ...}` ⇒ מפה חדשה בסדר-הכנסה של diff; המפתח 'sets' כבר קיים ⇒
//    ההשמה מעדכנת-במקום ושומרת את מיקומו — זהה לסמנטיקת-spread של JS
//    (LinkedHashMap של Dart: השמה למפתח-קיים אינה מזיזה אותו).
//  • `s.col === 'supporters'` — השוואה קשיחה (===) ללא קוארציה ⇒ `== 'supporters'`
//    על הערך כמות-שהוא (מחרוזת-בלבד עוברת; 5/true/null נכשלים בשתי-השפות).
//  • `s.data && typeof s.data === 'object'` — truthy וגם typeof-object: אובייקט (Map)
//    או מערך (List) עוברים; null נופל ב-truthy (typeof null==='object' אבל falsy);
//    מחרוזת/מספר/בוליאני נופלים ב-typeof. מומש ב-`_isObj` (Map||List — הטיפוסים
//    היחידים שממופים ל-typeof 'object' truthy בתחום-הנתונים של diff).
//  • `{...s.data, donations: []}` — כש-data הוא מערך, JS מרסס אינדקסים כמפתחות-מחרוזת
//    ("0","1",...) ⇒ `_spreadObj` משקף זאת (חוק-15: אינדקס-JS = מחרוזת-קנונית).
//  • `s.col` על set שאינו-אובייקט (JS ⇒ undefined, לא זריקה) ⇒ `_get` מחזיר null
//    לכל דבר שאינו Map — נאמן ל-property-access הסלחני של JS.
//  • זהות-רפרנס: set שלא-הותאם עובר as-is (אותו אובייקט) — כמו ב-JS map שמחזיר s.
//  • `diff.sets.map(...)` — אין מפתח 'sets' ⇒ JS זורק TypeError ⇒ גם כאן cast ל-List
//    על null זורק. אין locale/פורמט/מספרים/trim/toLowerCase מעורבים.

/// חיקוי property-access של JS: `o.k` — על לא-אובייקט מחזיר undefined (כאן null),
/// לא זורק. (Map בלבד נושא מפתחות בתחום-האטום.)
dynamic _get(dynamic o, String k) => o is Map ? o[k] : null;

/// `v && typeof v === 'object'` של JS בתחום-הנתונים: Map או List (מערך-JS הוא
/// typeof 'object'); null נופל ב-truthy; מחרוזת/מספר/בוליאני נופלים ב-typeof.
bool _isObj(dynamic v) => v is Map || v is List;

/// `{...data}` של JS: Map ⇒ עותק-שטוח שומר-סדר; List ⇒ אינדקסים כמפתחות-מחרוזת
/// קנוניות ("0","1",...) — כפי ש-spread-אובייקט של JS מרסס מערך.
Map<dynamic, dynamic> _spreadObj(dynamic data) {
  final out = <dynamic, dynamic>{};
  if (data is Map) {
    data.forEach((k, v) => out[k] = v);
  } else if (data is List) {
    for (var i = 0; i < data.length; i++) {
      out['$i'] = data[i];
    }
  }
  return out;
}

/// Path-B of cloud sync (doc-per-donation): returns a new diff in which every
/// `sets` entry of col==='supporters' with an object `data` gets a fresh `data`
/// whose `donations` is `[]` (the key is added even when absent — explicit spread).
/// Everything else — other collections, null data, sibling fields — passes by
/// reference. Pure, no mutation. Verbatim port of
/// new/atoms/strip-supporter-donations.mjs (`stripSupporterDonations`).
Map<dynamic, dynamic> stripSupporterDonations(dynamic diff) {
  final sets = (_get(diff, 'sets') as List)
      .map((s) {
        final data = _get(s, 'data');
        if (_get(s, 'col') == 'supporters' && _isObj(data)) {
          final newData = _spreadObj(data);
          newData['donations'] = <dynamic>[];
          final newSet = _spreadObj(s);
          newSet['data'] = newData;
          return newSet;
        }
        return s;
      })
      .toList();
  final out = <dynamic, dynamic>{};
  (diff as Map).forEach((k, v) => out[k] = v);
  out['sets'] = sets;
  return out;
}
