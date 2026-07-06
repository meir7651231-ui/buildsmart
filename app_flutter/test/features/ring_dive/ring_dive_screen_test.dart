// RD-B verification: RingDive drills the CLEAN derived taxonomy — the root wheel
// shows the 9 search styles, entering a style shows real clean axis options, and
// diving narrows to the next axis. No golden / no toImage (off the flaky path).
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
}
