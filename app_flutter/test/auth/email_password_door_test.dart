// The email+password door is closed.
//
// THE OWNER'S DECISION: sign-in is Google or a phone code, nothing else. A
// password is a secret this project would otherwise have to hold — resets, weak
// choices, breach exposure — and Google and the carrier already do that work.
//
// ⚠️ WHAT THESE TESTS DO **NOT** PROVE, AND MUST NOT BE READ AS PROVING:
// Firebase Auth is a public HTTPS API and the web API key ships inside
// main.dart.js. `accounts:signUp` therefore accepts email+password from anyone
// who reads the bundle, with the app not involved at all — confirmed against the
// live project, which answered WEAK_PASSWORD (it processed the request and only
// objected to the value). The ONLY lock is the Email/Password provider being
// disabled in the Firebase console. Everything here closes the door people can
// SEE, so nobody is offered an entrance the server is going to refuse.
//
// The gates are deliberately DOUBLED — one where the UI is drawn, one on the
// call that actually reaches Firebase. A single gate is one careless edit away
// from reopening, and reopening would be silent.

import 'dart:async';

import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/login_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records whether anything ever tried to mint an email account.
class _WatchfulGateway implements AuthGateway {
  final _controller = StreamController<AuthUser?>.broadcast();
  int createCalls = 0;
  int emailSignInCalls = 0;
  int resetCalls = 0;

  Future<void> close() => _controller.close();

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield null;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthUser?> signInWithGoogle() async => null;

  @override
  Future<String> sendOtp(String phone) async => 'verification-id';

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {}

  @override
  Future<void> signInWithEmailPassword(String e, String p) async =>
      emailSignInCalls++;

  @override
  Future<void> createUserWithEmailPassword(String e, String p) async =>
      createCalls++;

  @override
  Future<void> resetPassword(String email) async => resetCalls++;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> setRole({required String uid, required String role}) async {}

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      const {};
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('the flag is OFF by default — the decision holds without a build flag',
      () {
    // Inverted on purpose: every other flag here defaults false = "unchanged".
    // If this one defaulted to the old behaviour, any build that forgot to pass
    // it would quietly reopen the door.
    expect(kEmailPasswordAuth, isFalse);
  });

  group('the login sheet offers no email door', () {
    Future<_WatchfulGateway> pumpSheet(WidgetTester t) async {
      final gw = _WatchfulGateway();
      addTearDown(gw.close);
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
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
      return gw;
    }

    testWidgets('the "sign in with email and password" link is gone',
        (tester) async {
      await pumpSheet(tester);
      expect(find.text('כניסה עם אימייל וסיסמה'), findsNothing,
          reason: 'the only way into the email pane from this sheet');
    });

    testWidgets('no password field is reachable', (tester) async {
      await pumpSheet(tester);
      expect(find.text('סיסמה'), findsNothing);
      expect(find.text('סיסמה (6+ תווים)'), findsNothing);
      expect(find.text('צור חשבון'), findsNothing);
    });

    testWidgets('the phone path is untouched — the door that stays open',
        (tester) async {
      // Closing one door must not close the others; this is the check that
      // would have caught a gate written one level too wide.
      await pumpSheet(tester);
      expect(find.text('שלח קוד אימות'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        findsOneWidget,
      );
    });
  });

  group('the registration form takes a phone, not an email', () {
    Future<_WatchfulGateway> pumpWelcome(WidgetTester t) async {
      final gw = _WatchfulGateway();
      addTearDown(gw.close);
      t.view.physicalSize = const Size(420, 1400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        ProviderScope(
          overrides: [authGatewayProvider.overrideWithValue(gw)],
          child: const MaterialApp(
            locale: Locale('he'),
            home: WelcomeScreen(),
          ),
        ),
      );
      await t.pump();
      return gw;
    }

    testWidgets('the contact field asks for a phone number', (tester) async {
      await pumpWelcome(tester);
      expect(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextField, 'טלפון או אימייל'),
        findsNothing,
        reason: 'nobody may be invited to type something that is refused',
      );
    });

    testWidgets('typing an email never grows a password field', (tester) async {
      await pumpWelcome(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'שם מלא'),
        'מאיר ישראלי',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        'someone@example.com',
      );
      await tester.pump();

      expect(find.widgetWithText(TextField, 'סיסמה (6+ תווים)'), findsNothing);
    });

    testWidgets('an email address is rejected as a contact', (tester) async {
      await pumpWelcome(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'שם מלא'),
        'מאיר ישראלי',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        'someone@example.com',
      );
      await tester.pump();
      expect(find.text('מספר נייד לא תקין'), findsOneWidget);
    });

    testWidgets('⚠️ NO ACCOUNT IS MINTED from an email contact',
        (tester) async {
      // The assertion that matters: whatever the form allows, the call that
      // hands a password to Firebase must never run.
      final gw = await pumpWelcome(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'שם מלא'),
        'מאיר ישראלי',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        'someone@example.com',
      );
      await tester.pump();
      // Tap the CTA even though it should be disabled — a disabled button is a
      // UI state, not a guarantee.
      final cta = find.text('אישור והמשך');
      if (cta.evaluate().isNotEmpty) {
        await tester.tap(cta, warnIfMissed: false);
        await tester.pump();
      }
      expect(gw.createCalls, 0);
      expect(gw.emailSignInCalls, 0);
    });

    testWidgets('a real mobile number still registers', (tester) async {
      // The other half of the contract: the remaining door must still open.
      await pumpWelcome(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'שם מלא'),
        'מאיר ישראלי',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'מספר טלפון נייד'),
        '0501234567',
      );
      await tester.pump();
      expect(find.text('מספר נייד לא תקין'), findsNothing);
    });
  });

  group('the validators themselves are unchanged', () {
    // The door was closed by narrowing WHICH validator the form consults, not
    // by breaking the validators — anything else in the app that checks an
    // email must keep working.
    test('validEmail still recognises an email', () {
      expect(validEmail('someone@example.com'), isTrue);
    });

    test('validIsraeliMobile still recognises a mobile', () {
      expect(validIsraeliMobile('0501234567'), isTrue);
    });

    test('an email is not a mobile — the distinction the gate now rests on', () {
      expect(validIsraeliMobile('someone@example.com'), isFalse);
    });
  });
}
