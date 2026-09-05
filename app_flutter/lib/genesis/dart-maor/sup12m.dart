/// חוט · sup12m — מונה "תרמו ב-12 החודשים": כמה תורמים שתאריך-התרומה-האחרונה
/// שלהם (דרך שקע supLast, כולל היסטוריה) בתוך 365 הימים שקדמו להיום-המוזרק
/// (כולל יום-הסף עצמו). חוזה: sup12m.contract.md · מקור-האמת: new/atoms/sup12m.mjs.
/// הערות-נאמנות (DART-PORTING-RULES):
/// · ‏JS ‏setDate(getDate()-365) = אריתמטיקת-לוח מקומית מנרמלת ⇒ בנאי-DateTime
///   מנרמל (day-365) — לא ‏subtract(Duration) שרגיש ל-DST (רוח חוק-3).
/// · ‏`last && last >= cut` ⇒ ‏falsiness-JS מפורש (חוק-7) + השוואת-מחרוזות
///   לפי יחידות-קוד (‏compareTo של Dart ≡ ‏>= של JS על מחרוזות).
/// · אפס-import של אטום אחר — השכן ‏supLast מוזרק כשקע (חוק-1 של המחצב).

/// falsiness של JS על ערך-השקע: null / '' / 0 / -0 / NaN / false ⇒ שקרי.
bool _jsTruthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return !(v == 0 || v.isNaN);
  return true;
}

/// String(n).padStart(2,'0') של JS.
String _p2(dynamic n) => n.toString().padLeft(2, '0');

dynamic sup12m(dynamic supporters, dynamic todayIso, dynamic supLast) {
  // ‏new Date(todayIso+'T12:00:00') — צורת תאריך-שעה עם 'T' בלי אזור ⇒ זמן מקומי,
  // ואז ‏setDate(getDate()-365): נרמול-לוח גרגוריאני (זהה בבנאי-DateTime של Dart).
  final d0 = DateTime.parse((todayIso as String) + 'T12:00:00');
  final d = DateTime(d0.year, d0.month, d0.day - 365, 12);
  final cut = '${d.year}-${_p2(d.month)}-${_p2(d.day)}';
  var n = 0;
  for (final sp in (supporters as List)) {
    final last = supLast(sp);
    // ‏JS: ‏last && last >= cut — השוואה לקסיקוגרפית לפי יחידות-UTF-16.
    if (_jsTruthy(last) && (last as String).compareTo(cut) >= 0) n++;
  }
  return n;
}
