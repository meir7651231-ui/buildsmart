// CATALOG-CONFIG · Phase B card test — the GENERIC [ConfigCard] builds ANY
// engine [ProductConfigSchema]: one [WheelPicker] per [AttributeDef] (label +
// values), a colour wheel shows its Hebrew names, the center resolves the passed
// `imageAsset` (else the emoji fallback), a wheel SPIN changes the live selection
// (surfaced through onAddToCart), the qty stepper floors at 1, and בנה-קו fires
// with the SAME schema instance. The card holds NO per-product code — a new
// product is a data row. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§B).

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/wheel_picker.dart';
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
        _attr('diameter', 'קוטר', AttributeKind.dimension,
            const ['20', '25', '32', '40', '50']),
        _attr('length', 'אורך', AttributeKind.choice,
            const ['קצר', 'בינוני', 'ארוך']),
      ],
    );

ProductConfigSchema _manifold() => ProductConfigSchema(
      sku: 'M-1',
      nameHe: 'מחלק',
      familyId: 'מחלק',
      emoji: '🔀',
      attributes: [
        _attr('ports', 'יציאות', AttributeKind.number, const ['1', '2', '3', '4']),
        _attr('color', 'צבע', AttributeKind.color, const ['כחול', 'אדום']),
        _attr('diameter', 'קוטר', AttributeKind.dimension, const ['20', '25']),
      ],
    );

/// A schema with NO wheels — the base-card / M1 guard (image + qty + cart usable).
ProductConfigSchema _bare() => const ProductConfigSchema(
      sku: 'X-0',
      nameHe: 'ריק',
      familyId: '',
      emoji: '🔧',
      attributes: [],
    );

Widget _host(Widget card) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: card)),
    );

void main() {
  group('#catalog-config ConfigCard — generic build (any AttributeDef schema)', () {
    testWidgets('elbow schema → 3 wheel labels + emoji fallback + default value',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _elbow())));

      // one label per DECLARED wheel — the card hardcodes none of these.
      expect(find.text('זווית'), findsOneWidget);
      expect(find.text('קוטר'), findsOneWidget);
      expect(find.text('אורך'), findsOneWidget);
      // no imageAsset ⇒ the center shows the emoji (D.2 fallback).
      expect(find.text('🦵'), findsOneWidget);
      // the default (sortIndex==0) value is centred on its wheel.
      expect(find.text('45°'), findsOneWidget); // angle default
      expect(find.text('הוסף לסל'), findsOneWidget);
      expect(find.text('בנה קו'), findsOneWidget);
    });

    testWidgets('manifold schema → different shape, SAME card (generic)',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _manifold())));

      expect(find.text('יציאות'), findsOneWidget);
      expect(find.text('צבע'), findsOneWidget);
      expect(find.text('קוטר'), findsOneWidget);
      // a colour wheel renders its rows with the Hebrew colour name.
      expect(find.text('כחול'), findsOneWidget);
      expect(find.text('אדום'), findsOneWidget);
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

      expect(find.byType(WheelPicker), findsNothing); // no wheels
      expect(find.text('🔧'), findsOneWidget); // emoji center still shown
      await tester.tap(find.byIcon(Icons.add)); // qty stepper still usable
      await tester.pump();
      await tester.tap(find.text('הוסף לסל'));
      await tester.pump();
      expect(added, isTrue);
    });
  });

  group('#catalog-config ConfigCard — center image (plan D)', () {
    testWidgets('a card WITH an imageAsset renders an Image (resolved)',
        (tester) async {
      await tester.pumpWidget(
        _host(ConfigCard(schema: _elbow(), imageAsset: 'gold.jpeg')),
      );

      // STRUCTURAL assertion only — the image is built through the catalog
      // resolver, but a single pump never drives the async image frame, so
      // NOTHING is fetched: we assert the Image widget exists, and that the emoji
      // fallback is NOT shown in its place.
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('🦵'), findsNothing);
    });

    testWidgets('a null-image card shows the emoji, no Image (D.2 fallback)',
        (tester) async {
      await tester.pumpWidget(_host(ConfigCard(schema: _elbow())));

      expect(find.byType(Image), findsNothing);
      expect(find.text('🦵'), findsOneWidget);
    });
  });

  group('#catalog-config ConfigCard — wheel spin + qty stepper', () {
    testWidgets('a wheel spin changes the live selection (via onAddToCart)',
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

      // Spin the diameter wheel (2nd; seeds on its default '20' at index 0, so an
      // UPWARD drag lands on a later value — deterministic, no pixel math).
      await tester.drag(
        find.descendant(
          of: find.byType(WheelPicker).at(1),
          matching: find.byType(ListWheelScrollView),
        ),
        const Offset(0, -72),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('הוסף לסל'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!['diameter'], isNot('20')); // the spin replaced the default
      expect(captured!['angle'], '45°'); // an untouched default carried through
      expect(capturedQty, 1);
    });

    testWidgets('qty stepper: + raises, − floors at 1', (tester) async {
      int? qty;
      await tester.pumpWidget(
        _host(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, q) => qty = q,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('הוסף לסל'));
      await tester.pump();
      expect(qty, 2);

      // three decrements from 2 must not fall below the min of 1.
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      await tester.tap(find.text('הוסף לסל'));
      await tester.pump();
      expect(qty, 1);
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
      await tester.tap(find.text('בנה קו'));
      await tester.pump();
      expect(seen, same(schema));
    });
  });
}
