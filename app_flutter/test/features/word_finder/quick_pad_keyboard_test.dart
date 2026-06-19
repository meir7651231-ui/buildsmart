import 'package:buildsmart/features/word_finder/quick_pad_item.dart';
import 'package:buildsmart/features/word_finder/quick_pad_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A const-friendly no-op `onAdd` — a top-level tear-off so a `const`
/// [QuickPadKeyboard] can be built in a test that only inspects rendering.
void _noop(QuickPadItem _, int __) {}

void main() {
  group('QuickPadKeyboard', () {
    testWidgets('renders product labels as text and uses no Material icons',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPadKeyboard(
              items: const [
                QuickPadItem('ברז', payload: 'sku-1'),
                QuickPadItem('צינור', payload: 'sku-2'),
                QuickPadItem('אטם', payload: 'sku-3'),
              ],
              onAdd: (_, __) {},
            ),
          ),
        ),
      );

      // Each product label renders as plain text on its key.
      expect(find.text('ברז'), findsOneWidget);
      expect(find.text('צינור'), findsOneWidget);
      expect(find.text('אטם'), findsOneWidget);

      // The stepper uses the text glyphs '+' and '−' — one per item.
      expect(find.text('+'), findsNWidgets(3));
      expect(find.text('−'), findsNWidgets(3));

      // No key — label, stepper, nor any glyph — renders an Icon.
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets(
        'tapping + twice then add fires onAdd with qty 3 (1 default + 2)',
        (tester) async {
      QuickPadItem? added;
      int? addedQty;

      const items = [
        QuickPadItem('ברז', payload: 'sku-1'),
        QuickPadItem('צינור', payload: 'sku-2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPadKeyboard(
              items: items,
              onAdd: (item, qty) {
                added = item;
                addedQty = qty;
              },
            ),
          ),
        ),
      );

      // Scope the stepper finders to the FIRST item's cell (the Column that
      // contains its label) so we increment exactly that item's quantity.
      final firstCell = find.ancestor(
        of: find.text('ברז'),
        matching: find.byType(Column),
      );
      final plusInFirstCell = find.descendant(
        of: firstCell.first,
        matching: find.text('+'),
      );

      // Default qty is 1; render it.
      expect(
        find.descendant(of: firstCell.first, matching: find.text('1')),
        findsOneWidget,
      );

      // Tap '+' twice → qty becomes 3.
      await tester.tap(plusInFirstCell);
      await tester.pump();
      await tester.tap(plusInFirstCell);
      await tester.pump();

      expect(
        find.descendant(of: firstCell.first, matching: find.text('3')),
        findsOneWidget,
      );

      // Tap the product label ("add") → onAdd fires with the item and qty 3.
      await tester.tap(find.text('ברז'));
      await tester.pump();

      expect(added, isNotNull);
      expect(added!.label, 'ברז');
      expect(addedQty, 3);
    });

    testWidgets('onSwitchMode utility key renders as text and fires on tap',
        (tester) async {
      var switched = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPadKeyboard(
              items: const [QuickPadItem('ברז', payload: 'sku-1')],
              onAdd: (_, __) {},
              onSwitchMode: () => switched = true,
            ),
          ),
        ),
      );

      expect(find.text('מצב רגיל'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);

      await tester.tap(find.text('מצב רגיל'));
      await tester.pump();
      expect(switched, isTrue);
    });

    testWidgets('tapping − at qty 1 stays 1 (locks the floor)',
        (tester) async {
      const items = [QuickPadItem('ברז', payload: 'sku-1')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPadKeyboard(
              items: items,
              onAdd: (_, __) {},
            ),
          ),
        ),
      );

      final firstCell = find.ancestor(
        of: find.text('ברז'),
        matching: find.byType(Column),
      );
      final minusInFirstCell = find.descendant(
        of: firstCell.first,
        matching: find.text('−'),
      );

      // Default qty is 1.
      expect(
        find.descendant(of: firstCell.first, matching: find.text('1')),
        findsOneWidget,
      );

      // Tap '−' several times — qty must never drop below the floor of 1.
      await tester.tap(minusInFirstCell);
      await tester.pump();
      await tester.tap(minusInFirstCell);
      await tester.pump();
      await tester.tap(minusInFirstCell);
      await tester.pump();

      expect(
        find.descendant(of: firstCell.first, matching: find.text('1')),
        findsOneWidget,
      );
      // No negative / zero count ever surfaces on the qty readout.
      expect(
        find.descendant(of: firstCell.first, matching: find.text('0')),
        findsNothing,
      );
    });

    testWidgets('tapping + past the cap stays at kMaxQty',
        (tester) async {
      const items = [QuickPadItem('ברז', payload: 'sku-1')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPadKeyboard(
              items: items,
              onAdd: (_, __) {},
            ),
          ),
        ),
      );

      final firstCell = find.ancestor(
        of: find.text('ברז'),
        matching: find.byType(Column),
      );
      final plusInFirstCell = find.descendant(
        of: firstCell.first,
        matching: find.text('+'),
      );

      // Tap '+' more times than the cap allows (start at 1, so kMaxQty + 5
      // taps would overshoot to kMaxQty + 6 without the cap).
      for (var i = 0; i < kMaxQty + 5; i++) {
        await tester.tap(plusInFirstCell);
        await tester.pump();
      }

      // The qty readout is pinned at kMaxQty — never above it.
      expect(
        find.descendant(of: firstCell.first, matching: find.text('$kMaxQty')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: firstCell.first,
          matching: find.text('${kMaxQty + 1}'),
        ),
        findsNothing,
      );
    });

    testWidgets(
        'didUpdateWidget: longer then shorter list keeps stepped qty per '
        'surviving index, new indices default to 1', (tester) async {
      // Start with two items; bump each to a distinct, non-default qty.
      const itemsShort = [
        QuickPadItem('ברז', payload: 'sku-1'),
        QuickPadItem('צינור', payload: 'sku-2'),
      ];

      Widget build(List<QuickPadItem> items) => MaterialApp(
            home: Scaffold(
              body: QuickPadKeyboard(
                items: items,
                onAdd: (_, __) {},
              ),
            ),
          );

      await tester.pumpWidget(build(itemsShort));

      Finder cellFor(String label) => find.ancestor(
            of: find.text(label),
            matching: find.byType(Column),
          ).first;
      Finder plusIn(Finder cell) => find.descendant(
            of: cell,
            matching: find.text('+'),
          );

      // ברז → qty 3 (two '+' taps), צינור → qty 2 (one '+' tap).
      await tester.tap(plusIn(cellFor('ברז')));
      await tester.pump();
      await tester.tap(plusIn(cellFor('ברז')));
      await tester.pump();
      await tester.tap(plusIn(cellFor('צינור')));
      await tester.pump();

      expect(
        find.descendant(of: cellFor('ברז'), matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cellFor('צינור'), matching: find.text('2')),
        findsOneWidget,
      );

      // Rebuild with a LONGER list (same leading items + a fresh trailing one).
      // didUpdateWidget fires because it's the same widget type at the same
      // tree position; the State (and its _qty) is reused.
      const itemsLong = [
        QuickPadItem('ברז', payload: 'sku-1'),
        QuickPadItem('צינור', payload: 'sku-2'),
        QuickPadItem('אטם', payload: 'sku-3'),
      ];
      await tester.pumpWidget(build(itemsLong));
      await tester.pump();

      // Surviving indices keep their stepped qty; the new index defaults to 1.
      expect(
        find.descendant(of: cellFor('ברז'), matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cellFor('צינור'), matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cellFor('אטם'), matching: find.text('1')),
        findsOneWidget,
      );

      // Rebuild with a SHORTER list (drop the last item). The truncated tail
      // is discarded; the surviving leading indices keep their stepped qty.
      await tester.pumpWidget(build(itemsShort));
      await tester.pump();

      expect(find.text('אטם'), findsNothing);
      expect(
        find.descendant(of: cellFor('ברז'), matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cellFor('צינור'), matching: find.text('2')),
        findsOneWidget,
      );
    });

    testWidgets(
        'a11y: the stepper +/− keys carry product-named Semantics and the qty '
        'readout exposes its count as a Semantics value', (tester) async {
      // The stepper keys render bare glyphs ('−' / '+' / a number); without
      // Semantics a screen reader announces only "minus" / "plus" / a lone
      // digit. The keyboard wraps each in a Semantics node naming the action +
      // product, and exposes the qty via Semantics.value. This guards that the
      // a11y wrapping is present and follows the product label. ALL checks are
      // at the WIDGET level (SemanticsProperties on the Semantics widgets), so no
      // SemanticsHandle / semantics-tree access is needed.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPadKeyboard(
              items: [QuickPadItem('ברז', payload: 'sku-1')],
              onAdd: _noop,
            ),
          ),
        ),
      );

      // The increase / decrease keys carry a product-named Semantics label (the
      // bare '+' / '−' glyph label is excluded), so a screen-reader user hears
      // WHAT they are stepping. Checked at the widget level.
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'הוסף כמות · ברז',
        ),
        findsOneWidget,
        reason: 'the + key announces "increase quantity · <product>"',
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'הפחת כמות · ברז',
        ),
        findsOneWidget,
        reason: 'the − key announces "decrease quantity · <product>"',
      );

      // ACTIVATION (the synth-caught blocker): the increase/decrease Semantics
      // must carry the tap action THEMSELVES — excludeSemantics drops the child
      // InkWell's action, so without onTap on the labelled node an AT double-tap
      // is a no-op. Assert at the WIDGET level (SemanticsProperties.onTap),
      // mirroring the qty-value check below, so we don't touch the semantics-tree
      // machinery (and avoid a stray SemanticsHandle).
      final incNode = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'הוסף כמות · ברז',
      );
      expect(tester.widget<Semantics>(incNode).properties.onTap, isNotNull,
          reason: 'the + key must carry a tap action (AT-activatable, not just '
              'announced)');
      final decNode = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'הפחת כמות · ברז',
      );
      expect(tester.widget<Semantics>(decNode).properties.onTap, isNotNull,
          reason: 'the − key must carry a tap action (AT-activatable, not just '
              'announced)');

      // The qty readout exposes its count as a Semantics VALUE (not just a bare
      // digit label). Locate the explicit Semantics widget the keyboard added
      // (the one whose label is 'כמות') and assert its value tracks the count
      // (default 1) — matching on the widget's own SemanticsProperties so the
      // check is robust to ancestor/merge layout.
      final qtyNode = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'כמות',
      );
      expect(qtyNode, findsOneWidget,
          reason: 'the qty readout is wrapped in a labelled Semantics node');
      expect(
        tester.widget<Semantics>(qtyNode).properties.value,
        '1',
        reason: 'the qty readout exposes the count (default 1) as its value',
      );
    });

    testWidgets(
        'qty follows the PRODUCT across a same-length reorder, not the slot '
        '(canonical-audit money guard)', (tester) async {
      // Step product A to qty 3, REORDER the same-length list so A moves to the
      // other slot, then add A. Before the fix _qty was keyed by list index, so
      // the count stayed bound to slot 0 and A added the WRONG qty after a
      // reorder; now _qty is keyed by item identity, so the count follows A.
      QuickPadItem? added;
      int? addedQty;
      var items = const [
        QuickPadItem('ברז', payload: 'A'),
        QuickPadItem('צינור', payload: 'B'),
      ];
      late StateSetter setOuter;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuter = setState;
                return QuickPadKeyboard(
                  items: items,
                  onAdd: (item, qty) {
                    added = item;
                    addedQty = qty;
                  },
                );
              },
            ),
          ),
        ),
      );

      // A is at slot 0 — step its '+' twice → qty 3.
      await tester.tap(find.text('+').first);
      await tester.pump();
      await tester.tap(find.text('+').first);
      await tester.pump();

      // Reorder to [B, A] — SAME length, A now at slot 1.
      setOuter(() {
        items = const [
          QuickPadItem('צינור', payload: 'B'),
          QuickPadItem('ברז', payload: 'A'),
        ];
      });
      await tester.pumpAndSettle();

      // Tapping A's label adds A with qty 3 — the count followed the product
      // across the reorder, it did not stay on slot 0 (the index bug).
      await tester.tap(find.text('ברז'));
      await tester.pump();
      expect(added?.payload, 'A', reason: 'the tapped label is product A');
      expect(addedQty, 3,
          reason: 'qty 3 must follow product A across the reorder, never stay '
              'bound to the old slot index');
    });
  });
}
