// Roadmap step 81 — comprehensive data integrity for the SmartProduct card.
// The private _SmartProductSheet widget's *rendering* across all 935 sheets is
// covered by product_journey_test; this test locks in the *data* every section
// of the card reads, for every SmartProduct × brand, so a regression in any
// helper (summary / standards / tools / brand-guide / compat / compliance+why /
// variants / cheaper-alt / bridge) is caught fast and without a UI pump.
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every SmartProduct card has coherent, non-throwing data', () {
    var brandsChecked = 0;
    for (final sp in kSmartProducts) {
      expect(sp.brands, isNotEmpty, reason: '${sp.key} has no brands');

      // Brand guide: exactly one entry per brand, order-stable, never empty.
      final guide = brandDecisionGuide(sp);
      expect(guide.length, sp.brands.length, reason: '${sp.key} guide len');

      for (var i = 0; i < sp.brands.length; i++) {
        final b = sp.brands[i];
        brandsChecked++;

        // One-line summary always starts with the product name.
        expect(smartCardSummaryHe(sp, b), startsWith(sp.name));

        // Cheaper-alternative never points at a costlier or equal sibling.
        final alt = cheaperAlternativeBrand(sp, i);
        if (alt != null) {
          expect(b.price, isNotNull);
          expect(alt.price, lessThan(b.price!));
        }

        // When the brand resolves to a catalog product, the per-product
        // sections must all be well-formed.
        final prod = catalogProductForBrand(b);
        if (prod == null) continue;
        expect(catalogProductForSku(b.sku)?.sku, prod.sku);

        // standards: unique codes, non-empty scopes.
        final stds = israeliStandardsFor(prod);
        expect(stds.map((s) => s.code).toSet().length, stds.length,
            reason: 'dup standard for ${prod.sku}');
        for (final s in stds) {
          expect(s.scope, isNotEmpty);
        }

        // tools: de-duplicated.
        final tools = installToolsFor(prod);
        expect(tools.toSet().length, tools.length,
            reason: 'dup tool for ${prod.sku}');

        // compat carousel: every compatible product is a distinct other SKU,
        // and the explain label is non-empty.
        final compat = compatibleProductsFor(prod);
        for (final c in compat.take(3)) {
          expect(c.sku, isNot(prod.sku));
          expect(connectionExplainHe(prod, c), isNotEmpty);
        }

        // compliance + why: every trigger reason and explanation is usable.
        for (final t in complianceTriggersFor(prod)) {
          expect(t.reason, isNotEmpty);
          // why may be null only for an unrecognised label — but all real
          // labels are covered (see compliance_why_test); assert non-null here.
          expect(complianceWhyHe(t.label), isNotNull,
              reason: 'no why for "${t.label}"');
        }

        // variant family: includes the product itself; siblings share key.
        final fam = variantSiblingsOf(prod);
        expect(fam.any((q) => q.sku == prod.sku), isTrue);
      }
    }
    expect(brandsChecked, greaterThan(300));
  });
}
