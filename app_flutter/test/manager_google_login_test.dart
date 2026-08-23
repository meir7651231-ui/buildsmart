// Guards the MANAGER (OWNER) Google-only login gate (#manager-owner שלב 2):
//   • the manager board gate shows "כניסה עם Google" ONLY — no seed code, no
//     demo entry (the worker/courier/store gates keep their seed login);
//   • [isOwnerEmail] is the owner allowlist (case/space-insensitive);
//   • a Google sign-in whose email is on the allowlist grants a REAL (non-demo)
//     manager BoardSession carrying the Firebase uid; any OTHER account is
//     rejected and signed out (never silently admits a stranger);
//   • with NO Firebase gateway (the Firebase-free test/sandbox default) the gate
//     shows an honest "needs a connection" message instead of the button.
import 'dart:async';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fake [AuthGateway] whose `signInWithGoogle` returns a configurable user
/// (null = the user cancelled the chooser). Records `signOut` so the non-owner
/// rejection (sign-out) is assertable.
class _GoogleGate implements AuthGateway {
  _GoogleGate(this._user);
  final AuthUser? _user;
  int signOutCalls = 0;

  @override
  Future<AuthUser?> signInWithGoogle() async => _user;

  @override
  Future<void> signOut() async => signOutCalls++;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield null;
  }

  @override
  AuthUser? get currentUser => null;
  @override
  Future<String> sendOtp(String phone) async => 'vid';
  @override
  Future<void> signInWithSmsCode(String v, String s) async {}
  @override
  Future<void> signInWithEmailPassword(String e, String p) async {}
  @override
  Future<void> createUserWithEmailPassword(String e, String p) async {}
  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      const {};
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> setRole({required String uid, required String role}) async {}
}

void main() {
  group('isOwnerEmail — owner allowlist', () {
    test('the owner email matches regardless of case / surrounding spaces', () {
      expect(isOwnerEmail('meir7651231@gmail.com'), isTrue);
      expect(isOwnerEmail('MEIR7651231@Gmail.COM'), isTrue);
      expect(isOwnerEmail('  meir7651231@gmail.com  '), isTrue);
    });

    test('any other email — and null/empty — is rejected', () {
      expect(isOwnerEmail('someone@else.com'), isFalse);
      expect(isOwnerEmail(''), isFalse);
      expect(isOwnerEmail(null), isFalse);
    });
  });

  group('manager gate — Google-only', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    void sizeOf(WidgetTester t) {
      t.view.physicalSize = const Size(420, 1000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
    }

    testWidgets('no Firebase gateway → honest message, no Google button, no demo',
        (t) async {
      sizeOf(t);
      await t.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('he'),
            home: WelcomeScreen(boardRole: BoardRole.manager),
          ),
        ),
      );
      await t.pump();

      expect(find.text('המשך עם Google'), findsNothing);
      expect(find.textContaining('דורשת חיבור'), findsOneWidget);
      // The manager gate never offers a seed code field nor the demo entry.
      expect(find.text('מצב דמו'), findsNothing);
      expect(find.text('המשך ללא רישום (דוגמה)'), findsNothing);
    });

    testWidgets('owner Google sign-in → real manager board session', (t) async {
      sizeOf(t);
      final gw = _GoogleGate(
        const AuthUser(
          uid: 'owner-uid',
          email: 'meir7651231@gmail.com',
          displayName: 'מאיר',
        ),
      );
      await t.pumpWidget(
        ProviderScope(
          overrides: [authGatewayProvider.overrideWithValue(gw)],
          child: const MaterialApp(
            locale: Locale('he'),
            home: WelcomeScreen(boardRole: BoardRole.manager),
          ),
        ),
      );
      await t.pump();

      expect(find.text('המשך עם Google'), findsOneWidget);
      final c =
          ProviderScope.containerOf(t.element(find.byType(WelcomeScreen)));
      expect(c.read(boardAuthProvider)?.role, isNot(BoardRole.manager));

      await t.tap(find.text('המשך עם Google'));
      await t.pump();
      await t.pump();

      final session = c.read(boardAuthProvider);
      expect(session?.role, BoardRole.manager);
      expect(session?.uid, 'owner-uid');
      expect(session?.displayName, 'מאיר');
      expect(session?.demo, isFalse, reason: 'a Google owner login is NOT demo');
    });

    testWidgets('non-owner Google sign-in → rejected (no session, signed out)',
        (t) async {
      sizeOf(t);
      final gw = _GoogleGate(
        const AuthUser(uid: 'x', email: 'intruder@evil.com'),
      );
      await t.pumpWidget(
        ProviderScope(
          overrides: [authGatewayProvider.overrideWithValue(gw)],
          child: const MaterialApp(
            locale: Locale('he'),
            home: WelcomeScreen(boardRole: BoardRole.manager),
          ),
        ),
      );
      await t.pump();

      await t.tap(find.text('המשך עם Google'));
      await t.pump();
      await t.pump();

      final c =
          ProviderScope.containerOf(t.element(find.byType(WelcomeScreen)));
      expect(c.read(boardAuthProvider)?.role, isNot(BoardRole.manager),
          reason: 'a non-owner account must never reach the manager board');
      expect(gw.signOutCalls, greaterThan(0),
          reason: 'a rejected non-owner is signed out');
    });
  });
}
