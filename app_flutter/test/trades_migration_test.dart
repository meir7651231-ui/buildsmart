// Pins the Pillar-2 store migration (step 34 · R1 #18): a REAL upgrade path, not a
// symbolic no-op. An UNVERSIONED (v0/legacy) persisted doc is stamped to the current
// schema on load, with its data preserved; a current-version doc passes through
// unchanged. Future versions add an `if (from < N)` branch that this test guards.
import 'dart:convert';

import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an unversioned (v0) doc migrates to v1, preserving data', () async {
    // A legacy doc with NO schemaVersion + one authored trade.
    final legacy = jsonEncode({
      'trades': [
        {
          'id': 't1',
          'nameHe': 'אינסטלציה',
          'emoji': '🔧',
          'color': 1,
          'personaId': 'p',
        },
      ],
    });
    SharedPreferences.setMockInitialValues({'bs.trades.v1': legacy});

    final n = TradesStoreNotifier();
    await _settle(); // _load → migrate → fromJson

    expect(n.state.schemaVersion, kTradesDocVersion); // stamped to current
    expect(n.state.trades.single.id, 't1'); // data preserved through migration
  });

  test('migrate is identity for a current-version doc', () {
    final cur = {'schemaVersion': kTradesDocVersion, 'trades': <dynamic>[]};
    expect(TradesStoreNotifier.migrate(cur)['schemaVersion'], kTradesDocVersion);
  });

  group('schemaVersion is parsed tolerantly (no throws)', () {
    // A minimal valid shape: one authored trade, version as the STRING "1".
    Map<String, dynamic> minimal(Object version) => {
          'schemaVersion': version,
          'trades': [
            {
              'id': 't1',
              'nameHe': 'אינסטלציה',
              'emoji': '🔧',
              'color': 1,
              'personaId': 'p',
            },
          ],
        };

    test('a String "1" is tolerated → migrate + fromJson yield v1', () {
      final persisted = minimal('1');
      // Neither step throws on the String version…
      final migrated = TradesStoreNotifier.migrate(persisted);
      final doc = TradesDoc.fromJson(migrated);
      // …and the String "1" coerces to the int 1.
      expect(doc.schemaVersion, 1);
      expect(doc.trades.single.id, 't1'); // data preserved
    });

    test('a non-numeric String falls back to the current version', () {
      final persisted = minimal('abc');
      // fromJson on its own must not throw — it falls back to the current version.
      final docDirect = TradesDoc.fromJson(persisted);
      expect(docDirect.schemaVersion, kTradesDocVersion);
      // migrate also tolerates the garbage version and stamps it to v1.
      final migrated = TradesStoreNotifier.migrate(persisted);
      expect(migrated['schemaVersion'], 1);
      expect(TradesDoc.fromJson(migrated).schemaVersion, 1);
    });
  });
}
