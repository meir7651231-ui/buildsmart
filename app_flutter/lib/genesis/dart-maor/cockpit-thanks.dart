// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitThanks — תודות ממתינות (תרומה ב-windowDays האחרונים).
// מוצא: maor/src/components/supporters/cockpit.ts:150 + latestDonation:133 (inline) + COCKPIT_THANK_DAYS=3.
//        המקור-הקדוש: new/atoms/cockpit-thanks.mjs. חוק-4 — זהה-ביט למקור-JS.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). השכן daysSince מוזרק כשקע.
//        latestDonation הוטבע inline; פורמט-הכסף (_grp) inline מ-js-compat (toLocaleString).
//
// תפקיד: לכל תורם — התרומה האחרונה (donations∪hist, לפי-תאריך); אם ago∈[0,windowDays] ⇒ משימת-תודה.
//        ממוין לפי sort=windowDays-ago יורד (החמים-ביותר ראשון).
// הערות-המרה:
//  • `d.date > best.date` השוואת-מחרוזות ⇒ compareTo>0. `d.cur || '₪'` — null/'' ⇒ '₪'.
//  • `amount.toLocaleString('en-US')/('he-IL')` — שתי-הלוקאלות מקבצות-אלפים בפסיק זהה
//    (אומת מול Node: 1000⇒"1,000"); _grp מיישם קיבוץ-שלושות. פלט זהה.
//  • המיון יציב (עוגן-אינדקס משני) — נאמן ל-Array.sort היציב של JS.

/// Pending thank-yous: donors with a donation in the last windowDays, warmest first.
/// Verbatim port of new/atoms/cockpit-thanks.mjs (latestDonation + money-format inlined).
List<Map<String, dynamic>> cockpitThanks(
  List supporters,
  String todayIso,
  int windowDays,
  num Function(String, String) daysSince,
 {required String Function(String) term}) {
  Map? latestDonation(Map sp) {
    Map? best;
    for (final dd in (sp['donations'] as List)) {
      final d = dd as Map;
      final date = d['date'];
      if (date == null || date == '') continue;
      if (best == null || (date as String).compareTo(best['date'] as String) > 0) {
        final cur = d['cur'];
        best = {'date': date, 'amount': d['amount'], 'cur': (cur == null || cur == '') ? '₪' : cur};
      }
    }
    for (final hh in ((sp['hist'] ?? const []) as List)) {
      final h = hh as Map;
      final hd = h['d'];
      if (hd == null || hd == '') continue;
      if (best == null || (hd as String).compareTo(best['date'] as String) > 0) {
        final cc = h['c'];
        best = {'date': hd, 'amount': h['a'], 'cur': (cc == null || cc == '') ? '₪' : cc};
      }
    }
    return best;
  }

  final tasks = <Map<String, dynamic>>[];
  for (final s in supporters) {
    final sp = s as Map;
    final last = latestDonation(sp);
    if (last == null) continue;
    final ago = daysSince(last['date'] as String, todayIso);
    if (ago < 0 || ago > windowDays) continue;
    final money = last['cur'] == '\$'
        ? '\$' + _grp(last['amount'] as num)
        : '₪' + _grp(last['amount'] as num);
    tasks.add({
      'id': 'thanks:' + sp['id'].toString(),
      'kind': 'thanks',
      'supId': sp['id'],
      'name': sp['name'],
      'phone': (sp['phone'] == null || sp['phone'] == '') ? '' : sp['phone'],
      'email': (sp['email'] == null || sp['email'] == '') ? '' : sp['email'],
      'reason': term('trmh') + money + ' · ' + (ago <= 0 ? term('hyvm') : term('lpny') + _numStr(ago) + term('yvm')),
      'severity': 'warm',
      'sort': windowDays - ago,
    });
  }
  final order = List<int>.generate(tasks.length, (i) => i);
  order.sort((x, y) {
    final c = (tasks[y]['sort'] as num).compareTo(tasks[x]['sort'] as num);
    return c != 0 ? c : x.compareTo(y);
  });
  return [for (final i in order) tasks[i]];
}

// toLocaleString('he-IL'/'en-US') לשלמים — קיבוץ-אלפים בפסיק (אומת מול Node).
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

String _numStr(num n) =>
    (n is int || (n is double && n == n.truncateToDouble() && n.isFinite))
        ? n.toInt().toString()
        : n.toString();
