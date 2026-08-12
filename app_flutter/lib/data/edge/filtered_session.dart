// 🌉 מצב-מסונן · שלב B — ניהול-סשן ל-Auth-REST.
//
// מחזיק את הטוקנים שהתקבלו מ-EdgeRestAuth, מרענן את ה-idToken לפני פקיעה,
// מתמיד אותם באחסון-מפתח-ערך (localStorage בפרוד; מפה-בזיכרון בבדיקות),
// ומנקה ב-signOut. טהור — האחסון והשעון מוזרקים, אפס dart:html / רשת.

import 'dart:convert';

import 'package:buildsmart/data/edge/rest_auth.dart';

/// אחסון-מפתח-ערך מוזרק (בפרוד: עטיפת localStorage; בבדיקות: מפה).
abstract class EdgeKvStore {
  String? read(String key);
  void write(String key, String value);
  void remove(String key);
}

/// מפתח-האחסון של הסשן (פר-מקור — כמו ה-SDK עצמו).
const String kFilteredSessionKey = 'bs_filtered_session_v1';

/// סף-רענון: מרעננים כשנותרו פחות מזה עד הפקיעה (שוליים לשעונים/רשת).
const Duration kRefreshSkew = Duration(minutes: 5);

/// סשן מצב-מסונן חי — טוקנים + זמן-פקיעה מוחלט.
class FilteredSession {
  FilteredSession({
    required EdgeRestAuth auth,
    required EdgeKvStore store,
    required DateTime Function() now,
  })  : _auth = auth,
        _store = store,
        _now = now;

  final EdgeRestAuth _auth;
  final EdgeKvStore _store;
  final DateTime Function() _now;

  String? _idToken;
  String? _refreshToken;
  String? _localId;
  String? _email;
  DateTime? _expiresAt;

  bool get isSignedIn => (_idToken ?? '').isNotEmpty && (_localId ?? '').isNotEmpty;
  String? get localId => _localId;
  String? get email => _email;

  /// קליטת-טוקנים אחרי login/signup — מחשב זמן-פקיעה מוחלט ומתמיד.
  void adopt(EdgeAuthTokens t) {
    _idToken = t.idToken;
    _refreshToken = t.refreshToken;
    _localId = t.localId;
    _email = t.email;
    _expiresAt = _now().add(Duration(seconds: t.expiresInSeconds));
    _persist();
  }

  /// ה-idToken התקף — מרענן אוטומטית אם קרוב לפקיעה. null אם אין סשן.
  Future<String?> validIdToken() async {
    if (!isSignedIn) return null;
    final exp = _expiresAt;
    if (exp != null && _now().isBefore(exp.subtract(kRefreshSkew))) {
      return _idToken; // עדיין תקף
    }
    // רענון דרך securetoken (המתווך). כשל ⇒ הסשן נגמר (ניקוי).
    try {
      final t = await _auth.refresh(_refreshToken ?? '', _email ?? '');
      if (t.idToken.isEmpty) {
        clear();
        return null;
      }
      adopt(t);
      return _idToken;
    } on Object {
      clear();
      return null;
    }
  }

  /// ניקוי הסשן (signOut / רענון-שנכשל).
  void clear() {
    _idToken = _refreshToken = _localId = _email = null;
    _expiresAt = null;
    _store.remove(kFilteredSessionKey);
  }

  /// שחזור מהאחסון בהפעלה (חוזר true אם נטען סשן; לא מאמת — validIdToken כן).
  bool restore() {
    final raw = _store.read(kFilteredSessionKey);
    if (raw == null || raw.isEmpty) return false;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      _idToken = (m['idToken'] ?? '').toString();
      _refreshToken = (m['refreshToken'] ?? '').toString();
      _localId = (m['localId'] ?? '').toString();
      _email = (m['email'] ?? '').toString();
      final expMs = int.tryParse((m['expiresAtMs'] ?? '0').toString()) ?? 0;
      _expiresAt = expMs > 0 ? DateTime.fromMillisecondsSinceEpoch(expMs) : null;
      return isSignedIn;
    } on Object {
      clear();
      return false;
    }
  }

  void _persist() {
    _store.write(
      kFilteredSessionKey,
      jsonEncode({
        'idToken': _idToken,
        'refreshToken': _refreshToken,
        'localId': _localId,
        'email': _email,
        'expiresAtMs': _expiresAt?.millisecondsSinceEpoch ?? 0,
      }),
    );
  }
}
