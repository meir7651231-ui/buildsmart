/// חוט · enroll-summary — סיכום-עבר פר-שיבוץ (רישום-לשנה-הבאה).
/// המרה נאמנה מ-new/atoms/enroll-summary.mjs (חוק-4: המקור קדוש).
/// STATUS_LABEL היה קבוע פרטי באותו קובץ — נבלע לחוט; payBal/paidOf שקעים (חוק-1).
/// אפס import (dart-core בלבד).


/// שקע-truthiness (DART-PORTING-RULES כלל 7): JS falsy = false/0/''/null/NaN.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    v == 0 ||
    v == '' ||
    (v is double && v.isNaN);

Map<String, dynamic> enrollSummary(Map<String, dynamic> e,
  dynamic Function(Map<String, dynamic>) payBal,
  dynamic Function(Map<String, dynamic>) paidOf, Map<String, String> T) {
  final _statusLabel = {
  'active': T['k1']!,
  'paused': T['k2']!,
  'ended': T['k3']!,
  'wait': T['k4']!,
};
  final presentsList = (e['presents'] ?? const []) as List;
  final absencesList = (e['absences'] ?? const []) as List;
  final presents = presentsList.length;
  final absences = absencesList.length;
  final noshow = absencesList.where((a) => !_falsy(a['noshow'])).length;
  // (e.presents ?? []).slice().sort().slice(-1)[0] ?? ''
  // מיון לקסיקוגרפי על עותק; ריק ⇒ '' (שקע-האחרון). מחרוזות-ISO ⇒ הכרונולוגי-אחרון.
  final sorted = List.from(presentsList)..sort();
  final lastPresent = sorted.isEmpty ? '' : sorted.last;
  return {
    'presents': presents,
    'absences': absences,
    'noshow': noshow,
    'balance': payBal(e),
    'paid': paidOf(e),
    'statusLabel': _statusLabel[e['status']] ?? '',
    'lastPresent': lastPresent,
  };
}
