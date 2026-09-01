/// חוט · kit-progress — התקדמות ערכת-התקנה/מסירה של פרויקט (ורטיקל-הסטודיו).
/// המרה נאמנה מ-new/atoms/kit-progress.mjs (חוק-4: המקור קדוש).
/// נגזרת טהורה של a.kit בלבד — אפס import (רק dart-core), אפס שקעים.
///
/// כללי-המרה שהוחלו (DART-PORTING-RULES):
///  #2 null≠undefined — קלט null/חסר-kit ⇒ ריק, דרך `?.` + `?? const []`.
///  #7 truthiness — `k.done ?` של JS ⇒ `_truthy` (לא רק `== true`).
///  Math.round של JS מעגל חצי כלפי +∞; done/total ≥ 0 ⇒ זהה ל-`.round()` של Dart.
Map<String, Object> kitProgress(Map? a) {
  final kit = (a?['kit'] as List?) ?? const [];
  final total = kit.length;
  var done = 0;
  for (final k in kit) {
    final d = (k is Map) ? k['done'] : null;
    if (_truthy(d)) done++;
  }
  final pct = total > 0 ? ((done / total) * 100).round() : 0;
  return {
    'done': done,
    'total': total,
    'pct': pct,
    'ready': total > 0 && done == total,
  };
}

/// truthiness של JS: false / 0 / '' / null / NaN ⇒ falsy; השאר truthy.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
