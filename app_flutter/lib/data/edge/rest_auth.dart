// 🌉 מצב-מסונן · שלב A — לקוח-REST של Identity Toolkit דרך המתווך.
//
// לקוח על קו-מסונן לא יכול להשתמש ב-firebase_auth SDK (פונה ישירות ל-
// identitytoolkit.googleapis.com החסום, ואין הפניית-host). כאן: קריאות-REST
// דרך `idt.buildsmart-il.com` / `token.buildsmart-il.com` (Cloudflare Worker,
// allowlist) — הסנן רואה רק את הדומיין המאושר.
//
// טהור-כמה-שאפשר: בניית-הבקשה ומיפוי-התשובה מופרדים מהרשת (Sender מוזרק),
// כדי שהכול נבדק ביחידה בלי HTTP אמיתי. אפס תלות ב-firebase_auth/dart:html.

import 'dart:convert';

/// כתובות-הבסיס של המתווך (תת-דומיינים של הדומיין המאושר; ה-Worker מנתב
/// אותם ל-identitytoolkit/securetoken של גוגל).
const String kEdgeIdtBase = 'https://idt.buildsmart-il.com/v1';
const String kEdgeTokenBase = 'https://token.buildsmart-il.com/v1';

/// תוצאת-התחברות/הרשמה מוצלחת — הטוקנים לניהול-הסשן (שלב B).
class EdgeAuthTokens {
  const EdgeAuthTokens({
    required this.idToken,
    required this.refreshToken,
    required this.localId,
    required this.expiresInSeconds,
    required this.email,
  });

  final String idToken;
  final String refreshToken;
  final String localId;
  final int expiresInSeconds;
  final String email;
}

/// שגיאת-Auth ממופה לעברית — הודעה מוכנה-לטוסט + קוד-המקור (לבדיקות/לוג).
class EdgeAuthException implements Exception {
  const EdgeAuthException(this.hebrew, {this.code = ''});
  final String hebrew;
  final String code;
  @override
  String toString() => 'EdgeAuthException($code): $hebrew';
}

/// חוזה-שליחה מוזרק — מפריד את בניית-הבקשה מ-HTTP אמיתי (בדיקות מזריקות מדומה).
/// מחזיר את זוג (statusCode, body-כטקסט).
typedef EdgeHttpSend = Future<({int status, String body})> Function(
  Uri url,
  Map<String, String> headers,
  String body,
);

/// לקוח-REST ל-Identity Toolkit דרך המתווך. ה-apiKey הוא ה-web-key הציבורי
/// (כבר ב-bundle — אין סוד חדש).
class EdgeRestAuth {
  const EdgeRestAuth({required this.apiKey, required this.send});

  final String apiKey;
  final EdgeHttpSend send;

  /// בונה את ה-Uri לפעולת Identity-Toolkit (עם ה-key בשאילתה — כמו ה-SDK).
  Uri idtUri(String action) =>
      Uri.parse('$kEdgeIdtBase/accounts:$action?key=$apiKey');

  /// התחברות מייל+סיסמה. זורק [EdgeAuthException] בעברית על כשל.
  Future<EdgeAuthTokens> signInWithPassword(String email, String password) =>
      _passwordCall('signInWithPassword', email, password);

  /// יצירת-חשבון מייל+סיסמה. אותה תבנית, endpoint אחר.
  Future<EdgeAuthTokens> signUp(String email, String password) =>
      _passwordCall('signUp', email, password);

  Future<EdgeAuthTokens> _passwordCall(
      String action, String email, String password) async {
    final res = await send(
      idtUri(action),
      const {'Content-Type': 'application/json'},
      jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    final map = _decode(res.body);
    if (res.status != 200) throw _mapError(map);
    return _tokensFrom(map, fallbackEmail: email);
  }

  /// רענון ה-idToken דרך securetoken (לפני פקיעה — שלב B קורא לזה).
  Future<EdgeAuthTokens> refresh(String refreshToken, String email) async {
    final res = await send(
      Uri.parse('$kEdgeTokenBase/token?key=$apiKey'),
      const {'Content-Type': 'application/x-www-form-urlencoded'},
      'grant_type=refresh_token&refresh_token=$refreshToken',
    );
    final map = _decode(res.body);
    if (res.status != 200) throw _mapError(map);
    // securetoken מחזיר snake_case: id_token/refresh_token/user_id/expires_in
    return EdgeAuthTokens(
      idToken: (map['id_token'] ?? '').toString(),
      refreshToken: (map['refresh_token'] ?? refreshToken).toString(),
      localId: (map['user_id'] ?? '').toString(),
      expiresInSeconds: int.tryParse((map['expires_in'] ?? '3600').toString()) ?? 3600,
      email: email,
    );
  }

  EdgeAuthTokens _tokensFrom(Map<String, dynamic> map, {required String fallbackEmail}) {
    return EdgeAuthTokens(
      idToken: (map['idToken'] ?? '').toString(),
      refreshToken: (map['refreshToken'] ?? '').toString(),
      localId: (map['localId'] ?? '').toString(),
      expiresInSeconds: int.tryParse((map['expiresIn'] ?? '3600').toString()) ?? 3600,
      email: (map['email'] ?? fallbackEmail).toString(),
    );
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body.isEmpty ? '{}' : body);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } on Object catch (_) {
      return <String, dynamic>{};
    }
  }
}

/// מיפוי שגיאת Identity-Toolkit ל-Hebrew. הקוד יושב ב-error.message.
EdgeAuthException _mapError(Map<String, dynamic> map) {
  final error = map['error'];
  final code = (error is Map ? error['message'] : '')?.toString() ?? '';
  final base = code.split(':').first.trim(); // 'INVALID_PASSWORD : ...' ⇒ הקוד
  switch (base) {
    case 'EMAIL_NOT_FOUND':
    case 'INVALID_LOGIN_CREDENTIALS':
    case 'INVALID_PASSWORD':
      return EdgeAuthException('אימייל או סיסמה שגויים', code: base);
    case 'USER_DISABLED':
      return const EdgeAuthException('החשבון הושבת — פנו למנהל', code: 'USER_DISABLED');
    case 'EMAIL_EXISTS':
      return const EdgeAuthException('האימייל כבר רשום — נסו להתחבר', code: 'EMAIL_EXISTS');
    case 'WEAK_PASSWORD':
      return const EdgeAuthException('הסיסמה חלשה מדי — לפחות 6 תווים', code: 'WEAK_PASSWORD');
    case 'INVALID_EMAIL':
      return const EdgeAuthException('כתובת האימייל אינה תקינה', code: 'INVALID_EMAIL');
    case 'TOO_MANY_ATTEMPTS_TRY_LATER':
      return const EdgeAuthException('יותר מדי ניסיונות — נסו שוב מאוחר יותר', code: 'TOO_MANY_ATTEMPTS_TRY_LATER');
    default:
      return EdgeAuthException('ההתחברות נכשלה — נסו שוב', code: base.isEmpty ? 'UNKNOWN' : base);
  }
}
