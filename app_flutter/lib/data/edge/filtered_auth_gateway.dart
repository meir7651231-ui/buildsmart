// 🌉 מצב-מסונן · שלב C — AuthGateway פר-מצב-מסונן.
//
// מממש את חוזה [AuthGateway] מעל [EdgeRestAuth]+[FilteredSession] — כך שכל
// זרימות-ההתחברות של האפליקציה עובדות מבלי לגעת ב-firebase_auth (החסום בקו-
// מסונן). מייל+סיסמה בלבד; גוגל/SMS זורקים 'unavailable' (מוסתרים ב-UI, שלב E).
//
// טהור — אפס firebase/רשת ישירה; הכול דרך התפרים המוזרקים (Auth-REST + סשן).

import 'dart:async';

import 'package:buildsmart/data/edge/filtered_session.dart';
import 'package:buildsmart/data/edge/rest_auth.dart';
import 'package:buildsmart/state/auth_state.dart';

/// גשר-ה-Auth של מצב-מסונן. מוחלף בשורש-הספק כשמצב-מסונן דלוק (שלב E),
/// בדיוק כמו ההחלפה הקיימת Firebase-vs-local.
class FilteredAuthGateway implements AuthGateway {
  FilteredAuthGateway({required EdgeRestAuth auth, required FilteredSession session})
      : _auth = auth,
        _session = session {
    // שחזור סשן קיים בהפעלה ⇒ המשתמש נשאר מחובר בין ריצות.
    _session.restore();
    _emit();
  }

  final EdgeRestAuth _auth;
  final FilteredSession _session;

  // מזרים AuthUser? כמו firebase_auth: הערך הנוכחי לכל מאזין-חדש, ואז שינויים.
  final _controller = StreamController<AuthUser?>.broadcast();

  AuthUser? _userNow() => _session.isSignedIn
      ? AuthUser(uid: _session.localId!, email: _session.email)
      : null;

  void _emit() => _controller.add(_userNow());

  @override
  Stream<AuthUser?> authStateChanges() {
    // חוזה ה-SDK: הערך-הנוכחי מיידית ואז שינויים. לא async*/yield* — שם
    // המנוי ל-broadcast נרשם רק אחרי צריכת ה-yield הראשון, ואירוע-כניסה
    // שנפלט לפני-כן (broadcast לא מאגר) נבלע. במקום: מנוי נרשם ב-onListen
    // (סינכרוני, לפני כל _emit של פעולה), כך שאף אירוע לא אובד.
    late final StreamController<AuthUser?> ctrl;
    StreamSubscription<AuthUser?>? src;
    ctrl = StreamController<AuthUser?>(
      onListen: () {
        ctrl.add(_userNow()); // מצב-נוכחי
        src = _controller.stream.listen(ctrl.add, onError: ctrl.addError);
      },
      onCancel: () => src?.cancel(),
    );
    return ctrl.stream;
  }

  @override
  AuthUser? get currentUser => _userNow();

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    await _run(() => _auth.signInWithPassword(email, password));
  }

  @override
  Future<void> createUserWithEmailPassword(String email, String password) async {
    await _run(() => _auth.signUp(email, password));
  }

  Future<void> _run(Future<EdgeAuthTokens> Function() op) async {
    try {
      _session.adopt(await op());
      _emit();
    } on EdgeAuthException catch (e) {
      throw AuthGatewayException(e.code.isEmpty ? 'unavailable' : e.code, e.hebrew);
    }
  }

  @override
  Future<void> signOut() async {
    _session.clear();
    _emit();
  }

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async {
    // מצב-מסונן: אין קריאת-claims (הרול נאכף ע"י Rules על ה-idToken). ריק.
    return <String, dynamic>{};
  }

  @override
  Future<void> resetPassword(String email) async {
    // שליחת מייל-איפוס דרך המתווך (Identity-Toolkit sendOobCode) — שלב עתידי;
    // כרגע no-throw (אין enumeration), כמו חוזה ה-SDK לאימייל-לא-קיים.
  }

  // ── לא-זמין במצב-מסונן (גוגל/SMS נוגעים בכמה דומייני-גוגל) ──
  @override
  Future<String> sendOtp(String phone) async =>
      throw const AuthGatewayException('unavailable', 'SMS unavailable in filtered mode');

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async =>
      throw const AuthGatewayException('unavailable', 'SMS unavailable in filtered mode');

  @override
  Future<AuthUser?> signInWithGoogle() async =>
      throw const AuthGatewayException('unavailable', 'Google unavailable in filtered mode');

  @override
  Future<void> deleteAccount() async =>
      throw const AuthGatewayException('unavailable', 'account deletion not in filtered mode');

  @override
  Future<void> setRole({required String uid, required String role}) async =>
      throw const AuthGatewayException('unavailable', 'setRole not in filtered mode');

  /// ה-idToken התקף לשכבת-הנתונים (שלב D — Firestore-REST מצרף אותו).
  Future<String?> validIdToken() => _session.validIdToken();

  void dispose() => _controller.close();
}
