// Cluster-3 guards (9×9 fleet, autonomous run 2026-06-09 · tasks #37/#41):
// (#37) the "חלופות זולות" sheet gained a product search that filters the list.
// (#41) the "סרוק תוכנית" results gained per-item selection + a smart confirm
//        button ("אשר הכל" → "אשר את הבחירה" once you deselect something).
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(void Function(BuildContext) open) => ProviderScope(
      child: MaterialApp(
        builder: (ctx, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => open(ctx),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('#37 חלופות זולות — search filters (no-match → honest empty)',
      (t) async {
    await t.pumpWidget(_host(openCheaperAlternativesSheet));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('💡 חלופות זולות'), findsOneWidget);

    // A gibberish query must filter everything out → search-aware empty state.
    await t.enterText(find.byType(TextField).first, 'זזזזזזz');
    await t.pumpAndSettle();
    expect(find.text('לא נמצאו חלופות תואמות.'), findsOneWidget);

    // Clearing the query restores the auto list (empty-state message gone).
    await t.enterText(find.byType(TextField).first, '');
    await t.pumpAndSettle();
    expect(find.text('לא נמצאו חלופות תואמות.'), findsNothing);
  });

  testWidgets('#41 סרוק תוכנית — deselect flips confirm to "אשר את הבחירה"',
      (t) async {
    await t.pumpWidget(_host((ctx) => openScanPlanSheet(ctx)));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();

    // Picker → pick אינסטלציה → advance through the (finite, self-cancelling)
    // scan timer to the results phase.
    await t.tap(find.text('אינסטלציה'));
    await t.pump(); // start scan
    await t.pump(const Duration(seconds: 4)); // fire all periodic ticks
    await t.pumpAndSettle();

    // Default = all selected → "אשר הכל".
    expect(find.textContaining('אשר הכל'), findsOneWidget);
    expect(find.textContaining('אשר את הבחירה'), findsNothing);

    // Deselect one item → button flips to "אשר את הבחירה".
    final box = find.byType(Checkbox).first;
    expect(box, findsWidgets);
    await t.tap(box);
    await t.pumpAndSettle();
    expect(find.textContaining('אשר את הבחירה'), findsOneWidget);
  });
}
