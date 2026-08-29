/// חוט · wa-payment-text — נוסח תזכורת-תשלום ידידותית (חוגים) לוואטסאפ.
/// חוזה: wa-payment-text.contract.md · מקור-האמת: new/atoms/wa-payment-text.mjs
/// (חולץ מ-maor/src/lib/wa.ts:58-64). השכנים renderTemplate ו-orgOf = שקעי-פרמטר
/// (חוק-1 — אפס import של אטום אחר).
///
/// תיקון-הסגר (26.8): הפורמט he-IL של סכום שלילי דורש קידומת LRM (U+200E) לפני
/// המינוס, ו-Math.round של JS משמר אפס-שלילי (‏-0.5 ⇒ -0 ⇒ '‎-0'). שני העוזרים
/// _jsRound + _jsHeIlInt הוזרקו INLINE מהספרייה js-compat (חוק-1 — אפס import).

const int _pow2_53 = 9007199254740992; // 2^53 — גבול השלם-הבטוח של JS

/// חוק-6-נלווה · Math.round של JS: חצי מתעגל כלפי +∞ ‏(-2.5 ⇒ -2), ומשמר אפס-שלילי
/// ‏(ערך ב-(-0.5,0] ⇒ -0). NaN/אינסוף עוברים כפי-שהם.
num _jsRound(num x) {
  final d = x.toDouble();
  if (d.isNaN || d.isInfinite) return d;
  if (d == 0) return d; // משמר +0/-0
  final r = (d + 0.5).floorToDouble();
  if (r == 0 && d < 0) return -0.0; // JS: תוצאה-אפס מקלט-שלילי ⇒ -0
  return r;
}

/// ספרות-שלם מוחלטות מורחבות-מלא (‏toLocaleString מרחיב גם ≥1e21). **קריטי:**
/// ‏JS toLocaleString/String() = shortest-round-trip (‏1.2345678901234568e20 ⇒
/// "123456789012345680000"), **לא** פריסת-ה-double המדויקת (‏…683968) של
/// toStringAsFixed. Dart.toString נותן אותן ספרות (shortest) בצורת מעריכי/‎.0 —
/// כאן מרחיבים לשלם מלא. אומת מול Node (כולל 1e21/1.5e21/…680000).
String _absIntDigits(num a) {
  if (a is int) return a.abs().toString();
  final d = (a as double).abs();
  if (d == 0) return '0';
  if (d < _pow2_53) return d.toInt().toString();
  return _expandIntFromDart(d);
}

String _expandIntFromDart(double ad) {
  var s = ad.toString(); // ad>0, שלם-ערך: "D", "D.0", "D.DDDe+XX"
  var e = 0;
  final ei = s.indexOf('e');
  if (ei >= 0) {
    e = int.parse(s.substring(ei + 1));
    s = s.substring(0, ei);
  }
  String intp, frac;
  final di = s.indexOf('.');
  if (di >= 0) {
    intp = s.substring(0, di);
    frac = s.substring(di + 1);
  } else {
    intp = s;
    frac = '';
  }
  if (frac == '0') frac = '';
  final digits = intp + frac;
  final pointPos = intp.length + e;
  if (pointPos >= digits.length) return digits + '0' * (pointPos - digits.length);
  return digits.substring(0, pointPos);
}

/// חוק-6 · jsHeIlInt — מחקה `Math.round(n).toLocaleString('he-IL')` לשלמים (מהספרייה).
/// חיובי מקובץ-פסיקים (1,234,567); שלילי **וגם -0** ⇒ U+200E (LRM) + '-' + מקובץ.
/// n מגיע כבר-מעוגל (הקורא עשה _jsRound). מזהה -0.0.
String _jsHeIlInt(num n) {
  final neg = n < 0 || (n is double && n == 0 && n.isNegative);
  final digits = _absIntDigits(n < 0 ? -n : n); // ספרות-abs מורחבות-מלא
  final buf = StringBuffer();
  final len = digits.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final grouped = buf.toString();
  return neg ? '‎-' + grouped : grouped;
}

dynamic waPaymentText(dynamic orgName, dynamic what, dynamic balance,
    dynamic cfg, dynamic renderTemplate, dynamic orgOf) {
  return renderTemplate(cfg, 'wa.payment', {
    'org': orgOf(orgName),
    'what': what,
    'amount': _jsHeIlInt(_jsRound(balance)),
  });
}
