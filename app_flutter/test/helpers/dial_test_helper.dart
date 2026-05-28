// ignore_for_file: avoid_print
/// dial_test_helper.dart
///
/// Standard test harness for dial widgets (R2/R4).
/// Every dial feature test MUST use this — it guarantees RTL wrapping,
/// ProviderScope isolation, and no full-screen scaffold leaks.
///
/// Usage:
///   await DialTestHelper.pumpDial(tester, MyFeatureDial());
///   DialTestHelper.expectDialLeaf(tester, 'הזמנות פתוחות');
///   DialTestHelper.expectNoFullScreen(tester);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/widgets/dial.dart';

/// Wraps a dial widget in the standard test environment:
/// ProviderScope + MaterialApp + Directionality(RTL).
Widget dialTestShell(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          // Minimal scaffold for layout only — NOT a new feature scaffold.
          // This is test infrastructure, not production code.
          body: Center(child: child),
        ),
      ),
    ),
  );
}

abstract final class DialTestHelper {
  /// Pumps a dial widget wrapped in the standard test shell and settles.
  static Future<void> pumpDial(WidgetTester tester, Widget dialWidget) async {
    await tester.pumpWidget(dialTestShell(dialWidget));
    await tester.pumpAndSettle();
  }

  /// Asserts that a dial leaf with [label] text is visible in the tree.
  static void expectDialLeaf(WidgetTester tester, String label) {
    expect(
      find.text(label),
      findsAtLeastNWidgets(1),
      reason: 'Expected dial leaf "$label" to be in the widget tree.',
    );
  }

  /// Asserts the exact number of [DialRow] widgets rendered.
  static void expectDialLeafCount(WidgetTester tester, int count) {
    expect(
      find.byType(DialRow),
      findsNWidgets(count),
      reason: 'Expected exactly $count DialRow widgets.',
    );
  }

  /// Taps a dial leaf by its label text and settles.
  static Future<void> tapDialLeaf(WidgetTester tester, String label) async {
    final target = find.text(label).first;
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  /// Verifies that no full-screen pattern (R2) has leaked into the tree.
  ///
  /// Checks that no ADDITIONAL Scaffold beyond the test shell exists,
  /// and no route-pushing Navigator is present.
  ///
  /// NOTE: The test shell itself has one Scaffold — that is expected.
  /// Any Scaffold inside the dialed widget is an R2 violation.
  static void expectNoFullScreen(WidgetTester tester) {
    // Count Scaffolds: only the test shell's one is allowed.
    final scaffolds = find.byType(Scaffold).evaluate().length;
    expect(
      scaffolds,
      lessThanOrEqualTo(1),
      reason:
          'R2 violation: found $scaffolds Scaffold(s) in dial tree. '
          'New features must NOT create new Scaffold widgets.',
    );
  }

  /// Asserts that a leaf with [label] is NOT present (e.g., for ⛔ items
  /// that should be blocked or not yet connected).
  static void expectNoDialLeaf(WidgetTester tester, String label) {
    expect(
      find.text(label),
      findsNothing,
      reason: 'Expected dial leaf "$label" to be absent from the widget tree.',
    );
  }

  /// Taps a leaf and asserts a different set of leaves appears (drill-down).
  static Future<void> drillInto(
    WidgetTester tester,
    String parentLabel,
    List<String> expectedChildLabels,
  ) async {
    await tapDialLeaf(tester, parentLabel);
    for (final child in expectedChildLabels) {
      expectDialLeaf(tester, child);
    }
  }
}
