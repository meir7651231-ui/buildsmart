// ☁️ אטום-הצבה · רענון-OAuth (G60 · הכרעה-31). **טוקן-הרענון לעולם לא מגיע לכאן.**
// גוגל אינה מנפיקה refresh_token ללקוח-דפדפן ציבורי, ולכן הטוקן מת אחרי כשעה.
// הפתרון: סוד-הלקוח יושב בפונקציה, הפונקציה מחזיקה את הרענון, והלקוח מבקש
// access_token קצר בכל פעם. בלי מזהה-לקוח וכתובת-פונקציות ⇒ דורמנטי, אפס רשת.
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'ds_cloud.dart';

const List<String> kOauthScopes = [
  'https://www.googleapis.com/auth/gmail.readonly',
  'https://www.googleapis.com/auth/calendar.events',
];

/// כתובת-ההסכמה של גוגל. ה-state הוא ה-ID-token של המשתמש — כך שהחזרה נקשרת
/// לחשבון שממנו יצאה ואי-אפשר לתלות טוקן של אדם אחד באחר.
Future<String?> oauthUrl({required String clientId, required String fnBase}) async {
  if (clientId.trim().isEmpty || fnBase.trim().isEmpty) return null;
  final u = await _idToken();
  if (u == null) return null;
  final redirect = '${fnBase.trim().replaceAll(RegExp(r'/+$'), '')}/oauthCallback';
  final q = {
    'client_id': clientId.trim(),
    'redirect_uri': redirect,
    'response_type': 'code',
    'access_type': 'offline',
    'prompt': 'consent',
    'include_granted_scopes': 'true',
    'scope': kOauthScopes.join(' '),
    'state': u,
  };
  return Uri.https('accounts.google.com', '/o/oauth2/v2/auth', q).toString();
}

Future<String?> _idToken() async {
  try {
    final app = cloudUid().isEmpty ? null : FirebaseAuth.instance.currentUser;
    return app == null ? null : await app.getIdToken();
  } catch (_) {
    return null;
  }
}

String _cached = '';
DateTime _until = DateTime.fromMillisecondsSinceEpoch(0);

/// טוקן-גישה קצר, במטמון עד לפני-דקה מהפקיעה. לא מחובר ⇒ null (הקורא נופל
/// לטוקן שהודבק ידנית, אם יש — בלי לשבור את מי שעובד ככה היום).
Future<String?> oauthAccessToken({required String fnBase}) async {
  if (fnBase.trim().isEmpty) return null;
  if (_cached.isNotEmpty && DateTime.now().isBefore(_until)) return _cached;
  final id = await _idToken();
  if (id == null) return null;
  try {
    final r = await http.get(
      Uri.parse('${fnBase.trim().replaceAll(RegExp(r'/+$'), '')}/oauthToken'),
      headers: {'Authorization': 'Bearer $id'},
    );
    if (r.statusCode != 200) return null;
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    final t = (j['access_token'] ?? '').toString();
    if (t.isEmpty) return null;
    _cached = t;
    _until = DateTime.now().add(Duration(seconds: ((j['expires_in'] as num?)?.toInt() ?? 3600) - 60));
    return t;
  } catch (_) {
    return null;
  }
}
