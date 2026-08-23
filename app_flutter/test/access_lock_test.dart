// Access-lock feature — the owner-set password gate (config/access_lock.dart +
// OrgConfig.accessPasswordHash + AccessLockGate). Three tiers:
//   · 'hash'            — the pure hash/compare helpers (deterministic, salted,
//                         blank→'' sentinel, empty-stored = no lock).
//   · 'config round-trip' — encode/decode carry the hash under 'pwHash',
//                         omitted when empty (the A4 omit-empty idiom).
//   · 'gate widget'     — AccessLockGate over a MaterialApp: empty hash = the
//                         child unwrapped; a set hash locks until the right
//                         password is entered (wrong → 'סיסמה שגויה').
//
// Widget setup mirrors the repo convention (org_setup_wizard_test /
// invoice_gate_test): SharedPreferences.setMockInitialValues + a ProviderScope
// override of orgConfigProvider around the pumped MaterialApp.

import 'package:buildsmart/config/access_lock.dart';
import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/screens/access_lock_gate.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('hash', () {
    test('deterministic + non-empty for a real password; blank → the sentinel',
        () {
      // Same input → same digest, twice (deterministic), and it is a real hash.
      expect(hashAccessPassword('secret'), hashAccessPassword('secret'));
      expect(hashAccessPassword('secret'), isNotEmpty);
      // Blank / whitespace-only collapse to '' — the "no lock" sentinel.
      expect(hashAccessPassword('   '), '');
      expect(hashAccessPassword(''), '');
    });

    test('distinct inputs → distinct hashes; the hash is not the plaintext',
        () {
      expect(hashAccessPassword('secret'), isNot(hashAccessPassword('other')));
      expect(hashAccessPassword('secret'), isNot('secret'));
    });

    test('accessPasswordMatches: empty stored = open; else exact match only',
        () {
      // Empty stored hash = no lock → anything passes.
      expect(accessPasswordMatches('', 'anything'), isTrue);
      expect(accessPasswordMatches('', ''), isTrue);
      // A real stored hash requires the exact password.
      final h = hashAccessPassword('secret');
      expect(accessPasswordMatches(h, 'secret'), isTrue);
      expect(accessPasswordMatches(h, 'nope'), isFalse);
    });
  });

  group('config round-trip', () {
    test('a set hash rides under "pwHash" and decodes back', () {
      final encoded = encodeOrgConfig(const OrgConfig(accessPasswordHash: 'abc'));
      expect(encoded, contains('pwHash'));
      final decoded = decodeOrgConfig(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.accessPasswordHash, 'abc');
    });

    test('an empty hash is OMITTED from the envelope and decodes to \'\'', () {
      final encoded = encodeOrgConfig(const OrgConfig());
      expect(encoded, isNot(contains('pwHash')));
      expect(decodeOrgConfig(encoded)!.accessPasswordHash, '');
    });
  });

  group('gate widget', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    Future<void> pumpGate(WidgetTester t, OrgConfig cfg) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            orgConfigProvider.overrideWith((ref) => cfg),
            // The gate now reads the hash from the public fetch first — stub it
            // so the widget test never touches the network.
            accessHashFetchProvider.overrideWith(
              (ref) => Future<String?>.value(cfg.accessPasswordHash),
            ),
          ],
          child: const MaterialApp(
            home: AccessLockGate(child: Text('APP')),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('empty hash → the child renders, no lock', (t) async {
      await pumpGate(t, const OrgConfig());
      expect(find.text('APP'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('set hash → locked until the correct password is entered',
        (t) async {
      await pumpGate(
        t,
        OrgConfig(accessPasswordHash: hashAccessPassword('secret')),
      );

      // Locked: the app is hidden behind the password prompt.
      expect(find.text('APP'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);

      // A wrong password stays locked and surfaces the error.
      await t.enterText(find.byType(TextField), 'wrong');
      await t.tap(find.text('כניסה'));
      await t.pumpAndSettle();
      expect(find.text('APP'), findsNothing);
      expect(find.text('סיסמה שגויה'), findsOneWidget);

      // The correct password unlocks the gate → the child renders.
      await t.enterText(find.byType(TextField), 'secret');
      await t.tap(find.text('כניסה'));
      await t.pumpAndSettle();
      expect(find.text('APP'), findsOneWidget);
    });
  });
}
