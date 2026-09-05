// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitCalls — שיחות מומלצות = יעד-קשר-שעבר ∪ בסיכון-נטישה.
// מוצא: maor/src/components/supporters/cockpit.ts:84 + valueTag:56 (inline) + COCKPIT_SILENT_DAYS=60.
//        המקור-הקדוש: new/atoms/cockpit-calls.mjs. חוק-4 — זהה-ביט למקור-JS.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). השכנים supIls/supUsd/supLast/
//        daysSince/cockpitAtRisk מוזרקים כשקעי-פונקציה (חוק-1/חוק-3). valueTag הוטבע inline.
//
// תפקיד: כל תורם פעם-אחת (Set seen); לולאה-1 יעד-קשר שעבר (severity 'due', sort 1M+late);
//        לולאה-2 בסיכון (severity 'risk', sort=silent). ממוין לפי sort יורד.
// הערות-המרה:
//  • `sp.nextDate > todayIso` השוואת-מחרוזות ⇒ compareTo>0. ריק/חסר ⇒ מדולג (falsy).
//  • `1_000_000 + late` int (late מ-floor). `sp.phone || ''` — null/'' ⇒ ''.
//  • המיון `b.sort-a.sort` יורד, יציב (עוגן-אינדקס משני — Dart List.sort אינו יציב).

/// Recommended calls = overdue-contact ∪ at-risk (each donor once), sorted by sort desc.
/// Verbatim port of new/atoms/cockpit-calls.mjs (valueTag inlined; neighbours as sockets).
List<Map<String, dynamic>> cockpitCalls(
  List supporters,
  String todayIso,
  num rate,
  int silentDays,
  num Function(Map) supIls,
  num Function(Map) supUsd,
  String Function(Map) supLast,
  num Function(String, String) daysSince,
  List Function(List, String, int) cockpitAtRisk,
 {required String Function(String) term}) {
  String valueTag(Map sp) {
    final ils = supIls(sp) + supUsd(sp) * rate;
    if (ils >= 5000) return term('tvrmt-mrkzyt');
    if (ils >= 1000) return term('tvrmt-mhvtyt');
    return term('tvrmt');
  }

  final tasks = <Map<String, dynamic>>[];
  final seen = <Object?>{};
  for (final s in supporters) {
    final sp = s as Map;
    final nd = sp['nextDate'];
    if (nd == null || nd == '' || (nd as String).compareTo(todayIso) > 0) continue;
    final late = daysSince(nd, todayIso);
    tasks.add({
      'id': 'call:' + sp['id'].toString(),
      'kind': 'call',
      'supId': sp['id'],
      'name': sp['name'],
      'phone': (sp['phone'] == null || sp['phone'] == '') ? '' : sp['phone'],
      'email': (sp['email'] == null || sp['email'] == '') ? '' : sp['email'],
      'reason': late <= 0 ? term('yadkshr-lhyvm') : term('yadkshr-abr-lpny') + _numStr(late) + term('yvm'),
      'severity': 'due',
      'sort': 1000000 + late,
    });
    seen.add(sp['id']);
  }
  for (final s in cockpitAtRisk(supporters, todayIso, silentDays)) {
    final sp = s as Map;
    if (seen.contains(sp['id'])) continue;
    final silent = daysSince(supLast(sp), todayIso);
    tasks.add({
      'id': 'call:' + sp['id'].toString(),
      'kind': 'call',
      'supId': sp['id'],
      'name': sp['name'],
      'phone': (sp['phone'] == null || sp['phone'] == '') ? '' : sp['phone'],
      'email': (sp['email'] == null || sp['email'] == '') ? '' : sp['email'],
      'reason': valueTag(sp) + term('shkth') + _numStr(silent) + term('yvm'),
      'severity': 'risk',
      'sort': silent,
    });
    seen.add(sp['id']);
  }
  final order = List<int>.generate(tasks.length, (i) => i);
  order.sort((x, y) {
    final c = (tasks[y]['sort'] as num).compareTo(tasks[x]['sort'] as num);
    return c != 0 ? c : x.compareTo(y);
  });
  return [for (final i in order) tasks[i]];
}

// כמו `'' + n` של JS: שלם ⇒ בלי ".0" (daysSince סופי הוא int; מגן על num-double שלם-ערך).
String _numStr(num n) =>
    (n is int || (n is double && n == n.truncateToDouble() && n.isFinite))
        ? n.toInt().toString()
        : n.toString();
