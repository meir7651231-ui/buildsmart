// ⚛️ אטום-Dart (דרגת-חוזה) · callStats — סיכום יומן-שיחות פר-תומך (סה"כ · אחרון · לא-ענה).
// מוצא: maor/src/lib/dialer.ts:148-158 · המקור: new/atoms/call-stats.mjs —
//        `export function callStats(calls) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מקבל יומן-שיחות (List<Map{at, outcome}> או null) ומחזיר {total, last, noanswer}.
//        total=אורך היומן · last='at' של האחרון (או '' ביומן ריק) · noanswer=כמה outcome==='noanswer'.
//
// הערת-המרה (מקור→Dart) — למה הטיוטה-האוטומטית לא הספיקה:
//   * הרתמה (call-stats.test.mjs) היא Golden-אפיון שמזינה **מחרוזות** (לא רשימות): JS מנצל
//     דאק-טייפינג — למחרוזת יש `.length`, ‏for..of מפרק לתווים, ו-`char.outcome`/`char.at`===undefined.
//     Dart מוקלד ⇒ אני משחזר את הסמנטיקה: `_len`/`_at`/`_prop` מדמים ‏length/index/property של JS
//     גם על String וגם על List/Map. תו⇒`_prop` מחזיר null (=undefined), ולכן noanswer נשאר 0.
//   * truthiness: המקור `list.length ? … : ''` — int כתנאי. ב-Dart אסור int בתנאי ⇒ `len > 0`.
//     (הטיוטה השאירה `list.length ? …` — לא מתקמפל.)
//   * `.at`/`.outcome` על dynamic היו זורקים NoSuchMethod ב-Dart על מחרוזת ⇒ עוטפים ב-`_prop`.
//   * `JSON.stringify` משמיט מפתח עם ערך undefined. אני משמיט את המפתח 'last' כשהערך יהיה
//     undefined (‏_prop של תו⇒null) — ולכן פלט תו-בודד הוא {"total":n,"noanswer":0} בלי 'last'.
//   * סדר-המפתחות נשמר: total → last(אם קיים) → noanswer (Map-literal = LinkedHashMap, סדר-הכנסה).
//   * מוטביליות: רק noanswer הוא var; השאר final. אין locale/getMonth מעורבים.

int _len(dynamic x) {
  if (x is String) return x.length;
  if (x is List) return x.length;
  if (x is Map) return x.length;
  return 0;
}

dynamic _at(dynamic x, int i) {
  if (x is String) return x[i]; // תו-בודד (JS: char primitive)
  if (x is List) return x[i];
  return null;
}

// גישת-property בסגנון JS: על אובייקט ⇒ המפתח; על תו/פרימיטיב ⇒ undefined (=null).
dynamic _prop(dynamic o, String k) {
  if (o is Map) return o[k];
  return null;
}

/// Summarises a call log [calls] into {total, last, noanswer}, verbatim to the
/// JS source new/atoms/call-stats.mjs (`callStats`). `dynamic` mirrors JS duck
/// typing so the Golden harness (which feeds strings) behaves bit-identically:
/// a string has `.length`, iterates as chars, and `char.outcome`/`char.at` are
/// undefined. The 'last' key is omitted whenever the JS value would be undefined
/// (matching JSON.stringify), and is '' only for an empty log.
Map<String, dynamic> callStats(dynamic calls) {
  final list = calls ?? const [];
  final int total = _len(list);
  var noanswer = 0;
  for (var i = 0; i < total; i++) {
    if (_prop(_at(list, i), 'outcome') == 'noanswer') noanswer++;
  }
  final Map<String, dynamic> out = {'total': total};
  if (total > 0) {
    final last = _prop(_at(list, total - 1), 'at');
    if (last != null) out['last'] = last; // undefined ⇒ המפתח מושמט (כמו JSON.stringify)
  } else {
    out['last'] = '';
  }
  out['noanswer'] = noanswer;
  return out;
}
