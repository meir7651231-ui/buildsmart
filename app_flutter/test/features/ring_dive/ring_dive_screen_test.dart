// RD-B verification: RingDive drills the CLEAN derived taxonomy — the root wheel
// shows the 9 search styles, entering a style shows real clean axis options, and
// diving narrows to the next axis. No golden / no toImage (off the flaky path).
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_qty.dart';
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

  testWidgets('flag ON → root styles, then a clean taxonomy dive',
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

    // root: the 9 search styles.
    expect(wheel().labels.length, 9);
    expect(wheel().labels.any((l) => l.contains('מחלקה')), isTrue);

    // enter the 'dept' style (index 0) → clean department options.
    wheel().onSelect!(0);
    await tester.pumpAndSettle();
    expect(wheel().labels, contains('אינסטלציה'));
    final depts = wheel().labels;

    // dive into the first department → the axis switches to real categories.
    wheel().onSelect!(0);
    await tester.pumpAndSettle();
    expect(
      wheel().labels,
      isNot(equals(depts)),
      reason: 'a dive should advance to the next clean axis',
    );
  });

  testWidgets('compat: a product with real partners → what-connects mode',
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

    // dive by the focused option until a product lands in the qty phase.
    for (var i = 0; i < 14; i++) {
      if (find.byType(RingDiveQty).evaluate().isNotEmpty) break;
      wheel().onSelect!(0);
      await tester.pumpAndSettle();
    }
    expect(find.byType(RingDiveQty), findsOneWidget);

    // confirm the quantity → the done phase.
    await tester.tap(find.textContaining('הוסף לסל'));
    await tester.pumpAndSettle();

    // the added product connects to real partners (verified-connections
    // engine) → the "what connects" follow-up opens compat mode.
    await tester.tap(find.textContaining('מה מתחבר'));
    await tester.pumpAndSettle();
    expect(find.textContaining('תואמים'), findsWidgets);
  });

  testWidgets('job: "by job" style → real recipe → kit with components',
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

    // root: the 9th style is "לפי עבודה" (index 8) → the real recipe list.
    wheel().onSelect!(8);
    await tester.pumpAndSettle();
    expect(wheel().labels, isNotEmpty, reason: 'recipes fill the wheel');

    // pick the first recipe → the kit phase (real smart_tree components).
    wheel().onSelect!(0);
    await tester.pumpAndSettle();
    expect(find.textContaining('רכיבי הערכה'), findsOneWidget);
    expect(find.textContaining('הוסף ערכה לסל'), findsOneWidget);
  });

  testWidgets('wheel: a real tap after a drag still selects (gesture path)',
      (tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RingDiveWheel(
              labels: const <String>['a', 'b', 'c', 'd'],
              onSelect: (i) => selected = i,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final wheel = find.byType(RingDiveWheel);
    // a drag leaves the internal moved-distance high (> the tap threshold)...
    await tester.drag(wheel, const Offset(60, 30));
    await tester.pumpAndSettle();
    // ...and a genuine tap right after MUST still select. Before the fix the
    // stale `_moved` swallowed it, so a click after any spin did nothing.
    await tester.tap(wheel);
    await tester.pumpAndSettle();
    expect(
      selected,
      isNot(-1),
      reason: 'a tap after a drag must dive, not be swallowed by stale _moved',
    );
  });
}
