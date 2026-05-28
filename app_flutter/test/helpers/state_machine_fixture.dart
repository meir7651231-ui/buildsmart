/// state_machine_fixture.dart
///
/// Generic fixture for testing pure state-machine transition functions.
///
/// Matches PROTOCOL.md §9 — every state machine needs unit tests for
/// every (state, action) → next_state cell in the transition matrix.
///
/// Usage:
///   final fixture = StateMachineFixture<OrderStage, OrderAction>(
///     transition: (s, a) => orderTransition(mockOrder(s), a, UserRole.store).next,
///   );
///   fixture.expectTransition(OrderStage.newOrder, OrderAction.confirm, OrderStage.confirmed);
///   fixture.expectBlocked(OrderStage.newOrder, OrderAction.ship);

import 'package:flutter_test/flutter_test.dart';

/// A fixture that wraps a pure transition function and provides
/// assertion helpers for building exhaustive state-machine tests.
///
/// [S] — state type (e.g. enum OrderStage)
/// [A] — action type (e.g. enum OrderAction)
/// [R] — result type returned by [transition]; often the next [S],
///        but can be a richer result object (e.g. OrderTransitionResult).
class StateMachineFixture<S, A, R> {
  StateMachineFixture({required this.transition});

  /// Pure transition function. Must have no side-effects.
  /// Signature: (currentState, action) → result
  final R Function(S state, A action) transition;

  /// Asserts that transitioning [from] via [action] produces [to].
  void expectTransition(S from, A action, R to) {
    final result = transition(from, action);
    expect(
      result,
      equals(to),
      reason:
          'StateMachine: expected transition '
          '($from, $action) → $to but got $result',
    );
  }

  /// Asserts that transitioning [from] via [action] returns null,
  /// indicating a blocked / forbidden transition.
  ///
  /// Use when [R] is nullable (e.g. `S? transition(S, A)`).
  void expectBlocked(S from, A action) {
    final result = transition(from, action);
    expect(
      result,
      isNull,
      reason:
          'StateMachine: expected transition ($from, $action) to be blocked '
          '(null) but got $result',
    );
  }

  /// Asserts that transitioning [from] via [action] throws any [Exception].
  /// Use when the transition function signals failure via exceptions.
  void expectThrows(S from, A action) {
    expect(
      () => transition(from, action),
      throwsA(isA<Exception>()),
      reason:
          'StateMachine: expected transition ($from, $action) to throw '
          'but it returned normally.',
    );
  }

  /// Bulk-tests a matrix of (from, action, expected) tuples.
  ///
  /// Pass `null` as the expected result to assert a blocked transition.
  ///
  /// Example:
  /// ```dart
  /// fixture.testAllTransitions([
  ///   (OrderStage.newOrder, OrderAction.confirm, OrderStage.confirmed),
  ///   (OrderStage.newOrder, OrderAction.ship,    null),  // blocked
  /// ]);
  /// ```
  void testAllTransitions(List<(S, A, R?)> matrix) {
    for (final (from, action, expected) in matrix) {
      if (expected == null) {
        expectBlocked(from, action);
      } else {
        expectTransition(from, action, expected);
      }
    }
  }

  /// Asserts that [allowedActions] are all valid from [state],
  /// and [blockedActions] all produce null from [state].
  void expectValidActionsFrom(
    S state, {
    List<A> allowedActions = const [],
    List<A> blockedActions = const [],
  }) {
    for (final action in allowedActions) {
      final result = transition(state, action);
      expect(
        result,
        isNotNull,
        reason:
            'StateMachine: expected action $action to be allowed from '
            '$state but got null.',
      );
    }
    for (final action in blockedActions) {
      final result = transition(state, action);
      expect(
        result,
        isNull,
        reason:
            'StateMachine: expected action $action to be blocked from '
            '$state but got $result.',
      );
    }
  }
}
