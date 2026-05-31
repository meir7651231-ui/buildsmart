import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One entry in the in-memory "last actions" log used by the future undo
/// affordance. In-memory only — never persisted (mirrors crash_log.dart).
@immutable
class UserAction {
  const UserAction({required this.kind, required this.label, required this.at});

  /// Machine-readable category, e.g. 'brand-pick', 'add-to-project'.
  final String kind;

  /// Short human-readable description shown in UI.
  final String label;

  /// Timestamp the action was recorded at.
  final DateTime at;
}

/// Bounded-list notifier holding the most recent [UserAction]s, newest first.
/// Same shape as [CrashLogNotifier] in `crash_log.dart`.
class LastActionNotifier extends StateNotifier<List<UserAction>> {
  LastActionNotifier({this.maxEntries = 50}) : super(const []);

  final int maxEntries;

  /// Add a new action to the **front** (newest first) and trim to [maxEntries].
  void record({required String kind, required String label}) {
    final entry = UserAction(kind: kind, label: label, at: DateTime.now());
    final next = <UserAction>[entry, ...state];
    if (next.length > maxEntries) {
      state = next.sublist(0, maxEntries);
    } else {
      state = next;
    }
  }

  void clear() {
    state = const [];
  }

  /// Newest action, or `null` when the log is empty.
  UserAction? get latest => state.isEmpty ? null : state.first;

  /// Count of entries whose [UserAction.kind] exactly equals [kind].
  int countByKind(String kind) =>
      state.where((a) => a.kind == kind).length;
}

final lastActionProvider =
    StateNotifierProvider<LastActionNotifier, List<UserAction>>(
  (_) => LastActionNotifier(),
);
