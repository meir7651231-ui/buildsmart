// ☁️ אטום-הצבה · דחיפה (G59 · הכרעה-31). **דורמנטי-מלידה:** בלי קונפיג-ענן ובלי מפתח-VAPID
// אין רישום, אין טוקן, אין בקשה. הטוקן נשמר תחת המשתמש (`users/{uid}/push/{token}`) —
// השרת שולח אליו כשהאפליקציה סגורה; הוא מזהה מכשיר, לא אדם.
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'ds_cloud.dart';
import 'ds_swreg_stub.dart' if (dart.library.js_interop) 'ds_swreg_web.dart';

/// טוקן-המכשיר. חסר קונפיג/VAPID/רשות ⇒ null (המסך אומר, לא מזייף).
Future<String?> pushToken(String rawConfig, String vapidKey) async {
  final app = await cloudInit(rawConfig);
  if (app == null) return null;
  try {
    final j = jsonDecode(rawConfig) as Map<String, dynamic>;
    final cfg = {for (final k in ['apiKey', 'projectId', 'appId', 'messagingSenderId', 'authDomain']) k: (j[k] ?? '').toString()};
    if (!await registerPushSw(cfg)) return null;
    final m = FirebaseMessaging.instance;   // firebase_messaging חושף רק את אפליקציית-ברירת-המחדל
    final perm = await m.requestPermission();
    if (perm.authorizationStatus != AuthorizationStatus.authorized && perm.authorizationStatus != AuthorizationStatus.provisional) return null;
    return await m.getToken(vapidKey: vapidKey.trim().isEmpty ? null : vapidKey.trim());
  } catch (_) {
    return null;
  }
}
