// ⚛️ אטום-Dart (דרגת-חוזה) · donorScan — מעבר-יחיד על אירועי-נתינה.
// מוצא: maor-system/src/components/supporters/intel.ts:49 (donorScan)+monthsBefore:25 · המקור: new/atoms/intel-donor-scan.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        העוזר-הפרטי monthsBefore הוטבע inline (חוק-1/חוק-2), לוכד את todayIso בסגירה.
//
// הערות-המרה (JS→Dart):
//  • הנתונים הם Map (אובייקטי-JS): d.date/d.amount/d.cur ⇒ d['date']/d['amount']/d['cur'].
//  • `!date` (ריק/null) ⇒ date == null || date == '' (דלג).
//  • `(cur || '₪')` — cur כוזב (null/'') ⇒ '₪'.
//  • אריתמטיקת-JS float64: v = ₪ ? amount : amount*rate. int*double ⇒ double (זהה-IEEE754).
//    ils/monthly = num (מתחיל int 0, הופך double כשמתווסף ערך-מטבע-זר). 50*3.7 == 185.0 מדויק.
//  • השוואת-מחרוזות `date < first` (לקסיקוגרפי, ISO=כרונולוגי) ⇒ compareTo(...) < 0.
//  • `new Array(months).fill(0)` ⇒ List<num>.filled (אורך-קבוע; הצבת-אינדקס מותרת).
//  • הפלט Map בסדר-מפתחות זהה: count → ils → first → last → monthly (LinkedHashMap).

/// Single pass over gift events: {count, ils, first, last, monthly} (oldest→newest series).
/// Verbatim port of intel-donor-scan.mjs (`donorScan`); `monthsBefore` inlined.
Map<String, dynamic> donorScan(Map<String, dynamic> sp, String todayIso,
    [num rate = 3.7, int months = 12]) {
  int monthsBefore(String iso) {
    final y = iso.length >= 4 ? (int.tryParse(iso.substring(0, 4)) ?? 0) : 0;
    final m = iso.length >= 7 ? (int.tryParse(iso.substring(5, 7)) ?? 0) : 0;
    final ty =
        todayIso.length >= 4 ? (int.tryParse(todayIso.substring(0, 4)) ?? 0) : 0;
    final tm =
        todayIso.length >= 7 ? (int.tryParse(todayIso.substring(5, 7)) ?? 0) : 0;
    if (y == 0 || m == 0 || ty == 0 || tm == 0) return -1;
    return ty * 12 + tm - (y * 12 + m);
  }

  final monthly = List<num>.filled(months, 0);
  int count = 0;
  num ils = 0;
  String first = '', last = '';

  void take(dynamic date, dynamic amount, dynamic cur) {
    if (date == null || date == '') return;
    count++;
    final curEff = (cur == null || cur == '') ? '₪' : cur;
    final num v = curEff == '\$' ? (amount as num) * rate : (amount as num);
    ils += v;
    final ds = date as String;
    if (first.isEmpty || ds.compareTo(first) < 0) first = ds;
    if (last.isEmpty || ds.compareTo(last) > 0) last = ds;
    final mb = monthsBefore(ds);
    if (mb >= 0 && mb < months) monthly[months - 1 - mb] += v;
  }

  final dons = sp['donations'] as List;
  for (var i = 0; i < dons.length; i++) {
    final d = dons[i] as Map;
    take(d['date'], d['amount'], d['cur']);
  }
  final hist = sp['hist'];
  if (hist != null) {
    final h = hist as List;
    for (var i = 0; i < h.length; i++) {
      final e = h[i] as Map;
      take(e['d'], e['a'], e['c']);
    }
  }
  return {
    'count': count,
    'ils': ils,
    'first': first,
    'last': last,
    'monthly': monthly,
  };
}
