/// חוט · wa-digits — הומר JS→Dart (מקור: new/atoms/wa-digits.mjs).
/// חוזה: wa-digits.contract.md — זהה-ביט להקלטות-Golden.

/// חוק-7 (RULES-DIGEST): truthiness של JS — '' / 0 / -0 / NaN / null / false כוזבים.

/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים. (הוזרק ע"י מתקן-ההסגר)
bool _rqTruthy(dynamic v) =>
    !(v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN)));

bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || v == 0 || (v is num && v.isNaN);

dynamic waDigits(dynamic phone) {
  // JS: (phone || '').replace(/\D/g, '') — replace גלובלי של כל לא-ספרה.
  var d = (_falsy(phone) ? '' : phone).replaceAll(RegExp(r'\D'), '');
  if (_falsy(d)) return null;
  if (_rqTruthy(d.startsWith('00972'))) {
    d = '972' + ((d.substring(5)) as String);
  } else if (_rqTruthy(d.startsWith('00'))) {
    d = d.substring(2); // קידומת חיוג בינ"ל כללית
  }
  if (_rqTruthy(d.startsWith('9720'))) {
    d = '972' + ((d.substring(4)) as String); // ‎+972 שנשמר עם ה-0 המקומי
  }
  if (!_rqTruthy(d.startsWith('972')) &&
      !_rqTruthy(d.startsWith('0')) &&
      (d.length == 8 || d.length == 9)) {
    d = '0' + ((d) as String); // ישראלי בלי 0 מוביל — אותו דין כמו formatIsraeliPhone
  }
  if (_rqTruthy(d.startsWith('0'))) {
    if (d.length == 9 || d.length == 10) {
      d = '972' + ((d.substring(1)) as String);
    } else {
      return null; // 0-מוביל באורך אחר = לא-תקין ל-wa.me — עדיף בלי כפתור
    }
  }
  if (_rqTruthy(d.length < 8) || _rqTruthy(d.length > 15)) return null; // גבולות E.164
  return d;
}
