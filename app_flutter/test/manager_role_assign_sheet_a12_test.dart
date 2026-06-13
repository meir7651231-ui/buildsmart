// A12 (launch Phase A) — widget coverage for the manager role-assignment sheet
// ([ManagerRoleAssignSheet], manager_role_assign_sheet.dart): the in-app UI that
// forwards a role assignment through the EXISTING `assignRole({uid, role})` seam
// (auth_state.dart, S1.9) after resolving the target uid via the A7 directory
// ([UsersLookup], users_lookup.dart).
//
// Pins (the A12 contract):
//   • with a live backend (a fake gateway): picking a role + entering a PHONE
//     looks the phone up to a uid through a fake [UsersLookup] and forwards the
//     EXACT {uid, role} to the gateway's setRole — the seam the test asserts on;
//   • a pasted uid bypasses the lookup and is forwarded verbatim;
//   • a phone with no matching users doc does NOT call setRole (honest miss);
//   • WITHOUT a backend (gateway null — the Firebase-free / sandbox gate) the
//     action is DISABLED and the no-backend message is shown — NO assignment is
//     faked (HARD RULE #1).
//
// No Firebase here: the auth seam is a hand-rolled fake (the auth_state_test
// shape) and the directory is a real [UsersLookup] over the users_lookup_a7_test
// fake source — both Firebase-free, zero new packages.

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:buildsmart/screens/manager_role_assign_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [AuthGateway] recording every `setRole` forward — trimmed
/// from auth_state_test's fake to what this sheet exercises (the auth-stream is
/// a no-op single null event so the eager authStateProvider settles signed-out).
class _FakeAuthGateway implements AuthGateway {
  final List<({String uid, String role})> setRoleCalls = [];

  /// When non-null, the next [setRole] throws this code (the failure path).
  String? failRoleCode;

  @override
  Future<void> setRole({required String uid, required String role}) async {
    final code = failRoleCode;
    if (code != null) throw AuthGatewayException(code);
    setRoleCalls.add((uid: uid, role: role));
  }

  @override
  Stream<AuthUser?> authStateChanges() => Stream<AuthUser?>.value(null);

  @override
  AuthUser? get currentUser => null;

  @override
  Future<String> sendOtp(String phone) async => 'vid';

  @override
  Future<void> signInWithSmsCode(String v, String c) async {}

  @override
  Future<void> signInWithEmailPassword(String e, String p) async {}

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) async =>
      const {};

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}
}

/// The users_lookup_a7_test fake source: a `users` snapshot emitted as neutral
/// [RemoteDoc]s, so the real [UsersLookup] resolves phone→uid with no Firebase.
class _FakeUsersSource implements RemoteCollectionSource {
  _FakeUsersSource(this._docs);
  final List<RemoteDoc> _docs;

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(_docs);

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A small `users` directory mirroring the welcome flow ({phone} + an
  /// optional admin-assigned role); doc-id IS the auth.uid.
  List<RemoteDoc> sampleUsers() => [
        const RemoteDoc('uid-zevi', {kUsersPhoneField: '050-1234567'}),
        const RemoteDoc(
            'uid-store', {kUsersPhoneField: '052-2222222', kUsersRoleField: 'store'}),
      ];

  Future<void> settle(WidgetTester t, [int frames = 5]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  /// Pump the sheet directly (no full dashboard — the sheet is self-contained)
  /// inside a MaterialApp so toasts have a ScaffoldMessenger. [gateway] null ⇒
  /// the no-backend gate; [source] null ⇒ no directory (provider stays null).
  Future<void> pumpSheet(
    WidgetTester t, {
    _FakeAuthGateway? gateway,
    _FakeUsersSource? source,
  }) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          authGatewayProvider.overrideWithValue(gateway),
          if (source != null)
            usersLookupProvider.overrideWithValue(UsersLookup(source))
          else
            usersLookupProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(
          locale: Locale('he'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: ManagerRoleAssignSheet(),
            ),
          ),
        ),
      ),
    );
    await settle(t);
  }

  group('ManagerRoleAssignSheet — with a live backend (A12)', () {
    testWidgets('phone lookup → uid: forwards the EXACT {uid, role} to setRole',
        (t) async {
      final gw = _FakeAuthGateway();
      final src = _FakeUsersSource(sampleUsers());
      await pumpSheet(t, gateway: gw, source: src);

      // Enter the phone, pick a role, submit.
      await t.enterText(
          find.byKey(const ValueKey('role-assign-phone')), '050-1234567');
      await t.tap(find.byKey(const ValueKey('role-chip-courier')));
      await settle(t);
      await t.tap(find.byKey(const ValueKey('role-assign-submit')));
      await settle(t);

      // The phone resolved to uid-zevi and the picked role rode through verbatim.
      expect(gw.setRoleCalls, [(uid: 'uid-zevi', role: 'courier')]);
    });

    testWidgets('a pasted uid bypasses the lookup and is forwarded verbatim',
        (t) async {
      final gw = _FakeAuthGateway();
      final src = _FakeUsersSource(sampleUsers());
      await pumpSheet(t, gateway: gw, source: src);

      await t.enterText(
          find.byKey(const ValueKey('role-assign-uid')), 'uid-pasted');
      await t.tap(find.byKey(const ValueKey('role-chip-store')));
      await settle(t);
      await t.tap(find.byKey(const ValueKey('role-assign-submit')));
      await settle(t);

      expect(gw.setRoleCalls, [(uid: 'uid-pasted', role: 'store')]);
    });

    testWidgets('a phone with NO matching users doc does not call setRole',
        (t) async {
      final gw = _FakeAuthGateway();
      final src = _FakeUsersSource(sampleUsers());
      await pumpSheet(t, gateway: gw, source: src);

      await t.enterText(
          find.byKey(const ValueKey('role-assign-phone')), '099-0000000');
      await t.tap(find.byKey(const ValueKey('role-chip-worker')));
      await settle(t);
      await t.tap(find.byKey(const ValueKey('role-assign-submit')));
      await settle(t);

      expect(gw.setRoleCalls, isEmpty, reason: 'an unknown phone is an honest miss');
      expect(find.textContaining('לא נמצא משתמש'), findsOneWidget);
    });

    testWidgets('a server rejection surfaces a failure toast, never success',
        (t) async {
      final gw = _FakeAuthGateway()..failRoleCode = 'permission-denied';
      final src = _FakeUsersSource(sampleUsers());
      await pumpSheet(t, gateway: gw, source: src);

      await t.enterText(
          find.byKey(const ValueKey('role-assign-uid')), 'uid-pasted');
      await t.tap(find.byKey(const ValueKey('role-chip-manager')));
      await settle(t);
      await t.tap(find.byKey(const ValueKey('role-assign-submit')));
      await settle(t);

      expect(find.textContaining('נכשל'), findsOneWidget);
      expect(find.textContaining('✅'), findsNothing);
    });
  });

  group('ManagerRoleAssignSheet — no backend (HARD RULE #1)', () {
    testWidgets('the submit action is DISABLED and the gate banner is shown',
        (t) async {
      // No gateway/source override = the Firebase-free / sandbox gate; both
      // providers stay null. No assignment may be faked.
      await pumpSheet(t);

      // The no-backend banner is present.
      expect(find.textContaining('זמין רק עם חיבור לשרת'), findsWidgets);

      // The submit button is wired to a null onTap (disabled): even tapping it
      // (after picking a role would be impossible too — chips are disabled) does
      // nothing. We assert the InkWell's onTap is null.
      final inkwell = t.widget<InkWell>(
        find.ancestor(
          of: find.text('שייך תפקיד'),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkwell.onTap, isNull, reason: 'disabled with no backend');
    });
  });
}
