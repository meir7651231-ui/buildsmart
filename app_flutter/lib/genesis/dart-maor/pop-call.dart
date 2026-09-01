// ⚛️ אטום-Dart (דרגת-חוזה) · popCall — מסיר את האיבר/התו האחרון (slice(0,-1)).
// מוצא: new/atoms/pop-call.mjs —
//   export function popCall(calls) {
//     if (!calls || !calls.length) return calls;
//     return calls.slice(0, -1);
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: סיכום יומן-השיחות לתצוגת-החייגן; טהור, סובל undefined/null.
// שקע (חוק-1): calls — הקלט; במקור-ה-JS גם String וגם Array נתמכים (לשניהם
//   .length ו-.slice). רתמת-הזהב (new/atoms/pop-call.test.mjs) מפעילה מחרוזות בלבד,
//   שם slice(0,-1) = הסרת התו האחרון; המחרוזת הריקה מוחזרת כמו-שהיא.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • truthiness (כלל 7): JS `!calls || !calls.length` ⇒ מחרוזת/מערך ריקים או null
//     נופלים לשער-ההחזרה-המוקדמת. ב-Dart: null-check מפורש + isEmpty מפורש.
//   • substring שלילי (כלל 5): JS slice(0,-1) סלחן; Dart substring(0,-1) זורק —
//     ⇒ substring(0, length-1) אחרי שהריק כבר סונן בשער.
//   • null≠undefined (כלל 2): במקור calls==null/undefined נופל ב-`!calls` ⇒ מוחזר כמו-שהוא.

/// Verbatim behaviour of JS `popCall`: drops the last element/char (slice(0,-1)).
/// Empty or null input is returned as-is. Supports String (drop last char) and
/// List (drop last item), matching the JS source which relied on both having
/// `.length`/`.slice`. The golden harness exercises the String path.
dynamic popCall(dynamic calls) {
  // JS: `!calls` — null/undefined/empty-string fall through and are returned as-is.
  if (calls == null) return calls;
  if (calls is String) {
    // JS: `!calls` for '' is true, and `!calls.length` for length 0 is true.
    if (calls.isEmpty) return calls;
    // slice(0,-1) on a non-empty string == drop the last code unit.
    return calls.substring(0, calls.length - 1);
  }
  if (calls is List) {
    // JS: `![]` is false but `![].length` is true ⇒ empty array returned as-is.
    if (calls.isEmpty) return calls;
    return calls.sublist(0, calls.length - 1);
  }
  // Any other value: in JS a truthy non-array/string with no usable .length/.slice
  // never reaches the golden; returned as-is to stay side-effect-free.
  return calls;
}
