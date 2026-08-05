// CATALOG-CONFIG · dive-bs2b card test — the GENERIC [ConfigCard] renders ANY
// engine [ProductConfigSchema] as the CLEAN card (owner): the FULL product name
// clean ABOVE a SQUARE centre image (key 'configImageCenter', never empty — emoji
// fallback); the current values ride a CLEAN pill EMBEDDED on the image (no arrows,
// no edge labels · a ↕/↔ drag scrolls the two axes + swaps the photo); the diameter
// attribute(s) ride a TAPPABLE side wheel on the RIGHT and qty a tappable wheel on
// the LEFT (the wheels STAY). NO spinner ([ListWheelScrollView]), NO centre band, NO
// "הגלגלים של…" hint. Tapping a wheel / dragging an axis changes the live selection
// (surfaced through onAddToCart) and updates the pill + RE-RESOLVES the centre image.
// The card holds NO per-product code — a new product is a data row. Assertions check
// STRUCTURE + CONTRACT, never pixels. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§B).

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
// deterministic (no live-catalog variant matches → the emoji fallback shows, and
// the full name stays the schema name).
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
  group('#catalog-config ConfigCard — clean build (name · square image · value pill)', () {
    testWidgets(
        'elbow → full name above · square hero · value pill · קוטר+כמות wheels',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _elbow())));

      // the FULL product name, clean, above the image.
      expect(_key('configFullName'), findsOneWidget);
      expect(find.text('ברך'), findsOneWidget);

      // the image is the CENTRE hero, inside the (square) stage.
      expect(_key('configStage'), findsOneWidget);
      expect(_key('configImageCenter'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('configStage'),
          matching: _key('configImageCenter'),
        ),
        findsOneWidget,
      );

      // the current values are a CLEAN pill embedded on the image — the defaults
      // (sortIndex-0 of each axis), no arrows, no axis names.
      expect(find.text('20 · 45° · קצר'), findsOneWidget);
      // …and NONE of the old edge arrows/labels survive.
      expect(find.textContaining('▲'), findsNothing);
      expect(find.textContaining('▼'), findsNothing);
      expect(find.textContaining('◀'), findsNothing);
      expect(find.textContaining('▶'), findsNothing);
      expect(find.textContaining('הגלגלים של'), findsNothing); // no hint

      // the side wheels STAY: קוטר (right) + כמות (left) as TAPPABLE stacks.
      expect(find.text('קוטר'), findsOneWidget); // diameter wheel header
      expect(find.text('כמות'), findsOneWidget); // qty wheel header
      expect(find.text('40'), findsOneWidget); // an unselected diameter value

      // the two actions.
      expect(_key('configAddToCart'), findsOneWidget);
      expect(_key('configBuildLine'), findsOneWidget);

      // no imageAsset + no catalog variant ⇒ the centre shows the big emoji (D.2).
      expect(find.text('🦵'), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      // the abandoned dive-bs4 sins are ABSENT: no spinner.
      expect(find.byType(ListWheelScrollView), findsNothing);
    });

    testWidgets('manifold → axes swap in the pill (יציאות/צבע), SAME card (generic)',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _manifold())));

      expect(_key('configStage'), findsOneWidget);
      expect(find.text('מחלק'), findsOneWidget); // full name above
      // the pill carries the manifold defaults (diameter · ports · color).
      expect(find.text('20 · 1 · כחול'), findsOneWidget);
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
      expect(find.text('ריק'), findsOneWidget); // the full name
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

    testWidgets('a ↕ drag on the image cycles the FIRST axis; the pill tracks it',
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

      // an upward drag advances the angle off its default '45°' → '90°' (2 values,
      // clamped end), proving the scroll is ON THE IMAGE (↕=angle).
      await tester.drag(_key('configStage'), const Offset(0, -120));
      await tester.pumpAndSettle();

      // the embedded pill tracks the CURRENT values (scroll, not a static list).
      expect(find.text('20 · 90° · קצר'), findsOneWidget);
      expect(find.text('20 · 45° · קצר'), findsNothing);

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
