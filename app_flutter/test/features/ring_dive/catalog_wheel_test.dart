// CatalogWheel — proves the "pick any wheel" flow drives end-to-end: the axis
// selector offers ≥2 axes, picking one shows its values, picking a value adds a
// constraint, and the products list is reachable.
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
    // The size super-axis is really split into distinct axes — diameter itself
    // split by measuring system (inch / DN / mm), plus length + transition.
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

  testWidgets('axis wheel → value wheel → constraint → products', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogWheelScreen()));
    await tester.pumpAndSettle();

    // Ring 1 = the axis selector. Option 0 is "📋 הצג", the rest are axes.
    var wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels.first, contains('הצג'));
    expect(wheel.labels.length, greaterThan(3), reason: 'many axes to start from');

    // Pick the first real axis (index 1) → its VALUE wheel appears.
    wheel.onSelect!(1);
    await tester.pumpAndSettle();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels, isNotEmpty, reason: 'the axis has values to pick');

    // Pick its first value → a constraint is added, back to the axis selector.
    wheel.onSelect!(0);
    await tester.pumpAndSettle();
    wheel = tester.widget<RingDiveWheel>(find.byType(RingDiveWheel));
    expect(wheel.labels.first, contains('הצג'),
        reason: 'after a value we are back on the axis selector');

    // Tap "📋 הצג" → the products list.
    wheel.onSelect!(0);
    await tester.pumpAndSettle();
    expect(find.byType(RingDiveWheel), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });
}
