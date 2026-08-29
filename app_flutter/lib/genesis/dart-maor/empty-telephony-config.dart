// חוט · empty-telephony-config — קודם אוטומטית (צילום-גטר). המר מ-JS (המקור קדוש).
// אפס import (dart-core בלבד). התנהגות זהה-ביט למקור-ה-JS.
Map<String, dynamic> emptyTelephonyConfig({required String Function(String) term}) {
  return <String, dynamic>{
    'numbers': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'n1', 'e164': '', 'label': term('kv-rashy'), 'kind': 'sim'},
    ],
    'officeDays': <int>[0, 1, 2, 3, 4],
    'officeStart': '09:00',
    'officeEnd': '17:00',
    'officeExt': '101',
    'managerExt': '201',
    'vmBox': '100',
    'city': '',
    'kosherMode': false,
    'hebrewCalendar': true,
    'zmanim': false,
    'shabbat': true,
    'fasts': false,
    'voicemail': true,
  };
}
