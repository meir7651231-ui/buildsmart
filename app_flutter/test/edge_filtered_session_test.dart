// ratchet — מצב-מסונן שלבים B+C: סשן + AuthGateway דרך המתווך.
import 'dart:convert';
import 'package:buildsmart/data/edge/filtered_auth_gateway.dart';
import 'package:buildsmart/data/edge/filtered_session.dart';
import 'package:buildsmart/data/edge/rest_auth.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemStore implements EdgeKvStore {
  final Map<String, String> m = {};
  @override
  String? read(String key) => m[key];
  @override
  void write(String key, String value) => m[key] = value;
  @override
  void remove(String key) => m.remove(key);
}

EdgeRestAuth _authThatReturns({
  Map<String, dynamic>? signIn,
  Map<String, dynamic>? refresh,
  Map<String, dynamic>? error,
}) {
  return EdgeRestAuth(
    apiKey: 'k',
    send: (url, headers, body) async {
      if (error != null) return (status: 400, body: jsonEncode(error));
      final isRefresh = url.host == 'token.buildsmart-il.com';
      return (status: 200, body: jsonEncode(isRefresh ? refresh : signIn));
    },
  );
}

void main() {
  final t0 = DateTime(2026, 8, 12, 12);

  group('שלב B — FilteredSession', () {
    test('adopt + validIdToken כשעדיין תקף ⇒ בלי רענון', () async {
      final s = FilteredSession(
        auth: _authThatReturns(),
        store: _MemStore(),
        now: () => t0,
      )..adopt(const EdgeAuthTokens(idToken: 'ID', refreshToken: 'RE', localId: 'U', expiresInSeconds: 3600, email: 'a@b.com'));
      expect(s.isSignedIn, isTrue);
      expect(await s.validIdToken(), 'ID'); // בתוך התוקף
    });

    test('קרוב-לפקיעה ⇒ רענון אוטומטי דרך token.', () async {
      var now = t0;
      final s = FilteredSession(
        auth: _authThatReturns(refresh: {'id_token': 'ID2', 'refresh_token': 'RE2', 'user_id': 'U', 'expires_in': '3600'}),
        store: _MemStore(),
        now: () => now,
      )..adopt(const EdgeAuthTokens(idToken: 'ID', refreshToken: 'RE', localId: 'U', expiresInSeconds: 3600, email: 'a@b.com'));
      now = t0.add(const Duration(minutes: 58)); // נותרו <5 דק'
      expect(await s.validIdToken(), 'ID2'); // רוענן
    });

    test('רענון-שנכשל ⇒ ניקוי הסשן', () async {
      var now = t0;
      final s = FilteredSession(
        auth: _authThatReturns(error: {'error': {'message': 'TOKEN_EXPIRED'}}),
        store: _MemStore(),
        now: () => now,
      )..adopt(const EdgeAuthTokens(idToken: 'ID', refreshToken: 'RE', localId: 'U', expiresInSeconds: 3600, email: 'a@b.com'));
      now = t0.add(const Duration(minutes: 58));
      expect(await s.validIdToken(), isNull);
      expect(s.isSignedIn, isFalse);
    });

    test('persist+restore ⇒ המשתמש נשאר מחובר בין ריצות', () {
      final store = _MemStore();
      FilteredSession(auth: _authThatReturns(), store: store, now: () => t0)
          .adopt(const EdgeAuthTokens(idToken: 'ID', refreshToken: 'RE', localId: 'U', expiresInSeconds: 3600, email: 'a@b.com'));
      final s2 = FilteredSession(auth: _authThatReturns(), store: store, now: () => t0);
      expect(s2.restore(), isTrue);
      expect(s2.localId, 'U');
    });
  });

  group('שלב C — FilteredAuthGateway', () {
    FilteredAuthGateway gw({Map<String, dynamic>? signIn, Map<String, dynamic>? error}) {
      final auth = _authThatReturns(signIn: signIn, error: error);
      final session = FilteredSession(auth: auth, store: _MemStore(), now: () => t0);
      return FilteredAuthGateway(auth: auth, session: session);
    }

    test('signInWithEmailPassword ⇒ currentUser + אירוע ב-authStateChanges', () async {
      final g = gw(signIn: {'idToken': 'ID', 'refreshToken': 'RE', 'localId': 'U', 'expiresIn': '3600', 'email': 'a@b.com'});
      expect(g.currentUser, isNull);
      final seen = <AuthUser?>[];
      final sub = g.authStateChanges().listen(seen.add);
      await g.signInWithEmailPassword('a@b.com', 'pw');
      await Future<void>.delayed(Duration.zero);
      expect(g.currentUser?.uid, 'U');
      expect(g.currentUser?.email, 'a@b.com');
      expect(seen.last?.uid, 'U');
      await sub.cancel();
      g.dispose();
    });

    test('שגיאת-Auth ⇒ AuthGatewayException עם קוד-המקור', () async {
      final g = gw(error: {'error': {'message': 'INVALID_PASSWORD'}});
      expect(
        () => g.signInWithEmailPassword('a@b.com', 'x'),
        throwsA(isA<AuthGatewayException>().having((e) => e.code, 'code', 'INVALID_PASSWORD')),
      );
      g.dispose();
    });

    test('signOut ⇒ currentUser=null', () async {
      final g = gw(signIn: {'idToken': 'ID', 'refreshToken': 'RE', 'localId': 'U', 'expiresIn': '3600', 'email': 'a@b.com'});
      await g.signInWithEmailPassword('a@b.com', 'pw');
      await g.signOut();
      expect(g.currentUser, isNull);
      g.dispose();
    });

    test('גוגל/SMS ⇒ unavailable (לא-זמין במצב-מסונן)', () async {
      final g = gw();
      expect(g.signInWithGoogle, throwsA(isA<AuthGatewayException>().having((e) => e.code, 'code', 'unavailable')));
      expect(() => g.sendOtp('+972500000000'), throwsA(isA<AuthGatewayException>()));
      g.dispose();
    });
  });
}
