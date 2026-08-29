// ⚛️ אטום-Dart (דרגת-חוזה) · lessonTierOptions — אופציות רמות-ההנחה פר-שיעור לבורר.
// מוצא: maor/src/components/courses/lib.ts:270-276 · המקור: new/atoms/lesson-tier-options.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אפס שקעים.
//
// תפקיד: רשימת רמות-ההנחה הזמינות לחוג פר-שיעור, כאופציות-בורר {v,t}: תמיד פותחת
//        ב"מחיר מלא · ₪N" (v=''); כל רמה 1–3 עם מחיר truthy מוסיפה שורה עם שם-הרמה
//        (או ברירת-מחדל 'הנחה N') + המחיר שלה.
// קלט:  c — אובייקט-חוג (Map<String,Object?>) עם lessonPrice, lessonPrice1..3,
//        price1Name..price3Name אופציונליים. פלט: List<Map<String,String>> — {v,t}.
//
// הערות-המרה (מקור→Dart) — הכללים שהמנוע פספס בטיוטה:
//  • truthiness (כלל-המרה 7): JS `if (c.lessonPrice1)` — falsy ל-0/null/undefined/''/NaN.
//    הטיוטה כתבה `if (c.lessonPrice1)` (num, לא bool — לא-מתקמפל). ⇒ שקע `_falsy`.
//  • `c.lessonPrice || 0` (JS ||): מחזיר 0 כשהערך falsy, אחרת הערך. ⇒ `_falsy(v) ? 0 : v`.
//  • `c.price1Name || 'הנחה 1'`: אותו || על מחרוזת. ⇒ `_falsy(v) ? def : v.toString()`.
//  • `'₪' + number` (JS מספר→מחרוזת): שקע `_jsNum` המחקה Number.prototype.toString
//    (int → '80', double-שלם → '80' לא '80.0'). המקור משתמש ב-`+` פשוט (לא toLocaleString)
//    ⇒ בלי סימני-RTL/locale (כלל-המרה 6 לא חל כאן).
//  • מוטביליות: `final out` (הרשימה מוטבלת ב-add, ההפניה final) — לא `var`.

/// JS-truthiness for the value types in play (num, String, bool, null, other).
/// Mirrors JS `!v`: 0/NaN/''/null/undefined/false are falsy.
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  if (v is bool) return !v;
  return false; // any other object is truthy in JS
}

/// JS Number→String for finite values, matching `'' + n`:
/// integral values render without a fractional part ('80', not '80.0').
String _jsNum(Object? v) {
  final n = (v is num) ? v : 0;
  if (n is int) return n.toString();
  final d = (n as double);
  if (d.isFinite && d == d.truncateToDouble()) return d.toInt().toString();
  return d.toString();
}

/// Discount-tier selector options for a per-lesson course.
/// Verbatim port of new/atoms/lesson-tier-options.mjs (`lessonTierOptions`).
List<Map<String, String>> lessonTierOptions(Map<String, Object?> c) {
  final out = <Map<String, String>>[
    {
      'v': '',
      't': 'מחיר מלא · ₪' +
          _jsNum(_falsy(c['lessonPrice']) ? 0 : c['lessonPrice']),
    },
  ];
  if (!_falsy(c['lessonPrice1'])) {
    out.add({
      'v': '1',
      't': (_falsy(c['price1Name']) ? 'הנחה 1' : c['price1Name'].toString()) +
          ' · ₪' +
          _jsNum(c['lessonPrice1']),
    });
  }
  if (!_falsy(c['lessonPrice2'])) {
    out.add({
      'v': '2',
      't': (_falsy(c['price2Name']) ? 'הנחה 2' : c['price2Name'].toString()) +
          ' · ₪' +
          _jsNum(c['lessonPrice2']),
    });
  }
  if (!_falsy(c['lessonPrice3'])) {
    out.add({
      'v': '3',
      't': (_falsy(c['price3Name']) ? 'הנחה 3' : c['price3Name'].toString()) +
          ' · ₪' +
          _jsNum(c['lessonPrice3']),
    });
  }
  return out;
}
