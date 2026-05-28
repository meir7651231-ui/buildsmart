import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Executable WIRING CONTRACT — every wired button/setting added this cycle is
/// asserted here so the full `flutter test` regression enforces the contract.
/// Mirror of app_flutter/WIRING.md (keep both in sync).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  SmartCartLine line(int qty, {String key = 'lip:SKU1'}) => SmartCartLine(
        productKey: key,
        productName: 'מוצר בדיקה',
        productEmoji: '🔩',
        brandName: 'BS',
        brandPrice: 0,
        productQty: qty,
        accessories: const [],
      );

  group('CONTRACT · store grid — cart stepper', () {
    test('qtyForKey sums all lines sharing a product key', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)
        ..add(line(2))
        ..add(line(3))
        ..add(line(1, key: 'lip:OTHER'));
      expect(cart.qtyForKey('lip:SKU1'), 5);
      expect(cart.qtyForKey('lip:OTHER'), 1);
      expect(cart.qtyForKey('lip:MISSING'), 0);
    });

    test('setQtyForKey collapses a product to one line', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)
        ..add(line(2))
        ..add(line(3));
      cart.setQtyForKey(line(4));
      expect(cart.qtyForKey('lip:SKU1'), 4);
      expect(
        c
            .read(smartCartProvider)
            .where((l) => l.productKey == 'lip:SKU1')
            .length,
        1,
      );
    });

    test('setQtyForKey with qty <= 0 removes the product', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)..add(line(3));
      cart.setQtyForKey(line(0));
      expect(c.read(smartCartProvider), isEmpty);
    });
  });

  group('CONTRACT · store settings → cart defaults', () {
    test('defaultPayment (card) seeds cart payment method', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cartPaymentProvider), CartPaymentMethod.card);
    });

    test('selfPickupDefault=false keeps delivery on standard', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cartDeliveryProvider), CartDelivery.standard);
    });
  });

  group('CONTRACT · notifications — per-type filter', () {
    test('all types enabled → nothing muted', () {
      expect(notifMutedSections(NotifSettings.defaults), isEmpty);
    });

    test('disabling a type mutes its matching section', () {
      final s = NotifSettings.defaults.copyWith(
        typeOrders: false,
        typeShipments: false,
        typeDeals: false,
        typePriceDrops: false,
      );
      expect(
        notifMutedSections(s),
        {
          NotifSection.orders,
          NotifSection.shipments,
          NotifSection.deals,
          NotifSection.budget,
        },
      );
    });
  });

  group('CONTRACT · chats — mute / archive', () {
    test('mute-all sets every thread; clearing unmutes', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final muted = c.read(chatMutedIdsProvider.notifier);
      muted.setAll({'t1', 't2', 't3'});
      expect(c.read(chatMutedIdsProvider), {'t1', 't2', 't3'});
      muted.setAll(<String>{});
      expect(c.read(chatMutedIdsProvider), isEmpty);
    });

    test('archive adds, restore removes', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final arch = c.read(chatArchivedIdsProvider.notifier)..archive('t1');
      expect(c.read(chatArchivedIdsProvider), contains('t1'));
      arch.restore('t1');
      expect(c.read(chatArchivedIdsProvider), isNot(contains('t1')));
    });
  });

  group('CONTRACT · catalog מאתר finder — grouping (finder_screen.dart)', () {
    final named = kFinderGroups.where((g) => g.cats.isNotEmpty).toList();

    test('named groups are pairwise disjoint (no category in two groups)', () {
      final owner = <String, String>{};
      for (final g in named) {
        for (final c in g.cats) {
          expect(owner.containsKey(c), isFalse,
              reason: 'category "$c" claimed by "${owner[c]}" and "${g.label}"');
          owner[c] = g.label;
        }
      }
    });

    test('an אחר catch-all exists and no product has a blank category', () {
      expect(kFinderGroups.any((g) => g.cats.isEmpty), isTrue);
      for (final p in kLipskeyCatalog) {
        expect(p.categoryHe.trim(), isNotEmpty);
      }
    });

    test('curated sub-types cover every group category that has products', () {
      for (final entry in kFinderSubs.entries) {
        final group = named.firstWhere((g) => g.label == entry.key);
        final covered = {for (final s in entry.value) ...s.cats};
        final withProducts = group.cats
            .where((c) => kLipskeyCatalog.any((p) => p.categoryHe == c))
            .toSet();
        expect(withProducts.difference(covered), isEmpty,
            reason: 'group "${entry.key}" curated subs miss: '
                '${withProducts.difference(covered)}');
      }
    });

    test('curated sub labels are unique (guards the "ברזים ברזים" bug)', () {
      for (final entry in kFinderSubs.entries) {
        final labels = [for (final s in entry.value) s.label];
        expect(labels.toSet().length, labels.length,
            reason: 'group "${entry.key}" has duplicate sub labels');
      }
    });

    test('curated sub categories belong to their group', () {
      for (final entry in kFinderSubs.entries) {
        final group = named.firstWhere((g) => g.label == entry.key);
        for (final s in entry.value) {
          for (final c in s.cats) {
            expect(group.cats.contains(c), isTrue,
                reason: '"$c" in sub "${s.label}" is not in group "${entry.key}"');
          }
        }
      }
    });
  });

  group('CONTRACT · forgiving product search (catalogProductMatchesQuery)', () {
    test('a category word finds products in that category', () {
      final p = kLipskeyCatalog.firstWhere((p) => p.categoryHe == 'ברזי מטבח');
      expect(catalogProductMatchesQuery(p, 'מטבח'), isTrue);
    });

    test('everyday synonym maps to the catalogue term (שירותים → אסלה)', () {
      // Pick an actual toilet fixture (a seat), not the first substring match:
      // the first 'אסלה' product is a branch CONNECTOR, which the precision
      // contract below intentionally excludes from 'שירותים'.
      final p =
          kLipskeyCatalog.firstWhere((p) => p.categoryHe == 'מושבי אסלה');
      expect(catalogProductMatchesQuery(p, 'שירותים'), isTrue);
    });

    test('requireAll=false is a graceful superset of requireAll=true', () {
      final p = kLipskeyCatalog.firstWhere((p) => p.categoryHe == 'ברזי מטבח');
      expect(catalogProductMatchesQuery(p, 'מטבח זזזזז'), isFalse);
      expect(catalogProductMatchesQuery(p, 'מטבח זזזזז', requireAll: false),
          isTrue);
    });

    test('colour is searchable', () {
      final p = kLipskeyCatalog.firstWhere((p) => (p.color ?? '').isNotEmpty);
      expect(catalogProductMatchesQuery(p, p.color!), isTrue);
    });

    test('שירותים is precise — does not match toilet-branch connectors', () {
      final connector =
          kLipskeyCatalog.firstWhere((p) => p.categoryHe == 'מסעפים וחיבורי אסלה');
      expect(catalogProductMatchesQuery(connector, 'שירותים'), isFalse);
      final seat = kLipskeyCatalog.firstWhere((p) => p.categoryHe == 'מושבי אסלה');
      expect(catalogProductMatchesQuery(seat, 'שירותים'), isTrue);
    });

    test('relevance ranks a name match above a synonym match', () {
      final seat = kLipskeyCatalog.firstWhere((p) => p.nameHe.contains('מושב'));
      expect(searchRelevance(seat, 'מושב'),
          greaterThan(searchRelevance(seat, 'שירותים')));
    });
  });
}
