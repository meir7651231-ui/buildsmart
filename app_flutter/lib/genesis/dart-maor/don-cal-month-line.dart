// ⚛️ אטום-Dart (דרגת-חוזה) · donCalMonthLine — שורת-סיכום-החודש של לוח-התורמים.
// מוצא: maor/src/components/supporters/lib.ts:340-359 · המקור: new/atoms/don-cal-month-line.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן termOf הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: סופר תרומות-החודש (לפי השקע inMonth על התאריך), צובר שקל מול דולר, ומחזיר
//        שורת-סיכום; אין תרומות ⇒ הודעת "אין"; אין סכומים ⇒ "מהקובץ ההיסטורי".
// קלט:  entries (איטרבל של {date,amount,cur}) · inMonth(date)⇒bool · config (או null) ·
//        termOf(config,key,fallback)⇒String. פלט: String.
//
// הערות-המרה (מקור→Dart) — הכללים ב-machtzev/emit/DART-PORTING-RULES.md:
//  • truthiness (כלל-7): `config ? … : …` ⇒ `config != null` (undefined-JS ⇒ null-Dart);
//    `if (!mc)` ⇒ `mc == 0`; `mi ? …` / `mu ? …` / `mi && mu` ⇒ `!= 0` (0 falsy ב-JS).
//  • `sums || 'fallback'` — מחרוזת-ריקה falsy ב-JS ⇒ `sums.isEmpty ? fallback : sums`
//    (לא `??` — הטיוטה טעתה: '' אינו null). המנוע פספס גם את זה.
//  • `e.amount || 0` (undefined/0 ⇒ 0) ⇒ `(e['amount'] as num?) ?? 0` (המפתח חסר/null ⇒ 0).
//  • פורמט-locale (כלל-6): `Number.toLocaleString('he-IL')` על מספר שלם = ספרות-מערב עם
//    מפריד-אלפים פסיק, בלי סימן-RTL ⇒ שקע-הפורמט `_heGroup` מקבץ שלשות בפסיק (1234⇒"1,234").
//    (המנוע פלט קוד-שבור "mifunction toLocaleString(){[native code]}" — הוחלף מלא.)
//  • השכן termOf — פרמטר-פונקציה, לא import (חוק-3).

/// Month-summary line for the supporters calendar. Verbatim port of
/// new/atoms/don-cal-month-line.mjs (`donCalMonthLine`). The neighbour `termOf`
/// is injected as a socket (Law 1/3); `inMonth` is the date-membership socket.
String donCalMonthLine(
  Iterable entries,
  bool Function(dynamic date) inMonth,
  Map? config,
  String Function(Map config, String key, String fallback)? termOf,
 {required String Function(String) term}) {
  String t(String k, String fb) => config != null ? termOf!(config, k, fb) : fb;
  var mc = 0;
  num mi = 0;
  num mu = 0;
  for (final e in entries) {
    if (!inMonth(e['date'])) continue;
    mc++;
    final amount = (e['amount'] as num?) ?? 0;
    if (e['cur'] == '\$') {
      mu += amount;
    } else {
      mi += amount;
    }
  }
  if (mc == 0) return term('ayn') + t('entity.donations', term('trvmvt')) + term('mtvadvt-bchvdsh-zh');
  final sums = (mi != 0 ? '₪' + _heGroup(mi) : '') +
      (mi != 0 && mu != 0 ? ' + ' : '') +
      (mu != 0 ? '\$' + _heGroup(mu) : '');
  return '$mc ' +
      t('entity.donations', term('trvmvt')) +
      term('hchvdsh') +
      (sums.isEmpty ? term('skvmym-mhkvbts-hhystvry') : sums);
}

/// he-IL grouping (thousands separator = comma), mirroring Number.toLocaleString('he-IL')
/// for numeric values: Western digits, comma every three integer digits, no RTL mark.
String _heGroup(num n) {
  final neg = n < 0;
  final abs = neg ? -n : n;
  final whole = abs.truncate();
  String frac = '';
  if (abs != whole) {
    // up to 3 fraction digits, matching the default he-IL number format.
    final r = (abs * 1000).round() / 1000;
    final parts = r.toString().split('.');
    if (parts.length > 1) frac = '.' + parts[1];
    return (neg ? '-' : '') + _group3(r.truncate().toString()) + frac;
  }
  return (neg ? '-' : '') + _group3(whole.toString());
}

String _group3(String digits) {
  final buf = StringBuffer();
  final len = digits.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return buf.toString();
}
