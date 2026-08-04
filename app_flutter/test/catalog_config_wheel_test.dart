// CATALOG-CONFIG · Phase C wheel test — pins the two things phase C adds, on the
// ENGINE model ([AttributeKind]):
//   1. [WheelPicker] — a generic native spinner ([ListWheelScrollView]): it builds
//      with N values, shows its label + the centred value, renders a swatch for an
//      [AttributeKind.color] wheel, guards empty values with '—', and fires
//      [WheelPicker.onSelected] with a NEW index when spun (and re-centres when an
//      outside index change arrives via didUpdateWidget).
//   2. the [ConfigCard] renders REAL wheels (one [WheelPicker] per [AttributeDef]).
//
// DETERMINISM (no flaky pixel math): the card seeds each wheel on its DEFAULT
// (sortIndex==0) value, i.e. index 0, so a single over-two-extent UPWARD
// [WidgetTester.drag] + [WidgetTester.pumpAndSettle] MUST advance to a different,
// valid item under FixedExtentScrollPhysics snap. Assertions check the selection
// CONTRACT (value changed / untouched wheels kept their default), never an exact
// scrolled value. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§ פאזה C).

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/config_card.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/catalog_config/wheel_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A const no-op selection sink — lets the didUpdateWidget test build a `const`
/// [WheelPicker] (a closure would not be const).
void _noop(int _) {}

/// Build one [AttributeDef] with N string values (canonical == label).
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

/// A 3-wheel elbow schema (זווית · קוטר · אורך) — the canonical 3-wheel shape.
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

/// Host a single [WheelPicker] in a bounded-width box (a wheel needs finite width).
Widget _wheelHost(Widget wheel) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 160, child: wheel),
      ),
    ),
  );
}

/// Host a [ConfigCard] in a scroll view (its full height may exceed the surface).
Widget _cardHost(Widget card) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: card),
    ),
  );
}

void main() {
  group('#catalog-config WheelPicker — build · label · values', () {
    testWidgets('builds with N values, shows the label + the centred value',
        (tester) async {
      await tester.pumpWidget(
        _wheelHost(
          WheelPicker(
            labelHe: 'זווית',
            values: const ['15°', '30°', '45°', '90°'],
            selectedIndex: 3,
            kind: AttributeKind.number,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.byType(WheelPicker), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsOneWidget);
      expect(find.text('זווית'), findsOneWidget); // the muted label
      expect(find.text('90°'), findsOneWidget); // the centred (selected) value
    });

    testWidgets('a color wheel renders swatch dots beside the Hebrew names',
        (tester) async {
      await tester.pumpWidget(
        _wheelHost(
          WheelPicker(
            labelHe: 'צבע',
            values: const ['כחול', 'אדום'],
            selectedIndex: 0,
            kind: AttributeKind.color,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('צבע'), findsOneWidget);
      expect(find.text('כחול'), findsOneWidget); // centred colour name
      expect(find.byKey(const Key('wheelSwatch')), findsWidgets); // ≥1 swatch dot
    });

    testWidgets("empty values render a single '—' (null-fallback, no spinner)",
        (tester) async {
      await tester.pumpWidget(
        _wheelHost(
          WheelPicker(
            labelHe: 'קוטר',
            values: const [],
            selectedIndex: 0,
            kind: AttributeKind.dimension,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('—'), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsNothing);
    });
  });

  group('#catalog-config WheelPicker — spin + external re-centre', () {
    testWidgets('spinning the wheel fires onSelected with a NEW index',
        (tester) async {
      int? captured;
      await tester.pumpWidget(
        _wheelHost(
          WheelPicker(
            labelHe: 'קוטר',
            values: const ['20', '25', '32', '40', '50'],
            selectedIndex: 2, // MID-list ⇒ any drag direction moves off it
            kind: AttributeKind.dimension,
            onSelected: (i) => captured = i,
          ),
        ),
      );

      // Over-one-extent drag → FixedExtentScrollPhysics snaps to a new integer item.
      await tester.drag(find.byType(ListWheelScrollView), const Offset(0, 72));
      await tester.pumpAndSettle();

      expect(captured, isNotNull); // the wheel reported a settle
      expect(captured, isNot(2)); // and it left the initial centred index
    });

    testWidgets('an outside selectedIndex change re-centres (didUpdateWidget)',
        (tester) async {
      await tester.pumpWidget(
        _wheelHost(
          const WheelPicker(
            labelHe: 'זווית',
            values: ['15°', '30°', '45°', '90°'],
            selectedIndex: 0,
            kind: AttributeKind.number,
            onSelected: _noop,
          ),
        ),
      );
      expect(find.text('15°'), findsOneWidget); // starts centred on the first value

      // Re-seed from the parent → the wheel animates to the new pick, no throw.
      await tester.pumpWidget(
        _wheelHost(
          const WheelPicker(
            labelHe: 'זווית',
            values: ['15°', '30°', '45°', '90°'],
            selectedIndex: 3,
            kind: AttributeKind.number,
            onSelected: _noop,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('90°'), findsOneWidget); // re-centred on index 3
      expect(tester.takeException(), isNull);
    });
  });

  group('#catalog-config ConfigCard — renders one WheelPicker per attribute', () {
    testWidgets('elbow schema → 3 WheelPickers, 3 labels, emoji, buttons',
        (tester) async {
      await tester.pumpWidget(_cardHost(ConfigCard(schema: _elbow())));

      // one WheelPicker per DECLARED attribute — the card hardcodes none of these.
      expect(find.byType(WheelPicker), findsNWidgets(3));
      expect(find.text('זווית'), findsOneWidget);
      expect(find.text('קוטר'), findsOneWidget);
      expect(find.text('אורך'), findsOneWidget);
      // no imageAsset ⇒ the center shows the emoji (D.2 fallback).
      expect(find.text('🦵'), findsOneWidget);
      expect(find.text('הוסף לסל'), findsOneWidget);
      expect(find.text('בנה קו'), findsOneWidget);
    });

    testWidgets('spinning a wheel surfaces the changed selection via onAddToCart',
        (tester) async {
      Map<String, String>? captured;
      int? capturedQty;
      await tester.pumpWidget(
        _cardHost(
          ConfigCard(
            schema: _elbow(),
            onAddToCart: (schema, selection, qty) {
              captured = selection;
              capturedQty = qty;
            },
          ),
        ),
      );

      // The diameter wheel is the 2nd (זווית · קוטר · אורך). It seeds on its
      // default '20' (index 0), so an UPWARD drag MUST advance to a later value.
      final diameterWheel = find.descendant(
        of: find.byType(WheelPicker).at(1),
        matching: find.byType(ListWheelScrollView),
      );
      await tester.drag(diameterWheel, const Offset(0, -72));
      await tester.pumpAndSettle();

      await tester.tap(find.text('הוסף לסל'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!['diameter'], isNot('20')); // the spin changed the live pick
      expect(captured!['angle'], '45°'); // an untouched wheel keeps its default
      expect(captured!['length'], 'קצר'); // ditto
      expect(capturedQty, 1);
    });
  });
}
