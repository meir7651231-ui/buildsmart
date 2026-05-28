// state_machine_fixture.dart — generic fixture for exhaustive state-machine tests.
//
// Usage:
//   final f = StateMachineFixture<OrderStage, OrderAction, OrderStage?>(
//     transition: (s, a) => orderTransition(s, a),
//   );
//   f.expectTransition(OrderStage.newOrder, OrderAction.confirm, OrderStage.confirmed);
//   f.expectBlocked(OrderStage.newOrder, OrderAction.ship);
//   f.testAllTransitions([...]);

import 'package:flutter_test/flutter_test.dart';

/// Generic fixture for testing pure state-machine transition functions.
///
/// [S] — state type  (e.g. enum OrderStage)
/// [A] — action type (e.g. enum OrderAction)
/// [R] — result type — often the next [S], but can be a richer object.
///        Use [R] = `S?` where null means "blocked / forbidden".
class StateMachineFixture<S, A, R> {
  const StateMachineFixture({required this.transition});

  /// Pure transition function — no side-effects.
  final R Function(S state, A action) transition;

  /// Asserts (state, action) → [expected].
  void expectTransition(S state, A action, R expected) {
    final result = transition(state, action);
    expect(
      result,
      equals(expected),
      reason: 'transition($state, $action) → expected $expected, got $result',
    );
  }

  /// Asserts (state, action) → null (blocked / forbidden).
  /// Only valid when [R] is nullable.
  void expectBlocked(S state, A action) {
    final result = transition(state, action);
    expect(
      result,
      isNull,
      reason: 'transition($state, $action) should be blocked (null), got $result',
    );
  }

  /// Asserts (state, action) throws any Exception.
  void expectThrows(S state, A action) {
    expect(
      () => transition(state, action),
      throwsA(isA<Exception>()),
      reason: 'transition($state, $action) should throw',
    );
  }

  /// Bulk-tests a matrix of (from, action, expected) records.
  /// Pass null as expected to assert a blocked transition.
  ///
  /// Example:
  /// ```dart
  /// f.testAllTransitions([
  ///   (OrderStage.newOrder, OrderAction.confirm, OrderStage.confirmed),
  ///   (OrderStage.newOrder, OrderAction.ship,    null), // blocked
  /// ]);
  /// ```
  void testAllTransitions(List<(S, A, R?)> matrix) {
    for (final (state, action, expected) in matrix) {
      if (expected == null) {
        expectBlocked(state, action);
      } else {
        expectTransition(state, action, expected);
      }
    }
  }

  /// Asserts all [allowed] actions are non-null from [state],
  /// and all [blocked] actions are null.
  void expectActionsFrom(
    S state, {
    List<A> allowed = const [],
    List<A> blocked = const [],
  }) {
    for (final action in allowed) {
      final result = transition(state, action);
      expect(
        result,
        isNotNull,
        reason: 'action $action should be allowed from $state',
      );
    }
    for (final action in blocked) {
      final result = transition(state, action);
      expect(
        result,
        isNull,
        reason: 'action $action should be blocked from $state',
      );
    }
  }
}
