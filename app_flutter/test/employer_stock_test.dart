// Builder E1b (Wave E1) · test for the worker's READ-ONLY view of the
// employer (contractor) stock — lib/state/employer_stock.dart.
//
// The frozen contract (Builder E1a owns the impl):
//   employerStockProvider(String employerId) → List<EmployerStockItem>
//     • empty employerId        → const [] (the worker has no employer link;
//                                  honest gap, no fabrication);
//     • any non-empty employerId → the ONE device contractor's live stock
//                                  (`stockProvider`, a Map<String,String>
//                                  name → 'warehouse'|'site') mapped to
//                                  read-only EmployerStockItem(name, location),
//                                  warehouse-first then by name.
// The employerId is a SERVER-SWAP key, not a local selector: on the single
// device demo every non-empty id resolves to the same one contractor's stock
// (mirrors employer_link_test.dart's "id-agnostic" assertion).
//
// Firebase-free: stockProvider sources its seed through stockRepositoryProvider,
// which yields the const-backed LocalStockRepository when Firebase is not
// initialised (the whole test suite), so no Firestore is touched.
import 'package:buildsmart/data/phaseb_seeds.dart' show kStockDemo;
import 'package:buildsmart/screens/stock_screen.dart'
    show stockProvider, StockNotifier;
import 'package:buildsmart/state/employer_stock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A small, known contractor stock the resolution/sort/read-only cases seed
/// `stockProvider` with — deterministic and independent of the 11-row
/// `kStockDemo`. Intentionally out of warehouse-first/name order so the sort is
/// actually exercised.
const _seedStock = <String, String>{
  'מברגה': 'site', // site comes first alphabetically by name, but...
  'ברגים': 'warehouse', // ...warehouse must sort ahead of any site row,
  'אטם': 'warehouse', // and within warehouse, 'אטם' < 'ברגים' by name.
};

/// Override `stockProvider` with a fixed seed so the test owns the contractor's
/// stock exactly (no reliance on the demo seed for the precise assertions).
Override _withStock(Map<String, String> seed) =>
    stockProvider.overrideWith((ref) => StockNotifier(seed));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('employerStockProvider', () {
    test('empty employerId → const [] (no link, honest gap, no fabrication)',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(employerStockProvider(''));

      expect(items, isEmpty);
    });

    test(
        'non-empty employerId → the contractor stock as read-only '
        'EmployerStockItems (name + location), warehouse-first then name', () {
      final container = ProviderContainer(overrides: [_withStock(_seedStock)]);
      addTearDown(container.dispose);

      final items = container.read(employerStockProvider('contractor-demo'));

      // Every seeded row is projected (no rows dropped/added).
      expect(items.length, _seedStock.length);

      // name + location are carried verbatim from the contractor's Map.
      final byName = {for (final i in items) i.name: i.location};
      expect(byName, {
        'אטם': 'warehouse',
        'ברגים': 'warehouse',
        'מברגה': 'site',
      });

      // Order: warehouse rows first, then site; within a group, by name.
      expect(items.map((i) => i.name).toList(),
          ['אטם', 'ברגים', 'מברגה']);
      expect(items.map((i) => i.location).toList(),
          ['warehouse', 'warehouse', 'site']);
    });

    test(
        'the employerId is a server-swap key, not a local selector — any '
        'non-empty id resolves to the SAME one device contractor stock', () {
      final container = ProviderContainer(overrides: [_withStock(_seedStock)]);
      addTearDown(container.dispose);

      final a = container.read(employerStockProvider('contractor-demo'));
      final b = container.read(employerStockProvider('some-other-id'));

      // Both ids land on the one device contractor's stock (one per device).
      expect(b.length, a.length);
      expect(b.map((i) => i.name).toList(), a.map((i) => i.name).toList());
      expect(b.map((i) => i.location).toList(),
          a.map((i) => i.location).toList());
    });

    test(
        'resolves the REAL device seed (kStockDemo) without an override — '
        'every live stock row surfaces read-only with its true location', () {
      // No override: stockProvider seeds from kStockDemo via the const-backed
      // LocalStockRepository (Firebase-free), i.e. the actual contractor stock.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(employerStockProvider('contractor-demo'));

      // Same rows as the live contractor Map — none invented, none lost.
      expect(items.length, kStockDemo.length);
      expect(
        {for (final i in items) i.name: i.location},
        kStockDemo,
      );

      // Warehouse-first ordering holds end-to-end against the real seed: once a
      // 'site' row appears, no 'warehouse' row may follow it.
      var seenSite = false;
      for (final i in items) {
        if (i.location == 'site') {
          seenSite = true;
        } else {
          expect(seenSite, isFalse,
              reason: 'a warehouse row must not follow a site row');
        }
      }
    });
  });
}
