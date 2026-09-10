// אטום-הצבה (placement) · התראת-דפדפן. חוצה package:web — גבול-פלטפורמה מבוקר (חוק-6).
// G55 · עד כאן `_digest` יצא מיד ב-`if (kIsWeb) return` ⇒ באתר לא הייתה שום תזכורת, אף פעם.
//   ההתראה נשלחת דרך רישום ה-service worker כשהוא קיים (מגיעה גם כשהלשונית ברקע),
//   ונופלת ל-Notification של הדף אחרת. **אפס-שרת:** אין VAPID, אין push — התראה מקומית בלבד.
//   לכן היא לא מגיעה כשהאפליקציה סגורה לגמרי; זה מוצהר, לא מוסתר (ראה דוח G55).
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// האם המשתמש כבר אישר התראות (בלי לשאול).
bool notifyGranted() {
  try {
    return web.Notification.permission == 'granted';
  } catch (_) {
    return false;
  }
}

/// האם אפשר בכלל לבקש (הדפדפן תומך והמשתמש לא חסם).
bool notifyCanAsk() {
  try {
    return web.Notification.permission == 'default';
  } catch (_) {
    return false;
  }
}

/// בקשת-רשות — נקראת רק מתוך מחווה של המשתמש (הדפדפנים דוחים בקשה בטעינה).
Future<bool> notifyAsk() async {
  try {
    if (notifyGranted()) return true;
    final r = await web.Notification.requestPermission().toDart;
    return r.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

/// הצגה. `tag` מונע כפילות של אותה תזכורת בין רענונים.
Future<bool> notifyShow(String title, String body, String tag) async {
  try {
    if (!notifyGranted()) return false;
    final opts = web.NotificationOptions(body: body, tag: tag);
    final sw = web.window.navigator.serviceWorker;
    final reg = await sw.ready.toDart;
    await reg.showNotification(title, opts).toDart;
    return true;
  } catch (_) {
    try {
      web.Notification(title, web.NotificationOptions(body: body, tag: tag));
      return true;
    } catch (_) {
      return false;
    }
  }
}
