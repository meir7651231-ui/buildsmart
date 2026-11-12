// Maintenance module — the manager's home screen: every control the gate
// flagged has a tap area of at least 44 dp in height (build order 1, part ב).
// Measured on the real board at 390 × 844 with the demo data.

import 'package:buildsmart/features/maintenance/mx_screens.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home: the five flagged controls are ≥ 44 dp tall', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        mxClockProvider.overrideWithValue(() => DateTime(2026, 11, 12, 10)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MxApp()),
    );
    await tester.pumpAndSettle();

    double tall(Finder f) {
      expect(f, findsOneWidget);
      return tester.getSize(f).height;
    }

    // 1 · the role chip ("תפקיד: מנהל. החלפת תפקיד") — was 36.
    expect(tall(find.byKey(const Key('mx-roles'))), greaterThanOrEqualTo(44));
    // 2–4 · the calm "אין …" chips — were 33.
    for (final k in ['kpi-wo', 'kpi-urgent', 'kpi-po']) {
      final f = find.byKey(Key(k));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      expect(tall(f), greaterThanOrEqualTo(44), reason: k);
    }
    // 5 · a scheduled-inspection row in "היום" — the gate read 24 because the
    // row was cut by the bottom edge; its full tap area is the list tile.
    final row = find.ancestor(
      of: find.text('לחיצת בדיקה – ממסרי פחת'),
      matching: find.byType(ListTile),
    );
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    expect(tall(row), greaterThanOrEqualTo(44));
  });
}
