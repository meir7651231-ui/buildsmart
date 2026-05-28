import 'dart:convert';

import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deep persistence coverage: every store we moved to SharedPreferences must
/// (a) WRITE its key on change and (b) LOAD it back into a fresh provider
/// container — i.e. survive an app restart. Tested in both directions with a
/// mock prefs store, no UI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Let the notifiers' async _load/_persist microtasks settle.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 60));

  const sampleLine = SmartCartLine(
    productKey: 'lip:demo',
    productName: 'מוצר בדיקה',
    productEmoji: '📦',
    brandName: 'ספק',
    brandPrice: 120,
    productQty: 4,
    accessories: [SmartCartAcc(name: 'אום', emoji: '🔩', price: 15, qty: 3)],
  );

  group('smart cart persistence', () {
    test('WRITE — adding a line persists the JSON payload', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(smartCartProvider.notifier).add(sampleLine);
      await settle();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bs.smart-cart.v1');
      expect(raw, isNotNull);
      final decoded = (jsonDecode(raw!) as List)
          .map((e) => SmartCartLine.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(decoded.length, 1);
      expect(decoded.first.productKey, 'lip:demo');
      expect(decoded.first.productQty, 4);
      expect(decoded.first.total, 120 * 4 + 15 * 3); // 525
      expect(decoded.first.accessories.single.name, 'אום');
    });

    test('LOAD — a fresh container restores the saved cart', () async {
      SharedPreferences.setMockInitialValues({
        'bs.smart-cart.v1': jsonEncode([sampleLine.toJson()]),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(smartCartProvider.notifier); // triggers _load
      await settle();

      final lines = c.read(smartCartProvider);
      expect(lines.length, 1);
      expect(lines.first.productName, 'מוצר בדיקה');
      expect(lines.first.total, 525);
    });

    test('clear() empties both state and storage', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(smartCartProvider.notifier).add(sampleLine);
      await settle();
      c.read(smartCartProvider.notifier).clear();
      await settle();
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('bs.smart-cart.v1')!), isEmpty);
    });
  });

  group('store favorites persistence', () {
    test('WRITE — toggle persists the set', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(storeFavoritesProvider.notifier).toggle('הסל שלי');
      c.read(storeFavoritesProvider.notifier).toggle('ההזמנות שלי');
      await settle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('bs.store-favorites.v1')!.toSet(),
          {'הסל שלי', 'ההזמנות שלי'});
    });

    test('toggle is idempotent on/off', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(storeFavoritesProvider.notifier);
      n.toggle('x');
      expect(c.read(storeFavoritesProvider), {'x'});
      n.toggle('x');
      expect(c.read(storeFavoritesProvider), isEmpty);
    });

    test('LOAD — a fresh container restores favorites', () async {
      SharedPreferences.setMockInitialValues({
        'bs.store-favorites.v1': ['פקדונות', 'מכרז ספקים'],
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(storeFavoritesProvider.notifier);
      await settle();
      expect(c.read(storeFavoritesProvider), {'פקדונות', 'מכרז ספקים'});
    });
  });

  group('notification read/dismissed persistence', () {
    test('WRITE — read ids persist', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(notifReadIdsProvider.notifier).add('n1');
      c.read(notifReadIdsProvider.notifier).add('n2');
      await settle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('bs.notif-read.v1')!.toSet(), {'n1', 'n2'});
    });

    test('LOAD — read + dismissed restore into fresh containers', () async {
      SharedPreferences.setMockInitialValues({
        'bs.notif-read.v1': ['r1', 'r2'],
        'bs.notif-dismissed.v1': ['d1'],
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(notifReadIdsProvider.notifier);
      c.read(notifDismissedIdsProvider.notifier);
      await settle();
      expect(c.read(notifReadIdsProvider), {'r1', 'r2'});
      expect(c.read(notifDismissedIdsProvider), {'d1'});
    });

    test('remove() drops one id and persists', () async {
      SharedPreferences.setMockInitialValues({
        'bs.notif-dismissed.v1': ['a', 'b', 'c'],
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(notifDismissedIdsProvider.notifier);
      await settle();
      c.read(notifDismissedIdsProvider.notifier).remove('b');
      await settle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('bs.notif-dismissed.v1')!.toSet(), {'a', 'c'});
    });
  });
}
