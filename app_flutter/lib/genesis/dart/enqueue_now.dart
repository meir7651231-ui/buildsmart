// ⚛️ אטום-Dart · enqueueNow — צירוף-מוגן של פריט לתור-מתמיד (append-then-persist, לעולם-לא-זורק).
// מוצא: buildsmart/app_flutter/lib/logic/offline_order_queue.dart:229-237
//   (‏OfflineOrderQueue._enqueueNow, ענף claude/whats-happening-LyY9G — האתר-החי; חוק-4).
// הכרעת-קידום 🔌 (חוק-1/3): כל קריאות-החוץ הוזרקו כשקעים —
//   • `getInstance` — במקור SharedPreferences.getInstance() (‏:231).
//   • `getString`/`setString` — קריאה/כתיבה במפתח (‏:232-233; setString של פריפס
//     מחזיר Future<bool> — נכנס לשקע Future<void> כרגיל).
//   • `decode`/`encode` — השכנים-הפרטיים _decode/_encode (‏:313-336) — שקעי-קודק.
//   • `key` — קונפיג-הצבה (במקור kOfflineOrdersKey='bs.offline-orders.v1', ‏:80; חוק-6).
//   • `log` — במקור debugPrint (‏:235).
// הטיפוס OfflineOrderIntent לא הוטבע: האטום רק מצרף לרשימה ⇒ גנרי <T>; מזהה-הפריפס <P>.
//
// התנהגות (זהה-ביט למקור בחיווט שקעי-המקור):
//   decode(הגולמי-כולל-null) ⇒ ..add(intent) לסוף (FIFO) ⇒ setString(encode(...)).
//   מוגן-מוחלט (rule #1 של המקור): כל כשל ⇒ log verbatim
//   'OfflineOrderQueue: enqueue failed (ignored): $e' — לעולם לא זורק.
//
// קלט:  intent · getInstance · getString · setString · decode · encode · key · log.
// פלט:  Future<void> (תופעת-לוואי: כתיבה אחת ב-key, או log-כשל יחיד).

Future<void> enqueueNow<T, P>(
  T intent, {
  required Future<P> Function() getInstance,
  required String? Function(P prefs, String key) getString,
  required Future<void> Function(P prefs, String key, String value) setString,
  required List<T> Function(String? raw) decode,
  required String Function(List<T> pending) encode,
  required String key,
  required void Function(String message) log,
}) async {
  try {
    final prefs = await getInstance();
    final pending = decode(getString(prefs, key))..add(intent);
    await setString(prefs, key, encode(pending));
  } on Object catch (e) {
    log('OfflineOrderQueue: enqueue failed (ignored): $e');
  }
}
