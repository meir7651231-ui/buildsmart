// CATALOG-CONFIG · dive-bs2b card test — the GENERIC [ConfigCard] renders ANY
// engine [ProductConfigSchema] as the APPROVED dive-bs2b: the product IMAGE is the
// centre HERO (key 'configImageCenter'), never empty (emoji fallback); the first
// two non-diameter attributes are the ↕ / ↔ axes SCROLLED ON THE IMAGE (four edge
// labels · a ↕/↔ drag cycles them); the diameter attribute(s) ride a TAPPABLE
// side wheel on the RIGHT and qty a tappable wheel on the LEFT. There is NO
// spinner ([ListWheelScrollView]) and NO centre band (the two abandoned dive-bs4
// sins). Tapping a wheel value / dragging an axis changes the live selection
// (surfaced through onAddToCart) and RE-RESOLVES the centre image (pure
// re-resolution is pinned in catalog_config_variant_image_test). The card holds NO
// per-product code — a new product is a data row. Assertions check STRUCTURE +
// CONTRACT, never pixels. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§B/§dive-bs2b).

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

// PRIORITY (taxonomy) order — the card is positional: attr[0]=diameter (🔩 right)
// · attr[1]=angle (↕) · attr[2]=length (↔). A BOGUS familyId keeps the centre
// deterministic (no live-catalog variant matches → the emoji fallback shows).
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

// Manifold shape: attr[0]=diameter (🔩) · attr[1]=ports (↕) · attr[2]=color (↔).
ProductConfigSchema _manifold() => ProductConfigSchema(
      sku: 'M-1',
      nameHe: 'מחלק',
      familyId: 'בדיקה',
      emoji: '🔀',
      attributes: [
        _attr('diameter', 'קוטר', AttributeKind.dimension, const ['20', '25']),
        _attr('ports', 'יציאות', AttributeKind.number, const ['1', '2', '3', '4']),
        _attr('color', 'צבע', AttributeKind.color, const ['כחול', 'אדום']),
      ],
    );

/// A schema with NO wheels — the base-card / M1 guard (image + qty + cart usable).
ProductConfigSchema _bare() => const ProductConfigSchema(
      sku: 'X-0',
      nameHe: 'ריק',
      familyId: 'בדיקה',
      emoji: '🔧',
      attributes: [],
    );

Widget _host(Widget card) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: card)),
    );

/// A non-scrolling host — so a ↕/↔ drag on the image is not stolen by an ancestor
/// [Scrollable] (used by the axis-drag tests; determinism, no arena contest).
Widget _staticHost(Widget card) => MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 380, child: card)),
      ),
    );

Finder _key(String k) => find.byKey(Key(k));

void main() {
  group('#catalog-config ConfigCard — dive-bs2b build (image hero · 4 edges)', () {
    testWidgets(
        'elbow (3 attrs) → image CENTRE hero · ↕/↔ edge labels · קוטר+כמות wheels',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _elbow())));

      // the image is the CENTRE hero, inside the stage — never a boxed/top image.
      expect(_key('configStage'), findsOneWidget);
      expect(_key('configImageCenter'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('configStage'),
          matching: _key('configImageCenter'),
        ),
        findsOneWidget,
      );

      // the FOUR edge labels of the two image axes (data-driven — hardcoded none).
      expect(find.text('▲ זווית'), findsOneWidget); // ↕ name (top)
      expect(find.text('45°·90° ▼'), findsOneWidget); // ↕ values (bottom)
      expect(find.text('◀ אורך'), findsOneWidget); // ↔ name (right)
      expect(find.text('קצר ▶'), findsOneWidget); // ↔ first value (left)

      // the side wheels: קוטר (right) + כמות (left) as TAPPABLE stacks.
      expect(find.text('קוטר'), findsOneWidget); // diameter wheel header
      expect(find.text('כמות'), findsOneWidget); // qty wheel header
      expect(find.text('40'), findsOneWidget); // an unselected diameter value

      // the two actions.
      expect(_key('configAddToCart'), findsOneWidget);
      expect(_key('configBuildLine'), findsOneWidget);

      // no imageAsset + no catalog variant ⇒ the centre shows the big emoji (D.2).
      expect(find.text('🦵'), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      // the two abandoned dive-bs4 sins are ABSENT: no spinner, no axis band.
      expect(find.byType(ListWheelScrollView), findsNothing);
      expect(_key('configAxisPrimary'), findsNothing);
    });

    testWidgets('manifold schema → axes SWAP (יציאות/צבע), SAME card (generic)',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _manifold())));

      expect(_key('configStage'), findsOneWidget);
      expect(find.text('▲ יציאות'), findsOneWidget); // ↕ ports
      expect(find.text('◀ צבע'), findsOneWidget); // ↔ color
      expect(find.text('כחול ▶'), findsOneWidget); // ↔ first color
      expect(find.text('קוטר'), findsOneWidget); // same diameter side wheel
      expect(find.text('כמות'), findsOneWidget);
      expect(find.text('🔀'), findsOneWidget);
    });

    testWidgets('a schema with NO attributes still renders (image + qty + cart)',
        (tester) async {
      var added = false;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: _bare(),
            onAddToCart: (schema, selection, qty) => added = true,
          ),
        ),
      );

      expect(_key('configImageCenter'), findsOneWidget); // centre still present
      expect(find.text('🔧'), findsOneWidget); // emoji centre (never empty)
      expect(find.textContaining('▲'), findsNothing); // no axis labels
      expect(find.text('כמות'), findsOneWidget); // qty wheel still usable
      await tester.tap(find.text('2')); // pick qty 2
      await tester.pump();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();
      expect(added, isTrue);
    });
  });

  group('#catalog-config ConfigCard — centre image (plan D · variant/tile/emoji)', () {
    testWidgets('a card WITH an imageAsset renders an Image in the centre',
        (tester) async {
      await tester.pumpWidget(
        _host(ConfigCard(schema: _elbow(), imageAsset: 'gold.jpeg')),
      );

      // STRUCTURAL: the variant resolves to null (bogus family) so the tile image
      // is the centre — an Image (built through the catalog resolver), NOT the
      // emoji. A single pump never drives the async frame, so nothing is fetched.
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('🦵'), findsNothing);
      expect(
        find.descendant(
          of: _key('configImageCenter'),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a null-image card shows the emoji, no Image (D.2 fallback)',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _elbow())));

      expect(find.byType(Image), findsNothing);
      expect(find.text('🦵'), findsOneWidget);
    });
  });

  group('#catalog-config ConfigCard — tap wheels · drag axes · actions', () {
    testWidgets('tapping a קוטר value changes the live selection',
        (tester) async {
      Map<String, String>? captured;
      int? capturedQty;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, qty) {
              captured = selection;
              capturedQty = qty;
            },
          ),
        ),
      );

      await tester.tap(find.text('40')); // pick a non-default diameter
      await tester.pump();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!['diameter'], '40'); // the tap replaced the default '20'
      expect(captured!['angle'], '45°'); // untouched default (° · compliant)
      expect(captured!['length'], 'קצר'); // ditto
      expect(capturedQty, 1);
    });

    testWidgets('tapping the qty wheel sets qty; min option is 1', (tester) async {
      int? qty;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, q) => qty = q,
          ),
        ),
      );

      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();
      expect(qty, 4);

      await tester.tap(find.text('1')); // the floor value is always reachable
      await tester.pump();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();
      expect(qty, 1);
    });

    testWidgets('a ↕ drag on the image cycles the FIRST axis (angle)',
        (tester) async {
      Map<String, String>? captured;
      await tester.pumpWidget(
        _staticHost(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, qty) => captured = selection,
          ),
        ),
      );

      // an upward drag advances the angle wheel off its default '45°' → '90°'
      // (2 values, clamped end), proving the scroll is ON THE IMAGE (↕=angle).
      await tester.drag(_key('configStage'), const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();

      expect(captured!['angle'], '90°');
      expect(captured!['length'], 'קצר'); // the ↔ axis stayed on its default
    });

    testWidgets('a ↔ drag on the image cycles the SECOND axis (length)',
        (tester) async {
      Map<String, String>? captured;
      await tester.pumpWidget(
        _staticHost(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, qty) => captured = selection,
          ),
        ),
      );

      await tester.drag(_key('configStage'), const Offset(-120, 0));
      await tester.pumpAndSettle();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();

      expect(captured!['length'], 'ארוך'); // advanced to the clamped far end
      expect(captured!['angle'], '45°'); // the ↕ axis stayed on its default
    });

    testWidgets('בנה קו fires with the SAME schema instance', (tester) async {
      final schema = _manifold();
      ProductConfigSchema? seen;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: schema,
            onBuildLine: (s, selection, qty) => seen = s,
          ),
        ),
      );
      await tester.tap(_key('configBuildLine'));
      await tester.pump();
      expect(seen, same(schema));
    });
  });
}
