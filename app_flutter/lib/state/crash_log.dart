import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One error/diagnostic entry. In-memory only — never persisted, since error
/// payloads may carry sensitive context. Roadmap step 90 (in-app log only;
/// external telemetry like Sentry/Crashlytics is a separate wall-step).
@immutable
class CrashEntry {
  const CrashEntry({required this.message, required this.at, this.context});
  final String message;
  final String? context;
  final DateTime at;
}

class CrashLogNotifier extends StateNotifier<List<CrashEntry>> {
  CrashLogNotifier({this.maxEntries = 200}) : super(const []);

  final int maxEntries;

  /// Add a new entry to the **front** (newest first) and trim to [maxEntries].
  void record(String message, {String? context}) {
    final entry = CrashEntry(
        message: message, context: context, at: DateTime.now());
    final next = <CrashEntry>[entry, ...state];
    if (next.length > maxEntries) {
      state = next.sublist(0, maxEntries);
    } else {
      state = next;
    }
  }

  void clear() {
    state = const [];
  }

  /// Number of entries whose context contains [contextFilter]. When
  /// [contextFilter] is null, returns the total length.
  int countBy({String? contextFilter}) {
    if (contextFilter == null) return state.length;
    return state
        .where((e) => (e.context ?? '').contains(contextFilter))
        .length;
  }
}

final crashLogProvider =
    StateNotifierProvider<CrashLogNotifier, List<CrashEntry>>(
  (_) => CrashLogNotifier(),
);
