import 'package:buildsmart/state/saved_configs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('uid==null reads the legacy global key (byte-identical)', () async {
    SharedPreferences.setMockInitialValues({
      'bs.saved-configs.v1': ['p1#brandA', 'p2#brandB'],
    });
    final n = SavedConfigsNotifier();
    await n.ready;
    expect(n.state, {'p1#brandA', 'p2#brandB'});
    expect(n.isSaved('p1', 'brandA'), isTrue);
  });

  test('a scoped uid migrates the legacy global set on first load', () async {
    SharedPreferences.setMockInitialValues({
      'bs.saved-configs.v1': ['p1#brandA', 'p2#brandB'],
    });
    final n = SavedConfigsNotifier('A');
    await n.ready;
    expect(n.state, {'p1#brandA', 'p2#brandB'},
        reason: 'first scoped load migrates the legacy global set in');
  });

  test('scoped data takes precedence over the global key', () async {
    SharedPreferences.setMockInitialValues({
      'bs.saved-configs.v1': ['globalP#globalBrand'],
      'bs.saved-configs.v1::A': ['scopedP#scopedBrand'],
    });
    final n = SavedConfigsNotifier('A');
    await n.ready;
    expect(n.state, {'scopedP#scopedBrand'});
    expect(n.isSaved('globalP', 'globalBrand'), isFalse);
  });

  test('identity B does not see identity A saved configs (no cross-tenant bleed)',
      () async {
    SharedPreferences.setMockInitialValues({
      'bs.saved-configs.v1::A': ['onlyA#brandA'],
    });
    final n = SavedConfigsNotifier('B');
    await n.ready;
    expect(n.state, isEmpty);
  });

  test('a corrupt key does not throw (try/catch hardening)', () async {
    SharedPreferences.setMockInitialValues({
      'bs.saved-configs.v1': 'not-a-list',
    });
    final n = SavedConfigsNotifier();
    await n.ready; // must settle without an unhandled exception
    expect(n.state, isEmpty);
  });
}
