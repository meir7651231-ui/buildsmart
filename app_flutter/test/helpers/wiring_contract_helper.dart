/// wiring_contract_helper.dart
///
/// Helpers for asserting WIRING.md contracts in tests.
///
/// Every row in WIRING.md with status ✅ should have a corresponding
/// call to [expectWired] in wiring_test.dart.
/// Every row with ⛔ documents WHY it's blocked via [expectBlocked].
///
/// Usage:
///   WiringContractHelper.expectWired(
///     'currentRank dial leaf — shows rank by order count',
///     currentRank(0),
///     Rank.newcomer,
///   );
///   WiringContractHelper.expectBlocked(
///     'AI hub — 9 tools',
///     reason: 'backend required: AI inference endpoint not available',
///   );

import 'package:flutter_test/flutter_test.dart';

abstract final class WiringContractHelper {
  /// Asserts a wired behavior contract.
  ///
  /// [behavior]  — human-readable description matching WIRING.md row.
  /// [actual]    — the actual value returned by the implementation.
  /// [expected]  — the expected value per the contract.
  ///
  /// On failure, the message includes [behavior] so CI output maps
  /// directly to the WIRING.md row that broke.
  static void expectWired<T>(
    String behavior,
    T actual,
    T expected,
  ) {
    expect(
      actual,
      equals(expected),
      reason: 'WIRING contract failed: "$behavior"\n'
          '  expected: $expected\n'
          '  actual:   $actual',
    );
  }

  /// Asserts a wired behavior using a custom Matcher.
  ///
  /// Use when simple equality is not sufficient (e.g. `isNotEmpty`, `greaterThan(0)`).
  static void expectWiredThat<T>(
    String behavior,
    T actual,
    dynamic matcher,
  ) {
    expect(
      actual,
      matcher,
      reason: 'WIRING contract failed: "$behavior"\n'
          '  actual: $actual',
    );
  }

  /// Documents a ⛔ blocked behavior.
  ///
  /// This is not a real assertion — it always passes — but it:
  /// 1. Prints the behavior + reason to test output so CI is self-documenting.
  /// 2. Marks the feature as intentionally NOT implemented yet.
  /// 3. Signals that no code covers this path (so regressions are caught later).
  ///
  /// [behavior] — the WIRING.md row label.
  /// [reason]   — WHY it's blocked (backend / geo / data / telephony / etc.)
  static void expectBlocked(String behavior, {required String reason}) {
    // Always passes — documents the gap.
    // ignore: avoid_print
    print('⛔ WIRING blocked: "$behavior"\n   reason: $reason');
    expect(true, isTrue, reason: 'Placeholder for blocked: $behavior');
  }

  /// Asserts that a list of leaf labels are all present in an iterable.
  ///
  /// Useful for verifying that a dial contains exactly the expected leaves.
  static void expectLeafLabels(
    String behavior,
    Iterable<String> actualLabels,
    List<String> expectedLabels,
  ) {
    for (final label in expectedLabels) {
      expect(
        actualLabels,
        contains(label),
        reason: 'WIRING contract "$behavior": expected leaf "$label" '
            'to be present.',
      );
    }
    expect(
      actualLabels.length,
      equals(expectedLabels.length),
      reason: 'WIRING contract "$behavior": expected ${expectedLabels.length} '
          'leaves but found ${actualLabels.length}.',
    );
  }
}
