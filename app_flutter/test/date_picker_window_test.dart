// Nightly 2026-11-18 — editing a task whose planned start is outside the ±2y
// picker window threw ("initialDate must be on or after firstDate") instead of
// opening the date picker. `datePickerWindow` always contains the stored date.
import 'dart:async';

import 'package:buildsmart/logic/date_picker_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 18, 14, 30);

  group('datePickerWindow', () {
    test('no stored date ⇒ ±2y around today, initial = today (date-only)', () {
      final w = datePickerWindow(null, now);
      expect(w.initial, DateTime(2026, 11, 18));
      expect(w.first, DateTime(2024, 11, 18));
      expect(w.last, DateTime(2028, 11, 18));
    });

    test('stored date inside the window leaves the bounds alone', () {
      final w = datePickerWindow(DateTime(2026, 1, 5), now);
      expect(w.initial, DateTime(2026, 1, 5));
      expect(w.first, DateTime(2024, 11, 18));
      expect(w.last, DateTime(2028, 11, 18));
    });

    test('stored date 3 years ago stretches firstDate to it', () {
      final w = datePickerWindow(DateTime(2023, 6, 1, 9), now);
      expect(w.initial, DateTime(2023, 6));
      expect(w.first, DateTime(2023, 6));
      expect(w.last, DateTime(2028, 11, 18));
    });

    test('stored date 5 years ahead stretches lastDate to it', () {
      final w = datePickerWindow(DateTime(2031, 2), now);
      expect(w.first, DateTime(2024, 11, 18));
      expect(w.last, DateTime(2031, 2));
    });

    test('invariant first <= initial <= last over a wide sweep', () {
      for (var y = 1990; y <= 2070; y += 3) {
        for (final m in [1, 2, 6, 12]) {
          final w = datePickerWindow(DateTime(y, m, 28, 23, 59), now);
          expect(w.first.isAfter(w.initial), isFalse, reason: '$y-$m');
          expect(w.initial.isAfter(w.last), isFalse, reason: '$y-$m');
        }
      }
    });
  });

  testWidgets('showDatePicker opens on an old stored date (no assert)', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final w = datePickerWindow(DateTime(2021, 3, 10), DateTime.now());
    unawaited(
      showDatePicker(
        context: ctx,
        initialDate: w.initial,
        firstDate: w.first,
        lastDate: w.last,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
