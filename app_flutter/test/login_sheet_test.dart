// S1 WIDGET coverage — the Hebrew login sheet (S1.1–S1.3), the S1.6 role-picker
// gate, and the profile-screen auth surfaces (S1.7 logout / S1.8 deletion).
//
// Same seam discipline as auth_state_test.dart: a hand-rolled [_FakeAuthGateway]
// drives everything, Firebase is never touched, and the Firebase-free baseline
// (gateway = null) is pinned to render byte-identical to today.

import 'dart:async';

import 'package:buildsmart/screens/login_sheet.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal fake gateway for the widget flows (the full-knobbed twin lives in
/// auth_state_test.dart): correct OTP code = 123456 · email password = secret.
class _FakeAuthGateway implements AuthGateway {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? current;
  Map<String, dynamic> claims = const {};
  String? failSendCode;
  int signOutCalls = 0;
  int deleteCalls = 0;
  final List<String> otpPhones = [];

  void emit(AuthUser? user) {
    current = user;
    _controller.add(user);
  }

  void signInAs(AuthUser user, {Map<String, dynamic> withClaims = const {}}) {
    claims = withClaims;
    emit(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    // The seam CONTRACT (FirebaseAuth semantics): current state on subscribe.
    yield current;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => current;

  @override
  Future<String> sendOtp(String phone) async {
    final code = failSendCode;
    if (code != null) {
      failSendCode = null;
      throw AuthGatewayException(code);
    }
    otpPhones.add(phone);
    return 'vid-1';
  }

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {
    if (smsCode != '123456') {
      throw const AuthGatewayException('invalid-verification-code');
    }
    emit(const AuthUser(uid: 'u-phone', phone: '+972501234567'));
  }

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    if (password != 'secret') {
      throw const AuthGatewayException('wrong-password');
    }
    emit(AuthUser(uid: 'u-mail', email: email));
  }

  /// server-gate-auth — "צור חשבון": a NEW email already in use throws; a fresh
  /// one mints + signs in the account (correct create password = create123).
  final List<String> emailCreations = [];

  @override
  Future<void> createUserWithEmailPassword(String email, String password) async {
    if (email == 'dup@b.co') {
      throw const AuthGatewayException('email-already-in-use');
    }
    if (password.length < 6) {
      throw const AuthGatewayException('weak-password');
    }
    emailCreations.add(email);
    emit(AuthUser(uid: 'u-new', email: email));
  }

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      claims;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    emit(null);
  }

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    emit(null);
  }

  @override
  Future<void> setRole({required String uid, required String role}) async {}

  @override
  Future<void> resetPassword(String email) async {}

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('pure helpers', () {
    test('normalizeIlPhone — local → E.164, junk → null', () {
      expect(normalizeIlPhone('0501234567'), '+972501234567');
      expect(normalizeIlPhone('050-123 4567'), '+972501234567');
      expect(normalizeIlPhone('03-1234567'), '+97231234567'); // 9-digit local
      expect(normalizeIlPhone('+972501234567'), '+972501234567');
      expect(normalizeIlPhone('12'), isNull);
      expect(normalizeIlPhone('abc'), isNull);
      expect(normalizeIlPhone(''), isNull);
      expect(normalizeIlPhone('5012345678901'), isNull); // no leading 0 / +
    });

    test('hebrewAuthError — stable codes map to Hebrew, unknown → generic', () {
      expect(hebrewAuthError('invalid-phone-number'), 'מספר הטלפון אינו תקין');
      expect(
        hebrewAuthError('invalid-verification-code'),
        'קוד האימות שגוי — נסה שוב',
      );
      expect(
        hebrewAuthError('too-many-requests'),
        'יותר מדי ניסיונות — נסה שוב מאוחר יותר',
      );
      expect(hebrewAuthError('unavailable'), 'שירות ההתחברות אינו זמין כרגע');
      // P2 — account-enumeration: user-not-found folds into the SAME generic
      // credential message as a wrong password, so the sign-in form can't be
      // used to probe which emails are registered.
      expect(hebrewAuthError('user-not-found'), 'אימייל או סיסמה שגויים');
      expect(hebrewAuthError('wrong-password'), 'אימייל או סיסמה שגויים');
      expect(hebrewAuthError('invalid-credential'), 'אימייל או סיסמה שגויים');
      expect(hebrewAuthError('???'), 'ההתחברות נכשלה — נסה שוב');
    });

    test('hebrewAuthError — server-gate-auth createUser codes → honest Hebrew',
        () {
      expect(
        hebrewAuthError('email-already-in-use'),
        'האימייל כבר רשום — התחברו במקום',
      );
      expect(hebrewAuthError('weak-password'), 'סיסמה חלשה (6+ תווים)');
      expect(hebrewAuthError('invalid-email'), 'כתובת האימייל אינה תקינה');
    });
  });

  /// Pump a host app whose button opens [showLoginSheet]; returns nothing —
  /// the sheet is driven through finders.
  Future<void> pumpLoginHost(WidgetTester t, _FakeAuthGateway gw) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    addTearDown(gw.close);
    await t.pumpWidget(
      ProviderScope(
        overrides: [authGatewayProvider.overrideWithValue(gw)],
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showLoginSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('🔐 התחברות לחשבון'), findsOneWidget);
  }

  /// Let the (2s) toast SnackBar time out so no timer is pending at test end.
  Future<void> drainToast(WidgetTester t) =>
      t.pumpAndSettle(const Duration(seconds: 3));

  group('login sheet — S1.1/S1.2 phone OTP flow', () {
    testWidgets('phone → send code → enter code → signed in + sheet closes',
        (t) async {
      final gw = _FakeAuthGateway()..claims = const {'role': 'store'};
      await pumpLoginHost(t, gw);

      // S1.1 — send the OTP to the normalised E.164 number.
      await t.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        '0501234567',
      );
      await t.tap(find.text('שלח קוד אימות'));
      await t.pumpAndSettle();
      expect(gw.otpPhones, ['+972501234567']);
      expect(find.text('קוד אימות נשלח ב-SMS 📱'), findsOneWidget);
      expect(find.text('הקוד נשלח אל +972501234567'), findsOneWidget);

      // S1.2 — type the code; success closes the sheet via the auth stream.
      await t.enterText(
        find.widgetWithText(TextField, 'קוד בן 6 ספרות'),
        '123456',
      );
      await t.tap(find.text('אימות וכניסה'));
      await t.pumpAndSettle();
      expect(find.text('התחברת בהצלחה ✓'), findsOneWidget);
      expect(find.text('🔐 התחברות לחשבון'), findsNothing);
      await drainToast(t);
    });

    testWidgets('an invalid phone never reaches the gateway (Hebrew toast)',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.enterText(find.widgetWithText(TextField, 'מספר טלפון נייד'), '12');
      await t.tap(find.text('שלח קוד אימות'));
      await t.pumpAndSettle();
      expect(find.text('מספר הטלפון אינו תקין'), findsOneWidget);
      expect(gw.otpPhones, isEmpty);
      expect(find.text('שלח קוד אימות'), findsOneWidget); // still on step 1
      await drainToast(t);
    });

    testWidgets('a gateway failure surfaces as its Hebrew toast', (t) async {
      final gw = _FakeAuthGateway()..failSendCode = 'too-many-requests';
      await pumpLoginHost(t, gw);

      await t.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        '0501234567',
      );
      await t.tap(find.text('שלח קוד אימות'));
      await t.pumpAndSettle();
      expect(
        find.text('יותר מדי ניסיונות — נסה שוב מאוחר יותר'),
        findsOneWidget,
      );
      await drainToast(t);
    });

    testWidgets('a wrong code keeps the sheet open with a Hebrew toast',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        '0501234567',
      );
      await t.tap(find.text('שלח קוד אימות'));
      await t.pumpAndSettle();
      await t.enterText(
        find.widgetWithText(TextField, 'קוד בן 6 ספרות'),
        '000000',
      );
      await t.tap(find.text('אימות וכניסה'));
      await t.pumpAndSettle();
      expect(find.text('קוד האימות שגוי — נסה שוב'), findsOneWidget);
      expect(find.text('🔐 התחברות לחשבון'), findsOneWidget);
      await drainToast(t);
    });

    testWidgets(
        'Android auto-verification (user lands with no typed code) closes the sheet',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      // No interaction at all — the gateway signs in (verificationCompleted).
      gw.signInAs(const AuthUser(uid: 'u-auto', phone: '+972501234567'));
      await t.pumpAndSettle();
      expect(find.text('🔐 התחברות לחשבון'), findsNothing);
      expect(find.text('התחברת בהצלחה ✓'), findsOneWidget);
      await drainToast(t);
    });
  });

  group('login sheet — S1.3 email fallback', () {
    testWidgets('email + password signs in and closes the sheet', (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.tap(find.text('כניסה עם אימייל וסיסמה'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'אימייל'), 'a@b.co');
      await t.enterText(find.widgetWithText(TextField, 'סיסמה'), 'secret');
      await t.tap(find.text('כניסה עם אימייל'));
      await t.pumpAndSettle();
      expect(find.text('🔐 התחברות לחשבון'), findsNothing);
      await drainToast(t);
    });

    testWidgets('a wrong password toasts Hebrew and stays open', (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.tap(find.text('כניסה עם אימייל וסיסמה'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'אימייל'), 'a@b.co');
      await t.enterText(find.widgetWithText(TextField, 'סיסמה'), 'nope');
      await t.tap(find.text('כניסה עם אימייל'));
      await t.pumpAndSettle();
      expect(find.text('אימייל או סיסמה שגויים'), findsOneWidget);
      expect(find.text('🔐 התחברות לחשבון'), findsOneWidget);
      await drainToast(t);
    });

    // server-gate-auth — "צור חשבון" mints a REAL account from the email pane.
    testWidgets('create-account toggle → צור חשבון signs in the new account',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.tap(find.text('כניסה עם אימייל וסיסמה'));
      await t.pumpAndSettle();
      // The sign-in CTA is showing; flip to create-account mode.
      expect(find.text('כניסה עם אימייל'), findsOneWidget);
      await t.tap(find.text('אין לי חשבון — צור חשבון'));
      await t.pumpAndSettle();
      expect(find.text('צור חשבון'), findsOneWidget);
      expect(find.text('כניסה עם אימייל'), findsNothing);

      await t.enterText(find.widgetWithText(TextField, 'אימייל'), 'new@b.co');
      await t.enterText(
        find.widgetWithText(TextField, 'סיסמה (6+ תווים)'),
        'create123',
      );
      await t.tap(find.text('צור חשבון'));
      await t.pumpAndSettle();
      expect(gw.emailCreations, ['new@b.co']);
      // #3 — the create path now shows the email-verification notice (not the
      // generic sign-in toast); a verification mail was sent best-effort.
      expect(
        find.text('✓ החשבון נוצר — שלחנו מייל אימות לכתובת, אַשרו אותו'),
        findsOneWidget,
      );
      expect(find.text('🔐 התחברות לחשבון'), findsNothing); // sheet closed
      await drainToast(t);
    });

    testWidgets('צור חשבון — an already-registered email toasts honest Hebrew',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.tap(find.text('כניסה עם אימייל וסיסמה'));
      await t.pumpAndSettle();
      await t.tap(find.text('אין לי חשבון — צור חשבון'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'אימייל'), 'dup@b.co');
      await t.enterText(
        find.widgetWithText(TextField, 'סיסמה (6+ תווים)'),
        'create123',
      );
      await t.tap(find.text('צור חשבון'));
      await t.pumpAndSettle();
      expect(find.text('האימייל כבר רשום — התחברו במקום'), findsOneWidget);
      expect(find.text('🔐 התחברות לחשבון'), findsOneWidget); // stays open
      expect(gw.emailCreations, isEmpty);
      await drainToast(t);
    });

    // P2 — the client-side length pre-check short-circuits BEFORE the round-trip
    // (the gateway is never reached; the server weak-password error is a backstop).
    testWidgets('צור חשבון — a password under 6 chars is rejected client-side',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpLoginHost(t, gw);

      await t.tap(find.text('כניסה עם אימייל וסיסמה'));
      await t.pumpAndSettle();
      await t.tap(find.text('אין לי חשבון — צור חשבון'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'אימייל'), 'short@b.co');
      await t.enterText(
        find.widgetWithText(TextField, 'סיסמה (6+ תווים)'),
        '123',
      );
      await t.tap(find.text('צור חשבון'));
      await t.pumpAndSettle();
      expect(find.text('הסיסמה חייבת לפחות 6 תווים'), findsOneWidget);
      expect(gw.emailCreations, isEmpty); // never reached the gateway
      expect(find.text('🔐 התחברות לחשבון'), findsOneWidget); // stays open
      await drainToast(t);
    });
  });

  group('role picker gate — S1.6 (persona = identity)', () {
    Future<void> pumpPickerHost(
      WidgetTester t, {
      _FakeAuthGateway? gateway,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      if (gateway != null) addTearDown(gateway.close);
      await t.pumpWidget(
        ProviderScope(
          overrides: [authGatewayProvider.overrideWithValue(gateway)],
          child: MaterialApp(
            locale: const Locale('he'),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showRolePicker(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      // The host button does not WATCH auth (like home_shell's logo) — create
      // the provider eagerly so the gate test isn't racing lazy creation.
      ProviderScope.containerOf(t.element(find.text('open')))
          .read(authStateProvider);
      await t.pumpAndSettle();
    }

    testWidgets('signed-out (Firebase-free) keeps today’s picker', (t) async {
      await pumpPickerHost(t);
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('מי אתה?'), findsOneWidget);
    });

    testWidgets('a single-role user does NOT get the switcher', (t) async {
      final gw = _FakeAuthGateway();
      await pumpPickerHost(t, gateway: gw);
      gw.signInAs(
        const AuthUser(uid: 'u-store'),
        withClaims: const {'role': 'store'},
      );
      await t.pumpAndSettle();

      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(
        find.text('מי אתה?'),
        findsNothing,
        reason: 'one claim role = identity — the picker is locked',
      );
    });

    testWidgets('a multi-role user keeps the picker', (t) async {
      final gw = _FakeAuthGateway();
      await pumpPickerHost(t, gateway: gw);
      gw.signInAs(
        const AuthUser(uid: 'u-multi'),
        withClaims: const {
          'roles': ['store', 'courier'],
        },
      );
      await t.pumpAndSettle();

      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('מי אתה?'), findsOneWidget);
    });
  });

  group('profile screen — S1.7/S1.8 surfaces', () {
    Future<void> pumpProfile(
      WidgetTester t, {
      _FakeAuthGateway? gateway,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await t.binding.setSurfaceSize(const Size(440, 1700));
      addTearDown(() => t.binding.setSurfaceSize(null));
      if (gateway != null) addTearDown(gateway.close);
      await t.pumpWidget(
        ProviderScope(
          overrides: [authGatewayProvider.overrideWithValue(gateway)],
          child: const MaterialApp(
            locale: Locale('he'),
            home: ProfileScreen(),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('Firebase-free: NO auth rows render (zero regression)',
        (t) async {
      await pumpProfile(t);
      expect(find.text('🔐 התחברות לחשבון'), findsNothing);
      expect(find.text('🚪 התנתקות'), findsNothing);
      expect(find.text('🗑️ מחיקת חשבון'), findsNothing);
      // Today's rows are untouched.
      expect(find.text('🔄 החלפת תפקיד'), findsOneWidget);
      expect(find.text('🎮 מועדון BuildSmart'), findsOneWidget);
    });

    testWidgets('gateway + signed-out: the login row appears and opens the sheet',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpProfile(t, gateway: gw);
      gw.emit(null);
      await t.pumpAndSettle();

      final loginRow = find.text('🔐 התחברות לחשבון');
      expect(loginRow, findsOneWidget);
      await t.tap(loginRow);
      await t.pumpAndSettle();
      expect(find.text('🔐 התחברות לחשבון'), findsNWidgets(2)); // row + sheet
      expect(find.text('שלח קוד אימות'), findsOneWidget);
    });

    testWidgets(
        'signed-in single-role: logout+delete rows appear, role-switch row hides',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpProfile(t, gateway: gw);
      gw.signInAs(
        const AuthUser(uid: 'u1', phone: '+972501234567'),
        withClaims: const {'role': 'store'},
      );
      await t.pumpAndSettle();

      expect(find.text('חשבון'), findsOneWidget);
      expect(find.text('🚪 התנתקות'), findsOneWidget);
      expect(find.text('🗑️ מחיקת חשבון'), findsOneWidget);
      expect(find.text('🔐 התחברות לחשבון'), findsNothing);
      expect(
        find.text('🔄 החלפת תפקיד'),
        findsNothing,
        reason: 'S1.6 — single role: showRolePicker would no-op',
      );
    });

    testWidgets('logout signs out, wipes the profile, and flips back to login',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpProfile(t, gateway: gw);
      final container =
          ProviderScope.containerOf(t.element(find.byType(ProfileScreen)));
      container
          .read(userProfileProvider.notifier)
          .register(name: 'מאיר', contact: '050-1234567');
      gw.signInAs(const AuthUser(uid: 'u1'));
      await t.pumpAndSettle();

      await t.tap(find.text('🚪 התנתקות'));
      await t.pumpAndSettle();

      expect(gw.signOutCalls, 1);
      expect(find.text('התנתקת מהחשבון'), findsOneWidget);
      expect(container.read(userProfileProvider).name, isEmpty);
      expect(find.text('🚪 התנתקות'), findsNothing);
      expect(find.text('🔐 התחברות לחשבון'), findsOneWidget);
      await drainToast(t);
    });

    testWidgets('deletion asks for Hebrew confirmation before user.delete()',
        (t) async {
      final gw = _FakeAuthGateway();
      await pumpProfile(t, gateway: gw);
      gw.signInAs(const AuthUser(uid: 'u1'));
      await t.pumpAndSettle();

      // Cancel first — nothing deleted.
      await t.tap(find.text('🗑️ מחיקת חשבון'));
      await t.pumpAndSettle();
      expect(
        find.text('החשבון וכל הנתונים האישיים יימחקו לצמיתות. את הפעולה אי אפשר לבטל.'),
        findsOneWidget,
      );
      await t.tap(find.text('ביטול'));
      await t.pumpAndSettle();
      expect(gw.deleteCalls, 0);
      expect(find.text('🗑️ מחיקת חשבון'), findsOneWidget);

      // Confirm — the account is deleted and the screen flips to signed-out.
      await t.tap(find.text('🗑️ מחיקת חשבון'));
      await t.pumpAndSettle();
      await t.tap(find.text('מחק לצמיתות'));
      await t.pumpAndSettle();
      expect(gw.deleteCalls, 1);
      expect(find.text('החשבון נמחק לצמיתות'), findsOneWidget);
      expect(find.text('🗑️ מחיקת חשבון'), findsNothing);
      await drainToast(t);
    });
  });
}
