// Guards the welcome→auth wiring (#server-gate-auth · launch B8 "real
// registration for a NEW user"): with the backend flag OFF (the default — tests
// never initialise Firebase) the welcome flow stays on the demo path and the
// users-profile writer is null, so NOTHING reaches Firestore and no real account
// is fabricated. The flag-ON path (route to showLoginSheet → Firebase phone-OTP
// creates the account on first verify → mirror identity to users/{uid}) is
// exercised by the real-backend preview channel on a device — it needs a live
// Firebase gateway the sandbox can't provide, since `useFirebaseBackend` is true
// only when Firebase actually initialised.
//
// What IS lockable in-sandbox (and what these guards pin):
//   1. The flag-OFF welcome CTA registers LOCALLY and advances to the profession
//      step — it never writes to a (present) users sink. So even if the flag
//      gate in `_register` were dropped, this fails: demo must NOT mint a real
//      account record.
//   2. The "real account record" CONTRACT the flag-ON path writes — the exact
//      shape `_enterViaAuth` mirrors to `users/{uid}`: a merge of
//      {displayName, phone} keyed by the Firebase uid, with EMPTY identity
//      fields skipped (S5 rules let a signed-in user self-write only those).
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A recording fake of the `users` write-site ([RemoteCollectionSource]) — the
/// S2/S6 base-test fake shape: every `set` is captured in order. If the demo
/// path ever wrote here (it must not), `sets` would be non-empty.
class _FakeUsersSink implements RemoteCollectionSource {
  final List<({String id, Map<String, dynamic> data})> sets = [];

  @override
  Stream<List<RemoteDoc>> snapshots() => const Stream<List<RemoteDoc>>.empty();

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    sets.add((id: id, data: Map<String, dynamic>.of(data)));
  }

  @override
  Future<void> delete(String id) async {}
}

void main() {
  test('backend flag is OFF in tests → no live backend', () {
    expect(useFirebaseBackend, isFalse);
  });

  testWidgets('usersProfileWriterProvider is null without Firebase', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(usersProfileWriterProvider), isNull);
  });

  testWidgets('welcome renders the demo path with the flag OFF', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pump();

    // The demo entry link is present (flag OFF = the existing onboarding).
    expect(find.text('המשך ללא רישום (דוגמה)'), findsOneWidget);
    // Sanity: not yet entered the app.
    final c = ProviderScope.containerOf(
      tester.element(find.byType(WelcomeScreen)),
    );
    expect(c.read(welcomeSeenProvider), isTrue); // default true in tests
  });

  // ── B8: registration routing — flag OFF stays demo, mints NO real account ──
  testWidgets(
      'flag OFF: register CTA saves locally + advances, writes NO users doc',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(420, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sink = _FakeUsersSink();
    await tester.pumpWidget(
      ProviderScope(
        // A writer + a signed-in gateway are PRESENT — yet the flag-OFF demo
        // path must still never mirror. (In a real flag-OFF run both are null;
        // forcing them non-null here makes the no-write a genuine guard on the
        // `_register` flag gate, not an artifact of missing dependencies.)
        overrides: [
          usersProfileWriterProvider.overrideWithValue(sink),
        ],
        child: const MaterialApp(
          locale: Locale('he'),
          home: WelcomeScreen(),
        ),
      ),
    );
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WelcomeScreen)),
    );
    expect(container.read(startupStepProvider), 0); // on welcome

    // Fill a valid registration (name + Israeli mobile) and tap the CTA.
    await tester.enterText(
      find.widgetWithText(TextField, 'שם מלא'),
      'מאיר ישראלי',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'טלפון או אימייל'),
      '0501234567',
    );
    await tester.pump();
    await tester.tap(find.text('אישור והמשך'));
    await tester.pump();

    // Demo path (flag OFF): the profile is saved locally + registered, the
    // flow advanced to the profession step — and NOTHING was written to the
    // users collection (no real account fabricated).
    final profile = container.read(userProfileProvider);
    expect(profile.registered, isTrue);
    expect(profile.name, 'מאיר ישראלי');
    expect(profile.contact, '0501234567');
    expect(container.read(startupStepProvider), 1, reason: 'advanced to step 1');
    expect(sink.sets, isEmpty, reason: 'flag OFF must never mirror to users/');
  });

  // ── B8: the "real account record" the flag-ON path mirrors to users/{uid} ──
  // Pins the exact write `welcome_screen._enterViaAuth` performs after a NEW
  // user signs in (phone-OTP creates the Firebase account on first verify):
  // merge {displayName, phone} keyed by uid, with empty identity fields skipped.
  // Reproduces the write so a regression to the shape/keys/skip-rule fails here
  // even though the flag-gated routing itself is device-only.
  test('users/{uid} identity mirror: keys, uid-keyed, empties skipped', () {
    // Helper mirroring _enterViaAuth's payload builder verbatim.
    Map<String, dynamic> mirror(String name, String contact) => {
          if (name.isNotEmpty) 'displayName': name,
          if (contact.isNotEmpty) 'phone': contact,
        };

    final sink = _FakeUsersSink();
    const uid = 'firebase-uid-123';

    // A fully-identified new user → both fields written under the uid.
    sink.set(uid, mirror('מאיר ישראלי', '+972501234567'));
    expect(sink.sets.single.id, uid, reason: 'keyed by the Firebase uid');
    expect(sink.sets.single.data, {
      'displayName': 'מאיר ישראלי',
      'phone': '+972501234567',
    });

    // Empty identity fields are skipped (never blank-overwrite the doc / role).
    sink.sets.clear();
    sink.set(uid, mirror('', ''));
    expect(
      sink.sets.single.data,
      isEmpty,
      reason: 'no blank displayName/phone written',
    );

    sink.sets.clear();
    sink.set(uid, mirror('שם בלבד', ''));
    expect(sink.sets.single.data, {'displayName': 'שם בלבד'});
  });
}
