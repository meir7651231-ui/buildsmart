// Signing out / deleting the account from the open 👤 ProfileScreen must clear
// the form. The controllers were seeded once in initState, so after the
// identity wipe the previous person's name / phone / address / ח.פ. stayed on
// screen — and tapping שמור wrote them straight back into the wiped profile,
// for the next person who signs in on the device to inherit.

import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal [AuthGateway]: current-state-on-subscribe stream, sign-out and
/// delete both end the session. Anything else is never called here.
class _Gw implements AuthGateway {
  _Gw(this.current);
  final _c = StreamController<AuthUser?>.broadcast();
  AuthUser? current;
  bool failDelete = false;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield current;
    yield* _c.stream;
  }

  @override
  AuthUser? get currentUser => current;

  @override
  Future<Map<String, dynamic>> idTokenClaims({
    bool forceRefresh = false,
  }) async => const {};

  @override
  Future<void> signOut() async {
    current = null;
    _c.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    if (failDelete) throw const AuthGatewayException('network-request-failed');
    current = null;
    _c.add(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  Future<void> close() => _c.close();
}

const _a = UserProfile(
  name: 'דני כהן',
  contact: '0501234567',
  profession: 'חשמלאי',
  address: 'חיפה',
  businessId: '123456782', // valid check digit,
  registered: true,
);

Finder _field(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

String _text(WidgetTester t, String hint) =>
    t.widget<TextField>(_field(hint)).controller!.text;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pump(WidgetTester t, _Gw gw) async {
    SharedPreferences.setMockInitialValues({
      kUserProfileKey: jsonEncode(_a.toJson()),
    });
    await t.binding.setSurfaceSize(const Size(440, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    addTearDown(gw.close);
    final c = ProviderContainer(
      overrides: [authGatewayProvider.overrideWithValue(gw)],
    );
    addTearDown(c.dispose);
    // Let the profile load from prefs and the auth stream deliver the user
    // BEFORE the screen opens (its initState seeds the form once).
    c
      ..read(authStateProvider)
      ..read(userProfileProvider);
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(locale: Locale('he'), home: ProfileScreen()),
      ),
    );
    await t.pumpAndSettle();
    return c;
  }

  Future<void> tapRow(WidgetTester t, String label) async {
    await t.ensureVisible(find.text(label));
    await t.pumpAndSettle();
    await t.tap(find.text(label));
    await t.pumpAndSettle();
  }

  testWidgets('sign-out clears the form; שמור does not resurrect A', (t) async {
    final c = await pump(t, _Gw(const AuthUser(uid: 'a', email: 'a@x.co')));
    expect(_text(t, 'שם הקבלן'), 'דני כהן', reason: 'seeded with A');

    await tapRow(t, '🚪 התנתקות');

    expect(c.read(userProfileProvider).name, '', reason: 'profile wiped');
    expect(_text(t, 'שם הקבלן'), '');
    expect(_text(t, 'טלפון או אימייל'), '');
    expect(_text(t, 'כתובת / אזור'), '');
    expect(_text(t, 'ח.פ. / עוסק מורשה'), '');

    await tapRow(t, 'שמור');
    final p = c.read(userProfileProvider);
    expect(p.name, '');
    expect(p.contact, '');
    expect(p.businessId, '');
    expect(p.profession, '');
    expect(
      p.registered,
      isFalse,
      reason: 'saving after sign-out must not re-register A',
    );
  });

  testWidgets('account deletion clears the form', (t) async {
    final c = await pump(t, _Gw(const AuthUser(uid: 'a', email: 'a@x.co')));

    await tapRow(t, '🗑️ מחיקת חשבון');
    await t.tap(find.text('מחק לצמיתות'));
    await t.pumpAndSettle();

    expect(c.read(userProfileProvider).name, '');
    expect(_text(t, 'שם הקבלן'), '');
    expect(_text(t, 'ח.פ. / עוסק מורשה'), '');
  });

  testWidgets('a FAILED deletion keeps the account and the form', (t) async {
    final gw = _Gw(const AuthUser(uid: 'a', email: 'a@x.co'))
      ..failDelete = true;
    final c = await pump(t, gw);

    await tapRow(t, '🗑️ מחיקת חשבון');
    await t.tap(find.text('מחק לצמיתות'));
    await t.pumpAndSettle();

    expect(c.read(userProfileProvider).name, 'דני כהן');
    expect(_text(t, 'שם הקבלן'), 'דני כהן');
  });

  testWidgets('an ordinary save does not clear the form', (t) async {
    final c = await pump(t, _Gw(const AuthUser(uid: 'a', email: 'a@x.co')));

    await t.enterText(_field('כתובת / אזור'), 'תל אביב');
    await tapRow(t, 'שמור');

    expect(c.read(userProfileProvider).address, 'תל אביב');
    expect(_text(t, 'שם הקבלן'), 'דני כהן');
    expect(_text(t, 'כתובת / אזור'), 'תל אביב');
  });
  testWidgets('signing in again after sign-out shows the new details', (
    t,
  ) async {
    final c = await pump(t, _Gw(const AuthUser(uid: 'a', email: 'a@x.co')));
    await tapRow(t, '🚪 התנתקות');
    expect(_text(t, 'שם הקבלן'), '');

    // The login sheet registers the new person's name on success.
    c
        .read(userProfileProvider.notifier)
        .register(name: 'רונית לוי', contact: '0527654321');
    await t.pumpAndSettle();

    expect(_text(t, 'שם הקבלן'), 'רונית לוי');
    expect(_text(t, 'טלפון או אימייל'), '0527654321');

    // שמור now keeps B's name instead of blanking it.
    await tapRow(t, 'שמור');
    expect(c.read(userProfileProvider).name, 'רונית לוי');
  });

  testWidgets('a late profile change never overwrites typing', (t) async {
    final c = await pump(t, _Gw(const AuthUser(uid: 'a', email: 'a@x.co')));
    await tapRow(t, '🚪 התנתקות');
    await t.enterText(_field('שם הקבלן'), 'מוקלד');
    await t.pump();

    c
        .read(userProfileProvider.notifier)
        .register(name: 'אחר', contact: '0527654321');
    await t.pumpAndSettle();

    expect(_text(t, 'שם הקבלן'), 'מוקלד');
  });
}
