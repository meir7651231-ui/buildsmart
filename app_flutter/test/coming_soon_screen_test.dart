// Cluster-2 guard (9×9 fleet, autonomous run 2026-06-09 · task #29):
// picking חשמלאי / קבלן שיפוצים in the profession picker now routes to an
// honest ComingSoonScreen (instead of an empty flow). This widget test proves
// the screen names the profession and that "חזור לבחירת מקצוע" pops back.
import 'package:buildsmart/screens/coming_soon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ComingSoonScreen names the trade and back-button pops', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(ctx).push(ComingSoonScreen.route('חשמלאי')),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await t.tap(find.text('go'));
    await t.pumpAndSettle();

    // Honest "coming soon" content naming the chosen profession.
    expect(find.text('🚧'), findsOneWidget);
    expect(find.text('התוכן עבור חשמלאי בהכנה'), findsOneWidget);
    final back = find.text('‹ חזור לבחירת מקצוע');
    expect(back, findsOneWidget);

    // Back button returns to the picker (pops the route).
    await t.tap(back);
    await t.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);
    expect(find.text('🚧'), findsNothing);
  });
}
