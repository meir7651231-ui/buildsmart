// C3.4 — the product-sheet store-comparison line (StoreComparisonLine).
//
// Proves the UI wiring WITHOUT the compile-time gate: the widget is pumped directly
// (the sheet includes it only behind `if (kStoreComparisonUi)`, folded false), with
// the repository's source overridden by a fake — so the ON path is exercised while the
// live sheet stays byte-identical. Also asserts the gate is OFF by default.

import 'dart:async';

import 'package:buildsmart/data/repositories/store_inventory.dart';
import 'package:buildsmart/data/repositories/store_repo.dart';
import 'package:buildsmart/widgets/store_comparison_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake source over the deterministic C1 inventory (118220 = אחים 38/12 · מרכז 42/3).
class _FakeSource implements StoreInventorySource {
  _FakeSource(this._inv);
  final List<InventoryItem> _inv;
  @override
  Future<List<Store>> allStores() async => kC1Stores;
  @override
  Future<List<InventoryItem>> inventoryForSku(String sku) async =>
      <InventoryItem>[for (final it in _inv) if (it.sku == sku) it];
}

/// A source whose read never completes — the widget stays in its loading state.
class _HangingSource implements StoreInventorySource {
  @override
  Future<List<Store>> allStores() => Completer<List<Store>>().future;
  @override
  Future<List<InventoryItem>> inventoryForSku(String sku) =>
      Completer<List<InventoryItem>>().future;
}

Widget _host(StoreInventorySource source) => ProviderScope(
      overrides: [
        storeInventoryRepositoryProvider
            .overrideWithValue(StoreInventoryRepository(source)),
      ],
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: StoreComparisonLine(sku: '118220')),
        ),
      ),
    );

void main() {
  testWidgets('C3.4 — renders the store-comparison line from live inventory',
      (tester) async {
    await tester.pumpWidget(_host(_FakeSource(c1Inventory())));
    await tester.pumpAndSettle();

    expect(find.text('זמין ב-2 חנויות · הזול ב-38₪ · במלאי'), findsOneWidget);
    expect(find.byKey(const Key('storeComparisonLine')), findsOneWidget);
  });

  testWidgets('C3.4 — while the comparison is loading it renders nothing',
      (tester) async {
    await tester.pumpWidget(_host(_HangingSource()));
    await tester.pump(); // one frame — still loading

    expect(find.byKey(const Key('storeComparisonLine')), findsNothing);
    // The subtree is an empty SizedBox — the sheet is unchanged until data lands.
    expect(find.byType(Row), findsNothing);
  });

  test('C3.4 — the UI gate is OFF by default (sheet is byte-identical)', () {
    expect(kStoreComparisonUi, isFalse);
  });
}
