import 'package:buildsmart/state/product_favorites.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('uid==null reads the legacy global key (byte-identical)', () async {
    SharedPreferences.setMockInitialValues({
      'bs.product-favorites.v1': ['x', 'y'],
    });
    final n = ProductFavoritesNotifier();
    await n.ready;
    expect(n.state, {'x', 'y'});
  });

  test('a scoped uid migrates the legacy global set on first load', () async {
    SharedPreferences.setMockInitialValues({
      'bs.product-favorites.v1': ['x', 'y'],
    });
    final n = ProductFavoritesNotifier('A');
    await n.ready;
    expect(n.state, {'x', 'y'},
        reason: 'first scoped load migrates the legacy global set in');
  });

  test('scoped data takes precedence over the global key', () async {
    SharedPreferences.setMockInitialValues({
      'bs.product-favorites.v1': ['global'],
      'bs.product-favorites.v1::A': ['scopedA'],
    });
    final n = ProductFavoritesNotifier('A');
    await n.ready;
    expect(n.state, {'scopedA'});
  });

  test('identity B does not see identity A favorites (no cross-tenant bleed)',
      () async {
    SharedPreferences.setMockInitialValues({
      'bs.product-favorites.v1::A': ['onlyA'],
    });
    final n = ProductFavoritesNotifier('B');
    await n.ready;
    expect(n.state, isEmpty);
  });

  test('a corrupt key does not throw (try/catch hardening)', () async {
    SharedPreferences.setMockInitialValues({
      'bs.product-favorites.v1': 'not-a-list',
    });
    final n = ProductFavoritesNotifier();
    await n.ready; // must settle without an unhandled exception
    expect(n.state, isEmpty);
  });
}
