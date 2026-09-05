// חוט · term-label — תווית-תצוגה לתקופת-חיוב; 'months' מציג את המספר ("N חודשים").
// המרה מ-JS (new/atoms/term-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// קבוע-השכן PRICING_TERMS מוזרק כשקע terms (חוק-1 — אפס import של אטום אחר).
// חוזה: term-label.contract.md

// ‏String(num) של JS: מספר-שלם מודפס בלי ".0" (חוק-12 — Dart מדפיס 1.0 ל-double).
String _jsNumStr(dynamic n) {
  if (n is double && n.isFinite && n == n.roundToDouble() && n.abs() < 1e21) {
    final s = n.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
  return '$n';
}

dynamic termLabel(dynamic term, dynamic months, dynamic terms, Map<String, String> T) {
  if (term == 'months') {
    // JS: ‏months && months > 0 — ‏null/undefined/0/NaN כוזבים ⇒ 1 (חוק-7);
    // ‏months > 0 כבר מכסה 0/NaN/שלילי, כך שנותר רק לוודא שזה מספר.
    final m = (months is num && months > 0) ? months : 1;
    return '${_jsNumStr(m)}${T['k2']!}';
  }
  // JS: ‏terms.find(x => x.v === term)?.t ?? '' — לא-נמצא ⇒ '' (אין זריקה).
  for (final x in (terms as List)) {
    if (x['v'] == term) return x['t'] ?? '';
  }
  return '';
}
