// CatalogWheel — proves the "pick any wheel" flow drives end-to-end AND that the
// live product gallery under the wheel is wired: the axis selector offers ≥2
// axes, picking one shows a VALUE wheel with a gallery beneath it, spinning
// (onFocusChanged) previews the focused value, picking adds a constraint, and the
// full products grid is reachable.
//
// Uses pump() (not pumpAndSettle) because the gallery streams CDN images that
// never "settle" in the test environment — the widgets build fine, we just don't
// wait on the network (the SAME resolver the rest of the app's product surfaces
// use, which is test-green via its errorBuilder fallback).
//
//   flutter test test/features/ring_dive/catalog_wheel_test.dart

import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:buildsmart/features/ring_dive/catalog_wheel_screen.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart'
    show RingDiveWheel;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the FIRST wheel offers many startable axes', () {
    final first = catFindAxes(const <String, String>{});
    expect(first.length, greaterThanOrEqualTo(10),
        reason: 'you can start from most of the ~17 axes');
    expect(
        first,
        containsAll(<String>[
          'diamInch',
          'diamDn',
          'diamMm',
          'length',
          'transition',
        ]));
    expect(first.contains('size'), isFalse, reason: 'no lumped "size" axis');
    expect(first.contains('diameter'), isFalse,
        reason: 'no lumped "diameter" axis — split by system');
  });

  testWidgets('axis wheel → value wheel (+gallery) → constraint → products',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogWheelScreen()));
    await tester.pump();

    // Ring 1 = the axis selector. Slot 0 "📋 הצג", slot 1 "🔧 לפי עבודה", rest axes.
    var wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels.first, contains('הצג'));
    expect(wheel.labels[1], contains('עבודה'), reason: 'the job engine entry');
    expect(wheel.labels.length, greaterThan(4), reason: 'many axes to start');

    // The first wheel already carries a live gallery beneath it.
    expect(find.byType(GridView), findsOneWidget, reason: 'live gallery');

    // Pick the first real axis (slot 2) → its VALUE wheel (still + gallery).
    wheel.onSelect!(2);
    await tester.pump();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels, isNotEmpty, reason: 'the axis has values to pick');
    expect(find.byType(GridView), findsOneWidget, reason: 'value-wheel gallery');

    // Pick its first value → a constraint is added, back to the axis selector.
    wheel.onSelect!(0);
    await tester.pump();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels.first, contains('הצג'),
        reason: 'after a value we are back on the axis selector');

    // Tap "📋 הצג" → the full products GRID (images), no wheel.
    wheel.onSelect!(0);
    await tester.pump();
    expect(find.byType(RingDiveWheel), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(InkWell), findsWidgets, reason: 'tappable photo tiles');
  });

  testWidgets('the value wheel previews the focused value live (onFocusChanged)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogWheelScreen()));
    await tester.pump();
    var wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));

    // Into a value wheel.
    wheel.onSelect!(2);
    await tester.pump();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.onFocusChanged, isNotNull,
        reason: 'the wheel reports the focused index as it spins');

    // Spin lands on the first value → the gallery header previews it.
    wheel.onFocusChanged!(0);
    await tester.pump();
    expect(find.textContaining('תצוגה מקדימה'), findsOneWidget,
        reason: 'spinning previews the focused value under the wheel');
  });

  testWidgets('engine 3 — לפי עבודה → category → job → kit', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogWheelScreen()));
    await tester.pump();

    // Slot 1 = "🔧 לפי עבודה" → the job categories.
    var wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    wheel.onSelect!(1);
    await tester.pump();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels, isNotEmpty, reason: 'the job categories');

    // Category → its jobs.
    wheel.onSelect!(0);
    await tester.pump();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels, isNotEmpty, reason: 'jobs in the category');

    // Job → its assembled kit (a list of parts).
    wheel.onSelect!(0);
    await tester.pump();
    expect(find.byType(RingDiveWheel), findsNothing);
    expect(find.byType(ListView), findsOneWidget, reason: 'the kit list');
    expect(find.byType(ListTile), findsWidgets, reason: 'the kit parts');
  });
}
