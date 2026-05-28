// ignore_for_file: avoid_print // test helper — debugPrint not needed here

// dial_test_helper.dart — standard test harness for all dial widgets.
// Guarantees: RTL wrap · ProviderScope isolation · R2 leak detection.
//
// Usage:
//   await DialTestHelper.pumpDial(tester, MyFeatureDial());
//   DialTestHelper.expectDialLeaf(tester, 'דרגה');
//   DialTestHelper.expectNoFullScreen(tester);

import 'package:buildsmart/widgets/dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in ProviderScope + MaterialApp + RTL for isolated dial tests.
Widget dialTestShell(Widget child) => ProviderScope(
      child: MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

abstract final class DialTestHelper {
  /// Pumps [dialWidget] in the standard isolated shell and settles.
  static Future<void> pumpDial(
    WidgetTester tester,
    Widget dialWidget,
  ) async {
    await tester.pumpWidget(dialTestShell(dialWidget));
    await tester.pumpAndSettle();
  }

  /// Asserts a dial leaf with [label] text is present.
  static void expectDialLeaf(WidgetTester tester, String label) {
    expect(
      find.text(label),
      findsAtLeastNWidgets(1),
      reason: 'Expected dial leaf "$label"',
    );
  }

  /// Asserts exactly [count] DialRow widgets are rendered.
  static void expectDialLeafCount(WidgetTester tester, int count) {
    expect(
      find.byType(DialRow),
      findsNWidgets(count),
      reason: 'Expected $count DialRow widgets',
    );
  }

  /// Taps a dial leaf by label and settles.
  static Future<void> tapDialLeaf(
    WidgetTester tester,
    String label,
  ) async {
    await tester.tap(find.text(label).first);
    await tester.pumpAndSettle();
  }

  /// R2 check: only the test shell Scaffold is allowed — no new ones.
  static void expectNoFullScreen(WidgetTester tester) {
    final count = find.byType(Scaffold).evaluate().length;
    expect(
      count,
      lessThanOrEqualTo(1),
      reason:
          'R2 violation: $count Scaffold(s) found — '
          'new features must not add Scaffold',
    );
  }

  /// Asserts leaf [label] is absent (for ⛔ blocked items).
  static void expectNoDialLeaf(WidgetTester tester, String label) {
    expect(
      find.text(label),
      findsNothing,
      reason: 'Expected "$label" to be absent',
    );
  }

  /// Taps [parentLabel] and asserts [expectedChildren] appear.
  static Future<void> drillInto(
    WidgetTester tester,
    String parentLabel,
    List<String> expectedChildren,
  ) async {
    await tapDialLeaf(tester, parentLabel);
    for (final child in expectedChildren) {
      expectDialLeaf(tester, child);
    }
  }
}
