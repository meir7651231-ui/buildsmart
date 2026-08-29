/// חוט · wa-digits — הומר JS→Dart (מקור: new/atoms/wa-digits.mjs).
/// חוזה: wa-digits.contract.md — זהה-ביט להקלטות-Golden.

/// חוק-7 (RULES-DIGEST): truthiness של JS — '' / 0 / -0 / NaN / null / false כוזבים.
bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || v == 0 || (v is num && v.isNaN);

dynamic waDigits(dynamic phone) {
  // JS: (phone || '').replace(/\D/g, '') — replace גלובלי של כל לא-ספרה.
  var d = (_falsy(phone) ? '' : phone).replaceAll(RegExp(r'\D'), '');
  if (_falsy(d)) return null;
  if (d.startsWith('00972')) {
    d = '972' + d.substring(5);
  } else if (d.startsWith('00')) {
    d = d.substring(2); // קידומת חיוג בינ"ל כללית
  }
  if (d.startsWith('9720')) {
    d = '972' + d.substring(4); // ‎+972 שנשמר עם ה-0 המקומי
  }
  if (!d.startsWith('972') &&
      !d.startsWith('0') &&
      (d.length == 8 || d.length == 9)) {
    d = '0' + d; // ישראלי בלי 0 מוביל — אותו דין כמו formatIsraeliPhone
  }
  if (d.startsWith('0')) {
    if (d.length == 9 || d.length == 10) {
      d = '972' + d.substring(1);
    } else {
      return null; // 0-מוביל באורך אחר = לא-תקין ל-wa.me — עדיף בלי כפתור
    }
  }
  if (d.length < 8 || d.length > 15) return null; // גבולות E.164
  return d;
}
