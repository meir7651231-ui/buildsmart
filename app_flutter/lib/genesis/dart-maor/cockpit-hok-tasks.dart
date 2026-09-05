// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitHokTasks — הוראות-קבע שטרם-נרשמו החודש כתור-פעולה.
// מוצא: maor/src/components/supporters/cockpit.ts:180 · המקור-הקדוש: new/atoms/cockpit-hok-tasks.mjs.
//        חוק-4 — זהה-ביט למקור-JS. עוטף hokDue הקיים; hokDue מוזרק כשקע (חוק-1/חוק-3).
//        פורמט-הכסף (_grp) inline מ-js-compat (toLocaleString).
//
// קלט: supporters (List<Map>) · todayIso · שקע hokDue(supporters, todayIso) ⇒ List<Map{hok,...}>.
//      פלט: List<Map> (משימת-hok לכל תורם-חייב).
// הערות-המרה:
//  • `hok.day` בשרשור-מחרוזת ⇒ toString. `sort: 100 - (hok.day || 0)` — day ריק/0 ⇒ 0.
//  • `amount.toLocaleString(...)` ⇒ _grp (קיבוץ-אלפים, אומת מול Node). אין מיון (map בלבד).

/// Hoq (standing-order) tasks not yet recorded this month — wraps hokDue as an action queue.
/// Verbatim port of new/atoms/cockpit-hok-tasks.mjs (money-format inlined; hokDue as socket).
List<Map<String, dynamic>> cockpitHokTasks(
  List supporters,
  String todayIso,
  List Function(List, String) hokDue,
 {required String Function(String) term}) {
  return hokDue(supporters, todayIso).map((s) {
    final sp = s as Map;
    final hok = sp['hok'] as Map;
    final money = hok['cur'] == '\$'
        ? '\$' + _grp(hok['amount'] as num)
        : '₪' + _grp(hok['amount'] as num);
    final day = hok['day'];
    final dayVal = (day == null || day == 0) ? 0 : (day as num);
    return <String, dynamic>{
      'id': 'hok:' + sp['id'].toString(),
      'kind': 'hok',
      'supId': sp['id'],
      'name': sp['name'],
      'phone': (sp['phone'] == null || sp['phone'] == '') ? '' : sp['phone'],
      'email': (sp['email'] == null || sp['email'] == '') ? '' : sp['email'],
      'reason': term('hvk') + money + term('yvm') + _dayStr(day) + term('trm-nrshm-hchvdsh'),
      'severity': 'due',
      'sort': 100 - dayVal,
    };
  }).toList();
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

// שרשור `' · יום ' + hok.day` של JS: מספר⇒מחרוזת (שלם בלי ".0").
String _dayStr(dynamic day) {
  if (day is int) return day.toString();
  if (day is double && day == day.truncateToDouble() && day.isFinite) {
    return day.toInt().toString();
  }
  return '$day';
}
