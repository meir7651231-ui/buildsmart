// ⚛️ אטום-Dart (דרגת-חוזה) · roomInfoLabel — שורת-המידע על חדר
//    (משבצות · קיבולת · נגישות · ציוד).
// מוצא: maor/src/components/diary/lib.ts:291-304 · המקור: new/atoms/room-info-label.mjs
// חוזה: new/atoms/room-info-label.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט
//    למקור-ה-JS. אפס שקעים (אין locale / לוח-עברי — שרשור-מחרוזות בלבד).
//
// 🔧 תיקון-הסגר (כלל-12 · FIXES.md "פריסה-עשרונית מול shortest-round-trip"):
//    האטום נפל על שרשור double שלם בטווח [2^53, 1e21). המקור-השבור השתמש
//    ב-`toStringAsFixed(0)` שמדפיס את הפריסה-העשרונית-המדויקת של ה-double
//    (…688128) — אך JS `String(n)` מדפיס shortest-round-trip מרופד-אפסים
//    (…690000). ‏_jsStr המתוקן לוקח את `double.toString()` של Dart (שהוא
//    shortest-round-trip זהה-V8, פריסה-מלאה מרופדת-אפסים מתחת ל-1e21) וגוזם
//    את הזנב '.0' ש-Dart מוסיף לשלמים. אומת מול Node: 45/12/30/60 וכן
//    100000000000000680000 ⇒ '…690000'.
//
// הערות-המרה (DART-PORTING-RULES):
//  • truthiness (כלל 7): `room.eq || {}` / `room.slot || 60` / `room.cap ?` /
//    `room.access ?` / `.filter(([,v]) => v)` של JS ⇒ שקע `_truthy` מפורש.
//  • `Object.entries(eq)` — סדר-JS: מפתחות-אינדקס-מערך ממוינים עולה תחילה,
//    אחר-כך שאר-המפתחות בסדר-הכנסה ⇒ `_jsOwnKeys` משחזר את הסדר.
//  • שרשור מספר-למחרוזת ⇒ `_jsStr` (ראה תיקון-ההסגר לעיל).
//  • `eqOn.slice(0, 3)` הסלחן של JS ⇒ `take(3)`.

bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || v == '' || (v is num && v.isNaN);
bool _truthy(dynamic v) => !_falsy(v);

/// JS String(v) for concatenation. Numbers follow ECMAScript Number-to-String:
/// integral doubles print without a decimal point, and values in [2^53, 1e21)
/// use the *shortest round-trip* decimal (zero-padded), not the exact binary
/// expansion. Dart's `double.toString()` already yields shortest-round-trip
/// (V8-equivalent) full decimal below 1e21; we only strip the trailing '.0'.
String _jsStr(dynamic v) {
  if (v is num) {
    if (v is int) return v.toString();
    final d = v.toDouble();
    if (d.isNaN) return 'NaN';
    if (d == double.infinity) return 'Infinity';
    if (d == double.negativeInfinity) return '-Infinity';
    if (d == 0) return '0'; // כולל -0.0 ⇒ JS String(-0) === '0'
    var s = d.toString();
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
  }
  return v.toString();
}

final _arrayIndexRe = RegExp(r'^(0|[1-9]\d*)$');

/// Own-key order of JS Object.entries: array-index-like string keys ascending
/// first, then the remaining keys in insertion order.
List<dynamic> _jsOwnKeys(Map m) {
  final idx = <String>[];
  final rest = <dynamic>[];
  for (final k in m.keys) {
    if (k is String && k.length <= 10 && _arrayIndexRe.hasMatch(k)) {
      final n = int.parse(k);
      if (n <= 4294967294) {
        idx.add(k);
        continue;
      }
    }
    rest.add(k);
  }
  idx.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  return [...idx, ...rest];
}

/// Room info line: slot length (default 60) · capacity · accessibility · up to
/// 3 enabled equipment keys. Verbatim behaviour of the JS `roomInfoLabel`.
String roomInfoLabel(dynamic room, Map<String, String> T) {
  final eqRaw = room['eq'];
  final Map eq = _truthy(eqRaw) ? eqRaw as Map : const {};
  final eqOn = <dynamic>[];
  for (final k in _jsOwnKeys(eq)) {
    if (_truthy(eq[k])) eqOn.add(k);
  }
  final slot = room['slot'];
  final cap = room['cap'];
  return T['k1']! +
      _jsStr(_truthy(slot) ? slot : 60) +
      T['k2']! +
      (_truthy(cap) ? T['k3']! + _jsStr(cap) + T['k4']! : '') +
      (_truthy(room['access']) ? T['k5']! : '') +
      (eqOn.isNotEmpty ? ' · ' + eqOn.take(3).map(_jsStr).join(', ') : '');
}
