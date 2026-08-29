/// חוט · sup-usd (Dart) — סה"כ $ של תורם כולל היסטוריה: מונה-הקבלות (usd) +
/// שורות-hist דולריות. מקור-האמת: new/atoms/sup-usd.mjs · חוזה: sup-usd.contract.md.
/// נאמנות-JS: `usd || 0` = truthiness (חוק-7) · `hist ?? []` = nullish בלבד ·
/// `c === '$'` = שוויון-קשיח · האריתמטיקה כולה float64 (חוק-17).

/// falsy של JS: undefined/null · false · 0/-0/NaN · '' (חוק-7).
/// מפתח-חסר ב-Map ⇒ null ⇒ falsy — זהה ל-`undefined || 0` של JS.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    (v is num && (v == 0 || v.isNaN)) ||
    v == '';

/// גישת-שדה נאמנת-JS: Map ⇒ lookup (מפתח-חסר ⇒ null ≈ undefined).
dynamic _get(dynamic o, String k) => (o is Map) ? o[k] : null;

/// חוק-17: ה-`+` של JS חי במרחב-double — כופים toDouble בענף-המספרי.
double _jsAdd(num a, num b) => a.toDouble() + b.toDouble();

dynamic supUsd(dynamic sp) {
  // (sp.usd || 0)
  final dynamic usdRaw = _get(sp, 'usd');
  final num usd = _falsy(usdRaw) ? 0 : (usdRaw as num);
  // (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? h.a : 0), 0)
  final dynamic hist = _get(sp, 'hist') ?? [];
  num acc = 0;
  for (final h in (hist as List)) {
    final bool isUsd = _get(h, 'c') == '\$';
    acc = _jsAdd(acc, isUsd ? (_get(h, 'a') as num) : 0);
  }
  return _jsAdd(usd, acc);
}
