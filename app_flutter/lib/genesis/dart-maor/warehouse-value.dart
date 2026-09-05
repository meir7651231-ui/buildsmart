// חוט · warehouse-value — ערך-מלאי כולל (Σ qty×cost) למדד-מחסן, מעוגל לשקל שלם.
// חוזה: new/atoms/warehouse-value.contract.md · מוצא: maor/src/lib/warehouse.ts:69-71.
// המרה מ-JS (new/atoms/warehouse-value.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). טהור, לא משנה קלט.
//
// המקור: Math.round(warehouse.reduce((a, w) => a + (+w.qty || 0) * (+w.cost || 0), 0))
//
// הערות-המרה (JS→Dart, לפי RULES-DIGEST):
//  · `+v || 0` ⇒ שקע _num: מספר→עצמו (NaN⇒0) · bool→1/0 · מחרוזת→פרסור-ES
//    (ריק/רווחים⇒0, זבל/NaN⇒0, ‏'.5'/'5.' מתוקנים — תקינים ב-ES ולא ב-Dart,
//    ‏'-0x…'⇒0 — ‏Number של JS דוחה סימן על hex, ‏U+0085/U+180E אינם רווח-ES
//    כלל-16 ⇒ 0) · null/חסר/אחר⇒0.
//  · צבירה ב-double (כלל-17 — אריתמטיקת-JS היא תמיד float64).
//  · Math.round של JS = חצי-כלפי-+∞ (‏-0.5⇒0), בעוד ‏.round() של Dart = חצי-הרחק-
//    מאפס וזורק על אינסוף ⇒ שקע _jsRound (floor + השוואת-שארית; ‏0.49999999999999994⇒0).
//  · העיגול פעם-אחת על הסכום הכולל — לא פר-פריט (559.7 ⇒ 560).
num warehouseValue(dynamic warehouse) {
  double sum = 0;
  for (final w in (warehouse as List)) {
    final row = w is Map ? w : const {};
    sum += _num(row['qty']) * _num(row['cost']);
  }
  return _jsRound(sum);
}

// שקע-כפיית-מספר: מחקה את `+v || 0` של JS.
double _num(Object? v) {
  if (v is bool) return v ? 1 : 0; // +true=1, +false=0 (||0 ⇒ 0)
  if (v is num) {
    final d = v.toDouble();
    return d.isNaN ? 0 : d; // NaN כוזב ⇒ 0; ‏-0 ⇒ 0 באמת-JS — זהה במכפלה ובסכום
  }
  if (v is String) return _numStr(v);
  return 0; // null / מפתח-חסר / טיפוס-אחר: ‏+v הוא 0 או NaN, ואז ||0 ⇒ 0
}

// פרסור-מחרוזת בדקדוק-ES (כלל 10+16+18): Number(s) ואז ||0.
double _numStr(String s) {
  // U+0085/U+180E אינם רווח-לבן ב-ES (כלל-16) — Number ⇒ NaN ⇒ ||0 ⇒ 0,
  // בעוד trim/tryParse של Dart היו גוזמים אותם.
  if (s.contains('\u0085') || s.contains('\u180e')) return 0;
  final t = s.trim();
  if (t.isEmpty) return 0; // Number('') = 0 ⇒ ||0 ⇒ 0
  // ‏Number של JS דוחה סימן לפני קידומת-hex ('-0x10' ⇒ NaN); Dart מקבל.
  if (RegExp(r'^[+-]0[xXoObB]').hasMatch(t)) return 0;
  var u = t;
  // ‏'.5' / '+.5' / '5.' תקינים ב-ES ולא בדקדוק-Dart — משלימים ספרת-אפס.
  if (u.startsWith('.')) {
    u = '0$u';
  } else if (u.length > 1 && (u[0] == '+' || u[0] == '-') && u[1] == '.') {
    u = '${u[0]}0${u.substring(1)}';
  }
  if (u.endsWith('.')) u = '${u}0';
  final p = num.tryParse(u);
  if (p == null) return 0; // זבל ⇒ NaN ⇒ ||0 ⇒ 0
  final d = p.toDouble();
  return d.isNaN ? 0 : d; // 'NaN' מילולי ⇒ ||0 ⇒ 0; אינסוף אמת ⇒ נשמר
}

// Math.round של JS: הקרוב-ביותר, שוויון ⇒ כלפי-+∞; NaN/אינסוף עוברים כמות-שהם.
num _jsRound(double d) {
  if (d.isNaN || d.isInfinite) return d;
  final f = d.floorToDouble();
  final r = (d - f >= 0.5) ? f + 1 : f;
  // "מספר שלם" (חוזה): בטווח-הבטוח מחזירים int; מעבר לו ה-double כבר שלם.
  return r.abs() <= 9007199254740992.0 ? r.toInt() : r;
}
