// CATALOG-CONFIG · dive-bs2b — the CARD → SHEET bridge. The centre image is now
// TAPPABLE: a tap fires [ConfigCard.onOpenDetails] with the LIVE (schema, selection,
// qty) so the host can open the INTERNAL product sheet for the currently-selected
// variant. A null [onOpenDetails] leaves the image INERT — no tap handler (drags
// unaffected). Assertions check the CONTRACT (what the callback receives), never
// pixels. Mirrors the harness of test/catalog_config_card_test.dart. SSOT:
// knowledge/CATALOG-CONFIG-PLAN.md (§B).

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
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

// The SAME positional elbow the sibling card test uses: attr[0]=diameter (🔩 right)
// · attr[1]=angle (↕) · attr[2]=length (↔). A BOGUS familyId keeps the centre
// deterministic (no live-catalog variant matches → the emoji fallback shows, and no
// network Image is fetched on a single pump).
ProductConfigSchema _elbow() => ProductConfigSchema(
      sku: 'E-1',
      nameHe: 'ברך',
      familyId: 'בדיקה',
      emoji: '🦵',
      attributes: [
        _attr('diameter', 'קוטר', AttributeKind.dimension,
            const ['20', '25', '32', '40', '50']),
        _attr('angle', 'זווית', AttributeKind.choice, const ['45°', '90°']),
        _attr('length', 'אורך', AttributeKind.choice,
            const ['קצר', 'בינוני', 'ארוך']),
      ],
    );

Widget _host(Widget card) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: card)),
    );

Finder _key(String k) => find.byKey(Key(k));

void main() {
  group('#catalog-config ConfigCard — image tap → onOpenDetails (internal sheet)', () {
    testWidgets(
        'tapping the centre image fires onOpenDetails with the seeded selection',
        (tester) async {
      final schema = _elbow();
      ProductConfigSchema? seenSchema;
      Map<String, String>? seenSelection;
      int? seenQty;
      var taps = 0;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: schema,
            onOpenDetails: (s, selection, qty) {
              taps++;
              seenSchema = s;
              seenSelection = selection;
              seenQty = qty;
            },
          ),
        ),
      );

      await tester.tap(_key('configImageCenter'));
      await tester.pump();

      // fired once, with the SAME schema instance + the seeded defaults
      // (sortIndex-0 of each axis) + the default qty.
      expect(taps, 1);
      expect(seenSchema, same(schema));
      expect(seenSelection, isNotNull);
      expect(seenSelection!['diameter'], '20');
      expect(seenSelection!['angle'], '45°');
      expect(seenSelection!['length'], 'קצר');
      expect(seenQty, 1);
    });

    testWidgets(
        'the tap carries the CURRENT variant (after a wheel + qty change)',
        (tester) async {
      Map<String, String>? seenSelection;
      int? seenQty;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: _elbow(),
            onOpenDetails: (s, selection, qty) {
              seenSelection = selection;
              seenQty = qty;
            },
          ),
        ),
      );

      await tester.tap(find.text('40')); // a non-default diameter
      await tester.pump();
      await tester.tap(find.text('3')); // qty 3
      await tester.pump();
      await tester.tap(_key('configImageCenter'));
      await tester.pump();

      // the LIVE picks flow through — not the seeded defaults.
      expect(seenSelection!['diameter'], '40');
      expect(seenSelection!['angle'], '45°'); // untouched default
      expect(seenSelection!['length'], 'קצר'); // untouched default
      expect(seenQty, 3);
    });

    testWidgets('onOpenDetails: null ⇒ the image tap is INERT (no throw)',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _elbow())));

      // no handler wired → tapping the image does nothing and never throws.
      await tester.tap(_key('configImageCenter'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(_key('configImageCenter'), findsOneWidget); // still rendered
    });
  });
}
