// ⚛️ אטום-Dart (דרגת-חוזה) · stripSupKey — קילוף מפתח-התומכים ממסמך-ה-meta
// מוצא: maor/src/lib/supporterPartition.ts:70-81 · המקור: new/atoms/strip-sup-key.mjs —
//   export function stripSupKey(data) {
//     if (!('skey' in data)) return data;
//     const rest = { ...data };
//     delete rest.skey;
//     return rest;
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: קילוף לוג-הפעולות (`skey`) ממסמך-ה-meta לפני כתיבה לענן — הלוג נושא
//        שמות-תורמים ונשאר מקומי פר-מכשיר; עובדת לא תלמד על תורם של אחרת דרכו.
//
// הערות-המרה (חוק-4 — התנהגות זהה-ביט ל-JS):
// · `'skey' in data` — בדיקת-קיום-מפתח, לא בדיקת-ערך: מפתח שקיים עם ערך null/undefined
//   עדיין נתפס (חוק-2 ⇒ containsKey, לעולם לא `== null`).
// · אין מפתח ⇒ מוחזר **אותו** אובייקט (זהות-הפניה, לא עותק) — כמו `return data` ב-JS.
// · List: ‏`'skey' in []` ב-JS הוא בדיקת-property ⇒ תמיד false על מערך רגיל ⇒ המערך
//   מוחזר כמו-שהוא (כך גם כל דוגמאות-המערך בחוזה-ה-Golden).
// · יש מפתח ⇒ עותק-רדוד `{...data}` ואז `delete rest.skey` — שקול להעתקה שמדלגת על
//   'skey'; ה-delete אינו משנה את סדר שאר-המפתחות.
// · סדר-מפתחות (חוק-14): ‏spread ב-JS יוצר אובייקט חדש שסדרו = מפתחות-אינדקס-מערך
//   קנוניים ("0","7","42") ממוינים מספרית תחילה, ואחריהם שאר-המפתחות בסדר-הכנסה.
//   ‏Dart Map = סדר-הכנסה בלבד ⇒ העוזר ‏_jsSpreadOrderedKeys משחזר את דין-הסדר של JS.
// · קלט שאינו אובייקט/מערך (null/מספר/מחרוזת/בוליאני): ‏`in` ב-JS זורק TypeError ⇒
//   כאן ArgumentError שקול (מחוץ לחוזה-ה-Golden; משוקף לנאמנות, לא מרוכך).

/// מפתח-אינדקס-מערך קנוני של JS: מחרוזת-עשרונית ללא אפס-מוביל שערכה ‎< 2^32−1‎.
/// (אלה המפתחות ש-JS ממיין מספרית-תחילה ביצירת אובייקט — חוק-14.)
bool _isCanonicalIndexKey(String k) {
  if (k.isEmpty || k.length > 10) return false;
  if (k == '0') return true;
  final first = k.codeUnitAt(0);
  if (first < 0x31 || first > 0x39) return false; // אפס-מוביל ⇒ לא-קנוני
  for (var i = 1; i < k.length; i++) {
    final c = k.codeUnitAt(i);
    if (c < 0x30 || c > 0x39) return false;
  }
  final n = int.parse(k);
  return n < 4294967295; // 2^32 − 1
}

/// סדר-המפתחות ש-`{...data}` של JS מייצר: אינדקסים-קנוניים ממוינים מספרית תחילה,
/// אחריהם שאר-המפתחות בסדר-ההכנסה המקורי (מיון-יציב — חוק-1: decorate בעזרת אינדקס).
List<dynamic> _jsSpreadOrderedKeys(Map<dynamic, dynamic> data) {
  final idxKeys = <String>[];
  final restKeys = <dynamic>[];
  for (final k in data.keys) {
    if (k is String && _isCanonicalIndexKey(k)) {
      idxKeys.add(k);
    } else {
      restKeys.add(k);
    }
  }
  idxKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  return <dynamic>[...idxKeys, ...restKeys];
}

/// קילוף המפתח 'skey' ממסמך-נתונים לפני כתיבה לענן — התנהגות זהה-ביט למקור-ה-JS
/// new/atoms/strip-sup-key.mjs: אין 'skey' ⇒ מוחזר אותו אובייקט; יש ⇒ עותק-רדוד בלעדיו.
dynamic stripSupKey(dynamic data) {
  if (data is Map) {
    if (!data.containsKey('skey')) return data; // אותה הפניה, לא עותק
    final rest = <dynamic, dynamic>{};
    for (final k in _jsSpreadOrderedKeys(data)) {
      if (k == 'skey') continue; // ‏delete rest.skey — דילוג שקול, סדר-השאר נשמר
      rest[k] = data[k];
    }
    return rest;
  }
  if (data is List) return data; // ‏'skey' in array ⇒ false ⇒ המערך עצמו
  // ‏JS: `'skey' in <primitive|null>` ⇒ TypeError. משוקף:
  throw ArgumentError(
      "Cannot use 'in' operator to search for 'skey' in $data (JS TypeError)");
}
