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
}
