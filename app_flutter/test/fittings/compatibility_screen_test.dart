// 🔑 Phase E-lite slice 2 — compatibility screen smoke: the gated screen shows a
// ✓/✗ row per candidate and never crashes. Thin shell over the M5-clean capability.
import 'package:buildsmart/features/fittings/intel/compatibility_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the demo compatibility screen builds with ✓/✗ rows, no exception',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    await tester.pumpWidget(const MaterialApp(home: CompatibilityScreen()));
    // one row per candidate in the demo universe (3), each carrying ✓ or ✗
    final marks = find.byWidgetPredicate(
      (w) => w is Text && (w.data == '✓' || w.data == '✗'),
    );
    expect(marks, findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
