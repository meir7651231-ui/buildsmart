// PlainDive screen — proves ring 1 renders and is WIRED to the engine (its wheel
// labels are the engine's super-categories). Behind [kPlainDive]; self-skips off.
//
//   flutter test --dart-define=PLAIN_DIVE=true test/features/ring_dive/plain_dive_screen_test.dart

import 'package:buildsmart/features/ring_dive/plain_dive.dart';
import 'package:buildsmart/features/ring_dive/plain_dive_screen.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart' show kPlainDive;
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart'
    show RingDiveWheel;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ring 1 is wired to the engine super-categories', (tester) async {
    if (!kPlainDive) {
      markTestSkipped('PLAIN_DIVE off — run with --dart-define=PLAIN_DIVE=true');
      return;
    }
    await tester.pumpWidget(const MaterialApp(home: PlainDiveScreen()));
    await tester.pumpAndSettle();

    final wheel =
        tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels, plainSuperCats(),
        reason: 'ring 1 shows exactly the engine super-categories');
    expect(wheel.labels, isNotEmpty);
  });

  testWidgets('full drill spins ring→ring down to a product list', (tester) async {
    if (!kPlainDive) {
      markTestSkipped('PLAIN_DIVE off — run with --dart-define=PLAIN_DIVE=true');
      return;
    }
    await tester.pumpWidget(const MaterialApp(home: PlainDiveScreen()));
    await tester.pumpAndSettle();

    // Drive each ring by picking its first option (as a real tap would), through
    // the dictionary rings AND the size/attribute narrow rings, until the wheel
    // is gone and the final product list is on screen.
    var rings = 0;
    while (find.byType(RingDiveWheel).evaluate().isNotEmpty && rings < 12) {
      final w = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
      w.onSelect!(0);
      await tester.pumpAndSettle();
      rings++;
    }

    expect(rings, greaterThanOrEqualTo(3),
        reason: 'at least super-cat → classification → type before products');
    expect(find.byType(RingDiveWheel), findsNothing,
        reason: 'the drill ended on the product list, not a wheel');
    expect(find.byType(ListView), findsOneWidget,
        reason: 'the final ring is the remaining product(s)');
    expect(find.byType(ListTile), findsWidgets,
        reason: 'the drill reached real products');
  });
}
