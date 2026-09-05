/// חוט · given-value — Σ השווי שנמסר בפועל (מימושים חיים בלבד).
/// המרה נאמנה מ-new/atoms/given-value.mjs (חוק-4: המקור קדוש).
/// השכן liveRedemptions הוזרק כשקע (חוק-1 — אפס import פנימי).
/// Number.isFinite של JS ⇒ `v is num && v.isFinite` (null/NaN/∞ נספרים 0, בלי coercion).
num givenValue(List assignments, List Function(dynamic) liveRedemptions) {
  num sum = 0;
  for (final a in assignments) {
    for (final r in liveRedemptions(a)) {
      final v = r['value'];
      sum += (v is num && v.isFinite) ? v : 0;
    }
  }
  return sum;
}
