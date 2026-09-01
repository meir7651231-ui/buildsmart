// ⚛️ אטום-Dart (דרגת-חוזה) · smartFilter — סינון+מיון לפי ציון
// מוצא: maor/src/lib/search.ts (חולץ כלשונו) · המקור: new/atoms/smart-filter.mjs
// חוזה: new/atoms/smart-filter.contract.md — ציון 0 נופל, השאר יורדים מהגבוה לנמוך
//        (מיון יציב — שוויון שומר סדר-מקור); שאילתה ריקה ⇒ הרשימה כמות-שהיא; limit חותך.
// שקעים (חוק-11): hasQuery(q) · scoreOf(q, terms) · getTerms(it) — מוזרקים, לא ממומשים כאן.
// טוהר: פונקציית top-level עצמאית, אפס import של אטום אחר; עוזרים מקומיים בקידומת _.
//
// הערות-המרה (חוק-4 — התנהגות זהת-ביט ל-JS):
// • כלל-1 (מיון-יציב): JS Array.sort יציב; Dart List.sort לא-יציב ל-≥32 איברים.
//   ⇒ decorate-sort-undecorate — אינדקס-מקורי כשובר-שוויון (וגם כשההפרש NaN,
//   כי ב-JS תוצאת-comparator NaN מטופלת כ-+0 ⇒ שימור-סדר).
// • כלל-2 (null מול undefined): `limit !== undefined` ב-JS מבחין בין לא-הועבר לבין
//   null-מפורש (null עובר את התנאי ואז slice(0,null) ⇒ ריק). ⇒ זקיף _undefined
//   כברירת-מחדל; null שהועבר במפורש מגיע ל-slice ומקורץ ל-0 (כלל-15).
// • כלל-7 (truthiness): `!hasQuery(q)` — תוצאת-השקע עוברת _truthy נאמן-JS
//   (false/0/-0/NaN/''/null/undefined = שקר).
// • כללים 9/10/15 (קוארציה): `sc > 0` והשוואת `b.sc - a.sc` דרך _toNum שקול-ToNumber
//   (מחרוזת-מספרית משתתפת; NaN לעולם לא >0 ⇒ מסונן); `slice(0, limit)` דרך
//   ToIntegerOrInfinity — NaN⇒0, שלילי⇒מהסוף, clamp לאורך.

/// זקיף "לא-הועבר" — מבחין undefined-של-JS מ-null-מפורש (כלל-2).
class _Undefined {
  const _Undefined();
}

const _Undefined _undefined = _Undefined();

/// truthiness נאמן-JS (כלל-7): false · 0/-0/NaN · '' · null/undefined ⇒ שקר.
bool _truthy(dynamic v) {
  if (v == null || identical(v, _undefined)) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // אובייקטים/מערכים/פונקציות — תמיד אמת ב-JS
}

/// ToNumber שקול-JS (כללים 9/10): num⇒עצמו · bool⇒1/0 · null⇒0 · undefined⇒NaN ·
/// מחרוזת⇒trim ואז פרסור ('«ריק»'⇒0, כשל⇒NaN) · אחר⇒NaN (ללא valueOf — אין כאן).
num _toNum(dynamic v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return 0;
  if (identical(v, _undefined)) return double.nan;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    return num.tryParse(s) ?? double.nan;
  }
  return double.nan;
}

/// ToIntegerOrInfinity של JS (כלל-15): NaN⇒0 · ±Inf נשמר · אחרת truncate.
num _toIntOrInf(dynamic v) {
  final n = _toNum(v);
  if (n is double) {
    if (n.isNaN) return 0;
    if (n.isInfinite) return n;
    return n.truncate();
  }
  return n; // int
}

/// arr.slice(0, end) של JS על end שהועבר (כולל null/מחרוזת/שלילי): קוארציה
/// ל-ToIntegerOrInfinity, שלילי יחסי-לסוף, clamp ל-[0,len]. מחזיר עותק חדש.
List _jsSliceTo(List arr, dynamic end) {
  final len = arr.length;
  final e = _toIntOrInf(end);
  int stop;
  if (e == double.negativeInfinity) {
    stop = 0;
  } else if (e < 0) {
    final rel = len + e.toInt();
    stop = rel < 0 ? 0 : rel;
  } else if (e == double.infinity || e > len) {
    stop = len;
  } else {
    stop = e.toInt();
  }
  return arr.sublist(0, stop);
}

/// מסנן וממיין רשימת-פריטים לפי ציון-חיפוש — התנהגות זהת-ביט ל-JS
/// new/atoms/smart-filter.mjs. ‏limit לא-הועבר ⇒ כל-התוצאות (עותק).
dynamic smartFilter(dynamic q, dynamic items, dynamic getTerms, dynamic hasQuery,
    dynamic scoreOf, [dynamic limit = _undefined]) {
  final List list = items as List;
  final bool hasLimit = !identical(limit, _undefined);
  if (!_truthy(hasQuery(q))) {
    // JS: items.slice(0, limit) או items.slice() — תמיד עותק חדש.
    return hasLimit ? _jsSliceTo(list, limit) : list.sublist(0);
  }
  final scored = <Map<String, dynamic>>[];
  for (final it in list) {
    final sc = scoreOf(q, getTerms(it));
    final n = _toNum(sc);
    if (!n.isNaN && n > 0) scored.add({'it': it, 'sc': sc});
  }
  // מיון-יציב (כלל-1): אינדקסים ממוינים לפי הציון-יורד; שוויון/NaN ⇒ סדר-מקור.
  final idx = List<int>.generate(scored.length, (i) => i);
  idx.sort((a, b) {
    final num d = _toNum(scored[b]['sc']) - _toNum(scored[a]['sc']);
    if (d is double && d.isNaN) return a.compareTo(b); // JS: NaN ⇒ +0 ⇒ יציבות
    if (d > 0) return 1;
    if (d < 0) return -1;
    return a.compareTo(b);
  });
  final out = [for (final i in idx) scored[i]['it']];
  return hasLimit ? _jsSliceTo(out, limit) : out;
}
