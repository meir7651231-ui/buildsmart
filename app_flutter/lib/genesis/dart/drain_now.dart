// ⚛️ אטום-Dart · drainNow — מנוע-ריקון תור-הזמנות-אופליין (FIFO · crash-safe · אפס-כפל-השמה).
// מוצא: buildsmart/app_flutter/lib/logic/offline_order_queue.dart:269-309 (‏_drainNow; חוק-4 — הקוד-החלוץ קדוש).
// הכרעה 1 (🔌 שכן⇒שקע, חוק-1/3): כל קריאות-החוץ של המקור הוזרקו כפרמטרים —
//   • loadPending      — במקור SharedPreferences.getInstance()+getString+_decode (‏:272-273).
//   • offlineSuspect   — במקור ה-getter על connectivityProbeProvider (‏:188, נבדק ב-:275).
//   • placeOrder       — במקור _ref.read(ordersRepositoryProvider).placeOrder(who…notes) (‏:276, :283-292);
//                        מיפוי-השדות (createdAt ← intent.queuedAt) = חיווט-קופסה, לא מנוע.
//   • persistRemainder — במקור prefs.setString(kOfflineOrdersKey, _encode(pending)) (‏:302).
//   • log              — במקור debugPrint (‏:296, :306).
// המנגנון verbatim: ריק⇒0 **לפני** בדיקת-אופליין (הריפו/הפרוב לא ננגעים) · אופליין⇒0
// (התור נשמר — "נשלח בחזרת-רשת") · לולאת-FIFO: כשל-השמה ⇒ log+break (הכוונה והבאות
// נשמרות — "לאבד הזמנת-לקוח גרוע מלשחזר מאוחר") · אחרי כל השמה מוצלחת — התמדת-השארית
// **מיד** (קריסה באמצע לא תשים-כפול) · כשל-עוטף ⇒ log + החזרת המונה החלקי (התור שלם).
//
// קלט:  חמשת-השקעים בלבד. פלט: מספר-הכוונות שהושמו-בהצלחה בריקון הזה.

/// ריקון תור-הכוונות, FIFO, דרך שקע-ההשמה. לעולם לא זורק (rule #1 של המקור).
Future<int> drainNow<T>({
  required Future<List<T>> Function() loadPending,
  required bool Function() offlineSuspect,
  required void Function(T intent) placeOrder,
  required Future<void> Function(List<T> remainder) persistRemainder,
  required void Function(String message) log,
}) async {
  var replayed = 0;
  try {
    var pending = await loadPending();
    if (pending.isEmpty) return 0; // common path: never touches the repo
    if (offlineSuspect()) return 0; // still offline — keep the queue
    while (pending.isNotEmpty) {
      final intent = pending.first;
      try {
        placeOrder(intent);
      } on Object catch (e) {
        // Keep this intent (and the rest) for the next drain — losing a
        // customer's order is worse than replaying late.
        log('OfflineOrderQueue: replay failed (kept queued): $e');
        break;
      }
      pending = pending.sublist(1);
      replayed++;
      // Persist the remainder NOW — a crash here cannot double-place.
      await persistRemainder(pending);
    }
    return replayed;
  } on Object catch (e) {
    log('OfflineOrderQueue: drain failed (queue intact): $e');
    return replayed;
  }
}
