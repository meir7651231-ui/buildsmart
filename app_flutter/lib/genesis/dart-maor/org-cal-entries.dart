/// חוט · org-cal-entries — שורות לוח-התרומות הכלל-ארגוני (legacy supCalAll).
/// חוזה: org-cal-entries.contract.md · שקעים: supDonEvents (אירועי-התרומה של תומכת).
/// פורט זהה-התנהגות מ-new/atoms/org-cal-entries.mjs (חוק-4 — המקור קדוש).
///
/// מודל-נתונים: אובייקטי-JS ⇒ Map<String, dynamic> (מפתח-חסר = undefined = null).
/// supDonEvents = שקע: פונקציה sp ⇒ רשימת אירועי-תרומה.

// truthiness של JS: undefined/null/''/0/false/NaN = falsy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

List<Map<String, dynamic>> orgCalEntries(
  List<Map<String, dynamic>> supporters,
  List<Map<String, dynamic>> Function(Map<String, dynamic>) supDonEvents,
) {
  final out = <Map<String, dynamic>>[];
  for (final sp in supporters) {
    for (final e in supDonEvents(sp)) {
      out.add({
        'date': e['date'],
        'amount': e['amount'],
        'cur': e['cur'],
        'src': e['src'],
        'name': sp['name'],
        'spId': sp['id'],
      });
    }
    final ayin = sp['ayin'] as Map<String, dynamic>?;
    for (final l in (ayin?['log'] as List<dynamic>? ?? const [])) {
      final lm = l as Map<String, dynamic>;
      out.add({
        'date': lm['date'],
        'amount': 0,
        'cur': '',
        'src': '🧿 ' +
            (lm['eyes'] as String) +
            (_truthy(lm['name']) ? ' — ' + (lm['name'] as String) : ''),
        'name': sp['name'],
        'spId': sp['id'],
      });
    }
    for (final an in (ayin?['answers'] as List<dynamic>? ?? const [])) {
      final am = an as Map<String, dynamic>;
      out.add({
        'date': am['date'],
        'amount': 0,
        'cur': '',
        'src': '📞 תשובה: ' + (am['note'] as String),
        'name': sp['name'],
        'spId': sp['id'],
      });
    }
    if (_truthy(ayin?['nextTalk'])) {
      out.add({
        'date': ayin!['nextTalk'],
        'amount': 0,
        'cur': '',
        'src': '🔁 לדבר שוב',
        'name': sp['name'],
        'spId': sp['id'],
      });
    }
  }
  return out.where((e) => _truthy(e['date'])).toList();
}
