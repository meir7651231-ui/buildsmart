import 'package:buildsmart/state/recently_viewed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('uid==null reads the legacy global key (byte-identical)', () async {
    SharedPreferences.setMockInitialValues({
      'bs.recently-viewed.v1': ['x', 'y'],
    });
    final n = RecentlyViewedNotifier();
    await n.ready;
    expect(n.state, ['x', 'y']);
  });

  test('a scoped uid migrates the legacy global list on first load', () async {
    SharedPreferences.setMockInitialValues({
      'bs.recently-viewed.v1': ['x', 'y'],
    });
    final n = RecentlyViewedNotifier('A');
    await n.ready;
    expect(n.state, ['x', 'y'],
        reason: 'first scoped load migrates the legacy global list in');
  });

  test('scoped data takes precedence over the global key', () async {
    SharedPreferences.setMockInitialValues({
      'bs.recently-viewed.v1': ['global'],
      'bs.recently-viewed.v1::A': ['scopedA'],
    });
    final n = RecentlyViewedNotifier('A');
    await n.ready;
    expect(n.state, ['scopedA']);
  });

  test('identity B does not see identity A history (no cross-tenant bleed)',
      () async {
    SharedPreferences.setMockInitialValues({
      'bs.recently-viewed.v1::A': ['onlyA'],
    });
    final n = RecentlyViewedNotifier('B');
    await n.ready;
    expect(n.state, isEmpty);
  });

  test('a corrupt key does not throw (try/catch hardening)', () async {
    SharedPreferences.setMockInitialValues({
      'bs.recently-viewed.v1': 'not-a-list',
    });
    final n = RecentlyViewedNotifier();
    await n.ready; // must settle without an unhandled exception
    expect(n.state, isEmpty);
  });
}
