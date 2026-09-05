// חוט · delivery-list-lines — שורות תדפיס יום-חלוקה מקובצות פר-מתנדב.
// חוזה: delivery-list-lines.contract.md · שקע: statusLabel
// המרת-Dart מ-new/atoms/delivery-list-lines.mjs (חוק-4: התנהגות זהה למקור-JS).
// אפס import (dart-core בלבד). Map של Dart = insertion-order ⇒ סדר-הופעה-ראשונה.

List<String> deliveryListLines(
  List<Map<String, dynamic>> rows,
  String Function(dynamic status) statusLabel,
 {required String Function(String) term}) {
  final byVol = <dynamic, List<Map<String, dynamic>>>{};
  for (final r in rows) {
    final arr = byVol[r['volunteerName']] ?? <Map<String, dynamic>>[];
    arr.add(r);
    byVol[r['volunteerName']] = arr;
  }
  final out = <String>[];
  byVol.forEach((volName, list) {
    out.add('🦺 $volName (${list.length}${term('msyrvt')}');
    for (final r in list) {
      // truthiness של JS: מחרוזת ריקה/null = falsy ⇒ אין שרשור (כלל-7).
      final address = r['address'];
      final note = r['note'];
      out.add('  • ${r['familyName']} · ${statusLabel(r['status'])}' +
          (_truthy(address) ? ' · 📍 ' + address.toString() : '') +
          (_truthy(note) ? ' · ' + note.toString() : ''));
    }
  });
  return out;
}

bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is String) return v.isNotEmpty;
  if (v is bool) return v;
  return true;
}
