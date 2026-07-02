// Regression guard for the KB_GLOBAL finder product-tap CRASH the Android /
// KB_GLOBAL audit found (and its fix).
//
// THE BUG: under KB_GLOBAL the floating keyboard is mounted in an Overlay ABOVE
// the app Navigator, so the [FindKeyboardPanel]'s OWN BuildContext has no
// Navigator ancestor. Tapping a product called `showLipskeyProductSheet(context)`
// → `Navigator.of(context)` → threw "No Navigator found" (release/flag-only, so
// no widget test caught it before).
//
// THE FIX: the panel no longer opens the sheet on its own context — when the host
// supplies an [FindKeyboardPanel.onOpenProduct] callback it DEFERS to it, and the
// floating host routes the sheet through its ROOT-navigator context
// (`_navContext` = bsNavigatorKey's overlay under kKbGlobal). So the crux of the
// fix is: a product tap must reach `onOpenProduct`, NOT the panel's own context.
//
// This test drives a REAL finder dive to a product and asserts the tap is routed
// to the callback. It is flag-INDEPENDENT (the deferral wiring is the same on and
// off), so it runs in the normal suite and guards the fix from regressing (revert
// the panel to its own-context path and this goes red).

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/find_keyboard_panel.dart'
    show FindKeyboardPanel;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'a finder product tap is routed to onOpenProduct (KB_GLOBAL crash-fix wiring)',
    (tester) async {
      final opened = <LipskeyCatalogProduct>[];
      var sheetSiblings = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: FindKeyboardPanel(
                  onOpenProduct: (p, siblings) {
                    opened.add(p);
                    sheetSiblings = siblings.length;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The grid renders its option keys in a Wrap inside a Container(minHeight:
      // 140). Product keys carry the inventory glyph; option (word/chip) keys do
      // not. Drive the dive by tapping the FIRST grid key each turn until product
      // keys surface — the ≤6 gate guarantees convergence, so a small guard is
      // plenty. (Targeting the grid's own Wrap avoids the אבג/חזרה TextButtons in
      // the top row and the Chips in the selection row.)
      final gridWrap = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.minHeight == 140,
        ),
        matching: find.byType(Wrap),
      );
      final productKeys = find.byIcon(Icons.inventory_2_outlined);

      var guard = 0;
      while (productKeys.evaluate().isEmpty && guard < 10) {
        final keys = find.descendant(of: gridWrap, matching: find.byType(InkWell));
        expect(keys, findsWidgets,
            reason: 'the grid always offers at least one option key mid-dive');
        await tester.tap(keys.first);
        await tester.pumpAndSettle();
        guard++;
      }

      expect(productKeys, findsWidgets,
          reason: 'the dive reached product keys within the ≤6 gate');

      // Tap a product key — the crux. It must fire the host callback, NOT open a
      // sheet on the panel's own (KB_GLOBAL: Navigator-less) context.
      await tester.tap(productKeys.first);
      await tester.pumpAndSettle();

      expect(opened, isNotEmpty,
          reason: 'the product tap was routed to onOpenProduct (the host opens '
              'the sheet via its root-navigator context) — not the panel context');
      expect(sheetSiblings, greaterThanOrEqualTo(1),
          reason: 'the callback carries the product plus its sibling list');
    },
  );
}
