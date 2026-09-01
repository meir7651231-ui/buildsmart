/// חוט · effective-price — מחיר סמלי אחרי הנחת-הקריטריון הגבוהה (עיגול, ≥0).
/// המרה נאמנה מ-new/atoms/effective-price.mjs (חוק-4: המקור קדוש).
/// שקע (חוק-1): maxDiscountPct(criterionIds, criteria)→אחוז-ההנחה הגבוה (0 כשאין).
/// הערות-המרה: Number.isFinite⇒num.isFinite (NaN⇒0);
/// Math.round(x)=floor(x+0.5) — משוקף מפורשות לזהות-ביט מול JS.
int effectivePrice(
  num basePrice,
  List<String> criterionIds,
  List<Map<String, dynamic>> criteria,
  num Function(List<String>, List<Map<String, dynamic>>) maxDiscountPct,
) {
  final pct = maxDiscountPct(criterionIds, criteria);
  final num base = basePrice.isFinite ? basePrice : 0;
  final rounded = (base * (1 - pct / 100) + 0.5).floor();
  return rounded < 0 ? 0 : rounded;
}
