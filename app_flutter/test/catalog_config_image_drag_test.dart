// CATALOG-CONFIG · image-drag variant swap — a VERTICAL (angle) drag on the centre
// image must swap the variant photo/name just like the HORIZONTAL (diameter) one.
//
// REGRESSION (owner: "משיכה של התמונות לא עובד"): the angle WHEEL canonical is the
// bare degree number (`45`/`90`, product_config_schema `_angleValues` reads it with
// `\d+`), but `chipValuesOf` carried the angle WITH the degree sign (`45°`/`90°`).
// So a vertical drag set the selection token to `90`, which never matched the family
// chips' `90°`, the greedy [variantByAxes] skipped angle, and the picture never
// swapped — only the diameter (horizontal) drag worked. The fix folds the angle chip
// to its degree number so both sides compare 1:1.
import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart'
    show materialOf, typeGroupOf;
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart'
    show chipValuesOf, prioritizedSchema;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#catalog-config image drag — angle token consistency', () {
    test('chipValuesOf folds the angle to the wheel canonical (no °)', () {
      // a 45° PPR elbow — its angle chip must be the bare number `45`, matching the
      // wheel token, NOT `45°` (which would never match on a drag).
      final p = resolvedCatalogProducts.firstWhere((x) => x.sku == '92117102');
      final angle = chipValuesOf(p)['angle'];
      expect(angle, isNotNull);
      expect(angle, contains('45'));
      expect(angle!.any((v) => v.contains('°')), isFalse,
          reason: 'the angle chip must carry no ° so it matches the wheel token');
    });
  });

  group('#catalog-config image drag — a drag swaps the variant', () {
    testWidgets('VERTICAL (angle) drag swaps the variant: 45° → 90°',
        (tester) async {
      final p = resolvedCatalogProducts.firstWhere((x) => x.sku == '92117102');
      final mat = materialOf(p);
      final universe = [
        for (final m in typeGroupOf(p, resolvedCatalogProducts))
          if (materialOf(m) == mat) m,
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 380,
                child: ConfigCard(
                  schema: prioritizedSchema(p, universe: universe),
                  onAddToCart: (s, sel, q) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      String name() =>
          tester.widget<Text>(find.byKey(const Key('configFullName'))).data ?? '';
      final before = name();
      expect(before, contains('45°')); // seeds on the 45° elbow

      // a vertical drag steps the ANGLE axis → the photo/name must SWAP.
      await tester.drag(find.byKey(const Key('configStage')), const Offset(0, -160));
      await tester.pumpAndSettle();
      final after = name();
      expect(after, isNot(before),
          reason: 'a vertical (angle) drag must swap the variant, not sit still');
      expect(after, contains('90°')); // angle stepped 45° → 90°
    });

    testWidgets('HORIZONTAL (diameter) drag still swaps the variant',
        (tester) async {
      final p = resolvedCatalogProducts.firstWhere((x) => x.sku == '92117102');
      final mat = materialOf(p);
      final universe = [
        for (final m in typeGroupOf(p, resolvedCatalogProducts))
          if (materialOf(m) == mat) m,
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 380,
                child: ConfigCard(
                  schema: prioritizedSchema(p, universe: universe),
                  onAddToCart: (s, sel, q) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      String name() =>
          tester.widget<Text>(find.byKey(const Key('configFullName'))).data ?? '';
      final before = name();
      await tester.drag(find.byKey(const Key('configStage')), const Offset(-160, 0));
      await tester.pumpAndSettle();
      expect(name(), isNot(before),
          reason: 'a horizontal (diameter) drag must swap the variant');
    });
  });
}
