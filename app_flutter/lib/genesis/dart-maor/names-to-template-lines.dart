/// חוט · names-to-template-lines — פריטי-"עין" ⇒ שורות-תבנית רזות.
/// המרה נאמנה מ-new/atoms/names-to-template-lines.mjs (חולץ מ-maor/src/lib/ayin.ts:119-125).
/// חוק-4: התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). טהור top-level, אפס import (dart:core בלבד).
///
/// המקור:
///   names.filter(n => n.name.trim()).map(n => ({name:n.name.trim(), qty:+n.eyes||0, rate:n.rate||0}))
///
/// הערות-המרה (מקור→Dart, כללי DART-PORTING-RULES):
///  • truthiness (כלל 7): הפילטר `n.name.trim()` = מחרוזת-לא-ריקה ⇒ `.isNotEmpty`.
///  • `+n.eyes || 0`: כפייה-מספרית של JS (`_jsNumber`) ואז `|| 0` — NaN/0 נופלים ל-0.
///    ‏Number('')===0, Number('  ')===0, Number('abc')===NaN, Number('3')===3, Number(2.5)===2.5,
///    ‏undefined→NaN. num.tryParse משמר int ל-'3' ו-double ל-'2.5' (כלל 10 — tryParse לא זורק).
///  • `n.rate || 0`: JS-truthiness (`_jsTruthy`) — 0/NaN/null/undefined/'' ⇒ 0, אחרת הערך.
///  • null==undefined כאן חסר-משמעות: מפתח-חסר וגם null שניהם ⇒ 0 דרך `||` (כלל 2 לא-רלוונטי לפלט).
///  • אפס מוטציה של הקלט — filter/map בונים רשימה חדשה (contract: "לא משנה את הקלט").

bool _jsTruthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // objects/arrays truthy ב-JS
}

/// מחקה את כפיית `+v` / `Number(v)` של JS. מחזיר double.nan על קלט לא-מספרי.
num _jsNumber(dynamic v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return double.nan; // undefined→NaN (null→0, אך שניהם נופלים ל-0 דרך ||)
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0; // JS Number('')===0, Number('  ')===0
    return num.tryParse(s) ?? double.nan; // 'abc'→NaN
  }
  return double.nan;
}

/// פריטי-"עין" ⇒ שורות-תבנית רזות {name, qty, rate}.
/// המרה נאמנה של new/atoms/names-to-template-lines.mjs.
List<Map<String, dynamic>> namesToTemplateLines(List<Map<String, dynamic>> names) {
  final out = <Map<String, dynamic>>[];
  for (final n in names) {
    final name = (n['name'] as String).trim();
    if (name.isEmpty) continue; // `.filter(n => n.name.trim())`
    final e = _jsNumber(n['eyes']);
    final num qty = (e.isNaN || e == 0) ? 0 : e; // `+n.eyes || 0`
    final r = n['rate'];
    final num rate = _jsTruthy(r) ? (r as num) : 0; // `n.rate || 0`
    out.add({'name': name, 'qty': qty, 'rate': rate});
  }
  return out;
}
