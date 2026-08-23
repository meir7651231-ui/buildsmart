// CATALOG-CONFIG · dive-bs2b card test — the GENERIC [ConfigCard] renders ANY
// engine [ProductConfigSchema] as the CLEAN card (owner): the FULL product name
// clean ABOVE a SQUARE centre image (key 'configImageCenter', never empty — emoji
// fallback); the current values ride a CLEAN pill EMBEDDED on the image (no arrows,
// no edge labels · a ↕/↔ drag on the image cycles two CONFIG axes + swaps the
// photo/name); the diameter attribute rides a FULL spinning WheelPicker on the
// RIGHT and qty a full spinning wheel on the LEFT (owner "גלגל מלא" — a fling
// reaches any value). Spinning a wheel / dragging an axis changes the live selection
// (surfaced through onAddToCart) and updates the pill + RE-RESOLVES the centre image.
// The card holds NO per-product code — a new product is a data row. Assertions check
// STRUCTURE + CONTRACT, never pixels. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§B).

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart'
    show materialOf, typeGroupOf;
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart'
    show prioritizedSchema;
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

      // the side wheels are FULL spinners now (owner "גלגל מלא"): קוטר (right) +
      // כמות (left), each a native WheelPicker.
      expect(find.text('קוטר'), findsOneWidget); // diameter wheel header
      expect(find.text('כמות'), findsOneWidget); // qty wheel header

      // the two actions.
      expect(_key('configAddToCart'), findsOneWidget);
      expect(_key('configBuildLine'), findsOneWidget);

      // no imageAsset + no catalog variant ⇒ the centre shows the big emoji (D.2).
      expect(find.text('🦵'), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      // BOTH side wheels are native spinning WheelPickers (ListWheelScrollView).
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
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
      expect(find.text('כמות'), findsOneWidget); // the qty wheel still renders
      expect(find.byType(ListWheelScrollView), findsOneWidget); // as a spinner
      await tester.tap(_key('configAddToCart'));
      await tester.pump();
      expect(added, isTrue); // cart works with the default qty
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

  group('#catalog-config ConfigCard — spin wheels · drag axes · actions', () {
    testWidgets('spinning the קוטר wheel changes the live selection',
        (tester) async {
      Map<String, String>? captured;
      int? capturedQty;
      await tester.pumpWidget(
        _staticHost(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, qty) {
              captured = selection;
              capturedQty = qty;
            },
          ),
        ),
      );

      // the diameter wheel (tree-FIRST spinner) seeds on its default '20'; a fling
      // UP moves it to a later value — a FULL wheel, not tap-by-tap (owner).
      await tester.drag(
        find.byType(ListWheelScrollView).first,
        const Offset(0, -72),
      );
      await tester.pumpAndSettle();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!['diameter'], isNot('20')); // the spin left the default
      expect(captured!['angle'], '45°'); // an untouched axis keeps its default
      expect(captured!['length'], 'קצר'); // ditto
      expect(capturedQty, 1);
    });

    testWidgets('the qty wheel is a FULL spinner — reaches past the old cap of 4',
        (tester) async {
      int? qty;
      await tester.pumpWidget(
        _staticHost(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, q) => qty = q,
          ),
        ),
      );

      // spin qty (tree-LAST spinner) well past 4 — proof the owner can FLING to a
      // high quantity (e.g. 56), not tap 1→2→3→4 and stop.
      await tester.drag(
        find.byType(ListWheelScrollView).last,
        const Offset(0, -360),
      );
      await tester.pumpAndSettle();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();
      expect(qty, isNotNull);
      expect(qty, greaterThan(4)); // the old 1..4 ceiling is gone
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

    testWidgets('a ↔ drag FALLS BACK to קוטר when there is no 3rd axis (owner)',
        (tester) async {
      // owner: "משיכה לימין ולשמאל… משנים" — horizontal must never be dead. A
      // TWO-axis product [diameter, angle] has no length, so ↔ cycles the diameter
      // (↕ still cycles angle), so both drag directions change the variant.
      Map<String, String>? captured;
      final twoAxis = ProductConfigSchema(
        sku: 'T-2',
        nameHe: 'מצמד',
        familyId: 'בדיקה',
        emoji: '🔗',
        attributes: [
          _attr('diameter', 'קוטר', AttributeKind.dimension,
              const ['20', '25', '32', '40']),
          _attr('angle', 'זווית', AttributeKind.choice, const ['45°', '90°']),
        ],
      );
      await tester.pumpWidget(
        _staticHost(
          ConfigCard(
            schema: twoAxis,
            onAddToCart: (schema, selection, qty) => captured = selection,
          ),
        ),
      );

      await tester.drag(_key('configStage'), const Offset(-120, 0)); // ↔
      await tester.pumpAndSettle();
      await tester.tap(_key('configAddToCart'));
      await tester.pump();

      expect(captured!['diameter'], isNot('20')); // ↔ cycled diameter (fallback)
      expect(captured!['angle'], '45°'); // the ↕ axis (angle) stayed put
    });

    testWidgets('a REAL catalog card resolves a variant image + coherent name', (tester) async {
      // 213072 = 'ברך 15°'. The card resolves the centre image + name against the TYPE
      // GROUP ([typeGroupOf]) — the owner-reported bug was an EMPTY family (the fittings
      // `familyOf` never matched the whole-catalog schema), so nothing resolved and the
      // image/name were frozen. With a non-empty family the variant resolves ⇒ a real
      // Image renders (not the emoji) and the name matches the tapped variant.
      final berekh =
          resolvedCatalogProducts.firstWhere((p) => p.sku == '213072');
      await tester.pumpWidget(_staticHost(ConfigCard(schema: prioritizedSchema(berekh))));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const Key('configFullName'))).data,
        contains('ברך'),
      );
      // the variant resolved ⇒ a real Image is built (the family is non-empty; before
      // the fix the empty family gave no image → the emoji, i.e. no Image widget).
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('a REAL card: BOTH ↕ and ↔ drags change the variant name (owner)',
        (tester) async {
      // owner: "משיכה לימין ולשמאל ולמעלה ולמטה משנים את השם ואת התמונה". On a real
      // multi-variant type BOTH image drags re-resolve the variant → the full name
      // changes: ↕ cycles the 2nd config axis (angle), ↔ the 3rd or FALLS BACK to
      // קוטר. (Only physical config axes are dragged — never a descriptive filter.)
      // A PPR ברך whose DN20 comes in BOTH 45° and 90° (so ↕ moves the angle within
      // the seeded diameter), schema built with the same MATERIAL-scoped universe the
      // screen uses — so the angle wheel carries only this material's angles.
      final berekh =
          resolvedCatalogProducts.firstWhere((p) => p.sku == '92117102');
      final universe = [
        for (final m in typeGroupOf(berekh, resolvedCatalogProducts))
          if (materialOf(m) == materialOf(berekh)) m,
      ];
      await tester.pumpWidget(
        _staticHost(ConfigCard(schema: prioritizedSchema(berekh, universe: universe))),
      );
      await tester.pumpAndSettle();
      String name() => tester.widget<Text>(_key('configFullName')).data ?? '';
      final start = name();

      await tester.drag(_key('configStage'), const Offset(0, -120)); // ↕
      await tester.pumpAndSettle();
      final afterVertical = name();
      expect(afterVertical, isNot(start),
          reason: 'a ↕ (up/down) drag must change the variant name');

      await tester.drag(_key('configStage'), const Offset(-120, 0)); // ↔
      await tester.pumpAndSettle();
      expect(name(), isNot(afterVertical),
          reason: 'a ↔ (left/right) drag must change the variant name too');
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
