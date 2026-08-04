// CATALOG-CONFIG · phase E cart test — the config card's 'הוסף לסל' hands
// (schema, selection, qty) to its onAddToCart, and the [SmartCartLine] the dive
// screen builds from that CARRIES the chosen configuration (plan E.1 "הקונפיג
// נשמר בשורה"). There is NO price field in the catalog, so the price is the
// owner-decided stub (0 · 'לפי ספק'). Also pins the byte-identical-off contract:
// an EMPTY-selection line encodes with NO `selection` key (legacy-identical).
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§ פאזה E).

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AttributeDef _attr(
  String id,
  String nameHe,
  AttributeKind kind,
  List<String> labels,
) =>
    AttributeDef(
      id: id,
      tradeId: 'catalog',
      nameHe: nameHe,
      emoji: '📐',
      kind: kind,
      values: [
        for (var i = 0; i < labels.length; i++)
          AttributeValue(
            id: '$id-$i',
            labelHe: labels[i],
            canonical: labels[i],
            sortIndex: i,
          ),
      ],
    );

ProductConfigSchema _elbow() => ProductConfigSchema(
      sku: 'E-1',
      nameHe: 'ברך',
      familyId: 'ברך 90°',
      emoji: '🦵',
      attributes: [
        _attr('angle', 'זווית', AttributeKind.choice, const ['45°', '90°']),
        _attr('diameter', 'קוטר', AttributeKind.dimension, const ['20', '25', '32']),
        _attr('length', 'אורך', AttributeKind.choice,
            const ['קצר', 'בינוני', 'ארוך']),
      ],
    );

/// The default selection the card seeds for [_elbow] — each attr's sortIndex==0
/// value, stored as its canonical token.
const Map<String, String> _elbowDefault = {
  'angle': '45°',
  'diameter': '20',
  'length': 'קצר',
};

void main() {
  group('#catalog-config phase E — הוסף-לסל carries the config', () {
    testWidgets('tapping הוסף לסל fires onAddToCart with schema+selection+qty',
        (tester) async {
      final schema = _elbow();
      ProductConfigSchema? seenSchema;
      Map<String, String>? seenSelection;
      int? seenQty;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ConfigCard(
                schema: schema,
                onAddToCart: (s, selection, qty) {
                  seenSchema = s;
                  seenSelection = selection;
                  seenQty = qty;
                },
              ),
            ),
          ),
        ),
      );

      // Raise qty to 3 so a non-default value flows through the callback too.
      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('הוסף לסל'));
      await tester.pump();

      expect(seenSchema, same(schema));
      expect(seenQty, 3);
      // The default selection (angle 45° · diameter 20 · length קצר) is handed
      // through verbatim — keyed by AttributeDef.id, valued by canonical token.
      expect(seenSelection, _elbowDefault);
      expect(seenSelection!['angle'], '45°');
    });

    test('a SmartCartLine built from the card payload carries the selection', () {
      // The EXACT mapping the dive screen applies inside onAddToCart.
      final schema = _elbow();
      const selection = _elbowDefault;
      final line = SmartCartLine(
        productKey: 'lip:${schema.sku}',
        productName: schema.nameHe,
        productEmoji: schema.emoji,
        brandName: '',
        brandPrice: 0,
        productQty: 3,
        accessories: const [],
        selection: selection,
      );

      expect(line.productKey, 'lip:E-1');
      expect(line.productName, 'ברך');
      expect(line.brandPrice, 0); // price stub — no catalog price (owner decision)
      expect(line.selection, selection);
      expect(line.selection['angle'], '45°');
      // and the config survives a persistence round-trip.
      expect(SmartCartLine.fromJson(line.toJson()).selection, selection);
    });

    test('an EMPTY-selection line is JSON byte-identical (no selection key)', () {
      const line = SmartCartLine(
        productKey: 'lip:P-9',
        productName: 'צינור',
        productEmoji: '🔧',
        brandName: '',
        brandPrice: 0,
        productQty: 1,
        accessories: [],
      );
      final json = line.toJson();
      expect(json.containsKey('selection'), isFalse); // legacy-identical payload
      // a qty change must carry the (empty) selection without adding the key.
      expect(SmartCartLine.fromJson(json).selection, isEmpty);
    });
  });
}
