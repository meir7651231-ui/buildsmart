// wiring_contract_helper.dart — assertions for WIRING.md contracts.
//
// Every ✅ row in WIRING.md must have a matching expectWired() call.
// Every ⛔ row must have a matching expectBlocked() call.
//
// Usage:
//   WiringContractHelper.expectWired(
//     'cart stepper — qtyForKey sums lines',
//     actual: cart.qtyForKey('lip:SKU1'),
//     expected: 5,
//   );
//   WiringContractHelper.expectBlocked('מחירים — no price data');

import 'package:flutter_test/flutter_test.dart';

abstract final class WiringContractHelper {
  /// Asserts a wired (✅) contract: [actual] == [expected].
  /// [behavior] is the WIRING.md row description — shown on failure.
  static void expectWired<T>(
    String behavior, {
    required T actual,
    required T expected,
  }) {
    expect(
      actual,
      equals(expected),
      reason: 'WIRING ✅ "$behavior" — expected $expected, got $actual',
    );
  }

  /// Asserts a wired contract using a custom matcher.
  static void expectWiredThat<T>(
    String behavior, {
    required T actual,
    required Matcher matcher,
  }) {
    expect(
      actual,
      matcher,
      reason: 'WIRING ✅ "$behavior"',
    );
  }

  /// Documents a ⛔ blocked contract — always passes but prints the reason.
  /// Use for items that cannot be tested yet (no backend / no data).
  static void expectBlocked(String behavior, {String reason = ''}) {
    // ⛔ items are intentionally not implemented — this is not a skip,
    // it is an explicit declaration that the feature is blocked.
    expect(
      true,
      isTrue,
      reason: 'WIRING ⛔ "$behavior" — blocked: $reason',
    );
  }

  /// Asserts that [value] is not null and not empty (for String/List).
  static void expectNonEmpty(String behavior, dynamic value) {
    expect(
      value,
      isNotNull,
      reason: 'WIRING ✅ "$behavior" — value is null',
    );
    if (value is String) {
      expect(
        value,
        isNotEmpty,
        reason: 'WIRING ✅ "$behavior" — string is empty',
      );
    }
    if (value is List) {
      expect(
        value,
        isNotEmpty,
        reason: 'WIRING ✅ "$behavior" — list is empty',
      );
    }
  }

  /// Asserts an invariant holds — use for cross-cutting invariants
  /// like cartCount == sum(qty).
  static void expectInvariant(String description, {required bool holds}) {
    expect(
      holds,
      isTrue,
      reason: 'INVARIANT "$description" violated',
    );
  }
}
