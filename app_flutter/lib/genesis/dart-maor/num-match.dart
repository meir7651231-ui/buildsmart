// ⚛️ אטום-Dart (דרגת-חוזה) · numMatch — התאמת מספר לתחביר סינון-עמודות ("3" / "3+" / "2-4").
// מוצא: maor/src/components/families/lib.ts:129-139 · המקור: new/atoms/num-match.mjs
// חוזה: new/atoms/num-match.contract.md · אפס שקעים.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: בהינתן שאילתת-סינון q ומספר n — מחזיר האם n עומד בתחביר:
//   "3"   ⇒ שוויון מדויק (n === 3) · "3+" / "3 +" ⇒ n >= 3 ·
//   "2-4" / "2 - 4" ⇒ 2 <= n <= 4 · ריק/לא-מספרי ⇒ true (אין סינון).
//
// הערות-המרה (DART-PORTING-RULES + המקור):
//  • truthiness (כלל 7): `String(q || '')` של JS — q נפול (null/''/0/false/NaN) ⇒ ''.
//    שוקף בשקע `_falsy` מפורש: q-נפול ⇒ '' · אחרת q.toString(). `if (!q)` ⇒ `qs.isEmpty`.
//  • פירוק-מספר (כלל 10): הקבוצות הן `\d+` בלבד (regex מבטיח ספרות) ⇒ `num.parse` לא-זורק
//    ומחקה את `+m[1]`/`+q` של JS (Number). אין קלט-רע שמגיע ל-parse.
//  • RegExp: `q.match(/.../)` ⇒ `RegExp(r'...').firstMatch(qs)` (null=אין-התאמה, מקביל ל-null של JS);
//    `/^\d+$/.test(q)` ⇒ `.hasMatch(qs)`. אין substring/locale/getMonth/מודולו/מוטביליות בקוד-זה.
//  • השוואת-שוויון `n === +q`: מספר===מספר ב-JS ⇒ `n == num.parse(qs)` (int==int) ב-Dart.
//  • n מוקלד `num` — היחיד שעליו פועלים `>=`/`<=`/`==` (המקור מניח n מספרי).

bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || v == '' || (v is num && v.isNaN);

/// Whether number [n] matches the column-filter syntax in query [q].
/// Verbatim behaviour of the JS source `numMatch` (families/lib.ts).
///  "3" ⇒ n==3 · "3+" ⇒ n>=3 · "2-4" ⇒ 2<=n<=4 · empty/non-numeric ⇒ true.
bool numMatch(dynamic q, num n) {
  final qs = (_falsy(q) ? '' : q.toString()).trim();
  if (qs.isEmpty) return true;
  var m = RegExp(r'^(\d+)\s*\+$').firstMatch(qs);
  if (m != null) return n >= num.parse(m.group(1)!);
  m = RegExp(r'^(\d+)\s*-\s*(\d+)$').firstMatch(qs);
  if (m != null) return n >= num.parse(m.group(1)!) && n <= num.parse(m.group(2)!);
  if (RegExp(r'^\d+$').hasMatch(qs)) return n == num.parse(qs);
  return true;
}
