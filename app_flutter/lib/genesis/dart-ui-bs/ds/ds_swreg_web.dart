// אטום-הצבה · רישום מקלט-הדחיפה בדפדפן (G59). הקונפיג מגיע ב-query כי הבעלים מדביק
// אותו בזמן-ריצה; scope ייעודי כדי לא להתנגש ב-service worker של Flutter (G52).
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<bool> registerPushSw(Map<String, String> cfg) async {
  try {
    if (cfg['apiKey'] == null || cfg['projectId'] == null || cfg['appId'] == null) return false;
    final q = cfg.entries.where((e) => e.value.trim().isNotEmpty).map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    await web.window.navigator.serviceWorker
        .register('firebase-messaging-sw.js?$q'.toJS, web.RegistrationOptions(scope: 'firebase-cloud-messaging-push-scope'))
        .toDart;
    return true;
  } catch (_) {
    return false;
  }
}
