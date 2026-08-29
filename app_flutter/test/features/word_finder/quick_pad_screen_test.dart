// QuickPadScreen — BEHAVIORAL widget test for the flag-gated quick re-order
// pad (the DIVERSE-LIST "ערב-רב" mode).
//
// NOT a pixel/golden test (fonts are brittle): every assertion is on widget
// presence, a known pick label, or the cart notifier's reached state. Two
// cases:
//
//   Test 1 (gated OFF): with `kWordFinderFlag` NOT seeded, the screen is a
//     zero-height shrink → no QuickPadKeyboard mounts.
//
//   Test 2 (flag ON, with favorites): we seed `kWordFinderFlag` on AND
//     override `productFavoritesProvider` with 3 REAL `kDivePool` skus (taken
//     live from the pool, NOT hard-coded — so the test can't drift when the
//     catalog changes). We assert the keyboard mounts and that a KNOWN pick
//     label (computed live via the engine's `quickPicks` + `quickLabel`)
//     renders. Then we drive the keyboard exactly like
//     `quick_pad_keyboard_test.dart`: tap '+' once on the first item's cell
//     (qty 1 → 2) then tap that item's label key (the add affordance). We
//     assert the cart notifier received ONE line for that product with
//     productQty == 2.
//
// CART SPY: rather than supply the real cart's full plumbing, we override
// `smartCartProvider` with a plain `SmartCartNotifier` (its `add` simply
// appends a `SmartCartLine` to its `List<SmartCartLine>` state) and read that
// state back via the ProviderContainer — so the assertion is on the REAL line
// the screen built (productKey/productName/productQty), exactly as it would in
// production.
//
// Flag wiring mirrors `word_finder_screen_test.dart`: seed the flag via
// `SharedPreferences.setMockInitialValues({'bs.feature-flags.v1': [...]})` and
// `pumpAndSettle()` so the FeatureFlagsNotifier's async `_load()` resolves
// before we read the gate.

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart';
import 'package:buildsmart/features/word_finder/quick_pad_keyboard.dart';
import 'package:buildsmart/features/word_finder/quick_pad_screen.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A favorites notifier pre-seeded with `skus` — used to override
/// `productFavoritesProvider` so the pad has deterministic picks without
/// touching SharedPreferences ordering.
class _SeededFavorites extends ProductFavoritesNotifier {
  _SeededFavorites(Set<String> skus) {
    state = skus;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gated OFF → no QuickPadKeyboard (screen is shrink)',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // flag NOT set

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickPadScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(QuickPadKeyboard), findsNothing,
        reason: 'with kWordFinderFlag off the screen must render nothing');
  });

  testWidgets('flag ON + favorites: pad renders and a tap adds qty-2 to cart',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag], // flag ON
    });

    // Take 3 REAL skus straight from the pool (data-driven, drift-proof).
    final favList = kDivePool.take(3).map((p) => p.sku).toList();
    final favSet = favList.toSet();
    expect(favSet.length, greaterThanOrEqualTo(2),
        reason: 'need >=2 distinct real skus to exercise the pad');

    // Compute the EXPECTED picks/labels exactly as the screen will (favorites
    // only here → no recents/frequents). The keyboard renders these labels.
    final expectedPicks = quickPicks(favSkus: favSet);
    expect(expectedPicks, isNotEmpty,
        reason: 'seeded favorites must yield at least one quick pick');

    // The product we will tap-add. `quickLabel` can collide (two products may
    // share a short label), which would make a `find.text(label)` cell scope
    // ambiguous — so pick a UNIQUELY-labeled pick when one exists, else fall
    // back to the first (the cart assertion still pins the exact product+qty).
    final labelCounts = <String, int>{};
    for (final p in expectedPicks) {
      labelCounts[p.label] = (labelCounts[p.label] ?? 0) + 1;
    }
    final firstPick = expectedPicks.firstWhere(
      (p) => labelCounts[p.label] == 1,
      orElse: () => expectedPicks.first,
    );
    final firstProduct = firstPick.product;
    final firstLabel = firstPick.label;

    // A spy cart we can read back. The override returns a plain
    // SmartCartNotifier whose `add` appends to its state list.
    final container = ProviderContainer(
      overrides: [
        productFavoritesProvider
            .overrideWith((ref) => _SeededFavorites(favSet)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QuickPadScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // ASSERT: the keyboard mounts and a KNOWN pick label is shown.
    expect(find.byType(QuickPadKeyboard), findsOneWidget,
        reason: 'flag on + favorites → the quick pad keyboard mounts');
    expect(find.text(firstLabel), findsWidgets,
        reason: 'a known pick label must render on a key');

    // Cart starts empty.
    expect(container.read(smartCartProvider), isEmpty,
        reason: 'no line added before any tap');

    // Scope the stepper to the FIRST item's cell (the Column containing its
    // label), exactly like quick_pad_keyboard_test.dart, so we step the right
    // item's qty.
    final firstCell = find.ancestor(
      of: find.text(firstLabel).first,
      matching: find.byType(Column),
    );
    final plusInFirstCell = find.descendant(
      of: firstCell.first,
      matching: find.text('+'),
    );

    // Default qty is 1.
    expect(
      find.descendant(of: firstCell.first, matching: find.text('1')),
      findsOneWidget,
      reason: 'each item starts at quantity 1',
    );

    // Tap '+' once → qty becomes 2.
    await tester.tap(plusInFirstCell.first);
    await tester.pump();
    expect(
      find.descendant(of: firstCell.first, matching: find.text('2')),
      findsOneWidget,
      reason: 'one + tap raises the first item to quantity 2',
    );

    // Tap the product label (the add affordance) → screen adds the line.
    await tester.tap(find.text(firstLabel).first);
    await tester.pump();

    // ASSERT: the cart notifier received exactly ONE line, for the tapped
    // product, with the stepped quantity (2) and the canonical productKey the
    // product-sheet path uses ('lip:<sku>').
    final lines = container.read(smartCartProvider);
    expect(lines, hasLength(1), reason: 'exactly one line added by the tap');
    final line = lines.single;
    expect(line.productKey, 'lip:${firstProduct.sku}',
        reason: 'the line carries the canonical lip:<sku> key');
    expect(line.productName, firstProduct.nameHe,
        reason: 'the line names the tapped product');
    expect(line.productQty, 2,
        reason: 'the line carries the stepped quantity (1 default + 1 tap)');
  });
}
