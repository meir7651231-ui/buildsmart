// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitFeed — N אירועים אחרונים, מהחדש לישן (פיד-הקוקפיט).
// מוצא: maor/src/components/supporters/cockpit.ts:299 · המקור-הקדוש: new/atoms/cockpit-feed.mjs.
//        חוק-4 — זהה-ביט למקור-JS. השכן orgCalEntries מוזרק כשקע. פורמט-הכסף (_grp) inline.
//
// קלט: supporters (List<Map>) · limit (int) · שקע orgCalEntries(supporters) ⇒ List<Map{date,name,amount,cur,spId,src}>.
//      פלט: List<Map> בסדר id→date→who→what→spId.
// הערות-המרה:
//  • `.filter(e => e.date)` ⇒ where(date truthy). המיון (a.date<b.date?1:...:-1:0) = יורד לפי-תאריך;
//    יציב (עוגן-אינדקס משני — Dart List.sort אינו יציב; JS Array.sort יציב).
//  • `.slice(0, limit)` ⇒ take(limit). `.map((e,i)=>...)` — i = אינדקס ברשימה-החתוכה.
//  • `e.amount > 0` · `e.cur === '$'` · `e.spId ?? 'x'` · `e.name ?? ''` · `money ? ... : e.src||''`.
//  • `amount.toLocaleString(...)` ⇒ _grp (קיבוץ-אלפים, אומת מול Node).

/// Last N calendar events, newest-first, shaped for the cockpit feed.
/// Verbatim port of new/atoms/cockpit-feed.mjs (money-format inlined; orgCalEntries as socket).
List<Map<String, dynamic>> cockpitFeed(
  List supporters,
  int limit,
  List Function(List) orgCalEntries,
 {required String Function(String) term}) {
  final entries = orgCalEntries(supporters).where((e) {
    final d = (e as Map)['date'];
    return d != null && d != '';
  }).toList();
  // מיון יורד לפי-תאריך, יציב (עוגן-אינדקס משני).
  final order = List<int>.generate(entries.length, (i) => i);
  order.sort((x, y) {
    final dx = (entries[x] as Map)['date'] as String;
    final dy = (entries[y] as Map)['date'] as String;
    final c = dy.compareTo(dx);
    return c != 0 ? c : x.compareTo(y);
  });
  final sorted = [for (final i in order) entries[i] as Map];
  final sliced = sorted.take(limit).toList();
  final out = <Map<String, dynamic>>[];
  for (var i = 0; i < sliced.length; i++) {
    final e = sliced[i];
    final amount = e['amount'];
    final money = (amount is num && amount > 0)
        ? (e['cur'] == '\$' ? '\$' + _grp(amount) : '₪' + _grp(amount))
        : '';
    final src = e['src'];
    out.add({
      'id': (e['spId'] ?? 'x').toString() + ':' + e['date'].toString() + ':' + i.toString(),
      'date': e['date'],
      'who': e['name'] ?? '',
      'what': money.isNotEmpty ? term('trmh') + money : ((src == null || src == '') ? '' : src),
      'spId': e['spId'],
    });
  }
  return out;
}

// toLocaleString לשלמים — קיבוץ-אלפים בפסיק (אומת מול Node).
String _grp(num n) {
  final neg = n < 0;
  final abs = neg ? -n : n;
  String intPart;
  String frac = '';
  if (abs is int) {
    intPart = abs.toString();
  } else {
    final d = abs as double;
    if (d == d.truncateToDouble() && d.isFinite) {
      intPart = d.toInt().toString();
    } else {
      final str = d.toString();
      final dot = str.indexOf('.');
      intPart = dot >= 0 ? str.substring(0, dot) : str;
      frac = dot >= 0 ? str.substring(dot) : '';
    }
  }
  final buf = StringBuffer();
  final len = intPart.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return (neg ? '-' : '') + buf.toString() + frac;
}
