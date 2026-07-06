// P4 verification: the RingDive wheel is driven by the REAL card_engine — the
// opening turn offers real catalog words, and tapping the focused option dives
// (narrows the pool → a new option set). No golden / no toImage (keeps it off
// the flaky raster path).
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_screen.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('flag OFF → renders nothing (byte-identical)', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: RingDiveScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RingDiveWheel), findsNothing);
  });

  testWidgets('flag ON → the wheel shows real engine options and dives',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'bs.feature-flags.v1': <String>[kRingDiveFlag],
    });
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: RingDiveScreen())),
      ),
    );
    await tester.pumpAndSettle();

    RingDiveWheel wheel() =>
        tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));

    // Opening turn (CardAskWords) → real plain-words from the catalog lexicon.
    final opening = wheel().labels;
    expect(opening, isNotEmpty, reason: 'engine opening should offer words');

    // Dive on the focused option → the pool narrows → a different option set.
    wheel().onSelect!(0);
    await tester.pumpAndSettle();
    expect(
      wheel().labels,
      isNot(equals(opening)),
      reason: 'a dive should narrow the pool into a new option set',
    );
  });
}
