/// חוט · contact-to-row — כרטיס-vCard מפורסר ⇒ שורת-ייבוא ניטרלית.
/// המרה נאמנה מ-new/atoms/contact-to-row.mjs (חוק-4: המקור קדוש).
/// אפס import (dart-core בלבד). מייל/מזהה = דאטה נכנסת, לא סוד — אין הצבה.
///
/// כלל-דם #7 (truthiness): JS `c.org ?` / `filter(Boolean)` שומרים רק ערכים
/// truthy — מחרוזת לא-ריקה. Dart `if(x)` דורש bool, ולכן `_truthy` מפורש:
/// מחרוזת ⇒ לא-ריקה · אחר ⇒ != null (null≡undefined בהיעדר-מפתח). וכן
/// `x ?.value || ''` של JS = ערך-truthy-או-ריק, לא null-coalesce.
bool _truthy(dynamic v) => v is String ? v.isNotEmpty : v != null;

String _orEmpty(dynamic v) => _truthy(v) ? v as String : '';

Map<String, String> contactToRow(Map<String, dynamic> c) {
  final org = c['org'];
  final orgPart = _truthy(org) ? '🏢 ' + (org as String) : '';
  // [org?, title, note].filter(Boolean).join(' · ')
  final notes = [orgPart, c['title'], c['note']]
      .where(_truthy)
      .map((p) => p as String)
      .join(' · ');

  final phones = (c['phones'] as List);
  final emails = (c['emails'] as List);

  return {
    'name': (c['fullName'] as String).trim(),
    'phone': phones.isNotEmpty ? _orEmpty((phones[0] as Map)['value']) : '',
    'phone2': phones.length > 1 ? _orEmpty((phones[1] as Map)['value']) : '',
    'email': emails.isNotEmpty ? _orEmpty(emails[0]) : '',
    'address': c['address'] as String,
    'notes': notes,
  };
}
