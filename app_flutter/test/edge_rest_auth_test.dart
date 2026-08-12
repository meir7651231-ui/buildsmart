// ratchet — מצב-מסונן שלב A: לקוח-REST של Auth דרך המתווך.
//
// אינווריאנטים:
// 1. הקריאות פונות לתת-הדומיינים של המתווך (idt./token.buildsmart-il.com) —
//    לעולם לא ל-googleapis ישירות (זה כל הרעיון).
// 2. הצלחה ⇒ EdgeAuthTokens עם idToken/refreshToken/localId/expiresIn.
// 3. כל קוד-שגיאה של Identity-Toolkit ⇒ הודעה עברית ממופה (לא crash).
// 4. הכול נבדק בלי רשת (Sender מוזרק).
import 'dart:convert';
import 'package:buildsmart/data/edge/rest_auth.dart';
import 'package:flutter_test/flutter_test.dart';

EdgeHttpSend _fake({required int status, required Map<String, dynamic> body, List<Uri>? capture}) {
  return (Uri url, Map<String, String> headers, String reqBody) async {
    capture?.add(url);
    return (status: status, body: jsonEncode(body));
  };
}

void main() {
  const apiKey = 'AIza-test';

  test('signInWithPassword פונה למתווך (idt.), לא ל-googleapis', () async {
    final urls = <Uri>[];
    final auth = EdgeRestAuth(
      apiKey: apiKey,
      send: _fake(status: 200, capture: urls, body: {
        'idToken': 'ID', 'refreshToken': 'RE', 'localId': 'UID',
        'expiresIn': '3600', 'email': 'a@b.com',
      }),
    );
    final t = await auth.signInWithPassword('a@b.com', 'pw123456');
    expect(t.idToken, 'ID');
    expect(t.refreshToken, 'RE');
    expect(t.localId, 'UID');
    expect(t.expiresInSeconds, 3600);
    // הכתובת = תת-הדומיין המאושר, לא גוגל
    expect(urls.single.host, 'idt.buildsmart-il.com');
    expect(urls.single.toString(), contains('accounts:signInWithPassword'));
    expect(urls.single.toString(), isNot(contains('googleapis')));
  });

  test('refresh פונה ל-token.buildsmart-il.com וממפה snake_case', () async {
    final urls = <Uri>[];
    final auth = EdgeRestAuth(
      apiKey: apiKey,
      send: _fake(status: 200, capture: urls, body: {
        'id_token': 'NEWID', 'refresh_token': 'NEWRE', 'user_id': 'UID', 'expires_in': '3600',
      }),
    );
    final t = await auth.refresh('OLDRE', 'a@b.com');
    expect(t.idToken, 'NEWID');
    expect(t.refreshToken, 'NEWRE');
    expect(urls.single.host, 'token.buildsmart-il.com');
  });

  test('כל קוד-שגיאה ⇒ הודעה עברית ממופה', () async {
    Future<String> hebrewFor(String code) async {
      final auth = EdgeRestAuth(
        apiKey: apiKey,
        send: _fake(status: 400, body: {'error': {'message': code}}),
      );
      try {
        await auth.signInWithPassword('a@b.com', 'x');
        return 'NO-THROW';
      } on EdgeAuthException catch (e) {
        return e.hebrew;
      }
    }

    expect(await hebrewFor('INVALID_PASSWORD'), 'אימייל או סיסמה שגויים');
    expect(await hebrewFor('EMAIL_NOT_FOUND'), 'אימייל או סיסמה שגויים');
    expect(await hebrewFor('EMAIL_EXISTS'), contains('כבר רשום'));
    expect(await hebrewFor('WEAK_PASSWORD'), contains('חלשה'));
    expect(await hebrewFor('INVALID_EMAIL'), contains('אינה תקינה'));
    expect(await hebrewFor('SOMETHING_NEW'), contains('נכשלה')); // ברירת-מחדל, לא crash
  });

  test('גוף-JSON כולל returnSecureToken', () async {
    String? sentBody;
    final auth = EdgeRestAuth(
      apiKey: apiKey,
      send: (url, headers, body) async {
        sentBody = body;
        return (status: 200, body: jsonEncode({'idToken': 'ID', 'refreshToken': 'RE', 'localId': 'U', 'expiresIn': '3600'}));
      },
    );
    await auth.signInWithPassword('a@b.com', 'pw');
    final decoded = jsonDecode(sentBody!) as Map<String, dynamic>;
    expect(decoded['returnSecureToken'], isTrue);
  });
}
