import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 30 adversarial / edge-case regression tests across the app's logic.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  SmartCartLine cl(int q, {String k = 'lip:A'}) => SmartCartLine(
        productKey: k,
        productName: 'p',
        productEmoji: '',
        brandName: 'b',
        brandPrice: 0,
        productQty: q,
        accessories: const [],
      );

  // ─── Group A · cart stepper (6) ────────────────────────────────────────────
  group('A · cart', () {
    test('01 qtyForKey on empty cart is 0', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(smartCartProvider.notifier).qtyForKey('lip:A'), 0);
    });
    test('02 two lines same key sum', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(smartCartProvider.notifier)..add(cl(7))..add(cl(8));
      expect(n.qtyForKey('lip:A'), 15);
    });
    test('03 setQtyForKey on a new key inserts it', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(smartCartProvider.notifier).setQtyForKey(cl(3, k: 'lip:NEW'));
      expect(c.read(smartCartProvider.notifier).qtyForKey('lip:NEW'), 3);
    });
    test('04 setQtyForKey 0 removes', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(smartCartProvider.notifier)..add(cl(5));
      n.setQtyForKey(cl(0));
      expect(c.read(smartCartProvider), isEmpty);
    });
    test('05 setQtyForKey negative removes (no negative qty)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(smartCartProvider.notifier)..add(cl(5));
      n.setQtyForKey(cl(-9));
      expect(n.qtyForKey('lip:A'), 0);
    });
    test('06 setQtyForKey on one key leaves other keys intact', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(smartCartProvider.notifier)
        ..add(cl(2, k: 'lip:A'))
        ..add(cl(4, k: 'lip:B'));
      n.setQtyForKey(cl(0, k: 'lip:A'));
      expect(n.qtyForKey('lip:A'), 0);
      expect(n.qtyForKey('lip:B'), 4);
    });
  });

  // ─── Group B · notification per-type filter (8) ─────────────────────────────
  group('B · notif filter', () {
    const d = NotifSettings.defaults;
    test('07 all types on → nothing muted', () {
      expect(notifMutedSections(d), isEmpty);
    });
    test('08 orders off → {orders}', () {
      expect(notifMutedSections(d.copyWith(typeOrders: false)),
          {NotifSection.orders});
    });
    test('09 shipments off → {shipments}', () {
      expect(notifMutedSections(d.copyWith(typeShipments: false)),
          {NotifSection.shipments});
    });
    test('10 deals off → {deals}', () {
      expect(notifMutedSections(d.copyWith(typeDeals: false)),
          {NotifSection.deals});
    });
    test('11 price-drops off → {budget}', () {
      expect(notifMutedSections(d.copyWith(typePriceDrops: false)),
          {NotifSection.budget});
    });
    test('12 all four off → four sections', () {
      final m = notifMutedSections(d.copyWith(
        typeOrders: false,
        typeShipments: false,
        typeDeals: false,
        typePriceDrops: false,
      ));
      expect(m.length, 4);
    });
    test('13 safety is never muted (no toggle controls it)', () {
      final m = notifMutedSections(d.copyWith(
        typeOrders: false,
        typeShipments: false,
        typeDeals: false,
        typePriceDrops: false,
      ));
      expect(m.contains(NotifSection.safety), isFalse);
      expect(m.contains(NotifSection.all), isFalse);
    });
    test('14 unrelated toggle (sound) does not mute any section', () {
      expect(notifMutedSections(d.copyWith(soundEnabled: false)), isEmpty);
    });
  });

  // ─── Group C · chat mute / archive notifiers (5) ────────────────────────────
  group('C · chats', () {
    test('15 mute setAll stores the set', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(chatMutedIdsProvider.notifier).setAll({'t1', 't2'});
      expect(c.read(chatMutedIdsProvider), {'t1', 't2'});
    });
    test('16 mute clear empties', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(chatMutedIdsProvider.notifier)..setAll({'t1'});
      n.setAll(<String>{});
      expect(c.read(chatMutedIdsProvider), isEmpty);
    });
    test('17 archive adds the id', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(chatArchivedIdsProvider.notifier).archive('t9');
      expect(c.read(chatArchivedIdsProvider), contains('t9'));
    });
    test('18 archive twice is idempotent (set semantics)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(chatArchivedIdsProvider.notifier)
        ..archive('t9')
        ..archive('t9');
      expect(c.read(chatArchivedIdsProvider).where((e) => e == 't9').length, 1);
    });
    test('19 restore of a non-existent id is a no-op', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(chatArchivedIdsProvider.notifier)..archive('t1');
      n.restore('does-not-exist');
      expect(c.read(chatArchivedIdsProvider), {'t1'});
    });
  });

  // ─── Group D · catalog data integrity (9) ───────────────────────────────────
  group('D · catalog data', () {
    test('20 catalog is non-empty', () {
      expect(kLipskeyCatalog, isNotEmpty);
    });
    test('21 every SKU is unique', () {
      final skus = kLipskeyCatalog.map((p) => p.sku).toList();
      expect(skus.toSet().length, skus.length);
    });
    test('22 no empty product names', () {
      expect(kLipskeyCatalog.every((p) => p.nameHe.trim().isNotEmpty), isTrue);
    });
    test('23 every product has a category', () {
      expect(
          kLipskeyCatalog.every((p) => p.categoryHe.trim().isNotEmpty), isTrue);
    });
    test('24 inverted word index is built and non-empty', () {
      expect(lipskeyWordIndex(), isNotEmpty);
    });
    test('25 word index knows a common word ("ברז")', () {
      expect(lipskeyWordIndex()['ברז'], isNotNull);
      expect(lipskeyWordIndex()['ברז'], isNotEmpty);
    });
    test('26 every SKU referenced by the index exists in the catalog', () {
      final valid = kLipskeyCatalog.map((p) => p.sku).toSet();
      final referenced = lipskeyWordIndex().values.expand((e) => e).toSet();
      expect(referenced.difference(valid), isEmpty);
    });
    test('27 every uid is unique', () {
      final uids = kLipskeyCatalog.map((p) => p.uid).toList();
      expect(uids.toSet().length, uids.length);
    });
    test('28 every product sells at least "בודד"', () {
      expect(kLipskeyCatalog.every((p) => p.saleUnits.containsKey('בודד')),
          isTrue);
    });
  });

  // ─── Group E · settings model invariants (2) ────────────────────────────────
  group('E · settings models', () {
    test('29 catalog defaults are sane', () {
      const s = CatalogSettings.defaults;
      expect(s.viewMode, CatalogViewMode.list);
      expect(s.textSize, CatalogTextSize.medium);
      expect(s.highContrast, isFalse);
    });
    test('30 copyWith changes one field and preserves the rest', () {
      const s = CatalogSettings.defaults;
      final s2 = s.copyWith(highContrast: true);
      expect(s2.highContrast, isTrue);
      expect(s2.textSize, s.textSize);
      expect(s2.viewMode, s.viewMode);
    });
  });
}
